org 24576

CURRENT_SCREEN_MAP:	EQU $FE00
CURRENT_SCREEN_HARDNESS_MAP: EQU CURRENT_SCREEN_MAP + 160
CURRENT_SCREEN_OBJECTS: EQU CURRENT_SCREEN_MAP + 200

mainmenu_p6: EQU $DC63
intro_in_p6: EQU $DC6C
ending_in_p6: EQU $DC6F

start:
init_engine:
	call set_interrupt
	call MUSIC_Init
IF IO_DRIVER=4
	; Load preferences
	call IO_LoadPrefs
ENDIF
game_loop:
	call cls
	; Load menu music
	ld a, 12
	call MUSIC_Load
	call setrambank6		; and place RAM bank 6
	call mainmenu_p6
	call set_interrupt
	call setrambank0_with_di	; and set RAM bank 0
begin_level:
	call MUSIC_Stop
	call cls
IF IO_DRIVER=4
	; Save preferences
	call IO_SavePrefs
ENDIF

	call setrambank6		; and place RAM bank 6

    ; Check if this is the first time the intro is run,
    ; and only run it if we are in level 1
    ld a, (current_level)
    and a
    jr nz, begin_level_nointro
    ld a, (intro_shown)
    and a
    jr nz, begin_level_nointro

	call MUSIC_LoadIntro
	call MUSIC_Init			; little trick: load but don't play
	call intro_in_p6
	call MUSIC_Stop
begin_level_nointro:
	call setrambank0_with_di	; and set RAM bank 0
	call cls
	call InitVariables
	call InitSprites
	call InitEntities
	call InitObjectTable
	call InitPlayer
	call LoadLevel
	ld a, 1
	ld (show_passwd), a
	call LoadSprites
	call SaveCheckpoint
internal_loop:
	call game
	call MUSIC_Stop
	di
	call switchscreen
	ei
	ld a, (current_level)
	cp 8
	jr z, internal_loop_attract
	call draw_gameover_string
internal_loop_attract:
	ld a, (player_dead)
	;cp 2
	sub 2
	jr z, game_loop     ; back to main menu
	;cp 3
	dec a
	jr z, begin_level   ; new level
    ; cp 4
    dec a
    jp z, end_game      ; game completed!
	jr internal_loop
game:
	call InitTiles
	; Set visible page
	di 
	call switchscreen
	ei
	call RestoreCheckpoint
	call load_player_weapon_sprite
	ld a, (current_levely)
	and a
	jr z, LoadScreen_addx
	ld c, a			; C has current_levely
	ld a, (level_width)
	ld b, a			; B has level_width
	xor a
LoadScreen_loop:
	add a, c
	djnz LoadScreen_loop	; so we multiply current_levely*level_width
LoadScreen_addx:
	ld hl, current_levelx
	add a, (hl)

	call LoadScreen
	ld ix, CURRENT_SCREEN_OBJECTS
	call LoadObjects
	ld hl, CURRENT_SCREEN_OBJECTS
	call load_script
	call LoadEnemySprite

	ld a, (current_level)
	call MUSIC_Load
	call load_scorearea
	call DrawScreen

	ld ix, (ENTITY_PLAYER_POINTER)
	ld a, (initial_coordx)
	ld b, a
	ld a, (initial_coordy)
	ld c, a
	call UpdateSprite
	call RedrawScreen
	ld a, (current_level)
	and a
	jr z, mainloop		; do not show password in level 1 (makes no sense)
	cp 8
	jr nc, mainloop		; in attract mode and secret level, do not show password
	ld a, (show_passwd)
	and a
	jr z, mainloop
	xor a
	ld (show_passwd), a
	call draw_password
mainloop:
	; DEBUG: while we press S, we will see the alternate screen
;	ld bc, KEY_S 
;	call GET_KEY_STATE
;	and a
;	jr nz, mainloop_go
;kkloop_showaltscreen:
;	di 
;	call switchscreen	; Now show shadow screen
;kkloop_showaltscreen_loop:
;	ld bc, KEY_S 
;	call GET_KEY_STATE
;	and a
;	jr z, kkloop_showaltscreen_loop
;	call switchscreen	; Show main screen (from bank 7)
;	ei
	ld a, (current_level)
	cp 8
	jr nz, mainloop_go		; only check this if we are in attract mode
	ld bc, KEY_SPACE
	call GET_KEY_STATE
;	and a
	jr nz, mainloop_go
	; Pressed SPACE while in attract mode, let's get out of here!
	ld a, 2
	ld (player_dead), a
mainloop_go:
	; Press H for pause menu
	ld bc, KEY_H
	call GET_KEY_STATE
;	and a
	jr nz, mainloop_nopause
	ld a, FX_PAUSE
	call FX_Play
	call pause_menu
	ld a, FX_PAUSE
	call FX_Play
