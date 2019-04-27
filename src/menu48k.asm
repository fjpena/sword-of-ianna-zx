;org $C000
org $0000
INCLUDE "ianna48k.sym"

marcador: incbin "marcador.scr"
marcador_armas: dw marcador_armas_sword, marcador_armas_eclipse, marcador_armas_axe, marcador_armas_blade

marcador_armas_sword:
	DEFB	  0,106, 74,106, 42, 42,111,  0
	DEFB	  0,187,170,170,171,170,186,  0
	DEFB	  0,176,168,168, 40,168,176,  0
	DEFB	  0,  0, 28, 48, 14, 50, 28,  0
	DEFB	  0,128,  0,191,149,170,  0,128
	DEFB	  0,  0,  0,248, 86,168,  0,  0
	DEFB	 71, 71, 71,  6, 69, 71
marcador_armas_eclipse:
	DEFB	  0,109, 73,105, 73, 73,109,  0
	DEFB	  0, 46, 42, 42, 46, 40,168,  0
	DEFB	  0,216,144,216, 80, 80,216,  0
	DEFB	  0,  0, 28, 48, 14, 50, 28,  0
	DEFB	  0,  0,  0,190,148,  0,  0,  0
	DEFB	 60,102,195,195,165,219,102, 60
	DEFB	 71, 71, 71,  6, 66, 69
marcador_armas_axe:
	DEFB	  0,117, 85, 82,117, 85, 85,  0
	DEFB	  0, 96, 64, 96, 64, 64, 96,  0
	DEFB	  0,  0,  0,  0,  0,  0,  0,  0
	DEFB	  0,  0, 28, 48, 14, 50, 28,  0
	DEFB	  0,  0,  0,191,149,  0,  0,  0
	DEFB	126,181, 24,125, 85, 24,173,126
	DEFB	 71, 71,  0,  6, 66, 69
marcador_armas_blade:
	DEFB	  0,100, 84,100, 84, 84,102,  0
	DEFB	  0,236,170,170,234,170,172,  0
	DEFB	  0,192,128,192,128,128,192,  0
	DEFB	  0,  0, 28, 48, 14, 50, 28,  0
	DEFB	  0,128,  0,191,128,170,  0,128
	DEFB	  0, 16, 56,252,  7,172, 56, 16
	DEFB	 71, 71, 71,  6, 69, 71

; Character sprite with different weapons
barbarian_sword: incbin "barbaro_sword.cmp"
barbarian_eclipse: incbin "barbaro_eclipse.cmp"
barbarian_axe: incbin "barbaro_axe.cmp"
barbarian_blade: incbin "barbaro_blade.cmp"

mainmenu_ram6:	jp mainmenu
HEX_TO_TEXT_ram6: jp HEX_TO_TEXT
ENCODE_ram6: jp ENCODE
intro_p6: jp intro
ending_p6: jp ending

FONT: 
include "font.asm"
cambianivel_p6: jp cambianivel
; Main menu

;screen_to_show:   db 0
;timer: db 0
;menu_option: db 0

JOY_KEMPSTON	EQU 0
JOY_SINCLAIR1	EQU 1
JOY_SINCLAIR2	EQU 2
JOY_KEYS	EQU 3

mainmenu:
	ld a, 0xbf
	ld hl, 0x8000	
	ld de, menu_isr
	call SetIM2

	xor a
	ld (screen_to_show), a
	ld (menu_loops), a
 	ld (current_level), a
	ld (changed_settings), a
	ld hl, player_available_weapons
	ld de, player_available_weapons + 1
	ld bc, 6
	ld (hl), a
	ldir
	jp showmenu
;	call showmenu
;	ret

DECODE:
	ld ix, password_value
	ld a, (ix+0)
	and $0f
	ld (current_level), a
	ld hl, 0
	ld (player_available_weapons), hl
	ld (player_available_weapons+2), hl
	ld iy, player_available_weapons
	ld a, (ix+0)
	bit 7, a
	jr z, decode_2
	ld (iy+0), 1
decode_2:
	bit 6, a
	jr z, decode_3
	ld (iy+1), 1
decode_3:
	bit 5, a
	jr z, decode_4
	ld (iy+2), 1
decode_4:
	bit 4, a
	jr z, decode_end
	ld (iy+3), 1
decode_end:
	ld a, (ix+1)
	ld (player_level), a
	ld a, (ix+2)
	ld (player_experience), a
	ld a, (ix+3)
	ld (player_current_weapon), a
	ret

ENCODE:
	ld e, 0		; e == checksum
	ld ix, score_password_value
	ld a, (current_level)
	ld b, a
	ld hl, player_available_weapons
	ld c, $80
	call testbyte
	ld c, $40
	call testbyte	
	ld c, $20
	call testbyte	
	ld c, $10
	call testbyte
	ld a, b
	add a, e
	ld e, a
	ld a, b
	xor $55
	ld (ix+0), a
	ld a, (player_level)
	add a, e
	ld e, a
	ld a, (player_level)
	xor $55
	ld (ix+1), a
	ld a, (player_experience)
	add a, e
	ld e, a
	ld a, (player_experience)
	xor $55
	ld (ix+2), a
	ld a, (player_current_weapon)
	add a, e
	ld e, a
	ld a, (player_current_weapon)
	xor $55
	ld (ix+3), a
	ld (ix+4), e	; checksum
	ret

; INPUT:
; C: byte to add
; HL: pointer
testbyte:
	ld a, (hl)
	inc hl
	and a
	ret z
	ld a,b
	or c
	ld b,a
	ret

; Calculate screen position
; INPUT
;	B: X position
;	C: Y position
; OUTPUT:
;	HL: screen position

