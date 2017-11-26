;Entity struct:

;- Sprite pointer, NULL if not active (2 bytes)
;- Script id (1 byte)
;- Script position (1 byte)
;- Energy (0-255) for objects. 
;- 7 bytes for future expansion

; For player / enemies: 
;		- byte 5: player state (see definitions below)
;		- byte 6: animation position
;		- byte 7: when hitting with the sword, additional sprite index
;		- byte 8: last attack/defense movement
;		- byte 9: object number in level table (enemies only!)
;		- byte 10: For enemies, the high nibble will be the enemy type, the low nibble the enemy level 

; For object:
;		- byte 5: object number in level table
;		- byte 6: X for object, in stile coordinates
;		- byte 7: Y for object, in stile coordinates
;		- byte 8: object type
;		- bytes 0 and 1 will be $FF

ENTITY_SIZE: EQU 12
ENTITY_DATA: EQU $BF40 ;  12 bytes, 8 entities
ENTITY_PLAYER_POINTER: 	EQU ENTITY_DATA
ENTITY_ENEMY1_POINTER: 	EQU ENTITY_DATA+12
ENTITY_ENEMY2_POINTER: 	EQU ENTITY_DATA+24
ENTITY_OBJECT1_POINTER:	EQU ENTITY_DATA+36
ENTITY_OBJECT2_POINTER:	EQU ENTITY_DATA+48
ENTITY_OBJECT3_POINTER:	EQU ENTITY_DATA+60
ENTITY_OBJECT4_POINTER:	EQU ENTITY_DATA+72
ENTITY_OBJECT5_POINTER:	EQU ENTITY_DATA+84


ENTITY_PLAYER: 	EQU 0
ENTITY_ENEMY1: 	EQU 1
ENTITY_ENEMY2: 	EQU 2	; so 2 enemies maximum per screen
ENTITY_OBJECT1:	EQU 3
ENTITY_OBJECT2:	EQU 4
ENTITY_OBJECT3:	EQU 5
ENTITY_OBJECT4:	EQU 6
ENTITY_OBJECT5:	EQU 7	; so maximum 5 moving objects per screen

; State definitions
; State & 1 will always be 0 if looking left, 1 if looking right

STATE_IDLE_LEFT:		EQU 0
STATE_IDLE_RIGHT:		EQU 1
STATE_WALK_LEFT:		EQU 2
STATE_WALK_RIGHT:		EQU 3
STATE_RUN_LEFT:			EQU 4
STATE_RUN_RIGHT:		EQU 5
STATE_JUMP_UP_LOOK_LEFT:	EQU 6
STATE_JUMP_UP_LOOK_RIGHT:	EQU 7
STATE_JUMP_LEFT:		EQU 8
STATE_JUMP_RIGHT:		EQU 9
STATE_DOWN_LOOK_LEFT:		EQU 10
STATE_DOWN_LOOK_RIGHT:		EQU 11
STATE_FALLING_LOOK_LEFT:	EQU 12
STATE_FALLING_LOOK_RIGHT:	EQU 13
STATE_FINISHFALL_LOOK_LEFT:	EQU 14
STATE_FINISHFALL_LOOK_RIGHT:	EQU 15
STATE_CROUCH_LEFT:		EQU 16
STATE_CROUCH_RIGHT:		EQU 17
STATE_TURNING_LEFT:		EQU 18
STATE_TURNING_RIGHT:	EQU 19
STATE_SWITCH_LEFT:		EQU 20	
STATE_SWITCH_RIGHT:		EQU 21
STATE_HANG_LEFT:		EQU 22
STATE_HANG_RIGHT:		EQU 23
STATE_CLIMB_LEFT:		EQU 24
STATE_CLIMB_RIGHT:		EQU 25
STATE_BRAKE_LEFT:		EQU 26
STATE_BRAKE_RIGHT:		EQU 27
STATE_BRAKE_TURN_LEFT:		EQU 28
STATE_BRAKE_TURN_RIGHT:		EQU 29
STATE_LONGJUMP_LEFT:		EQU 30
STATE_LONGJUMP_RIGHT:		EQU 31
STATE_OUCH_LEFT:		EQU 32
STATE_OUCH_RIGHT:		EQU 33

STATE_UNSHEATHE_LEFT:		EQU 34
STATE_UNSHEATHE_RIGHT:		EQU 35
STATE_SHEATHE_LEFT:		EQU 36
STATE_SHEATHE_RIGHT:		EQU 37
STATE_IDLE_SWORD_LEFT:		EQU 38
STATE_IDLE_SWORD_RIGHT:		EQU 39
STATE_WALK_SWORD_LEFT:		EQU 40
STATE_WALK_SWORD_RIGHT:		EQU 41
STATE_SWORD_HIGHSLASH_LEFT:	EQU 42
STATE_SWORD_HIGHSLASH_RIGHT:	EQU 43
STATE_SWORD_LOWSLASH_LEFT:	EQU 44
STATE_SWORD_LOWSLASH_RIGHT:	EQU 45
STATE_SWORD_MEDSLASH_LEFT:	EQU 46
STATE_SWORD_MEDSLASH_RIGHT:	EQU 47
STATE_SWORD_BACKSLASH_LEFT:	EQU 48
STATE_SWORD_BACKSLASH_RIGHT:	EQU 49
STATE_SWORD_BLOCK_LEFT:		EQU 50
STATE_SWORD_BLOCK_RIGHT:	EQU 51
STATE_SWORD_OUCH_LEFT:		EQU 52
STATE_SWORD_OUCH_RIGHT:		EQU 53
STATE_DYING_LEFT:		EQU 54
STATE_DYING_RIGHT:		EQU 55
STATE_GRAB_LEFT:		EQU 56
STATE_GRAB_RIGHT:		EQU 57
STATE_ROCK_LEFT:		EQU 58
STATE_ROCK_RIGHT:		EQU 59
STATE_SECONDARY_LEFT:	EQU 60
STATE_SECONDARY_RIGHT:	EQU 61
STATE_DOOR_LEFT:		EQU 62
STATE_DOOR_RIGHT:		EQU 63
STATE_TELEPORT_LEFT: EQU 64
STATE_TELEPORT_RIGHT: EQU 65

; Variables
newx: db 0
newy: db 0
deltax: db 0
deltay: db 0
stairy: db 0	; value to climb up/down the stairs
cannotmove_reason: db 0

; Scratch area for player and enemies, used for:
; - Temporary script storage
; - Subscript execution
; - WARNING: bytes 6-7 are reserved for subscript storage!!!!

scratch_area_player: db 0, 0, 0, 0, 0, 0, 0, 0	; scratch area for player scripts 
scratch_area_enemy1: db 0, 0, 0, 0, 0, 0, 0, 0	; scratch area for enemy scripts 
scratch_area_enemy2: db 0, 0, 0, 0, 0, 0, 0, 0	; scratch area for enemy scripts 
scratch_area_obj1:   db 0, 0, 0, 0, 0, 0, 0, 0	; scratch area for enemy scripts 
scratch_area_obj2:   db 0, 0, 0, 0, 0, 0, 0, 0	; scratch area for enemy scripts 
scratch_area_obj3:   db 0, 0, 0, 0, 0, 0, 0, 0	; scratch area for enemy scripts 
scratch_area_obj4:   db 0, 0, 0, 0, 0, 0, 0, 0	; scratch area for enemy scripts 
scratch_area_obj5:   db 0, 0, 0, 0, 0, 0, 0, 0	; scratch area for enemy scripts 

; Init entity table
; Basically clean it up.
;
; INPUT: none
InitEntities:
	ld hl, ENTITY_DATA
	ld de, ENTITY_DATA+1
	ld bc, 95
InitEntities_common:
	xor a
	ld (hl), a
	ldir
	ret

; Re-init entity table, needed when switching screens:
ReInitEntities:
 	ld hl, ENTITY_ENEMY1_POINTER 
	ld de, ENTITY_ENEMY1_POINTER+1
	ld bc, 83
	jr InitEntities_common


initplayerdata:
	dw	barbaro_idle		;animation position
	db	SPR_24x32_MIRROR	;sprite type
	db	0			;X
	db	24			;Y
	db	3			;3 chars in X
	db	4			;4 chars in Y
	db	1			;redraw
; Initialize player entity
; INPUT: none
InitPlayer:
	; Create new sprite for barbarian
	call NewSprite		; get address of new sprite in HL	
				; should now check that HL != 0, but we have just initialized sprites and know that it works
	ld (ENTITY_PLAYER_POINTER), hl
;	ld de, barbaro_idle					; 3	 10
;	ld (hl), e						; 1	  7	
;	inc hl							; 1	  6
;	ld (hl), d		; Store animation position	; 1	  7
;	inc hl							; 1	  6
;	ld (hl), SPR_24x32_MIRROR	; sprite type		; 2	 10
;	inc hl							; 1	  6
;	ld (hl), 0		; X				; 2	 10
;	inc hl							; 1	  6
;	ld (hl), 24		; Y				; 2	 10
;	inc hl							; 1	  6
;	ld (hl), 3		; 3 chars in X			; 2	 10
;	inc hl							; 1	  6
;	ld (hl), 4		; 4 chars in Y			; 2	 10
;	inc hl							; 1	  6
;	ld (hl), 1		; redraw			; 2	 10
								;24	126
					
	ex de, hl		; 1	 4			; 9	  4
	ld hl, initplayerdata	; 3	10			;12	 14
	ld bc, 8		; 3	10			;15	 24
	ldir			; 2	21*7+16			;17	187

	; ENTITY_PLAYER_POINTER+5 is the state, 0 by default means idle, looking left
	; ENTITY_PLAYER_POINTER+6 is the animation position, between 0 and 5.
    ld a, (player_level)
    ld c, a
;    ld e, a
;    ld d, 0
    ld hl, barbarian_max_energy
;    add hl, de
    add hl, bc
    ld a, (hl)      ; this is the barbarian max energy for the current level
    ld (ENTITY_PLAYER_POINTER+4),a
	ret

; Check if we should go to a different screen
; INPUT:
;	- A: value output from entity_canmovehor (or other similar function)
;	- IY: pointer to entity sprite
;	- cannotmove_reason
;
; OUTPUT:
;	- Carry flag set if screen changed
;	- Carry flag reset if screen unchanged
CheckScreenChange_nochange:
	pop af
;	scf
;	ccf		; Make sure carry flag is not set
	and a
	ret
CheckScreenChange:
	and a
	ret z			; if A==0, can move, nothing to do
	push af
	ld a, (cannotmove_reason)
	and a
	jr z, CheckScreenChange_nochange	; hitting a wall, nothing to do
	ld hl, ENTITY_PLAYER_POINTER
	ld e, (hl)
	inc hl
	ld d, (hl)		; The player sprite pointer is in DE
	ld a, iyh
	cp d
	jr nz, CheckScreenChange_nochange
	ld a, iyl
	cp e
	jr nz, CheckScreenChange_nochange	; if the entity is not the player, do nothing


	ld a, (ix+5)		; we should not exit the screen if we are ouching
	and $fe
	cp STATE_OUCH_LEFT
	jr z, CheckScreenChange_nochange
	cp STATE_SWORD_OUCH_LEFT
	jr z, CheckScreenChange_nochange

	; So now we should be changing screen. 	
	ld a, (cannotmove_reason)
	dec a
	jr nz, CheckScreenChange_right
CheckScreenChange_left:
	; we are moving to the left
	ld a, (current_levelx)
	and a
	jr z, CheckScreenChange_nochange	; cannot move past X=0
	dec a
	ld (current_levelx), a
	; we should set the X value of the player to 256-24
	ld a, 232
	ld (iy+3), a
	jr CheckScreenChange_LoadScreen	
CheckScreenChange_right:
	dec a
	jr nz, CheckScreenChange_down
	ld a, (current_levelx)
	inc a
	ld b, a
	ld a, (level_width)
	cp b
	jr z, CheckScreenChange_nochange	; cannot move past the max X
	ld a, b
	ld (current_levelx), a
	; we should set the X value of the player to 0
	xor a
	ld (iy+3), a
	jr CheckScreenChange_LoadScreen	
CheckScreenChange_down:
	dec a
	jr nz, CheckScreenChange_up
	ld a, (current_levely)
	inc a
	ld b, a
	ld a, (level_height)
	cp b
	jr z, CheckScreenChange_nochange	; cannot move past the max X
	ld a, b
	ld (current_levely), a
	; we should set the Y value of the player to 0
	xor a
	ld (iy+4), a
	jr CheckScreenChange_LoadScreen	
CheckScreenChange_up:
	dec a
	jr nz, CheckScreenChange_nochange	; strange value!
	ld a, (current_levely)
	and a
	jr z, CheckScreenChange_nochange	; cannot move past Y=0
	dec a
	ld (current_levely), a
	; we should set the Y value of the player to 160-32
	ld a, 136				; FIXME this was changed based on the python version
	ld (iy+4), a
	jr CheckScreenChange_LoadScreen	
CheckScreenChange_LoadScreen:
	; current_levely*level_width+current_levelx
	ld a, (current_levely)
	and a
	jr z, CheckScreenChange_LoadScreen_addx
	ld c, a			; C has current_levely
	ld a, (level_width)
	ld b, a			; B has level_width
	xor a
CheckScreenChange_LoadScreen_loop:
	add a, c
	djnz CheckScreenChange_LoadScreen_loop	; so we multiply current_levely*level_width
CheckScreenChange_LoadScreen_addx:
	ld hl, current_levelx
	add a, (hl)
	push iy
	call ChangeScreen
	pop iy
	pop af
landed_clash:
	scf
	ret		; Carry flag set, we have changed screen


; Get the hardness value under our feet
; INPUT:
;	- newx, newy: new position
;	- IX: pointer to entity
; OUTPUT:
;	- Carry flag reset if not clashing, set if clashing

CheckWhereDidILand:
	ld a, (ix+5)
	and 1	
	jr nz, landed_right
landed_left:
	ld e, -16
	jr landed_common
landed_right:
	ld e, 16
landed_common:
	ld a, (newx)		; get X position
	add a, e
	;srl a			; and divide by 16 to get to stile coordinates
	;srl a
	;srl a
	;srl a
	rra
	rra
	rra
	rra
	and 15
	ld b, a			; store in B
	ld a, (newy)
	add a, 24
;	srl a
;	srl a
;	srl a
;	srl a
	rra
	rra
	rra
	rra
	and 15
	ld c, a			; same for the Y coordinate
	call GetHardness
	and a
    jr nz, landed_checkclash
	ld a, (newx)		; get X position
;	srl a			; and divide by 16 to get to stile coordinates
;	srl a
;	srl a
;	srl a
	rra
	rra
	rra
	rra
	and 15
	ld b, a			; store in B
	ld a, (newy)
	add a, 24
;	srl a
;	srl a
;	srl a
;	srl a
	rra
	rra
	rra
	rra
	and 15
	ld c, a			; same for the Y coordinate
	call GetHardness
	and a
    ret z
landed_checkclash:
	cp 3			; this is the low one. We are clashing if Y AND 8 is 0
	jr nz, landed_upperhalf
landed_lowerhalf: ; this is the low one. We are clashing if Y AND 8 is 0
	ld a, (newy)
	and 8
	jr z, landed_clash
	xor a
	ret
landed_upperhalf: ; this is the high one. We are clashing if Y AND 8 is 8
	ld a, (newy)
	and 8
	jr nz, landed_clash
	xor a
	ret
;landed_clash:
;	scf
;	ret

; Script for player, when controlled by joystick
; INPUT:
;	- IX: pointer to entity structure

player_state_functions: 	dw entity_idle, entity_walk, entity_run, entity_jump_up, entity_shortjump, entity_movedown
				dw entity_fall, entity_finishfall, entity_crouch, entity_turn, entity_switch, entity_hang
				dw entity_climb, entity_brake, entity_brake_turn, entity_longjump, entity_ouch, entity_unsheathe
				dw entity_sheathe, entity_idle_sword, entity_walk_sword, entity_swordhigh, entity_swordlow
				dw entity_swordmed, entity_swordback, entity_swordblock, entity_swordouch, entity_die
				dw entity_grab, entity_rock, entity_secondary, entity_door, entity_teleport1

; What to do when the entity is in the idle state
entity_idle:
	ld a, (entity_joystick)
	bit 5, a			; BIT 5 is ACTION (CAPS SHIFT)
	jr nz, entity_action_unsheathe	; ACTION when idle is unsheathe sword
	bit 4, a			; BIT 4 is FIRE
	jp z, entity_idle_checkleft	; not pressed, check directions
entity_fire_checkleft:
	bit 2, a
	jr z, entity_fire_checkright	; FIRE + LEFT is run left
	ld a, (ix+5)			; we need to be looking left to jump left
	and 1	
	jp nz, entity_idle_left_turn
	call get_sprite_pointer_iy
	jp entity_startrunning
entity_fire_checkright:
	bit 3, a
	jr z, entity_fire_checkup	; FIRE + RIGHT is run right

	ld a, (ix+5)			; we need to be looking right to jump right
	and 1	
	jp z, entity_idle_right_turn
	call get_sprite_pointer_iy
	jp entity_startrunning
entity_fire_checkup:
	bit 0, a
	jr z, entity_fire_checknothing	; FIRE + UP is unsheathe, just like the ACTION button
