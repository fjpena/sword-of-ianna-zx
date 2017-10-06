org 24100

INCLUDE "unodos.api"

load_1:		
		ld hl, loader_table_ianna
		ld (loader_table), hl
		ld hl, ianna_str
		ld (loader_file),hl

start:
    ld a, '*'       ; Default drive
	ld ix, (loader_file)
	ld b, fa_read
	rst $08
	db f_open       ; Open file
	jp c,0
	ld (filehandle), a

start_load:    	ld hl, (loader_table)
	        ld b, (hl)	; b==iteratons
		inc hl
load_loop:	push bc
		ld a, (hl)		
		ld ixl, a
		inc hl
		ld a, (hl)
		ld ixh, a
		inc hl			; ix==load address, hl== address of size
		ld c, (hl)		
		inc hl
		ld b, (hl)
		inc hl			; ix==load address, hl== start of store address, bc == length
		ld a, (hl)		
		ld (destination_address), a
		inc hl
		ld a, (hl)		; destination_address ==store address
		ld (destination_address+1), a
		inc hl
		ld e, (hl)		; E == RAM BANK & compressed -> compressed not used in this game
		
		push hl	
		push ix	
		push de			; save for later
		push bc
                
		ld a, (filehandle)
		rst $08
		db f_read
		; jp c, 0   		; check for errors!!!!!
   		pop bc
		pop de		
		pop ix		; hl still in the stack
;		pop hl
		
		push bc
		ld a, e
        call setrambank      ; set RAM BANK 
		pop bc

not_compressed:	; block is not compressed
		push ix		; bc = length
		pop hl		; hl = source address
		ld de, (destination_address)	; de = dest address
		ldir		; just copy!
        ld a, $10
        call setrambank
continue_loop:  pop hl			; get the HL pointer back!
		inc hl			; and point to the next block
		pop bc			; get the counter back!
		djnz load_loop
		
		ld e, (hl)
		inc hl
		ld d, (hl)		; get the execution address in de
		push de
		
close_file:
       		ld a, (filehandle)
		rst $08
		db f_close

set_ram_paging:
		ld a, $10		; RAM 0, ROM 2 (48k BASIC)
		call setrambank
		; Now change the border, wait for a key and continue
		ld a, 1
		out ($fe), a
wait_keypressed_loop:
		call KEYPRESSED
		and a
		jr z, wait_keypressed_loop
		xor a
		out ($fe), a
launch_program: pop hl			; get the execution address
		LD IY, 5C3Ah		; re-establish the IY pointer (must be done!)
		jp (hl)			; and run!




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
       di
       or $10			; select always ROM1 (128K) or ROM3 (+2A/+3)
       ld BC, $7FFD
       ld ($5b5c), a   ; save in the BASIC variable
       out (c), a
       ei
       ret

loader_table   dw 0
loader_file    dw 0
destination_address dw 0
filehandle:	db 0

ianna_str	db "ianna.gam",0


loader_table_ianna:
	db 4		; 4 entries

	dw 32768	; load at 32768   (loading.scr)
	dw 6912		; load 6912 bytes
	dw 16384	; after loading, copy to 16384
	db $00		; RAM Bank 0, not compressed
	
	dw 32768	; load at 32768 (ram3.bin)
	dw 16372    ; load 16372 bytes
	dw 49152	; after loading, copy to 49152
	db $03		; RAM Bank 3, not compressed

	dw 32768	; load at 32768 menu.bin
	dw 16254    ; load 16254 bytes
	dw 49152	; after loading, copy to 49152
	db $06		; RAM Bank 6, not compressed

	dw 24576
	dw 40448	; load 40448 bytes (ianna.bin)
	dw 24576	; after loading, copy to 24600
	db $00		; RAM Bank 0, not compressed

	dw 24576	; randomize usr 24576

