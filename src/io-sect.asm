; Generic I/O

level_track:  db $0e		; level 1
	          db $10		; level 2
	          db $13		; level 3
	          db $15		; level 4
	          db $18		; level 5
	          db $0e		; level 6
	          db $0e		; level 7 
	          db $0e		; level 8
	          db $18		; level 0 (attract mode)	

level_sector:	db 7		; level 1 (sector - $41)
	      		db 8		; level 2
	      		db 4		; level 3
	      		db 8		; level 4
	      		db 6		; level 5
	      		db 7		; level 6
	      		db 7		; level 7 
	      		db 7		; level 8
	      		db 5		; level 0 (attract mode)	

level_size:   	db 19		; level 1 (bytes / 512)
				db 23		; level 2
				db 22		; level 3
				db 24		; level 4
				db 24		; level 5
				db 19		; level 6
				db 19		; level 7
				db 19		; level 8
				db 8		; level 0 (attract mode)

sprite_track:	db $1c		; skeleton
				db $1c		; orc
				db $1d		; mummy
				db $1d		; troll
				db $1e		; rock
				db $1c		; knight
				db $1c		; dal gurak
				db $1e		; golem
				db $1c		; ogre
				db $1c		; minotaur
				db $1c		; demon
				db $1f		; golem - sup
				db $1c		; ogre - sup
				db $1c		; minotaur - sup
				db $1c		; demon - sup

sprite_sector:	db 2		; skeleton
				db 7		; orc
				db 3		; mummy
				db 8		; troll
				db 4		; rock
				db 2		; knight
				db 2		; dal gurak
				db 5		; golem
				db 2		; ogre
				db 2		; minotaur
				db 2		; demon
				db 3		; golem - sup
				db 1		; ogre - sup
				db 2		; minotaur - sup
				db 2		; demon - sup

sprite_size_sectors:db 5		; skeleton
					db 5		; orc
					db 5		; mummy
					db 5		; troll
					db 1		; rock
					db 5		; knight
					db 5		; dal gurak
					db 5		; golem
					db 5		; ogre
					db 5		; minotaur
					db 5		; demon
					db 5		; golem - sup
					db 2		; ogre - sup
					db 5		; minotaur - sup
					db 5		; demon - sup

sprite_size:	dw 2053		; skeleton
				dw 2253		; orc
				dw 2227		; mummy
				dw 2213		; troll
				dw 499		; rock
				dw 2053		; knight
				dw 2053		; dal gurak
				dw 2334		; golem
				dw 2053		; ogre
				dw 2053		; minotaur
				dw 2053		; demon
				dw 1006		; golem - sup
				dw 2053		; ogre - sup
				dw 2053		; minotaur - sup
				dw 2053		; demon - sup


; Load level from disk
; Will *always* place stuff in RAM Page 1, at $c000
; INPUT:
;	- A: level to load

IO_LoadLevel:
	ld hl, level_track
	ld e, a
	ld d, 0
	add hl, de		; hl points to the track
	ld b, (hl)		; B == track
	ld hl, level_sector
	add hl, de
	ld c, (hl)		; C == sector
	ld hl, level_size
	add hl, de	
	ld a, (hl)		; A == number of sectors to load
	ld e, a			; E == number of sectors to load

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

;	- A:  page for destination
;	- B: track
;	- C: sector
;	- E: number of sectors to load

IO_LoadSprite:
	push af			; save sprite number, we will need them later
	ld hl, sprite_track
	ld e, a
	ld d, 0
	add hl, de		; hl points to the offset
	ld b, (hl)		; B = track
	ld hl, sprite_sector
	add hl, de
	ld c, (hl)		; C = sector
	ld hl, sprite_size_sectors
	add hl, de
	ld e, (hl)		; E = nsectors
	ld hl, (current_spraddr)		; load address
	ld a, 4			; and store in RAMBank4
	call IO_Load
	pop af
	add a, a
	ld e, a
	ld d, 0
	ld hl, sprite_size
	add hl, de
	ld c, (hl)
	inc hl
	ld b, (hl)		; BC is number of bytes loaded
	ret 

; Input/output functions for +3DOS, using sectors
; +3DOS constants

DOS_EST_1346    equ $13F
DOS_OPEN        equ $106
DOS_READ        equ $112
DOS_CLOSE       equ $109
DOS_REF_XDPB    equ $151
DD_LOGIN        equ $175
DD_READ_SECTOR  equ $163
DD_L_OFF_MOTOR  equ $19c

; Set the proper environment for +3DOS
; This means: IM1, RAM7, save previous RAM bank

previous_rambank: db 0

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
	call SetIM2
	ret

; Load from +3 sector
; INPUT:
;	- HL: destination
;	- A:  page for destination
;	- B: track
;	- C: sector
;	- E: number of sectors to load


number_of_sectors: db 0

IO_Load:
	ld d, b		; track
	ld b, a		; page in $C000
	ld a, e
	ld (number_of_sectors), a	
	ld e, c		; sector
	ld c, 0		; unit 0
	push de
	push bc
	push hl

	call DOS_Setenv
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
	pop hl			; recover destination address
	pop bc			; recover page and unit
	pop de			; recover the track and sector

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
    ld b, 0
    call DD_L_OFF_MOTOR     ; stop motor	
	call DOS_RestoreEnv
	ret

