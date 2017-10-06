; Scripting engine

; For each screen, there will be an associated scripting table, defining each entity behaviour
; The scripting table will have the following syntax:

; Byte 0: number of entries in the table
; Byte 1-n: Entity #Bytes [action parameters], where
;
;	- Entity is a number specifying the entity (0 is player, 1 is enemy 1, 2 is enemy 2...)
;	- #Bytes is the number of bytes used by the actions, NOT INCLUDING any previous byte (entity, #bytes)
;	- [action parameters] is an array of variable length. Each action may have 0 or more parameters, which will be defined by the parser
;
; The maximum size of the scripting table should be 256 bytes, hopefully it will be less than that for most screens
;
; During runtime, each entity will have a pointer to its area in the scripting table. 
; The #bytes byte will then be used to hold an offset to the current running action

; Each action function will receive two parameters:
; - IX: pointer to entity structure
; - HL: pointer to action parameters

script_area: EQU $7802
string_area: EQU $7800

entity_script_pointers: dw ENTITY_PLAYER_POINTER+2, ENTITY_ENEMY1_POINTER+2, ENTITY_ENEMY2_POINTER+2, ENTITY_OBJECT1_POINTER+2
			dw ENTITY_OBJECT2_POINTER+2, ENTITY_OBJECT3_POINTER+2, ENTITY_OBJECT4_POINTER+2, ENTITY_OBJECT5_POINTER+2	

; script action definitions
ACTION_NONE:		EQU 0	; do nothing, no parameters
ACTION_JOYSTICK:	EQU 1	; control position/animation with joystick, no parameters
ACTION_PLAYER:		EQU 2	; player control
ACTION_PATROL:		EQU 3	; move left-right in the area, waiting until the player is in its view area
ACTION_FIGHT:		EQU 4	; Fight
ACTION_SECONDARY:	EQU 5	; secondary entity, no parameters
ACTION_STRING:		EQU 6	; print a string in the notification area, useful for cutscenes. One parameter (db): string id
ACTION_WAIT:		EQU 7	; do nothing for a number of game frames. One parameter (db): number of frames
ACTION_MOVE:		EQU 8	; move for a number of game frames. Two parameter (db): direction, number of frames
ACTION_WAIT_SWITCH_ON:	EQU 9	; wait for a switch to be changed from 0 to 1 or 2. One parameter (db): object id
ACTION_WAIT_DEAD:	EQU 9	; wair for an enemy to be dead (its parameter is 1). One parameter (db): object id
ACTION_WAIT_DESTROYED:	EQU 9	; wair for an object to be destroyed (its parameter is 1). One parameter (db): object id
ACTION_WAIT_SWITCH_OFF:	EQU 10	; wait for a switch to be changed from 1/2 to 0. One parameter (db): object id
ACTION_TOGGLE_SWITCH_ON:	EQU 11	; toggle a switch. It will change the switch from 1 to 2, and also update the tiles. One parameter (db): object id
ACTION_TOGGLE_SWITCH_OFF: EQU 12	; toggle a switch. It will change the switch from 2 to 0, and also update the tiles. One parameter (db): object id
ACTION_OPEN_DOOR:	 EQU 13	; open a door. It will change the object value from 0 to 1, then to 2 when done, and update the tiles. One parameter (db): object id
ACTION_CLOSE_DOOR:	 EQU 14	; close a door. It will change the object value from 2 to 1, then to 0 when done, and update the tiles. One parameter (db): object id 
ACTION_REMOVE_BOXES:	 EQU 15	; remove a group of boxes. One parameter (db): object id
ACTION_RETURN_SUBSCRIPT: EQU 16  ; return from a subscript
ACTION_RESTART_SCRIPT:	EQU 17 	; restart the script
ACTION_TELEPORT:	EQU 18	; teleport. 4 params (db): x,y of screen to go, x,y position in screen (in pixels)
ACTION_KILL_PLAYER:	EQU 19	; immediately kill the player
ACTION_ENERGY:		EQU 20	; add/reduce energy on entity touching it. 1 param (db): amount of energy to add/reduce
ACTION_SET_TIMER:	EQU 21	; set global timer, which will be decremented on every frame. 1 param(db): value to set
ACTION_WAIT_TIMER_SET:	EQU 22	; wait until global timer is != 0
ACTION_WAIT_TIMER_GONE:	EQU 23	; wait until global timer is == 0
ACTION_WAIT_CONTACT:	EQU 24	; wait until the player touches the entity
ACTION_MOVE_STILE:	EQU 25	; move stile. 5 params(db): x,y for stile, deltax, deltay per frame, number of frames.
ACTION_CHANGE_OBJECT:	EQU 26  ; switch to other object. 1 param(db): id of new object
ACTION_WAIT_PICKUP:	EQU 27	; used for objects, wait until picked up
ACTION_IDLE:		EQU 28	; set the state to idle
ACTION_ADD_INVENTORY:	EQU 29	; add object to inventory. 1 param(db): id of object to add to inventory
ACTION_REMOVE_JAR:	EQU 30	; remove a jar. One parameter (db): object id
ACTION_REMOVE_DOOR:	EQU 31	; remove a door. One parameter (db): object id
ACTION_ADD_ENERGY:  EQU 32  ; add energy. One parameter (db): amount of energy to add
ACTION_CHECK_OBJECT_IN_INVENTORY: EQU 33  ; wait until an object is in the inventory. One parameter (db): object id
ACTION_REMOVE_OBJECT_FROM_INVENTORY: EQU 34  ; remove object from inventory. One parameter (db): object id
ACTION_CHECKPOINT: EQU 35	; set checkpoint. No parameters
ACTION_FINISH_LEVEL: EQU 36 ; end level. One parameter (db): 0 -> get back to main menu. 1 -> Go to next level.
ACTION_ADD_WEAPON: EQU 37   ; add weapon to inventory. One parameter (db): 1-> eclipse, 2-> axe, 3-> blade
ACTION_WAIT_CROSS_DOOR: EQU 38   ; wait until player is crossing our door
ACTION_CHANGE_STILE: EQU 39  ; change stile. 3 parameters (db): x, y in stile coords, and stile number (0-255)
ACTION_CHANGE_HARDNESS: EQU 40   ; change hardness for stile. 3 parameters (db): x, y in stile coords, hardness value (0-3)
ACTION_SET_OBJECT_STATE: EQU 41  ; set object state. 2 parameters (db): object id, state value (0: normal, 1: transitioning, 2: dead/changed, 3-255: other)
ACTION_WAIT_OBJECT_STATE: EQU 42  ; wait until the object state has a specific value. 2 parameters (db): object id, state value
ACTION_NOP: EQU 43  ; no-op action
ACTION_WAIT_CONTACT_EXT: EQU 44  ; wait for contact with area. 4 parameters (db): upper-left X in chars, upper-left Y in chars, width, height in chars
ACTION_TELEPORT_EXT:	EQU 45	; teleport without waiting for contact. 4 params (db): x,y of screen to go, x,y position in screen (in pixels)
ACTION_TELEPORT_ENEMY: EQU 46  ; teleport enemy to a different location in this screen. 2 params (db): x, y (in pixels)
ACTION_MOVE_OBJECT: EQU 47     ; move object in screen. 4 params (db): objid, deltax, deltay per frame, number of frames
ACTION_WAIT_PICKUP_INVENTORY:	EQU 48	; used for objects, wait until picked up and make sure there is space in the inventory
ACTION_FX:	EQU 49	; play an FX. 1 param (db): effect

; Action functions
action_functions:	dw action_none, action_joystick, action_player, action_patrol, action_fight, action_secondary, action_string 
			dw action_wait, action_move, action_wait_switch_on, action_wait_switch_off, action_toggle_switch_on 
			dw action_toggle_switch_off, action_open_door, action_close_door, action_remove_boxes, action_return_subscript
			dw action_restart_script, action_teleport, action_kill_player, action_energy, action_set_timer, action_wait_timer_set
			dw action_wait_timer_gone, action_wait_contact, action_move_stile, action_change_object, action_wait_pickup
			dw action_idle, action_add_inventory, action_remove_jar, action_remove_door, action_add_energy
			dw action_check_object_in_inventory, action_remove_object_from_inventory, action_checkpoint, action_finish_level
			dw action_add_weapon, action_wait_cross_door, action_change_stile, action_change_hardness, action_set_object_state
            dw action_wait_object_state, action_nop, action_wait_contact_ext, action_teleport_ext, action_teleport_enemy
			dw action_move_object, action_wait_pickup_inventory, action_fx

; Flag descriptions, will be used as parameters to functions
FLAG_PATROL_NONE:	EQU 0
FLAG_PATROL_NOFALL:	EQU 1	; do not jump blindly on platforms

FLAG_FIGHT_NONE:		EQU 0
FLAG_FIGHT_NOFALL:	EQU 1	; do not jump blindly when fighting

action_flags: db 0

