;music_playing: db 0
;music_state: db 0		; 0: music+fx, 1: music only, 2: fx only

;music_sfx:  equ $C759
;music_addr: equ $CB72	; music will be on a fixed location, and we'll load it from disk/cart
;music_save: db 0

; Load music
; INPUT:
;	- A: music number

; Play FX
FX_SWORD1 			EQU 1
FX_DESTROY_BLOCK 	EQU 2
FX_BLOCK_HIT		EQU 3
FX_HIT				EQU 4
FX_LEVER			EQU 5
FX_SKELETON_FALL	EQU 6
FX_PICKUP			EQU 7
FX_GROUND			EQU 8
FX_GRIP				EQU 9
FX_UNSHEATHE		EQU 10
FX_SHEATHE			EQU 11
FX_INVENTORY_MOVE	EQU 12
FX_INVENTORY_SELECT	EQU 13
FX_OPEN_DOOR		EQU 14
FX_CLOSE_DOOR		EQU 15
FX_ENTER_DOOR		EQU 16
FX_TEXT				EQU 17
FX_PAUSE			EQU 18
FX_LONGJUMP			EQU 19
FX_EMPTY		    EQU 20
FX_LEVEL_UP			EQU 21

; Input:
;	A: sound effect to play

FX_ADDRESS:
;   defb e, b, efecto 					;efecto >> 0= nop, 28=inc e, 29=dec e 
; 										; cuando se use 29 comprobar que E sea mayor que B
;										; cuando se use 28 comprobar que E+B sea menor de 255

    defb 5,30,28                        ;PLAY_FX_SWORD1 			
    defb 10,80,28                       ;PLAY_FX_DESTROY_BLOCK 	
    defb 10,40,0                        ;PLAY_FX_BLOCK_HIT		
    defb 10,40,0                        ;PLAY_FX_HIT				
    defb 10,40,0                        ;PLAY_FX_LEVER			
    defb 10,40,0                        ;PLAY_FX_SKELETON_FALL	
    defb 160,5,29                       ;PLAY_FX_PICKUP			
    defb 1,50,0                         ;PLAY_FX_GROUND			
    defb 10,40,0                        ;PLAY_FX_GRIP				
    defb 3,25,28                        ;PLAY_FX_UNSHEATHE		
    defb 28,25,29                       ;PLAY_FX_SHEATHE			
    defb 100,10,0                       ;PLAY_FX_INVENTORY_MOVE	
    defb 160,20,0                       ;PLAY_FX_INVENTORY_SELECT	
    defb 80,40,28                       ;PLAY_FX_OPEN_DOOR		
    defb 120,40,29                      ;PLAY_FX_CLOSE_DOOR		
    defb 10,40,0                        ;PLAY_FX_ENTER_DOOR		
    defb 11,3,29                        ;PLAY_FX_TEXT				
    defb 30,20,28                        ;PLAY_FX_PAUSE			
    defb 1,50,0                         ;PLAY_FX_LONGJUMP			
    defb 10,40,0                        ;PLAY_FX_EMPTY		    
    defb 10,40,0                        ;PLAY_FX_LEVEL_UP			

FX_Play:
	di
	push bc
	push de
	push hl
	ld c, a
	add a,a
	add a, c							;multiplicamos en sonido por 3
	ld c, a
	ld b, 0
	ld hl, FX_ADDRESS
	add hl, bc							;y ahora tendremos la direccion de final del sonido
	dec hl								;no ponemos en el ultimo dato del sonido que queremos
	ld a, (hl)							;cargamos en A el efecto a usar
	ld (efecto),a						;y modificamos el codigo con el efecto
	dec hl
	ld d, (hl)							;ponemos D
	dec hl
	ld e, (hl)							;ponemos E
	xor a								;A a 0 para el borde negro
	call loopfx0						;y ejecutamos el sonido
	pop hl
	pop de
	pop bc	
	ei
	ret

loopfx0:	
	ld bc, 24574
	out (c), a			;activamos desactivamos altavoz
	xor 16
	ld c, e					;pausamos con el valor de E
loopfx1:	
	dec c
	jr nz,loopfx1
efecto 
	nop						;aqui ira el efecto,que será =nop ,=inc e ,=dec e
	dec d
	jr nz, loopfx0			;repetir D veces
	xor a					;desactivamos el altavoz y borde negro
	out ($FE), a			;lo pasamos al puerto
	ret


