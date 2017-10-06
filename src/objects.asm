; Object struct

; - Byte 0: object state: 0: off; 1: switching on / dead / destroyed; 2: on; 3-255: TBD 
; - Byte 1: Object-specific properties.
; 2 bytes per object in the level, 128 max objects per level: 256 bytes

OBJECT_DATA: EQU $FF00

; Object types
OBJECT_NONE		EQU 0
OBJECT_SWITCH		EQU 1
OBJECT_DOOR		EQU 2
OBJECT_DOOR_DESTROY	EQU 3
OBJECT_FLOOR_DESTROY	EQU 4
OBJECT_WALL_DESTROY	EQU 5
OBJECT_BOX_LEFT		EQU 6
OBJECT_BOX_RIGHT	EQU 7
OBJECT_JAR		EQU 8
OBJECT_TELEPORTER	EQU 9
; Pickable object types
OBJECT_KEY_GREEN	EQU 11
OBJECT_KEY_BLUE     EQU 12
OBJECT_KEY_YELLOW	EQU 13
OBJECT_BREAD		EQU 14
OBJECT_MEAT		    EQU 15
OBJECT_HEALTH		EQU 16
OBJECT_KEY_RED		EQU 17
OBJECT_KEY_WHITE   	EQU 18
OBJECT_KEY_PURPLE	EQU 19
; Object types for enemies
OBJECT_ENEMY_SKELETON	EQU 20
OBJECT_ENEMY_ORC	EQU 21
OBJECT_ENEMY_MUMMY	EQU 22
OBJECT_ENEMY_TROLL	EQU 23
OBJECT_ENEMY_ROCK	EQU 24
OBJECT_ENEMY_KNIGHT EQU 25
OBJECT_ENEMY_DALGURAK EQU 26
OBJECT_ENEMY_GOLEM  EQU 27
OBJECT_ENEMY_OGRE   EQU 28
OBJECT_ENEMY_MINOTAUR EQU 29
OBJECT_ENEMY_DEMON    EQU 30
OBJECT_ENEMY_SECONDARY EQU 31

; functions for inactive objects
inactive_obj_functions: dw inactive_none, inactive_switch, inactive_door, inactive_door_destroy, inactive_floor_destroy, inactive_wall_destroy, inactive_box_left, inactive_box_right, inactive_jar, inactive_teleporter

; script ids per pickable object
scripts_per_pickable_object: db 8, 5, 3, 10, 4, 6, 9, 7, 11 ; FIXME check this!!!
tiles_per_pickable_object: db 217, 218, 219, 220, 221, 222, 223, 224, 225

; Init object table
; Basically clean it up.
;
; INPUT: none
InitObjectTable:
	ld hl, OBJECT_DATA
	ld de, OBJECT_DATA+1
	xor a
	ld (hl), a
	ld bc, 255
	ldir
	ret

; Load objects in a room
; INPUT:
;	- IX: pointer to object definition

LoadObjects:
	inc ix		; skip the player script
LoadObjects_enemy1:
	ld iy, ENTITY_ENEMY1_POINTER
	call load_enemy	
	jr nc, LoadObjects_enemy2
	ld bc, 12
	jr LoadObjects_object1_add
LoadObjects_enemy2:
	ld bc, 6
	add ix, bc	; go to enemy 2
	ld iy, ENTITY_ENEMY2_POINTER
	call load_enemy
LoadObjects_object1:
	ld bc, 6
LoadObjects_object1_add:
	add ix, bc	; go to object 1
	ld iy, ENTITY_OBJECT1_POINTER
	call load_object
LoadObjects_object2:
	ld bc, 6
	add ix, bc	; go to object 2
	ld iy, ENTITY_OBJECT2_POINTER
	call load_object
LoadObjects_object3:
	ld bc, 6
	add ix, bc	; go to object 3
	ld iy, ENTITY_OBJECT3_POINTER
	call load_object
LoadObjects_object4:
	ld bc, 6
	add ix, bc	; go to object 4
	ld iy, ENTITY_OBJECT4_POINTER
	call load_object