; Movement definitions
MOVE_UP:			EQU 1
MOVE_DOWN:		EQU 2
MOVE_LEFT:		EQU 4
MOVE_RIGHT:		EQU 8
MOVE_FIRE:		EQU 16
MOVE_SELECT:		EQU 32
MOVE_FORWARD:		EQU 64
MOVE_BACKWARD:		EQU 128


; Load script for the current screen
; It will only load the player script. The enemy and object scripts
; will be loaded by the LoadObjects function
; INPUT
;	- HL: pointer to script

load_script:
	ld a, (hl)		; get the script for the player
	ld ix, ENTITY_PLAYER_POINTER
	ld (ix+2), a		; store script
	ld (ix+3), 0		; current address in script
	ret
	
; Run script for a given entity
; INPUT:
;	- IX: pointer to entity
;	- IY: pointer to entity scratch area
;   Scratch area is tricky. Bytes 0-5 are meant to be used only by the current script, bytes 6-7 are used for subroutines.
;   This means that, when jumping to another script, only bytes 6-7 are preserved, everything else is cleared
run_script:
	ld (entity_current), ix	; save the current entity in a variable, this will be useful someday
	ld a, (ix+2)	; get the current entity script
	ld b, 0
	add a, a	; *2, to index the array
	ld c, a		; DE is the offset in the array
	ld hl, (script_area)
	add hl, bc	; hl points to the script
	ld e, (hl)
	inc hl
	ld d, (hl)	; DE is really pointing to the script
	ex de, hl	; HL has it
	ld c, (ix+3)	; offset
	add hl, bc	; hl points to the action to execute

	ld a, (hl)
	inc hl		; HL points to the parameters	
	push hl
	add a, a
	ld c, a
	ld hl, action_functions
	add hl, bc	 
	ld e, (hl)
	inc hl
	ld d, (hl)
	pop hl	; DE has the pointer, HL points to the parameters
	ld (run_script_call+1), de

	push ix
	push iy
run_script_call: call 0	; to be dinamically updated
	pop iy
	pop ix
	; IMPORTANT: any execution to an action will return a value in A. 
	; This value is the number of bytes to add to the offset, or 0 if nothing
	and a
	ret z		; if the offset is 0, just go
	add a, (ix+3)	; add offset to returned value
	ld (ix+3), a	; and store
	; if moved, cleanup scratch area, but only bytes 0-5
	push iy
	pop hl
	ld de, 2
	ld (hl), d
	add hl, de
	ld (hl), d
	add hl, de
	ld (hl), d
	ret



; Move left and right, change to fight mode when the player is detected
; in the entity line of sight

action_patrol:
    ; if for some reason we are falling, do nothing
    ld a, (ix+5)
    and $fe
    cp STATE_FALLING_LOOK_LEFT
    jr z, action_patrol_nothing
	ld a, (hl)
	ld (action_flags), a	; Save flags
	; Check if the player is in the line of sight
	; If so, go to fight mode
	ld e, (ix+0)
	ld d, (ix+1)		; DE has the sprite pointer
	ld iyh, d
	ld iyl, e		; Get the sprite pointer in IY
	ld hl, ENTITY_PLAYER_POINTER
	ld e, (hl)
	inc hl
	ld d, (hl)		; The player sprite pointer is in DE
	inc de
	inc de
	inc de			
	inc de			; point to the player Y coord
	ld a, (de)
	cp (iy+4)		; Check if the Y coord is the same for both
	jr nz, action_patrol_noplayer ; not in the line of sight
	dec de			; point to the player X coord

	ld a, (ix+5)		; get the state
	and $fe
	cp STATE_TURNING_LEFT	; check unless we are turning
	jr z, action_patrol_noplayer	
	ld a, (ix+5)		; get the state
	and 1			; if 0, looking left. if 1, looking right
	ld a, (de)
	jr nz, action_patrol_checkright
action_patrol_checkleft:
	sub (iy+3)		; if the X is lower, it is in the line of sight
	jr nc, action_patrol_noplayer
action_patrol_fight:
	ld a, $11		; UP+FIRE
	ld (entity_joystick), a
action_wait_end:
	ld a, 2			; move to next action
	ret			
action_patrol_checkright:
	sub (iy+3)		; if the X is higher, it is in the line of sight
	jr nc, action_patrol_fight
action_patrol_noplayer:
	ld a, (ix+5)	
	cp STATE_WALK_LEFT	
	jr z, action_patrol_left
	cp STATE_TURNING_LEFT
	jr z, action_patrol_left
	cp STATE_IDLE_RIGHT
	jr z, action_patrol_left
action_patrol_right:	
	ld a, (action_flags)
	and FLAG_PATROL_NOFALL
	jr z, action_patrol_right_nocheck
	ld e, 8
    xor a
    ld (deltay), a
	call entity_wouldfall_ifmoveright
	and a
;	jr nz, action_patrol_nothing
    jr nz, action_patrol_left_nocheck   ; would fall if moving right, then move left
action_patrol_right_nocheck:
	ld a, 8
	jr action_patrol_end
action_patrol_left:
	ld a, (action_flags)
	and FLAG_PATROL_NOFALL
	jr z, action_patrol_left_nocheck
	ld e, 8
    xor a
    ld (deltay), a
	call entity_wouldfall_ifmoveleft
	and a
;	jr nz, action_patrol_nothing
    jr nz, action_patrol_right_nocheck  ; would fall if moving left, then move right
action_patrol_left_nocheck:
	ld a, 4
	jr action_patrol_end
action_patrol_nothing:
action_secondary:
	xor a
action_patrol_end:
	ld (entity_joystick), a
action_none:
	xor a			; return 0 as offset for next script
	ret

; Fight action. This will be THE action for enemies, we should add as much AI as possible
; Input:
;	- IX: pointer to entity
;	- HL: pointer to parameters. Nothing for now

PLAYER_MAX_DIST: EQU 64
PLAYER_MED_DIST: EQU 40
PLAYER_MIN_DIST: EQU 32

action_random_number: db 0
action_fight_scratch: dw 0

action_fight:
    ; if for some reason we are falling, do nothing
    ld a, (ix+5)
    and $fe
    cp STATE_FALLING_LOOK_LEFT
    jr z, action_patrol_nothing
	ld (action_fight_scratch), iy
	call random
	ld (action_random_number), a
	ld a, (ix+5)
	and $fe
	cp STATE_IDLE_LEFT		; we did some action before, and now went idle.
	jr nz, action_fight_noidle
	ld a, -2			; WARNING this could cause issues
	ret
action_fight_noidle:
	ld a, (hl)
	ld (action_flags), a	; Save flags
	ld e, (ix+0)
	ld d, (ix+1)		; DE has the sprite pointer
	ld iyh, d
	ld iyl, e		; Get the sprite pointer in IY
	ld hl, ENTITY_PLAYER_POINTER
	ld e, (hl)
	inc hl
	ld d, (hl)		; The player sprite pointer is in DE
	inc de
	inc de
	inc de			; DE now points to the X position
	inc de			; DE now points to the Y position
	ld a, (de)
	sub (iy+4)
	jr nc, 	action_fight_noidle_positive
	neg			; abs(distance in Y)
action_fight_noidle_positive:
	cp 9
	jp nc, action_fight_playergone	; distance in Y > 8, player has dissappeared!
	dec de			; OK, still there, now point to the X position
	ld a, (ix+5)		; get the state
	and 1			; if 0, looking left. if 1, looking right
	jp z, action_fight_checkleft
action_fight_checkright:
	; lets see how far from the player we are. If we are too far, get closer
	ld a, (de)		; player X
	sub (iy+3)		; minus entity X
	jp c, action_fight_playergone	; if the player has escaped to the left, switch side
	; So, we have the distance in A
	cp PLAYER_MAX_DIST
	jr c, action_fight_right_nomaxdist
action_fight_right_maxdist:
	; far from the barbarian, lets get closer
	ld a, (action_flags)
	and FLAG_FIGHT_NOFALL
	jr z, action_fight_1_nocheck
action_fight_right_getcloser:
	ld e, 8
    xor a
    ld (deltay), a
	call entity_wouldfall_ifmoveright
	and a
	jr nz, action_patrol_nothing
action_fight_1_nocheck:
	ld a, MOVE_RIGHT
	jp action_fight_go
action_fight_right_nomaxdist:
	cp PLAYER_MED_DIST
	jr c, action_fight_right_nomeddist
action_fight_right_meddist:
	; medium distance, check if we will execute a far attack
	ld de, 7	; long attack
	call get_enemy_probability ; attack probability will be in A
	ld e, a
	ld a, (action_random_number)
	cp e				; if the random number is <= than the enemy probability, the enemy will execute the attack
					; otherwise, it will get closer
	jr nc, action_fight_right_getcloser
	; so execute the attack!
	ld de, 2	; long attack
	call get_enemy_attack	; get the attack in A
	ld iy, (action_fight_scratch)
	call action_call_subscript
	jp action_patrol_nothing

action_fight_right_nomeddist:
	cp PLAYER_MIN_DIST
	jr c, action_fight_right_tooclose
