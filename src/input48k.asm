; Get the status of a key
; Input: 
;	- BC: Key to get; B will hold the row number, C the bit to check
; Output:
;	- A: 0 if key is pressed, other value if pressed
	
GET_KEY_STATE:
	ld a, c		; save the bit to check in A
	ld c, $fe	; ready to read!
	in e,(c)	; get the row in e
	and e
	ret		; the key is pressed if A = 0, and not pressed if A != 0

; Here are all the key definitions
	
KEY_CAPS: 	EQU &fe01
KEY_Z: 		EQU &fe02 	
KEY_X: 		EQU &fe04
KEY_C: 		EQU &fe08
KEY_V: 		EQU &fe10
KEY_A: 		EQU &fd01
KEY_S: 		EQU &fd02
KEY_D: 		EQU &fd04
KEY_F: 		EQU &fd08
KEY_G: 		EQU &fd10
KEY_Q: 		EQU &fb01
KEY_W: 		EQU &fb02
KEY_E: 		EQU &fb04
KEY_R: 		EQU &fb08
KEY_T: 		EQU &fb10
KEY_1: 		EQU &f701
KEY_2: 		EQU &f702
KEY_3: 		EQU &f704
KEY_4: 		EQU &f708
KEY_5: 		EQU &f710
KEY_0: 		EQU &ef01
KEY_9: 		EQU &ef02
KEY_8: 		EQU &ef04
KEY_7: 		EQU &ef08
KEY_6: 		EQU &ef10
KEY_P: 		EQU &df01
KEY_O: 		EQU &df02
KEY_I: 		EQU &df04
KEY_U: 		EQU &df08
KEY_Y: 		EQU &df10
KEY_ENTER: 	EQU &bf01
KEY_L: 		EQU &bf02
KEY_K: 		EQU &bf04
KEY_J: 		EQU &bf08
KEY_H: 		EQU &bf10
KEY_SPACE: 	EQU &7f01
KEY_SS: 	EQU &7f02
KEY_M: 		EQU &7f04
KEY_N: 		EQU &7f08
KEY_B: 		EQU &7f10

; The action key will need a pressed-released check
; When action_ack is 1, it means it has been processed, so
; it will be ignored in future frames

action_ack: db 0

; Get joystick state
; joynum: 0 (Kempston), 1 (Sinclair 1), 2 (Sinclair 2), 3 (Keys)
; If joynum == 3, HL holds a pointer a 6 int array with the Key definitions (UP,DOWN, LEFT, RIGHT, FIRE, SELECT)
; Input:	
;		A: joynum
; Returns:  
;		A: joystick state
; Bit #:  76     5     4   3210
;         ||     |     |   ||||
;         XX 	BUT2  BUT1 RLDU
;
; 1 means pressed, 0 means not pressed

get_joystick:
		push bc		; save all the registers that may be modified
		push de
		push hl
		and a
		jr nz, check_sinclair1	; A==0, so Kempston
		call read_kempston_joystick
		jr get_joy_end
check_sinclair1:
		dec a
		jr nz, check_sinclair2
		call read_sinclair1_joystick
		jr get_joy_end
check_sinclair2:
		dec a
		jr nz, get_joy_redef
		call read_sinclair2_joystick
		jr get_joy_end
get_joy_redef:
		call read_redefined
get_joy_end:
		pop hl
		ld bc, 10
		add hl, bc
		ld c, (hl)
		inc hl
		ld b, (hl)
		ld l, a
;		ld bc, KEY_CAPS
		call GET_KEY_STATE
;		and a
		jr nz, get_joy_finish
get_joy_end_processaction_pressed:
		ld a, (action_ack)
		and a
		ld a, l
		jr nz, get_joy_finish_finished ; ACTION was previously pressed, but not yet released
		ld a, $20
		or l
		jr get_joy_finish_finished
get_joy_finish:
		xor a
		ld (action_ack), a		; the ACTION key is not pressed
		ld a, l
