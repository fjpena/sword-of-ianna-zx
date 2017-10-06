org $C000
INCLUDE "atPlayer.speccy.asm"
org $C759
INCBIN "iannafx.mus"
org $CB72
ds 3393
music0:
INCBIN "music-nomusic.pck"
music1:
INCBIN "music-level1.pck"		; level 1
music3:
INCBIN "music-level3.pck"		; level 3
music4:
INCBIN "music-level4.pck"		; level 4 
music5:
INCBIN "music-level5.pck"		; level 5 
music6:
INCBIN "music-level6.pck"		; level 6 
music7:
INCBIN "music-level7.pck"		;  level 7 
music8:
INCBIN "music-level8.pck"		;  level 8
music_gameover:
INCBIN "music-gameover.pck"		; game over
music_menu:
INCBIN "music-menu.pck"         ; Main menu