action_fight_right_mindist:
	; short distance. First, we will check if the barbarian is executing a slash
	; If so, we may try to block
	ld a, (ENTITY_PLAYER_POINTER+5)	; get the barbarian state
	cp STATE_SWORD_HIGHSLASH_LEFT
	jr c, action_fight_right_mindist_attack	; if < highslash, no need to block
	cp STATE_SWORD_BLOCK_LEFT
	jr nc, action_fight_right_mindist_attack ; > backslash, no need to block
	ld de, 21	; block
	call get_enemy_probability ; attack probability will be in A
	ld e, a
	ld a, (action_random_number)
	cp e				; if the random number is >= than the enemy probability, the enemy will execute the block
	jr nc, action_fight_right_mindist_attack	
	; so block
	ld a, MOVE_UP
	jp action_fight_go

action_fight_right_mindist_attack:
	; check if we will execute a short attack
	ld de, 14	; short attack
	call get_enemy_probability ; attack probability will be in A
	ld e, a
	ld a, (action_random_number)
	cp e				; if the random number is <= than the enemy probability, the enemy will execute the attack
					; otherwise, it will get closer
	jp nc, action_patrol_nothing	; do nothing!
	; so execute the attack!
	call random	; get a second random number. If it is > 180, execute the second attack. Else, the first one
	cp 180
	jr nc, action_fight_right_attack2
action_fight_right_attack1:
	ld de, 0
	jr action_fight_right_attack_go
action_fight_right_attack2:
	ld de, 1	; long attack
action_fight_right_attack_go:
	call get_enemy_attack	; get the attack in A
	ld iy, (action_fight_scratch)
	call action_call_subscript
	jp action_patrol_nothing

action_fight_right_tooclose:	
	; we are too close, there is a 50% chance we hit the player
	ld a, (action_random_number)
	cp 128
	jr nc, action_fight_right_attack2	; attack!
;let's get further
action_fight_right_tooclose_goaway:
	ld a, MOVE_LEFT
	jp action_fight_go

action_fight_checkleft:
	ld a, (de)		; player X
	sub (iy+3)		; minus entity X
	jp nc, action_fight_playergone	; if the player has escaped to the right, switch side
	neg			; turn into a positive value
	; So, we have the distance in A
	cp PLAYER_MAX_DIST
	jr c, action_fight_left_nomaxdist
action_fight_left_maxdist:
	; far from the barbarian, lets get closer
	ld a, (action_flags)
	and FLAG_FIGHT_NOFALL
	jr z, action_fight_2_nocheck
action_fight_left_getcloser:
	ld e, 8
    xor a
    ld (deltay), a
	call entity_wouldfall_ifmoveleft
	and a
	jp nz, action_patrol_nothing
action_fight_2_nocheck:
	ld a, MOVE_LEFT
	jr action_fight_go
action_fight_left_nomaxdist:
	cp PLAYER_MED_DIST
	jr c, action_fight_left_nomeddist
action_fight_left_meddist:
	; medium distance, check if we will execute a far attack
	; medium distance, check if we will execute a far attack
	ld de, 7	; long attack
	call get_enemy_probability ; attack probability will be in A
	ld e, a
	ld a, (action_random_number)
	cp e				; if the random number is <= than the enemy probability, the enemy will execute the attack
					; otherwise, it will get closer
	jr nc, action_fight_left_getcloser
	; so execute the attack!
	ld de, 2	; long attack
	call get_enemy_attack	; get the attack in A
	ld iy, (action_fight_scratch)
	call action_call_subscript
	jp action_patrol_nothing

action_fight_left_nomeddist:
	cp PLAYER_MIN_DIST
	jr c, action_fight_left_tooclose
action_fight_left_mindist:
	; short distance. First, we will check if the barbarian is executing a slash
	; If so, we may try to block
	ld a, (ENTITY_PLAYER_POINTER+5)	; get the barbarian state
	cp STATE_SWORD_HIGHSLASH_LEFT
	jr c, action_fight_left_mindist_attack	; if < highslash, no need to block
	cp STATE_SWORD_BLOCK_LEFT
	jr nc, action_fight_left_mindist_attack ; > backslash, no need to block
	ld de, 21	; block
	call get_enemy_probability ; attack probability will be in A
	ld e, a
	ld a, (action_random_number)
	cp e				; if the random number is >= than the enemy probability, the enemy will execute the block
	jr nc, action_fight_left_mindist_attack	
	; so block
	ld a, MOVE_UP
	jr action_fight_go
action_fight_left_mindist_attack:
	;  we will execute a short attack
	ld de, 14	; short attack
	call get_enemy_probability ; attack probability will be in A
	ld e, a
	ld a, (action_random_number)
	cp e				; if the random number is <= than the enemy probability, the enemy will execute the attack
					; otherwise, it will get closer
	jp nc, action_patrol_nothing	; do nothing!
	; so execute the attack!
	call random	; get a second random number. If it is > 150, execute the second attack. Else, the first one
	cp 150
	jr nc, action_fight_left_attack2
action_fight_left_attack1:
	ld de, 0
	jr action_fight_left_attack_go
action_fight_left_attack2:
	ld de, 1	; long attack
action_fight_left_attack_go:
	call get_enemy_attack	; get the attack in A
	ld iy, (action_fight_scratch)
	call action_call_subscript
	jp action_patrol_nothing


action_fight_left_tooclose:	
	; we are too close, there is a 50% chance we hit the player
	ld a, (action_random_number)
	cp 128
	jr nc, action_fight_left_attack2	; attack!let's get further
	ld a, MOVE_RIGHT

action_fight_go:
	ld (entity_joystick), a
	xor a
	ret

action_fight_playergone:
	ld a, MOVE_SELECT
	jr action_fight_go


; Joystick movement

action_joystick:
	ld a, (ix+5)		; get current state
	and $fe			; ignore the least significant bit
	ld c, a
	ld b, 0
	ld hl, player_state_functions
	add hl, bc		; HL gets the pointer to the function
	ld e, (hl)
	inc hl
	ld d, (hl)		; DE now has the address
	ld (action_joystick_call+1), de
action_joystick_call:
	call 0			; and jump to the function
action_player:
	xor a			; return 0 as offset for next script
	ret

; Joystick movement for the main player

script_player:
	ld a, (entity_joystick)
	bit 5, a			; BIT 5 is ACTION (CAPS SHIFT)
	jr z, script_player_noaction_ack
	ld a, 1
	ld (action_ack), a
script_player_noaction_ack:
	ld a, (ix+5)		; get current state
	and $fe			; ignore the least significant bit
	ld c, a
	ld b, 0
	ld hl, player_state_functions
	add hl, bc		; HL gets the pointer to the function
	ld e, (hl)
	inc hl
	ld d, (hl)		; DE now has the address
	ld (script_player_call+1), de
script_player_call:
	call 0			; and jump to the function
	xor a			; return 0 as offset for next script
	ld (joystick_state), a	; reset joystick state
	ret

; Wait for a number of frames, doing nothing
; IY: pointer to scratch area
;	- Byte 0: used to check if the action is already started
;	- Byte 1: current number of frames waited

action_wait:
	ld a, (iy+0)
	sub ACTION_WAIT
	jr z, action_wait_notfirsttime
	ld (iy+0), ACTION_WAIT
	xor a
	ld (iy+1), a	; reset counter
action_wait_notfirsttime:
	ld (entity_joystick), a
	ld a, (iy+1)
	inc a
	ld (iy+1), a
	cp (hl)
	jp z, action_wait_end
	xor a		; have not reached the number of frames yet, so no increase in pointer
	ret

;	ld a, 2		; go to next slot in script
;	ret		

; Move for a number of frames 
; INPUT:
;	- param 1: movement
; 	- param 2: number of frames
; IY: pointer to scratch area
;	- Byte 0: used to check if the action is already started
; 	- Byte 1: used to store the movement direction
;	- Byte 2: current number of frames executing action

action_move:
	ld a, (iy+0)
	cp ACTION_MOVE
	jr z, action_move_checkdirection
	ld (iy+0), ACTION_MOVE	; store the movement
action_move_checkdirection:
	ld a, (iy+1)
	cp (hl)
	jr z, action_move_notfirsttime
	ld a, (hl)
	ld (iy+1), a		; store the movement direction
	ld (iy+2), 0	; reset counter
action_move_notfirsttime:
	push hl
	push iy
	ld a, (hl)
	bit 6, a	; bit 6 is MOVE_FORWARD
	jr z, action_move_notforward
	; so we are moving forward... where is forward?
	and 10111111b	; mask out the bit
	push af
	ld a, (ix+5)
	and 1
	jr z, action_move_forward_left
action_move_forward_right:
	pop af
	or 8		; set the move_right bit
	jr action_move_notforward
action_move_forward_left:
	pop af
	or 4		; set the move_left bit
action_move_notforward:
	bit 7, a	; bit 7 is MOVE_BACKWARD	
	jr z, action_move_notbackward
	; so we are moving backwards... where is backwards?
	and 01111111b	; mask out the bit
	push af
	ld a, (ix+5)
	and 1
	jr z, action_move_backward_left