;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;***********************************************************************************************
;ANTEATER music routine for ZX Spectrum
;by utz 08'2014 modified by Spirax
;***********************************************************************************************

;se llama con 		A: musica a reprocducir 
;si llamamos a Music_Play si el valor de la musica es distinto de 0 nos permitira salir con cualquier tecla
;si llamamos a Music_Play_Nopausa no permite parar la musica hasta que se acabe

Music_Play:	
	ld (keyreturn), a				;ponemos a en la pausa 
Music_Play_Nopausa:
	call IO_LoadMusic				;carga la musica en memoria
	di
	ld hl, $F780
	ld (OrderPntr), hl
	call readOrder
	xor a
	ld (keyreturn), a				;ponemos a 0 la pausa 
	ei
	ret
	
readOrder
		ld hl, (OrderPntr)			;get order pointer
		ld e, (hl)					;read pnt pointer
		inc hl
		ld d, (hl)
		inc hl
		ld (OrderPntr), hl
		ld a, d				;if pattern pointer = #0000, end of song reached
		or e
		ret z
		ld (PtnPntr), de

;**************************************************************************************************		
readPtn
		ld a, (keyreturn)
		or a
		jr z, saltarsekeyb
		ld bc, 24574
		in a, (c)
		cpl
		and #1f
		ret nz
saltarsekeyb		
		
		ld hl, (PtnPntr)
		ld a, (hl)			;check for pattern end		
		cp #ff
		jr z,readOrder

		ld a, (hl)
		and %11111100		;mask lowest 2 bits
		ld b, a				;speed
		ld c, b
		
		ld a, (hl)
		and %00000011
		or a				;if !=0, we have drum
		call nz, drums

		ld a, (I.esuninves)			;ahora comprobamos si estamos en un inves
		or a						;si hay cualquier valor es un inves
		jp nz, continuemusic.inves	;y saltamos a la rutina modificada para un Inves

		ld a, #10
		ld (switch1), a
		ld (switch2), a
	
drdata		
		inc hl
		xor a
		ld d, (hl)			;counter ch2
		ld e, d
		push hl
		ld h, #10			;output mask ch2
		or d
		jr nz, rdskip1		
		ld h, a				;mute if note byte = 0
rdskip1
		ld l, h				;swap mask
		exx
		pop hl
		inc hl
		ld b, (hl)			;counter A
		or b
		jr nz, rdskip2
		ld (switch1), a
		ld (switch2), a
rdskip2
		ld c, b				;backup counter A/B
		ld d, b				;counter B
		inc hl
		ld (PtnPntr), hl
		ld hl, #1000			;output mask ch1
		exx

;**************************************************************************************************		
play
		ld a, h			;4	;load output mask ch2
		exx			    ;4
		dec b			;4	;dec counter A
		out ($fe), a	;11	;output ch2
		jr nz, wait1	;12/7
		ld a, h			;4	;flip output mask and restore counter
switch1 equ $+1					;mute switch
		xor #10			;7
		ld h, a			;4
		ld b, c			;4
skip1
		dec d			;4	;dec counter B
		ld a, l			;4	;load output mask ch1
		jr nz, wait2	;12/7
		ld d, c			;4	;restore counter
switch2 equ $+1			;mute switch
		xor #10			;7	;swap output mask
		ld l, a			;4
		
		rra				;4	;increment counter to create pwm effect if output mask = #10
		rra				;4
		rra				;4
		rra				;4
		add a, d		;4
		ld d, a			;4
		
skip2
		ld a, l			;4
		and h			;4	;combine output masks
		out (#fe),a		;11	;output ch1
		
		exx				;4
		dec d			;4	;decrement counter ch1
		jp nz, wait3	;10
		ld d, e			;4	;restore counter
		ld a, h			;4	;swap output mask
		xor l			;4
		ld h, a			;4
		
skip3		
		dec bc			;6	;decrement speed counter
		ld a, b			;4
		or c			;4
		nop				;4	;take care of IO contention
		jp nz,	play	;10
						;184
		jp readPtn

;**************************************************************************************************

wait1
		nop				;4
		jp skip1		;10

wait2
		;sla (hl)		;15
		;sla (hl)		;15
		inc hl			;6
		dec hl			;6
		inc hl			;6
		dec hl			;6
		jr skip2		;12
						;36
wait3
		nop				;4
		jr skip3		;12

;**************************************************************************************************
;drums modificados para que funcionen en ambos modelos :)
drums
		push hl

		dec a
		ld hl, switch2
		ld d, #fd
		jr z, drum2
		dec a
		ld d, #bf
		ld hl, drdata+7
		jr z, drumloop3
		