calcscreenpos:
        ld a, c			; 4
		and $07			; 7  <-the 3 lowest bits are the line within a char
		ld h,a			; 4
		ld a,c			; 4  <- the top 2 bits are the screen third
		rra			; 4
		rra			; 4
		rra			; 4
		and $18			; 7
		or h			; 4
		or $40			; 4
		ld h,a			; 4 (total 50 t-states) H has the high byte of the address 
		
		ld a,b			;4
		rra			;4
		rra			;4
		rra			;4
		and $1f			;7  <- the top 5 bits are the char pos. The low 3 bits are the pixel pos
		ld l,a			;4
		ld a,c			;4
		rla			;4
		rla			;4
		and $e0			;7
		or l			;4
		ld l,a			;4 (total 54 t-states) L has the low byte of the address
		ret

; 8 bytes starting at X=12 (in tile coords)
; D: destination Y (in pixels)
; E: source Y
scroll_line:
	push de
	push bc

	push de
	ld c, d
	ld b, 96
	call calcscreenpos	; destination screen position in HL
	pop de
	ex de, hl		; destination screen position in DE
	ld c, l
	ld b, 96
	call calcscreenpos	; source screen position in HL
	ld b, 8
scroll_line_loop:
	ld a, (hl)
	ld (de), a
	inc l
	inc e
	djnz scroll_line_loop
    pop bc
    pop de
	ret

scrollup:
	halt
	halt
	halt
	halt
	ld de, 17*8*256 + 17*8+1
	ld b, 16
scrollup_loop_up:
	call scroll_line
	inc d
	inc e
	djnz scrollup_loop_up

	ld de, 19*8*256 + 19*8+2
	ld b, 14
scrollup_loop_middle:
	call scroll_line
	inc d
	inc e
	djnz scrollup_loop_middle

	ld de, 20*8*256+6*256 + 21*8
	call scroll_line
	ld de, 20*8*256+7*256 + 21*8
	call scroll_line

	ld de, 21*8*256 + 21*8+1
	ld b, 16
scrollup_loop_down:
	call scroll_line
	inc d
	inc e
	djnz scrollup_loop_down
	ret

scrolldown:
	halt
	halt
	halt
	halt
	ld de, 22*8*256+7*256 + 22*8+6
	ld b, 16
scrolldown_loop_down:
	call scroll_line
	dec d
	dec e
	djnz scrolldown_loop_down
	ld de, 21*8*256 + 20*8+6
	ld b, 14
scrolldown_loop_middle:
	call scroll_line
	dec d
	dec e
	djnz scrolldown_loop_middle
	ld de, 19*8*256+2*256 + 19*8
	call scroll_line
	ld de, 19*8*256+1*256 + 19*8
	call scroll_line

	ld de, 19*8*256 + 18*8+7
	ld b, 16
scrolldown_loop_up:
	call scroll_line
	dec d
	dec e
	djnz scrolldown_loop_up
	ret


;current_string_list: dw string_list_es
string_list: dw string_1, string_2, string_3, string_4, string_5_1
string_list_es: dw string_1_es, string_2, string_3_es, string_4, string_5_1
string_1: db "  PLAY  ",0
string_2: db "PASSWORD",0
string_3: db "ENGLISH ",0
string_4: db "REDEFINE",0
string_1_es: db " JUGAR  ",0
string_3_es: db "ESPA$OL ",0
string_5_1:  db "MUSIC/FX",0
string_5_2:  db " MUSIC  ",0
string_5_3:  db "   FX   ",0
string_long: db "                                ",0
;credit_timer: db 0
;credit_current: db 0

menu_cleancreditsattr:
	ld e, 0
	ld bc, 22
	ld a, 32
	call credit_setattr_loop
	ld e, 7
	ld bc, 23
	ld a, 32
	call credit_setattr_loop
	ld bc, 23
	ld iy, string_long
	jp print_string3
	;call print_string3
	;ret

showmenu:
	xor a
	ld (menu_running), a
	ld (menu_counter), a
	ld (start_delta), a
	call showmenu_select_language

	ld hl, menu_screen
	;ld de, 16384
	call depackscr

	xor a
	ld (menu_option), a
	ld (credit_timer), a
	ld e, a
	call credit_setattr

	ld ix, (current_string_list)
	ld a, (ix+8)
	ld iyl, a
	ld a, (ix+9)
	ld iyh, a
	ld bc, 12*256 + 18
	call print_string3

	ld a, (ix+0)
	ld iyl, a
	ld a, (ix+1)
	ld iyh, a
	ld bc, 12*256 + 19
	call print_string_double
	ld a, (ix+2)
	ld iyl, a
	ld a, (ix+3)
	ld iyh, a
	ld bc, 12*256 + 21
	call print_string3
	ld a, (ix+4)
	ld iyl, a
	ld a, (ix+5)
	ld iyh, a

	ld bc, 12*256 + 22
	call print_string3
	ld a, (ix+6)
	ld iyl, a
	ld a, (ix+7)
	ld iyh, a

	ld bc, 12*256 + 17
	call print_string3

	ld a, 1
	ld (menu_running), a
showmenu_loop:
	ld a, (credit_timer)
	and a
	jr nz, showmenu_credit_phase1
	ld a, (credit_current)
	add a, a
	ld e, a
	ld d, 0
	ld hl, string_credits
	add hl, de
	ld a, (hl)
	inc hl
	ld iyl, a
	ld a, (hl)
	ld iyh, a		; IY points to the current credit
	ld bc, 8*256 + 23
	call print_string3

	ld a, (credit_current)
	inc a
	cp 4									
	jr nz, showmenu_credit_nochange
	xor a
showmenu_credit_nochange:
	ld (credit_current), a
	jr showmenu_credit_continue