action_move_backward_right:
	pop af
	or 4		; set the move_left bit
	jr action_move_notbackward
action_move_backward_left:
	pop af
	or 8		; set the move_right bit
action_move_notbackward:
	ld (entity_joystick), a
action_move_common:
	pop iy
	pop hl	
	inc hl
	ld a, (iy+2)	; get the number of frames
	inc a
	ld (iy+2), a
	cp (hl)
	jr nz, action_kill_player_nooverlap
	ld a, 3		; go to next slot in script
	ret

; Kill the player if it touches the entity
; No params
action_kill_player:
 	ld a, (ix+5)
	add a, a
	ld l, a
	ld h, $ff
	ld a, (hl)
	and a
	jr nz, action_kill_player_nooverlap	; if the entity status is not 0, do nothing
	ld iy, ENTITY_PLAYER_POINTER
	push iy
	call check_stile_entity_overlap
	pop iy
;	jr c, action_kill_player_nooverlap
	call nc, kill_entity
;	ld a, 1
;	ret
action_kill_player_nooverlap:
action_energy_contact_done:
	xor a
	ret

; Add energy to player
; INPUT:
;	- HL: pointer to parameters
;	  Param 1 (byte): amount of energy to add 
action_add_energy:
	ld iy, ENTITY_PLAYER_POINTER
	call action_energy_contact
    ld a, 2         ; go to next action
    ret
    

; Add/reduce the amount of energy of the entity touching this
; INPUT:
;	- HL: pointer to parameters
;	  Param 1 (byte): amount of energy to add or reduce
action_energy:
	push hl
	ld iy, ENTITY_PLAYER_POINTER
	push iy
	call check_stile_entity_overlap
	pop iy
	pop hl
;	jr nc, action_energy_contact		; player is touching	
;	push hl
;	ld iy, ENTITY_ENEMY1_POINTER
;	push iy
;	call check_stile_entity_overlap
;	pop iy
;	pop hl
;	jr nc, action_energy_contact		; enemy 1 is touching
;	push hl
;	ld iy, ENTITY_ENEMY2_POINTER
;	push iy
;	call check_stile_entity_overlap
;	pop iy
;	pop hl
;	jr nc, action_energy_contact		; enemy 2 is touching
	jr c, action_energy_contact_done
;action_energy_contact_done:
;	xor a					; no enemy is touching, just exit
;	ret
action_energy_contact:
	ld a, (iy+4)
	and a
	jr z, action_energy_contact_done	; if we are dying, do nothing more
	ld a, (hl)
	bit 7, a		; is it negative?
	jr z, action_energy_contact_add
action_energy_contact_substract:
	neg
	call get_energy_value
	ld a, (iy+4)
	sub l
	jr nc, action_energy_contact_not_negative
	xor a					; If a < 0, then a=0
action_energy_contact_not_negative:
	ld (iy+4), a
	and a
	jr nz, action_energy_contact_done
	; so the entity energy is now 0, it is dying
	ld (iy+4), 1
	call kill_entity
	jr action_energy_contact_done
action_energy_contact_add:
	call get_energy_value
	ld a, (iy+4)
	add a, l
    ld e, a         ; and store in E
    ; now check if we are going beyond the maximum energy. If so, just set the max
    call  get_entity_max_energy ; max energy for current level in A
    cp e
    jr nc, action_add_energy_nomax
    ld e, a         ; set energy to maximum
action_add_energy_nomax:
    ld (iy+4), e
	xor a
	ret

; INPUT:  A - energy percentage
; OUTPUT: L - amount of energy to add/substract
get_energy_value:
	ld h, a			; H is the amount of energy
	push hl
	call get_entity_max_energy
	pop hl
	ld e, a
	call Mul8x8		; result in HL
	ld c, 100
	call Div16_8	; HL = max_energy*100 / amount	(in HL), L is the value
	ret

; Add an object to the inventory
; INPUT:
;	-HL: pointer to parameters
;	 Param 1 (byte): object id	
action_add_inventory:
	ld e, (hl)
	ld hl, inventory
action_add_loop:
	ld a, (hl)
	and a
	jr nz, action_add_loop_cont
	ld (hl), e
	jr action_add_end
action_add_loop_cont:
	inc hl
	inc d
	ld a, d
	cp 6
	jr nz, action_add_loop
	; This is a problem: we are adding an object to the inventory, but have no slots left
action_add_end:
	ld a, 2
	ld (inv_refresh), a
	ret

; Wait for an object to be in the inventory
; INPUT:
;	-HL: pointer to parameters
;	 Param 1 (byte): object id	
action_check_object_in_inventory:
	ld c, (hl)			; store object in C
	ld hl, inventory
	ld b, INVENTORY_SIZE
action_check_in_inv_loop:
	ld a, (hl)
	cp c
	jr z, action_check_in_inv_found
	inc hl
	djnz action_check_in_inv_loop
	xor a
	ret

; Remove an object from the inventory
; INPUT:
;	-HL: pointer to parameters
;	 Param 1 (byte): object id	
action_remove_object_from_inventory:
	ld a, (hl)	
	call remove_object_from_inventory
	call force_inv_redraw
action_check_in_inv_found:		; found, go to next action in script
	ld a, 2				; NOTE: we are not checking if the object was not in the inventory
	ret

; Check if inventory is full
; OUTPUT:
;   - CY flag set: inventory is full
;   - CY flag not set: there are holes in the inventory
is_inventory_full:
	ld hl, inventory
	ld b, 6
is_inventory_full_loop:
	ld a, (hl)
	inc hl
	and a
	ret z		; if 0, cy is reset already
	djnz is_inventory_full_loop
	scf
	ret

	

; Helper function
; Remove object from inventory
; INPUT:
;	- A: object to remove

remove_object_from_inventory:
	ld c, a			; save in C
	ld hl, inventory
	ld b, INVENTORY_SIZE
remove_object_loop:
	ld a, (hl)
	cp c
	jr z, remove_object_loop_found
	inc hl
	djnz remove_object_loop
remove_object_loop_found:
	ld (hl), 0
; also, make sure there are no gaps
	ld hl, inventory
	ld b, INVENTORY_SIZE-1
remove_object_loop2:
	ld a, (hl)
	and a
	jr nz, remove_object_loop2_next
	inc hl
	ld a, (hl)
	ld c, a
	xor a 
	ld (hl), a
	dec hl
	ld (hl), c
remove_object_loop2_next:
	inc hl
	djnz remove_object_loop2
	ret

; Wait until global timer is gone (==0)
action_wait_timer_gone:
	ld a, (global_timer)
	and a
	jr nz, timer_gone_wait
	inc a
	ret


; Wait until the player touches the object
; INPUT:
;	- HL: pointer to paramaters.
action_wait_contact:
	ld iy, ENTITY_PLAYER_POINTER
	call check_stile_entity_overlap
	jr c, action_wait_no_contact		; no overlap
	ld a, 1
	ret

; Change the object
; INPUT:
;	- HL: pointer to paramaters.
;	- Param 1 (byte): new object type

action_change_object:
	push hl
	ld a, (ix+5)
	add a, a	; A*2
	ld l, a
	ld h, $ff	; The object area starts on $FF00, easy!
	xor a
	ld (hl), a
    inc hl
    ld (hl), a
	pop hl
	ld a, (hl)
	ld (ix+8), a	; new object type
	sub OBJECT_KEY_GREEN ; make it base 0
	ld e, a
	ld d, 0
	ld hl, scripts_per_pickable_object
	add hl, de
	ld a, (hl)	; this is the script
	ld (ix+2), a    ; script id
	ld (ix+3), 0	; script position
	; change the stile 
	ld hl, tiles_per_pickable_object
	add hl, de
	ld a, (hl)	; stile for object
	push af
	; now set the stile
	ld b, (ix+6)	; X in stile coords
	ld c, (ix+7)	; Y in stile coords
	push bc
	inc c
	call GetHardness
	pop bc
	and a		; if A=0, the stile below is empty, so put the new object there
	jr nz, action_change_object_nodown
	inc c
	ld (ix+7), c
action_change_object_nodown:
	pop af
	call SetStile
timer_gone_wait:
action_wait_no_contact:
action_pickup_no_contact:
	xor a		; since we are changing the object, do not do anything
	ret

; Wait until the player picks the object up, make sure
; there is room in the inventory
action_wait_pickup_inventory:
	call action_wait_pickup
	and a
	ret z
	call is_inventory_full
	jr c, action_pickup_no_contact	; if the inventory is already full, do nothing!!! TODO add sound effect to show
	ld a, 1
	ret

; Wait until the player picks the object up
action_wait_pickup:
	ld iy, ENTITY_PLAYER_POINTER
	call check_stile_entity_overlap
	jr c, action_pickup_no_contact		; no overlap
	; now check if the player is crouching
	ld iy, ENTITY_PLAYER_POINTER
	ld a, (iy+5)
	and $fe
	cp STATE_CROUCH_LEFT
	jr nz, action_pickup_no_contact
    ; Remove object
