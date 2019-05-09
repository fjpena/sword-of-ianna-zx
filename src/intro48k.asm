;intro_var: db 0
;number_screens: db 0
;menu_string_list: dw 0
;menu_screen_list: dw 0
;menu_attr_list: dw 0
;menu_cls_loop: db 0

load_buffer: EQU $AC80	    ; using the tiles/superfiles buffer to load stuff
screen_buffer: EQU $7800    ; strings/scripts level for screen bitmap buffer
attr_buffer: EQU $BE00      ; dirty tiles / spdata area for attribute buffer

intro_strings: dw string01, string02, string03, string04, string05
intro_strings_en: dw string01_en, string02_en, string03_en, string04_en, string05_en
final_strings: dw end_string01, end_string02, end_string03
final_strings_en: dw end_string01_en, end_string02_en, end_string03_en

intro_screens: dw load_buffer, load_buffer+1020, load_buffer+1020+592, load_buffer+1020+592+777, load_buffer+1020+592+777+484
intro_attrs:   dw load_buffer+3777, load_buffer+3777+59, load_buffer+3777+59+96, load_buffer+3777+59+96+102, load_buffer+3777+59+96+102+69
final_screens: dw load_buffer, load_buffer+592, load_buffer+592+1302
final_attrs:   dw load_buffer+2819, load_buffer+2819+96, load_buffer+2819+96+66

string01: db 'HACE TIEMPO, EL MUNDO ESTUVO DOMINADO POR EL SE$OR DEL CAOS.',0
string02: db 'ANTE TAL SITUACI;N, LA DIOSA IANNA ELIGI; A TUKARAM PARA PORTAR LA ESPADA SAGRADA QUE ELIMINAR>A EL MAL.',0
string03: db 'TUKARAM CONSIGUI; TRAER LA PAZ A NUESTRAS TIERRAS, SIENDO SU ESTIRPE BENDECIDA COMO SIERVOS DE LA DIOSA.',0
string04: db 'PERO EL MAL NO DESCANSA, Y SIGLOS M%S TARDE INTENTA RECUPERAR TERRENO.',0
string05: db 'COMO HEREDERO DE TUKARAM, TU DEBER ES PONERTE EN MARCHA, VENCER AL CAOS Y RESTABLECER EL ORDEN.',0

string01_en: db 'A LONG TIME AGO, THE WORLD WAS RULED BY THE NOCUOUS LORD OF CHAOS.',0
string02_en: db 'THE GODDESS IANNA APPOINTED TUKARAM TO WIELD THE SACRED SWORD THAT COULD DEFEAT EVILNESS.',0
string03_en: db 'TUKARAM BROUGHT PEACE TO OUR LANDS, AND HIS LINEAGE WAS BLESSED AS SERVANTS OF THE GODDESS.',0
string04_en: db 'BUT EVIL DOES NOT REST, AND SOME CENTURIES LATER IT TRIES TO RECOVER.',0
string05_en: db 'AS AN HEIR OF TUKARAM, IT IS YOUR SWORN DUTY TO GO NOW, OVERCOME CHAOS AND RESTORE ORDER.',0

end_string01: db 'EL CAOS HA SIDO EXPULSADO Y LA DIOSA IANNA EST% AGRADECIDA.',0
end_string02: db 'VUELVE CON TU PUEBLO, FIEL GUERRERO, Y VIVE TRANQUILO. CUSTODIAR? LA ESPADA, PUES EL MAL NO DESCANSA.',0
end_string03: db 'REGRESAR AL HOGAR ES LA MAYOR RECOMPENSA, Y LA PAZ EL BIEN M%S PRECIADO.',0

end_string01_en: db 'THE LORD OF CHAOS HAS BEEN DEFEATED, AND IANNA IS WELL PLEASED.',0
end_string02_en: db 'GO BACK TO YOUR VILLAGE AND ENJOY A PEACEFUL LIFE. I WILL KEEP THE SWORD, FOR EVIL DOES NOT REST.',0
end_string03_en: db 'RETURNING HOME IS THE HIGHEST REWARD, AND PEACE THE MOST PRECIOUS POSSESSION.',0


intro:
        ld a, 1
        ld (intro_shown), a
        ; Now do the usual stuff
		ld a, (language)
		and a
		jr nz, intro_english
        ld hl, intro_strings
		jr intro_common
intro_english:
		ld hl, intro_strings_en
intro_common:
        ld de, intro_screens
        ld a, 5
        ld (number_screens), a
		ld c, 1			; intro
        call slideshow
		ld b, 20			;120
intro_end_loop:
		halt
		djnz intro_end_loop
		ret
		


ending:
		ld a, (language)
		and a
		jr nz, end_english
        ld hl, final_strings
		jr end_common
end_english:
		ld hl, final_strings_en
