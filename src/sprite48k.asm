org $C000

; Sprite offsets, used by the animation engine

SPRITE_OFFSET_IDLE:		EQU	0
SPRITE_OFFSET_TURN:		EQU	96
SPRITE_OFFSET_WALK:		EQU	192
SPRITE_OFFSET_FALL:		EQU	768
SPRITE_OFFSET_CROUCH:		EQU	960
SPRITE_OFFSET_UNSHEATHE:	EQU	1248
SPRITE_OFFSET_IDLE_SWORD:	EQU	1344
SPRITE_OFFSET_WALK_SWORD:	EQU	1440
SPRITE_OFFSET_HIGH_SWORD:	EQU	1728
SPRITE_OFFSET_FORW_SWORD:	EQU	2112
SPRITE_OFFSET_COMBO1_SWORD:	EQU	2496
SPRITE_OFFSET_LOW_SWORD:	EQU	2688
SPRITE_OFFSET_BACK_SWORD:	EQU	3072
SPRITE_OFFSET_BLOCK_SWORD:	EQU	SPRITE_OFFSET_LOW_SWORD+288
SPRITE_OFFSET_OUCH_SWORD:	EQU	3456
SPRITE_OFFSET_DIE:		    EQU	3552

; Be careful! The following offsets *may* change if more common animations are added

SPRITE_OFFSET_OUCH:		    EQU	3936
SPRITE_OFFSET_JUMP_UP:		EQU	4032
SPRITE_OFFSET_SHORTJUMP:	EQU	4800
SPRITE_OFFSET_LONGJUMP:		EQU	5280
SPRITE_OFFSET_RUN:		    EQU	5760
SPRITE_OFFSET_BRAKE:		EQU	6144
SPRITE_OFFSET_BRAKETURN:	EQU	6240
SPRITE_OFFSET_SWITCH:		EQU	6432
SPRITE_OFFSET_GRAB:		    EQU	6624

; Next sprite will start at 6720

barbaro_idle:
include "sprite_barbaro.asm"
enemy_base_sprite:	; here is where the sprite for the current enemy will be loaded


END_SPRITES
org $FA80
; Pause menu data
pause_string0: DB 42, 43, 43, 43, 43, 43,'P','A','U','S','A', 40, 40, 40, 40, 40, 41,0
pause_string1: DB 60, 91, 92, 32,'I','N','V','E','N','T','A','R','I','O', 32, 32, 60,0
pause_string2: DB 60, 93, 94, 32,'U','S','A','R',' ','O','B','J','E','T','O', 32, 60,0
pause_string3: DB 60, 64, 32, 32,'C','A','M','B','I','A','R',' ','A','R','M','A', 60,0
pause_string4: DB 61,'H',' ',' ','C','O','N','T',' ',' ','X',' ','Q','U','I','T', 61,0
pause_string5: DB 42, 43, 43, 43, 43, 43, 43, 43,' ', 40, 40, 40, 40, 40, 40, 40, 41,0

pause_string0_en: DB 42, 43, 43, 43, 43, 43,'P','A','U','S','E', 40, 40, 40, 40, 40, 41,0
pause_string1_en: DB 60, 91, 92, 32,'I','N','V','E','N','T','O','R','Y', 32, 32, 32, 60,0
pause_string2_en: DB 60, 93, 94, 32,'U','S','E',' ','O','B','J','E','C','T', 32, 32, 60,0
pause_string3_en: DB 60, 64, 32, 32,'P','I','C','K', 32,'W','E','A','P','O','N', 32, 60,0
pause_string4_en: DB 61,'H',' ',' ','B','A','C','K',' ',' ','X',' ','Q','U','I','T', 61,0
pause_string5_en: DB 42, 43, 43, 43, 43, 43, 43, 43,' ', 40, 40, 40, 40, 40, 40, 40, 41,0

pause_attr0: DB 1,1,1,1,1,1,71,71,71,71,71,1,1,1,1,1,1
pause_attr1: DB 1,69,69,0,67,67,67,67,67,67,67,67,67,67,67,67,1
pause_attr2: DB 1,69,0,0,67,67,67,67,0,0,69,0,67,67,67,67,1
pause_attr3: DB 1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1 
org $FC00
enemy_info:
enemy_info_skeleton: 	DB   2,  7,  14,  25,  35,  50, 65	; Energy per level
		     	DB  20,  40,  80, 120, 160, 200, 220	; Probability of long-range attack, per level
		     	DB  40,  75, 100, 140, 180, 215, 235	; Probability of short-range attack, per level
		     	DB  20,  40,  80, 100, 125, 150, 175	; Blocking probability, per level
		     	DB  13,  14,  12, 0			; short1, short2, far attack, 0 padding to make it 32 bytes

