; Code to manage the score area
SCOREAREA: EQU $C000
WEAPON_SPRITES: EQU $C480

; load the score area in screen
load_scorearea:
	call setrambank6
	ld e, 0		; e is the counter
	ld c, 20	; C is the Y tile
loadsc_y_loop:
	ld b, 0		; B is the X tile
loadsc_x_loop:
	push de
	call CopyTile_score
	pop de
	inc b
	inc e
	ld a, b
	cp 32
	jr nz, loadsc_x_loop
	inc c
	ld a, c
	cp 24
	jr nz, loadsc_y_loop	
loadsc_end:
	call setrambank0_with_di

	; draw score status
	call draw_score_status

	; And copy the actual tiles
	call switchscreen_setrambank7

	ld c, 20	; C is the Y tile
loadsc_y_loop_2:
	ld b, 0		; B is the X tile
loadsc_x_loop_2:
	push bc
	call CopyTile
	pop bc
	inc b
	ld a, b
	cp 32
	jr nz, loadsc_x_loop_2
	inc c
	ld a, c
	cp 24
	jr nz, loadsc_y_loop_2
	call switchscreen_setrambank0
	ret

; Copy tile from score area into screen
;
; INPUT:
;	B: x tile
;	C: y tile
;	E: tile number (0-127)

CopyTile_score:
	push bc
	ld a, e
	push af
	push bc
			
	ld hl, SCOREAREA	
	ld e, a				; A*8 is the beginning of the tile
	ld d, 0
	xor a
	rl e
	rl d	
	rl e
	rl d
	rl e
	rl d			
	add hl, de		;
	ex de, hl		; DE points to the tile
	
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

	ld a, (de)
	ld (hl), a
	inc e			; can do INC E, since the tiles are aligned in memory
	inc h
	ld a, (de)
	ld (hl), a
	inc e
	inc h
	ld a, (de)
	ld (hl), a
	inc e
	inc h
	ld a, (de)
	ld (hl), a
	inc e
	inc h
	ld a, (de)
	ld (hl), a
	inc e
	inc h
	ld a, (de)
	ld (hl), a
	inc e
	inc h
	ld a, (de)
	ld (hl), a
	inc e
	inc h
	ld a, (de)
	ld (hl), a	; 8 bytes, go!
	
	; now look after the attribute
	
	pop bc		; get X and Y back
	pop af
	ld hl, SCOREAREA + 1024 ; this is where the attributes are
	ld e, a
	ld d, 0
	add hl, de
	ld a, (hl)	; A has the attribute	
	ex af, af'

	; BC = Y*32+X, to address the memory array
	ld a, c										; 4
	rrca
	rrca
	rrca			; XXXYYYYY						; 12
	ld c, a										; 4
	and $E0										; 7
	or b										; 4
	ld b, a										; 4
	ld a, c										; 4
	and $1f										; 7
	ld c, b										; 4
	ld b, a										; 4. 54 rather than 103

	ld hl, 16384+6144	; attribute area in screen
	add hl, bc		; so HL points to the byte in the attribute area...
	ex af, af'		; get the attribute back
	ld (hl), a		; and the attribute is stored!
	pop bc
	ret



; Clean score area, just leaving the outer frame
clean_scorearea:
	call setrambank6
	ld c, 21	; C is the Y tile
cleansc_y_loop:
	ld b, 1		; B is the X tile
cleansc_x_loop:
	ld e, 34
	call CopyTile_score

	inc b
	ld a, b
	cp 31
	jr nz, cleansc_x_loop
	inc c
	ld a, c
	cp 24
	jr nz, cleansc_y_loop	
cleansc_end:
	call setrambank0_with_di
	; And copy the actual tiles
	di 
	call switchscreen	; Now show shadow screen, where everything is ok
	call setrambank7		; and place RAM bank 7
	ei

	ld c, 21	; C is the Y tile
cleansc_y_loop_2:
	ld b, 1		; B is the X tile
cleansc_x_loop_2:
	push bc
	call CopyTile
	pop bc
	inc b
	ld a, b
	cp 31
	jr nz, cleansc_x_loop_2
	inc c
	ld a, c
	cp 24
	jr nz, cleansc_y_loop_2

	di
	call switchscreen	; Show main screen (from bank 7)
	call setrambank0	; and set RAM bank 0
	ei
	ret

; Draw the barbarian inventory
draw_score_inventory:
	ld a, 3
	ld (currentx), a
	; if (current_object > first_object + 2) first_object++
	ld a, (inv_first_obj)
	add a, 3
	ld b, a
	ld a, (inv_current_object)
	cp b	
	jr c, draw_inv_noincfirst
	ld a, (inv_first_obj)
	inc a
	ld (inv_first_obj), a
	jr draw_inv_draw