end_common:
        ld de, final_screens
        ld a, 3
        ld (number_screens), a
		ld c, 2			; end
        call slideshow
        ld b, 20		;100
end_wait_loop:
        halt
        djnz end_wait_loop
        call cls
	;	call MUSIC_Stop
        jp end_credits

; INPUT:
; A: number of screens
; C: 1: intro, 2: end 
; HL: pointer to strings
; DE: pointer to screen addresses

slideshow:
	ld (number_screens), a
	ld (menu_string_list), hl
	ld (menu_screen_list), de
    add a, a
    ld l, a
    ld h, 0
    add hl, de          	; HL = right after screen_list, that is, attr_list
    ld (menu_attr_list), hl
    ld hl, screen_buffer	;cargamos directamente en screen_buffer
	ld a, c
	ld (intromusicpage), a	;guardamos C= intro ó C= End
	xor a
	call IO_LoadIntro		; load intro frame 0

	ld a, (intromusicpage)	;recuperamos Intro o End screens
	ld hl, load_buffer		;las cargamos en load buffer para poder descomprimirlas
	call IO_LoadIntro		; load screens
    ; Now show the frame, and start with the slideshow
	ld hl, screen_buffer	;aqui esta el Intro Frama
	call depackscr			;lo descomprimimos en pantalla

	xor a					;ponemos A a 0 
	ld (intro_var), a		;y entramos en el loop
intro_loop:
    ld a, (intro_var)		;pantalla que queremos cargar
	call load_screen		;la cargamos
    call menu_cls
    call menu_cls_textarea
	call draw_screen

    ld a, (intro_var)
    add a, a
    ld hl, (menu_string_list)
    ld e, a
    ld d, 0
    add hl, de
    ld a, (hl)
    ld iyl, a
    inc hl
    ld a, (hl)
    ld iyh, a
    ld bc, 2*256+18
;	ld b, 2
;	ld c, 18
	call print_string_menu

;aqui vamos a llamar a la musica de la pagina
	ld b, 0
	ld a, (intromusicpage)
	cp 1
	jr nz, noesintromusic
	ld b,2						;si es intro le sumamos 2 a la pagina para el orden de almacenado
	jr intromusiccomun
noesintromusic	
	cp 2
	jr nz, intromusiccomun
	ld b, 7						;si es end le sumamos 2 a la pagina para el orden de almacenado
intromusiccomun	
    ld a, (intro_var)
	add a, b
	call Music_Play_Nopausa

;    ld b, 0
;waitloop:
;	xor a
;	ld (joystick_state), a	; reset joystick state
;   halt
;	ld a, (joystick_state)
;	bit 4, a
;	jr nz, waitloop_done
;    djnz waitloop

;waitloop_done:
    ld a, (intro_var)
    inc a
	ld hl, number_screens
    cp (hl)
	ret nc
    ld (intro_var), a
    jr intro_loop

;  A: screen number
load_screen:
    ld de, screen_buffer
	add a, a
	ld c, a
	ld b, 0
    push bc
	ld hl, (menu_screen_list)
	add hl, bc
	ld c, (hl)
	inc hl
	ld b, (hl)
	ld h, b
	ld l, c
	call depack             ; Place bitmap in bitmap buffer
    pop bc
    ld de, attr_buffer
	ld hl, (menu_attr_list)
	add hl, bc
	ld c, (hl)
	inc hl
	ld b, (hl)
	ld h, b
	ld l, c
	jp depack             ; Place attributes in attr buffer
;	ret


draw_screen:
	ld bc, $0800
    ld de, screen_buffer
draw_screen_loop_char:
	push bc
	push de
	call print_char_menu_go
	pop de
	pop bc
	ld hl, 8
	add hl, de
	ex de, hl			; DE points to the next char
	inc b
	ld a, b
	cp 24
	jr nz, draw_screen_loop_char
	ld b, 8
	; next y
	inc c
	ld a, c
	cp 16
	jr nz, draw_screen_loop_char
draw_screen_attributes:
	ld hl, attr_buffer			; go to the start of the attribute area
	ld bc, $0800
;	halt
draw_screen_loop_attr:
;	ld a, (hl)
	ld e, (hl)
	push hl
;	push bc
;	ld e, a
	call SetAttribute
;	pop bc
	pop hl
	inc hl
	inc b
	ld a, b
	cp 24
	jr nz, draw_screen_loop_attr
;    halt
	ld b, 8
	; next y
	inc c
	ld a, c
	cp 16
	jr nz, draw_screen_loop_attr
	ret	

; Print a string, terminated by 0
; INPUT:
;	IY: pointer to string
;	B: X in chars
;	C: Y in chars

