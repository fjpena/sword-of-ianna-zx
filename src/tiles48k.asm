TILEMAP: EQU $AD00
TILEMAP_SUPERTILES: EQU CURRENT_SCREEN_MAP
SUPERTILE_DEF: EQU $B500	; supertile definitions: AB-CD, each being one tile
SUPERTILE_COLORS: EQU $B900	; supertile colors: AB-CD, each being one byte for the attribute
curscreen_animtiles:	EQU $BFA0


; Dirty tiles, needing to be restored with the background tile (192 bytes)
tiles_dirty:	EQU $BE00	; ends at $BEBF
ndirtyrects:	db 0

; Init tiles
; Initialize the dirty tiles area. Will just zero it out.
;
; Now each dirty rectangle will have a simple 4-byte schema:
;
; Byte 0: X char (min)
; Byte 1: Y char (min)
; Byte 2: X char (max)
; Byte 3: Y char (max)
;
; Potentially, we can have up to 48 dirty rectangles, so 48x4=192 bytes
 

InitTiles:
	ld hl, tiles_dirty
	ld bc, 191		; Just fill the whole structure with zeroes
	ld (hl), b
	ld de, tiles_dirty+1
	ldir

	ld hl, 16384
	ld (hl), l
	ld de, 16384+1
	ld bc, 6911
	ldir			; clean main screen

;	di
;	call setrambank7
;	ld hl, 49152
;	ld (hl), l
;	ld de, 49152+1
;	ld bc, 6911
;	ldir			; clean shadow screen
;	call setrambank0
;	ei

	xor a
	ld (ndirtyrects), a	; no dirty tiles.
	ret



; Draw initial screen from tile map
DrawScreen:
	xor a
	ld (ndirtyrects), a	; no dirty tiles.
	
	ld c, 20
drawsc_y_loop:
	ld b, 32
drawsc_x_loop:
	push bc
	exx
	pop bc
	call DrawTile_withattr
	exx
	djnz drawsc_x_loop
	dec c
	jr nz, drawsc_y_loop

	; Switch visible screen to the shadow one
;	di
;	call switchscreen
;	call setrambank7
;	ei

	; And copy the actual tiles
;	ld bc, 0
;	ld de, 32*256+24
;	call InvalidateTiles
;	call TransferDirtyTiles

	; Finally, switch again the visible screen
;	di
;	call switchscreen
;	call setrambank0
;	ei
	ret

; Set a tile attribute
;
; INPUT: 
;
;	B: x in char coords
;	C: y in char coords
;	E: attribute
SetAttribute:
	; BC = Y*32+X, to address the memory array
;	push bc										;11	no se altera no hay que guardalo
;	push de										;11 no se altera no hay que guardalo

;	ld a, c										; 4
;	rrca
;	rrca
;	rrca			; XXXYYYYY					; 12
;	ld c, a										; 4
;	and $E0										; 7
;	or b										; 4
;	ld b, a										; 4
;	ld a, c										; 4
;	and $1f										; 7
;	ld c, b										; 4
;	ld b, a										; 4. 54 rather than 103
;	ld hl, 16384+6144							; 10	attribute area in screen
;	add hl, bc									; 11 so HL points to the byte in the attribute area...
;												75 + 42 del push & pop

	ld a, c										;4
	and 7										;7
	rrca										;4
	rrca										;4
	rrca										;4	
	or b										;4
	ld l, a										;4
	ld a, c										;4
	and 24										;7
	rra											;4
	rra											;4
	rra											;4
	or 88										;7
	ld h,a										;4
;												65 ahorramos 52 t-states y 22 bytes



	ld (hl), e		; and the attribute is stored!
;	pop de										;10
;	pop bc										;10
	ret


; Draw a tile of a supertile anywhere on screen, including its attribute
;
; INPUT:
;	A: stile
;	E: offset (0-3)
;	B: x in char coords
;	C: y in char coords
DrawStile_tile:
	push af
	push bc
	push bc
	; The offset in the stile array is A*4+offset
	ld b, 0					;7
	rl a					;8
	rl b					;8
	rl a					;8
	rl b					;8
	add a, e				;4
	ld c, a					;4 BC has the offset
	;						;47
	ld hl, SUPERTILE_COLORS
	add hl, bc
	ld a, (hl)	; A has the attribute
