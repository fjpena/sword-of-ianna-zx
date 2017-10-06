DOS_EST_1346    equ $13F
DOS_OPEN        equ $106
DOS_READ        equ $112
DOS_CLOSE       equ $109
DOS_REF_XDPB    equ $151
DD_LOGIN        equ $175
DD_READ_SECTOR  equ $163
DD_L_OFF_MOTOR  equ $19c

org 24000

load_1:		
start:
		; start by setting black border, black ink, black paper
		xor a
		out ($fe), a
		ld hl, 16384
		ld (hl), 0
		ld de, 16384+1
		ld bc, 6911
		ldir			; clean shadow screen

       		ld b, 7         ; RAM 7, ROM 3 (+3DOS)
       		call setrambank
deact_ramdisk:
       		ld hl, $0000
       		ld de, $0000
       		call DOS_EST_1346
       		JP NC, 0        ; reset if failed

open_disk:
		ld a, 'A'               ; drive A
        	call DOS_REF_XDPB       ; make IX point to XDPB A: (necessary for calling DD routines)
        	jp nc, 0                ; reset if failed
        	ld c, 0
        	push ix
        	call DD_LOGIN           ; log in disk in unit 0
        	pop ix
        	jp nc, 0                ; reset if failed

start_load:    	ld hl, loader_table
	        ld b, (hl)		; b==iteratons
		inc hl
load_loop:
		push bc

		ld e, (hl)		
		inc hl
		ld d, (hl)
		ld (load_address), de
		inc hl			; ix==load address, hl== address of unit

		ld b, 0		; ram 0 in $C000
		ld c, 0		; unit 0
		ld d, (hl)	; track number
		inc hl
		ld e, (hl)	; sector number
		inc hl
		ld a, (hl)	
		ld (number_of_sectors), a ; number of sectors
		inc hl

		ld a, (hl)		
		ld (destination_address), a
		inc hl
		ld a, (hl)		; destination_address ==store address
		ld (destination_address+1), a
		inc hl
		ld a, (hl)		; C == RAM BANK & compressed -> compressed not used in this game
		ld (bankcomp), a

		push hl
		ld hl, (load_address)
read_loop:
		push bc
		push de
		push hl
		push ix
        	call DD_READ_SECTOR
        	pop ix
        	jp nc, 0                ; reset if failed
        	pop hl
        	ld de, 512
        	add hl, de              ; next sector
        	pop de
        	pop bc
	        inc e	
        	ld a, e
        	cp 9
        	jr nz, no_inc_track
		inc d
		ld e, 0
no_inc_track:
		ld a, (number_of_sectors)
		dec a
		ld (number_of_sectors), a
		jr nz, read_loop
read_finished:
		
		ld a, (bankcomp)
		and $07			
                ld b, a
                call setrambank      ; set RAM BANK 


not_compressed:	; block is not compressed
		ld hl, (load_address)
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
       		call DD_L_OFF_MOTOR     ; stop motor

set_ram_paging:
		ld b, $10		; RAM 0, ROM 2 (48k BASIC)
		call setrambank


launch_program: pop hl			; get the execution address
		LD IY, 5C3Ah		; re-establish the IY pointer (must be done!)
		jp (hl)			; and run!



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


destination_address dw 0
load_address: dw 0
number_of_sectors: db 0
bankcomp: db 0

loader_table:
	db 3		; 4 entries
	
	dw 32768	; load at 32768 (cedmus.bin)
	db 0		; track
	db 2		; sector
	db 32		; number of sectors to load (512 bytes/sector)
	dw 49152	; after loading, copy to 49152
	db $03		; RAM Bank 3, not compressed
	
	dw 32768	; load at 32768 (menu.bin)
	db 3		; track
	db 7		; sector
	db 21		; number of sectors to load (512 bytes/sector)
	dw 49152	; after loading, copy to 49152
	db $06		; RAM Bank 6, not compressed

	dw 24576	; load at 24576
	db 6		; track
	db 1		; sector
	db 79		; number of sectors to load (512 bytes/sector)
	dw 24576	; after loading, copy to 24576
	db $00		; RAM Bank 0, not compressed

	dw 24576	; randomize usr 24576
	