print_string_menu:
	push iy
	call next_word_menu
	pop iy
	ld a, d
	and a
	ret z		; return on NULL
	
	add a, b
	cp 32
	jr c, print_str_nonextline_menu
print_str_nextline_menu: 	; go to next line
	ld b, 2
	inc c
print_str_nonextline_menu:
	; now print word
	call print_word_menu
	jr print_string_menu
;	ret

; Find next word
; INPUT:
;	IY: pointer to string
; OUTPUT:
;	D: word length
next_word_menu:
	ld d, 0
next_word_menu_loop:
	ld a, (iy+0)
	and a
	ret z
	cp ' '
	jr z, next_word_menu_finished
	cp ','
	jr z, next_word_menu_finished
	cp '.'
	jr z, next_word_menu_finished
	inc d
	inc iy
	jr next_word_menu_loop
next_word_menu_finished:
	inc d
	ret	

; Print a word on screen
; INPUT:
;	- B: X in chars
;	- C: Y in chars
;	- D: word length
print_word_menu:
;    halt				<<<<<<<<<<<<<le quito la pausa de impresion para escuchar la musica
	ld a, (iy+0)
	push de
;	push iy				;no tocamos IY en print_char_menu no hace falta guardarlo
	push bc
	call print_char_menu
	pop bc
;	pop iy
	pop de
	inc iy
	inc b
	ld a, d
	dec a
	ld d, a
	jr nz, print_word_menu
	ret

menu_cls:					;borra el area del grafico poniendo los atributos a 0
	ld hl, 22528 + 5
	ld de, 10
	ld a, 16
	ld bc, $1616
menu_cls_inerloop:
	ld (hl),0
	inc l
	djnz menu_cls_inerloop
	ld b, c
	add hl, de
	dec a
	jr nz, menu_cls_inerloop
	ret

;	xor a
;	ld (menu_cls_loop), a
	
;	ld b, 20
;menu_cls_outerloop:
;	ld hl, 16384+6144+5
;	ld e, a
;	ld d, 0
;	add hl, de		; HL points to the first row 
;	ld de, 30
;	ld c, 16
;	halt
;   halt
;menu_cls_inerloop:
;	xor a
;	ld (hl), a
;	inc hl
;	ld (hl), 2
;	inc hl
;	ld (hl), 2
;	add hl, de
;	dec c
;	jr nz, menu_cls_inerloop
;	ld a, (menu_cls_loop)
;	inc a
;	ld (menu_cls_loop), a
;	dec b
;	jr nz, menu_cls_outerloop
	; last line, the last column is red, now clean 
;	ret

menu_cls_textarea:			;borra las 4 lineas de texto poniendo todo a 0
	ld hl, 20544
	ld de, 128
	ld a, 8
menu_cls_textarea_yloop:
	ld bc,$1E04
menu_cls_textarea_xloop:
	inc l
	ld (hl), 0
	djnz menu_cls_textarea_xloop
	ld b, $1E
	inc l
	inc l
	dec c
	jr nz, menu_cls_textarea_xloop
	add hl, de
	dec a
	jr nz, menu_cls_textarea_yloop
	ret
;    ld de, FONT
;    ld c, 18
;menu_cls_textarea_yloop:
;    ld b, 2    
;menu_cls_textarea_xloop:
;   push bc
;	push de
;	call print_char_menu_go
;	pop de
;	pop bc
;   inc b
;    ld a, b
;    cp 30
;    jr nz, menu_cls_textarea_xloop
;    inc c
;    ld a, c
;    cp 23
;    jr nz, menu_cls_textarea_yloop
;    ret

print_char_menu:
;	sub 32				;7 first char is number 32
;	ld e, a				;4
;	ld d, 0				;7
;	rl e				;8
;	rl d				;8
;	rl e				;8
;	rl d				;8
;	rl e				;8
;	rl d				;8 Char*8, to get to the first byte
;	ld hl, FONT			;10
;	add hl, de			;11 HL points to the first byte
;	ex de, hl			;4 DE points to the first byte
	;					91 total 

	ld l, a 					;4
	ld h, 0						;7
	add hl,hl					;11 duplicamos HL (x2)
	add hl,hl					;11 duplicamos HL (x4 en total)
	add hl,hl					;11 duplicamos HL (x8 en total)
	ld a, high FONT - 1			;7
	add a, h					;4
	ld d, a 					;4
	ld e, l						;4
	;							63 total


	
print_char_menu_go:
	ld hl, TileScAddress	; address table
;	ld a, c
;	add a,c			; C = 2*Y, to address the table
;	ld c,a
	ld a, b			; A = X
	ld b, 0			; Clear B for the addition
	add hl, bc		;ahorramos 1 t-state y 2 bytes
	add hl, bc		; hl = address of the first tile
	ld c, (hl)
	inc l
	ld b, (hl)		; BC = Address
	ld l, a			; hl = X
	ld h, 0
	add hl, bc		; hl = tile address in video memory
	ld b, 8