;	ld (ATTRIBUTE), a	;ahorramos 7 t-states y 2 bytes usando A'
	ex af, af'			;' 
	
	ld hl, SUPERTILE_DEF
	add hl, bc
;	ld a, (hl)		;7	 A has the first tile number
;	ld c, a			;4
;	ld b, 0			;7
;	rl c			;8
;	rl b			;8
;	rl c			;8
;	rl b			;8
;	rl c			;8
;	rl b			;8 Tile number * 8 
;	ld hl, TILEMAP	;10
;	add hl, bc		;11 HL points to the first line of the tile
;	ex de, hl		;4 and save it in DE
;					91

	ld c, (hl)		;7 C has the first tile number
	ld b, 0			;7
	ld h, b			;4
	ld l, c			;4
	add hl, bc		;11 x2
	add hl, hl		;11 x4
	add hl, hl		;11 x8
	ld de, TILEMAP	;10
	add hl, de		;11 HL points to the first line of the tile
	ex de, hl		;4 and save it in DE
;					80	ahorramos 11 t-states y 3 Bytes
	pop bc
;	push bc			;con la nueva formula no lo vamos a volver a usar no hace falta guardarlo

	ld hl, TileScAddress	; address table
;	ld a, c			;4
;	add a,c			;4 C = 2*Y, to address the table
;	ld c,a			;4
	ld a, b			; A = X
	ld b, 0			; Clear B for the addition
	add hl, bc		;11 ahorramos 1 t-state y 2 bytes
	add hl, bc		; hl = address of the first tile
	ld c, (hl)
	inc l
	ld b, (hl)		; BC = Address
	ld l, a			; hl = X
	ld h, 0
	add hl, bc		; hl = tile address in video memory

	ld a, (de)
	ld (hl), a
	inc e			; can do INC E, since the TILES table will be aligned in memory
	inc h
	ld a, (de)
	ld (hl), a
	inc e
	inc h
	ld a, (de)
	ld (hl), a
	inc e
	inc h
	ld a, (de)
	ld (hl), a
	inc e
	inc h
	ld a, (de)
	ld (hl), a
	inc e
	inc h
	ld a, (de)
	ld (hl), a
	inc e
	inc h
	ld a, (de)
	ld (hl), a
	inc e
	inc h
	ld a, (de)
	ld (hl), a	; 8 bytes, go!
	
	; now look after the attribute
	
;	pop bc		; get X and Y back , ya no lo necesitamos vamos a calcular sobre HL


	; BC = Y*32+X, to address the memory array
;	rrc c
;	rrc c
;	rrc c			; XXXYYYYY					; 24
;	ld a, c										; 4
;	and $E0										; 7
;	or b										; 4
;	ld b, a										; 4
;	ld a, c										; 4
;	and $1f										; 7
;	ld c, b										; 4
;	ld b, a										; 4. 62 rather than 103

;	ld hl, 16384+6144							;10 attribute area in screen
;	add hl, bc									;11 so HL points to the byte in the attribute area...
;	ld a, (ATTRIBUTE)							;13
;												96

	ld a, h							;4 para calcular la direccion de attributos
	and %00011000					;7 solo necesitamos saber en que tercio de la pantalla está
	rra								;4 ya que L seguira igual
	rra								;4 hacemos AND 24 y rotamos los bits 3 y 4 hasta los bits 1 y 2
	rra								;4
	or $58							;7 y se lo sumamos a la direccion de inicio de atributos de pantalla
	ld h, a							;4 pasandolo a H, ahora HL tendra la direccion completa del atributo
	ex af, af'		;'				;4	recuperamos el atributo que guardamos al principio
;									38  rather than 96 :)

	ld (hl), a		; and the attribute is stored!
	pop bc
	pop af
	ret


; Draw a tile, including its attribute
;
; INPUT:
;	B: x tile + 1
;	C: y tile + 1
ATTRIBUTE:  db 0