get_joy_finish_finished:
		pop de
		pop bc
		ret

;------------------------------------
; Read routine for kempston joysticks
;------------------------------------

read_kempston_joystick:
		ld c, 31
		in c, (c)		
		ld a, 255
		cp c
		jr z, nokempston	; if the value read is 255, then there is no kempston interface
		xor a		; clear carry and A
kempston_right:
		rr c
		jr nc, kempston_left
		or $08		; right is pressed
kempston_left:
		rr c
		jr nc, kempston_down
		or $04		; left is pressed				
kempston_down:
		rr c
		jr nc, kempston_up
		or $02		; down is pressed
kempston_up:
		rr c
		jr nc, kempston_fire
		or $01		; up is pressed
kempston_fire:	
		rr c
		ret nc		; no carry, just return
		or $10		
		ret
nokempston:	xor a
		ret		; nothing read

;--------------------------------------
; Read routine for Sinclair 1 joysticks
;--------------------------------------

read_sinclair1_joystick:
	       ld bc, $effe
	       in c, (c)  ; Leemos solo la fila 6-0. Los bits a 0 están pulsados
	       xor a
sinclair1_fire:
		rr c
		jr c, sinclair1_up
		or $10		; fire is pressed
sinclair1_up:
		rr c
		jr c, sinclair1_down
		or $01		; up is pressed
sinclair1_down:
		rr c
		jr c, sinclair1_right
		or $02		; down is pressed
sinclair1_right:
		rr c
		jr c, sinclair1_left
		or $08		; right is pressed
sinclair1_left:
		rr c
		ret c		; no carry, just return
		or $04		; left pressed
		ret

;--------------------------------------
; Read routine for Sinclair 2 joysticks
;--------------------------------------

read_sinclair2_joystick:
	       ld bc, $f7fe
	       in c, (c)  ; Leemos solo la fila 1-5. Los bits a 0 están pulsados
	       xor a
sinclair2_left:
		rr c
		jr c, sinclair2_right
		or $04		; left is pressed
sinclair2_right:
		rr c
		jr c, sinclair2_down
		or $08		; right is pressed
sinclair2_down:
		rr c
		jr c, sinclair2_up
		or $02		; down is pressed
sinclair2_up:
		rr c
		jr c, sinclair2_fire
		or $01		; up is pressed
sinclair2_fire:
		rr c
		ret c		; no carry, just return
		or $10		; left pressed
		ret

;--------------------------------------
; Read routine for Redefined Keys
;--------------------------------------
read_redefined:; we use d as an A 
redefined_up:
	      ld d,0
	      ld c, $fe   ; ready to read!
	      ld e,(hl)
	      inc hl
	      ld b,(hl)
	      inc hl
	      in a,(c)   ; get the row in e
	      and e
	      jr nz, redefined_down
	      inc d
redefined_down:
	      ld e,(hl)
	      inc hl
	      ld b,(hl)
	      inc hl
	      in a,(c)   ; get the row in e
	      and e
	      jr nz, redefined_left
	      inc d
	      inc d
redefined_left:
	      ld e,(hl)
	      inc hl
	      ld b,(hl)
	      inc hl
	      in a,(c)   ; get the row in e
	      and e
	      jr nz, redefined_right
	      inc d
	      inc d
	      inc d
	      inc d
redefined_right:
	      ld e,(hl)
	      inc hl
	      ld b,(hl)
	      inc hl
	      in a,(c)   ; get the row in e
	      and e
	      jr nz, redefined_fire
	      ld a, d
	      or $08
	      ld d, a
redefined_fire:
	      ld e,(hl)
	      inc hl
	      ld b,(hl)
	      inc hl
	      in a,(c)   ; get the row in e
	      and e
	      jr nz, redefined_end
	      ld a, d
	      or $10
	      ret
redefined_end:
		ld a,d
		ret


		
