DOS_EST_1346 	equ $13F
DOS_OPEN 	equ $106
DOS_READ 	equ $112
DOS_CLOSE	equ $109
DOS_MOTOR_OFF	equ $19c

org 24100

load_1:		
		ld hl, loader_table_ianna
		ld (loader_table), hl
		ld hl, ianna_str
		ld (loader_file),hl

start:
       		ld b, 7         ; RAM 7, ROM 3 (+3DOS)
       		call setrambank
deact_ramdisk:
       		ld hl, $0000
       		ld de, $0000
       		call DOS_EST_1346
       		JP NC, 0        ; reset if failed

       		ld hl, (loader_file) ; 
       		ld bc, $0001    	; File handle 0, exclusive read
       		ld de, $0002	; Open, place pointer after  header
       		call DOS_OPEN	; open file
       		jp nc, 0        	; reset if open failed (change into something better!!!)


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
		ld e, (hl)		
		inc hl
		ld d, (hl)
		inc hl			; ix==load address, hl== start of store address, de == length
		ld a, (hl)		
		ld (destination_address), a
		inc hl
		ld a, (hl)		; destination_address ==store address
		ld (destination_address+1), a
		inc hl
		ld c, (hl)		; C == RAM BANK & compressed -> compressed not used in this game
		
		push hl
				
		ld a,ixh
		ld h, a
		ld a,ixl	
		ld l, a
		push ix	
		push de			; save for later
		push bc
                
		ld bc, $0000	; b=file descriptor 0, load to RAM BANK 0
       		call DOS_READ	; read bytes
       		;jp nc, 0       	; reset if read failed (change into something better!!!)                                                                
                
   		; check for errors!!!!!
   		pop bc
		pop de		
		pop ix		; hl still in the stack
;		pop hl
		
		push bc
		ld a, c
		
		and $07			
                ld b, a
                call setrambank      ; set RAM BANK 
		pop bc


not_compressed:	; block is not compressed
		push ix
		push de
		pop bc		; bc = length
		pop hl		; hl = source address
		ld de, (destination_address)	; de = dest address
		ldir		; just copy!

continue_loop:  ld b, $07
                call setrambank         ; set the RAM BANK back to 7 (+3DOS)
		pop hl			; get the HL pointer back!
		inc hl			; and point to the next block
		pop bc			; get the counter back!
		djnz load_loop
		
		ld e, (hl)
		inc hl
		ld d, (hl)		; get the execution address in de
		push de
		
close_file:
       		ld b, 0
       		call DOS_CLOSE	; close file
       		;jp nc, 0        	; reset if close failed (change into something better!!!)       
       		call DOS_MOTOR_OFF	; disconnect drive motor

        call wait_for_side2

set_ram_paging:
		ld b, $10		; RAM 0, ROM 2 (48k BASIC)
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



filename_check: db "IANNA.DAT",$ff
message: db 16,7,17,0,22,20,2,  "INSERT DISC SIDE 2,", $ff
message2: db 16,7,17,0,22,21,1,"PRESS KEY TO CONTINUE", $ff
select              equ  01601h    ;BASIC routine to open stream

wait_for_side2:
   		ld b, 7         ; RAM 7, ROM 3 (+3DOS)
   		call setrambank
   		ld hl, filename_check ; 
   		ld bc, $0001    	; File handle 0, exclusive read
   		ld de, $0002	; Open, place pointer after  header
   		call DOS_OPEN	; open file
   		jr nc, wait_for_side2_waitkey ; print message and wait for key
   		ld b, 0
   		call DOS_CLOSE	; close file
   		call DOS_MOTOR_OFF	; disconnect drive motor            
        ret

wait_for_side2_waitkey:
		ld b, $10		; RAM 0, ROM 2 (48k BASIC)
		call setrambank
		LD IY, 5C3Ah		; re-establish the IY pointer (must be done!)
        ld   a,2
        call select              ;BASIC ROM routine to open stream (A)
        ld   hl,message
        call print               ;print a message
        ld hl, message2
        call print

        ld hl,23560         ; LAST K system variable.
        ld (hl),0           ; put null value there.
waitkey_loop:
        ld a,(hl)           ; new value of LAST K.
        cp 0                ; is it still zero?
        jr z, waitkey_loop  
        jr wait_for_side2        

print:
     ld   a,(hl)              ;this just loops printing characters
     cp   0FFh                ;until if finds FFh
     ret  z
     rst  10h                 ;with 48K ROM in, this will print char in A
     inc  hl
     jr   print




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

; INPUT: B: page to set 
setrambank:
       di
       ld A, ($5B5C)
       and $E8
       or b
       ld BC, $7FFD
       ld ($5b5c), a   ; save in the BASIC variable
       out (c), a
       ei
       ret

loader_table   dw 0
loader_file    dw 0
destination_address dw 0

ianna_str	db "IANNA.GAM",$ff


loader_table_ianna:
	db 4		; 4 entries

	dw 32768	; load at 32768   (loading.scr)
	dw 6912		; load 6912 bytes
	dw 16384	; after loading, copy to 16384
	db $00		; RAM Bank 0, not compressed
	
	dw 32768	; load at 32768   (ram3.bin)
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