LoadObjects_object5:
	ld bc, 6
	add ix, bc	; go to object 5
	ld iy, ENTITY_OBJECT5_POINTER
	call load_object
	; Cleanup scratch area for scripts here
	ld hl, scratch_area_player
	ld de, scratch_area_player+1
	xor a
	ld (hl), a
	ld bc, 63
	ldir
	ret

; Load an enemy
; INPUT:
;	- IX: pointer to enemy definition
;	- IY: pointer to enemy entity
; RETURNS:
;	- Carry flag set: there was a secondary enemy. Reset: no secondary enemy

load_enemy:
	ld a, (ix+1)	; object type
	and a		; if 0, object is not present
	jr nz, load_enemy_present
load_enemy_not_present:
	xor a
	ld (iy+0), a
	ld (iy+1), a	; Sprite address is 0000, so no enemy
	ld (iy+4), a	; no energy
	ret
load_enemy_present:
	; first, check object id and see if there is any energy left. Otherwise, do not create object.
	ld a, (ix+0)	; get the object id
	add a, a	; *2 to index the array
	ld h, $FF
	ld l, a		; address the array
	ld a, (hl)	; get the object state. For enemies, 0 will mean still alive, non-zero will mean dead
	and a
	jr nz, load_enemy_not_present	; if non-zero, no enemy to load
	push hl
	; Enemy there, lets get ready
	call NewSprite		; get address of new sprite in HL	
	ld a, h
	or l			; if HL=0, cannot create new sprites. THIS SHOULD NOT HAPPEN!
	jr z, load_enemy_not_present
	ld a, l
	ld (iy+0), a
	ld a, h
	ld (iy+1), a		; store sprite address	
	ld de, enemy_base_sprite
	ld (hl), e
	inc hl
	ld (hl), d		; Store animation position
	inc hl			
	ld (hl), SPR_24x32_MIRROR	; sprite type
	inc hl
	ld a, (ix+2)		; X, in stile coords. We need to multiply by 16
	add a, a		; *2
	add a, a		; *4
	add a, a		; *8
	add a, a		; *16
	ld (hl), a		; X
	inc hl
	ld a, (ix+3)		; Y, in stile coords. We need to multiply by 16
	add a, a		; *2
	add a, a		; *4
	add a, a		; *8
	add a, a		; *16
	ld (hl), a		; Y
	inc hl
	ld (hl), 3		; 3 chars in X	FIXME should we consider different sizes??? Maybe depending on the enemy type
	inc hl
	ld (hl), 4		; 4 chars in Y FIXME should we consider different sizes??? Maybe depending on the enemy type
	inc hl
	ld (hl), 1		; redraw
	pop hl
	inc hl			; point to the energy value

	ld a, (ix+1)		; object type
	sub OBJECT_ENEMY_SKELETON ; make it base 0
	rlca
	rlca
	rlca
	rlca			; move to the high nibble
	or (ix+4)		; A = enemy_type | enemy_level
	ld (iy+10), a		; and store it!

	call get_entity_max_energy
	ld (iy+4), a		; store the enemy energy in A

	ld a, (ix+5)		; script id
	ld (iy+2), a		; store script id
	ld (iy+3), 0		; and set 0 as the current address in script
	ld a, (ix+0)		; object id
	ld (iy+9), a		; and store it
	; Now, lets check if this enemy requires a secondary entity
	ld a, (ix+1)		; object type
	cp OBJECT_ENEMY_GOLEM
	jr z, load_enemy_secondary
	cp OBJECT_ENEMY_OGRE
	jr z, load_enemy_secondary
	cp OBJECT_ENEMY_MINOTAUR
	jr z, load_enemy_secondary
	cp OBJECT_ENEMY_DEMON
	jr z, load_enemy_secondary
	xor a				; No secondary enemy
	ret
