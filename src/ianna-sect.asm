FILE_BOOTSECTOR_BIN:
; bootsector.bin
; Side, track, sector
defb #00, #00, #41
; Length in bytes
defw #0200
FILE_STAGE2_BIN:
; stage2.bin
; Side, track, sector
defb #00, #00, #42
; Length in bytes
defw #00ea
FILE_MENU_BIN:
; menu.bin
; Side, track, sector
defb #00, #00, #43
; Length in bytes
defw #0000
FILE_IANNA_BIN:
; ianna.bin
; Side, track, sector
defb #00, #00, #43
; Length in bytes
defw #9e00
FILE_LEVEL1_MAP:
; level1.map
; Side, track, sector
defb #00, #09, #41
; Length in bytes
defw #29df
FILE_LEVEL2_MAP:
; level2.map
; Side, track, sector
defb #00, #0b, #44
; Length in bytes
defw #2ea3
FILE_LEVEL3_MAP:
; level3.map
; Side, track, sector
defb #00, #0e, #41
; Length in bytes
defw #2f25
FILE_LEVEL4_MAP:
; level4.map
; Side, track, sector
defb #00, #10, #47
; Length in bytes
defw #30fe
FILE_LEVEL5_MAP:
; level5.map
; Side, track, sector
defb #00, #13, #45
; Length in bytes
defw #37b0
FILE_LEVEL6_MAP:
; level6.map
; Side, track, sector
defb #00, #16, #46
; Length in bytes
defw #361b
FILE_LEVEL7_MAP:
; level7.map
; Side, track, sector
defb #00, #19, #47
; Length in bytes
defw #2d87
FILE_LEVEL8_MAP:
; level8.map
; Side, track, sector
defb #00, #1c, #43
; Length in bytes
defw #2e30
FILE_LEVEL9_MAP:
; level9.map
; Side, track, sector
defb #00, #1e, #49
; Length in bytes
defw #218d
FILE_LEVEL0_MAP:
; level0.map
; Side, track, sector
defb #00, #20, #48
; Length in bytes
defw #0f3e
FILE_SPRITE_ESQUELETO_CMP:
; sprite_esqueleto.cmp
; Side, track, sector
defb #00, #21, #47
; Length in bytes
defw #0831
FILE_SPRITE_ORC_CMP:
; sprite_orc.cmp
; Side, track, sector
defb #00, #22, #43
; Length in bytes
defw #07e7
FILE_SPRITE_MUMMY_CMP:
; sprite_mummy.cmp
; Side, track, sector
defb #00, #22, #47
; Length in bytes
defw #08b1
FILE_SPRITE_TROLL_CMP:
; sprite_troll.cmp
; Side, track, sector
defb #00, #23, #43
; Length in bytes
defw #08f3
FILE_SPRITE_ROLLINGSTONE_CMP:
; sprite_rollingstone.cmp
; Side, track, sector
defb #00, #23, #48
; Length in bytes
defw #01f3
FILE_SPRITE_GOLEM_INF_CMP:
; sprite_golem_inf.cmp
; Side, track, sector
defb #00, #23, #49
; Length in bytes
defw #09b6
FILE_SPRITE_GOLEM_SUP_CMP:
; sprite_golem_sup.cmp
; Side, track, sector
defb #00, #24, #45
; Length in bytes
defw #0501