DrawTile_withattr:
	ld a, c
	cp 21
	ret nc			; avoid drawing outside the lower border

	dec b
	dec c
	push bc			; Save X and Y

	; Find the offset in the stile array
	; It is (c and 1) * 2 + (b and 1)
	ld a, c
	and 1
	rlca
	ld c, a
	ld a, b
	and 1
	or c			; A has the offset
	ld e, a

	; First, find the stile number for this tile address
	; We will index the TILEMAP_SUPERTILES array with this formula: (c/2)*16 + b/2
	pop bc			; get X and Y back!
	push bc			; and save them, we will need them later yet one more time
	ld a, c
	rlca
	rlca
	rlca
	and $f0		; A has (c/2) * 16
	ld c, a		; (C/2) * 16
	ld a, b
	sra a		; a = b/2
	or c		; A now has the index in the TILEMAP_SUPERTILES array
	ld c, a
	ld b, 0
	ld hl, TILEMAP_SUPERTILES
	add hl, bc
	ld a, (hl)	; A == stile
	pop bc
	jp DrawStile_tile

; Copy individual tile from shadow to main screen
;
; INPUT:
;	B: x tile
;	C: y tile

;CopyTile:													;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;	push bc
;	ld hl, TileScAddress	; address table
;	ld a, c
;	add a,c			; C = 2*Y, to address the table
;	ld c,a
;	ld a, b			; A = X
;	ld b,0			; Clear B for the addition
;	add hl, bc		; hl = address of the first tile
;	ld c, (hl)
;	inc hl
;	ld b, (hl)		; BC = Address
;	ld l, a			; hl = X
;	ld h, 0
;	add hl, bc		; hl = tile address in shadow video memory

;	ld a, $80
;	add a, h		
;	ld d, a
;	ld e, l			; DE now points to the address in the actual video memory	

;	ld a, (hl)
;	ld (de), a
;	inc h
;	inc d
;	ld a, (hl)
;	ld (de), a
;	inc h
;	inc d
;	ld a, (hl)
;	ld (de), a
;	inc h
;	inc d
;	ld a, (hl)
;	ld (de), a
;	inc h
;	inc d
;	ld a, (hl)
;	ld (de), a
;	inc h
;	inc d
;	ld a, (hl)
;	ld (de), a
;	inc h
;	inc d
;	ld a, (hl)
;	ld (de), a
;	inc h
;	inc d
;	ld a, (hl)
;	ld (de), a
;	inc h
;	inc d			; 8 bytes, go!
;	pop bc

;	ld hl, 16384+6144	; start of the attribute area. We will need to address 32*C + B		; 10
;	rrc c
;	rrc c
;	rrc c			; XXXYYYYY						; 24
;	ld a, c										; 4
;	and $E0										; 7
;	or b										; 4
;	ld b, a										; 4
;	ld a, c										; 4
;	and $1f										; 7
;	ld c, b										; 4
;	ld b, a										; 4. 62 rather than 103
;	add hl, bc		; HL now points to the source attribute area				; 11
;	ld a, $80											; 7
;	add a, h											; 4
;	ld d, a												; 4
;	ld e, l			; DE now points to the address in the actual video memory		; 4
;	ld a, (hl)											; 7
;	ld (de), a		; and now copy the attribute						; 7. 116 more t-states per transferred tile

;	ret


; Invalidate tiles
; INPUT:
;	B: First tile to invalidate in X
;	C: First tile to invalidate in Y
;	D: Number of tiles to invalidate in X
;	E: Number of tiles to invalidate in Y

InvalidateTiles:
	push de
	ld a, (ndirtyrects)
	add a, a	
	add a, a		; a*4
	ld e, a
	ld d, 0
	ld hl, tiles_dirty
	add hl, de		; HL points to the dirty rectangle area
	pop de
	ld (hl), b
	inc l
	ld (hl), c	
	inc l
	ld (hl), d
	inc l
	ld (hl), e
	ld a, (ndirtyrects)
	inc a
	ld (ndirtyrects),a	; we now have one more dirty rect
	ret


; Redraw all invalidated tiles
; No input