draw_inv_noincfirst:
	; else if current_object < first_object first_object --
	ld a, (inv_first_obj)
	ld b, a
	ld a, (inv_current_object)
	cp b
	jr nc, draw_inv_draw
	ld a, (inv_first_obj)
	dec a
	ld (inv_first_obj), a
draw_inv_draw:
	ld a, (inv_first_obj)
draw_inv_draw_loop:
	push af
	cp 6
	jr nc, draw_inv_draw_loop_blank
	ld hl, inventory
	ld e, a
	ld d, 0
	add hl, de
	ld a, (hl)	; A has the object
	and a
	jr z, draw_inv_ready
	sub OBJECT_KEY_GREEN ; make it base 0
	ld e, a
	ld d, 0
	; get the stile
	ld hl, tiles_per_pickable_object
	add hl, de
	ld a, (hl)	; A has the tile for the object
draw_inv_ready:
	push af
	ld a, (currentx)
	ld b, a
	ld c, 21
	pop af
	jr draw_inv_go
draw_inv_draw_loop_blank:
	ld a, (currentx)
	ld b, a
	ld c, 21
	xor a
draw_inv_go:
	; This is a slightly unoptimized way of doing this, but...
	ld e, 0
	call DrawStile_tile
	ld e, 1
	inc b
	call DrawStile_tile
	ld e, 3
	inc c
	call DrawStile_tile
	ld e, 2
	dec b
	call DrawStile_tile
draw_inv_continueloop:
	ld a, (currentx)
	add a, 3
	cp 12	
	jr nc, draw_inv_marker	; already drew 3 objects 
	ld (currentx), a ; move 3 chars right in the inventory
	pop af
	inc a		; next item in inventory
	jr draw_inv_draw_loop
draw_inv_marker:
	; cleanup the markers
	ld a, ' '
	ld bc, 3*256 + 23
	call print_char
	ld a, ' '
	ld bc, 6*256 + 23
	call print_char
	ld a, ' '
	ld bc, 9*256 + 23
	call print_char
	; now print it
	pop af
	ld a, (inv_first_obj)
	ld b, a
	ld a, (inv_current_object)
	sub b		; 
	ld b, a
	add a, a
	add a, b	; (current_obj - first_obj) * 3
	add a, 3	; 3 + (current_obj - first_obj) * 3
	ld b, a
	ld c, 23
	ld e, 7
	;push bc
	call SetAttribute
	;pop bc
	ld a, 95
	call print_char
	xor a
	ld (inv_refresh), a
	; And set the area to be redrawn
	ld bc, 2*256 + 21
	ld de, 10*256 + 3
	jp InvalidateTiles
	;call InvalidateTiles
	;ret


; print a meter
; INPUT:
;   - B: Value (0..255)
;   - C: X
;   - Color (?)
draw_blank: db 0

draw_meter:
	ld e, b
	ld d, 12
	call Div8	; Value / 12 is in the range 0..21, result in A is the number of lines to draw
	ld b, 189
	push af
	ld d, a
	ld a, 21
	sub d
	ld (draw_blank), a
	pop af
	and a
	jr z, draw_meter_loop_done
	ld e, 93
draw_meter_loop:
	call draw_line

	dec b
	dec a
	jr nz, draw_meter_loop
draw_meter_loop_done:
	ld a, (draw_blank)
	and a
	ret z
	ld e, 65
draw_meter_loop_2:
	call draw_line
	dec b
	dec a
	ret z
	jr draw_meter_loop_2


; draw a single meter line
; INPUT:
;	- C: X
;	- B: Y
;	- E: value (65 or 93)

draw_line:
	push af
	push bc	

	ld a, b			; 4
	and $07			; 7  <-the 3 lowest bits are the line within a char
	ld h,a			; 4
	ld a,b			; 4  <- the top 2 bits are the screen third
	rra			; 4
	rra			; 4
	rra			; 4
	and $18			; 7
	or h			; 4
	or $40			; 4	<- If the start address is 16384, this should be $40
	ld h,a			; 4 (total 50 t-states) H has the high byte of the address 
	
	ld a,c			;4
	rra			;4
	rra			;4
	rra			;4
	and $1f			;7  <- the top 5 bits are the char pos. The low 3 bits are the pixel pos
	ld l,a			;4
	ld a,b			;4
	rla			;4
	rla			;4
	and $e0			;7
	or l			;4
	ld l,a			;4 (total 54 t-states) L has the low byte of the address
	ld (hl), e
	pop bc
	pop af
	ret