showmenu_credit_phase1:
	cp 8
	jr nc, showmenu_credit_phase2
	call credit_fadein
	jr showmenu_credit_continue
showmenu_credit_phase2:
	cp 248
	jr c, showmenu_credit_continue
	call credit_fadeout	
showmenu_credit_continue:
	ld a, (credit_timer)
	inc a
	ld (credit_timer), a
showmenu_loop_continue:
	halt
	ld a, (joystick_status)
	bit 1, a		; Down
	jp z, showmenu_checkscrolldown

	xor a
	ld (timer), a
	ld (menu_loops), a ; something pressed, do not go to attract mode

	ld a, FX_INVENTORY_MOVE
	call FX_Play

	ld a, (menu_option)
	inc a
	cp 5
	jr c, showmenu_loop_no5
	xor a
showmenu_loop_no5:
	ld (menu_option), a
	jp showmenu_scrollup
showmenu_checkscrolldown:
	bit 0, a		; Up
	jp z, showmenu_checkfire

	xor a
	ld (timer), a
	ld (menu_loops), a ; something pressed, do not go to attract mode

	ld a, FX_INVENTORY_MOVE
	call FX_Play
	
	ld a, (menu_option)
	dec a
	cp 5
	jr c, showmenu_loop_no0
	ld a, 4
showmenu_loop_no0:
	ld (menu_option), a
	jp showmenu_scrolldown
showmenu_checkfire:
	bit 4, a		; Fire
	jr nz, showmenu_firepressed
showmenu_nothingpressed:
	ld a, (timer)
	inc a
	ld (timer), a		; anytime the timer reaches 0 (around 5 secs) we change the screen
	jp nz, showmenu_loop
	ld a, (menu_loops)
	inc a
	ld (menu_loops), a
	cp 14
	jp z, showmenu_go_attract	; after 14 loops (~70 secs) we go to attract mode
	jp showmenu_loop
showmenu_firepressed:
	xor a
	ld (timer), a
	ld (menu_loops), a ; something pressed, do not go to attract mode
showmenu_waitnofire:
	call check_firepress
	jr c, showmenu_waitnofire		; fire not pressed

	ld a, FX_OPEN_DOOR 
	call FX_Play

	ld a, (menu_option)
	and a
	jr nz, showmenu_fire_check1
	ret
showmenu_fire_check1:
	dec a
	jr nz, showmenu_fire_check2		; if menu_option is 1, then we are going for password
	call menu_password			;  A == 255 : password not valid
	cp 255 
	jr z, showmenu_p_fail
    cp 253
    jr nz, showmenu_p_ok
    call DECODE_SECRETLEVEL
	ld iy, string_passwordok
	jr showmenu_p_print
showmenu_p_ok:
	; here, set current_level and other stuff 
	call DECODE
	ld iy, string_passwordok
	jr showmenu_p_print
showmenu_p_fail:
	ld iy, string_passwordfail
	call showmenu_p_print
	jp showmenu
showmenu_p_print:
	push iy
	call menu_cleancreditsattr
	pop iy
	ld bc, 8*256 + 23
	call print_string3
showmenu_p_waitfire:
	call check_firepress
	jr nc, showmenu_p_waitfire		; fire not pressed
showmenu_p_waitnofire:
	call check_firepress
	jr c, showmenu_p_waitnofire		; fire not pressed
	ret
showmenu_fire_check2:
	dec a
	jr nz, showmenu_fire_check3		; if menu_option is 2, then we are going for password
	ld a, 1
	ld (changed_settings), a
	ld a, (language)
	xor 1
	ld (language), a
	call showmenu_select_language
	jp showmenu
showmenu_fire_check3:		; menu_option is 3, redefine
	dec a
	jr nz, showmenu_fire_check4
	call redefine_keys
	ld a, 1
	ld (changed_settings), a
	jp showmenu
showmenu_fire_check4:		; Change music info

;	ld a, (music_state)
;	inc a
;	cp 3
;	jr z, showmenu_fire_music_fx
;	ld (music_state), a
;	ld hl, string_list
;	ld de, 8
;	add hl, de
;	push hl
;	ld e, (hl)	
;	inc hl
;	ld d, (hl)
;	ld hl, 9
;	add hl, de
;	ex de, hl
;	pop hl
;	ld (hl), e
;	jr showmenu_fire_music_common	
;showmenu_fire_music_fx:
;	xor a
;	ld (music_state), a
;	ld hl, string_list
;	ld de, 8
;	add hl, de
;	ld de, string_5_1
;showmenu_fire_music_common:
;	ld (hl), e
;	inc hl
;	ld (hl), d
;	ld bc, 9
;	add hl, bc
;	ld (hl), e
;	inc hl
;	ld (hl), d

	jp showmenu



showmenu_scrolldown:
	ld b, 8
showmenu_scrolldown_loop:
	push bc
	call scrolldown
	pop bc
	djnz showmenu_scrolldown_loop
	; Now put the first line last
	ld a, (menu_option)
	add a, 3
	cp 5
	jr c, showmenu_scrolldown_loop_no5
	sub 5
showmenu_scrolldown_loop_no5:
	add a, a
	ld e, a
	ld d, 0
	ld hl, (current_string_list)
	add hl, de
	ld a, (hl)
	ld iyl, a
	inc hl
	ld a, (hl)
	ld iyh, a
	ld bc, 12*256 + 17
	call print_string3
	jp showmenu_loop

showmenu_scrollup:
	ld b, 8
showmenu_scrollup_loop:
	push bc
	call scrollup
	pop bc
	djnz showmenu_scrollup_loop
	; Now put the first line last
	ld a, (menu_option)
	add a, 2
	cp 5
	jr c, showmenu_scrollup_loop_no5
	sub 5