mainloop_nopause:
	ld a, (animate_tile)
	inc a
	ld (animate_tile), a
	and 1
	jr nz, no_animate_tiles
	call AnimateSTiles
no_animate_tiles:
	; Run scripts
	call RunScripts
	; Check gravities
	call CheckGravities
	; And redraw
	call waitforVBlank
	call RedrawScreen

	ld a, (player_dead)
	and a
	ret nz		; if the player is dead, exit
	; tick global timer
	ld a, (global_timer)
	and a
	jr z, mainloop
	dec a
	ld (global_timer), a
	jr mainloop

end_game:
	call MUSIC_Stop
	call cls
	call setrambank6		; and place RAM bank 6
	call MUSIC_LoadEnd
	call MUSIC_Init			; little trick: load but don't play
	call ending_in_p6
	call setrambank0_with_di	; and set RAM bank 0
	call cls
    jp game_loop

waitforVBlank:
	push af
	push bc
	push de
	push hl
	push ix
	push iy
waitforVBlank_loop:
	ld a, (frames_noredraw)
	cp 5			; wait until we have spent at least 5 frames without redrawing
	jr nc, vblank_done
waitforVBlank_score:
	ld a, (score_semaphore)
	and a
	jr nz, waitforvblank_halt_go	; if the score_semaphore is taken, do nothing!
	ld a, (inv_refresh)
	and a
	jr z, waitforVBlank_noscore
	call draw_score_inventory
waitforVBlank_noscore:
	ld a, (inv_what_to_print)
	and a
	jr nz, waitforvblank_check1
waitforvblank_0:
	call draw_barbarian_state
	ld a, 1
	jr waitforvblank_halt
waitforvblank_check1:
	;cp 1
	dec a
	jr nz, waitforvblank_2
waitforvblank_1:
	ld ix, ENTITY_ENEMY1_POINTER
	ld a, 24
	call draw_enemy_state
	ld a, 2
	jr waitforvblank_halt
waitforvblank_2:
	ld ix, ENTITY_ENEMY2_POINTER
	ld a, 27
	call draw_enemy_state
	xor a
waitforvblank_halt:	
	ld (inv_what_to_print), a
waitforvblank_halt_go:	
	halt
	jr waitforVBlank_loop
vblank_done:
	xor a
	ld (frames_noredraw), a ; 0 frames without a redraw
	pop iy
	pop ix
	pop hl
	pop de
	pop bc
	pop af
	ret


set_interrupt:
	ld a, 0xbf
	ld hl, 0x8000	
	ld de, ISR
	jp SetIM2
;	call SetIM2
;	ret


pause_menu_print_attr1:
	ld hl, pause_attr1
; B: X char
; C: Y char
; HL: pointer to attribute list
pause_menu_print_attr:
	ld a, 17
	ld b, 8
pause_menu_print_attr_loop:
	ld e, (hl)
	push bc
	push hl
	push af
	call SetAttribute
	pop af
	pop hl
	pop bc
	inc b
	inc hl
	dec a
	jr nz, pause_menu_print_attr_loop
	ret

pause_menu:
	; first, wait until the H key is released
	ld bc, KEY_H
	call GET_KEY_STATE
;	and a
	jr z, pause_menu
pause_menu_print:
	ld c, 8
	ld hl, pause_attr0
	call pause_menu_print_attr
	ld c, 9
;	ld hl, pause_attr1
	call pause_menu_print_attr1
	ld c, 10
;	ld hl, pause_attr1
	call pause_menu_print_attr1
	ld c, 11
;	ld hl, pause_attr1
	call pause_menu_print_attr1
	ld c, 12
	ld hl, pause_attr2
	call pause_menu_print_attr
	ld c, 13
	ld hl, pause_attr3
	call pause_menu_print_attr

	ld a, (language)
	and a
	jr nz, pause_menu_en
	ld iy, pause_string0
	jr pause_menu_print_go
pause_menu_en:
	ld iy, pause_string0_en
pause_menu_print_go:
	ld bc, 8*256 + 8
	ld a, 6
pause_menu_print_loop:
	push bc
	push iy
	push af
	call print_string2		
	pop af
	pop iy
	pop bc
	ld de, 18
	add iy, de
	inc c
	dec a
	jr nz, pause_menu_print_loop

pause_menu_inner_loop:
	ld a, (joystick_state)
	bit 4, a			; BIT 4 is FIRE
	jr nz, pause_menu_inner_use_object
	bit 2, a			; BIT 2 is left
	jr z, pause_menu_inner_check_right
	; pressed left. wait until it is depressed, change object left
pause_menu_inner_left_loop:
	call pause_menu_waitkey
	bit 2, a
	jr nz, pause_menu_inner_left_loop
	ld a, FX_INVENTORY_MOVE
	call FX_Play
	ld a, (inv_current_object)
	and a
	jr z, pause_menu_inner_done	; cannot reduce the current object
	dec a
	ld (inv_current_object),a
	jr pause_menu_inner_updateinv
