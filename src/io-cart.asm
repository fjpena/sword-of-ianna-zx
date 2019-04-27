; I/O for dandare's cartridge
MLDoffset2:		EQU 23808
sectorgrabar	EQU	23809
romsectorgrabar	EQU	23810
hlsectorgrabar	EQU	23811
SAVEPREFS 		EQU 23813
enviacomandosimple:	equ 23873

; Per-level data:  ROM page + 1(db), offset (dw), size (dw)
level_page: db 5, 6, 7, 8, 9, 10, 11, 12, 13, 14

level_data: dw     0, 10853		; level 1
			dw     0, 12123		; level 2
			dw     0, 12164		; level 3
			dw     0, 12685		; level 4
			dw     0, 14356		; level 5
			dw     0, 13925		; level 6
			dw     0, 11783		; level 7
			dw     0, 12116		; level 8
			dw 	   0,  3926		; level 0 (attract mode)
			dw	   0,  8662		; level 9 (easter egg)

; Per-sprite data: ROM page + 1(db), offset (dw), size (dw)
sprite_page: db 7, 9, 12, 14, 5, 14, 14, 6, 8, 11, 11, 8, 10, 6, 10

sprite_data:	dw 12164, 2193	;0  skeleton
				dw 14356, 2023	;1 orc				
				dw 12116, 2225	;2 mummy
				dw 13737, 2312	;3 troll
				dw 10853,  499	;4 rock
				dw  8662, 2455	;5 knight
				dw 11117, 2620	;6 dal gurak
    			dw 12123, 2486		;7 golem			
    			dw 12685, 2186		;8 ogre				
	    		dw 11783, 2186		;9 minotaur			
	    		dw 13969, 2124		;A demon			
	    		dw 14871, 1281	    ;B golem - sup		
	    		dw 13925, 1315		;C ogre - sup		
	        	dw 14609, 1766		;D minotaur - sup	
			    dw 15240, 1091		;E demon - sup		

INTRO_ROM_PAGE: EQU 3
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
	call ixlconde												;<<<<<<<<<<<<<<<<<<<<<
    pop de          ; restore size
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
	call ixlintro				;<<<<<<<<<<<<<<<
	ld hl, $AC80	; buffer
	xor a			; Page 0
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
	call ixlintro				;<<<<<<<<<<<<<<<
	ld hl, $CB72	; buffer
	ld a, 3			; Page 3
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
	call ixlconde										;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    pop de
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
;	- IXl: ROM page (+1)

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
	call SENDNRCMD
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

; ----------------------------------------------------------------------------------------
; Send Normal Command to Dandanator - Sends Command/Data
;     A  = Cmd/Data, 
;	 
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
			LD (1),A					; Send Pulse (Zesarux recognizes addr 1 as command)
			DJNZ NRCMDLOOP
			LD B, PAUSELOOPSN			; Timeout Command/Data
WAITXCMD:	DJNZ WAITXCMD				
			RET							
; ----------------------------------------------------------------------------------------			
PAUSELOOPSN EQU 40						; 40 is recognized by all firmwares. 10 is faster but only work from 6.4 onwards

IO_LoadPrefs:
	    call CART_Setenv
		call selectromsector
		ld hl, (hlsectorgrabar)
		ld de, 16384
		ld bc, 14
		ldir				; load prefs
		call prefs_cksum
		ld c, a
		ld a, (16384+13)
		cp c
		jr nz, LoadPrefs_exit				; if the checksum isn't valid, just ignore
		ld a, (16384)
		ld (language), a
		ld hl, 16385
		ld de, key_defs
		ld bc, 12
		ldir
LoadPrefs_exit:
		jp CART_RestoreEnv
		nop
		nop
;	    call CART_RestoreEnv
;		ret
	
; Save preferences (language and redefined keys)
; We will use the screen as buffer, we do not have space anywhere else!	
IO_SavePrefs:
		ld a, (changed_settings)
		and a
		ret z	; do not save if no changes were made
		ld de, 16384
		ld a, (language)
		ld (de), a
		inc de
		ld hl, key_defs
		ld bc, 12
		ldir
		; calculate checksum, so we can skip loading them if wrong
		call prefs_cksum
		ld (de), a
	    call CART_Setenv
;		ld a, 19			; slot where the code is located
;		call SENDNRCMD
		ld hl, 16384
		call SAVEPREFS
	    jp CART_RestoreEnv
;	    call CART_RestoreEnv
;		ret

selectromsector
	ld a, (romsectorgrabar)
	jr SENDNRCMD


; Calculate checksum of the preferences, return in A

prefs_cksum:
		ld hl, 16384
		ld b, 12
		ld a, (hl)
cksum_loop:
		inc hl
		add a, (hl)
		djnz cksum_loop
		inc a				; We add all values and then add 1, to avoid a list of zeros being a valid checksum
		ret
;		nop
;	display "total bytes ",/d, $-level_page

ixlconde
	ld a, (MLDoffset2)
	ld d, a
	ld a, (hl)
	add a, d
ixlend
	ld ixl, a		; IXl holds the ROM page +1
	ret

ixlintro
	ld a, (MLDoffset2)
	ld l, a
	ld a, INTRO_ROM_PAGE
	add a, l
	jr ixlend
	nop
	