showmenu_scrollup_loop_no5:
	add a, a
	ld e, a
	ld d, 0
	ld hl, (current_string_list)
	add hl, de
	ld a, (hl)
	ld iyl, a
	inc hl
	ld a, (hl)
	ld iyh, a
	ld bc, 12*256 + 22
	call print_string3
	jp showmenu_loop
;	ret
showmenu_go_attract:
	ld a, 8
	ld (current_level), a
	ret

showmenu_select_language:
	ld a, (language)
	and a
	jr z, showmenu_language_sp
	ld hl, string_list
	ld (current_string_list), hl
	ld hl, redefine_en
	ld (current_redefine_strings), hl
	ret
showmenu_language_sp:
	ld hl, string_list_es
	ld (current_string_list), hl
	ld hl, redefine_es
	ld (current_redefine_strings), hl
	ret


string_enterpassword: db "PASSWORD:",0
string_passwordok: db   "  PASSWORD OK",0
string_passwordfail: db "INVALID PASSWORD",0
string_presskey: db "PRESS ",0
string_left:    db "LEFT ",0
string_right:   db "RIGHT",0
string_up:      db "UP   ",0
string_down:    db "DOWN ",0
string_fire:    db "FIRE ",0
string_select:  db "FIRE2",0
string_presskey_es: db "PULSA ",0
string_left_es:    db "IZQUIERDA",0
string_right_es:   db "DERECHA  ",0
string_up_es:      db "ARRIBA   ",0
string_down_es:    db "ABAJO    ",0
string_fire_es:    db "DISPARO  ",0
string_select_es:  db "DISPARO 2",0;

;current_redefine_strings: dw redefine_es
redefine_es: dw string_presskey_es, string_up_es, string_down_es, string_left_es, string_right_es,  string_fire_es, string_select_es
redefine_en: dw string_presskey, string_up, string_down, string_left, string_right, string_fire, string_select

string_credits: dw string_code, string_art, string_music, string_48k
string_code:	db "  CODE: UTOPIAN ",0
string_art:   	db "ART: PAGANTIPACO",0
string_music:   db " SOUND: MCALBY  ",0
string_48k: 	db "48K MLD: SPIRAX ",0

;menu_loops: db 0

;password_string: db "          ",0
;password_value:  db 0, 0, 0, 0, 0	; current_level	| player_available_weapons, player_level, player_exp, player_current_weapon, cksum

; INPUT:
; 	E: Attribute
credit_setattr:
	ld bc, 8*256+23
	ld a, 16
credit_setattr_loop:
	push af
	push bc
	push de
	call SetAttribute
	pop de
	pop bc
	inc b
	pop af
	dec a
	jr nz, credit_setattr_loop
	ret

credit_fadeout:
	ld a, (23272)
	and a
	ret z		; if the attribute is 0 already, no fade out
	dec a
	ld e, a
	;call credit_setattr
	;ret
	jp credit_setattr

credit_fadein:
	ld a, (23272)
	cp 7 
	ret nc		; if the attribute is >=7 already, no fade in
	inc a
	ld e, a
	;call credit_setattr
	;ret
	jp credit_setattr


; Run a quick checksum of the 4 initial values in password_value
; OUTPUT:
;	- A: checksum

password_checksum:
	xor a
	ld hl, password_value
	ld b, 4
password_checksum_loop
	add a, (hl)
	inc hl
	djnz password_checksum_loop
	ret

; Check if password values are ok
; OUTPUT:
;	- A: 0=OK, 1= NOT OK

;save_level: db 0

weapon_masks: db $80, $40, $20, $10
secret_pass: db '0CAFECAFE0'

menu_password:
	call menu_cleancreditsattr
	ld bc, 8*256+23
	ld iy, string_enterpassword
	call print_string3

	ld hl, password_string
	ld de, password_string+1
	ld a, ' '
	ld (hl), a
	ld bc, 9
	ldir

	ld b, 0	; B is the counter
	ld hl, password_string

readloop:
	push bc
	push hl
	call SCAN_KEYBOARD_CHAR		; read keyboard in A
	pop hl
	pop bc
	cp  13				; 13 is ENTER
	jr z, read_finished

	cp '0'
	jr c, readloop		; ignore chars < 0
	cp 'g'
	jr nc, readloop		; ignore chars > F
	cp '9'+1
	jr c, readloop_number	; this is a number
	cp 'a'
	jr c, readloop		; less than A, not a number
readloop_ok:
	sub 32
readloop_number:

	ld (hl), a			; store the new key press
	ld a, b
	cp 10
	jr z, read_continue		; don't go beyond 10 characters
	
	ld a, FX_SHEATHE
	call FX_Play
	
	inc hl
	ld (hl), 0
	inc b
read_continue:
	push bc
	push hl
	ld bc, 18*256+23
	ld iy, password_string
	call print_string3
	pop hl
	pop bc
	ld a, b
	cp 10
	jr nz, readloop
read_finished:
    ; Check if the player knows the secret level password
    ld a, FX_INVENTORY_SELECT
	call FX_Play
	
	ld hl, password_string
    ld de, secret_pass
    ld b, 10
secret_loop:
    ld a, (de)
    cp (hl)
    jr nz, read_nosecret
    inc hl
    inc de
    djnz secret_loop
secret_found:
    ld a, 253   ; go to secret level
    ret