load_enemy_secondary:
	push ix
	ld iy, ENTITY_ENEMY2_POINTER
	call NewSprite		; get address of new sprite in HL	
	ld a, h
	or l			; if HL=0, cannot create new sprites. THIS SHOULD NOT HAPPEN!
	jp z, load_enemy_not_present
	ld (iy+0), l
	ld (iy+1), h		; store sprite address	
	ld (iy+2), 2		; script id for ACTION_SECONDARY
	xor a
	ld (iy+3), a		; script position
	ld (iy+4), a		; energy
	ld (iy+5), STATE_SECONDARY_LEFT
	ld (iy+6), a		; animation position
	ld (iy+7), a
	ld (iy+10), OBJECT_ENEMY_SECONDARY*16-OBJECT_ENEMY_SKELETON*16
	; now the sprite
	ld ix, ENTITY_ENEMY1_POINTER
	ld e, (ix+0)
	ld d, (ix+1)		; DE has the original sprite
	ld ixh, d
	ld ixl, e			; IX: original sprite
	ex de, hl
	ld iyh, d
	ld iyl, e			; IY: new sprite
	ld a, (ix+2)
	ld (iy+2), a		; sprite type
	ld a, (ix+3)
	ld (iy+3), a		; xpos
	ld a, (ix+4)
	sub 32
	ld (iy+4), a		; ypos
	ld e, (ix+0)
	ld d, (ix+1)		; sprite address. The sprite for the secondary one is primary+3936
	ld hl, 3936
	add hl, de	
	ld (iy+0), l
	ld (iy+1), h		; and place in the sprite
	ld a, (ix+5)
	ld (iy+5), a		; x chars
	ld a, (ix+6)
	ld (iy+6), a		; y chars
	ld (iy+7),1			; force redraw
	pop ix
	scf					; there is a secondary enemy
	ret


; Load an object
; INPUT:
;	- IX: pointer to object definition
;	- IY: pointer to object entity

load_object:
	ld a, (ix+1)	; object type
	and a		; if 0, object is not present
	jr nz, load_object_present
load_object_not_present:
	xor a
	ld (iy+0), a
	ld (iy+1), a	; Sprite address is 0000, so no object
	ld (iy+4), a	; no energy
	ret
load_object_present:
	; common object load 
	ld (iy+0), $ff
	ld (iy+1), $ff		; Objects will use $ffff as the sprite address (unused)
	ld a, (ix+0)		; Object id
	ld (iy+5), a		; Store object id
	ld a, (ix+2)		; X in stile terms
	ld (iy+6), a		; and store
	ld a, (ix+3)		; Y in stile terms
	ld (iy+7), a		; and store
	ld a, (ix+1)
	ld (iy+8), a		; object type
	ld a, (ix+5)		; script id
	ld (iy+2), a		; store script id
	; first, check object id and see its state. If 0, it will be active, otherwise inactive
	ld a, (ix+0)	; get the object id
	add a, a	; *2 to index the array
	ld h, $FF
	ld l, a		; address the array
	ld a, (hl)	; get the object state. For objects, 0 will mean still alive (default), non-zero will mean inactive
	and a	
	jr nz, load_object_inactive	
load_object_active:
	ld a, (ix+4)		; energy
	ld (iy+4), a		;

	ld (iy+3), 0		; and set 0 as the current address in script
	ret
load_object_inactive:
	; This is the funny (and tricky) part. Inactive objects mean switches already switched on, doors already open... We need to do several things:
	; First, update the tiles accordingly, as if we were executing its state change
	; Second, update the hardness map 
	; Third, make sure the script offset is appropriate
	; and store the remaining properties

	; first some common stuff
	ld (iy+4), 0		; energy for inactive objects will always be 0
	ld a, (ix+1)		; retrieve object type
	add a, a		; *2 to index array
	ld c, a
	ld b, 0
	ld hl, inactive_obj_functions
	add hl, bc		; hl points to the function
	ld e, (hl)
	inc hl
	ld d, (hl)
	ld (load_object_inactive_call+1), de
load_object_inactive_call:
	call 0			; call the object-specific function to set the right properties
inactive_none:
	ret

; All inactive object functions receive the following parameters:
; INPUT:
;	- IX: pointer to object definition
;	- IY: pointer to object entity
; They must deal with the tilemap, hardness map and script offset

