org 24100

start:
	di 
	call check128k
	jr   z, carga_pantalla

	ld   hl, scr48
	call depackscr
lock	halt
	jr   lock

carga_pantalla
	ld   ix, #4000
	ld   de, #1B00
	call LD_BYTES
	jr   nc, carga_pantalla

	ld   a, #13
	call setrambank
carga_ram3	
	ld   ix, 49152
	ld   de, 16372
	call LD_BYTES
	jr   nc, carga_ram3

	ld   a, #16
	call setrambank
carga_ram6
	ld   ix, 49152
	ld   de, 16254
	call LD_BYTES
	jr   nc, carga_ram6

	ld   a, #10
	call setrambank
carga_main
	ld   ix, 24576
	ld   de, 40448
	call LD_BYTES
	jr   nc, carga_main

	; Now change the border, wait for a key and continue
	ld a, 1
	out ($fe), a
wait_keypressed_loop:
	call KEYPRESSED
	and a
	jr z, wait_keypressed_loop
	xor a
	out ($fe), a

launch_program: 
	jp   24576		; and run!




LD_BYTES 
	ld   a, 255
	scf
	inc  d
	ex   af, af'
	dec  d 
	ld   a, 8
	out  (#FE), a
	jp   #562		;sin hacer el PUSH HL a #53F




; Function: test if any key is pressed
; INPUT: none
; OUTPUT: A = 0 if no key pressed, A != 0 if any key pressed
; MODIFIES: AF, BC, DE

KEYPRESSED:
        LD BC, $FEFE    ; This is the first row, we will later scan all of them
        LD D,8          ; loop counter

keyp_scanloop:
        IN A, (C)       ; Read the row status
        CPL             ; invert, so that any bit in 1 is a key pressed
        AND $1f         ; get the 5 significant bits
        RET NZ          ; A != 0, a key was pressed
        RLC B           ; go to the next row
        DEC D
        JR NZ, keyp_scanloop
        XOR A           ; No key pressed, A=0 and return
        RET

; INPUT: A: page to set 
setrambank:
       ld   BC, $7FFD
       ld   ($5b5c), a   ; save in the BASIC variable
       out  (c), a
       ret

 
	;entrada ninguna, OJO asume Interrupciones estan desabilitadas
	;modifica BC, DE, HL A y A'
	;salida Z para 128k
	;salida NZ para 48k

check128k	
	ld bc, $7ffd
	ld e, $11	;E= segundo banco de memoria para probar
	ld a, ($5b5c)	;recuperamos el banco actual de la variable del sistema
	ld d, a		;D= banco actual
	ld hl, $C000	;usamos $C000 como direccion de prueba
	ld a, (hl)	;ponemos en A el contenido actual
	out (c), e	;cambiamos al segundo banco
	cpl		;invertimos A
	ex af, af'
	ld a, (hl)	;guardamos el contenido del segundo banco en A'
	ex af, af'
	ld (hl), a	;cargamos A invertido en el segundo banco
	cpl		;lo invertimos otra vez para restaurar el valor original
	out (c), d	;cambiamos al banco original
	cp (hl)		;comparamos A con el contenido de HL, en un 128k mantendra el valor original y sera Z, en un 48k el contenido de HL estara invertido por lo que sera NZ
	out (c),e	;cambiamos al segundo banco
	ex af, af'
	ld (hl), a	;restauramos el contenido del segundo banco de A'
	ex af, af'
	out (c), d	;dejamos el banco original
	ld (hl), a	;y restauramos el valor que tenia al principio
	ret


      include "depack.asm"

scr48
       incbin "48k.cmp"