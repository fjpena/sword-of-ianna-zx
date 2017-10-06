; Generic I/O

level_data:     dw     0, 10848		; level 1
	        	dw 10848, 12123	; level 2
            	dw 22971, 12159	; level 3
            	dw 35130, 12685	; level 4
		        dw 47815, 14356	; level 5
		        dw 62171, 13925	; level 6
		        dw     0, 11783	; level 7  (file 2)
		        dw 11783, 12116	; level 8  (file 2)
		        dw 23899,  3926	; level 0 (attract mode, file 2)	
				dw 27825,  8662	; level 9 (easter egg)


sprite_data:	dw     0, 2193	; skeleton
				dw  2193, 2023	; orc
				dw  4216, 2225	; mummy
				dw  6441, 2312	; troll
				dw  8753,  499	; rock
				dw  9252, 2455	; knight
				dw 11707, 2620	; dal gurak
				dw 14327, 2486	; golem
				dw 16813, 2186	; ogre
				dw 18999, 2186	; minotaur
				dw 21185, 2124	; demon
				dw 23309, 1281	; golem - sup
				dw 24590, 1315	; ogre - sup
				dw 25905, 1766	; minotaur - sup
				dw 27671, 1091	; demon - sup

intro_data: dw    0, 1498	; intro - frame
			dw 1498, 4131	; intro - screens
			dw 5629, 3082	; end - screens
			dw 8711, 1814; end - credits
			dw 10525, 2630  ; music - intro
			dw 13155, 2052	; music - end
			dw 15207, 462	; music - credits

; Load level from disk
; Will *always* place stuff in RAM Page 1, at $c000
; INPUT:
;	- A: level to load

IO_LoadLevel:
    call IO_loading
	cp 6
	jr c, IO_LoadLevel_file1
	ld ix, filename_2
	jr IO_LoadLevel_common
IO_LoadLevel_file1:
	ld ix, filename
IO_LoadLevel_common:
	ld hl, level_data
	call IO_getdata
	ld hl, $C000		; load at $C000
	ld a, 1			; and store in RAMBank1
;	call IO_Load
;	ret 
	jp IO_Load


IO_getdata:
	add a, a
	add a, a
	ld e, a
	ld d, 0
	add hl, de		; hl points to the offset
	ld c, (hl)
	inc hl
	ld b, (hl)		; BC holds the offset to load
	inc hl
	ld e, (hl)
	inc hl
	ld d, (hl)		; DE holds the size
	ret

; Print a string on screen, not controlling line breaks
; INPUT:
;	IY: pointer to string
;	B: X in chars
;	C: Y in chars
print_string_3dos:
	ld a, (iy+0)
	and a
	ret z		; return on NULL
	push iy
	push bc
	call print_char
	pop bc
	pop iy
	inc iy
	inc b
	jr nz, print_string_3dos
	ret	

; Load sprite from disk
; Will *always* place stuff in RAM page 4
; INPUT:
;	- A: sprite to load
;   - (current_spraddr): where to load
;
; RETURNS:
;	- BC: number of bytes loaded

IO_LoadSprite:
	ld hl, sprite_data
	call IO_getdata
	ld hl, (current_spraddr)		; load address
	ld a, 4			; and store in RAMBank4
	ld ix, filename_spr
	push de
	call IO_Load
	pop bc
	ret 


; Load intro screen pack from from disk
; Will *always* place stuff in RAM page 0, address $AC80
; INPUT:
;	- A: screen pack to load

IO_LoadIntro:
    call IO_loading
	ld hl, intro_data
	call IO_getdata
	xor a			; Page 0
	ld hl, $AC80	; buffer
	ld ix, filename_intro
	jp IO_Load
;	call IO_Load
;	ret 


; Load intro music 
; Will *always* place stuff in RAM page 3, address $CC00
; INPUT:
;	- A: music to load (for now, just 4)
IO_LoadIntroMusic:
    call IO_loading
	ld hl, intro_data
	call IO_getdata
	ld a, 3			; Page 3
	ld hl, $CB72	; buffer
	ld ix, filename_intro
	jp IO_Load
	

loading_string_en: db "LOADING...",0
loading_string:    db "CARGANDO...",0

IO_loading:
    push af
	ld a, (language)
	and a
	jr z, IO_loading_spanish
    ld iy, loading_string_en
	jr IO_loading_common
IO_loading_spanish:
    ld iy, loading_string
IO_loading_common:
    ld bc, $0B0C
    call print_string_3dos
    ld a, 7
    ld hl, 16384+6144+12*32+11
    ld de, 16384+6144+12*32+11+1
    ld (hl), a
    ld bc, 10
    ldir
    pop af
    ret

; Input/output functions for +3DOS, using plain files
; +3DOS constants
DOS_EST_1346 	equ $13F
DOS_OPEN 	equ $106
DOS_READ 	equ $112
DOS_CLOSE	equ $109
DOS_MOTOR_OFF	equ $19c
DOS_EST_POS	equ $136

; Set the proper environment for +3DOS
; This means: IM1, RAM7, save previous RAM bank

previous_rambank: db 0
filename:       db "IANNA.DAT",$ff
filename_2:     db "IANNA2.DAT",$ff
filename_spr: db "IANNA.SPR",$ff
filename_intro: db "INTRO.BIN",$ff

DOS_Setenv:
        ld A, ($5B5C)
        ld (previous_rambank), a
        di
	ld b, 7
	call setrambank_p3
	im 1	
	LD IY, 5C3Ah		; re-establish the IY pointer (must be done!)
	ei
	ret

; Restore the previous environment
; This means: IM2, previous RAM bank and screen

DOS_RestoreEnv:
	di
	ld a, (previous_rambank)
	ld b, a
	call setrambank_p3
	ei
	ld a, 0xbf
	ld hl, 0x8000	
	ld de, ISR
;	call SetIM2
;	ret
	jp SetIM2

; Load from +3 file
; INPUT:
;	- HL: destination
;	- A:  page for destination
;	- DE: number of bytes to load
;	- BC: offset in file
;   - IX: filename

IO_Load:
	push hl
	push de
	push af
	push bc

	call DOS_Setenv
	ld hl, $0000
	ld de, $0000
	call DOS_EST_1346
	JP NC, 0        ; reset if failed

	push ix
	pop hl		    ; file name
	ld bc, $0001    ; File handle 0, exclusive read
	ld de, $0002	; Open, place pointer after  header
	call DOS_OPEN	; open file
	jp nc, 0        	; reset if open failed (change into something better!!!)
	
	; go to offset
	pop bc
	ld h, b
	ld l, c
	ld e, 0		; WARNING: this is only allowing up to 64K file offsets. If we need more than that, redesign it!
	ld b, 0		; file descriptor 0
	call DOS_EST_POS
	JP NC, 0        ; reset if failed

	pop af
	ld c, a		; load to RAM BANK specified in A
	ld b, $00	; b=file descriptor 0
	pop de		; DE = number of bytes to load
	pop hl		; destination
       	call DOS_READ	; read bytes

	ld b, 0
   	call DOS_CLOSE	; close file
       	call DOS_MOTOR_OFF	; disconnect drive motor
	jp DOS_RestoreEnv

;	call DOS_RestoreEnv
;	ret