print_char_menu_loop:
	ld a, (de)
	ld (hl), a
	inc e			; FIXME! will be able to do INC E, when FONTS is aligned in memory
	inc h
	djnz print_char_menu_loop
	ret

end_credits:
	ld hl, load_buffer
	ld a, 3
	call IO_LoadIntro		; load credits screen
;   Load credits music
;	call MUSIC_LoadCredits
;	call MUSIC_Init			; little trick: load but don't play
;    call cls
	ld hl, load_buffer
	call depackscr
;	ld a, 1
;	ld (music_playing), a	; music is now playing
	ld iy, credits01
	ld b, 43									;lineas de los creditos <<<<<<<<<<<<<<<<<<<<<<
end_credits_line:
	push iy
	push bc
	call credits_string
	call end_credits_loop
	pop bc
	pop iy
	ld de, 16
	add iy, de
	djnz end_credits_line
	ld b, 14
end_credits_end:
	push bc
	call end_credits_loop
	pop bc
	djnz end_credits_end
	ld bc, 12*256+16
    ld iy, credits_end
    call credits_string_loop
end_credits_wait_loop:
  	xor a
   	ld (joystick_state), a	; reset joystick state
    halt
   	ld a, (joystick_state)
   	bit 4, a
  	jr z, end_credits_wait_loop
;	call MUSIC_Stop
	ret

end_credits_loop:
	ld a, 8
end_credits_loop_inner:
	halt
	halt
	halt
	halt
	push af
	call credits_scrollup
	pop af
	dec a
	jr nz, end_credits_loop_inner
	ret


; IY: string

credits_string:
	ld bc, 10*256+23
;	ld c, 23
credits_string_loop
	ld a, (iy+0)
	and a
	ret z
;	push iy				;no tocamos IY en print_char_menu no hace falta guardarlo
	push bc
	call print_char_menu
	pop bc
;	pop iy
	inc iy
	inc b
	jr credits_string_loop


; 16 bytes starting at X=10 (in tile coords)
; D: destination Y (in pixels)
; E: source Y
credits_scroll_line:
	push de
	ld c, d
	ld b, 80
	call calcscreenpos	; destination screen position in HL
	pop de
	ex de, hl		; destination screen position in DE
	ld c, l
	ld b, 80
	call calcscreenpos	; source screen position in HL
	ld b, 16
credits_scroll_line_loop:
	ld a, (hl)
	ld (de), a
	inc l
	inc e
	djnz credits_scroll_line_loop
	ret

; scroll all lines from Y=87 to Y=184
credits_scrollup:
	ld de, 87*256+88
	ld b, 191-87
credits_scrollup_loop:
	push bc
	push de
	call credits_scroll_line
	pop de
	inc d
	inc e
	pop bc
	djnz credits_scrollup_loop
	ret

; FIXME: this will be compressed here
credits01: db 'RETROWORKS 2017',0
credits02: db '               ',0
credits03: db 'CODE:          ',0
credits04: db '        UTOPIAN',0
credits05: db '               ',0
credits06: db 'GFX, LEVELS:   ',0
credits07: db '    PAGANTIPACO',0
credits08: db '               ',0
credits09: db 'MUSIC AND SFX: ',0
credits10: db '         MCALBY',0
credits11: db '               ',0
credits12: db 'LOADING SCREEN:',0
credits13: db '            MAC',0
credits14: db '               ',0
credits15: db 'OPTIMIZATIONS: ',0
credits16: db '     METALBRAIN',0
credits17: db '               ',0
credits18: db 'CARTRIDGE HW:  ',0
credits19: db '        DANDARE',0
credits20: db '               ',0
credits181: db '48K MLD VER:   ',0
credits191: db '         SPIRAX',0
credits201: db '               ',0
credits21: db 'PROOFREADING:  ',0
credits22: db '  FELIX CLOWDER',0
credits23: db '               ',0
credits24: db 'TESTING:       ',0
credits25: db '         METR81',0
credits26: db '         IVANZX',0
credits27: db 'RETROWORKS TEAM',0
credits28: db '               ',0
credits29: db 'WE WANT TO SAY ',0
credits30: db '  THANK YOU TO:',0
credits31: db '               ',0
credits32: db 'FRIENDWARE AND ',0
credits33: db '   REBEL ACT   ',0
credits34: db '  STUDIOS, FOR ',0
credits35: db '    CREATING   ',0
credits36: db 'BLADE: THE EDGE',0
credits37: db '  OF DARKNESS  ',0
credits38: db '               ',0
credits39: db '  YOU, PLAYER, ',0
credits40: db '  FOR PLAYING  ',0


credits_end: db '    THE END    ',0