RedrawInvTiles:
	ld a, (ndirtyrects)
	and a
	ret z			; no dirty tiles, just exit
	ld b, a
	ld hl, tiles_dirty 	; get the dirty tiles list
dirtyrectloop:
	push bc
	ld b, (hl)		; Xmin
	inc l				;esta alineado en memoria podemos hacer inc L y ahorramos 8 t-states
	ld c, (hl)		; Ymin
	inc l
	ld d, (hl)		; Xcount
	inc l
	ld e, (hl)		; Ycount
	inc l
	push hl			; save pointer

dirty_y_loop:
	push de
	push bc
dirty_x_loop:
	push bc
	exx
	pop bc
	inc b
	inc c
	call DrawTile_withattr	; FIXME if we change this to not "withattr", it is faster, but does not allow other stuff
	exx
	inc b
	dec d
	jr nz, dirty_x_loop
	pop bc
	pop de
	inc c
	dec e
	jr nz, dirty_y_loop	

	pop hl			; restore pointer to dirty rect list
	pop bc			; restore loop counter
	djnz dirtyrectloop	; loop!

	ret



; Transfer all dirty tiles from the shadow to the real screen
;
;	INPUT: none
;	OUTPUT: none

;TransferDirtyTiles:
;	ld a, (ndirtyrects)
;	and a
;	ret z			; no dirty tiles, just exit
;	ld b, a
;	ld hl, tiles_dirty 	; get the dirty tiles list
;dirtyrectloop_2:
;	push bc
;	ld b, (hl)		; Xmin
;	inc hl
;	ld c, (hl)		; Ymin
;	inc hl
;	ld d, (hl)		; Xcount
;	inc hl
;	ld e, (hl)		; Ycount
;	inc hl
;	push hl			; save pointer

;dirty_y_loop_2:
;	push de
;	push bc
;dirty_x_loop_2:
;;	push bc
;;	exx
;;	pop bc
;;	call CopyTile
;;	exx
;	inc b
;	dec d
;	jr nz, dirty_x_loop_2
;	pop bc
;	pop de
;	inc c
;	dec e
;	jr nz, dirty_y_loop_2	

;	pop hl			; restore pointer to dirty rect list
;	pop bc			; restore loop counter
;	djnz dirtyrectloop_2	; loop!

;	xor a
;	ld (ndirtyrects), a	; set dirtyrects number to 0
;	ret


; Get tile value for address X, Y (in tile form)
; INPUT:
; 	- B: X value
;	- C: Y value
; OUTPUT:
;	- A: stile value. If > 240, it is an animated tile and can be crossed, so it will return 0
;GetTile:
;	ld hl, TILEMAP_SUPERTILES	; need to get to HL + C*16 + B, and C is between 0 and 9
;	sla c
;	sla c
;	sla c
;	sla c		;C * 16
;	ld a, b
;	ld b, 0
;	add a, c
;	ld c, a		; C*16+b
;	add hl, bc
;	ld a, (hl)
;	cp 240
;	ret c
;	xor a
;	ret
	

; Go through the animation of animated stiles
; - INPUT: none
; - OUTPUT: none
AnimateSTiles:
	ld a, (curscreen_numanimtiles)
	and a
	ret z	; If there are no animated tiles here, just return
	ld hl, curscreen_animtiles
AnimateSTiles_loop:
	push af
	ld b, (hl)
	inc hl
	ld c, (hl)
	inc hl		; get the X and Y coordinates
	push hl		; save the pointer to 
	ld hl, TILEMAP_SUPERTILES	; we need to address the map at C*16+B
	ld a, c
	rrca
	rrca
	rrca
	rrca		
	and $f0
	or b
	ld e, a
	ld d, 0			
	add hl, de	; HL now points to the supertile
	ld a, (hl)	; THIS is the supertile to increment
	cp 240
	jr c, AnimateSTiles_loop_cont		; if this supertile is < 240, there is no need to increment
	and $fc		; keep the high 6 bits
	ld e, a		; save it in E
	ld a, (hl)
	inc a
	and $3		; next animation
	or e
	ld (hl), a	; save the updated supertile. Now we just have to update it on screen
	
	call UpdateSuperTile