entity_action_unsheathe:
	ld a, (ix+5)
	and 1				
	add a, STATE_UNSHEATHE_LEFT
	ld (ix+5), a
	ld (ix+6), 0		; animation is now 0
	call get_sprite_pointer_ix ; Get the sprite pointer in IX
	ld de, SPRITE_OFFSET_UNSHEATHE
	jp entity_updatesprite	
entity_fire_checknothing:	; no other direction pressed, this is toggle switch
	; Is there any switch next to us?
	call entity_checkswitch
	ret nc				; entity_checkswitch will return carry flag active if a switch is next, NC if not
entity_idle_switchon:
	push af
	ld a, FX_LEVER
	call FX_Play
	pop af
	; Great, we have the object id in A. Lets set its value to 1
	add a, a		; A*2 to index the array
    ld l, a
	ld h, $ff
	ld (hl), 1		; the switch is switching on/off
	ld a, (ix+5)
	and 1				
	add a, STATE_SWITCH_LEFT
	ld (ix+5), a
	ld (ix+6), 0		; animation is now 0
	call get_sprite_pointer_ix ; Get the sprite pointer in IX
	ld de, SPRITE_OFFSET_SWITCH
	ld hl, (entity_sprite_base)
	add hl, de
	ld (ix+0), l
	ld (ix+1), h		; Store animation position
	ld a, (ix+5)
	and 1				
	jr z, entity_idle_switchon_right
entity_idle_switchon_right:
;	ld a, -8
	xor a
	jr entity_idle_switchon_common
entity_idle_switchon_left:	
	ld a, 8
entity_idle_switchon_common:
	add a, (ix+3)
	ld b, a
	ld c, (ix+4)		; Keep position
	jp UpdateSprite
;	call UpdateSprite	; Update sprite
;	ret			

entity_idle_checkleft:
	bit 2, a			; BIT 2 is move left
	jr nz, entity_idle_left
	bit 3, a			; BIT 3 is move right
	jp nz, entity_idle_right
	bit 0, a			; BIT 0 is move up
	jp nz, entity_idle_up
	bit 1, a			; BIT 0 is move down
	jp z, entity_idle_idle
	jp entity_idle_down
entity_idle_left:
	ld a, (ix+10)			; high nibble is enemy type
	and $f0
	cp OBJECT_ENEMY_ROCK*16-OBJECT_ENEMY_SKELETON*16  ; Is this a rock?
	jr nz, entity_idle_left_norock
entity_idle_left_rock:
	ld (ix+5), STATE_ROCK_LEFT	; moving left
	ld c, SPR_24x32_MIRROR	
	jr entity_startmove_common
entity_idle_left_norock:
	ld a, (ix+5)
	and 1	
	jr nz, entity_idle_left_turn
	; now check if we are also pressing UP. In that case, start a short jump
	ld a, (entity_joystick)
	bit 0, a
	jr z, entity_idle_left_walk
entity_idle_left_shortjump:
	; start jumping
	ld (ix+5), STATE_JUMP_LEFT	
	ld c, SPR_24x32_MIRROR
	jp entity_startshortjump
entity_idle_left_walk:
	; start walking left	
	ld (ix+5), STATE_WALK_LEFT	; moving left
	ld c, SPR_24x32_MIRROR
	jp entity_startmove_common
entity_idle_left_turn:
	ld (ix+5), STATE_TURNING_LEFT
	ld c, SPR_24x32_MIRROR
	jp entity_idle_turn_common
entity_idle_right:
	ld a, (ix+10)			; high nibble is enemy type
	and $f0
	cp OBJECT_ENEMY_ROCK*16-OBJECT_ENEMY_SKELETON*16  ; Is this a rock?
	jr nz, entity_idle_right_norock
entity_idle_right_rock:
	ld (ix+5), STATE_ROCK_RIGHT	; moving right
	ld c, SPR_24x32_NOMIRROR	
	jr entity_startmove_common
entity_idle_right_norock:
	ld a, (ix+5)
	and 1	
	jr z, entity_idle_right_turn	; the entity was looking left, so go through the turn around animation
	; now check if we are also pressing UP. In that case, start a short jump
	ld a, (entity_joystick)
	bit 0, a
	jr z, entity_idle_right_walk
entity_idle_right_shortjump:
	; start jumping
	ld (ix+5), STATE_JUMP_RIGHT	
	ld c, SPR_24x32_NOMIRROR
	jp entity_startshortjump
entity_idle_right_walk:
	; start walking right
	ld (ix+5), STATE_WALK_RIGHT	; moving right
	ld c, SPR_24x32_NOMIRROR	
entity_startmove_common:
	ld (ix+6), 0		; animation is now 0
	call get_sprite_pointer_ix ; Get the sprite pointer in IX
	ld (ix+2), c		; store sprite type
	ld de, SPRITE_OFFSET_WALK
	jp entity_updatesprite
entity_idle_right_turn:
	ld (ix+5), STATE_TURNING_RIGHT
	ld c, SPR_24x32_NOMIRROR
entity_idle_turn_common:
	ld (ix+6),0		; reset animation
	call get_sprite_pointer_ix ; Get the sprite pointer in IX
	ld (ix+2), c		; store sprite type
	ld de, SPRITE_OFFSET_TURN
entity_updatesprite:
	ld hl, (entity_sprite_base)
	add hl, de
	ld (ix+0), l
	ld (ix+1), h		; Store animation position
	ld b, (ix+3)
	ld c, (ix+4)		; Keep position
	jp UpdateSprite
;	call UpdateSprite	; Update sprite
;	ret
	
entity_startshortjump:
	ld (ix+6), 0		; animation is now 0
	call get_sprite_pointer_ix ; Get the sprite pointer in IX
	ld (ix+2), c		; Store sprite type
	ld de, SPRITE_OFFSET_SHORTJUMP
	jp entity_updatesprite	

entity_idle_up:
	call entity_check_teleport
	jr nc, entity_idle_up_noteleport
	ld a, FX_ENTER_DOOR
	call FX_Play
	ld a, (ix+5)
	and 1
	add a, STATE_DOOR_LEFT	; now crossing a door
	ld (ix+5), a		; set state
	ld (ix+6), 0		; reset animation
	call get_sprite_pointer_ix ; Get the sprite pointer in IX
	ld de, SPRITE_OFFSET_TURN
	jp entity_updatesprite

entity_idle_up_noteleport:
	call get_sprite_pointer_iy ; Get the sprite pointer in IY
	; check if we should move one char to the left or the right
	ld a, (iy+4)		; substract 16 temporarily so we can check if we will hang
	and a
	ret z				; If Y=0, we cannot jump up
	sub 16
	ld (iy+4), a
	ld a, (ix+5)
	and 1			; if zero, looking left
	jr nz, entity_idle_up_right
entity_idle_up_left:
	ld e, 0
	jr entity_idle_up_startchecks
entity_idle_up_right:
	ld e, 16
entity_idle_up_startchecks:
	push de
	call entity_canhang_up
	pop de
	and a
	jr z, entity_idle_up_zero	; no need to move
entity_idle_up_checkleft:
	ld a, (iy+3)
	and a
	jr z, entity_idle_up_checkright	; dont check if we are at the left!
	sub 8
	ld (iy+3), a
	push de
	call entity_canhang_up
	pop de
	and a
	jr z, entity_idle_up_minus8	; moving left
	ld a, (iy+3)
	add a, 8
	ld (iy+3), a
entity_idle_up_checkright:
	ld a, (iy+3)
	add a, 8
	jr c, entity_idle_up_zero	; if > 255, dont check
	ld (iy+3), a
	call entity_canhang_up
	and a
	jr z, entity_idle_up_plus8	; moving right
	ld a, (iy+3)
	sub 8
	ld (iy+3), a
	jr entity_idle_up_zero
entity_idle_up_minus8:
	ld a, (iy+3)
	add a, 8
	ld (iy+3), a
	sub 8
	ld (newx), a
	jr entity_idle_up_finishedcheck
entity_idle_up_plus8:
	ld a, (iy+3)
	sub 8
	ld (iy+3), a
	add a, 8
	ld (newx), a
	jr entity_idle_up_finishedcheck
entity_idle_up_zero:
	ld a, (iy+3)
	ld (newx), a
entity_idle_up_finishedcheck:
	ld a, (iy+4)		; recover this 16
	add a, 16
	ld (iy+4), a
	ld a, (ix+5)
	and 1
	add a, STATE_JUMP_UP_LOOK_LEFT	; now jumping
	ld (ix+5), a		; set state
	ld (ix+6), 0		; reset animation
	ld de, SPRITE_OFFSET_JUMP_UP
	ld hl, (entity_sprite_base)
	add hl, de
	ld (iy+0), l
	ld (iy+1), h		; Store animation position
	ld a, (iy+4)		; Keep position
	ld (newy), a
	jp player_updatesprite
;	call player_updatesprite
;	ret

entity_idle_down:
	call get_sprite_pointer_iy ; Get the sprite pointer in IY
	call entity_cango_down
	and a
	jr nz, entity_down_crouch			; cannot move down, so crouch
entity_down_down:
	ld a, (ix+5)
	and 1
	add a, STATE_DOWN_LOOK_LEFT
	ld (ix+5), a
	ld (ix+6), 7		; animation is now 7, will be decreased to 0
	push ix
	call get_sprite_pointer_ix ; Get the sprite pointer in IX
	ld de, SPRITE_OFFSET_JUMP_UP+96*7
	jr entity_down_crouch_common
;	ld hl, (entity_sprite_base)
;	add hl, de
;	ld (ix+0), l
;	ld (ix+1), h		; Store animation position
;	ld b, (ix+3)
;	ld c, (ix+4)		; Keep position
;	call UpdateSprite	; Update sprite
;	pop ix			; and get IX back with the entity sprite	
;	ret

entity_down_crouch:
	ld a, (ix+5)
	and 1
	add a, STATE_CROUCH_LEFT
	ld (ix+5), a		; crouch 
	ld (ix+6), 0		; animation is now 0
	push ix
	call get_sprite_pointer_ix ; Get the sprite pointer in IX
	ld de, SPRITE_OFFSET_CROUCH
entity_down_crouch_common:
	ld hl, (entity_sprite_base)
	add hl, de
	ld (ix+0), l
	ld (ix+1), h		; Store animation position
	ld b, (ix+3)
	ld c, (ix+4)		; Keep position
	call UpdateSprite	; Update sprite
	pop ix			; and get IX back with the entity sprite
entity_idle_idle:
	ret

; What to do when the entity is walking
entity_walk: 
	xor a
	ld (deltay), a
	ld a, (entity_joystick)	
    bit 5, a                        ; BIT 5 is ACTION (CAPS SHIFT)
    jp nz, entity_action_unsheathe  ; ACTION when idle is unsheathe sword
	bit 4, a			; BIT 4 is FIRE
	jr z, entity_walk_checkup
	; Now check combinations of fire + direction
	jp entity_fire_checkleft
entity_walk_checkup:
	bit 0, a			; BIT 0 is UP
	jr z, entity_walk_checkleft
	; start jumping
	ld a, (ix+5)
	and 1
	add a, STATE_JUMP_LEFT
	ld (ix+5), a
;	ld a, (ix+5)
	and 1
	jr z, entity_walk_checkup_left
entity_walk_checkup_right:
	ld c, SPR_24x32_NOMIRROR
	jp entity_startshortjump
entity_walk_checkup_left:
	ld c, SPR_24x32_MIRROR
	jp entity_startshortjump

entity_walk_checkleft:
	ld a, (entity_joystick)		; BIT 2 is move left
	bit 2, a
	jr z, entity_walk_checkright
	jr entity_walk_left
entity_walk_checkright:
	bit 3, a			; BIT 3 is move right
	jp z, entity_walk_idle
	jp entity_walk_right
entity_walk_left:
	ld a, (ix+5)		; get state
	and 1	
	jp nz, entity_walk_idle	; the entity was walking right, so it does not make much sense to move right at the same time
	call get_sprite_pointer_iy ; Get the sprite pointer in IY
	ld a, (ix+6)
	inc a
	ld (ix+6), a
	and $7
	cp 6
	jr z, entity_walk_left_restartanim	; restart the animation after 6 animations
	and 1
	jr nz, entity_walk_left_nomove
	; check if it is possible to move left
	xor a
	ld (forcemove), a
	ld (deltay), a
	ld a, 1
	ld (checkstair), a
	ld a, -8
	ld (deltax),a
	call entity_move
	jp nc, entity_walk_idle		; hitting a wall	
entity_walk_left_common:
	ld e, (iy+0)
	ld d, (iy+1)
	ld hl, 96
	add hl, de		; HL has the new sprite address
	ld (iy+0), l
	ld (iy+1), h		; store anim
	jp player_updatesprite
;	call player_updatesprite
;	ret
entity_walk_left_nomove:		; no need to move, just increase animation
	ld a, (iy+3)		; get X position
	ld (newx), a
	ld a, (iy+4)		; get Y position
	ld (newy), a
	jr entity_walk_left_common

entity_walk_left_restartanim:
	ld a, (ix+6)
	add a, 2		; so anim & 7 will always be 0--6
	ld (ix+6), a
	xor a
	ld (forcemove), a
    ld (deltay), a
 ;   ld a, 1
	inc a
	ld (checkstair), a
    ld a, -8
    ld (deltax),a
	call entity_move
	jp nc, entity_walk_idle		; hitting a wall	
	ld e, (iy+0)
	ld d, (iy+1)
	ld hl, -(96*5)
	add hl, de		; HL has the new sprite address
	ld (iy+0), l
	ld (iy+1), h		; store anim
	jp player_updatesprite
;	call player_updatesprite
;    ld a, FX_STEP  
;    ld (play_effect), a
;	ret

entity_walk_right:
	ld a, (ix+5)		; get state
	and 1	
	jp z, entity_walk_idle  ; the entity was walking left, so it does not make much sense to move right at the same time
	call get_sprite_pointer_iy ; Get the sprite pointer in IY
	ld a, (iy+3)
	ld (newx), a		; Set this here for now, if there is any change we will get it later on
	ld a, (ix+6)
	inc a
	ld (ix+6), a
	and $7
	cp 6
	jr z, entity_walk_right_restartanim	; restart the animation after 6 animations
	and 1
;	jr nz, entity_walk_right_nomove
	jp nz, entity_walk_left_nomove
	; check if it is possible to move right
	xor a
	ld (forcemove), a
    ld (deltay), a
;    ld a, 1
	inc a
	ld (checkstair), a
    ld a, 8
    ld (deltax),a
	call entity_move
;	jp nc, entity_walk_idle		; hitting a wall	
	jp c, entity_walk_left_common
;entity_walk_right_nomove:		; no need to move, just increase animation
;	jp entity_walk_left_nomove

entity_walk_idle:			; we were moving, but not anymore
	ld a, (ix+6)			; check animation state
	and 1
	jp z, entity_set_idle		; set the idle animation position
	ld a, (ix+5)
	and 1				; if zero, looking left, else looking right
	jp z, entity_walk_left
	jp entity_walk_right
;	ret

entity_walk_right_restartanim:
	ld a, (ix+6)
	add a, 2		; so anim & 7 will always be 0--6
	ld (ix+6), a
	; check if it is possible to move right
	xor a
	ld (forcemove), a
    ld (deltay), a
    ld a, 1
	ld (checkstair), a
    ld a, 8
    ld (deltax),a
	call entity_move
	jp nc, entity_walk_idle		; hitting a wall	
	ld e, (iy+0)
	ld d, (iy+1)
	ld hl, -(96*5)
	add hl, de		; HL has the new sprite address	
	ld (iy+0), l
	ld (iy+1), h		; store anim
 	jp player_updatesprite
;	call player_updatesprite
;    ld a, FX_STEP  
;    ld (play_effect), a
;	ret

; when we get here, IX points to the entity, IY to the sprite

entity_startrunning:
	ld a, (ix+5)
	and 1			; if zero, looking left, else looking right
	add a, STATE_RUN_LEFT	; now running
	ld (ix+5), a
	ld (ix+6), 0		; animation is now 0	
	push ix
	call get_sprite_pointer_ix ; Get the sprite pointer in IX
	ld de, SPRITE_OFFSET_RUN
	ld hl, (entity_sprite_base)
	add hl, de
	ld (ix+0), l
	ld (ix+1), h		; Store animation position
	ld b, (ix+3)
	ld c, (ix+4)		; Keep position
	call UpdateSprite	; Update sprite
	pop ix			; and get IX back with the entity sprite
	ret

; Set the entity to idle

entity_set_idle:
	ld a, (ix+5)
	and 1		; if zero, idle looking left, else idle looking right
	ld (ix+5), a
	ld (ix+6), 0		; animation is now 0	
	push ix
	call get_sprite_pointer_ix ; Get the sprite pointer in IX
	ld de, SPRITE_OFFSET_IDLE
entity_set_common:
	ld hl, (entity_sprite_base)
	add hl, de
	ld (ix+0), l
	ld (ix+1), h		; Store animation position
	ld b, (ix+3)
	ld c, (ix+4)		; Keep position
	call UpdateSprite	; Update sprite
	pop ix			; and get IX back with the entity sprite
	ret

; Set the entity to idle when holding sword
entity_set_idle_sword:
	ld a, (ix+5)
	and 1		; if zero, idle looking left, else idle looking right
	add a, STATE_IDLE_SWORD_LEFT
	ld (ix+5), a
	ld (ix+6), 0		; animation is now 0	
	push ix
	call get_sprite_pointer_ix ; Get the sprite pointer in IX
	ld de, SPRITE_OFFSET_IDLE_SWORD
	jr entity_set_common

