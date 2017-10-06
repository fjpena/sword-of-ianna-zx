org 24000

start_load:    	
	ld ix, loader_table_ianna
    ld b, (ix+0)	; b==iteratons
	inc ix
load_loop:	
	push bc

	ld a, (ix+0)	; ROM page
	call IF2_SetROM	; Set ROM page

	ld a, (ix+7)	; RAM page
	call setrambank	; set RAM page
	ld l, (ix+1)
	ld h, (ix+2)	; HL = source (offset in page)
	ld c, (ix+3)
	ld b, (ix+4)	; BC = number of bytes to load
	ld e, (ix+5)
	ld d, (ix+6)	; DE = destination
	ldir			; copy data

	ld bc, 8
	add ix, bc		; go to next entry

	pop bc			; get the counter back!
	djnz load_loop
		
	ld e, (ix+0)
	ld d, (ix+1)		; get the execution address in de
	push de

set_ram_paging:
	ld a, $10		; RAM 0, ROM 2 (48k BASIC)
	call setrambank
wait_keypressed_loop:
	call KEYPRESSED
	and a
	jr z, wait_keypressed_loop
	xor a
	out ($fe), a

launch_program: 
	pop hl			; get the execution address
	LD IY, 5C3Ah	; re-establish the IY pointer (must be done!)
;	ei				; enable interrupts
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
	or $10			; select always ROM1 (128K) or ROM3 (+2A/+3)
	ld BC, $7FFD
	ld ($5b5c), a   ; save in the BASIC variable
	out (c), a
	ret

; INPUT: A: ROM page to set (0-31)
IF2_SetROM:
	ld b, 5
    rlca
    rlca
    rlca				; let's shift it 3 bits to the left, page numbers are 0-31
SigKV4Step:  
    rlca
    JR C, K4S1
    LD ($3ffc), A
    JR afterK4S1
K4S1:
    LD ($3ffd), A
afterK4S1:
    DJNZ SigKV4Step
	ld b, 0
sillyloop:
	djnz sillyloop
	ret

loader_table_ianna:
	db 6		; 6 entries

	db 17		; load from page 17
	dw 0		; load offset is 0
	dw 6912		; load 6912 bytes (loading.scr)
	dw 16384	; loading screen
	db $00		; RAM Bank 0, not compressed

	db 4		; load from ROM page 4
	dw 0		; load offset is 0
	dw 16372	; load 16372 bytes (ianna-4.rom) -> ram3.bin
	dw 49152	; load to 49152
	db $03		; RAM Bank 3, not compressed

	db 3		; load from ROM page 3
	dw 0		; load offset is 0
	dw 16254    ; load 16254 bytes (menu)
	dw 49152	; load to 49152
	db $06		; RAM Bank 6, not compressed

	; We have to do something special in this case. Due to the way the
	; Kartusho v4 cart paging works, we cannot read anything in the last
	; 4 bytes of the lower page ($3ffc-$3fff). So we need to adapt the
	; files to skip the last 4 bytes, and load them in the next page.

	db 0		; load from ROM page 0
	dw 8192		; load offset is 8192
	dw 8188  	; load 8188 bytes (ianna-0.rom)
	dw 24576	; load to 24576
	db $00		; RAM Bank 0, not compressed

	db 1		; load from ROM page 1
	dw 0 		; load offset is 0
	dw 16380  	; load 16380 bytes (ianna-1.rom)
	dw 32764	; load to 32764
	db $00		; RAM Bank 0, not compressed

	db 2		; load from ROM page 2
	dw 0 		; load offset is 0
	dw 15878  	; load 15872 bytes (ianna-2.rom)
	dw 49144	; load to 49144
	db $00		; RAM Bank 0, not compressed

	dw 24576	; randomize usr 24576