;	ld a, (ix+5)
;	add a, a	; A*2
;	ld l, a
;	ld h, $ff	; The object area starts on $FF00, easy!
;	ld (hl), 1
	ld a, FX_PICKUP
	call FX_Play
	ld a, 1			; contact and player crouching, go!
	ret

; Wait until the player is crossing this door
action_wait_cross_door:
	; check if the player is crossing the door
	ld iy, ENTITY_PLAYER_POINTER
	ld a, (iy+5)
	and $fe
	cp STATE_DOOR_LEFT
	jr nz, action_pickup_no_contact
	; so it is crossing a door, is it *this* door?
	ld iy, ENTITY_PLAYER_POINTER
	call check_stile_entity_overlap
	jr c, action_pickup_no_contact		; no overlap
	ld a, 1		; so done!
	ret


; Wait until the player touches an area
; INPUT:
;	- HL pointer to parameters.
;	- Param 1 (byte): upper-left X (in chars)
;	- Param 2 (byte): uppet-left Y (in chars)
;	- Param 3 (byte): width (in chars)
;	- Param 4 (byte): height (in chars)

action_wait_contact_ext:
	ld ix, simulatedsprite
	ld a, (hl)	; upper-left x, in chars
	inc hl
	add a, a
	add a, a
	add a, a	; a*8 (chars)
	ld (ix+3), a ; Y for simulated sprite
	ld a, (hl)	; upper-left y, in chars
	inc hl
	add a, a
	add a, a
	add a, a	; a*8 (chars)
	ld (ix+4), a ; Y for simulated sprite
	ld a, (hl)	; width in chars
	inc hl
	ld (ix+5), a
	ld a, (hl)	; height in chars
	ld (ix+6), a
	ld iy, ENTITY_PLAYER_POINTER
   	ld e, (iy+0)
	ld d, (iy+1)
	ld iyh, d
	ld iyl, e   ; get sprite from entity in IY
	call check_sprite_overlap
	jr c, action_wait_no_contact
	ld a, 5
	ret


; Set global timer
; INPUT:
;	- HL: pointer to paramaters.
;	- Param 1 (byte): value to set 

action_set_timer:
	ld a, (hl)	; value to set
	ld (global_timer), a
	ld a, 2
	ret

; Wait until global timer is set (!=0)
action_wait_timer_set:
	ld a, (global_timer)
	and a
	ret z		; if gloal_timer is 0, continue waiting
	ld a, 1
	ret


; Set entity as idle
; Input:
;	- IX: pointer to entity
;	- HL: pointer to parameters. Nothing for now
action_idle:
    call entity_set_idle
	xor a
	ld (entity_joystick), a
action_nop: ; we are overloading this action, but hey, we're saving 3 bytes :)
    ld a, 1
    ret


; Restart script
; INPUT:
;   - IX: pointer fo entity
;	- HL: pointer to parameters. 
action_restart_script:
	ld (ix+3), 0		; and set 0 as the current address in script	
    xor a
    ret                 ; And return with 0 as offset. Easy!

; Set a stile value in the current screen
; INPUT:
;   - IX: pointer to entity
;   - HL: pointer to parameters:
;	- Param 1 (byte): stile X
;	- Param 2 (byte): stile Y
;	- Param 3 (byte): stile value
action_change_stile:
	ld b, (hl)	; X
	inc hl
	ld c, (hl)	; Y
	inc hl
	ld a, (hl)	; stile value
	call SetStile
	call LoadScreen_FindAnimTiles ; some animated tiles may have moved, let's check that
	ld a, 4
	ret


; Set a stile hardness in the current screen
; INPUT:
;   - IX: pointer to entity
;   - HL: pointer to parameters:
;	- Param 1 (byte): stile X
;	- Param 2 (byte): stile Y
;	- Param 3 (byte): hardness (0-3)
action_change_hardness:
	ld b, (hl)	; X
	inc hl
	ld c, (hl)	; Y
	inc hl
	ld a, (hl)	; hardness
	call SetHardness
	ld a, 4
	ret