; Set the entity to running
entity_set_running:
	ld a, (ix+5)
	and 1		; if zero, idle looking left, else idle looking right
	add a, STATE_RUN_LEFT
	ld (ix+5), a
	ld (ix+6), 0		; animation is now 0	
	push ix
	call get_sprite_pointer_ix ; Get the sprite pointer in IX
	ld de, SPRITE_OFFSET_RUN
	jr entity_set_common

; What to do when the entity is turning around
; Simply complete the turn around
entity_turn:
	ld a, (ix+5)
	cp STATE_TURNING_LEFT
	jp z, entity_idle_left
	jp entity_idle_right	


entity_jump_up:
	ld a, (entity_joystick)
	bit 0, a			; still pressing up?
	jr z, entity_jump_up_nocheck
entity_jump_up_skiphang:
	ld a, (ix+6)
	cp 1
	jr nz, entity_jump_common	; if 1 and pressing up, move straight to anim 3
	add a, 2
	ld (ix+6), a

; need to check if it is possible to hang, to climb
	call get_sprite_pointer_iy ; Get the sprite pointer in IY
	ld a, (ix+5)
	and 1
	jr nz, entity_jump_skiphang_lookright
	ld e, 0
	call entity_canhang_up
	jr entity_jump_skiphang_check
entity_jump_skiphang_lookright:
	ld e, 16
	call entity_canhang_up
entity_jump_skiphang_check:
	and a
	jp nz, entity_jump_canthang 		; cannot hang

entity_jump_up_skiphang_climb:
	ld a, FX_GRIP
	call FX_Play
	ld a, (ix+5)
	and 1
	add a, STATE_CLIMB_LEFT	
	ld (ix+5), a
	ld e, (ix+0)
	ld d, (ix+1)		; DE has the sprite pointer
	ld iyh, d
	ld iyl, e		; Get the sprite pointer in IY

	ld a, (iy+3)		; get X position
	ld (newx), a
	ld a, (iy+4)		; get Y position
	sub 8
	ld (newy), a	

	ld e, (iy+0)
	ld d, (iy+1)
	ld hl, 96+96
	add hl, de		; HL has the new sprite address
	ld (iy+0), l
	ld (iy+1), h		; store anim
	jp player_updatesprite
;	call player_updatesprite
;	ret

entity_jump_up_nocheck:
	ld a, (ix+6)
	cp 1
	jr z, entity_jump_canhang
entity_jump_common:
	inc a			; next animation position
	ld (ix+6), a
	call get_sprite_pointer_iy ; Get the sprite pointer in IY
	ld a, (iy+3)		; get X position
	ld (newx), a
	ld a, (iy+4)
	sub 8
	ld (newy), a
	ld e, (iy+0)
	ld d, (iy+1)
	ld hl, 96
	add hl, de		; HL has the new sprite address
	ld (iy+0), l
	ld (iy+1), h		; store anim
	jp player_updatesprite
;	call player_updatesprite
;	ret
entity_jump_canhang:
	call get_sprite_pointer_iy ; Get the sprite pointer in IY
	ld a, (ix+5)
	and 1
	jr nz, entity_jump_canhang_lookright
	ld e, 0
	call entity_canhang_up
	jr entity_jump_canhang_check
entity_jump_canhang_lookright:
	ld e, 16
	call entity_canhang_up
entity_jump_canhang_check:
	and a
	jr z, entity_jump_hang 		; can hang
entity_jump_canthang:
	ld a, (ix+5)
	and 1
	ld (ix+5), a			; set idle state
	ret
entity_jump_hang:
	ld a, FX_GRIP
	call FX_Play
	ld a, (ix+5)
	and 1
	add a, STATE_HANG_LEFT	
	ld (ix+5), a
	ld a, (ix+6)

	jr entity_jump_common
;	ret

; while hanging, check for the next key press. If up, climb. If down, just release and let yourself go down

entity_hang:
	ld a, (entity_joystick)		; BIT 0 is move up
	bit 0, a
	jr z, entity_hang_checkdown
entity_hang_up:
	ld a, (ix+5)
	and 1
	add a, STATE_CLIMB_LEFT	
	ld (ix+5), a
	ld a, (ix+6)
	inc a			; next animation position
	ld (ix+6), a
	call get_sprite_pointer_iy ; Get the sprite pointer in IY
	ld a, (iy+3)		; get X position
	ld (newx), a
	ld a, (iy+4)		; get Y position
	ld (newy), a	
	jp entity_climb_done
entity_hang_checkdown:
	bit 1, a			; BIT 1 is move down
	ret z
entity_hang_down:
	jp entity_set_idle		; set idle state
;	ret

; when climbing, just ignore any key press and finish animation

entity_climb:
	call get_sprite_pointer_iy ; Get the sprite pointer in IY
	ld a, (ix+6)
	inc a			; next animation position
	ld (ix+6), a
	cp 4
	jr nz, entity_climb_state5
entity_climb_state4:
	xor a
	ld (forcemove), a
	ld (deltax),a
	ld (checkstair), a
	ld a, -8
	ld (deltay), a
	call entity_move
	jp entity_climb_done

entity_climb_state5:
	cp 5
	jp nz, entity_climb_state6
	xor a
	ld (forcemove), a
	ld (deltax),a
	ld (checkstair), a
	ld a, -16
	ld (deltay), a
	call entity_move
	jp entity_climb_done
entity_climb_state6:
	cp 6
	jr nz, entity_climb_state7
	ld a, (iy+3)		; get X position
	ld (newx), a
	ld a, (iy+4)
	ld (newy), a		
	jp entity_climb_done
entity_climb_state7:
	cp 7
;	jr nz, entity_climb_state8
	jp nz, entity_set_idle
	xor a
	ld (forcemove), a
	ld (deltax),a
	ld (checkstair), a
	ld a, -8
	ld (deltay), a
	call entity_move
	jp entity_climb_done
;entity_climb_state8:
;	jp entity_set_idle
entity_climb_done:
	ld e, (iy+0)
	ld d, (iy+1)
	ld hl, 96
	add hl, de		; HL has the new sprite address	
	ld (iy+0), l
	ld (iy+1), h		; store anim
	jp player_updatesprite
;	call player_updatesprite
;	ret
	
; When at the last animation position of crouch, just go on
; When we are done, stay crouching while pressing DOWN
; Else, stand up

entity_crouch:
	ld a, (ix+6)
	cp 1
	jp z, entity_crouch_checkjoy	; if we keep pressing down when we are already crouching, just wait for the key release
	cp 2
	jp z, entity_set_idle
entity_crouch_contanim:
	inc a
	ld (ix+6), a		; increase animation position

	ld e, (ix+0)
	ld d, (ix+1)
	ld ixh, d
	ld ixl, e
	ld e, (ix+0)
	ld d, (ix+1)
	ld hl, 96
	add hl, de		; HL has the new sprite address
	ld (ix+0), l
	ld (ix+1), h		; store anim
	ld b, (ix+3)
	ld c, (ix+4)		; Keep position
	jp UpdateSprite
;	call UpdateSprite	; Update sprite
;	ret
entity_crouch_checkjoy:
	ld a, (entity_joystick)		
	bit 1, a
	ret nz			; if still pressing DOWN, just wait
	; Released DOWN, now stand up
	ld a, (ix+6)
	jp entity_crouch_contanim ; move one more animation position
;	ret

; when moving down, just do it until we are left in the hanging position
entity_movedown:
	ld a, (ix+6)
	dec a			; previous animation position
	ld (ix+6), a
	call get_sprite_pointer_iy ; Get the sprite pointer in IY

;	cp 2
	sub 2
	jr z, entity_movedown_hang
;	cp 3
	dec a
	jp z, entity_down_nochange
;	cp 4
	dec a
	jp z, entity_down_move2 ; if animation==4, move down 2 chars
;	cp 5
	dec a
	jp z, entity_down_nochange	; if animation==5 or animation==3, stay in the same position. For everyone else, move down 1 char
	
	ld a, (iy+3)		; get X position
	ld (newx), a
	ld a, (iy+4)
	add a, 8
	ld (newy), a
	jr entity_down_done
entity_down_nochange:
	ld a, (iy+3)		; get X position
	ld (newx), a
	ld a, (iy+4)
	ld (newy), a
	jr entity_down_done

entity_down_move2:
	ld a, (iy+3)		; get X position
	ld (newx), a
	ld a, (iy+4)
	add a, 16
	ld (newy), a
entity_down_done:
	ld e, (iy+0)
	ld d, (iy+1)
	ld hl, -96
	add hl, de		; HL has the new sprite address
	ld (iy+0), l
	ld (iy+1), h		; store anim
	jp player_updatesprite
;	call player_updatesprite
;	ret

entity_movedown_hang:
	ld a, (ix+5)
	and 1
	add a, STATE_HANG_LEFT	
	ld (ix+5), a
	ld a, (iy+3)		; get X position
	ld (newx), a
	ld a, (iy+4)
	add a, 8
	ld (newy), a
	jp entity_down_done
;	ret

; doing a short jump

entity_shortjump:
	call get_sprite_pointer_iy ; Get the sprite pointer in IY
	ld a, (ix+6)
	inc a			; next animation position
	ld (ix+6), a
	cp 1
	jr z, entity_shortjump_1
	cp 4
	jr z, entity_shortjump_4
	cp 5
	jp z, entity_set_idle
entity_shortjump_2or3:
	ld a, 8
	ld (deltax), a
	xor a
	ld (deltay), a
	jr entity_shortjump_common
entity_shortjump_1:
	ld a, 16
	ld (deltax), a
	ld a, -8
	ld (deltay), a
	jr entity_shortjump_common
entity_shortjump_4:
	ld a, 16
	ld (deltax), a
	ld a, 8
	ld (deltay), a
	jr entity_shortjump_common
entity_shortjump_common:
	ld a, (ix+5)		; get state
	and 1
	jr z, entity_shortjump_left	
entity_shortjump_right:
	jr entity_shortjump_done	
entity_shortjump_left:
	ld a, (deltax)
	neg
	ld (deltax), a
entity_shortjump_done:
	xor a
	ld (forcemove), a
	ld (checkstair), a
	push ix
	push iy
	call entity_move
	pop iy
	pop ix
	jp nc, entity_shortjump_set_idle		; hitting a wall
	ld a, (ix+6)		; we check if we have landed on a used char
	cp 4			; in that case, we will move up 8 pixels
	jr nz, entity_shortjump_check_nochange
	call CheckWhereDidILand
	jr nc, entity_shortjump_check_nochange
entity_shortjump_landed:
	ld a, (newy)
	sub 8
	ld (newy), a
entity_shortjump_check_nochange:
	ld e, (iy+0)
	ld d, (iy+1)
	ld hl, 96
	add hl, de		; HL has the new sprite address
	ld (iy+0), l
	ld (iy+1), h		; store anim
	push ix
	call player_updatesprite
	pop ix
	ld a, (ix+6)
	cp 4
	ret nz
	jr entity_shortjump_checksound
;	call player_updatesprite
;	ret
entity_shortjump_set_idle:
	ld a, (ix+6)		; we check if we have landed on a used char
	cp 4			; in that case, we will move up 8 pixels
	jp nz, entity_set_idle
	jr entity_shortjump_landed

entity_shortjump_checksound:
	call entity_checkgravity
	and a
	ret z
	ld a, FX_GROUND
	call FX_Play
	ret


; What to do while falling
entity_fall:
	ld a, (ix+6)
	inc a
	ld (ix+6), a		; one more frame falling down
	call get_sprite_pointer_iy ; Get the sprite pointer in IY
	; only the player can hang
	ld a, ixl
	cp ENTITY_PLAYER_POINTER%256
	jr z, entity_fall_barbarian	; This is the barbarian
	; if this is the rock, just check if we are hitting someone
	ld a, (ix+10)
	and $f0
	cp OBJECT_ENEMY_ROCK*16-OBJECT_ENEMY_SKELETON*16  ; Is this a rock?
	ret nz              ; not the barbarian, not a rock, go away!
	jp check_rock_kills_entity
;	call check_rock_kills_entity
;	ret
entity_fall_barbarian:
	ld a, (ix+5)
	and 1
	jr nz, entity_fall_canhang_lookright
	ld e, -8
	call entity_canhang
	jr entity_fall_canhang_check
entity_fall_canhang_lookright:
	ld e, 24
	call entity_canhang
entity_fall_canhang_check:
	and a
	ret nz				; cannot hang
entity_fall_hang:
	ld a, (ix+5)
	and 1
	add a, STATE_GRAB_LEFT
	ld (ix+5), a
	ld (ix+6), 0
	call get_sprite_pointer_iy ; Get the sprite pointer in IY
	ld a, (iy+3)
	ld (newx), a
	
	ld a, (canhang_half)
	and a
	jr nz, entity_fall_hang_lowerhalf
entity_fall_hang_upperhalf:
	ld a, (iy+4)
	and $f0
	jr entity_fall_hang_continue
entity_fall_hang_lowerhalf:
	ld a, (iy+4)
	or $8
entity_fall_hang_continue:
	ld (newy), a
	ld de, SPRITE_OFFSET_GRAB
	ld hl, (entity_sprite_base)
	add hl, de
	ld (iy+0), l
	ld (iy+1), h		; Store animation position
	jp player_updatesprite
;	call player_updatesprite
;	ret

entity_finishfall:
	ld a, ixl
	cp ENTITY_PLAYER_POINTER%256
	jr z, entity_finishfall_norock
	; is this the rock?
	ld a, (ix+10)
	and $f0
	cp OBJECT_ENEMY_ROCK*16-OBJECT_ENEMY_SKELETON*16  ; Is this a rock?
	jr nz, entity_finishfall_norock
entity_finishfall_rock:
	jp entity_rock_crash
entity_finishfall_norock:
	ld a, (ix+4)
	and a
	jr z, entity_finishfall_die ; dead
	ld a, FX_GROUND
	call FX_Play	
	ld a, (ix+6)
	ld (ix+6), 0		; reset
	cp 3
	ret c			; less than two frames, no problem
	cp 6
	jp c,  entity_down_crouch	; must have been falling for at least two frames
	cp 8
	jr c, entity_finishfall_damage
entity_finishfall_die:	; falling from too high, now die
	push ix
	pop iy
	jp kill_entity
;	call kill_entity
;	ret
entity_finishfall_damage: ;falling from high, damage
	add a, 3
	ld c, a	
	ld a, 5
	add a, (ix+4)
	sub c 	; energy - (frames_fallen+3) + 5
	jr c, entity_finishfall_die
	jr z, entity_finishfall_die	; die if result is negative or zero
	ld (ix+4), a
	jp entity_down_crouch
;	ret

; What to do when the entity is running
entity_run: 	
	xor a
	ld (deltay), a
	ld a, (entity_joystick)	
	bit 0, a			; BIT 4 is UP
	jr z, entity_run_checkleft
; long jump
	ld a, FX_LONGJUMP
	call FX_Play
	ld a, (ix+5)
	and 1
	add a, STATE_LONGJUMP_LEFT
	ld (ix+5), a
	ld (ix+6), 0		; animation is now 0
	call get_sprite_pointer_ix ; Get the sprite pointer in IX
	ld de, SPRITE_OFFSET_LONGJUMP
	jp entity_updatesprite	
;	ret				
entity_run_checkleft:
	ld a, (entity_joystick)		; BIT 2 is move left
	bit 2, a
	jr z, entity_run_checkright
	jr entity_run_left
entity_run_checkright:
	bit 3, a			; BIT 3 is move right
	jp z, entity_run_brake
	jp entity_run_right
entity_run_left:
	ld a, (ix+5)		; get state
	and 1	
	jp nz, entity_run_brake_turn	; Trigger the turn+run state, we pressed left while running right
	call get_sprite_pointer_iy ; Get the sprite pointer in IY
	ld a, (ix+6)
	inc a
	ld (ix+6), a
	and $7
	cp 4
	jr z, entity_run_left_restartanim	; restart the animation after 4 animations
	; check if it is possible to move left
	xor a
	ld (forcemove), a
    ld (deltay), a
    ld a, 1
	ld (checkstair), a
    ld a, -8
    ld (deltax),a
	call entity_move
	jp nc, entity_run_idle		; hitting a wall	
entity_run_left_common:
	ld e, (iy+0)
	ld d, (iy+1)
	ld hl, 96
	add hl, de		; HL has the new sprite address
	ld (iy+0), l
	ld (iy+1), h		; store anim
	jp player_updatesprite
;	call player_updatesprite
;	ret

entity_run_left_restartanim:
	ld a, (ix+6)
	add a, 4		; so anim & 7 will always be 0-4
	ld (ix+6), a
	; check if it is possible to move left
	xor a
	ld (forcemove), a
    ld (deltay), a
    ld a, 1
	ld (checkstair), a
    ld a, -8
    ld (deltax),a
	call entity_move
	jp nc, entity_run_idle		; hitting a wall
entity_run_left_restartanim_common:	
	ld e, (iy+0)
	ld d, (iy+1)
	ld hl, -(96*3)
	add hl, de		; HL has the new sprite address
	ld (iy+0), l
	ld (iy+1), h		; store anim
	jp player_updatesprite
;	call player_updatesprite
;	ret