read_nosecret:
	; convert password string into value
	ld hl, password_string
	call TEXT_TO_HEX
	xor $55		; supersecret value :)
	ld (password_value), a
	call TEXT_TO_HEX
	xor $55		; supersecret value :)
	ld (password_value+1), a
	call TEXT_TO_HEX
	xor $55		; supersecret value :)
	ld (password_value+2), a
	call TEXT_TO_HEX
	xor $55		; supersecret value :)
	ld (password_value+3), a
	call TEXT_TO_HEX
	ld (password_value+4), a	; the checksum is not XOR-ed
	; check if checksum is valid
	call password_checksum
	ld b, a
	ld a, (password_value+4)
	cp b
	jr z, is_password_valid
	
;	jr nz, menu_password_invalid
	; check if resulting values are valid
;	call is_password_valid
;	and a
;	jr nz, menu_password_invalid
;menu_password_valid:
;	xor a
;	ret
menu_password_invalid:
;	ld a, 255
;	ret
	
password_invalid:
	ld a, 255
	ret
		
is_password_valid:
	; save player level
	ld a, (player_level)
	ld (save_level), a
	ld a, (password_value)	; current level
	and $0f			; low nibble is current level
	cp 8
	jr nc, password_invalid	; level cannot be > 7
	ld (player_level), a
	ld a, (password_value)	; high nibble is available_weapons
	and $80			; at least the basic sword must be there
	jr z, password_invalid
	ld a, (password_value+1); player_level
	cp 8
	jr nc, password_invalid	; player level cannot be > 7
	call get_player_max_exp ; get max experience for saved level in A
	ld hl, password_value+2
	cp (hl)			; compare with the experience
	jr c, password_invalid	; if the saved value is > the max experience for this level, fail!
	ld a, (password_value+3); player_current_weapon, it has to be one of the available_weapons
	ld hl, weapon_masks
	ld e, a
	ld d, 0
	add hl, de
	ld b, (hl)		; B contains the mask
	ld a, (password_value)	; high nibble is available_weapons
	and b
	ld a, (save_level)
	ld (player_level), a	; restore value
	jr z, password_invalid	; the weapon is not available, so the password is not valid
	xor a
	ret


; Convert text into hex value
; INPUT:
;	- HL: pointer to char
; OUTPUT:
;	- A: value 

TEXT_TO_HEX:
     	ld e, 0
     	call TH_CONV

	rla
	rla
	rla
	rla		;Set it in bits 7-4
	ld e,a	;Store first digit in E

TH_CONV:
	ld a,(hl)
	inc hl
	sub 48
	cp 10
	jr c,noletter
	sub 7
noletter:
	or e
	ret

; Convert HEX value into text
; Input: 
;	- A: value to convert
;	- DE: where to put the value, gets incremented

HEX_TO_TEXT:
     ld c,a
     rra
     rra
     rra
     rra
     call HT_CONV
     ld	a,c
HT_CONV:
     and 15
     add a,48
     cp 58
     jr c,noletter2
     add a,7
noletter2:
     ld (de), a
     inc de
     ret

;HEX_NUMBERS:
;     defb '0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'

; We cannot select any of the following keys, because they are reserved
;forbidden_keys: dw KEY_H, 0, 0, 0, 0, 0, 0
;n_forbidden_keys: dw 1 	; 1 key (for now)
; Input: DE: key
; Output: - carry flag set: invalid, not set: valid
is_valid_key:
	ld hl, forbidden_keys
	ld a, (n_forbidden_keys)
	ld b, a	
is_valid_key_loop:
	ld a, (hl)
	inc hl
	cp e
	jr nz, is_valid_key_loop_cont
	ld a, (hl)
	cp d
	jr nz, is_valid_key_loop_cont
	; Same key, so not valid
	scf
	ret
is_valid_key_loop_cont:
	inc hl
	djnz is_valid_key_loop
	xor a	; reset carry flag
	ret

redefine_keys:
	call menu_cleancreditsattr   
	ld a, 1
	ld (n_forbidden_keys), a
	ld bc, 8*256 + 23
	ld ix, (current_redefine_strings)
	ld a, (ix+0)
	ld iyl, a
	ld a, (ix+1)
	ld iyh, a
	call print_string3
	; Up
redefine_up:
	ld ix, (current_redefine_strings)
	ld a, (ix+2)
	ld iyl, a
	ld a, (ix+3)
	ld iyh, a
	ld bc, 14*256+23
	call print_string3
	call SCAN_KEYBOARD
	push af
	ld a, FX_SHEATHE
	call FX_Play
	pop af
	call is_valid_key
	jr c, redefine_up
	ld (key_defs), de
	ld (forbidden_keys+2), de
	ld a, 2
	ld (n_forbidden_keys), a
	; Down
redefine_down:
	ld ix, (current_redefine_strings)
	ld a, (ix+4)
	ld iyl, a
	ld a, (ix+5)
	ld iyh, a
	ld bc, 14*256+23
	call print_string3
	call SCAN_KEYBOARD
	push af
	ld a, FX_SHEATHE
	call FX_Play
	pop af
	call is_valid_key
	jr c, redefine_down
	ld (key_defs+2), de
	ld (forbidden_keys+4), de
	ld a, 3
	ld (n_forbidden_keys), a
	; Left
redefine_left:
	ld ix, (current_redefine_strings)
	ld a, (ix+6)
	ld iyl, a
	ld a, (ix+7)
	ld iyh, a
	ld bc, 14*256+23
	call print_string3
	call SCAN_KEYBOARD
	push af
	ld a, FX_SHEATHE
	call FX_Play
	pop af
	call is_valid_key
	jr c, redefine_left
	ld (key_defs+4), de
	ld (forbidden_keys+6), de
	ld a, 4
	ld (n_forbidden_keys), a
	; Right