; Set the state for an object
; INPUT:
;	- IX: pointer to entity
;	- HL: pointer to parameters
;	- Param 1 (byte): objid
;	- Param 2 (byte): value to set
action_set_object_state:
	ld a, (hl)	; objid
    inc hl      ; point to value
	add a, a	; A*2
	ld e, a
	ld d, $ff	; The object area starts on $FF00, easy!
	ld a, (hl)	; value
	ld (de), a	; set it and go
	inc de
	xor a
	ld (de), a	; reset the second value (it's usually temp stuff, so erase it!)
	ld a, 3		; next instruction
	ret

; Wait until the state for an object has this value
; INPUT:
;	- IX: pointer to entity
;	- HL: pointer to parameters
;	- Param 1 (byte): objid
;	- Param 2 (byte): value to wait for
action_wait_object_state:
	ld a, (hl)	; objid
    inc hl      ; point to value
	add a, a	; A*2
	ld e, a
	ld d, $ff	; The object area starts on $FF00, easy!
    ex de, hl   ; HL points to the object area, DE to the value to compare to
    ld a, (de)
    cp (hl)
    jr z, action_wait_object_state_found
    xor a       ; Different values, continue
    ret
action_wait_object_state_found:
	ld a, 3		; next instruction
	ret

; Move a stile
; INPUT:
;   - IX: pointer to entity
;   - HL: pointer to parameters:
;	- Param 1 (byte): stile X
;	- Param 2 (byte): stile Y
;	- Param 3 (byte): deltax per frame
;	- Param 4 (byte): deltay per frame
;   - Param 5 (byte): number of frames
; IY: pointer to scratch area
;	- Byte 0: number of frames remaining. If 0, we need to start again
;   - Byte 1: stile X
;   - Byte 2: stile Y
; 	- Byte 3: deltax
;	- Byte 4: deltay

saved_hardness: db 0

action_move_stile:
    ld a, (iy+0)
    and a
    jr nz, action_move_stile_start
action_move_stile_first:
    ld a, (hl)      ; x
    ld (iy+1), a
    inc hl
    ld a, (hl)
    ld (iy+2), a    ; y
    inc hl
    ld a, (hl)
    ld (iy+3), a    ; deltax
    inc hl
    ld a, (hl)
    ld (iy+4), a    ; deltay
    inc hl
    ld a, (hl)
    ld (iy+0), a    ; number of frames
action_move_stile_start:
    ld b, (iy+1)
    ld c, (iy+2)

    push iy
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
	ld a, (hl)
	ld (saveA), a	; Save this tile
	xor a
	ld (hl), a	; save the updated supertile. Now we just have to update it on screen
	pop bc
	push bc
	call UpdateSuperTile
	pop bc
	push bc
    call GetHardness    ; retrieve the current hardness
    ld (saved_hardness), a ; and save it
    pop bc
	xor a
	call SetHardness	; and set the hardness of this stile to "empty"
    pop iy

    ld a, b
    add a, (iy+3)       ; x+deltax
    ld (iy+1), a
    ld b, a
    ld a, c
    add a, (iy+4)       ; y+deltay
    ld (iy+2), a
    ld c, a             ; so BC is the new stile position
    
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
	ld a, (saveA)	; recover the tile
	ld (hl), a	; save the updated supertile. Now we just have to update it on screen
    push iy
	push bc
	call UpdateSuperTile
	pop bc
	ld a, (saved_hardness)
	call SetHardness	; and set the hardness of this stile to the saved one
	call LoadScreen_FindAnimTiles ; some animated tiles may have moved, let's check that
    pop iy
    ld a, (iy+0)
    dec a
    ld (iy+0), a
    jr z, action_move_stile_finished
    xor a
    ret
action_move_stile_finished:
    ld a, 6
    ret


; Check for an overlap between an entity and an object
; INPUT:
;   - IX: Pointer to object
;   - IY: Pointer to entity
; OUTPUT:
;	- Carry flag on: no overlap
;	- Carry flag off: overlap

check_stile_entity_overlap:
    push ix
    push iy
    ld iy, simulatedsprite
	ld a, (ix+6)	; X for object
	add a, a	
	add a, a
	add a, a
	add a, a	; a*16
	ld (iy+3), a	; X for simulated sprite
	ld a, (ix+7)	; Y for object
	add a, a	
	add a, a
	add a, a
	add a, a	; a*16
	ld (iy+4), a	; Y for simulated sprite
	ld (iy+5), 2
	ld (iy+6), 2
	pop ix      ; get pointer to entity in IX
   	ld e, (ix+0)
	ld d, (ix+1)
	ld ixh, d
	ld ixl, e   ; get sprite from entity in IX
	call check_sprite_overlap
    pop ix      ; get pointer to object back in IX
    ret

; Wait until the player is touching the teleporter, then move to specified
; screen and coordinates
; INPUT:
;	- Param 1 (byte): X of screen to go
;	- Param 2 (byte): Y of screen to go
;	- Param 3 (byte): x coordinates, in pixels
;	- Param 4 (byte): y coordinates, in pixels

; action_teleport_ext does not wait for anything, and just teleports
newscreen: db 0

action_teleport:
	push hl
	ld iy, ENTITY_PLAYER_POINTER
	call check_stile_entity_overlap
	pop hl
	jr c, action_no_teleport		; no overlap
	; overlap, so teleport!!
action_teleport_teleport:
action_teleport_ext:
	ld a, (hl)
	ld (current_levelx), a
	ld d, a		 	; save current_levelx in A
	inc hl
	ld a, (hl)
	ld (current_levely), a

	and a
	jr z, teleport_LoadScreen_addx
	ld c, a			; C has current_levely
	ld a, (level_width)
	ld b, a			; B has level_width
	xor a
teleport_LoadScreen_loop:
	add a, c
	djnz teleport_LoadScreen_loop	; so we multiply current_levely*level_width
teleport_LoadScreen_addx:
	add a, d
	ld (newscreen), a

	inc hl
	ld b, (hl)
	inc hl
	ld c, (hl)			; B = newx for barbarian, C = newy
	ld ix, (ENTITY_PLAYER_POINTER)
	ld a, b
	ld (initial_coordx), a
	ld a, c
	ld (initial_coordy), a
	call UpdateSprite
	ld a, (newscreen)
	call ChangeScreen
	xor a
	ret
action_no_teleport:
	xor a
	ret

; Open this door
; INPUT:
;	- Param 1 (byte) object id
action_open_door:
	ld a, (hl)	; object id to wait on
	cp 255
	jr z, action_open_door_cont
    call find_object ; on exit, A should keep the value (or crash), IX point to the object for the door to be opened
action_open_door_cont:
	ld a, (ix+5)	 ; get the door id
	add a, a	; A*2
	ld l, a
	ld h, $ff	; The object area starts on $FF00, easy!
	ld a, (hl)	; if the value is 2, the door is already open
	cp 2
	jr z, action_open_door_done
	inc l
	ld a, (hl)	; will do 3 steps. If got to 3, exit
	and a
	jr nz, action_open_door_checkcont
;	push af
	ld a, FX_OPEN_DOOR
	call FX_Play
;	pop af
	xor a
action_open_door_checkcont:
	cp 3
	jr nz, action_open_door_continue
	xor a
	ld (hl), a	; cleanup
	dec hl
action_open_door_done:
	ld a, 2
	ld (hl), a	; The door is open
	ret		; go to next item
action_open_door_continue:
	ld a, (ix+6) 	; X in stile coords
	ld b, a
	ld a, (ix+7)	; Y in stile coords
	add a, 3
	sub (hl)	; This is the stile to make blank (for now)
	ld c, a
	ld a, (hl)
	inc a
	ld (hl), a	; Store the new value in A

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
	ld a, (hl)
	ld (saveA), a	; Save this tile, we will put it in Y-1
	xor a
	ld (hl), a	; save the updated supertile. Now we just have to update it on screen
	pop bc
	push bc
	call UpdateSuperTile
	pop bc
	xor a
	call SetHardness	; and set the hardness of this stile to "empty"
	dec c		; Y-1
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
	ld a, (saveA)	; recover the tile
	ld (hl), a	; save the updated supertile. Now we just have to update it on screen
	pop bc
	push bc
	call UpdateSuperTile
	pop bc
	xor a
	call SetHardness	; and set the hardness of this stile to "empty"
	xor a
	ret

; Close this door
; INPUT:
;	- Param 1 (byte) object id
simulated_object: ds 8

action_close_door:
	ld a, (hl)	; object id to wait on
	cp 255
	jr z, action_close_door_cont
    call find_object ; on exit, A should keep the value (or crash), IX point to the object for the door to be opened
action_close_door_cont:
	ld a, (ix+5)	 ; get the door id
	add a, a	; A*2
	ld l, a
	ld h, $ff	; The object area starts on $FF00, easy!
	ld a, (hl)	; if a is 0, it is already closed, so go away
	and a
	jr nz, action_close_door_notclosed
	ld a, 2
	ret
action_close_door_notclosed:
	inc l
	ld a, (hl)	; will do 3 steps. If got to 3, exit
	and a
	jr nz, action_close_door_checkcont
;	push af
	ld a, FX_OPEN_DOOR
	call FX_Play
;	pop af
	xor a
action_close_door_checkcont:
	cp 3
	jr nz, action_close_door_continue
	xor a
	ld (hl), a	; Cleanup
	dec hl
	ld (hl), a	; The door is open
	ld a, 2
	ret		; go to next item
action_close_door_continue:
	ld b, (ix+6) 	; X in stile coords
	add  a, (ix+7)	; Y in stile coords
	ld c, a
	ld a, (hl)
	inc a
	ld (hl), a	; Store the new value in A

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
	ld a, (hl)
	ld (saveA), a	; Save this tile, we will put it in Y+1
	dec a
	ld (hl), a	; save the updated supertile. Now we just have to update it on screen
	pop bc
	push bc
	call UpdateSuperTile
	pop bc
	ld a,1
	call SetHardness	; and set the hardness of this stile to "full"
	inc c		; Y+1
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
	ld a, (saveA)	; recover the tile
	ld (hl), a	; save the updated supertile. Now we just have to update it on screen
	pop bc
	push bc
	call UpdateSuperTile
	pop bc
	ld a,1
	call SetHardness	; and set the hardness of this stile to "full"

	; now check if we are crushing any entity. Remember, B=stileX, Y=stileY
	push ix
	ld ix, simulated_object
	ld (ix+6), b
	ld (ix+7), c

	ld iy, ENTITY_PLAYER_POINTER
	push iy
	call check_stile_entity_overlap
	pop iy
	call nc, kill_entity
	ld iy, ENTITY_ENEMY1_POINTER
	ld a, (iy+0)
	or (iy+1)
	jr z, close_check_2
 	push iy
	call check_stile_entity_overlap
	pop iy
	call nc, kill_entity
close_check_2:
	ld iy, ENTITY_ENEMY2_POINTER
	ld a, (iy+0)
	or (iy+1)
	jr z, close_check_3
 	push iy
	call check_stile_entity_overlap
	pop iy
	call nc, kill_entity
close_check_3:
	pop ix	
	xor a
	ret


; Teleport an enemy in the current screen
; INPUT:
;	- Param 1 (byte): X of screen to go (in pixels)
;	- Param 2 (byte): Y of screen to go
; IY: pointer to scratch area
;	- Byte 0: used to check if the action is already started

action_teleport_enemy:
	; Avoid corner case: do not teleport if enemy energy == 0
	ld a, (ix+4)
	and a
	ret z
	ld a, (iy+0)
	cp ACTION_TELEPORT_ENEMY
	jr z, action_teleport_enemy_notfirsttime
	ld (iy+0), ACTION_TELEPORT_ENEMY
	; set entity to state STATE_TELEPORT_[LEFT|RIGHT] and update sprite
	ld a, (ix+5)
	and 1
	add a, STATE_TELEPORT_LEFT
	ld (ix+5), a
	ld hl, SPRITE_OFFSET_LOW_SWORD
	push ix
	call entity_startmove_sword_common
	pop ix
action_teleport_enemy_donefornow:
	jp action_secondary
action_teleport_enemy_notfirsttime:
	; there is a chance that, while teleporting, we changed state (e.g. if we were hit)
	; in that case, abort script
	ld a, (ix+5)
	and $fe
	cp STATE_TELEPORT_LEFT
	jr nz, action_teleport_enemy_finished
	ld a, (ix+6)
	cp 3
	jr nz, action_teleport_enemy_checkend
	; Here we should teleport
	ld a, (hl)		; B == X 
	inc hl
	ld c, (hl)		; C == Y
	ld e, (ix+0)
	ld d, (ix+1)		; DE has the sprite pointer
	ld iyh, d
	ld iyl, e		; Get the sprite pointer in IY
	ld (newx), a
	ld a, c			; get Y position
	ld (newy), a
	push ix
	call player_updatesprite
	call RedrawAllSprites		; When teleporting, we can invalidate too many tiles
	pop ix
	jp action_secondary
action_teleport_enemy_checkend:
	cp 6
	jp nz, action_secondary
    call entity_set_idle
action_teleport_enemy_finished:
	ld a, 3		; Finished!
	ret


; Move an object, and its associated stile
; INPUT:
;   - IX: pointer to entity
;   - HL: pointer to parameters:
;	- Param 1 (byte): objid
;	- Param 2 (byte): deltax per frame
;	- Param 3 (byte): deltay per frame
;   - Param 4 (byte): number of frames
; IY: pointer to scratch area
;	- Byte 0: number of frames remaining. If 0, we need to start again
;   - Byte 1: stile X	-> passed to subfunction in action_move_stile
;   - Byte 2: stile Y	-> passed to subfunction in action_move_stile
; 	- Byte 3: deltax
;	- Byte 4: deltay

action_move_object:
	ld a, (hl)	; object id 
	cp 255
	jr z, action_move_object_cont
    call find_object ; on exit, A should keep the value (or crash), IX point to the object for the object to be moved
action_move_object_cont:
	ld a, (iy+0)
	and a
	jr nz, action_move_object_start
	inc hl	; deltax
	ld a, (hl)
	ld (iy+3), a	; deltax
	inc hl
	ld a, (hl)
	ld (iy+4), a	; deltay
	inc hl
	ld a, (hl)
	ld (iy+0), a	; number of frames
action_move_object_start:
	ld a, (ix+6)	; x, in stile coordinates
	ld (iy+1), a
	ld a, (ix+7)	; y, in stile coordinates
	ld (iy+2), a
	push ix
	call action_move_stile_start	; use the move_stile function to move the tile
	pop ix
	ld a, (iy+1)	; new X
	ld (ix+6), a	; and store
	ld a, (iy+2)	; new Y
	ld (ix+7), a	; and store
	ld a, (iy+0)
	and a
	jr z, action_move_object_done
	xor a
	ret
action_move_object_done:
	ld a, 5
	ret

; Inmediately kill entity
; INPUT
;	- IY: pointer to entity
kill_entity:
;	ld a, (iy+4)
;	and a
;	ret z		; the entity energy is already 0, so it is dead 
	ld a, (iy+5)	; get the state
	and $fe
	cp STATE_OUCH_LEFT
    ret z       ; if the entity is already in the "ouch" state, we've been here before
	cp STATE_DYING_LEFT
	ret z
	xor a
	ld (iy+4), a
	ld a, (iy+5)	; set the ouch state
	and 1		; if zero, idle looking left, else idle looking right
	add a, STATE_OUCH_LEFT
	ld (iy+5), a
	ld (iy+6), 0		; animation is now 0	
	ld a, FX_HIT
	jp FX_Play
	

; Remove a group of 4 boxes, updating hardness map accordingly
; INPUT:
;	- Param 1 (byte) object id
action_remove_boxes:
	ld a, (hl)	; object id 
	cp 255
	jr z, action_remove_boxes_cont
    call find_object ; on exit, A should keep the value (or crash), IX point to the object for the door to be opened
action_remove_boxes_cont:
	ld a, (ix+5)	; get the box id
	add a, a	; A*2
	inc a		; Parameters
	ld l, a
	ld h, $ff	; The object area starts on $FF00, easy!
	ld a, (hl)	; will do 4 steps. If got to 4, exit
	cp 4
	jr z, action_remove_boxes_finished
	inc a
	ld (hl), a	; next step
	; So, now we should put all boxes as stile 235+A
	add a, 235
    ld b, (ix+6)
    ld c, (ix+7)
	call SetStile
	; now we should now if the key box is on the left or the right
	push af
	ld a, (ix+8)	; object type
	cp OBJECT_BOX_LEFT
	jr z, action_remove_boxes_left
object_remove_boxes_right:
	pop af
	dec b
	dec hl		; box to the left
	ld (hl), a	; store the new tile
	push hl
	push bc
	push af
	call UpdateSuperTile
	pop af
	pop bc
	pop hl
	inc c
	ld de, 16
	add hl, de	; box below-left
	ld (hl), a	; store the new tile
	push hl
	push bc
	push af
	call UpdateSuperTile
	pop af
	pop bc
	pop hl	
	inc hl
	inc b
	ld (hl), a
	call UpdateSuperTile
	xor a
	ret
action_remove_boxes_left:
	pop af
	inc b
	inc hl		; box to the right
	ld (hl), a	; store the new tile
	push hl
	push bc
	push af
	call UpdateSuperTile
	pop af
	pop bc
	pop hl
	inc c
	ld de, 16
	add hl, de	; box below-right
	ld (hl), a	; store the new tile
	push hl
	push bc
	push af
	call UpdateSuperTile
	pop af
	pop bc
	pop hl	
	dec b
	dec hl		; box to the left
	ld (hl), a
	call UpdateSuperTile
	xor a
	ret

action_remove_boxes_finished:
	ld a, (ix+6) 	; X in stile coords
	ld b, a
	ld a, (ix+7)	; Y in stile coords
	ld c, a		; This is the stile to make blank (for now)
	push ix
	call empty_supertile
	pop ix
	ld a, (ix+8)	; object type
    push ix
	cp OBJECT_BOX_LEFT
	jr z, action_remove_boxes_finished_left
action_remove_boxes_finished_right:
	dec b
	call empty_supertile
	inc c
	call empty_supertile
	inc b	
	call empty_supertile
    jr action_remove_boxes_finished_end
action_remove_boxes_finished_left:
	inc b
	call empty_supertile
	inc c
	call empty_supertile
	dec b	
	call empty_supertile
action_remove_boxes_finished_end:
    pop ix
    ld a, (ix+5)
    add a, a
    ld l, a
    ld h, $ff
	ld a, 2		; Go to next action in script
    ld (hl), a
	ret



; Remove a door (vertical group of 3 vert stiles), updating hardness map accordingly
; INPUT:
;	- Param 1 (byte) object id
action_remove_door:
	ld a, (hl)	; object id 
	cp 255
	jr nz, action_remove_door_cont
	ld a, (ix+5)	; if the parameter is 255, object id is "self"
action_remove_door_cont:
	add a, a	; A*2
	inc a		; Parameters
	ld l, a
	ld h, $ff	; The object area starts on $FF00, easy!
	ld a, (hl)	; will do 4 steps. If got to 4, exit
	cp 4
	jr z, action_remove_door_finished
	inc a
	ld (hl), a	; The door is open
	; So, now we should put all stiles as stile 235+A
	add a, 235
    ld b, (ix+6)
    ld c, (ix+7)
	dec c	; Y - 1
	call SetStile
	inc c
	ld de, 16
	add hl, de
	ld (hl), a	; store the new tile
	push hl
	push bc
	push af
	call UpdateSuperTile
	pop af
	pop bc
	pop hl
	inc c
	ld de, 16
	add hl, de	; box below-left
	ld (hl), a	; store the new tile
	push hl
	push bc
	push af
	call UpdateSuperTile
	pop af
	pop bc
	pop hl	
	xor a
	ret
action_remove_door_finished:
	; We should use some animation, I guess. For now, just destroy them and play some sound
	ld a, (ix+6) 	; X in stile coords
	ld b, a
	ld a, (ix+7)	; Y in stile coords
	dec a
	ld c, a		; This is the stile to make blank (for now)
	call empty_supertile
	inc c
	call empty_supertile
	inc c
	call empty_supertile
	ld a, 2		; Go to next action in script
	ret

; Remove a jar (1 stile), updating hardness map accordingly
; INPUT:
;	- Param 1 (byte) object id
action_remove_jar:
	ld a, (hl)	; object id 
	cp 255
	jr z, action_remove_jar_cont
    call find_object ; on exit, A should keep the value (or crash), IX point to the object for the door to be opened
action_remove_jar_cont:
	ld a, (ix+5)	; if the parameter is 255, object id is "self"
	add a, a	; A*2
	inc a		; Parameters
	ld l, a
	ld h, $ff	; The object area starts on $FF00, easy!
	ld a, (hl)	; will do 4 steps. If got to 4, exit
	cp 4
	jr z, action_remove_jar_finished
	inc a
	ld (hl), a	; The jar is broken
	; So, now we should put the stile as stile 235+A
	add a, 235
    ld b, (ix+6)
    ld c, (ix+7)
	call SetStile
	xor a
	ret
action_remove_jar_finished:
	; We should use some animation, I guess. For now, just destroy them and play some sound
	ld b, (ix+6) 	; X in stile coords
	ld c, (ix+7)	; Y in stile coords
    push ix
	call empty_supertile
    pop ix
    ld a, (ix+5)
    add a, a
    ld l, a
    ld h, $ff
	ld a, 2		; Go to next action in script
    ld (hl), a
	ret


; Finish level
; INPUT:
;	- Param 1 (byte): 0 -> get back to main menu. 1 -> Go to next level. 2-> Finished game!
action_finish_level:
    ld a, (hl)  ; action
    add a, 2
    ld (player_dead), a
    cp 3
    jr nz,action_finish_nonewlevel
    ld a, (current_level)
    inc a
    ld (current_level), a
action_finish_nonewlevel:
    xor a
    ret

; Add a weapon to the inventory
; INPUT:
;	- Param 1 (byte): 1->eclipse, 2->axe, 3->blade
action_add_weapon:
	ld e, (hl)	; weapon
	ld d, 0
	ld hl, player_available_weapons
	add hl, de
	ld a, 1
	ld (hl), a
    ld a, 2
	ret

; Wait for a switch to be non-zero
; INPUT:
;	- Param 1 (byte) object id
action_wait_switch_on:
	ld a, (hl)	; object id to wait on
	cp 255
	jr nz, action_wait_switch_on_cont
	ld a, (ix+5)	; if the parameter is 255, object id is "self"
action_wait_switch_on_cont:
	add a, a	; A*2
	ld l, a
	ld h, $ff	; The object area starts on $FF00, easy!
	ld a, (hl)
	and a	
	ret z		; If a is zero, return. Also, check again!
action_wait_switch_off_ok:
	ld a, 2		; The switch is non-zero now. Move on
	ret

; Wait for a switch to be zero
; INPUT:
;	- Param 1 (byte) object id
action_wait_switch_off:
	ld a, (hl)	; object id to wait on
	cp 255
	jr nz, action_wait_switch_off_cont
	ld a, (ix+5)	; if the parameter is 255, object id is "self"
action_wait_switch_off_cont:
	add a, a	; A*2
	ld l, a
	ld h, $ff	; The object area starts on $FF00, easy!
	ld a, (hl)
	cp 2
	jr nz, action_wait_switch_off_ok
	xor a
	ret 		; switch is still on


saveA: db 0
toggle_amount: db 0

; Toggle a switch from 1 to 2, and update tiles accordingly
action_toggle_switch_on:
	ld a, (hl)	; object id
	cp 255
	jr z, action_toggle_switch_on_cont
    call find_object ; on exit, A should keep the value (or crash), IX point to the object for the switch to be toggled
action_toggle_switch_on_cont:
	ld a, (ix+5)	; if the parameter is 255, object id is "self"
	add a, a
	ld l, a
	ld h, $ff
	ld a, 2
	ld (hl), a	; set the value to 2
	ld (toggle_amount), a
action_toggle_switch_execute:
	; now, get back and update the supertile
	ld a, (ix+6) 	; X in stile coords
	ld b, a
	ld a, (ix+7)	; Y in stile coords
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
	ld a, (toggle_amount)
	add a, (hl)	; THIS is the supertile to increment
			    ; FIXME WE ARE ASSUMING TILES FOR SWITCHES TO BE ONE AFTER ANOTHER!!
	ld (hl), a	; save the updated supertile. Now we just have to update it on screen
	push af
	ld de, 16
	add hl, de	; go to next row
	ld a, (toggle_amount)
	add a, (hl)
	ld (hl), a	; and increase it as well
	ld (saveA), a
	pop af
	pop bc
	push bc
	call UpdateSuperTile
	pop bc
	inc c		; Y+1
	ld a, (saveA)
	call UpdateSuperTile
	ld a, 2		; jump to next action in script, always!
	ret

; Toggle a switch from 2 to 0, and update tiles accordingly
action_toggle_switch_off:
	ld a, (hl)	; object id
	cp 255
	jr z, action_toggle_switch_off_cont
    call find_object ; on exit, A should keep the value (or crash), IX point to the object for the switch to be toggled
action_toggle_switch_off_cont:
	ld a, (ix+5)	; if the parameter is 255, object id is "self"
	add a, a
	ld l, a
	ld h, $ff
	ld (hl), 0	; set the value to 0
	; now, get back and update the supertile
	ld a, -2
	ld (toggle_amount), a
	jr action_toggle_switch_execute


; print a string in the notification area, useful for cutscenes. 
; INPUT:
;	- Param1 (byte) string id
action_string:
	ld a, 1
	ld (score_semaphore), a	; the score area is now my precious!!!
	push ix
	push hl
	call clean_scorearea	; Clean score area to print the string
	pop hl
	pop ix
	ld a, (hl)
	add a, a
	ld c, a
	ld b, 0
	ld hl, (string_area)
	add hl, bc		; HL now points to the string address
	ld a, (hl)	
	ld iyl, a
	inc hl
	ld a, (hl)
	ld iyh, a		; IY now holds the pointer to the string
;	ld b, 1
;	ld c, 21		; Go print string	
	ld bc, $0115
	call print_string
	call wait_till_read
	call load_scorearea
	xor a
	ld (score_semaphore), a	; now you can do whatever you want with the score area
	ld a, 2
	ret



; Call a sub-script (subroutine). 
; WARNING: we only allow ONE LEVEL OF RECURSION. There is no such a thing as a stack
; We are simply using the scratch area to store the current script and script position
; INPUT:
;	-  A: script id
;	- IX: pointer to entity
;	- IY: pointer to scratch area
;		- Byte 6: script id
;		- Byte 7: script position
action_call_subscript:
	ld e, a
	ld a, (ix+2)
	ld (iy+6), a	; save script id
	ld a, (ix+3)
	ld (iy+7), a	; save script position
	ld (ix+2), e	; store new script
	ld (ix+3), 0	; pointer in script	
	ret


; Return from a subscript
; INPUT:
;	- IX: pointer to entity
;	- IY: pointer to scratch area
;		- Byte 6: script id
;		- Byte 7: script position

action_return_subscript:
	ld a, (iy+6)
	ld (ix+2), a	; restore script id
	ld a, (iy+7)
	ld (ix+3), a	; restore script position
	xor a
	ret

; Set checkpoint
; No parameters
action_checkpoint:
	; Set initial_coordx and initial_coordy based on the player coords
	ld a, (SPDATA+3)
	ld (initial_coordx), a
	ld a, (SPDATA+4)
	ld (initial_coordy), a
	call SaveCheckpoint
	ld a, 1			; next script
	ret


; Find object pointer, based on objid
; INPUT:
;   A: object id
; OUTPUT:
;   IX: pointer to object
; Warning: if no object is found, it will crash!
find_object:
    ld ix, ENTITY_OBJECT1_POINTER
    ld bc, 12
    ld e, a   
find_object_loop:
 	ld a, (ix+5)
    cp e
    ret z       ; if the object id matches, we can go!
    add ix, bc
    jr find_object_loop


; Find next word
; INPUT:
;	IY: pointer to string
; OUTPUT:
;	D: word length
next_word:
	ld d, 0
next_word_loop:
	ld a, (iy+0)
	and a
	ret z
	cp ' '
	jr z, next_word_finished
	cp ','
	jr z, next_word_finished
	cp '.'
	jr z, next_word_finished
	inc d
	inc iy
	jr next_word_loop
next_word_finished:
	inc d
	ret	

; Wait until the user has read the line
wait_till_read:
	xor a
	ld (joystick_state), a	; reset joystick state
	ld bc, 30*256+23
	ld a, 64
	push bc
	call print_char
	call switchscreen_setrambank7
	pop bc
	call CopyTile
	call switchscreen_setrambank0
wait_till_read_loop:
	ld a, (joystick_state)
	bit 4, a
	jr z, wait_till_read_loop
	xor a
	ld (joystick_state), a	; reset joystick state
	ld a, FX_TEXT
	call FX_Play
	ret

; Print a string, terminated by 0
; INPUT:
;	IY: pointer to string
;	B: X in chars
;	C: Y in chars

print_string:
	push iy
	call next_word
	pop iy
	ld a, d
	and a
	ret z		; return on NULL
	
	add a, b
	cp 32
	jr c, print_str_nonextline
print_str_nextline: 	; go to next line
	ld b, 1
	inc c
	ld a, c
	cp 24
	jr nz, print_str_nonextline
	push iy
	push de
	call wait_till_read
	call clean_scorearea
	pop de
	pop iy
	ld bc, 256+21

print_str_nonextline:
	; now print word
	call print_word
	jr print_string
	ret

; Print a word on screen
; INPUT:
;	- B: X in chars
;	- C: Y in chars
;	- D: word length

wait_alternate: db 0

print_word:
	ld a, (iy+0)
	push de
	push iy
	push bc

	call print_char

	pop bc
	push bc
	ld a, (wait_alternate)
	xor 1
	ld (wait_alternate), a
	and a
	call z, waitforVBlank
	; copy the tile to the main screen (this is slow, I know!)
	call switchscreen_setrambank7
	pop bc
	push bc
	call CopyTile
	call switchscreen_setrambank0
	pop bc
	pop iy
	pop de

	inc iy
	inc b
	ld a, d
	dec a
	ld d, a
	jr nz, print_word
	ret

; Print a string on screen, not controlling line breaks
; INPUT:
;	IY: pointer to string
;	B: X in chars
;	C: Y in chars
print_string2:
	ld a, (iy+0)
	and a
	ret z		; return on NULL
	push iy
	push bc
	call print_char
	pop bc
	push bc

	; copy the tile to the main screen (this is slow, I know!)
	call switchscreen_setrambank7
	pop bc
	push bc
	call CopyTile
	call switchscreen_setrambank0
	pop bc
	pop iy
	inc iy
	inc b
	jr nz, print_string2
	ret	

; Play an effect
; INPUT:
;	- param 1: effect number
action_fx:
	ld a, (hl)	; effect id
	call FX_Play
	ld a, 2
	ret

switchscreen_setrambank0:
	di
	call switchscreen	; Show main screen (from bank 7)
	call setrambank0	; and set RAM bank 0
	ei
	ret

switchscreen_setrambank7:
	di 
	call switchscreen	; Now show shadow screen, where everything is ok
	call setrambank7		; and place RAM bank 7
	ei
	ret