entity_run_right:
	ld a, (ix+5)		; get state
	and 1	
	jp z, entity_run_brake_turn	; Trigger the turn+run state, we pressed right while running left
	call get_sprite_pointer_iy ; Get the sprite pointer in IY
	ld a, (ix+6)
	inc a
	ld (ix+6), a
	and $7
	cp 4
	jr z, entity_run_right_restartanim	; restart the animation after 4 animations
	; check if it is possible to run right
	xor a
	ld (forcemove), a
    ld (deltay), a
    ld a, 1
	ld (checkstair), a
    ld a, 8
    ld (deltax),a
	call entity_move
	jp nc, entity_run_idle		; hitting a wall	

entity_run_right_noprob:
	jp entity_run_left_common

entity_run_right_restartanim:
	ld a, (ix+6)
	add a, 4		; so anim & 7 will always be 0--4
	ld (ix+6), a

	; check if it is possible to run right
	xor a
	ld (forcemove), a
    ld (deltay), a
    ld a, 1
	ld (checkstair), a
    ld a, 8
    ld (deltax),a
	call entity_move
	jp nc, entity_run_idle		; hitting a wall	
    jr entity_run_left_restartanim_common
;	ret

entity_run_brake:			; we were running, but not anymore
	ld a, (ix+5)
	and 1			; if zero, looking left, else looking right
	add a, STATE_BRAKE_LEFT
entity_run_brake_common:
	ld (ix+5), a
	ld (ix+6), 0		; animation is now 0	
	push ix
	call get_sprite_pointer_ix ; Get the sprite pointer in IX
	ld de, SPRITE_OFFSET_BRAKE
	ld hl, (entity_sprite_base)
	add hl, de
	ld (ix+0), l
	ld (ix+1), h		; Store animation position
	ld b, (ix+3)
	ld c, (ix+4)		; Keep position
	call UpdateSprite	; Update sprite
	pop ix			; and get IX back with the entity sprite
	ret 

entity_run_brake_turn:
	ld a, (ix+5)
	and 1			; if zero, looking left, else looking right
	add a, STATE_BRAKE_TURN_LEFT
	jr entity_run_brake_common

entity_run_idle:
	ld a, (ix+5)	; hit a wall while running, set the ouch state
	and 1		; if zero, idle looking left, else idle looking right
	add a, STATE_OUCH_LEFT
	ld (ix+5), a
	ld (ix+6), 0		; animation is now 0	
	push ix
	call get_sprite_pointer_ix ; Get the sprite pointer in IX
	ld de, SPRITE_OFFSET_OUCH
	ld hl, (entity_sprite_base)
	add hl, de
	ld (ix+0), l
	ld (ix+1), h		; Store animation position
	ld b, (ix+3)
	ld c, (ix+4)		; Keep position
	call UpdateSprite	; Update sprite
	pop ix			; and get IX back with the entity sprite		
	ld a, FX_HIT
	call FX_Play		
	ret

; Breaking
entity_brake:
	xor a
	ld (deltay), a
	ld a, (ix+6)
	inc a
	cp 3
	jp z, entity_set_idle	; brake for two frames

	ld (ix+6), a
	call get_sprite_pointer_iy ; Get the sprite pointer in IY
	ld a, (ix+5)		; get state
	and 1	
	jr nz, entity_brake_right
entity_brake_left:
	ld a, -8
	jr entity_brake_common
entity_brake_right:
	ld a, 8
entity_brake_common:
	; check if it is possible to run
    ld (deltax),a
	xor a
	ld (forcemove), a
    ld (deltay), a
    ld a, 1
	ld (checkstair), a
	call entity_move
	jp nc, entity_run_idle		; hitting a wall	
	jp player_updatesprite
;	call player_updatesprite
;	ret

entity_brake_turn:
	xor a
	ld (deltay), a
	ld a, (ix+6)
	inc a
	cp 4
	jp z, entity_braketurn_finish	; brake for three frames

	ld (ix+6), a
	call get_sprite_pointer_iy ; Get the sprite pointer in IY

	ld a, (ix+5)		; get state
	and 1	
	jr nz, entity_braketurn_right
entity_braketurn_left:
	ld a, -8
	jr entity_braketurn_common
entity_braketurn_right:
	ld a, 8
entity_braketurn_common:
	; check if it is possible to run
    ld (deltax),a
	xor a
	ld (forcemove), a
    ld (deltay), a
    ld a, 1
	ld (checkstair), a
	call entity_move
	jp nc, entity_run_idle		; hitting a wall	
	ld a, (ix+6)
	cp 1
	jr z, entity_braketurn_common_noinc
	ld e, (iy+0)
	ld d, (iy+1)
	ld hl, 96
	add hl, de		; HL has the new sprite address
	ld (iy+0), l
	ld (iy+1), h		; store anim
entity_braketurn_common_noinc:
	jp player_updatesprite
;	call player_updatesprite
;	ret

entity_braketurn_finish:
	ld a, (ix+5)
	and 1		; if zero, idle looking left, else idle looking right
	xor 1		; and reverse direction
	add a, STATE_RUN_LEFT
	ld (ix+5), a
	ld (ix+6), 0		; animation is now 0	
	push ix
	call get_sprite_pointer_ix ; Get the sprite pointer in IX
	ld de, SPRITE_OFFSET_RUN
	ld hl, (entity_sprite_base)
	add hl, de
	ld (ix+0), l
	ld (ix+1), h		; Store animation position
	ld a, (ix+2)
	xor 1
	ld (ix+2), a		; reverse sprite type
	ld b, (ix+3)
	ld c, (ix+4)		; Keep position
	call UpdateSprite	; Update sprite
	pop ix			; and get IX back with the entity sprite
	ret



entity_longjump:
	call get_sprite_pointer_iy ; Get the sprite pointer in IY	
	ld a, (ix+6)
	inc a			; next animation position
	ld (ix+6), a
;	cp 1
	dec a
	jr z, entity_longjump_1
	dec a
;	cp 2
	jr z, entity_longjump_2
	sub 3
;	cp 5
	jr z, entity_longjump_5
	dec a
;	cp 6
	jr z, entity_longjump_6
	dec a
;	cp 7
	jp z, entity_set_running
entity_longjump_3or4:
	ld a, 8
	ld (deltax), a
	xor a
	ld (deltay), a
	jr entity_longjump_common
entity_longjump_1:
	ld a, 8
	ld (deltax), a
	ld a, -8
	ld (deltay), a
	jr entity_longjump_common
entity_longjump_2:
	ld a, 16
	ld (deltax), a
	ld a, -8
	ld (deltay), a
	jr entity_longjump_common
entity_longjump_5:
	ld a, 16
	ld (deltax), a
	ld a, 8
	ld (deltay), a
	jr entity_longjump_common
entity_longjump_6:
	ld a, 8
	ld (deltax), a
	ld a, 8
	ld (deltay), a

entity_longjump_common:
	ld a, (ix+5)		; get state
	and 1
	jr z, entity_longjump_left	
entity_longjump_right:
	jr entity_longjump_done	
entity_longjump_left:
	ld a, (deltax)
	neg
	ld (deltax), a
entity_longjump_done:
	xor a
	ld (forcemove), a
	ld (checkstair), a
	call entity_move
	jp nc, entity_longjump_idle		; hitting a wall

	ld a, (ix+6)		; we check if we have landed on a used char
	cp 6			; in that case, we will move up 8 pixels
	jr nz, entity_longjump_check_nochange
	call CheckWhereDidILand
	jr nc, entity_longjump_check_nochange
	ld a, (newy)
	sub 8
	ld (newy), a
entity_longjump_check_nochange:
	ld a, (ix+6)
	cp 4
	jr z, entity_longjump_noanim
	cp 6
	jr nz, entity_longjump_normalanim
entity_longjump_landed:
	ld e, (iy+0)
	ld d, (iy+1)
	ld hl, -(96*4)
	add hl, de		; HL has the new sprite address
	ld (iy+0), l
	ld (iy+1), h		; store anim
;	jr entity_longjump_noanim
	push ix
	call player_updatesprite
	pop ix
	jp entity_shortjump_checksound

entity_longjump_normalanim:
	ld e, (iy+0)
	ld d, (iy+1)
	ld hl, 96
	add hl, de		; HL has the new sprite address		
	ld (iy+0), l
	ld (iy+1), h		; store anim
entity_longjump_noanim:
	jp player_updatesprite
;	call player_updatesprite
;	ret
entity_longjump_idle:
	ld a, (deltax)
	cp 16
	jr z, entity_longjump_retry ; A long jump in state 2/5 failed, so we cannot move 16 pixels. Maybe we can move 8...
	cp -16 
	jr z, entity_longjump_retry ; A long jump in state 2/5 failed, so we cannot move 16 pixels. Maybe we can move 8...
	ld a, (ix+6)
    	cp 6
	jp nz, entity_set_idle
	call CheckWhereDidILand
	jp nc, entity_set_idle
	ld a, (newy)
	sub 8
	ld (newy), a
    	jp entity_longjump_landed
;	ret

entity_longjump_retry:
	ld a, (deltay)
	cp -8
	jp z, entity_longjump_1
	jp entity_longjump_6

entity_ouch:
	xor a	
	ld (deltay), a
	ld c, (ix+5)		; c has the current state
	ld a, (ix+6)
	inc a
	cp 2
	jr z, entity_ouch_checkdeath	; only for one frame
	ld (ix+6), a
	call get_sprite_pointer_iy ; Get the sprite pointer in IY
	ld b, (iy+3)
	ld a, c
	and 1			; if 0, looking left. if 1, looking right
	jr z, entity_ouch_left
	ld a, -8
	jr entity_ouch_common
entity_ouch_left:
	ld a, 8
entity_ouch_common:
	push bc
	push af
	; check if it is possible to move left
    ld (deltax),a
	xor a
	ld (forcemove), a
    ld (deltay), a
    ld a, 1
	ld (checkstair), a
	call entity_move
	jr nc, entity_ouch_nomove		; hitting a wall
	pop af
	jr entity_ouch_done
entity_ouch_nomove:
	pop af
	xor a
entity_ouch_done:
	pop bc
	add a, b
	ld b, a
	ld c, (iy+4)		; Keep position
	push iy
	pop ix
	jp UpdateSprite
;	call UpdateSprite	; Update sprite
;	ret
entity_ouch_checkdeath:
	ld a, (ix+4)
	and a
	jp nz, entity_set_idle ; not dead, just set to idle
	jp entity_swordouch_die


entity_swordouch:
	ld c, (ix+5)		; c has the current state
	ld a, (ix+6)
	inc a
	cp 2
	jp z, entity_swordouch_checkdeath	; only for one frame

	ld (ix+6), a
	call get_sprite_pointer_iy ; Get the sprite pointer in IY
	ld b, (iy+3)
	ld a, c
	and 1			; if 0, looking left. if 1, looking right
	jr z, entity_swordouch_left
	ld a, -8
	jr entity_swordouch_common
entity_swordouch_left:
	ld a, 8
entity_swordouch_common:
	push bc
	push af
	; check if it is possible to move left
	ld (deltax),a
	xor a
	ld (forcemove), a
	ld (deltay), a
	ld a, 1
	ld (checkstair), a
	call entity_move
	jp nc, entity_swordouch_nomove		; hitting a wall
	pop af
	jr entity_swordouch_done
entity_swordouch_nomove:
	pop af
	xor a
entity_swordouch_done:
	pop bc
	add a, b
	ld b, a
	ld c, (iy+4)		; Keep position
	push iy
	pop ix
	jp UpdateSprite
;	call UpdateSprite	; Update sprite
;	ret
entity_swordouch_checkdeath:
	ld a, (ix+4)
	and a
	jp nz, entity_set_idle_sword ; not dead, just set to idle
entity_swordouch_die:
	; so the entity is dying
	; first thing: if this is an enemy, we should set it to dead in the object table
	; otherwise, make it the enemy base
	ld a, ixl
	cp ENTITY_PLAYER_POINTER%256
	jr z, entity_swordouch_checkdeath_setsprite	; This is the barbarian, no need to do this

    call set_entity_dead
entity_swordouch_checkdeath_setsprite:
	ld a, (ix+5)
	and 1				; 
	add a, STATE_DYING_LEFT
	ld (ix+5), a
	ld (ix+6), 0		; animation is now 0
	call get_sprite_pointer_ix ; Get the sprite pointer in IX
	ld de, SPRITE_OFFSET_DIE
	jp entity_updatesprite	
;	ret


entity_unsheathe:
	ld a, FX_UNSHEATHE
	call FX_Play
	ld a, (ix+5)
	and 1				; we should jump left only if looking right
	add a, STATE_IDLE_SWORD_LEFT
	ld (ix+5), a
	ld (ix+6), 0		; animation is now 0
	call get_sprite_pointer_ix ; Get the sprite pointer in IX
	ld de, SPRITE_OFFSET_IDLE_SWORD
	jp entity_updatesprite	
;	ret

entity_sheathe:
	ld a, FX_SHEATHE
	call FX_Play
	ld a, (ix+5)
	and 1				; we should jump left only if looking right
	add a, STATE_IDLE_LEFT
	ld (ix+5), a
	ld (ix+6), 0		; animation is now 0
	call get_sprite_pointer_ix ; Get the sprite pointer in IX
	ld de, SPRITE_OFFSET_IDLE
	jp entity_updatesprite	
;	ret


; when idle with the sword...

entity_idle_sword:
	ld a, (entity_joystick)	
	bit 4, a			; BIT 4 is FIRE
	jp z, entity_idlesword_checkleft
	; Now check combinations of fire + direction

entity_fire_sword_checkup:
	bit 0, a			; BIT 0 is UP
	jr z, entity_fire_sword_checkdown
	ld a, (ix+8)
	and $fe
	cp STATE_SWORD_HIGHSLASH_LEFT
	ret z				; do not repeat movement!
	ld a, (ix+5)
	and 1
	add a, STATE_SWORD_HIGHSLASH_LEFT
	ld (ix+5), a
	ld (ix+8), a
	ld hl, SPRITE_OFFSET_HIGH_SWORD
	jp entity_startmove_sword_common
entity_fire_sword_checkdown:
	bit 1, a			; BIT 1 is DOWN
	jr z, entity_fire_sword_checkleft
	ld a, (ix+8)
	and $fe
	cp STATE_SWORD_LOWSLASH_LEFT
	ret z				; do not repeat movement!
	ld a, (ix+5)
	and 1
	add a, STATE_SWORD_LOWSLASH_LEFT
	ld (ix+5), a
	ld (ix+8), a
	ld hl, SPRITE_OFFSET_LOW_SWORD
	jp entity_startmove_sword_common
entity_fire_sword_checkleft:
	bit 2, a			; BIT 2 is LEFT
	jr z, entity_fire_sword_checkright
	ld a, (ix+5)
	and 1
	jr z, entity_fire_sword_forward
entity_fire_sword_backward:		; FIXME to be implemented (back hit)
	ld a, (ix+8)
	and $fe
	cp STATE_SWORD_BACKSLASH_LEFT
	ret z				; do not repeat movement!
	ld a, (ix+5)
	and 1
	add a, STATE_SWORD_BACKSLASH_LEFT
	ld (ix+5), a
	ld (ix+8), a
	ld hl, SPRITE_OFFSET_BACK_SWORD
	jp entity_startmove_sword_common

entity_fire_sword_checkright:
	bit 3, a			; BIT 3 is right
	jp z,	entity_idlesword_idle		; just ignore if only pressing fire
	ld a, (ix+5)
	and 1
	jr z, entity_fire_sword_backward	; looking left and pressed fire+right
entity_fire_sword_forward:
	ld a, (ix+8)
	and $fe
	cp STATE_SWORD_MEDSLASH_LEFT
	ret z				; do not repeat movement!
	ld a, (ix+5)
	and 1
	add a, STATE_SWORD_MEDSLASH_LEFT
	ld (ix+5), a
	ld (ix+8), a
	ld hl, SPRITE_OFFSET_FORW_SWORD
	jp entity_startmove_sword_common

entity_idlesword_checkleft:
	bit 2, a			; BIT 2 is move left
;	jr z, entity_idlesword_checkright
	jr nz, entity_idlesword_walk
;entity_idlesword_checkright:
	bit 3, a			; BIT 3 is move right
;	jp z, entity_idlesword_checkaction
	jr nz, entity_idlesword_walk
;entity_idlesword_checkaction:
	bit 5, a			; BIT 5 is ACTION, down does nothing for now
;	jr z, entity_idlesword_checkup
	jr nz, entity_idlesword_down
;entity_idlesword_checkup:
	bit 0, a
	jr z, entity_idlesword_idle
entity_idlesword_block:
	ld a, (ix+8)
	and $fe
	cp STATE_SWORD_BLOCK_LEFT
	ret z				; do not repeat movement!
	ld a, (ix+5)
	and 1
	add a, STATE_SWORD_BLOCK_LEFT
	ld (ix+5), a
	ld (ix+8), a
	ld hl, SPRITE_OFFSET_BLOCK_SWORD
	jp entity_startmove_sword_common

entity_idlesword_walk:
	ld a, (ix+5)
	and 1	
	add a, STATE_WALK_SWORD_LEFT
	ld (ix+5), a
	ld (ix+8), a
	ld hl, SPRITE_OFFSET_IDLE_SWORD
entity_startmove_sword_common:
	ld (ix+6), 0		; animation is now 0
	call get_sprite_pointer_ix ; Get the sprite pointer in IX
	ex de, hl
	jp entity_updatesprite