redefine_right:
	ld ix, (current_redefine_strings)
	ld a, (ix+8)
	ld iyl, a
	ld a, (ix+9)
	ld iyh, a
	ld bc, 14*256+23
	call print_string3
	call SCAN_KEYBOARD
	push af
	ld a, FX_SHEATHE
	call FX_Play
	pop af
	call is_valid_key
	jr c, redefine_right
	ld (key_defs+6), de
	ld (forbidden_keys+8), de
	ld a, 5
	ld (n_forbidden_keys), a
	; Fire
redefine_fire:
	ld ix, (current_redefine_strings)
	ld a, (ix+10)
	ld iyl, a
	ld a, (ix+11)
	ld iyh, a
	ld bc, 14*256+23
	call print_string3
	call SCAN_KEYBOARD
	push af
	ld a, FX_SHEATHE
	call FX_Play
	pop af
	call is_valid_key
	jr c, redefine_fire
	ld (key_defs+8), de
	ld (forbidden_keys+10), de
	ld a, 6
	ld (n_forbidden_keys), a
	; Select
redefine_select:
	ld ix, (current_redefine_strings)
	ld a, (ix+12)
	ld iyl, a
	ld a, (ix+13)
	ld iyh, a
	ld bc, 14*256+23
	call print_string3
	call SCAN_KEYBOARD
	push af
	ld a, FX_SHEATHE
	call FX_Play
	pop af
	call is_valid_key
	jr c, redefine_select
	ld (key_defs+10), de
	ld (forbidden_keys+12), de
	ld a, 7
	ld (n_forbidden_keys), a
	ret


DECODE_SECRETLEVEL:
    ld a, 2
    ld (player_level), a
    ld a, 9
	ld (current_level), a
	ld iy, player_available_weapons
	ld (iy+0), 1
	ld (iy+1), 1
	ld (iy+2), 1
	ld (iy+3), 1	; all weapons are available
	xor a
	ld (player_experience), a
	ld (player_current_weapon), a    
    ret

; Print a string on screen, not controlling line breaks
; INPUT:
;	IY: pointer to string
;	B: X in chars
;	C: Y in chars
print_string3:
	ld a, (iy+0)
	and a
	ret z		; return on NULL
	push iy
	push bc
	call print_char
	pop bc
;	push bc
;	pop bc
	pop iy
	inc iy
	inc b
	jr nz, print_string3
	ret	

; Print a string on screen, not controlling line breaks, double size
; INPUT:
;	IY: pointer to string
;	B: X in chars
;	C: Y in chars
print_string_double:
	ld a, (iy+0)
	and a
	ret z		; return on NULL
	push iy
	push bc
	call print_char_double
	pop bc
;	push bc
;	pop bc
	pop iy
	inc iy
	inc b
	jr nz, print_string_double
	ret	

; Print a character on screen
; INPUT:
;	- A: char
;	- B: X in chars
;	- C: Y in chars

print_char_double:
	sub 32		; first char is number 32
	
	ld e, a
	ld d, 0
	rl e
	rl d
	rl e
	rl d
	rl e
	rl d		; Char*8, to get to the first byte
	ld hl, FONT
	add hl, de	; HL points to the first byte
	ex de, hl	; DE points to the first byte

print_char_double_go:
;	ld a, (rombank)		;Sistem var with the previous value
;	and $07			;Preserve the low bits
;	push af
;	push bc
;	call setrambank6		; Set RAM Bank 6 for FONT
;	pop bc

	ld hl, TileScAddress	; address table
	ld a, c
	add a,c			; C = 2*Y, to address the table
	ld c,a
	ld a, b			; A = X
	ld b,0			; Clear B for the addition
	add hl, bc		; hl = address of the first tile
	ld c, (hl)
	inc hl
	ld b, (hl)		; BC = Address
	ld l,a			; hl = X
	ld h, 0
	add hl, bc		; hl = tile address in video memory

	push hl
	ld b, 4
print_char_double_loop_1:
	ld a, (de)
	ld (hl), a
	inc h
	ld (hl), a
	inc h
	inc e			; FIXME! will be able to do INC E, when FONTS is aligned in memory
	djnz print_char_double_loop_1
	pop hl
	ld bc, 32
	add hl, bc
	ld b, 4
print_char_double_loop_2:
	ld a, (de)
	ld (hl), a
	inc h
	ld (hl), a
	inc h
	inc e			; FIXME! will be able to do INC E, when FONTS is aligned in memory
	djnz print_char_double_loop_2

;	pop af
;	di
;	ld b, a
;	call setrambank		; set previous rom bank
;	ei
	ret



; Read joysticks, set carry if fire is pressed
check_firepress:
		halt
read_sinc1_joystick:
       	ld bc, $effe
       	in c, (c)  		; Leemos solo la fila 6-0. Los bits a 0 están pulsados
       	xor a
sinc1_fire:
       	rr c
       	jr c,read_sinc2_joystick
       	; Sinclair 1 fire detected
       	ld a, JOY_SINCLAIR1
		ld (selected_joystick),a
		scf 
		ret
read_sinc2_joystick:
	    ld bc, $f7fe
      	in c, (c)  ; Leemos solo la fila 1-5. Los bits a 0 están pulsados
       	ld a,c
		and $10
		jr nz, read_keyb
       	; Sinclair 2 fire detected
       	ld a, JOY_SINCLAIR2
		ld (selected_joystick),a
		scf 
		ret
read_keyb:
		ld bc, (key_defs+8)	; ready to read!
		call GET_KEY_STATE
;		and a
		jr nz, read_kemps
		; Keyboard fire detected
	    ld a, JOY_KEYS
		ld (selected_joystick),a
		scf 
		ret