AnimateSTiles_loop_cont:
	pop hl
	pop af
	dec a
	jr nz, AnimateSTiles_loop
	ret


; Update a supertile on screen
; Assumes the supertile map has already been updated
; INPUT:
;	- A: stile number
;	- B: X coord of stile
;	- C: Y coord of stile
UpdateSuperTile:
    ex af, af'
    ld a, b
    add a, b
    ld b, a         ; Multiply X by two to get to tile coordinates
    ld a, c
    add a, c        ; Multiply Y by two to get to tile coordinates. 
    ld c, a
    ex af, af'

;    ld d, 2
;    ld e, 2
	ld de, $0202
 ;   push bc			;<<<<<<<<<<<
    call InvalidateTiles	; Invalidate tiles
;	pop bc				;<<<<<<<<<<<
;	jp AnimStile_CheckSprites <<<<<<< hemos movido el simulated sprite al final no hace falta el JP
;	call AnimStile_CheckSprites ; Check overlapping sprites
;	ret


; Check if animated stile overlaps with sprites
; If so, mark them for redraw
; INPUT:
;	- B: X position for tile
;	- C: Y position for tile

; We will abuse the sprite routines...


AnimStile_CheckSprites:
	ld ix, simulatedsprite
;	ld a, b			;4
;	rlca			;4
;	rlca			;4
;	rlca			;4
;	and $f8			;7
;	ld (ix+3), a	; xmin
;	ld a, c			;4
;	rlca			;4
;	rlca			;4
;	rlca			;4
;	and $f8			;7
;	ld (ix+4), a	; ymin
;					46
	
	ld h, b			;4
	ld l, c			;4
	add hl,bc		;11
	add hl,hl		;11
	add hl,hl		;11
	ld (ix+3), h	; xmin
	ld (ix+4), l	; ymin
;					41 ahorramos 5 t-states 

	ld (ix+5), d	; number of chars used in X
	ld (ix+6), e	; number of chars used in Y
	jp MarkOverlappingSprites
;    call MarkOverlappingSprites
;	ret

simulatedsprite: ds 7


; Get the value for the tile in the hardness map
;
; INPUT:
;	- B: X in stile coordinates
;	- C: Y in stile coordinates
; OUTPUT: 
;	- A: value in hardness map
GetHardness:
	ld a, c			; we will need to point to hardness + Y*4 + X/4
	cp 10
	jr nc, gh_fardown	; going below the end of screen
	rlca
	rlca			; Y*4
	ld e, a
	ld d, 0
	ld a, b
	and $0C			; get the two most significant bits
	rrca
	rrca
	or e
	ld e, a			
	ld hl, CURRENT_SCREEN_HARDNESS_MAP
	add hl, de		; HL now points to the correct byte
	ld e, (hl)		; and we keep it in E
	ld a, b			; each pair of bits holds the value for a single tile. We will need to select those
	and $3	
	rlca			; 6 - (B & 3 ) * 2 is the number of shifts to do
	ld b, a
	ld a, 6
	sub b			; A has it
	jr z, gh_noshift
gh_shiftloop:
	rrc e
	dec a
	jr nz, gh_shiftloop	; we are shifting it right
gh_noshift:
	ld a, e			; now load it in A
	and $3			; and keep only the two significant bits
	ret
gh_fardown:
	xor a			; if going down, hardness is 0
	ret


; Set the value for the stile in the hardness map
;
; INPUT:
;	- B: X in stile coordinates
;	- C: Y in stile coordinates
;	- A: value in hardness map to set (0 to 3)

hardness_bitmask: db $3F, $CF, $F3, $FC

SetHardness:
	push bc
	ex af, af'
	ld a, b
	and $3		
	ld e, a
	ld d, 0
	ld hl, hardness_bitmask
	add hl, de
	ld a, (hl)	; so A has the bitmask

	push af			; save the bitmask
	ld a, c			; we will need to point to hardness + Y*4 + X/4
	rlca
	rlca			; Y*4
	ld e, a
	ld d, 0
	ld a, b
	and $0C			; get the two most significant bits
	rrca
	rrca
	or e
	ld e, a			
	ld hl, CURRENT_SCREEN_HARDNESS_MAP
	add hl, de		; HL now points to the correct byte
	ld e, (hl)		; and we keep it in E
	pop af			; restore the bitmask
	and e			; A AND E will ignore the bitmask
	ld e, a			; and store it back on E
	ex af, af'		; restore A, the value to set in the hardness map
	ld d, a			; and save it in D

	ld a, b			; each pair of bits holds the value for a single tile. We will need to select those
	and $3	
	rlca			; 6 - (B & 3 ) * 2 is the number of shifts to do
	ld b, a
	ld a, 6
	sub b			; A has it
	jr z, sh_noshift
sh_shiftloop:
	rlc d
	dec a
	jr nz, sh_shiftloop	; we are shifting it right
sh_noshift:
	ld a, e			; now load the original bits in A
	or d			; and OR it with the new value
	ld (hl), a		; Finally, save it!
	pop bc
	ret

; Set the value for the stile in the map
;
; INPUT:
;	- B: X in stile coordinates
;	- C: Y in stile coordinates
;	- A: stile value to set (0 to 255)
SetStile:
	push af
	ld hl, TILEMAP_SUPERTILES	; we need to address the map at C*16+B
	ld a, c
	rrca
	rrca
	rrca
	rrca		
	and $f0
	or b
	ld e, a
	ld d, 0			
	add hl, de	; HL now points to the supertile
	pop af
	ld (hl), a	; store the new tile
	push hl
	push bc
	push de
	push af
	push ix
	push iy
	call UpdateSuperTile
	pop iy
	pop ix
	pop af
	pop de
	pop bc
	pop hl
	ret

; Supporting function: make a supertile empty
; INPUT:
;	- B: X coordinate
;	- C: Y coordinate

empty_supertile:
	push bc
	xor a
	call SetStile
	pop bc
	xor a
	call SetHardness	; and set the hardness of this stile to "empty"
	ret

; Print a character on screen
; INPUT:
;	- A: char
;	- B: X in chars
;	- C: Y in chars

print_char:
;	sub 32				;7 first char is number 32
;	ld e, a				;4
;	ld d, 0				;7
;	rl e				;8
;	rl d				;8
;	rl e				;8
;	rl d				;8
;	rl e				;8
;	rl d				;8 Char*8, to get to the first byte
;	ld hl, FONT_IN_RAM6	;10
;	add hl, de			;11 HL points to the first byte
;	ex de, hl			;4 DE points to the first byte
	;					91 total 

	ld l, a 					;4
	ld h, 0						;7
	add hl,hl					;11 duplicamos HL (x2)
	add hl,hl					;11 duplicamos HL (x4 en total)
	add hl,hl					;11 duplicamos HL (x8 en total)
	ld a, high FONT_IN_RAM6 - 1			;7
	add a, h					;4
	ld d, a 					;4
	ld e, l						;4
	;							63 total

print_char_go:
	ld a, (rombank)		;Sistem var with the previous value
	push af
	push bc
	call setrambank6		; Set RAM Bank 6 for FONT
	pop bc

	ld hl, TileScAddress	; address table
;	ld a, c					;4 
;	add a, c				;4  C = 2*Y, to address the table
;	ld c, a					;4
	ld a, b					; A = X
	ld b, 0					; Clear B for the addition
	add hl, bc				;11	ahorramos 1t-state y 2 bytes :)
	add hl, bc				; hl = address of the first tile
	ld c, (hl)
	inc l
	ld b, (hl)				; BC = Address
	ld l, a					; hl = X
	ld h, 0
	add hl, bc				; hl = tile address in video memory

	ld b, 8
print_char_loop:
	ld a, (de)
	ld (hl), a
	inc e			; FIXME! will be able to do INC E, when FONTS is aligned in memory
	inc h
	djnz print_char_loop
	pop af
	di
	ld b, a
	call setrambank		; set previous ram bank
	ei
	ret


FONT_IN_RAM6:  EQU $1D00