pause_menu_inner_check_right:
	bit 3, a			; BIT 3 is right
	jr z, pause_menu_inner_check_down
pause_menu_inner_right_loop:
	call pause_menu_waitkey
	bit 3, a
	jr nz, pause_menu_inner_right_loop
	ld a, FX_INVENTORY_MOVE
	call FX_Play
	ld a, (inv_current_object)
	cp INVENTORY_SIZE - 1
	jr z, pause_menu_inner_done	; cannot increase the current object
	inc a
	ld (inv_current_object),a
pause_menu_inner_updateinv:
	call force_inv_redraw
pause_menu_inner_check_down:
	bit 1, a
	jr z, pause_menu_inner_done
	; pressed down. wait until it is depressed, change weapon if available
pause_menu_inner_down_loop:
	call pause_menu_waitkey
	bit 1, a
	jr nz, pause_menu_inner_down_loop
pause_menu_change_weapon:
	ld a, FX_INVENTORY_MOVE
	call FX_Play
	ld a, (player_current_weapon)
	inc a				
	and $3
	ld (player_current_weapon), a
	ld hl, player_available_weapons
	ld e, a
	ld d, 0
	add hl, de
	ld a, (hl)
	and a
	jr z, pause_menu_change_weapon	; weapon not available, check next
	call draw_weapon
	call RedrawScreen
	jr pause_menu_inner_done
pause_menu_inner_use_object:
	call pause_menu_waitkey
	bit 4, a			; BIT 4 is FIRE
 	jr nz, pause_menu_inner_use_object
	ld a, (inv_current_object)
	ld e, a
	ld d, 0
	ld hl, inventory
	add hl, de
	ld a, (hl)	; get object
	cp OBJECT_HEALTH	; the health potion. For now, it is the only one we can use as such
	jr nz, pause_menu_inner_done
	; set maximum health
	ld iy, ENTITY_PLAYER_POINTER
	call get_entity_max_energy	 ; get the maximum energy
	ld (ENTITY_PLAYER_POINTER+4), a				; and set it!
	ld a, FX_INVENTORY_SELECT
	call FX_Play
	ld a, OBJECT_HEALTH
	call remove_object_from_inventory
	jr pause_menu_inner_updateinv
pause_menu_inner_done:
	xor a			
	ld (joystick_state), a	; reset joystick state
pause_menu_check_for_exit:
	ld bc, KEY_H
	call GET_KEY_STATE
;	and a
	jr z, pause_menu_wait_for_exit_depressed
pause_menu_check_for_end:
	ld bc, KEY_X
	call GET_KEY_STATE
;	and a
	jp nz, pause_menu_inner_loop
pause_menu_wait_for_end_depressed:
	ld a, 2
	ld (player_dead), a
	ld bc, KEY_H
	call GET_KEY_STATE
;	and a
	jr z, pause_menu_wait_for_end_depressed
pause_menu_wait_for_exit_depressed:
	ld bc, KEY_H
	call GET_KEY_STATE
;	and a
	jr z, pause_menu_wait_for_exit_depressed
	; Load the new weapon animations, just in case
	call load_player_weapon_sprite
	; invalidate the whole area to force a full redraw
	ld bc, 0
	ld de, 32*256 + 20
	call InvalidateTiles
	jp RedrawAllSprites
;	call RedrawAllSprites
;	ret

pause_menu_waitkey:
	xor a
	ld (joystick_state), a
	halt
	ld a, (joystick_state)
	ret

; Run scripts for all entities
RunScripts:
	xor a
	ld (screen_changed), a
	ld ix, ENTITY_PLAYER_POINTER
	ld hl, barbaro_idle
	ld (entity_sprite_base), hl
	ld a, (joystick_state)
	ld (entity_joystick), a
	ld iy, scratch_area_player
	call run_script
	ld ix, ENTITY_PLAYER_POINTER
	call script_player
	; If we changed screen, we should stop now!
	ld a, (screen_changed)
	and a
	ret nz
	ld ix, ENTITY_ENEMY1_POINTER
	ld a, (ix+0)
	or (ix+1)
	jr z, runs_noenemy1
	xor a
	ld (entity_joystick), a
	ld hl, enemy_base_sprite
	ld (entity_sprite_base), hl
	ld iy, scratch_area_enemy1
	call run_script

	ld ix, ENTITY_ENEMY1_POINTER
	call action_joystick

runs_noenemy1:
	ld ix, ENTITY_ENEMY2_POINTER
	ld a, (ix+0)
	or (ix+1)
	jr z, runs_noenemy2
	xor a
	ld (entity_joystick), a
	ld a, (ix+10)
	and $f0
	cp OBJECT_ENEMY_SECONDARY*16-OBJECT_ENEMY_SKELETON*16
	jr nz, runs_enemy2_nosecondary
	ld hl, enemy_base_sprite+3936
	jr runs_enemy2_go