inactive_switch:
	; now, get back and update the supertile
	ld a, (iy+6) 	; X in stile coords
	ld b, a
	ld a, (iy+7)	; Y in stile coords
	ld c, a
	push bc
	ld hl, TILEMAP_SUPERTILES	; we need to address the map at C*16+B

	ld a, c
	rrca
	rrca
	rrca
	rrca		
	and $f0
	or b
	ld e, a
	ld d, 0			
	add hl, de	; HL now points to the supertile
	ld a, (hl)	; THIS is the supertile to increment
	add a, 2	; FIXME WE ARE ASSUMING TILES FOR SWITCHES TO BE ONE AFTER ANOTHER!!
	ld (hl), a	; save the updated supertile. Now we just have to update it on screen
	push af
	ld de, 16
	add hl, de	; go to next row
	ld a, (hl)
	add a, 2
	ld (hl), a	; and increase it as well
	ld (saveA), a
	pop af
	pop bc
	; As a last step, we should place the script offset accordingly. 
	; For switches, it will ALWAYS be 4, since their script must be: wait for condition, associated condition, turn switch, switch id
	ld (iy+3), 4		; and set 0 as the current address in script	
	ret

inactive_door_destroy:
	ld b, (iy+6) 	; X in stile coords
	ld c, (iy+7)	; Y in stile coords
;	dec a
;	ld c, a
	dec c

	ld hl, TILEMAP_SUPERTILES	; we need to address the map at C*16+B
	ld a, c
	rrca
	rrca
	rrca
	rrca		
	and $f0
	or b
	ld e, a
	ld d, 0			
	add hl, de	; HL now points to the supertile
	xor a
	ld de, 16
	ld (hl), a
	add hl, de
	ld (hl), a
	add hl, de
	ld (hl), a
	; now set the hardness to empty
	call SetHardness
	inc c
	xor a
	call SetHardness
	inc c
	xor a
	call SetHardness
	; As a last step, we should place the script offset accordingly. 
	; For breakable doors, deactivate script
deact_script:
	xor a
	ld (iy+3), a		; and set 0 as the current address in script	
    ld (iy+2), a        ; set script to ACTION_NONE
	ret

inactive_jar:
	ld b, (iy+6) 	; X in stile coords
	ld c, (iy+7)	; Y in stile coords

	ld hl, TILEMAP_SUPERTILES	; we need to address the map at C*16+B
	ld a, c
	rrca
	rrca
	rrca
	rrca		
	and $f0
	or b
	ld e, a
	ld d, 0			
	add hl, de	; HL now points to the supertile
	xor a
	ld de, 16
	ld (hl), a
	; now set the hardness to empty
	call SetHardness
	; As a last step, we should place the script offset accordingly. 
	; For jars, deactivate script
	jp deact_script


inactive_door:
	ld b, (iy+6) 	; X in stile coords
	ld a, (iy+7)	; Y in stile coords
	add a, 3
	ld c, a

	ld hl, TILEMAP_SUPERTILES	; we need to address the map at C*16+B
	ld a, c
	rrca
	rrca
	rrca
	rrca		
	and $f0
	or b
	ld e, a
	ld d, 0			
	add hl, de	; HL now points to the supertile
	ld a, (hl)
	ld de, -48
	add hl, de	; so it is the end of the door
	ld (hl), a
	ld de, 16
	add hl, de	; next line
	xor a
	ld (hl), a
	add hl, de
	ld (hl), a
	add hl, de
	ld (hl), a	; and set the remaining three chars as blank
	; now set the hardness to empty
	dec c
	dec c
	xor a
	call SetHardness
	inc c
	xor a
	call SetHardness
	inc c
	xor a
	call SetHardness
	; As a last step, we should place the script offset accordingly. 
	; For doors, it will ALWAYS be 4, since their script must be: wait for condition, associated condition, turn door, door id
	ld (iy+3), 4		; and set 0 as the current address in script	
	ret

inactive_floor_destroy:
inactive_wall_destroy:
inactive_teleporter:
	ret