read_kemps:
		ld c, 31
		in c, (c)		
		ld a, 255
		cp c
		jr z, no_fire	; if the value read is 255, then there is no kempston interface
	    ld a,c
		and $10
		jr z, no_fire
	    ; Kempston fire detected
	    ld a, JOY_KEMPSTON
		ld (selected_joystick),a
		scf 
		ret
no_fire:
		xor a	; clear carry
		ret


; Read all joysticks, return the aggregated value in A
; Returns:  
;		A: joystick state
; Bit #:  76     5    	  4   3210
;         ||     |    	  |   ||||
;         XX CAPS SHIFT  BUT1 RLDU
;joystick_status: db 0

read_joysticks:
	call read_kempston_joystick
	ld b, a
	push bc
	call read_sinclair1_joystick
	pop bc
	or b
	ld b, a
	push bc
	call read_sinclair2_joystick
	pop bc
	or b
	ld b, a
	push bc
	ld hl, key_defs
	call read_redefined
	pop bc
	or b
	ld (joystick_status), a
	ret


; Scan the keyboard to find a single keypress
; Input: n/a
; Output: key scan code, in DE

KeyCodes:
   defw KEY_CAPS,  KEY_Z,  KEY_X, KEY_C, KEY_V
   defw KEY_A,     KEY_S,  KEY_D, KEY_F, KEY_G
   defw KEY_Q,     KEY_W,  KEY_E, KEY_R, KEY_T
   defw KEY_1,     KEY_2,  KEY_3, KEY_4, KEY_5
   defw KEY_0,     KEY_9,  KEY_8, KEY_7, KEY_6
   defw KEY_P,     KEY_O,  KEY_I, KEY_U, KEY_Y
   defw KEY_ENTER, KEY_L,  KEY_K, KEY_J, KEY_H
   defw KEY_SPACE, KEY_SS, KEY_M, KEY_N, KEY_B

SCAN_KEYBOARD:
	LD BC, $FEFE	; This is the first row, we will later scan all of them
	LD HL,KeyCodes  ; Let's go to the KeyCode table
	LD A,8		; loop counter
	
scan_loop:
	IN E, (C)	; Read the row status
	LD D, 5		; We just need to do it 5 times per scan line
find_keypress:
	RR E
	JR NC, keyfound	; we found a pressed key!
	INC HL
	INC HL		; if not, go to the next scan code
	DEC D
	JR NZ, find_keypress ; try next key
	RLC B
	DEC A
	JR NZ, scan_loop	; back to the scan loop. This will repeat forever until a key press is found					
	JR SCAN_KEYBOARD	; if not, restart again		
keyfound:
	LD E,(HL)	; This is the scan code. We are not going back to the main loop, so we can reuse A
	INC HL
	LD D, (HL)
	PUSH DE
waitforrelease:
   	XOR A
    IN A, (C)  
   	CPL 
   	AND $1F
   	JR NZ, waitforrelease ; some key in this row is still pressed                   
   	POP DE
	RET   

; Scan the keyboard to find a single keypress
; Return the char
; Input: n/a
; Output: char, in A
KeyCodes_char:
   defb 255,'z','x','c','v'      ; CAPS SHIFT, Z, X, C, V
   defb 'a','s','d','f','g'      ; A, S, D, F, G
   defb 'q','w','e','r','t'      ; Q, W, E, R, T
   defb '1','2','3','4','5'      ; 1, 2, 3, 4, 5
   defb '0','9','8','7','6'      ; 0, 9, 8, 7, 6
   defb 'p','o','i','u','y'      ; P, O, I, U, Y
   defb 13,'l','k','j','h'       ; ENTER, L, K, J, H
   defb ' ',254,'m','n','b'      ; SPACE, SYM SHIFT, M, N, B


SCAN_KEYBOARD_CHAR:
	LD BC, $FEFE	; This is the first row, we will later scan all of them
	LD HL,KeyCodes_char  ; Let's go to the KeyCode table
	LD A,8		; loop counter
	
scan_loop_char:
	IN E, (C)	; Read the row status
	LD D, 5		; We just need to do it 5 times per scan line
find_keypress_char:
	RR E
	JR NC, keyfound_char	; we found a pressed key!	
	INC HL		; if not, go to the next scan code
	DEC D
	JR NZ, find_keypress_char ; try next key
	RLC B
	DEC A
	JR NZ, scan_loop_char	; back to the scan loop. This will repeat forever until a key press is found					
	JR SCAN_KEYBOARD_CHAR	; if not, restart again		
keyfound_char:
	LD A,(HL)	; This is the scan code. We are not going back to the main loop, so we can reuse A
	PUSH AF
waitforrelease_char:
   	XOR A
    IN A, (C)  
   	CPL 
   	AND $1F
   	JR NZ, waitforrelease_char ; some key in this row is still pressed                   
   	POP AF
	RET   

;menu_running: db 0
;menu_counter: db 0

menu_isr:
	; check joystick state
	call read_joysticks
	; play music, if needed
	
	;ld a, (music_playing)
	;and a
	;jr z, menu_isr_wave		; if not playing music, do nothing
	;call MUSIC_Play
menu_isr_wave:
	; simply get the joystick state
	ld a, (menu_running)
	and a
	ret z
	ld a, (menu_counter)
	inc a
	and $7
	ld (menu_counter), a
	cp 2
	jp z, waveeffect
	cp 6
	jp z, waveeffect_part2
    cp 7 
    jp z, wave_cycleattr
	ret


wave_move_right_1:
	; this is: rotate right 1 pixel
	; HL already points to the first line
	xor a
	ld b, 32
waveeffect_minus1_loop:
	ld a, (hl)
	rra
	ld (hl), a
	inc hl
	djnz waveeffect_minus1_loop	
	ret

wave_move_left_1:
	; this is: rotate left 1 pixel
	; HL already points to the first line
	ld bc, 31
	add hl, bc
	xor a
	ld b, 32