runs_enemy2_nosecondary:
	ld hl, enemy_base_sprite
runs_enemy2_go:
	ld (entity_sprite_base), hl
	ld iy, scratch_area_enemy2
	call run_script

	ld ix, ENTITY_ENEMY2_POINTER
	call action_joystick


runs_noenemy2:
	ld b, 5		; 5 objects
	ld ix, ENTITY_OBJECT1_POINTER
	ld iy, scratch_area_obj1
runs_object_loop:
	push iy
	push ix
	push bc
	ld a, (ix+0)
	or (ix+1)
	jr z, runs_noobj	; skip object if absent
	call run_script
runs_noobj:
	pop bc
	pop ix
	pop iy
	ld de, ENTITY_SIZE		; entity size
	add ix, de		; go to next object
	ld de, 8		; scratch area size
	add iy, de
	djnz runs_object_loop
	ret



; Check gravity for player and enemies
CheckGravities:
	ld ix, ENTITY_PLAYER_POINTER
	ld hl, barbaro_idle
	ld (entity_sprite_base), hl
	call entity_gravity
	ld ix, ENTITY_ENEMY1_POINTER
	ld a, (ix+0)
	or (ix+1)
	jr z, chkg_noenemy1	
	ld hl, enemy_base_sprite
	ld (entity_sprite_base), hl
	call entity_gravity
chkg_noenemy1:
	ld ix, ENTITY_ENEMY2_POINTER
	ld a, (ix+0)
	or (ix+1)
	ret z
	ld hl, enemy_base_sprite
	ld (entity_sprite_base), hl
	jp entity_gravity
;	call entity_gravity
;	ret



; Flush changes to screen
RedrawScreen:
	call RedrawInvTiles	
	call DrawSpriteList	; then the sprite list
	halt
	di 
	call switchscreen	; Now show shadow screen, where everything is ok
	call setrambank7		; and place RAM bank 7
	ei
	call TransferDirtyTiles	; Transfer dirty tiles to main screen
	halt
	di	
	call switchscreen	; Show main screen (from bank 7)
	call setrambank0	; and set RAM bank 0
	ei
	ret


; ISR routine
ISR:
	; simply get the joystick state
	ld a, (selected_joystick)
	ld hl, key_defs
	call get_joystick
	ld b, a
	ld a, (joystick_state)
	or b
	ld (joystick_state), a
	; increase the variable defining the number of frames without screen update
	ld a, (frames_noredraw)
	inc a
	ld (frames_noredraw), a
	; and play music, if needed
	ld a, (music_playing)
	and a
	ret z		; if not playing music, do nothing
	jp MUSIC_Play
;	call MUSIC_Play
;	ret

; Load sprites for level

; Array defining the sprites to load per level
; Low byte:  bit mask with: 0 DALGURAK KNIGHT ROCK TROLL MUMMY ORC SKELETON
; High byte: bit mask with: 0 0 0 0 DEMON MINOTAUR OGRE GOLEM 
;					 level1 level2 level3 level4 level5 level6 level7 level8 attract level9
sprites_per_level: dw $0017, $011b, $023a, $0c27, $0129, $0c2b, $0001, $0968, $001f, $0208
current_spraddr: dw 0

FIRST_ENEMY_SPRITE: EQU $C000

LoadSprites:
	ld hl, FIRST_ENEMY_SPRITE
	ld (current_spraddr), hl
	ld a, (current_level)
	add a, a
	ld e, a
	ld d, 0
	ld hl, sprites_per_level
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)			; DE has the bitmask for the enemies in level
	ld b, 7				; for now we have up to 7 small enemies
	xor a				; A counts the sprites
	ld hl, enemy_sprite_data
	call LoadSprites_loop
	ld e, d
	ld b, 4				; 4 big sprites, low side
	ld a, 7				; starting from sprite 7
	ld hl, enemy_sprite_data+14
	call LoadSprites_loop
	ld e, d
	ld b, 4				; 4 big sprites, high side
	ld a, 11			; starting from sprite 11
	ld hl, enemy_secondsprite_data
	jp LoadSprites_loop
;	call LoadSprites_loop
;	ret

LoadSprites_loop:
	rr e				; rotate lower bit into accumulator
	jr nc, LoadSprites_loop_cont
	push de
	push bc
	push af
	push hl
	call IO_LoadSprite	; load sprite A. Returns loaded bytes into BC
	pop hl
	ld de, (current_spraddr)
	ld (hl), e
	inc hl
	ld (hl), d			; save spraddr into the variable
	dec hl
	push hl
	ld h, b
	ld l, c
	add hl, de
	ld (current_spraddr), hl	; and save future address
	pop hl
	pop af
	pop bc
	pop de
LoadSprites_loop_cont:
	inc a
	inc hl
	inc hl
	djnz LoadSprites_loop
	ret