inactive_box_left:
	ld b, (iy+6) 	; X in stile coords
	ld c, (iy+7)	; Y in stile coords
	ld hl, TILEMAP_SUPERTILES	; we need to address the map at C*16+B
	ld a, c
	rrca
	rrca
	rrca
	rrca		
	and $f0
	or b
	ld e, a
	ld d, 0			
	add hl, de	; HL now points to the supertile
	ld de, 16
	xor a	
	ld (hl), a
	inc hl
	ld (hl), a
	add hl, de
	ld (hl), a
	dec hl
	ld (hl), a	; and clean up the four boxes
	call SetHardness
	inc b
	xor a
	call SetHardness
	inc c
	xor a
	call SetHardness
	dec b
	xor a
	call SetHardness
	; As a last step, we should place the script offset accordingly. 
	; For boxes, deactivate script
	jp deact_script


inactive_box_right:
	ld b, (iy+6) 	; X in stile coords
	ld c, (iy+7)	; Y in stile coords
	ld hl, TILEMAP_SUPERTILES	; we need to address the map at C*16+B
	ld a, c
	rrca
	rrca
	rrca
	rrca		
	and $f0
	or b
	ld e, a
	ld d, 0			
	add hl, de	; HL now points to the supertile
	ld de, 16
	xor a
	ld (hl), a
	dec hl
	ld (hl), a
	add hl, de
	ld (hl), a
	inc hl
	ld (hl), a	; and clean up the four boxes
	call SetHardness
	dec b
	xor a
	call SetHardness
	inc c
	xor a
	call SetHardness
	inc b
	xor a
	call SetHardness
	; As a last step, we should place the script offset accordingly. 
	; For boxes, deactivate script
	jp deact_script


; Check if we are hitting a breakable object
; In that case, reduce its energy and make it break if required
; INPUT:
;	- B: X coord in stiles
;	- C: Y coord in stiles

check_break_object:
	ld iy, ENTITY_OBJECT1_POINTER
	ld l, 5			; loop counter
	ld de, ENTITY_SIZE
check_break_object_loop:
	ld a, (iy+0)
	or (iy+1)
	jr z, check_break_object_loop_continue	
	; so the object is active, does the position match?
	ld a, (iy+6)
	cp b			; same X stile?
	jr nz, check_break_object_loop_continue
	ld a, (iy+7)
	cp c
	jr nz, check_break_object_loop_continue
	; cool, so the position matches
	ld a, (iy+8)		; object type
	cp OBJECT_BOX_LEFT		; is it a box?		FIXME there will be more breakable objects!!!
	jr z, check_break_object_loop_gotit
	cp OBJECT_BOX_RIGHT
	jr z, check_break_object_loop_gotit
	cp OBJECT_DOOR_DESTROY
	jr z, check_break_object_loop_gotit
	cp OBJECT_WALL_DESTROY
	jr z, check_break_object_loop_gotit
	cp OBJECT_JAR
	jr nz, check_break_object_loop_continue

check_break_object_loop_gotit:
	; so... we got it!!!
	ld (iy+4), 0		; no energy
	ld a, (iy+5)		; object id
	add a, a
	ld h, $ff		; The object area starts on $FF00, easy!
	ld l, a			; HL is pointing to the position
	ld (hl), 1		; 1 means dead!
	; and use the broken object FX
	ld a, FX_DESTROY_BLOCK
	call FX_Play
	ret			; and return
check_break_object_loop_continue:
	dec l
	jr z, check_break_object_loop_notfound
	add iy, de
	jr check_break_object_loop
check_break_object_loop_notfound:
	ret



; Get entity max energy, based on its level
; Input:
; - IY: pointer to entity
; OUTPUT:
; -  A: energy
; Will preserve all registers
get_entity_max_energy_ix:
	push ix
	pop iy
get_entity_max_energy:
	push hl
	push de
	push bc
    ld a, iyl
    cp ENTITY_PLAYER_POINTER % 256    ; is this the player?
    jr z, get_player_max_energy
	ld a, (iy+10)		; get enemy type | enemy_level
	ld c, a			; store in C
	and $f0			; this is enemy type * 16
	ld hl, enemy_info	; pointer base
	ld e, a
	ld d, 0
	; And now multiply by 32 to get there
	rl e
	rl d			; enemy_type * 32
	add hl, de		; HL now points to the right enemy
	ld b, 0			; C has the level, so we get to the proper position
	ld a, c
	and $0f
	ld c, a			; A = enemy_level
	add hl, bc
	ld a, (hl)		; And now A has the energy for the current enemy/level
    jr get_entity_max_energy_done