waveeffect_plus1_loop:
	ld a, (hl)
	rla
	ld (hl), a
	dec hl
	djnz waveeffect_plus1_loop
	ret


wave_delta: db 2, 2, 1, 1, -1, -1, -2, -2, -2, -2, -1, -1, 1, 1, 2, 2

  ; -------------------------------
  ; PACO: Variable para controlar los ciclos que se salta el efecto de atributos  
  ; -------------------------------
;attribute_cycle: db 2
  ; -------------------------------
  ; FIN PACO  
  ; -------------------------------

;start_delta: db 0
;current_delta: db 0
;current_y: db 0
; wave from line 80 to 119
waveeffect:
	ld a, (start_delta)
	ld (current_delta), a
	ld bc, $0050	; X=0, Y=80
	jr waveeffect_start
waveeffect_part2:
	ld bc, $0064	; X=0, Y=100
waveeffect_start:
	ld a, 20
	ld (current_y), a
waveeffect_yloop:
	push bc
	call calcscreenpos	; HL points to the first byte to shift
	push hl
	ld a, (current_delta)			; A will serve as counter for Y
	ld e, a
	ld d, 0
	ld hl, wave_delta
	add hl, de	
	ld a, (hl)
	pop hl
	cp 1
	jr z, waveeffect_plus1
	cp 2
	jr z, waveeffect_plus2
	cp -1
	jr nz, waveeffect_minus2
waveeffect_minus1:
	call wave_move_right_1
	jr waveeffect_nextline
waveeffect_plus1:
	call wave_move_left_1
	jr waveeffect_nextline
waveeffect_plus2:
	push hl
	call wave_move_left_1
	pop hl
	call wave_move_left_1
	jr waveeffect_nextline
waveeffect_minus2:
	push hl
	call wave_move_right_1
	pop hl
	call wave_move_right_1
waveeffect_nextline:
	; go to next line
	pop bc
	inc c
	; increment wave counter
	ld a, (current_delta)
	inc a
	and $f
	ld (current_delta), a
	ld a, (current_y)
	dec a
	jr z, waveeffect_end
	ld (current_y), a
	jp waveeffect_yloop
waveeffect_end:
	ld a, (start_delta)
	inc a
	and $f
	ld (start_delta), a
    ret
wave_cycleattr:
	; Now, cycle the attributes
  ; -------------------------------
  ; PACO: Saltar el ciclo de atributos cada "attribute_cycle" ciclos  
  ; -------------------------------
  ld a, (attribute_cycle)
  dec a
  jr z, wave_cycleattr_continue
  ld (attribute_cycle), a
  jr wave_cycleattr_exit 
  
wave_cycleattr_continue:
  ld a, 3
  ld (attribute_cycle), a
  ; -------------------------------
  ; FIN PACO  
  ; -------------------------------
  
	ld hl, 16384+6144+320+4*32+31
	ld de, 16384+6144+320+5*32+31
	ld b, 5*32
wave_cycleattr_loop1:
	ld a, (hl)
	ld (de), a
	dec de
	dec hl
	djnz wave_cycleattr_loop1
	ld hl, 16384+6144+320+32*5
	ld de, 16384+6144+320
	ld b, 32
wave_cycleattr_loop2:
	ld a, (hl)
	ld (de), a
	inc de
	inc hl
	djnz wave_cycleattr_loop2

  ; -------------------------------
  ; PACO: Etiqueta para ir al final del efecto  
  ; -------------------------------
wave_cycleattr_exit:
  ; -------------------------------
  ; FIN PACO  
  ; -------------------------------
  ret


cambianivel:						
	push de
	ld a, $F7
  	in A, ($FE)						; leemos fila 1-2-3-4-5
	bit 0, A                		; Leemos la tecla 1
	jr nz, no1						
	ld a, 1
	jr nuevonivel
no1:
	bit 1, A                		; Leemos la tecla 2
	jr nz, no2						
	ld a, 2
	jr nuevonivel
no2:
	bit 2, A                		; Leemos la tecla 3
	jr nz, no3						
	ld a, 3
	jr nuevonivel
no3:
	bit 3, A                		; Leemos la tecla 4
	jr nz, no4
	ld a, 4
	jr nuevonivel
no4:
	bit 4, A                		; Leemos la tecla 5
	jr nz, no5						
	ld a, 5
	jr nuevonivel
no5:
	ld a, $EF
  	in A, ($FE)						; leemos fila 0-9-8-7-6
	bit 0, A                		; Leemos la tecla 0
	jr nz, no0						

	ld a, 0
	jr nuevonivel
no0:
	bit 1, A                		; Leemos la tecla 9
	jr nz, no9						
	ld a, 9
	jr nuevonivel
no9:
	bit 2, A                		; Leemos la tecla 8
	jr nz, no8						
	ld a, 8
	jr nuevonivel
no8:
	bit 3, A                		; Leemos la tecla 7
	jr nz, no7
	ld a, 7
	jr nuevonivel
no7:
	bit 4, A                		; Leemos la tecla 6
	jr nz, endcambianivel
	ld a, 6
nuevonivel:
	ld (current_level),a
	xor a
	ld (show_passwd), a
	ld a, 15
	ld (player_experience), a 
	ld a,1
	ld de,player_available_weapons
	ld (de),a
	inc de
	ld (de),a
	inc de
	ld (de),a
	inc de
	ld (de),a
    
	ld (intro_shown), a

	ld a, 7
	ld (player_level), a

endcambianivel
	xor a
	out (254),a
	pop de
	ret


menu_screen: incbin "menu_screen.cmp"

intro_final:
INCLUDE "intro48k.asm"
