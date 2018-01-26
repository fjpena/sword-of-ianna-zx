; I/O for Alberto Villena's Kartusho v4 cartridge

; Per-level data:  ROM page (db), offset (dw), size (dw)
level_page: db 6, 7, 8, 9, 10, 11, 12, 13, 6, 15

level_data: dw     0, 10853		; level 1
			dw     0, 12123		; level 2
			dw     0, 12164		; level 3
			dw     0, 12685		; level 4
			dw     0, 14356		; level 5
			dw     0, 13925		; level 6
			dw     0, 11783		; level 7
			dw     0, 12116		; level 8
			dw 10853,  3926		; level 0 (attract mode)
			dw	   0,  8662		; level 9 (easter egg)

; Per-sprite data: ROM page (db), offset (dw), size (dw)
sprite_page: db 5, 5, 5, 5, 5, 5, 5, 14, 14, 14, 14, 14, 14, 14, 14

sprite_data:	dw     0, 2193	; skeleton
				dw  2193, 2023	; orc
				dw  4216, 2225	; mummy
				dw  6441, 2312	; troll
				dw  8753,  499	; rock
				dw  9252, 2455	; knight
				dw 11707, 2620	; dal gurak
    			dw     0, 2486		; golem
    			dw  2486, 2186		; ogre
	    		dw  4672, 2186		; minotaur
	    		dw  6858, 2124		; demon
	    		dw  8982, 1281	    ; golem - sup
	    		dw 10263, 1315		; ogre - sup
	        	dw 11578, 1766		; minotaur - sup
			    dw 13344, 1091		; demon - sup

INTRO_ROM_PAGE: EQU 16

intro_data: dw    0, 1498	; intro - frame
			dw 1498, 4131	; intro - screens
			dw 5629, 3082	; end - screens
			dw 8711, 1814	; end - credits
			dw 10525, 2630  ; music - intro
			dw 13155, 2052	; music - end
			dw 15207, 462	; music - credits


; Load level from disk
; Will *always* place stuff in RAM Page 1, at $c000
; INPUT:
;	- A: level to load

IO_LoadLevel:
    push af
	ld hl, level_data
	add a, a
	add a, a		; A*4, to offset
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
	pop af
    push de         ; save size
	ld hl, level_page
	ld e, a
	ld d, 0
	add hl, de      
    pop de          ; restore size
	ld a, (hl)
	ld ixl, a		; IXl holds the ROM page
	ld hl, $C000		; load at $C000
	ld a, 1			; and store in RAMBank1
	jp IO_Load
;	call IO_Load
;	ret


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
	ld ixl, INTRO_ROM_PAGE
	jp IO_Load
;	call IO_Load
;	ret

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
	ld a, 3			; Page 0
	ld hl, $CB72	; buffer
	ld ixl, INTRO_ROM_PAGE
	jp IO_Load



; Load sprite from disk
; Will *always* place stuff in RAM page 4
; INPUT:
;	- A: sprite to load
;   - (current_spraddr): where to load
;
; RETURNS:
;	- BC: number of bytes loaded

IO_LoadSprite:
	push af
	ld hl, sprite_data
	add a, a
	add a, a		; A*4, to offset
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
	pop af
    push de
	ld hl, sprite_page
	ld e, a
	ld d, 0
	add hl, de
    pop de
	ld a, (hl)
	ld ixl, a		; IXl holds the ROM page
	ld hl, (current_spraddr)		; load address
	ld a, 4			; and store in RAMBank4
	push de
	call IO_Load
	pop bc
	ret


; Load from cartridge
; INPUT:
;	- HL: destination
;	- A:  page for destination
;	- DE: number of bytes to load
;	- BC: offset in file
;	- IXl: ROM page

IO_Load:
	push hl
	push de
	push bc
	push ix
	push af		; save level
    call CART_Setenv
    pop af
	; set RAM page
	ld b, a
	call setrambank
	; set ROM page
	pop ix
	ld a, ixl
	call IF2_SetROM
	; prepare to LDIR
	pop hl	; HL = source (offset in page)
	pop bc	; BC = number of bytes to load
	pop de	; DE = destination
	ldir
	jp CART_RestoreEnv
;    call CART_RestoreEnv
;	ret



; Set the proper environment for Cartridge
; This means: Interrupts disabled, save previous RAM bank

previous_rambank: db 0

CART_Setenv:
    di
    ld A, ($5B5C)
    ld (previous_rambank), a
	ret

; Restore the previous environment
; This means: Interrupts enabled, previous RAM bank

CART_RestoreEnv:
	ld a, (previous_rambank)
	ld b, a
	call setrambank
	ei
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

