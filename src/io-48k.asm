; I/O for dandare's cartridge on a ZX 48K

; Per-level data:  ROM page + 1(db), offset (dw), size (dw)
level_page: db 5, 6, 7, 8, 9, 10, 11, 12, 13, 14

;level_data: dw    0, 10853		; level 1
;			dw     0, 12123		; level 2
;			dw     0, 12164		; level 3
;			dw     0, 12685		; level 4
;			dw     0, 14356		; level 5
;			dw     0, 13925		; level 6
;			dw     0, 11783		; level 7
;			dw     0, 12116		; level 8
;			dw 	   0,  3926		; level 0 (attract mode)
;			dw	   0,  8662		; level 9 (easter egg)

; Per-sprite data: ROM page + 1(db), offset (dw), size (dw)
sprite_page: db 7, 9, 12, 14, 5, 14, 14, 6, 8, 11, 11, 8, 10, 6, 10

sprite_data:	dw 12164	;, 2193	;0  skeleton
				dw 14356	;, 2023	;1 orc				
				dw 12116	;, 2225	;2 mummy
				dw 13737	;, 2312	;3 troll
				dw 10853	;,  499	;4 rock
				dw  8662	;, 2455	;5 knight
				dw 11117	;, 2620	;6 dal gurak
    			dw 12123	;, 2486		;7 golem			
    			dw 12685	;, 2186		;8 ogre				
	    		dw 11783	;, 2186		;9 minotaur			
	    		dw 13969	;, 2124		;A demon			
	    		dw 14871	;, 1281	    ;B golem - sup		
	    		dw 13925	;, 1315		;C ogre - sup		
	        	dw 14609	;, 1766		;D minotaur - sup	
			    dw 15240	;, 1091		;E demon - sup		

INTRO_ROM_PAGE: EQU 3
intro_data: dw    0, 1498	; intro - frame
			dw 1498, 4131	; intro - screens
			dw 5629, 3082	; end - screens
			dw 8711, 1814	; end - credits
;			dw 10525, 2630  ; music - intro
;			dw 13155, 2052	; music - end
;			dw 15207, 462	; music - credits

;music_page:
;			db 1,1,1,1,1,1,1,1,1,1		;todas las melodias en pagina 1 ahorramos 10bytes :)
music_data:
			dw  12288,	56			;0 Music death
			dw  12344,	758			;1 Music Menu

			dw 	13102,	149			;2 Music intro P0
			dw 	13251,	149			;3 Music intro P1
			dw 	13400,	149			;4 Music intro P2
			dw 	13549,	149			;5 Music intro P3
			dw 	13698,	143			;6 Music intro P4

			dw 	13102,	149			;7 Music Intro0 P0
			dw 	13841,	137			;8 Music End P1
			dw 	13978,	134			;9 Music End P2


; Load level 
; Will only modify the rom number for bank 1, where the level start at $0000
; INPUT:
;	- A: level to load

IO_LoadLevel:
	ld hl, level_page
	ld e, a
	ld d, 0
	add hl, de      
	ld a, (I.MLDoffset2)
	ld c, (hl)
	add a, c
	ld (romatbank1), a
	ret		
	
; Load intro screen pack
; Will *always* place stuff in RAM page 0 on a 48k ;)
; it will load from ROM so no need to buffer on screen
; INPUT:
;	- A: screen pack to load
;	. HL: address where to load
; 
IO_LoadIntro:
	push hl					;guardamos la direccion donde cargar
	ld hl, intro_data
	add a, a
	add a, a				; A*4, to offset
	ld e, a
	ld d, 0
	add hl, de				; hl points to the offset
	ld c, (hl)
	inc hl
	ld b, (hl)				; BC: offset in file
	inc hl
	ld e, (hl)
	inc hl
	ld d, (hl)				; DE: number of bytes to load
	ld a, (I.MLDoffset2)	;A= differencia del cartucho con el MLD
	ld l, a					;lo pasamos a L
	ld a, INTRO_ROM_PAGE	;A = MLD page con la INTRO		
	add a, l				;lo sumamos y queda en A la pagina del cartucho con la Intro
	pop hl					;recuperamos la direccion donde cargar en HL
	jp IO_Load				;con BC, DE y HL y A