drum1
		ld hl, drdata
		
		ld a, c			;timing correction
		sub #c2
		ld c, a
		jr nc, tskip1
		dec b
tskip1
		push bc
		ld b, 12
drum1a
		ld a, #10
		push bc
		ld bc,24574
		out (c), a
		ld a, (hl)
drumloop1
		dec a
		jr nz, drumloop1
		out (c), a
		ld a, (hl)
drumloop2
		dec a
		jr nz, drumloop2	
		inc hl
		pop bc
		djnz drum1a
		jr drumret

drum2
		dec b			;timing correction
		ld a, #d9
		ld (switch3), a		;modify end marker value
drumloop3
		ld a, c			;timing correction
		sub d
		jr nc, tskip2
		dec b
tskip2
		push bc
drumloop30
		ld a, #10
		ld bc, 24574
		out (c), a
switch3 equ $+1
		ld a, 6
		ld b, (hl)
		xor b
		jr z, drumret
dl3a
		push hl
		pop hl
		djnz dl3a
		xor a
		ld b, $5F
		out (c), a
		ld b, (hl)
dl3b
		push hl
		pop hl
		djnz dl3b
		inc hl
		jr drumloop30
		ld a, 6
		ld (switch3), a

drumret
		pop bc
		pop hl
		ret
		
;**************************************************************************************************
OrderPntr
		dw 0		
PtnPntr
		dw 0
keyreturn
		db 0
		


;**************************************************************************************************
;rutina modificada para usar el puerto 24574 donde hay un 255 para que funcione en el inves
;hay que ajustar timings

continuemusic.inves:
		ld a, #10
		ld (switch1.inves), a
		ld (switch2.inves), a
	
drdata.inves		
		inc hl
		xor a
		ld d, (hl)			;counter ch2
		ld e, d
		push hl
		ld h, #10			;output mask ch2
		or d
		jr nz, rdskip1.inves		
		ld h, a				;mute if note byte = 0
rdskip1.inves
		ld l, h				;swap mask
		exx
		pop hl
		inc hl
		ld b, (hl)			;counter A
		or b
		jr nz, rdskip2.inves
		ld (switch1.inves), a
		ld (switch2.inves), a
rdskip2.inves
		ld c, b				;backup counter A/B
		ld d, b				;counter B
		inc hl
		ld (PtnPntr), hl
		ld hl, #1000			;output mask ch1
		exx

;**************************************************************************************************		
play.inves
		ld a, h			;4	;load output mask ch2
		exx			    ;4
		dec b			;4	;dec counter A
		push bc			;+11
		ld bc, 24574	;+10
		out (c), a		;11+1	;output ch2
		pop bc			;+10
		jr nz, skip1.inves	;12/7		quitamos el wait ya que hemos metido mas t-states
		ld a, h			;4	;flip output mask and restore counter
switch1.inves equ $+1					;mute switch
		xor #10			;7
		ld h, a			;4
		ld b, c			;4
skip1.inves
		dec d			;4	;dec counter B
		ld a, l			;4	;load output mask ch1
		jr nz, skip2.inves	;12/7		nos saltamos la pausa ya que hemos metido mas t-states
		ld d, c			;4	;restore counter
switch2.inves equ $+1			;mute switch
		xor #10			;7	;swap output mask
		ld l, a			;4
		
		rra				;4	;increment counter to create pwm effect if output mask = #10
		rra				;4
		rra				;4
		rra				;4
		add a, d		;4
		ld d, a			;4
		
skip2.inves
		ld a, l			;4
		and h			;4	;combine output masks
		push bc
		ld bc, 24574
		out (c),a		;11	;output ch1
		pop bc
		
		exx				;4
		dec d			;4	;decrement counter ch1
		jp nz, skip3.inves	;10			;quitamos el pausa ya que hemos metido mas t-states
		ld d, e			;4	;restore counter
		ld a, h			;4	;swap output mask
		xor l			;4
		ld h, a			;4
		
skip3.inves		
		dec bc			;6	;decrement speed counter
		ld a, b			;4
		or c			;4
		nop				;4	;take care of IO contention
		jp nz,	play.inves	;10
						;184
		jp readPtn

;**************************************************************************************************