get_player_max_energy:
    ld a, (player_level)
    ld e, a
    ld d, 0
    ld hl, barbarian_max_energy
    add hl, de
    ld a, (hl)      ; this is the barbarian max energy
get_entity_max_energy_done:
	pop bc
	pop de
	pop hl	
	ret

; Get max player experience for the current level
; OUTPUT:
; -  A: max exp for current level

get_player_max_exp:
    ld a, (player_level)
get_player_exp_for_level:
    ld e, a
    ld d, 0
    ld hl, barbarian_level_exp
    add hl, de
    ld a, (hl)      ; this is the barbarian max exp for this level
    ret



; Get enemy probability for an attack, based on its level
; Input:
; - IX: pointer to entity
; - DE: offset: 7 for long attack, 14 for short attack, 21 for block
; OUTPUT:
; -  A: probability
; Will preserve all registers

get_enemy_probability:
	push hl
	push bc
	ld a, (ix+10)		; get enemy type | enemy_level
	ld c, a			; store in C
	and $f0			; this is enemy type * 16
	ld hl, enemy_info	; pointer base
	add hl, de		; HL points to the right base
	ld e, a
	ld d, 0
	; And now multiply by 32 to get there
	rl e
	rl d			; enemy_type * 32
	add hl, de		; HL now points to the right enemy
	ld b, 0			; C has the level, so we get to the proper position
	ld a, c
	and $0f
	ld c, a			; A = enemy_level
	add hl, bc
	ld a, (hl)		; And now A has the probability
	pop bc
	pop hl	
	ret

; Get enemy attack
; Input:
; - IX: pointer to entity
; - DE: offset: 0 for short1 attack, 1 for short2 attack, 2 for long attack
; OUTPUT:
; -  A: script id
; Will preserve all registers

get_enemy_attack:
	push hl
	ld a, (ix+10)		; get enemy type | enemy_level
	and $f0			; this is enemy type * 16
	ld hl, enemy_info+28	; pointer base
	add hl, de		; + attack type
	ld e, a
	ld d, 0
	; And now multiply by 32 to get there
	rl e
	rl d			; enemy_type * 32
	add hl, de		; HL now points to the right enemy
	ld a, (hl)		; And now A has the attack
	pop hl	
	ret

; Get entity attack damage
; Input:
; - (entity_current): pointer to current (attacking) entity
; - IX: pointer to receiving entity
; OUTPUT:
; -  E: damage

weapon_damage: db 0,1,2,4

get_entity_attack_damage:
    push hl
    push af
    ld hl, (entity_current)
    ld a, ENTITY_PLAYER_POINTER % 256
    cp l    ; is this the player?
    jr z, get_player_attack_damage
    ; for enemies, the attack damage is the level (*2 if the player is not carrying a weapon)
    ld de, 10
    add hl, de
    ld a, (hl)   ; the low nibble is the enemy level
	and $0f		  
    inc a
	ld e, a		 ; and we have it in E in base 1 (remember levels start by 0)
    ld a, (ix+5) ; this is the receiving entity state
    cp STATE_UNSHEATHE_LEFT
    jr nc, get_entity_attack_damage_finished ; we are carrying a weapon, so no double damage
    ld a, e
    add a, e
    ld e, a     ; E*2
    jr get_entity_attack_damage_finished 
get_player_attack_damage:
    ; for the player, the attack damage is level + weapon-damage
    ld hl, weapon_damage
    ld a, (player_current_weapon)
    ld e, a
    ld d, 0
    add hl, de
    ld a, (hl)  ; so A has the weapon damage level
    ld e, a
    ld a, (player_level)
    inc a
    add a, e
    ld e, a     ; done, E is the damage level
get_entity_attack_damage_finished:
    pop af
    pop hl
    ret