entity_idlesword_down:	; sheathe the sword
	ld a, (ix+5)
	and 1				; we should jump left only if looking right
	add a, STATE_SHEATHE_LEFT
	ld (ix+5), a
	ld hl, SPRITE_OFFSET_UNSHEATHE
	jp entity_startmove_sword_common
;	ret

entity_idlesword_idle:
	xor a
	ld (ix+8), a
	ret

; when walking with the sword

entity_walk_sword:
	ld a, (entity_joystick)
    bit 5, a                        ; BIT 5 is ACTION (FIRE 2)
    jr nz, entity_idlesword_down    ; ACTION when walking with sword is sheathe sword  
	bit 4, a			; BIT 4 is FIRE
	jp nz, entity_fire_sword_checkup
	bit 0, a			; BIT 0 is UP
	jr nz, entity_idlesword_block

	ld a, (entity_joystick)		; BIT 2 is move left
	bit 2, a
;	jr z, entity_walk_sword_checkright
	jr nz, entity_walk_sword_left
;entity_walk_sword_checkright:
	bit 3, a			; BIT 3 is move right
;	jr z, entity_walk_sword_checkaction
	jp nz, entity_walk_sword_right
	jp entity_set_idle_sword

entity_walk_sword_left:
	call get_sprite_pointer_iy ; Get the sprite pointer in IY
	ld a, (ix+5)		; get state
	and 1	
	jp nz, entity_walk_sword_left_backwards	; the entity was walking right, so it needs to go backwards
	ld a, (ix+6)
	inc a
	ld (ix+6), a		; next animation position
	and $3
	jp z, entity_walk_sword_left_restartanim	; restart the animation after 4 animations
	cp 3
	jr nz, entity_walk_sword_left_nomove
	; check if it is possible to move left
	ld a, -8
	ld (deltax),a
	xor a
	ld (forcemove), a
	ld (deltay), a
	ld a, 1
	ld (checkstair), a
	call entity_move
	jp nc, entity_set_idle_sword		; hitting a wall	
	jp entity_walk_left_common
entity_walk_sword_left_backwards:
	ld a, (ix+6)
	dec a
	ld (ix+6), a		; next animation position
	and $3
	cp 3
	jr z, entity_walk_sword_backwards_restartanim	; restart the animation after 4 animations
	cp 2
	jr nz, entity_walk_backwards_nomove
	; check if it is possible to move left
	ld a, -8
	ld (deltax),a
	xor a
	ld (forcemove), a
	ld (deltay), a
	ld a, 1
	ld (checkstair), a
	call entity_move
	jp nc, entity_set_idle_sword		; hitting a wall	
	jp entity_walk_backwards_common
entity_walk_backwards_nomove:
; no need to move, just increase animation
	ld a, (iy+3)
	ld (newx), a
	ld a, (iy+4)
	ld (newy), a
	jp entity_walk_backwards_common
entity_walk_sword_backwards_restartanim:
	ld a, (iy+3)
	ld (newx), a
	ld a, (iy+4)
	ld (newy), a
entity_walk_sword_backwards_restartanim_common:
	ld e, (iy+0)
	ld d, (iy+1)
	ld hl, 96*3
	add hl, de		; HL has the new sprite address
	ld (iy+0), l
	ld (iy+1), h		; store anim
	jp player_updatesprite
;	call player_updatesprite
;	ret

entity_walk_sword_left_nomove:		; no need to move, just increase animation
	ld a, (iy+3)
	ld (newx), a
	ld a, (iy+4)
	ld (newy), a
   	jp entity_walk_left_common    

entity_walk_sword_left_restartanim:
	ld a, (iy+3)
	ld (newx), a
	ld a, (iy+4)
	ld (newy), a
entity_walk_sword_restartanim_common:
	ld e, (iy+0)
	ld d, (iy+1)
	ld hl, -(96*3)
	add hl, de		; HL has the new sprite address
	ld (iy+0), l
	ld (iy+1), h		; store anim
	jp player_updatesprite
;	call player_updatesprite
;	ret

entity_walk_sword_right:
	call get_sprite_pointer_iy ; Get the sprite pointer in IY
	ld a, (ix+5)		; get state
	and 1	
	jp z, entity_walk_sword_right_backwards	; the entity was walking left, so it needs to go backwards
	ld a, (ix+6)
	inc a
	ld (ix+6), a
	and $3
	jr z, entity_walk_sword_left_restartanim	; restart the animation after 4 animations
	cp 3
	jr nz, entity_walk_sword_left_nomove
	; check if it is possible to move right
	ld a, 8
	ld (deltax),a
	xor a
	ld (forcemove), a
	ld (deltay), a
	ld a, 1
	ld (checkstair), a
	call entity_move
	jp nc, entity_set_idle_sword		; hitting a wall	
	jp entity_walk_left_common

entity_walk_sword_right_backwards:
	ld a, (ix+6)
	dec a
	ld (ix+6), a		; next animation position
	and $3
	sub 3
;	cp 3
	jp z, entity_walk_sword_backwards_restartanim	; restart the animation after 4 animations
;	cp 2
	inc a
	jp nz, entity_walk_backwards_nomove
	; check if it is possible to move left
	ld a, 8
	ld (deltax),a
	xor a
	ld (forcemove), a
   	ld (deltay), a
	ld a, 1
	ld (checkstair), a
	call entity_move
   	jp nc, entity_set_idle_sword		; hitting a wall	
;	jp entity_walk_backwards_common
;entity_walk_sword_idle:			; we were moving, but not anymore
;	jp entity_set_idle_sword	; set the idle animation position (with sword)
;	ret
entity_walk_backwards_common:
	ld e, (iy+0)
	ld d, (iy+1)
	ld hl, -96
	add hl, de		; HL has the new sprite address
	ld (iy+0), l
	ld (iy+1), h		; store anim
	jp player_updatesprite
;	call player_updatesprite
;	ret
entity_swordback:
entity_swordmed:
entity_swordlow:
entity_swordhigh:
	xor a
	ld (deltay), a
	ld a, (ix+6)
	inc a
	ld (ix+6), a
;	cp 1
	dec a
	ret z			; two frames with the first animation position
;	cp 2
	dec a
	jp z, entity_swordhigh_slash
;	cp 4
	sub 2
	jp z, entity_swordhigh_checkcombo
;	cp 5
	dec a
	ret z
;	cp 6
	dec a
	jr z, entity_swordhigh_docombo
;	cp 7
	dec a
	jr z, entity_swordhigh_endcombo

entity_swordhigh_back:
	; for this animation, we add 192 to the animation position and set a 24x32 sprite	
	ld a, (ix+7)
	and a
	jr z, entity_swordhigh_back_nodeletespr
    call clean_second_sprite
entity_swordhigh_back_nodeletespr:
	call get_sprite_pointer_iy ; Get the sprite pointer in IY
	ld hl, 192
	ld e, (iy+0)
	ld d, (iy+1)		; DE has the sprite pointer
	add hl, de		; HL has the new sprite address
	ld (iy+0), l
	ld (iy+1), h
	ld a, (iy+3)
	ld (newx), a
	ld a, (iy+4)
	ld (newy), a
	jp player_updatesprite
;	call player_updatesprite
;	ret

entity_swordhigh_endcombo:
	ld a, (ix+7)
	and a
	jr z, entity_swordhigh_endcombo_nodeletespr
    call clean_second_sprite
entity_swordhigh_endcombo_nodeletespr:
	jp entity_set_idle_sword

entity_swordhigh_docombo:
	ld a, (ix+5)
	and 1
	jr z, entity_swordhigh_docombo_left
entity_swordhigh_docombo_right:
	call get_sprite_pointer_iy ; Get the sprite pointer in IY
	; check if it is possible to move right
    ld a, 8
	jr entity_swordhigh_docombo_common
entity_swordhigh_docombo_left:
	call get_sprite_pointer_iy ; Get the sprite pointer in IY
	; check if it is possible to move left
    ld a, -8
entity_swordhigh_docombo_common:
    ld e, a
    ld (deltax),a
	xor a
	ld (forcemove), a
    ld (deltay), a
    ld a, 1
	ld (checkstair), a
    push de
	push ix
	push iy
	call entity_move
	pop iy
	pop ix
    pop de
	jr nc, entity_swordhigh_slash	; do not move if not possible
    ; check if the entity would fall if it moved
	ld a, (iy+3)		; get X position
	add a, e			; simulate the right movement
	call entity_wouldfall_common	; and check if it would fall (A !=0)
    and a
    jr nz, entity_swordhigh_slash   ; do not move, or we'll fall
	push ix
	push iy
	call player_updatesprite
	pop iy
	pop ix
	jr entity_swordhigh_slash

entity_swordhigh_checkcombo:
	ld a, (ix+5)
	and $fe
	cp STATE_SWORD_MEDSLASH_LEFT
	jp nz, entity_set_idle_sword	; only check the basic combo if we are slashing forward
	; ok, we are slashing forward, now check direction
	ld a, (ix+5)
	and 1
	jr z, entity_swordhigh_checkcombo_left
entity_swordhigh_checkcombo_right:
	ld a, (entity_joystick)		; BIT 2 is move left
	bit 2, a
	jp z, entity_set_idle_sword	; looking right, not doing anything... set idle
	ret

entity_swordhigh_checkcombo_left:

	ld a, (entity_joystick)		
	bit 3, a			; BIT 3 is move right
	jp z, entity_set_idle_sword	; looking left, not doing anything... set idle
	ret

hitting_entity_looking_at: db 0
self_injury: db 0

entity_swordhigh_slash:
	ld (entity_current), ix  ; save the current entity
	call get_sprite_pointer_iy ; Get the sprite pointer in IY
	ld a, (ix+5)
	and 1
	ld (hitting_entity_looking_at),a	; save where the entity is looking at
	jr z, entity_swordhigh_slash_checkleft
entity_swordhigh_slash_checkright:
	call entity_slashright_hits_bkg
	jr entity_swordhigh_slash_checkcommon
entity_swordhigh_slash_checkleft:
	call entity_slashleft_hits_bkg
entity_swordhigh_slash_checkcommon:
	and a
	jr z, entity_swordhigh_slash_normal	; can slash without issues

	; we are hitting some background. B is stile X, C is stile Y. 
	ld a, FX_BLOCK_HIT
	call FX_Play
	; are we hitting a breakable object????
	call check_break_object

	ld (ix+7), 0		; no new sprite
	call get_sprite_pointer_iy ; Get the sprite pointer in IY
	ld hl, 96
	ld e, (iy+0)
	ld d, (iy+1)		; DE has the sprite pointer
	add hl, de		; HL has the new sprite address
	ld (iy+0), l
	ld (iy+1), h
	ld a, (iy+3)
	ld (newx), a
	ld a, (iy+4)
	ld (newy), a
	jp player_updatesprite
;	call player_updatesprite
;	ret
entity_swordhigh_slash_normal:
	; for this animation, we add 96 to the animation position and get a second sprite
	call NewSprite		; get address of new sprite in HL
	push hl			; save the second sprite address
	ld de, SPDATA		; we will just get the difference
	xor a			; reset carry flag
	sbc hl, de		; and get the difference
	ld a, l
	ld (ix+7), a		; store the offset of the new sprite in the last position of the entity
	ld e, (ix+0)
	ld d, (ix+1)		; DE has the sprite pointer
	pop ix			; IX has the second sprite address

	ld iyh, d
	ld iyl, e		; Get the sprite pointer in IY
	ld hl, 96
	ld e, (iy+0)
	ld d, (iy+1)		; DE has the sprite pointer
	add hl, de		; HL has the new sprite address
	ld (iy+0), l
	ld (iy+1), h

	ld de, 96
	add hl, de		; HL has the new sprite address
	ld (ix+0), l
	ld (ix+1), h
	ld a, (iy+2)		; get the sprite type
	ld (ix+2), a		; same for the other sprite
	and 1	
	jr z, entity_swordhigh_slash_right
entity_swordhigh_slash_left:
	ld a, (iy+3)		; get the X position
	ld (newx), a
	sub 24
	ld (ix+3), a		; X for the second sprite
	jr entity_swordhigh_slash_cont
entity_swordhigh_slash_right:
	ld a, (iy+3)
	ld (newx), a
	add a, 24
	ld (ix+3), a
entity_swordhigh_slash_cont:
	ld a, (iy+4)
	ld (ix+4), a
	ld (newy), a
	ld (ix+5), 3
	ld (ix+6), 4
	ld (ix+7), 1
	push ix				; save sword sprite address, we will use it to check for entity collisions!
	push iy
	ld b, (ix+3)
	ld c, (ix+4)
	call UpdateSprite
	pop iy
	call player_updatesprite
	pop ix

	ld a, FX_SWORD1
	call FX_Play

	; we are not hitting the background. Lets check if we are hitting another entity. If so,
	; we will be injuring someone
	push ix
	call entity_slash_hits_entity
	pop iy		; we have THE CURRENT entity in IY, it might be useful later on
	ret nc		; if no carry flag, no entity is injured, just continue

	; So, someone was injured. For a quick test, just go to the "ouch" position with sword
	ld ix, ENTITY_PLAYER_POINTER
	and a
	jr z, entity_swordhigh_injury_cont
	ld de, ENTITY_SIZE
entity_swordhigh_injury_loop:
	add ix, de
	dec a
	jr nz, entity_swordhigh_injury_loop
entity_swordhigh_injury_cont:
	; check if the entity is blocking. In this case, do nothing
	ld a, (ix+5)
	and $fe		; ignore the left-right bit
	cp STATE_SWORD_BLOCK_LEFT
	jr nz, entity_swordhigh_injury_otherentity
entity_swordhigh_injury_self:
	ld a, 1
	ld (self_injury), a
	ld ix, (entity_current)
	; we should here destroy the second sprite!!!
	ld a, (ix+7)
	and a
	jr z, entity_swordhigh_injury_ok_cont
    call clean_second_sprite
	jr entity_swordhigh_injury_ok_cont ; so THE CURRENT entity is ouching, because the other one is blocking
entity_swordhigh_injury_otherentity:
	xor a
	ld (self_injury), a
	; The other entity will ouch. If they are in the middle of an attack,
	; we have to delete the second sprite
	ld a, (ix+7)
	and a
	jr z, entity_swordhigh_injury_otherentity_nodeletespr

    push iy
    call clean_second_sprite
    pop iy
entity_swordhigh_injury_otherentity_nodeletespr:
	; We should reduce the entity health, and make it die if needed
	ld a, (ix+4)		; Entity energy
	and a
	ret z
    
    call get_entity_attack_damage   ; get the entity attack damage
    sub e
	jr c, entity_swordhigh_injury_otherentity_die ; the result is <0, die die die!
	ld (ix+4), a
	jr nz, entity_swordhigh_injury_ok_cont 
entity_swordhigh_injury_otherentity_die:
	ld (ix+4), 0
	; so the entity is dying!
entity_swordhigh_injury_ok_cont:
	; if IX ==  ENTITY_PLAYER_POINTER, then set entity_sprite_base to be the barbarian base
	; otherwise, make it the enemy base
	ld a, ixl
	cp ENTITY_PLAYER_POINTER%256
	jr z, entity_swordhigh_injury_ok_cont_barb
entity_swordhigh_injury_ok_cont_enemy:
	ld hl, enemy_base_sprite
	jr entity_swordhigh_injury_ok_cont_cont
entity_swordhigh_injury_ok_cont_barb:
	ld hl, barbaro_idle
entity_swordhigh_injury_ok_cont_cont:
	ld a, (ix+5)
	cp STATE_IDLE_SWORD_LEFT
	jr nc, injury_with_sword
    ; So there is no sword, but... if this is an enemy, there is no
    ; injury without sword animation
    ld a, ixl
    cp ENTITY_PLAYER_POINTER%256
    jr nz, injury_with_sword
injury_without_sword:
	ld a, (hitting_entity_looking_at)
	xor 1
	add a, STATE_OUCH_LEFT
	ld (ix+5), a
	ld (ix+6), 0		; animation is now 0	
	call get_sprite_pointer_ix ; Get the sprite pointer in IX
	ld de, SPRITE_OFFSET_OUCH
	jr injury_done
injury_with_sword:
	ld a, (self_injury)
	and a
	jr nz, injury_with_sword_self
injury_with_sword_notself:
	ld a, (hitting_entity_looking_at)
	xor 1
	add a, STATE_SWORD_OUCH_LEFT
	jr injury_with_sword_cont
injury_with_sword_self:
	ld a, (ix+5)
	and 1
	add a, STATE_SWORD_OUCH_LEFT
injury_with_sword_cont:
	ld (ix+5), a
	ld (ix+6), 0		; animation is now 0	
	call get_sprite_pointer_ix ; Get the sprite pointer in IX
	ld de, SPRITE_OFFSET_OUCH_SWORD
injury_done:
	add hl, de
	ld (ix+0), l
	ld (ix+1), h		; Store animation position

	ld a, (self_injury)
	and a
	jr nz, entity_swordhigh_injury_ok_cont_cont_selfinjury_sound
	
	ld a, (hitting_entity_looking_at)
	ld (ix+2), a
	ld a, FX_HIT
	call FX_Play
	jr entity_swordhigh_injury_ok_cont_cont_selfinjury
entity_swordhigh_injury_ok_cont_cont_selfinjury_sound:
	ld a, FX_BLOCK_HIT
	call FX_Play
entity_swordhigh_injury_ok_cont_cont_selfinjury:
	ld b, (ix+3)
	ld c, (ix+4)		; Keep position
	jp UpdateSprite