; Load level
; No parameters.
; The basic map structure is:
;	Byte 0-7: 	LEVELXXX, where XXX will be a level-specific key
;	Byte 8-9: 	offset_tileinfo
; 	Byte 10-11:	offset_stileinfo
;	Byte 12-13: offset_stilecolors
;	Byte 14-15:	offset_strings_english
;	Byte 16-17:	offset_strings
;	Byte 18:	level_nscreens
;	Byte 19: 	level_width
;	Byte 20:	level_height
;	Byte 21:	level_nscripts
;	Byte 22:	level_strings
;	Byte 23-24:	initial screen (x,y)
;	Byte 25-26:	initial coords in first screen (x,y)
;	Byte 27:	reserved
;	Byte 28-XXX:	addresses of compressed screens (level_width * level_height * 2 bytes). For now, maximum 64 screens per level (128 bytes)
;	XXX-YYY:	compressed screens
;	At the end:	compressed tileinfo, compressed stileinfo
	
LEVEL_SCREEN_ADDRESSES: EQU $AC80

LoadLevel:
    ld a, (current_level)
	call IO_LoadLevel

	di
	call setrambank1		; and place RAM bank 1
	; FIXME: should somehow check if the level structure is correct
	ld ix, $C000		
	ld a, (ix+8)
	ld l, a
	ld a, (ix+9)
	ld h, a	
	ld (level_tiles_addr), hl
	ld a, (ix+10)
	ld l, a
	ld a, (ix+11)
	ld h, a	
	ld (level_stiles_addr), hl
	ld a, (ix+12)
	ld l, a
	ld a, (ix+13)
	ld h, a	
	ld (level_stilecolors_addr), hl
	ld a, (ix+14)
	ld l, a
	ld a, (ix+15)
	ld h, a	
	ld (level_string_en_addr), hl
	ld a, (ix+16)
	ld l, a
	ld a, (ix+17)
	ld h, a	
	ld (level_string_addr), hl
	ld a, (ix+18)
	ld (level_nscreens), a
	ld a, (ix+19)
	ld (level_width), a
	ld a, (ix+20)
	ld (level_height), a	
	ld a, (ix+21)
	ld (level_nscripts), a
	ld a, (ix+22)
	ld (level_nstrings), a
	ld a, (ix+23)
	ld (current_levelx), a
	ld a, (ix+24)
	ld (current_levely), a
	ld a, (ix+25)
	ld (initial_coordx), a
	ld a, (ix+26)
	ld (initial_coordy), a

	; depack tiles and stiles 
	push ix			; save the level address 
	ld hl, (level_tiles_addr)
	ld de, TILEMAP		; level_tiles
	call depack
	ld hl, (level_stiles_addr)
	ld de, SUPERTILE_DEF		; level_supertiles
	call depack
	ld hl, (level_stilecolors_addr)
	ld de, SUPERTILE_COLORS		; level_supertilecolors
	call depack

	ld a, (language)
	and a
	jr nz, load_strings_en
	ld hl, (level_string_addr)
	jr load_strings_common
load_strings_en:
	ld hl, (level_string_en_addr)
load_strings_common:
	ld de, string_area		; level_strings + scripts
	call depack

	; finally, get the list of screens into RAM
	ld a, (level_nscreens)
	add a, a		; * 2
	ld c, a
	ld b, 0
	pop hl			; restore the level address
	ld de, 28
	add hl, de		; At the beginning+28, we have the first one
	ld de, LEVEL_SCREEN_ADDRESSES
	ldir			; and copy all the stuff
;	call setrambank0	; and set RAM bank 0 to finish
;	ei
    call setrambank0_with_di
	; FIXME: this is just meant to be running quick tests without changing the map
	;ld a, 6
	;ld (current_levelx), a
	;ld a, 0
	;ld (current_levely), a
	;ld a, OBJECT_KEY_RED
	;ld (inventory), a
	ret

; Load screen
; INPUT:
;	- A: screen to load

LoadScreen:
	add a, a		; to index the array
	ld c, a
	ld b, 0
	ld hl, LEVEL_SCREEN_ADDRESSES
	add hl, bc
	ld e, (hl)
	inc hl
	ld d, (hl)		; DE points to the screen address
	di
	call setrambank1		; and place RAM bank 1
	ei
	ex de, hl		; HL has the source
	;ld de, 16384		; use the screen as buffer
	call depackscr
	call setrambank0_with_di	; and set RAM bank 0
	; And now move the loaded screen into the proper area
	ld hl, 16384
	ld de, CURRENT_SCREEN_MAP
	ld bc, 243
	ldir			; and copy 
	; Find the number of animated tiles in the screen!!!
LoadScreen_FindAnimTiles:
	xor a
	ld (curscreen_numanimtiles), a
	ld hl, curscreen_animtiles	; area in memory with the animated tile positions
	ld de, CURRENT_SCREEN_MAP
	ld b, 10		; 10 in Y
