INCLUDE "ram3.sym"
music_playing: db 0
music_state: db 0		; 0: music+fx, 1: music only, 2: fx only

music_sfx:  equ $C759
music_addr: equ $CB72	; music will be on a fixed location, and we'll load it from disk/cart
music_save: db 0

; Load music
; INPUT:
;	- A: music number

MUSIC_Load:
	di
	ld l, a
	ld a, (music_state)
	and 2
	jr z, MUSIC_Load_music
	ld a, 10
	jr MUSIC_Load_nomusic
MUSIC_Load_music:
	ld a, l
MUSIC_Load_nomusic:
	push af
	call MUSIC_setbank
	ld hl, music_levels
	pop af
	add a, a
	ld e, a
	ld d, 0
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl
	ld de, music_addr		; level_tiles
	call depack
MUSIC_Load_common:
	ld de, music_addr
	call atInit
	ld de, music_sfx
	call atSfxInit
	ld a, 1
	ld (music_playing), a	; music is now playing
	call MUSIC_restorebank
	ei
	ret

MUSIC_LoadCredits:
	ld a, 6
	jr MUSIC_LoadIntro_Common
MUSIC_LoadEnd:
	ld a, 5
	jr MUSIC_LoadIntro_Common
MUSIC_LoadIntro:
	ld a, 4
MUSIC_LoadIntro_Common:
	push af
	di
	call MUSIC_setbank
	pop af
MUSIC_LoadIntro_Load:
	call IO_LoadIntroMusic
	jr MUSIC_Load_common


MUSIC_restorebank:
	ld a, (music_save)
	ld b, a
	jp setrambank		; set previous ram bank

MUSIC_setbank:
	ld a, (23388)		;Sistem var with the previous value
	and $07			;Preserve the low bits
	ld (music_save), a
	ld b, 3
	jp setrambank		; Set RAM Bank 3 for music

; Play music

MUSIC_Play:
	call MUSIC_setbank
	call atPlay
	jp MUSIC_restorebank

; Stop music
MUSIC_Stop:
    di
	call MUSIC_setbank
	call atStop
	call atSfxStop
	call MUSIC_restorebank
	ei

; Init music
MUSIC_Init:
	xor a 
	ld (music_playing), a
	ret	

; Play FX
FX_SWORD1 			EQU 1
FX_DESTROY_BLOCK 	EQU 2
FX_BLOCK_HIT		EQU 3
FX_HIT				EQU 4
FX_LEVER			EQU 5
FX_SKELETON_FALL	EQU 6
FX_PICKUP			EQU 7
FX_GROUND			EQU 8
FX_GRIP				EQU 9
FX_UNSHEATHE		EQU 10
FX_SHEATHE			EQU 11
FX_INVENTORY_MOVE	EQU 12
FX_INVENTORY_SELECT	EQU 13
FX_OPEN_DOOR		EQU 14
FX_CLOSE_DOOR		EQU 15
FX_ENTER_DOOR		EQU 16
FX_TEXT				EQU 17
FX_PAUSE			EQU 18
FX_LONGJUMP			EQU 19
FX_EMPTY		    EQU 20
FX_LEVEL_UP			EQU 21

; Input:
;	A: sound effect to play

FX_Play:
	push hl
	ld l, a
	ld a, (music_state)
	and 1
	jr nz, FX_Play_nofx
	ld a, l
	pop hl
	di
	push bc
	push de
	push hl
	push ix
	push iy
	push af
	call MUSIC_setbank
	pop af
	ld l, a			; effect
	ld a, 1			; channel B
	ld h, 15		; volume
	ld de, 36		; C4 ??
	ld bc, 0
	call atSfxPlay
	call MUSIC_restorebank
	pop iy
	pop ix
	pop hl
	pop de
	pop bc
	ei
	ret
FX_Play_nofx:
	pop hl
	ret