enemy_info_orc:		DB   2,  7,  14,  25,  35,  50, 65
			DB  20,  40,  80, 120, 160, 200, 220
			DB  40,  75, 100, 140, 180, 215, 235
			DB  20,  40,  80, 100, 125, 150, 175	
			DB  13,  16,  15, 0

enemy_info_mummy:	DB   2,  5,   10,  20,  35,  50,  70
			DB  20,  40,  80, 120, 160, 200, 220
			DB  40,  75, 100, 140, 180, 215, 235
			DB  20,  40,  80, 100, 125, 150, 175
			DB  18,  14,  17, 0

enemy_info_troll:	DB   5,  10,  20,  35,  45,  60,  80
			DB  20,  40,  80, 120, 160, 200, 220
			DB  40,  75, 100, 140, 180, 215, 235
			DB  20,  40,  80, 100, 125, 150, 175
			DB  13,  16,  19, 0

enemy_info_rock:	DB 255,  255,  255,  255,  255,  255,  255
			DB   0,  0,  0,  0,  0,  0,  0
			DB   0,  0,  0,  0,  0,  0,  0
			DB   0,  0,  0,  0,  0,  0,  0
			DB  20, 20, 20, 0

enemy_info_knight: 	DB   7,  12,  20,  30,  45,  55,  70	; Energy per level
		     	DB  20,  40,  80, 120, 160, 200, 220	; Probability of long-range attack, per level
		     	DB  40,  75, 100, 140, 180, 215, 235	; Probability of short-range attack, per level
		     	DB  20,  40,  80, 120, 160, 200, 220	; Blocking probability, per level
		     	DB  22,  23,  21, 0			; short1, short2, far attack, 0 padding to make it 32 bytes

enemy_info_dalgurak: 	DB   99,  99,  99,  99,  99,  99, 99; 99	; Energy per level
		     	DB  80,  80,  80, 80, 80, 80, 80	; Probability of long-range attack, per level
		     	DB  40,  75, 100, 140, 180, 215, 235	; Probability of short-range attack, per level
		     	DB  20,  40,  80, 120, 160, 200, 220	; Blocking probability, per level
		     	DB  12,  30,  29, 0			; short1, short2, far attack, 0 padding to make it 32 bytes

enemy_info_golem: 	DB  10,  20,  35,  50,  65,  80,  99	; Energy per level
		     	DB  20,  40,  80, 120, 160, 200, 220	; Probability of long-range attack, per level
		     	DB  20,  40,  80, 120, 160, 200, 220	; Probability of short-range attack, per level
		     	DB  40,  80,  120, 160, 200, 220, 240	; Blocking probability, per level
		     	DB  16,  13,  19, 0			; short1, short2, far attack, 0 padding to make it 32 bytes

enemy_info_ogre: 	DB  10,  20,  35,  50,  65,  80,  99	; Energy per level
		     	DB  20,  40,  80, 120, 160, 200, 220	; Probability of long-range attack, per level
		     	DB  20,  40,  80, 120, 160, 200, 220	; Probability of short-range attack, per level
		     	DB  20,  40,  80, 120, 160, 200, 220	; Blocking probability, per level
		     	DB  25,  26,  24, 0			; short1, short2, far attack, 0 padding to make it 32 bytes

enemy_info_minotaur: 	DB 10,  20,  35,  50,  65,  80,  99	; Energy per level
		     	DB  20,  40,  80, 120, 160, 200, 220	; Probability of long-range attack, per level
		     	DB  20,  40,  80, 120, 160, 200, 220	; Probability of short-range attack, per level
		     	DB  20,  40,  80, 120, 160, 200, 220	; Blocking probability, per level
		     	DB  25,  26,  12, 0			; short1, short2, far attack, 0 padding to make it 32 bytes

enemy_info_demon: 	DB 10,  20,  35,  48,  60,  80,  99	; Energy per level
		     	DB  20,  40,  80, 120, 160, 200, 220	; Probability of long-range attack, per level
		     	DB  20,  40,  80, 120, 160, 200, 220	; Probability of short-range attack, per level
		     	DB  20,  40,  80, 120, 160, 200, 220	; Blocking probability, per level
		     	DB  28,  24,  27, 0			; short1, short2, far attack, 0 padding to make it 32 bytes




org $fdff
dummyend: db 0			; So we finish at fe00
