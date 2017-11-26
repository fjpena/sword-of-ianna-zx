; Generic I/O for ESXDOS

INCLUDE "unodos.api"

level_offset:   dw 0		; level 1
	        	dw 10853	; level 2
            	dw 22976	; level 3
            	dw 35140	; level 4
		        dw 47825	; level 5
		        dw 62181	; level 6
		        dw 0		; level 7  (file 2)
		        dw 11783	; level 8  (file 2)
		        dw 23899	; level 0 (attract mode, file 2)	
				dw 27825	; level 9 (easter egg)

level_size: dw 10853	; level 1
            dw 12123	; level 2
        	dw 12164	; level 3
            dw 12685	; level 4
        	dw 14356    ; level 5
        	dw 13925	; level 6
        	dw 11783	; level 7
        	dw 12116	; level 8
        	dw 3926		; level 0 (attract mode)
			dw 8662		; level 9 (easter egg)

sprite_offset:	dw 0		; skeleton
				dw 2193		; orc
				dw 4216		; mummy
				dw 6441		; troll
				dw 8753		; rock
				dw 9252		; knight
				dw 11707	; dal gurak
				dw 14327	; golem
				dw 16813	; ogre
				dw 18999	; minotaur
				dw 21185	; demon
				dw 23309	; golem - sup
				dw 24590	; ogre - sup
				dw 25905	; minotaur - sup
				dw 27671	; demon - sup

sprite_size:	dw 2193		; skeleton
				dw 2023		; orc
				dw 2225		; mummy
				dw 2312		; troll
				dw 499		; rock
				dw 2455		; knight
				dw 2620		; dal gurak
				dw 2486		; golem
				dw 2186		; ogre
				dw 2186		; minotaur
				dw 2124		; demon
				dw 1281		; golem - sup
				dw 1315		; ogre - sup
				dw 1766		; minotaur - sup
				dw 1091		; demon - sup


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
	cp 6
	jr c, IO_LoadLevel_file1
	ld ix, filename_2
	jr IO_LoadLevel_common
IO_LoadLevel_file1:
	ld ix, filename
IO_LoadLevel_common:
	ld hl, level_offset
	add a, a
	ld e, a
	ld d, 0
	add hl, de		; hl points to the offset
	ld c, (hl)
	inc hl
	ld b, (hl)		; BC holds the offset to load
	ld hl, level_size
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)		; DE holds the size
	ld hl, $C000		; load at $C000
	ld a, 1			; and store in RAMBank1
	call IO_Load
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
	ld hl, sprite_offset
	add a, a
	ld e, a
	ld d, 0
	add hl, de		; hl points to the offset
	ld c, (hl)
	inc hl
	ld b, (hl)		; BC holds the offset to load
	ld hl, sprite_size
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)		; DE holds the size
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
	ld hl, intro_data
	add a, a
	add a, a			; A*4, to offset
	ld e, a
	ld d, 0
	add hl, de		; hl points to the offset
	ld c, (hl)
	inc hl
	ld b, (hl)		; BC: offset in file
	inc hl
	ld e, (hl)
	inc hl
	ld d, (hl)		; DE: number of bytes to load
	xor a			; Page 0
	ld hl, $AC80	; buffer
	ld ix, filename_intro
	call IO_Load
	ret 


; Load intro music 
; Will *always* place stuff in RAM page 3, address $CC00
; INPUT:
;	- A: music to load (for now, just 4)
IO_LoadIntroMusic:
	ld hl, intro_data
	add a, a
	add a, a			; A*4, to offset
	ld e, a
	ld d, 0
	add hl, de		; hl points to the offset
	ld c, (hl)
	inc hl
	ld b, (hl)		; BC: offset in file
	inc hl
	ld e, (hl)
	inc hl
	ld d, (hl)		; DE: number of bytes to load
	ld a, 3			; Page 3
	ld hl, $CB72	; buffer
	ld ix, filename_intro
	jp IO_Load



; Set the proper environment for ESXDOS

previous_rambank: db 0
filename:     db "ianna.dat",0
filename_2:   db "ianna2.dat",0
filename_spr: db "ianna.spr",0
filename_intro: db "intro.bin",0

DOS_Setenv:
    ld a, ($5B5C)
    ld (previous_rambank), a
	LD IY, 5C3Ah		; re-establish the IY pointer (just in case)
	ret

; Restore the previous environment
; This means: IM2, previous RAM bank and screen

DOS_RestoreEnv:
	di
	ld a, (previous_rambank)
	ld b, a
	call setrambank
	ei
	ret

; Load from ESXDOS file
; INPUT:
;	- HL: destination
;	- A:  page for destination
;	- DE: number of bytes to load
;	- BC: offset in file
;   - IX: filename
esxdos_filehandle: db 0

IO_Load:
	push hl
	push de
	push af
	push bc
	call DOS_Setenv

    ld a, '*'       ; Default drive
	ld b, fa_read
	rst $08
	db f_open       ; Open file
	jp c,0          ; reset if open failed (change into something better!!!)
	ld (esxdos_filehandle), a


	; go to offset
	pop bc

    ld d, b
    ld e, c
    ld bc, 0    ; WARNING: this is only allowing up to 64K file offsets. If we need more than that, redesign it!
    ld ixl, 0   ; seek from start of file
    rst $08
    db f_seek
	jp c,0          ; reset if seek failed (change into something better!!!)

	pop af

	di
	ld b, a
	call setrambank
	ei

	pop bc		; BC = number of bytes to load
	pop ix		; destination
	ld a, (esxdos_filehandle)
	rst $08
    db f_read


	ld a, (esxdos_filehandle)
	rst $08
	db f_close

	call DOS_RestoreEnv
	ret