;	call UpdateSprite	; Update sprite
;	ret

; Block for two frames, then go to idle
entity_swordblock:
	ld a, (ix+6)
	inc a
	ld (ix+6), a
	cp 6
	jp z, entity_set_idle_sword
	ret

entity_switch:
	ld a, (ix+5)
	and 1
	jr z, entity_switch_left
entity_switch_right:
	ld b, 8
	jr entity_switch_go
entity_switch_left:
	ld b, -8
entity_switch_go:
	ld a, (ix+6)
	cp 3
	jp z, entity_set_idle
	and a
	jr nz, entity_switch_back
entity_switch_forw:
	ld hl, 96
	jr entity_switch_contanim	
entity_switch_back:
	ld hl, -96
	ex af, af'
	ld a, b
	neg
	ld b, a			; reverse 
	ex af, af'
entity_switch_contanim:
	inc a
	ld (ix+6), a		; increase animation position
	cp 3
	jp z, entity_switch_end	; final animation
	ld e, (ix+0)
	ld d, (ix+1)
	ld ixh, d
	ld ixl, e
	ld e, (ix+0)
	ld d, (ix+1)
entity_switch_commonanim:
	add hl, de		; HL has the new sprite address
	ld (ix+0), l
	ld (ix+1), h		; store anim
	ld a, b
	add a, (ix+3)
	ld b, a
	ld c, (ix+4)		; Keep position
	jp UpdateSprite
;	call UpdateSprite	; Update sprite
;	ret
entity_switch_end:
	call get_sprite_pointer_ix ; Get the sprite pointer in IX
	ld de, SPRITE_OFFSET_WALK
	ld hl, (entity_sprite_base)
	jr entity_switch_commonanim

; Dying animation
entity_die:
	ld a, (ix+6)
	cp 3
	jr nc, entity_die_nomore
	and a
	jr nz, entity_die_noeffect
	push af
	; Play effect (for now, just the skeleton)
	ld a, FX_SKELETON_FALL
	call FX_Play
	pop af
entity_die_noeffect:
	inc a
	ld (ix+6), a		; increase animation position

	ld e, (ix+0)
	ld d, (ix+1)
	ld ixh, d
	ld ixl, e
	ld e, (ix+0)
	ld d, (ix+1)
	ld hl, 96
	add hl, de		; HL has the new sprite address
	ld (ix+0), l
	ld (ix+1), h		; store anim
	ld b, (ix+3)
	ld c, (ix+4)		; Keep position	
	jp UpdateSprite
;	call UpdateSprite	; Update sprite
;	ret
entity_die_finished:
	ld a, (ix+6)
	cp 4
	ret z			; only increase experience once
	inc a
	ld (ix+6), a
	; increase the player exp
	jp increase_player_exp
;	call increase_player_exp
;	ret
entity_die_nomore:
	; is this the barbarian?
	ld a, ixl
	cp ENTITY_PLAYER_POINTER%256
	jr nz, entity_die_finished
    ; play gameover music
	ld a, 11            ; gameover music
	call MUSIC_Load
    ld b, 180
gameover_music_loop:
    halt
    djnz gameover_music_loop
	ld a, 1
	ld (player_dead), a
	ret

; Increase the player level, based on the defeated enemy
; INPUT: 
;	- IX: pointer to enemy

increase_player_exp:
	ld a, (ix+10)			; high nibble is enemy type
	and $f0
	cp OBJECT_ENEMY_ROCK*16-OBJECT_ENEMY_SKELETON*16  ; Is this a rock?
	ret z			; do not increase exp on broken rocks
	ld a, (ix+10)
	and $0f			; low nibble is the level	
	inc a			; and add 1 (remember we start from 0)
	ld c, a
	ld a, (player_experience)
	add a, c		; A has the new exp
	ld c, a			; and save in C
	call get_player_max_exp	; get max exp for this level in A
	cp c
	jr z, increase_player_exp_nextlevel
	jr nc, increase_player_exp_done
increase_player_exp_nextlevel:
	; so we have increased our level. Exp is now 0, set energy to max in new level
	ld a, FX_LEVEL_UP
	call FX_Play    
	ld a, (player_level)
	inc a
	ld (player_level), a			; set new level
	ld iy, ENTITY_PLAYER_POINTER
	call get_entity_max_energy
	ld (iy+4), a					; set new energy
	ld c, 0							; new exp
increase_player_exp_done
	ld a, c
	ld (player_experience), a
	ret

; Update player sprite, based on the new position
; IY points to the sprite structure

player_updatesprite:
	ld a, (newx)
	ld b, a
	ld a, (newy)
	ld c, a
	push iy
	pop ix
	jp UpdateSprite
;	call UpdateSprite
;	ret

; Generic move entity function
; INPUT:
;	- IX: pointer to entity
;	- IY: pointer to sprite structure
;	- deltax: pixels to move in X
;	- deltay: pixels to move in Y
;	- checkstair: 1 if stairs should be considered, 0 if not
;	- forcemove: 1 if movement should be forced no matter what, 0 otherwise
; OUTPUT:
;	- carry flag set: movement is possible
;	- carry flag not set: could not move
;	- newx: new X position for sprite
;	- newy: new Y position for sprite
checkstair: db 0
forcemove: db 0

entity_move:
	ld a, (deltax)
	and a
	jp z, entity_move_y
entity_move_x:
	xor a
	ld (stairy), a
	ld a, (deltax)
	ld e, a
	call entity_canmovehor	; check if the entity can move
	and a
	jr nz, entity_move_x_1
entity_move_x_0:
	ld a, (deltax)
	add a, (iy+3)
	ld (newx), a	
	ld a, (deltay)
	add a, (iy+4)
	ld b, a
	ld a, (checkstair)
	and a
	jr z, entity_move_x_0_nostair
	ld a, (stairy)
	add a, b
	ld b, a	
entity_move_x_0_nostair:
	ld a, b			
	ld (newy), a
	jp entity_move_done
entity_move_x_1:
	ld a, (cannotmove_reason)
	and a
	jr nz, entity_move_x_2
	ld a, (forcemove)
	and a
	jp z, entity_move_failed
	jr entity_move_x_0		; move anyway
entity_move_x_2:	; going to the screen on the left or the right
	call CheckScreenChange
	jr nc, entity_move_failed 
	ld a, (iy+3)
	ld (newx), a
	ld a, (iy+4)
	ld (newy), a
	jr entity_move_done
entity_move_y:
	ld a, (deltay)
	ld e, a
	call entity_canmovevert	; check if the entity can move
	and a
	jr nz, entity_move_y_3
	ld a, (deltay)
	add a, (iy+4)
	ld (newy), a	
	ld a, (iy+3)
	ld (newx), a
	jr entity_move_done
entity_move_y_3:
    ; we need to make a special case here. If an entity is falling
    ; below the screen, and it is *not* the player, it must die immediately
    push af
	ld a, ixl
	cp ENTITY_PLAYER_POINTER%256
    jr z, entity_move_y_3_barbarian ; this is the barbarian
    ld a, (cannotmove_reason)
    cp 3                            ; cannot move, because it is going down
    jr nz, entity_move_y_3_barbarian ; if not, just do whatever
    ; now, make the entity dissapear immediately
    pop af
	call entity_remove
    call set_entity_dead
	; if the enemy has a secondary entity, we need to remove it as well
	ld a, (ix+10)
	and $f0
	cp OBJECT_ENEMY_DEMON*16-OBJECT_ENEMY_SKELETON*16
	jr c, entity_move_done
	push ix
	ld ix, ENTITY_ENEMY2_POINTER
	call entity_remove	
	pop ix
entity_move_done:
	scf		; Carry flag set, we were able to "move"
    ret
entity_move_y_3_barbarian:
    pop af
	call CheckScreenChange
	ld a, (iy+3)
	ld (newx), a
	ld a, (iy+4)
	ld (newy), a
	jr entity_move_done
;entity_move_done:
;	scf		; Carry flag set, we were able to move
;	ret
entity_move_failed:
	ld a, (iy+3)
	ld (newx), a
	ld a, (iy+4)
	ld (newy), a
	xor a		; reset carry flag
	ret


entity_remove:
    ld h, (ix+1)
    ld l, (ix+0)        ; enemy sprite in HL
	push ix
	call CleanSprite	; clean sprite
	pop ix
    ld (ix+0), 0
    ld (ix+1), 0
    ld (ix+4), 0        ; reset entity (dead, sprite is NULL)
	ret

; Get highest possible Y with something not vacuum below or ar the specified position
;
; INPUT:
;	- B: X in char coordinates
;	- C: Y in char coordinates
; OUTPUT: 
;	- A: highest Y

HighYBelow:
	; Basically, we should loop through GetHardness calls
	; while Y < 10 {
 	;     value = GetHardness(X,Y)
	;     switch(value):
	;		case 0: Y++;
	;		case 1: return(x*2)
	;		case 2: return(x*2)
	;		case 3: return(x*2+1)
	; }
;	ld a, b
;	srl a
;	ld b, a		; convert X to stile coordinates
	srl b
;	ld a, c
;	srl a
;	ld c, a		; convert Y to stile coordinates
	srl c
HighYBelow_loop:	
	ld a, c
	cp 10
	jr nc, 	HighYBelow_off	; Y >= 10, go away!
	push bc
	call GetHardness
	pop bc
	and a
	jr z, HighYBelow_loop_continue	
	dec a
	jr nz, HighYBelow_2or3
HighYBelow_1:			; 1 is a full block
	ld a, c
	add a,a
	ret
HighYBelow_2or3:
	dec a
	jr z, HighYBelow_1	; it is 2, so same as 1
	ld a, c
	add a, a
	inc a			; Y*2+1
	ret
HighYBelow_loop_continue:
	inc c		; Y++
	jr HighYBelow_loop
HighYBelow_off:
	ld a, 25	; maximum Y in a screen
	ret


; Check if the entity can move up or down
; Will only check for screen exits!
; Check if entity can move left or right
; INPUT:
;	  E: number of pixels to move
;	 IY: points to the sprite structure
; OUTPUT: A 0 if can move, non-zero if cannot
;	 If it cannot move, variable cannotmove_reason will hold one of the following values:
;		0: Hit something
;		1: Going to the screen on the left
;		2: Going to the screen on the right
;		3: Going to the screen below
;		4: Going to the screen above
entity_canmovevert:
	ld a, (iy+4)
	add a, e		; The maximum Y in the screen is 160, so if y+ychars > 160 or y < 0, we are changing screen
	cp $f0
	jr nc, entity_canmovevert_goup

	ld a, e
	and $80
	jr nz, entity_canmovevert_ok	; if not going up, and the movement is negative (thus going up), ignore

	ld a, (iy+4)
	add a, e	
	; is not going up. Lets check if the value + ychars is > 160
	ld b, a
	ld a, (iy+6)
	add a, a
	add a, a
	add a, a		
	add a, b		; new Y + Ysize in chars
	cp 160
	jr nc, entity_canmovevert_godown	; the sprite is going under the screen
entity_canmovevert_ok:
	xor a
	ret
entity_canmovevert_goup:
	ld a, 4
	ld (cannotmove_reason), a
	ld a, 1
	ret
entity_canmovevert_godown:
	ld a, 3
	ld (cannotmove_reason), a
	ld a, 1
	ret