load_findanim_loopy:	
	ld c, 16		; 16 in X	
load_findanim_loopx:
	ld a, (de)
	cp 240
	jr c, load_findanim_notfound
load_findanim_found:		; this is an animated tile
	ld a, 16
	sub c			; 16-C is the X position
	ld (hl), a
	inc hl
	ld a, 10
	sub b			; 10-B is the Y position
	ld (hl), a
	inc hl
	ld a, (curscreen_numanimtiles)
	inc a
	ld (curscreen_numanimtiles), a	; We have one more animated tile
load_findanim_notfound:
	inc de
	dec c
	jp nz, load_findanim_loopx
	djnz load_findanim_loopy
	ret


; Load enemy sprite
; INPUT: none

LoadEnemySprite:
	ld ix, ENTITY_ENEMY1_POINTER
	ld a, (ix+0)
	or (ix+1)
	jr nz, LoadEnemySprite_go
	ld ix, ENTITY_ENEMY2_POINTER
	ld a, (ix+0)
	and (ix+1)
	ret z		; no enemies in this screen
LoadEnemySprite_go:
	ld a, (ix+10)
	and $f0
	rrca
	rrca
	rrca		; this is enemy type * 2
	ld c, a
	ld a, (current_enemy_sprite)
	cp c
	ret z		; if the current enemy sprite is already loaded, do not do anything else
	ld a, c
	ld (current_enemy_sprite), a
	ld b, 0
	ld hl, enemy_sprite_data
	add hl, bc	
	ld e, (hl)
	inc hl
	ld d, (hl)	; DE is the position of the enemy sprite in RAM bank 4
	ex de, hl	; HL
	push hl

	di 
	call setrambank4		; and place RAM bank 4
	ei
	pop hl
	;ld de, 16384		; use screen as buffer
	call depackscr		; decompress
	call setrambank0_with_di	; and set RAM bank 0
	; now copy the sprite to RAM bank 0
	ld hl, 16384
	ld de, enemy_base_sprite
	ld bc, 3936		; FIXME review if this changes!!!
	ldir

	; now check if the enemy has a second sprite
	ld ix, ENTITY_ENEMY1_POINTER
	ld a, (ix+10)
	and $f0
	cp OBJECT_ENEMY_GOLEM*16-OBJECT_ENEMY_SKELETON*16
	jr z, LoadEnemySprite_secondsprite
	cp OBJECT_ENEMY_OGRE*16-OBJECT_ENEMY_SKELETON*16
	jr z, LoadEnemySprite_secondsprite
	cp OBJECT_ENEMY_MINOTAUR*16-OBJECT_ENEMY_SKELETON*16
	jr z, LoadEnemySprite_secondsprite
	cp OBJECT_ENEMY_DEMON*16-OBJECT_ENEMY_SKELETON*16
	jr z, LoadEnemySprite_secondsprite
	ret
LoadEnemySprite_secondsprite:
	rrca
	rrca
	rrca		; this is enemy type * 2
	sub 14		; OBJECT_ENEMY_GOLEM is OBJECT_ENEMY_SKELETON+7
	ld c, a
	ld b, 0
	ld hl, enemy_secondsprite_data
	add hl, bc	
	ld e, (hl)
	inc hl
	ld d, (hl)	; DE is the position of the enemy sprite in RAM bank 4
	ex de, hl	; HL

	push hl
	di 
	call setrambank4		; and place RAM bank 4
	ei
	pop hl
	;ld de, 16384		; use screen as buffer
	call depackscr		; decompress
	call setrambank0_with_di	; and set RAM bank 0
	; now copy the sprite to RAM bank 0
	ld hl, 16384
	ld de, enemy_base_sprite + 3936
	ld bc, 3936		; FIXME review if this changes!!!
	ldir
	ret
	
; Go to new screen
; INPUT:
;	- A: new screen, in the format expected by LoadScreen
screen_changed: db 0
ChangeScreen:
	call LoadScreen
	call ReInitSprites	
	call ReInitEntities
	ld ix, CURRENT_SCREEN_OBJECTS
	call LoadObjects
	ld hl, CURRENT_SCREEN_OBJECTS
	call load_script
	call LoadEnemySprite
	call draw_score_status

	; invalidate the whole area to force a full redraw
	; And copy the actual tiles
	ld bc, 0
	ld de, 32*256 + 20
	call InvalidateTiles
	call RedrawScreen

	ld a, 4
	ld (frames_noredraw), a ; 4 frames without a redraw, this means redraw on the next frame!
	ld (screen_changed), a	; any value != 0 means we changed screen
	ret

