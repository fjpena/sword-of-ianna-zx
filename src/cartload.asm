	org 24000


set_cart_boot:
	ld a, 41	; 41,1,0 special command stores in eeprom bank 1 on normal boot (if not stored already)
	ld d, 1
	ld e, 0
	call SENDSPCMD
	call SENDCONF

set_reset_boot:
	; Current slot is 0. Make sure it will be used after a reset
	ld hl,1		 
    ld a, 39		; Command 39 sets current rom Slot as reset slot
	call SENDNRCMD  


start_load:    	
	ld ix, loader_table_ianna
    ld b, (ix+0)	; b==iteratons
	inc ix
load_loop:	
	push bc

	ld a, (ix+0)	; ROM page
	ld hl, DDNTRADDRCMD
	call SENDNRCMD	; Set ROM page

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

loader_table_ianna:
	db 6		; 6 entries

	db 18		; load from page 17
	dw 0		; load offset is 0
	dw 6912		; load 6912 bytes (loading.scr)
	dw 16384	; loading screen
	db $00		; RAM Bank 0, not compressed

	db 5		; load from ROM page 4
	dw 0		; load offset is 0
	dw 16372	; load 16372 bytes (ianna-4.rom) -> ram3.bin
	dw 49152	; load to 49152
	db $03		; RAM Bank 3, not compressed

	db 4		; load from ROM page 3
	dw 0		; load offset is 0
	dw 16254    ; load 16254 bytes (menu)
	dw 49152	; load to 49152
	db $06		; RAM Bank 6, not compressed

	db 1		; load from ROM page 0
	dw 8192		; load offset is 8192
	dw 8192  	; load 8192 bytes (ianna-0.rom)
	dw 24576	; load to 24576
	db $00		; RAM Bank 0, not compressed

	db 2		; load from ROM page 1
	dw 0 		; load offset is 0
	dw 16384  	; load 16384 bytes (ianna-1.rom)
	dw 32768	; load to 32768
	db $00		; RAM Bank 0, not compressed

	db 3		; load from ROM page 2
	dw 0 		; load offset is 0
	dw 15872  	; load 15872 bytes (ianna-2.rom)
	dw 49152	; load to 49152
	db $00		; RAM Bank 0, not compressed


	dw 24576	; randomize usr 24576

; ----------------------------------------------------------------------------------------
; Send Special Command to Dandanator - Sends Command (a), Data 1 (d) and Data 2 (e)- Prepare for Pulse
; Destroys HL, B.
; Uses Extra 2 bytes on Stack
;
;   ********************  MUST BE RUN FROM RAM IF CHANGING SLOTS ********************
;
; ----------------------------------------------------------------------------------------
SENDSPCMD:	LD HL,DDNTRADDRCMD			; HL=0 Command (ZESARUX)
			CALL SENDNRCMD				; Send command 	

			INC HL						; HL=1 Data1 (ZESARUX)
			LD A,D						; Data 1
			CALL SENDNRCMD				; Send Data 1

			INC HL						; HL=2 Data2 (ZESARUX)
			LD A,E						; Data 2
			JP SENDNRCMD				; Send Data 2

										; Now about 0,5ms to confirm command with a pulse to DDNTRADDRCONF
; ----------------------------------------------------------------------------------------



; ----------------------------------------------------------------------------------------
; Send Normal Command to Dandanator - Sends Command/Data
;     A  = Cmd/Data, 
;	  HL = port number:  1 for cmd, 2 for data1, 3 for data2, (0 for confirmation) (ZESARUX) 
; Destroys B
; NOTE: 0 is signaled by 256 pulses.
;
;    		********************  MUST BE RUN FROM RAM  ********************
;
; ----------------------------------------------------------------------------------------
SENDNRCMD:	LD B,A	
NRCMDLOOP:	NOP		  					; Some time to avoid very fast pulses
			NOP
			NOP
			LD (HL),A					; Send Pulse			
			DJNZ NRCMDLOOP
			LD B, PAUSELOOPSN			; Timeout Command/Data
WAITXCMD:	DJNZ WAITXCMD				
			RET							
; ----------------------------------------------------------------------------------------



; ----------------------------------------------------------------------------------------
; Send Confirmation Pulse to dandanator and wait a bit - Also Pause Routine
; ----------------------------------------------------------------------------------------

SENDCONF:	LD (0),A
PAUSE: 		PUSH BC
			LD B,PAUSELOOPSN
WAITPAUSE:	DJNZ WAITPAUSE
			POP BC
			RET			
; ----------------------------------------------------------------------------------------

PAUSELOOPSN 	EQU 40					; 40 is compatible with all firmware versions. 10 is faster but only >=6.4
DDNTRADDRCMD 	EQU 1	