;place rom for music and return hl as music address
;will load the music at $F780
;IMPUT: 
;	-A Music to load
;RETURN:

IO_LoadMusic:
	push af
    call CART_Setenv	;save the actual rom paged for later restore
;	ld hl, music_page	;rom pages for the Music
;	add hl, de			;hl has the rom for the music we want
	ld a, (I.MLDoffset2);take the offsed for MLD roms
	inc a				;todas las musicas estan en la rom 1   <<<<<<<<<<<
;	ld b, a				;store it on b
;	ld a, (hl)			;take the page rom for the Music we want to load
;	add a, b			;add the offset with the MLD
	call I.enviacomandosimple	;page the rom
	pop af
	ld hl, music_data	;list with the address offset and sizes of the Musics
	add a, a			;we multiply A*2 
	add a, a			;we multiply A*4 
	ld e, a				;we place the list offset on DE
	ld d, 0
	add hl, de			;now HL points to the offset of the music we want to load
	ld e, (hl)
	inc hl
	ld d, (hl)			;DE now have the source address of the music
	inc hl
	ld c, (hl)
	inc hl
	ld b, (hl)			;BC has the size
	ex de, hl			;change the source to HL
	ld de, $F780		;and put the destination on DE
	ldir				;copy it to memory
	jp CART_RestoreEnv	;restore the previous rom page and return


; Load sprite from ROM
; Will place stuff in RAM page 0
; INPUT:
;	- A: sprite to load
;   - DE: where to uncompress
;
; RETURNS:
;	
IO_LoadSprite:
	push de				;save destination
	ld e, a				;place the sprite number on DE
	ld d, 0
	push af				;save sprite
	push de
    call CART_Setenv	;save the actual rom paged for later restore
	ld hl, sprite_page	;rom pages for the sprites
	pop de
	add hl, de
	ld a, (I.MLDoffset2)	;take the offsed for MLD roms
	ld e, a				
	ld a, (hl)			;take the page rom for the sprite to load
	add a, e			;add the offset with the MLD
	call I.enviacomandosimple		;page the rom
	pop af				;recover the sprite to load
	ld hl, sprite_data	;list wih the offset of the sprites
	add a, a			;we multiply A*2 
	ld e, a				;we place the list offset on DE, as D was not touched and value is still 0
	add hl, de			;now HL points to the offset
	ld e, (hl)
	inc hl
	ld d, (hl)			;DE now have the source address
	ex de, hl			;change it to HL
	pop de				;recover the destination from Stack
	call depack			;descomprimos en ram
	jp CART_RestoreEnv	;restore the previous rom paged and return


; Load from cartridge
; INPUT:
;	- HL: destination
;	- DE: number of bytes to load
;	- BC: offset in file
;	- A: ROM page (+1)

IO_Load:
	push hl
	push de
	push bc
	push af
    call CART_Setenv
	; set ROM page
	pop af
	call I.enviacomandosimple
	; prepare to LDIR
	pop hl	; HL = source (offset in page)
	pop bc	; BC = number of bytes to load
	pop de	; DE = destination
	ldir
	jp CART_RestoreEnv


; Set the proper environment for Cartridge
; This means: Interrupts disabled, save previous ROM bank

previous_rambank: db 0

CART_Setenv:
    di
    ld A, (rombank)
    ld (previous_rambank), a
	ret

; Restore the previous environment
; This means: Interrupts enabled, previous ROM bank

CART_RestoreEnv:
	ld a, (previous_rambank)
	ld b, a
	call setrambank
	ei
	ret

IO_LoadPrefs:
	    call CART_Setenv
		ld a, (I.romsectorgrabar)
		call I.enviacomandosimple
		ld hl, (I.hlsectorgrabar)
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
		ld hl, 16384
		call I.SAVEPREFS
	    jp CART_RestoreEnv

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