; Save checkpoint
SaveCheckpoint:
	; We are saving stuff in RAM7, $FE00 to $FFFF
	; We have to save
	; 1- The sprite and entity data areas ($BEC0 to $BF9F, 224 bytes)
	halt
	di 
	call setrambank7		; and place RAM bank 7
	ld hl, SPDATA
	ld de, $fe00
	ld bc, 224
	ldir			; and copy 
	; 2- Current status (up to 32 bytes, currently 27)
	ld hl, global_timer
	ld de, $fee0
	ld bc, player_current_weapon-global_timer+1
	ldir			; and copy
	; 3- And the object data (256 bytes in $ff00-$ffff, but in RAM 0)
	ld hl, $ff00
	ld d, 0			; d will serve as counter	
savechk_loop:	
	call setrambank0
	ld e, (hl)		; get the byte
	call setrambank7
	ld (hl), e		; store the byte
	inc hl
	dec d
	jr nz, savechk_loop	; 256 bytes in total
	call setrambank0	; leave RAM status clean
	ei					; and enable interrupts
	ret

; Restore checkpoint
RestoreCheckpoint:
	; Restoring stuff from RAM7, $FE00 to $FFFF
	; 1- The sprite and entity data areas ($BEC0 to $BF9F, 224 bytes)
	halt
	di 
	call setrambank7		; and place RAM bank 7
	ld hl, $fe00
	ld de, SPDATA
	ld bc, 224
	ldir			; and copy 
	; 2- Current status (up to 32 bytes, currently 27)
	ld hl, $fee0
	ld de, global_timer
	ld bc, player_current_weapon-global_timer+1
	ldir			; and copy
	; 3- And the object data (256 bytes in $ff00-$ffff, but in RAM 0)
	ld hl, $ff00
	ld d, l			; d will serve as counter	
restorechk_loop:	
	call setrambank7
	ld e, (hl)		; get the byte
	call setrambank0
	ld (hl), e		; store the byte
	inc hl
	dec d
	jr nz, restorechk_loop	; 256 bytes in total
;	call setrambank0	; leave RAM status clean
	ei					; and enable interrupts
	call ReInitSprites	
	jp ReInitEntities
;	call ReInitEntities
;	ret


; Load player weapon sprite
weapon_spr_addr: dw $C560, $CB07, $D0E4, $D6CF

load_player_weapon_sprite:
	; Step 1: decompress
	call setrambank6
	ld a, (player_current_weapon)
	add a, a
	ld e, a
	ld d, 0
	ld hl, weapon_spr_addr
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)		; DE = sprite address
	ex de, hl
	;ld de, 16384		; use screen as buffer
	call depackscr		; decompress	
	; Step 2: copy 
	call setrambank0_with_di
	ld hl, 16384
	ld de, barbaro_idle_espada.sev
	ld bc, 2208
	ldir			; and copy 
	ret

; TEMP
key_defs: dw KEY_Q, KEY_A, KEY_O, KEY_P, KEY_SPACE, KEY_CAPS
; Global variables
;                     skeleton orc mummy troll rock knight dalgurak golem ogre minotaur demon
enemy_sprite_data: dw        0,  0,    0,    0,   0,     0,       0,    0,   0,       0,    0
;enemy_sprite_data: dw enemy_skeleton, enemy_orc, enemy_mummy, enemy_troll, enemy_rollingstone
;						   golem ogre minotaur demon
enemy_secondsprite_data: dw    0,   0,       0,    0
;enemy_secondsprite_data: dw enemy_skeleton, enemy_skeleton, enemy_skeleton, enemy_skeleton

language: db 0	; 0: Spanish, 1: English
show_passwd: db 0

; Barbarian constants
barbarian_level_exp:  db 16, 64, 96, 128, 160, 192, 240, 255
barbarian_max_energy: db  6, 10, 18, 32,  48,  64,  80,  99 

selected_joystick: db 0
randData: dw 123
current_level: db 0

current_enemy_sprite: db 255
joystick_state: db 0
; Current level information
level_nscreens: db 0
level_nscripts: db 0
level_nstrings: db 0
level_width: db 0
level_height: db 0
level_tiles_addr: dw 0
level_stiles_addr: dw 0
level_stilecolors_addr: dw 0
level_string_en_addr: dw 0
level_string_addr: dw 0
curscreen_numanimtiles: db 0
frames_noredraw: db 0
animate_tile: db 0
entity_sprite_base:	dw 0
entity_current:		dw 0
global_timer: db 0
initial_coordx: db 0
initial_coordy: db 0
entity_joystick:	db 0
; Inventory handling variables
inv_current_object: db 0
inv_first_obj:      db 0
inv_refresh:	    db 0	; refresh inventory?
INVENTORY_SIZE	EQU 6
inventory:	    ds INVENTORY_SIZE		; FIXME we are assuming a maximum of 6 objects in the inventory
inv_what_to_print:  db 0	; 0: barbarian, 1: enemy 1, 2: enemy 2
score_semaphore:    db 0
currentx: db 0
current_levelx: db 0
current_levely: db 0
; Barbarian state
player_dead: db 0
player_available_weapons: db 0,0,0,0
player_level: db 0
player_experience:    db  0
player_current_weapon: db WEAPON_SWORD