; Draw enemy energy
; INPUT:
;	- IX: entity
;	- A: X (in char numbers)
draw_char: db 0

draw_enemy_state:
	ld (draw_char), a 
	ld a, (ix+0)
	or (ix+1)
	jp z, draw_enemy_noenemy
	ld a, (ix+4)
	and a
	jp z, draw_enemy_noenemy
    ld a, (ix+10)   
	and $f0
	cp OBJECT_ENEMY_ROCK*16-OBJECT_ENEMY_SKELETON*16  ; Is this a rock?
    jp z, draw_enemy_noenemy
	cp OBJECT_ENEMY_SECONDARY*16-OBJECT_ENEMY_SKELETON*16 ; Is it a secondary object?
    jp z, draw_enemy_noenemy
	; change the attributes
	ld a, (draw_char)
	ld b, a
	ld c, 21
	ld e, 2
	call SetAttribute
	inc c
	call SetAttribute
	inc c
	call SetAttribute
	inc b
	dec c
	dec c
	inc e
	call SetAttribute
	inc b
	dec e
	call SetAttribute
	dec b
	inc c
	ld e, 5
	call SetAttribute
	inc b
	call SetAttribute
	dec b
	inc c
	call SetAttribute
	inc b
	call SetAttribute
	call get_entity_max_energy_ix 	; so A is the maximum energy
	ld c, (ix+4)		; and C is the current energy. C*256/A would be the one to use
	ld h, c
	ld l, 0
	dec hl
	ld c, a
	call Div16_8		; result in HL, we will only take L
	ld b, l
	ld a, (draw_char)
	rlca
	rlca
	rlca
	ld c, a
	call draw_meter
	ld e, (ix+4)
	ld d, 10
	call Div8		; A is the enemy energy / 10, D is the remainder
	push de
	push af
	ld a, (draw_char)
	inc a
	ld b, a
	ld c, 22
	pop af
	add a, '0'
	call print_char
	pop de
	ld a, (draw_char)
	add a, 2
	ld b, a
	ld c, 22
	ld a, d
	add a, '0'
	call print_char
	ld a, (ix+10)
	and $0f		; the level is in the low nibble
	ld d, a
	ld a, (draw_char)
	add a, 2
	ld b, a
	ld c, 23
	ld a, d
	add a, '1'
	call print_char
	jr draw_enemy_invalidate
draw_enemy_noenemy:
	; change the attributes
	ld a, (draw_char)
	ld b, a
	ld c, 21
	ld e, 1
	call SetAttribute
	inc c
	call SetAttribute
	inc c
	call SetAttribute
	inc b
	ld c, 21
	call SetAttribute
	inc b
	call SetAttribute
	dec b
	inc c
	call SetAttribute
	inc b
	call SetAttribute
	dec b
	inc c
	call SetAttribute
	inc b
	call SetAttribute
	ld b, 0
	ld a, (draw_char)
	rlca
	rlca
	rlca
	ld c, a
	call draw_meter
	ld a, (draw_char)
	inc a
	ld b, a
	ld c, 22
	ld a, '0'
	call print_char
	ld a, (draw_char)
	add a, 2
	ld b, a
	ld c, 22
	ld a, '0'
	call print_char
	ld a, (draw_char)
	add a, 2
	ld b, a
	ld c, 23
	ld a, '0'
	call print_char
draw_enemy_invalidate:
	; And set the area to be redrawn
	ld a, (draw_char)
	ld b, a
	ld c, 21
	ld de, 3*256 + 3
	jp InvalidateTiles
;	call InvalidateTiles
;	ret

draw_barbarian_state:
	; Print barbarian energy
	ld ix, ENTITY_PLAYER_POINTER
	ld c, (ix+4)		; and C is the current energy. C*256/A would be the one to use
	ld a, c
	and a
	jr nz, draw_barbarian_state_energynot0
	ld b, a
	jr draw_barbarian_state_energy
draw_barbarian_state_energynot0:
	ld h, c
	ld l, 0
	dec hl
	call get_entity_max_energy_ix
	ld c, a
	call Div16_8		; result in HL, we will only take L
	ld b, l
draw_barbarian_state_energy:
	ld c, 168
	call draw_meter
	; Print barbarian experience for current level
	ld a, (player_experience)
	and a
	jr nz, draw_barbarian_state_expnot0
	ld b, a
	jr draw_barbarian_state_exp
draw_barbarian_state_expnot0:
	ld c, a
   	call get_player_max_exp ; H*256/A would be the one to use
        ld h, c
        ld l, 0
        dec hl
        ld c, a
	call Div16_8		; result in HL, we will only take L
	ld b, l
draw_barbarian_state_exp:
	ld c, 176
	call draw_meter
	; Print barbarian level 
	ld bc, 20*256 + 23
	ld a, (player_level)
	add a, '1'
	call print_char
	; And set the area to be redrawn
	ld bc, 20*256 + 21
	ld de, 3*256 + 3
	jp InvalidateTiles
;	call InvalidateTiles
;	ret

; Draw the currently used weapon
draw_weapon:
	call setrambank6
	ld a, (player_current_weapon)
	add a, a			; a*2 to index the table
	ld e, a
	ld d, 0
	ld hl, WEAPON_SPRITES
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)			; DE points to the weapon sprite
	ld bc, 14*256 + 21
draw_weapon_loop_char:	
	push bc
	push de
	call print_char_go
	pop de
	pop bc
	ld hl, 8
	add hl, de
	ex de, hl			; DE points to the next char
	inc b
	ld a, b
	cp 17
	jr nz, draw_weapon_loop_char
	ld b, 14
	; next y
	inc c
	ld a, c
	cp 23
	jr nz, draw_weapon_loop_char
draw_weapon_attributes:
	ld a, (player_current_weapon)
	add a, a			; a*2 to index the table
	ld e, a
	ld d, 0
	ld hl, WEAPON_SPRITES
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ld hl, 48
	add hl, de			; go to the start of the attribute area
	ld bc, 14*256 + 21
draw_weapon_loop_attr:
	ld a, (hl)
	push hl
	push bc
	ld e, a
	call SetAttribute
	pop bc
	pop hl
	inc hl
	inc b
	ld a, b
	cp 17
	jr nz, draw_weapon_loop_attr
	ld b, 14
	; next y
	inc c
	ld a, c
	cp 23
	jr nz, draw_weapon_loop_attr
	; set the area to be invalidated
	ld bc, 14*256 + 21
	ld de, 3*256 + 2
	call InvalidateTiles
	jp setrambank0_with_di
;	ret	
	
 

; Draw the score status
draw_score_status:
	; Print barbarian status
	call draw_barbarian_state
	; Print current weapon
	call draw_weapon
	; Print enemy 1 energy (in meter and number), print enemy 1 level	
	ld ix, ENTITY_ENEMY1_POINTER
	ld a, 24
	call draw_enemy_state
	; Print enemy 2 energy (in meter and number), print enemy 2 level	
	ld ix, ENTITY_ENEMY2_POINTER
	ld a, 27
	call draw_enemy_state
	; Print inventory
	jp draw_score_inventory
;	call draw_score_inventory
;	ret

; Force an inventory redraw
force_inv_redraw:
	ld a, 1
	ld (inv_refresh), a
	ld (frames_noredraw), a		; trick to force a redraw
	call waitforVBlank
	jp RedrawScreen
;	call RedrawScreen
;	ret

; Draw password for level
score_password_string: db "PASSWORD:1234567890",0
score_gameover_string_en: db "    PRESS FIRE",0
score_gameover_string:    db "   PULSA DISPARO",0
score_password_value: db 0,0,0,0,0

HEX_TO_TEXT_p6  EQU $DC66
ENCODE_p6	EQU $DC69

draw_gameover_string:
	ld a, (language)
	and a
	jr z, draw_gameover_spanish
    ld iy, score_gameover_string_en
	jr draw_password_common
draw_gameover_spanish:
    ld iy, score_gameover_string
draw_gameover_common:
	jr draw_password_common

draw_password:
	call setrambank6
	call ENCODE_p6
	ld de, score_password_string+9
	ld a, (score_password_value)
	call HEX_TO_TEXT_p6
	ld a, (score_password_value+1)
	call HEX_TO_TEXT_p6
	ld a, (score_password_value+2)
	call HEX_TO_TEXT_p6
	ld a, (score_password_value+3)
	call HEX_TO_TEXT_p6
	ld a, (score_password_value+4)
	call HEX_TO_TEXT_p6
	call setrambank0_with_di

	ld iy, score_password_string
draw_password_common:
	ld a, 1
	ld (score_semaphore), a	; the score area is now my precious!!!
	call clean_scorearea
	ld bc, 6*256+22		; Go print string
	call print_string2
	call wait_till_read
	call load_scorearea
	xor a
	ld (score_semaphore), a	; now you can do whatever you want with the score area
	ld a, 2
	ret