; Check if entity can move left or right
; INPUT:
;	  E: number of pixels to move
;    IX: pointer to entity
;	 IY: points to the sprite structure
; OUTPUT: A 0 if can move, non-zero if cannot
;	 If it cannot move, variable cannotmove_reason will hold one of the following values:
;		0: Hit something
;		1: Going to the screen on the left
;		2: Going to the screen on the right
;		3: Going to the screen below
;		4: Going to the screen above
;	It also updates the value of stairy, to specify if it is necessary to go up/down a stair
;
; Its basic algorithm is:
;
; if (Hardness(X+deltax,Y) != 0) cannot_move
;  else {
;        ycur=y at sprite feet
;        y0 = max y below (X+deltax,Y+31)
;        y1 = max y below (X+deltax+23,Y+31)
;        ynew=min(y0,y1)
;        if(ynew == ycur) can_move, no stair
;         else if(ynew > ycur && (ynew-ycur <9)) can_move, stair down
;          else if (ycur-ynew <9) can_move, stair up
;           else cannot_move
ycur: db 0
y0:   db 0
y1:   db 0
adjustx: db 0

entity_canmovehor:
	ld a, (iy+3)
	add a, e
	cp $f0	
	jr c, entity_canmovehor_go	; not exiting through the left or right
	; if e is negative, we are exiting through the left
	ld a, e
	and $80
	jr z, entity_canmovehor_right

entity_canmovehor_left:
	xor a
	ld (stairy), a
	ld a, 1
	ld (cannotmove_reason), a
	ret

entity_canmovehor_right:
	xor a
	ld (stairy), a
	ld a, 2
	ld (cannotmove_reason), a
	ret

entity_canmovehor_go:
	xor a
	ld (cannotmove_reason), a	; if we cannot move, it will be because we are hitting a wall
	ld (adjustx), a
	ld a, e
	and $80
	jr nz,  entity_canmovehor_go_noadjustx
	ld a, 16
	ld (adjustx), a
entity_canmovehor_go_noadjustx:
	ld a, (adjustx)	
	add a, (iy+3)		; get X position
	add a, e
;	srl a			; and divide by 16 to get to stile coordinates
;	srl a
;	srl a
;	srl a
	rra
	rra
	rra
	rra
	and 15
	ld b, a			; store in B
	ld a, (deltay)
	add a, (iy+4)
	jp m, entity_cannotmovehor ; This a really weird case, to avoid changing screen while doing a short/longjump
;	srl a			; and divide by 16 to get to stile coordinates
;	srl a
;	srl a
;	srl a
	rra
	rra
	rra
	rra
	and 15
	ld c, a			; same for the Y coordinate
    push bc
   	push de
	call GetHardness
	pop de
    pop bc
	and a			; if not 0, easy thing: cannot move
	jr z, entity_canmovehor_go_check2
    ; well, not that easy. If the hardness is 2 and the low nibble of Y is 8, we are simply going  below something
    cp 2
    jp nz, entity_cannotmovehor
    ld a, (deltay)
    add a, (iy+4)
    and $0f
    jp z, entity_cannotmovehor
entity_canmovehor_go_check2:
    inc c           ; now check the knee
    push de
	call GetHardness
    pop de
    and a
   	jr z, entity_maybecan ; if 0, no prob
	ld a, (ix+5)
	and $fe
	cp STATE_JUMP_LEFT
	jr z, entity_cannotmovehor ; Hitting with the knee and jumping
	cp STATE_LONGJUMP_LEFT
	jr z, entity_cannotmovehor ; Hitting with the knee and jumping

;   	ld a, (deltay)
;   	and a
;    jr nz, entity_cannotmovehor ; Hitting with the knee and jumping

entity_maybecan:
	ld a, (deltay)
	add a, (iy+4)		; get current Y
	add a, 32		; add 32 to go the land under its feet (FIXME if some enemies have a different size!)
	srl a
	srl a
	srl a			; and convert it to char coordinates
	ld (ycur), a		; store it for later use
	; now get the highest used char under the sprite feet, when moving to the new position
	ld a, (iy+3)		; get current X
	add a, e		; so we go to the new position
	srl a			; and divide by 8 to get to char coordinates
	srl a
	srl a	
	ld b, a			; store it in B
	ld a, (deltay)
	add a, (iy+4)	; get current Y
	add a, 31		; go to its feet (FIXME if some enemies have a different size!)
	srl a			; and divide by 8 to get to char coordinates
	srl a
	srl a	
	ld c, a			; store it in C
	push bc
	call HighYBelow			; get the highest Y in A
	ld (y0), a
	pop bc
	; the second one is easy, just need to go 2 chars to the right (FIXME if some enemies have a different size!)
	ld a, 2
	add a, b
	ld b, a			; 2 chars to the right
	call HighYBelow		; and get the second highest
	ld b, a
	ld a, (y0)
	cp b			; if B is lower than A, set it. Otherwise ignore
	jr c, entity_maybecan_y0lower
	ld a, b			; so A is the lowest possible value between y0 and y1
entity_maybecan_y0lower:
	ld b, a			; save if in B
	ld a, (ycur)		; and now compare ycur with ynew
	cp b
	jr z, entity_canmovehor_flat
	jr nc, entity_canmovehor_up	; ynew > ycur
entity_canmovehor_down:
	; so ynew > ycur, what is the difference?
	ld c, a				; C = ycur
	ld a, b				; A = ynew
	sub c
	cp 2
	jr nc, entity_canmovehor_flat	; ycur - ynew > 1 (in char terms), so we should be faaaaaalling
	ld a, 8				; in this case, ycur-ynew==1, so we need to move down
	ld (stairy), a
	xor a
	ret
entity_canmovehor_up:
	sub b
	cp 2
	jr nc, entity_cannotmovehor	; ynew - ynew > 1 (in char terms), so there is something blocking our feet
	ld a, -8			; in this case, ynew-ycur==1, so we need to move up
	ld (stairy), a
	xor a
	ret
entity_canmovehor_flat:
	xor a
	ld (stairy), a
	ret
entity_cannotmovehor:
	xor a
	ld (stairy), a
	ld a, 1
	ret


; Check if entity can hang, looking left or right
; IY points to the sprite structure
;	- E is 0 if checking left, 16 if checking right
; OUTPUT: A 0 if can move, non-zero if cannot

entity_canhang_up:
	ld a, (iy+3)		; get X position
	add a, e
;	srl a			; and divide by 16 to get to tile coordinates
;	srl a
;	srl a
;	srl a
	rra
	rra
	rra
	rra
	and 15
	ld b, a			; store in B
	ld a, (iy+4)
;	srl a
;	srl a
;	srl a
;	srl a
	rra
	rra
	rra
	rra
	and 15
	ld c, a			; same for the Y coordinate
	push de
	call GetHardness		; get the tile number in A
	pop de
	cp 2				; can only hang if the tile number is 2 or 3
	jr c, entity_canhang_up_noway
	; second check: the stile *above* should be empty!
	ld a, (iy+3)		; get X position
	add a, e
;	srl a			; and divide by 16 to get to tile coordinates
;	srl a
;	srl a
;	srl a
	rra
	rra
	rra
	rra
	and 15
	ld b, a			; store in B
	ld a, (iy+4)
	sub 16
	jr c, entity_canhang_up_thirdcheck
;	srl a
;	srl a
;	srl a
;	srl a
	rra
	rra
	rra
	rra
	and 15
	ld c, a			; same for the Y coordinate
	call GetHardness		; get the tile number in A
	and a
	jr nz, entity_canhang_up_noway
entity_canhang_up_thirdcheck:
	ld a, (iy+3)		; get X position
	add a, 8
;	srl a			; and divide by 16 to get to tile coordinates
;	srl a
;	srl a
;	srl a
	rra
	rra
	rra
	rra
	and 15
	ld b, a			; store in B
	ld a, (iy+4)
;	srl a
;	srl a
;	srl a
;	srl a
	rra
	rra
	rra
	rra
	and 15
	ld c, a			; same for the Y coordinate
	jp GetHardness
;	call GetHardness		; get the tile number in A
;	ret			; if the tile is 0, we can hang
entity_canhang_up_noway:
	ld a, 1			; do not move
	ret			

; Check if entity can hang, looking left of right
; E: -8 (left) or 24 (right)
; IY points to the sprite structure
; OUTPUT: A 0 if can hang, non-zero if cannot
;	  Additionally, canhang_half will be 0 if hanging from upper half ($X0), 1 if hanging from lower half ($X8)

canhang_delta: db 0
canhang_half: db 0

entity_canhang:
	ld a, e
	cp -8
	jr nz, entity_canhang_right
entity_canhang_left:
	ld a, 8
	jr entity_canhang_go
entity_canhang_right:
	ld a, -8
entity_canhang_go:
	ld (canhang_delta), a	
	ld a, (iy+3)		; get X position
	add a, e
	srl a			; and divide by 16 to get to stile coordinates
	srl a
	srl a
	srl a
	ld b, a			; store in B
	ld a, (iy+4)
	srl a
	srl a
	srl a
	srl a
	ld c, a			; same for the Y coordinate
	push de
	call GetHardness
	pop de
	cp 2			; if 0 or 1, easy thing: cannot hang 
	jr c, entity_canhang_noway
	; so there is some place we can hang from. First thing is to check which half it is
	cp 3
	jr z, entity_canhang_lowerhalf
entity_canhang_upperhalf:
	xor a
	jr entity_canhang_eitherhalf
entity_canhang_lowerhalf:
	ld a, 1
entity_canhang_eitherhalf:
	ld (canhang_half), a

	;Just to make sure, lets check
	; there is nothing just on top of that stile
	ld a, (iy+3)		; get X position
	add a, e
;	srl a			; and divide by 16 to get to stile coordinates
;	srl a
;	srl a
;	srl a
	rra
	rra
	rra
	rra
	and 15
	ld b, a			; store in B
	ld a, (iy+4)
;	cp 16
	sub 16	
	jr c, entity_canhang_noway	; safety check, do not try below 0!
;	sub 16
;	srl a
;	srl a
;	srl a
;	srl a
	rra
	rra
	rra
	rra
	and 15
	ld c, a			; same for the Y coordinate
	push de
	call GetHardness
	pop de
	and a			; if not 0, easy thing: cannot hang 
	jr nz, entity_canhang_noway
	; and finally, lets check we cannot hang 1 char to the left/right 
	ld a, (canhang_delta)
	add a, (iy+3)		; get X position
	add a, e
;	srl a			; and divide by 16 to get to stile coordinates
;	srl a
;	srl a
;	srl a
	rra
	rra
	rra
	rra
	and 15
	ld b, a			; store in B
	ld a, (iy+4)
;	srl a
;	srl a
;	srl a
;	srl a
	rra
	rra
	rra
	rra
	and 15
	ld c, a			; same for the Y coordinate
	push de
	call GetHardness
	pop de
	and a			; if not 0, easy thing: cannot hang because we are touching another tile
	jr nz, entity_canhang_noway
	xor a
	ret
entity_canhang_noway:
	ld a, 1			; do not move
	ret


; Check if entity can move down (may need two checks)
; IX points to the entity structure
; IY points to the sprite structure
; OUTPUT: A 0 if can move, non-zero if cannot
entity_cango_down:
;	ld a, (iy+4)
;	cp 97
;	jp nc, entity_canhang_upleft_noway ; do not try when we are down already!

	ld a, (ix+5)		; get state
	and 1			; if 0, looking left. If 1, looking right
	jr nz, entity_cangodown_lookright
entity_cangodown_lookleft:
	ld a, (iy+3)		; get X position
	add a, 16
	jr entity_cangodown_cont
entity_cangodown_lookright:
	ld a, (iy+3)
entity_cangodown_cont:
;	srl a			; and divide by 16 to get to tile coordinates
;	srl a
;	srl a
;	srl a
	rra
	rra
	rra
	rra
	and 15
	ld b, a			; store in B
	ld a, (iy+4)
	add a, 32
;	srl a
;	srl a
;	srl a
;	srl a
	rra
	rra
	rra
	rra
	and 15
	ld c, a			; same for the Y coordinate
	call GetHardness	; get the hardness value in A
	and a
	jp nz, entity_canhang_up_noway

	ld a, (ix+5)		; get state
	and 1			; if 0, looking left. If 1, looking right
	jr z, entity_cangodown2_lookleft
entity_cangodown2_lookright:
	ld a, (iy+3)
	add a, 16
	jr entity_cangodown2_cont
entity_cangodown2_lookleft:
	ld a, (iy+3)		; get X position
entity_cangodown2_cont:
;	srl a			; and divide by 16 to get to tile coordinates
;	srl a
;	srl a
;	srl a
	rra
	rra
	rra
	rra
	and 15
	ld b, a			; store in B
	ld a, (iy+4)
	add a, 32
;	srl a
;	srl a
;	srl a
;	srl a
	rra
	rra
	rra
	rra
	and 15
	ld c, a			; same for the Y coordinate
	call GetHardness	; get the hardness value in A
	cp 2			; If not 2, the stile below does not allow hanging
	jp nz, entity_canhang_up_noway

	ld a, (iy+3)		; get X position
;	srl a			; and divide by 16 to get to tile coordinates
;	srl a
;	srl a
;	srl a
	rra
	rra
	rra
	rra
	and 15
	ld b, a			; store in B
	ld a, (iy+4)
	add a, 48

;	cp 192
	cp 160
	jr nc, entity_cango_down_ok
;	srl a
;	srl a
;	srl a
;	srl a
	rra
	rra
	rra
	rra
	and 15
	ld c, a			; same for the Y coordinate
	call GetHardness	; get the hardness value in A
	and a
	jp nz, entity_canhang_up_noway
	ld a, (iy+3)		; get X position
;	srl a			; and divide by 16 to get to tile coordinates
;	srl a
;	srl a
;	srl a
	rra
	rra
	rra
	rra
	and 15
	ld b, a			; store in B
	ld a, (iy+4)
	add a, 64

;	cp 192
	cp 160
	jr nc, entity_cango_down_ok

;	srl a
;	srl a
;	srl a
;	srl a
	rra
	rra
	rra
	rra
	and 15
	ld c, a			; same for the Y coordinate
	jp GetHardness
;	call GetHardness	; get the hardness value in A
;	ret			; if the tile is 0, we can move down
entity_cango_down_ok:
	xor a
	ret


slash_deltax_1: db 0
slash_deltax_2: db 0
slash_hits_x: db 0

; Generic function for slash hit checks
; INPUT:
;	  IY: sprite structure
;       A: (iy+3), X position
; OUTPUT:- A 0 if it does not hit, 1 to 3 if it does, $ff if it goes beyond the end of the screen
;	 - If it is hitting something, B will store the X stile coord, C the Y stile coord

entity_slash_hits_bkg:
    ld d, a
    ld a, (slash_deltax_1)
    add a, d         ; X + deltax
;	srl a			; and divide by 16 to get to tile coordinates
;	srl a
;	srl a
;	srl a
	rra
	rra
	rra
	rra
	and 15
	ld b, a			; store in B
	ld a, (iy+4)
;	srl a
;	srl a
;	srl a
;	srl a
	rra
	rra
	rra
	rra
	and 15
	ld c, a			; same for the Y coordinate
	push bc
	call GetHardness	
	pop bc
	and a
	ret nz			; If the hardness is 0, it is background. If not, we are hitting the wall. 
    inc c
	push bc
	call GetHardness ; Check again, for the lower stile
	pop bc
	and a
	ret nz			; If the hardness is 0, it is background. If not, we are hitting the wall.
    dec c
	ld d, (iy+3)		; get X position again
    ld a, (slash_deltax_2)
	add a, d		; make sure we are checking *both tiles*
;	srl a			; and divide by 16 to get to tile coordinates
;	srl a
;	srl a
;	srl a
	rra
	rra
	rra
	rra
	and 15
	ld b, a			; store in B
	ld a, (iy+4)
;	srl a
;	srl a
;	srl a
;	srl a
	rra
	rra
	rra
	rra
	and 15
	ld c, a			; same for the Y coordinate
	push bc
	call GetHardness
	pop bc
    and a
    ret nz
    inc c
	push bc
	call GetHardness ; Check again, for the lower stile
	pop bc
	ret			


entity_slash_hits:
    ld a, (slash_hits_x)
	ld b, a
	ld a, (iy+4)
;	srl a
;	srl a
;	srl a
;	srl a
	rra
	rra
	rra
	rra
	and 15
	ld c, a
	ld a, $ff		; we are going beyond the left margin
	ret

; Check if the entity hits some background at its left with the sword
; INPUT:
;	  IY: sprite structure
; OUTPUT:- A 0 if it does not hit, 1 to 3 if it does, $ff if it goes beyond the end of the screen
;	 - If it is hitting something, B will store the X stile coord, C the Y stile coord

entity_slashleft_hits_bkg:
    ld a, -8
    ld (slash_deltax_1), a
    ld a, -24
    ld (slash_deltax_2), a
;    ld a, 0
	xor a
    ld (slash_hits_x), a
    ld a, (iy+3)		; get X position
	cp 24
	jr c, entity_slash_hits
    jp entity_slash_hits_bkg    

; Check if the entity hits some background at its right with the sword
; INPUT:
;	  IY: sprite structure
; OUTPUT:- A 0 if it does not hit, 1 to 3 if it does, $ff if it goes beyond the end of the screen
;	 - If it is hitting something, B will store the X stile coord, C the Y stile coord

entity_slashright_hits_bkg:
    ld a, 24
    ld (slash_deltax_1), a
    ld a, 40
    ld (slash_deltax_2), a
    ld a, 15
    ld (slash_hits_x), a
	ld a, (iy+3)		; get X position
	cp 256-47
	jr nc, entity_slash_hits
    jp entity_slash_hits_bkg



; Check if a slash is hitting another entity
; INPUT:
;	- IX: sprite for slash
; OUTPUT:
;	- If hitting an entity, carry flag is ON, and A is the entity number (ENTITY_PLAYER, ENTITY_ENEMY1 or ENTITY_ENEMY2)
entity_slash_hits_entity:
	xor a
	ld iy, ENTITY_PLAYER_POINTER

entity_slash_hits_entity_loop:
	ex af, af'
	push iy
	ld e, (iy+0)
	ld a, (iy+1)
	or e
	jr z, entity_slash_hits_entity_contloop
	; if the enemy is teleporting, ignore
	ld a, (iy+5)
	and $fe
	cp STATE_TELEPORT_LEFT
	jr z, entity_slash_hits_entity_contloop
	ld a, (iy+1)
	ld iyh, a
	ld iyl, e
	call check_sprite_overlap	; do sprites overlap?
	jr c, entity_slash_hits_entity_contloop
    ; so the sprites overlap. Just in case, lets check the entity is not dead
    pop iy
    push iy
    ld a, (iy+4)
    and a
    jr nz, entity_slash_hits_entity_yes ; energy is not zero, so there we go
entity_slash_hits_entity_contloop:
	pop iy
	ex af, af'
	inc a
	cp 3
	ret z
	ld de, ENTITY_SIZE
	add iy, de
	jr entity_slash_hits_entity_loop
entity_slash_hits_entity_yes:
	pop iy
	ld a, (iy+10)			; high nibble is enemy type
	and $f0
	cp OBJECT_ENEMY_DALGURAK*16-OBJECT_ENEMY_SKELETON*16  ; Are we hitting Dal Gurak??
	jr nz, entity_slash_hits_entity_yes_sure
	ld a, (player_current_weapon)
	cp WEAPON_BLADE
	jp nz, entity_slash_noblade			; We are hitting Dal Gurak, but are we using the right weapon?
entity_slash_hits_entity_yes_sure:
	ex af, af'			; A has the entity
	scf				; set carry flag!
	ret
	

; Check if the entity should move down because of the gravity
; IX points to the entity
; OUTPUT: A 0 if gravity should affect,non-zero if it is standing on ground
entity_checkgravity:
    ld a, (ix+10)   
	and $f0
	cp OBJECT_ENEMY_SECONDARY*16-OBJECT_ENEMY_SKELETON*16  ; Is this a secondary enemy?
    jp z, entity_checkgravity_secondary	; if so, gravity does not apply
	call get_sprite_pointer_iy ; Get the sprite pointer in IY
	ld a, (iy+3)		; get X position
;	srl a			; and divide by 16 to get to tile coordinates
;	srl a
;	srl a
;	srl a
	rra
	rra
	rra
	rra
	and 15
	ld b, a			; store in B
	ld a, (iy+4)
;	srl a
;	srl a
;	srl a
;	srl a
	rra
	rra
	rra
	rra
	and 15
	ld c, a			; same for the Y coordinate: BC have the coordinates
	ld a, (iy+6)		; A has the number of chars in Y
	srl a			; divided by 2 to get in tiles
	add a, c
	ld c, a			
	push bc
	call GetHardness	; If A is 0 or 3, it can go down
	pop bc
	and a
	jr z, 	entity_checkgravity_mayfall	
	cp 3
	jr z, 	entity_checkgravity_mayfall_checkhalfstile
	ld a, 1
	ret			; the entity is laying on the ground
entity_checkgravity_mayfall_checkhalfstile:
	; entity is on a half-tile. If the Y position is also half, then it is not falling
	ld a, (iy+4)
	and $8
	jr z, entity_checkgravity_mayfall	; it is on a stile boundary, so it may be falling
entity_checkgravity_nogravity:
	ld a, 1
	ret			; the entity is laying on the ground
entity_checkgravity_secondary:
	; we are doing a special case here. Since gravities are processed after scripts
	; the base entity may be falling already, so we need to fix the Y to make sure it is ok
	push ix
	ld ix, ENTITY_ENEMY1_POINTER
	ld e, (ix+0)
	ld d, (ix+1)		; DE has the sprite pointer
	inc de
	inc de
	inc de
	inc de
	ld a, (de)
	sub 32			; Y - 32
	pop ix
	ld e, (ix+0)
	ld d, (ix+1)		; DE has the sprite pointer
	inc de
	inc de
	inc de
	inc de
	ld (de), a
	ld a, 1
	ret			; the entity is laying on the ground


entity_checkgravity_mayfall:
	ld a, (iy+5)		; number of chars in X
	and 1			; is it an odd number?
	ld e, a
	srl a			; divided by 2 to get tiles
	add a, b
	add a, e
	ld b, a			
	call GetHardness
	and a
;	jr z, 	entity_checkgravity_willfall	
	ret z
	cp 3
	jr nz, 	entity_checkgravity_wontfall
;	ld a, 1
;	ret
;entity_checkgravity_willfall_checkhalfstile2:
	; entity is on a half-tile. If the Y position is also half, then it is not falling
	ld a, (iy+4)
	and $8
;	jr z, entity_checkgravity_willfall	; it is on a stile boundary, so it is falling
	ret z
entity_checkgravity_wontfall:
	ld a, 1
	ret			; the entity is laying on the ground

;entity_checkgravity_willfall:
;	xor a			; gravity will affect
;	ret

; Check if entity would fall if it moved left
; IY points to the sprite structure
; INPUT:
;	  E: number of pixels to move left
; OUTPUT: A 0 if can move, non-zero if cannot

entity_wouldfall_ifmoveleft:
	push iy
	push de
	ld a, e
	neg
	ld e, a
	call entity_canmovehor
	pop de
	pop iy
	and a
	ret nz				; if it cannot move left, just do not check anymore

	ld a, (iy+3)		; get X position
	sub e			; simulate the left movement
entity_wouldfall_common:
;	srl a			; and divide by 16 to get to tile coordinates
;	srl a
;	srl a
;	srl a
	rra
	rra
	rra
	rra
	and 15
	ld b, a			; store in B
	ld a, (iy+4)
;	srl a
;	srl a
;	srl a
;	srl a
	rra
	rra
	rra
	rra
	and 15
	ld c, a			; same for the Y coordinate: BC have the coordinates
	ld a, (iy+6)		; A has the number of chars in Y
	srl a			; divided by 2 to get in tiles
	add a, c
	ld c, a			
	push bc
	call GetHardness
	pop bc
	and a
	jr nz, itwouldnotfall
;	jr z, itwouldfall	; TODO verify VERY WELL!!!
	ld a, (iy+5)		; number of chars in X
	and 1			; is it an odd number?
	ld e, a
	srl a			; divided by 2 to get tiles
	add a, b
	add a, e
	ld b, a			
	call GetHardness
	and a
	jr z, itwouldfall
itwouldnotfall:
	xor a
	ret
itwouldfall:
    ; yes, it would fall, but... could it go through the stair?
    ld a, (stairy)
    and a
    jr nz, itwouldnotfall
	ld a, 1
	ret


; Check if entity would fall if it moved right
; IY points to the sprite structure
; INPUT:
;	  E: number of pixels to move right
; OUTPUT: A 0 if can move, non-zero if cannot

entity_wouldfall_ifmoveright:
	push iy
	push de
	call entity_canmovehor
	pop de
	pop iy
	and a
	ret nz				; if it cannot move left, just do not check anymore

	ld a, (iy+3)		; get X position
	add a, e			; simulate the right movement
	jr entity_wouldfall_common	; and go to the common part

; check an entity gravity, and act accordingly
; INPUT: 
;	IX: pointer to entity

entity_gravity:
	ld a, (ix+0)
	or (ix+1)
	ret z		; if the sprite pointer is NULL, the entity is not active
	ld a, (ix+5)
	and $fe
	cp STATE_JUMP_UP_LOOK_LEFT	
	ret z
	cp STATE_JUMP_LEFT	
	ret z
	cp STATE_LONGJUMP_LEFT	
	ret z
	cp STATE_HANG_LEFT	
	ret z
	cp STATE_GRAB_LEFT	
	ret z
	cp STATE_CLIMB_LEFT	
	ret z
	cp STATE_DOWN_LOOK_LEFT	
	ret z
    cp STATE_DYING_LEFT
    ret z
    cp STATE_OUCH_LEFT
    ret z

	cp STATE_FALLING_LOOK_LEFT
	jr nz, entity_fall_notfallingyet
entity_fall_alreadyfalling:
; How much should the entity fall?
	ld a, (ix+6)		; number of frames falling
	srl a
	inc a			; frames/2 + 1 is the number of chars to fall
entity_fall_falling_loop:
	push af
	push ix
	push iy
	call entity_fall_notfallingyet
	pop iy
	pop ix
	ld a, (ix+5)
	and $fe
	cp STATE_FINISHFALL_LOOK_LEFT
	jr z, entity_fall_loop_abort
	pop af
	dec a
	jr nz, entity_fall_falling_loop
	ret

entity_fall_loop_abort:
	pop af
	ret

entity_fall_notfallingyet:
	call entity_checkgravity
	and a
	jp nz, entity_dontfall
	; There is vacuum under the character, move down
    ; Check if there is a secondary sprite, and delete it if so
    ld a, (ix+7)
    and a
    jr z, entity_fall_notfallingyet_noaddsprite
    call clean_second_sprite
entity_fall_notfallingyet_noaddsprite:
	ld a, (ix+5)
	and $fe
	cp STATE_FALLING_LOOK_LEFT
	jr nz, entity_fall_start
	jr entity_fall_continue
entity_fall_start:
	ld a, (ix+5)
	and 1
	add a, STATE_FALLING_LOOK_LEFT
	ld (ix+5), a
	ld (ix+6), 0		; will hold the number of frames faling down
entity_fall_continue:
	call get_sprite_pointer_iy ; Get the sprite pointer in IY

	xor a
	ld (forcemove), a
	ld (deltax),a
	ld (checkstair), a
	ld a, 8
	ld (deltay), a
	call entity_move
    ; There is a chance this is an enemy, and it is going out of the screen
    ; if so, it will be dead here, and we should not do anything else
    ld a, (ix+0)
    or (ix+1)
    ret z       ; zero means we died in the movement process
	ld de, SPRITE_OFFSET_FALL
	ld hl, (entity_sprite_base)
	add hl, de
	ld (iy+0), l
	ld (iy+1), h		; Store animation position
	jp player_updatesprite
;	call player_updatesprite
;	ret
entity_dontfall:
	ld a, (ix+5)
	cp STATE_FALLING_LOOK_RIGHT
	jp z, entity_finishedfalling
	cp STATE_FALLING_LOOK_LEFT
	jp z, entity_finishedfalling
	cp STATE_FINISHFALL_LOOK_RIGHT
	jp z, entity_set_idle	
	cp STATE_FINISHFALL_LOOK_LEFT
	jp z, entity_set_idle
	ret

entity_finishedfalling:
	ld a, (ix+5)
	and 1
	add a, STATE_FINISHFALL_LOOK_LEFT
	ld (ix+5), a
	call get_sprite_pointer_ix
;	ld e, (ix+0)
;	ld d, (ix+1)		; DE has the sprite pointer
;	ld ixl, e
;	ld ixh, d
	ld de, SPRITE_OFFSET_FALL+96
	ld hl, (entity_sprite_base)
	add hl, de
	ld (ix+0), l
	ld (ix+1), h		; Store animation position
	ld b, (ix+3)
	ld c, (ix+4)
	jp UpdateSprite
;	call UpdateSprite
;	ret


; Check if a switch is next to the entity
; INPUT:
;	- IX: pointer to entity structure
; OUTPUT:
;	- Carry flag set if there is an entity, reset if not
;	- If set, A: object id

entity_checkswitch:
	ld a, (ix+5)
	and 1				; if it is zero, we are looking left
	jr nz, entity_checkswitch_left
entity_checkswitch_right:
	ld b, -8
	jr entity_checkswitch_cont
entity_checkswitch_left:
	ld b, 24			; C is the offset from the entity position
entity_checkswitch_cont:
	call get_sprite_pointer_iy ; Get the sprite pointer in IY
	ld a, (iy+3)
	add a, b		; A will have the new X position
;	srl a
;	srl a
;	srl a
;	srl a			; divide by 16 to get to stile coordinates
	rra
	rra
	rra
	rra
	and 15
	ld b, a			; Store in B
	ld a, (iy+4)
;	srl a
;	srl a
;	srl a
;	srl a			; divide by 16 to get to stile coordinates
	rra
	rra
	rra
	rra
	and 15
	ld c, a			; C has the Y position
	; now, loop through the current screen objects. If any object is a switch AND	
	; has the same stile coordinates AND it is active, we found it
	ld iy, ENTITY_OBJECT1_POINTER
	ld l, 5			; loop counter
	ld de, ENTITY_SIZE
entity_checkswitch_loop:
	ld a, (iy+0)
	or (iy+1)
	jr z, entity_checkswitch_loop_continue
	; so the object is active, are we in the same position?
	ld a, (iy+6)
	cp b			; same X stile?
	jr nz, entity_checkswitch_loop_continue
	ld a, (iy+7)
	cp c
	jr nz, entity_checkswitch_loop_continue
	; cool, so we found an object right next to the object.
	ld a, (iy+8)		; object type
	cp OBJECT_SWITCH	; is it a switch?
	jr nz, entity_checkswitch_loop_continue
	; so... we got it!!!
	ld a, (iy+5)		; store the object id in A
	scf			; set carry flag
	ret			; and return
entity_checkswitch_loop_continue:
	dec l
	jr z, entity_checkswitch_notfound
	add iy, de
	jr entity_checkswitch_loop
entity_checkswitch_notfound:
entity_slash_noblade:
	xor a			; reset carry flag
	ret


; Check if a teleport is being touched by the player
; OUTPUT:
;	- Carry flag set if there is an entity, reset if not

entity_check_teleport:
	push ix
	ld ix, ENTITY_OBJECT1_POINTER
	ld l, 5			; loop counter
	ld de, ENTITY_SIZE
entity_checkteleport_loop:
	ld a, (ix+0)
	or (ix+1)
	jr z, entity_checkteleport_loop_continue
	ld a, (ix+8)		; object type
	cp OBJECT_TELEPORTER	; is it a teleporter?
	jr nz, entity_checkteleport_loop_continue
	; so the object is active, are touching?
	ld iy, ENTITY_PLAYER_POINTER
	push de
	call check_stile_entity_overlap
	pop de
	jr c, entity_checkteleport_loop_continue ; if carry flag is set, not touching
	; so... we got it!!!
	pop ix
	scf			; set carry flag
	ret			; and return
entity_checkteleport_loop_continue:
	dec l
	jr z, entity_checkteleport_notfound
	add ix, de
	jr entity_checkteleport_loop
entity_checkteleport_notfound:
	pop ix
	xor a			; reset carry flag
	ret


; Player is about to hang

entity_grab:
	ld a, FX_GRIP
	call FX_Play
	ld a, (ix+5)
	and 1
	add a, STATE_HANG_LEFT	
	ld (ix+5), a
	ld (ix+6), 2
	call get_sprite_pointer_iy ; Get the sprite pointer in IY
	ld a, (ix+5)
	and 1
	jr z, entity_grab_left
entity_grab_right:
	ld a, (iy+3)		; get X position
	add a, 8
	jr entity_grab_common
entity_grab_left:
	ld a, (iy+3)		; get X position
	sub 8
entity_grab_common:
	ld (newx), a
	ld a, (iy+4)
	ld (newy), a
	ld de, SPRITE_OFFSET_JUMP_UP+96*2
	ld hl, (entity_sprite_base)
	add hl, de
	ld (iy+0), l
	ld (iy+1), h		; Store animation position
	jp player_updatesprite
;	call player_updatesprite
;	ret

; Manage rock movement
; INPUT: 
;	IX: pointer to entity

entity_rock:
	call get_sprite_pointer_iy ; Get the sprite pointer in IY
	xor a
	ld (forcemove), a
	ld (deltay), a
	ld a, 1
	ld (checkstair), a

	ld a, (ix+5)		; get state
	and 1	
	jr z, entity_rock_left
entity_rock_right:
	ld a, (ix+6)
	inc a
	and $3
	ld (ix+6), a
	ld a, 8
	ld (deltax), a
	jr entity_rock_common
entity_rock_left:
	ld a, (ix+6)
	dec a
	and $3
	ld (ix+6), a
	ld a, -8
	ld (deltax), a
entity_rock_common:
	call entity_move
	jp nc, entity_rock_crash		; hitting a wall	
	ld a, (ix+6)
	and a
	jr z, entity_rock_common_restartanim
	ld e, (iy+0)
	ld d, (iy+1)
	ld hl, 96
	add hl, de		; HL has the new sprite address
	ld (iy+0), l
	ld (iy+1), h		; store anim
entity_rock_common_continue:
	push ix
	push iy
	call player_updatesprite
	pop iy
	pop ix
	jp check_rock_kills_entity
;	call check_rock_kills_entity
;	ret
entity_rock_common_restartanim:
	ld e, (iy+0)
	ld d, (iy+1)
	ld hl, -(96*3)
	add hl, de		; HL has the new sprite address
	ld (iy+0), l
	ld (iy+1), h		; store anim
	jr entity_rock_common_continue
entity_rock_crash:
    call set_entity_dead

	ld a, (ix+5)
	and 1				; 
	add a, STATE_DYING_LEFT
	ld (ix+5), a
	ld (ix+6), 0		; animation is now 0
	call get_sprite_pointer_ix ; Get the sprite pointer in IX
	ld de, SPRITE_OFFSET_DIE
	jp entity_updatesprite
;	ret



; check if the rock is touching an entity
; actually, we only check it with the player, we can only have rocks
; on a single screen :)
; INPUT:
; 	IY is the entity sprite
; 	IX is the entity
check_rock_kills_entity:
	ld ix, ENTITY_PLAYER_POINTER
	call get_sprite_pointer_ix ; Get the sprite pointer in IX
	call check_sprite_overlap
    ret c                       ; not touching
rock_kills_entity:
	; kill entity
	push iy
	ld iy, ENTITY_PLAYER_POINTER
	call kill_entity
	pop iy
	ret

; Manage secondary entities
; INPUT: 
;	IX: pointer to entity
entity_secondary:
	ld iy, ENTITY_ENEMY1_POINTER	; we need to mimic what entity1 is doing
	ld a, (iy+5)
	and 1
	add a, STATE_SECONDARY_LEFT
	ld (ix+5), a					; set state
	ld a, (iy+6)
	ld (ix+6), a					; animation position
	; FIXME add secondary sprite checks
	ld e, (iy+0)
	ld d, (iy+1)					; HL has the entity sprite
	ld iyh, d
	ld iyl, e						; IY == primary entity sprite
;	ld e, (ix+0)
;	ld d, (ix+1)					; HL has the secondary sprite
;	ld ixh, d
;	ld ixl, e						; IX == secondary entity sprite
	call get_sprite_pointer_ix

	ld a, (iy+2)
	ld (ix+2), a					; sprite type
	ld b, (iy+3)					; xpos
	ld a, (iy+4)
	sub 32
	ld c, a					; ypos
	ld e, (iy+0)
	ld d, (iy+1)					; sprite address. The sprite for the secondary one is primary+3936
	ld hl, 3936
	add hl, de	
	ld (ix+0), l
	ld (ix+1), h					; and place in the sprite

	call UpdateSprite
	; Now check if there is a second sprite 
    ; for the secondary entity
	ld ix, ENTITY_ENEMY2_POINTER
	ld iy, ENTITY_ENEMY1_POINTER
	ld a, (iy+7)			; secondary sprite
    and a
	jr z, entity_secondary_nosecondsprite
entity_secondary_secondsprite:
	; do we have the second sprite already?
	ex af, af'
	ld a, (ix+7)
	and a
	ret nz
	call NewSprite		; get address of new sprite in HL
	push hl
	ld de, SPDATA		; we will just get the difference
	xor a			; reset carry flag
	sbc hl, de		; and get the difference
	ld a, l
	ld (ix+7), a		; store the offset of the new sprite in the last position of the entity
	ex af, af'		; A is the second sprite for the first entity
	ld e, a
	ld d, 0
	ld iy, SPDATA
	add iy, de		; IY now points to the second sprite
	ld e, (iy+0)
	ld d, (iy+1)		; DE is the sprite address
	ld hl, 3936
	add hl, de
	ex de, hl		; DE is the new sprite address
	pop ix			; IX now points to the sprite address for the secondary entity
	ld (ix+0), e
	ld (ix+1), d
	ld a, (iy+2)
	ld (ix+2), a		; sprite type
	ld a, (iy+5)
	ld (ix+5), a		; x chars
	ld a, (iy+6)
	ld (ix+6), a		; y chars
	ld b, (iy+3)
	ld a, (iy+4)
	sub 32
	ld c, a		; ypos
	jp UpdateSprite
;	call UpdateSprite
;	ret
entity_secondary_nosecondsprite:
	ld a, (ix+7)
	and a
	ret z			; There is no second sprite, so no sprite to remove
	jp clean_second_sprite
;    call clean_second_sprite
;	ret


; Go through doors
; INPUT: 
;	IX: pointer to entity
entity_door:
	ld a, (ix+6)
	inc a
	cp 4
	jp nc, entity_set_idle
	ld (ix+6), a
	ret
;entity_door_finished:
;	jp entity_set_idle
;	ret

; First phase of the teleport
entity_teleport1:
	ld a, (ix+6)
	cp 6
	ret z
	inc a
	ld (ix+6), a		; increase animation position
	cp 4
	jr nc, entity_teleport_2
	ld hl, 96
	jr entity_teleport_common
; Second phase of the teleport
entity_teleport_2:
	ld hl, -96
entity_teleport_common:
	ld e, (ix+0)
	ld d, (ix+1)
	ld ixh, d
	ld ixl, e
	ld e, (ix+0)
	ld d, (ix+1)
	add hl, de		; HL has the new sprite address
	ld (ix+0), l
	ld (ix+1), h		; store anim
	ld b, (ix+3)
	ld c, (ix+4)		; Keep position
	jp UpdateSprite


; Set entity as dead in object table
; INPUT:
;   IX: pointer to entity
set_entity_dead:
	ld a, (ix+9)	; get the object id
	add a, a	; *2 to index the array
	ld h, $FF
	ld l, a		; address the array
	ld a, 1		; 1 means dead
	ld (hl), a 
    ret

; Clean second sprite
clean_second_sprite:
    ld e, a
	ld d, 0
	ld hl, SPDATA
	add hl, de
	push ix
	call CleanSprite	; clean sprite
	pop ix
    ld (ix+7), 0
    ret

; Get the sprite pointer in IY
; Input: IX: entity
get_sprite_pointer_iy:
	ld e, (ix+0)
	ld d, (ix+1)		; DE has the sprite pointer
	ld iyh, d
	ld iyl, e		; Get the sprite pointer in IY	
	ret

; Get the sprite pointer in IX
; Input: IX: entity
get_sprite_pointer_ix:
	ld e, (ix+0)
	ld d, (ix+1)		; DE has the sprite pointer
	ld ixh, d
	ld ixl, e		; Get the sprite pointer in IY	
	ret
