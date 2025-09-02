; Generic I/O
	include "sizes_files.sym"

level_data:     
		dw sizemap1	 		;10
		dw sizemap2			;11
		dw sizemap3	 		;12
		dw sizemap4	 		;13
		dw sizemap5	 		;14
		dw sizemap6	 		;15
		dw sizemap7	 		;16
		dw sizemap8	 		;17
		dw sizemap0			;18
		dw sizemap9	 		;19

sprite_data:	
		dw size_spr_esqueleto		;20
		dw size_spr_orc			;21
		dw size_spr_mummy		;22
		dw size_spr_troll		;23
		dw size_spr_rollingstone	;24
		dw size_spr_caballerorenegado	;25
		dw size_spr_dalgurak		;26
		dw size_spr_golem_inf		;27
		dw size_spr_ogro_inf		;28
		dw size_spr_minotauro_inf	;29
		dw size_spr_demonio_inf		;30
		dw size_spr_golem_sup		;31
		dw size_spr_ogro_sup		;32
		dw size_spr_minotauro_sup	;33
		dw size_spr_demonio_sup		;34

intro_data: 	
		dw size_intro_marco		;40 intro - frame
		dw size_intro_screens		;41 intro - screens
		dw size_end_screens		;42 end - screens
		dw size_end_credits		;43 end - credits
		dw size_music_intro		;44 music - intro
		dw size_music_end		;45 music - end
		dw size_music_credits		;46 music - credits
	
; Load level from disk
; Will *always* place stuff in RAM Page 1, at $c000
; INPUT:
;	- A: level to load

IO_LoadLevel:
	call IO_loading
	ld   hl, level_data
	call IO_getdata
	ld   b, #11		; and store in RAMBank1
	add  a, 10
	ld   ix, $C000		; load at $C000
	jp   IO_Load


	;INPUT 		HL point to table
	;		A  position on table
	;OUTPUT		DE Size of block to LOAD
	;MODIFY		HL;DE
IO_getdata:
	push af
	add  a, a		;a*2
	ld   e, a
	ld   d, 0
	add  hl, de		; hl points to the offset on table
	ld   e, (hl)
	inc  hl
	ld   d, (hl)		; DE holds the size to load
	pop  af
	ret

; Print a string on screen, not controlling line breaks
; INPUT:
;	IY: pointer to string
;	B: X in chars
;	C: Y in chars
print_string_tap:
	ld   a, (iy+0)
	and  a
	ret  z		; return on NULL
	push iy
	push bc
	call print_char
	pop  bc
	pop  iy
	inc  iy
	inc  b
	jr   nz, print_string_tap
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
	ld   hl, sprite_data
	call IO_getdata
	ld   b, #14			; and store in RAMBank4
	add  a, 20
	ld   ix, (current_spraddr)	; load address
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
	ld   hl, intro_data
	call IO_getdata
	ld   b, #10
	add  a, 40
	ld   ix, $AC80	; buffer
	jp   IO_Load


; Load intro music 
; Will *always* place stuff in RAM page 3, address $CC00
; INPUT:
;	- A: music to load (for now, just 4)
IO_LoadIntroMusic:
    	call IO_loading
	ld   hl, intro_data
	call IO_getdata

	ld   b, #13		; Page 3
	add  a, 40
	ld   ix, $CB72		; buffer
	jp   IO_Load
	

loading_string_en: db "LOADING...",0
loading_string:    db "CARGANDO...",0

IO_loading:
	push af
    	ld   a, (language)
	and  a
	ld   iy, loading_string	
	jr   z, IO_loading_common
    		ld iy, loading_string_en
	
IO_loading_common:
    	ld   bc, $0B0C
    	call print_string_tap
    	ld   a, 7
    	ld   hl, 16384+6144+12*32+11
    	ld   de, 16384+6144+12*32+11+1
    	ld   (hl), a
    	ld   bc, 10
    	ldir
    	pop  af
    	ret

; Set the proper environment for +3DOS
; This means: IM1, RAM7, save previous RAM bank

previous_rambank: 	db 0



DOS_Setenv:
        ld   a, ($5B5C)
        ld   (previous_rambank), a
        di
	call setrambank_p3
	im   1	
	ld   iy, $5C3A		; re-establish the IY pointer (must be done!)
	ret

; Restore the previous environment
; This means: IM2, previous RAM bank and screen

DOS_RestoreEnv:
	di
	xor  a 
	out  (#FE), a
	ld   a, (previous_rambank)
	ld   b, a
	call setrambank_p3
	ld   a, 0xbf
	ld   hl, 0x8000	
	ld   de, ISR
	jp   SetIM2


; Load from Tape
; INPUT:
;	- IX: destination
;	- DE: number of bytes to load	
;	- B:  page for destination
;	- A:  FLAG for tape block 

IO_Load:
	ld   (IO_Flag + 1), a	; guarda el flag para poder repetir
	ld   (IO_IX_Address + 2), ix
	ld   (IO_DE_size + 1), de
	call DOS_Setenv
	
IO_Flag
	ld   a, 0
IO_IX_Address
	ld   ix, 0
IO_DE_size
	ld   de, 0
	scf
	call LD_BYTES
	jp   c, DOS_RestoreEnv
	jr   IO_Flag


LD_BYTES 
	inc  d
	ex   af, af'
	dec  d
	di 
	ld   a, 8
	out  (#FE), a
	in   a, (#FE)
	rra 
	and  32 
	or   2
	ld   c, a 
	cp   a  
	jp   #56B		;LD_BREAK 1387

	;ajuste de tamaño a la rutina IO-3Dos
	ds   466  - $ + level_data  , 0
	