WEAPON_SWORD: 	EQU 0
WEAPON_ECLIPSE: EQU 1
WEAPON_AXE: 	EQU 2
WEAPON_BLADE: 	EQU 3

; Additional routines:
 INCLUDE "objects.asm"
 INCLUDE "scripts.asm"	 ; Script code
;				 level1, level2, level3, level4, level5, level6, level7, level8, attrac, secret, nomus   	gameover      main menu
music_levels: dw music1, music5, music3, music4, music5, music6, music7, music8, music0, music4, music0,  music_gameover, music_menu
; Random routine from http://wikiti.brandonw.net/index.php?title=Z80_Routines:Math:Random
;-----> Generate a random number
; ouput a=answer 0<=a<=255
; all registers are preserved except: af

random:
        push    hl
        push    de
        ld      hl,(randData)
        ld      a,r
        ld      d,a
        ld      e,(hl)
        add     hl,de
        add     a,l
        xor     h
        ld      (randData),hl
        pop     de
        pop     hl
        ret


; Initialize variables:
InitVariables:
	ld a, 255
	ld (current_enemy_sprite), a
	xor a
	ld hl, joystick_state
	ld (hl), a
	ld de, level_nscreens
	ld bc, player_dead-joystick_state
	ldir
	ld a, 1
	ld (player_available_weapons), a
;	ld a, 15
;	ld (player_experience), a ; FIXME this is a cheat
	ret



END_PAGE2:

org $8000
IM2table: ds 257	 ; IM2 table (reserved)
 INCLUDE "depack.asm"
 INCLUDE "entities.asm"
 INCLUDE "tiles.asm"	 ; Tile code
 INCLUDE "drawsprite.asm" ; Sprite code
 INCLUDE "score.asm"	; code to manage the score area
 INCLUDE "music.asm"
 INCLUDE "im2.asm"
 INCLUDE "rambank.asm"
 INCLUDE "input.asm"
 INCLUDE "io.asm"

changed_settings: db 0
intro_shown: db 0
cls_loop: db 0

cls:
	xor a
	ld (cls_loop), a
	
	ld b, 30
cls_outerloop:
	ld hl, 16384+6144
	ld e, a
	ld d, 0
	add hl, de		; HL points to the first row 
	ld de, 30
	ld c, 24
	halt
cls_inerloop:
	xor a
	ld (hl), a
	inc hl
	ld (hl), 2
	inc hl
	ld (hl), 2
	add hl, de
	dec c
	jr nz, cls_inerloop
	ld a, (cls_loop)
	inc a
	ld (cls_loop), a
	dec b
	jr nz, cls_outerloop
	; last line, the last column is red, now clean 
cls_end:
    ld hl, 16384
    ld de, 16385
;	xor a
    ld (hl), l
    ld bc, 6911
    ldir
	ret

;Divide 8-bit values
;In: Divide E by divider D
;Out: A = result, D = rest
;
Div8:
    xor a
    ld b,8
Div8_Loop:
    rl e
    rla
    sub d
    jr nc,Div8_NoAdd
    add a,d
Div8_NoAdd:
    djnz Div8_Loop
    ld d,a
    ld a,e
    rla
    cpl
    ret

; Divide a 16-bit value by an 8-bit one
; INPUT: HL / C
; OUTPUT: HL: result

Div16_8:
  push de
  ld a,c                         ; checking the divisor; returning if it is zero
  or a                           ; from this time on the carry is cleared
  ret z
  ld de,-1                       ; DE is used to accumulate the result
  ld b,0                         ; clearing B, so BC holds the divisor
Div16_8_Loop:                    ; subtracting BC from HL until the first overflow
  sbc hl,bc                      ; since the carry is zero, SBC works as if it was a SUB
  inc de                         ; note that this instruction does not alter the flags
  jr nc,Div16_8_Loop             ; no carry means that there was no overflow
  ex de, hl                      ; HL gets the result
  pop de
  ret



; Multiply two 8-bit values into a 16-bit value
; INPUT: H - value 1
;		 E - value 2
; OUTPUT: HL: result
Mul8x8:                           ; this routine performs the operation HL=H*E
  ld d,0                         ; clearing D and L
  ld l,d
  ld b,8                         ; we have 8 bits
Mul8bLoop:
  add hl,hl                      ; advancing a bit
  jp nc,Mul8bSkip                ; if zero, we skip the addition (jp is used for speed)
  add hl,de                      ; adding to the product if necessary
Mul8bSkip:
  djnz Mul8bLoop
  ret


END_CODE_PAGE3:
org $BD00
 INCLUDE "rotatetable.asm"	; sprite rotation tables

END_PAGE3:
 INCLUDE "sprite.asm"
END_PAGE4:
