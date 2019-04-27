#all: ianna-3dos.dsk sword.hdf ianna-cart.rom ianna-dan.rom ianna-if2.rom

all: clean mld rom

music-nomusic.pck: music-nomusic.mus
	apack  music-nomusic.mus music-nomusic.pck

music-level1.pck: music-level1.mus
	apack  music-level1.mus music-level1.pck

music-level3.pck: music-level3.mus
	apack  music-level3.mus music-level3.pck

music-level4.pck: music-level4.mus
	apack  music-level4.mus music-level4.pck

music-level5.pck: music-level5.mus
	apack  music-level5.mus music-level5.pck

music-level6.pck: music-level6.mus
	apack  music-level6.mus music-level6.pck

music-level7.pck: music-level7.mus
	apack  music-level7.mus music-level7.pck

music-level8.pck: music-level8.mus
	apack  music-level8.mus music-level8.pck

music-gameover.pck: music-gameover.mus
	apack  music-gameover.mus music-gameover.pck

music-menu.pck: music-menu.mus
	apack  music-menu.mus music-menu.pck

ianna.spr: sprite_esqueleto.cmp sprite_orc.cmp sprite_mummy.cmp sprite_troll.cmp sprite_rollingstone.cmp sprite_golem_inf.cmp sprite_golem_sup.cmp sprite_caballerorenegado.cmp sprite_dalgurak.cmp sprite_demonio_inf.cmp sprite_demonio_sup.cmp sprite_minotauro_inf.cmp sprite_minotauro_sup.cmp sprite_ogro_inf.cmp sprite_ogro_sup.cmp

sprite_caballerorenegado.cmp: sprite_caballerorenegado.asm
	pasmo sprite_caballerorenegado.asm sprite_caballerorenegado.bin
	apack  sprite_caballerorenegado.bin sprite_caballerorenegado.cmp

sprite_dalgurak.cmp: sprite_dalgurak.asm
	pasmo sprite_dalgurak.asm sprite_dalgurak.bin
	apack  sprite_dalgurak.bin sprite_dalgurak.cmp

sprite_demonio_inf.cmp: sprite_demonio_inf.asm
	pasmo sprite_demonio_inf.asm sprite_demonio_inf.bin
	apack  sprite_demonio_inf.bin sprite_demonio_inf.cmp

sprite_demonio_sup.cmp: sprite_demonio_sup.asm
	pasmo sprite_demonio_sup.asm sprite_demonio_sup.bin
	apack  sprite_demonio_sup.bin sprite_demonio_sup.cmp

sprite_minotauro_inf.cmp: sprite_minotauro_inf.asm
	pasmo sprite_minotauro_inf.asm sprite_minotauro_inf.bin
	apack  sprite_minotauro_inf.bin sprite_minotauro_inf.cmp

sprite_minotauro_sup.cmp: sprite_minotauro_sup.asm
	pasmo sprite_minotauro_sup.asm sprite_minotauro_sup.bin
	apack  sprite_minotauro_sup.bin sprite_minotauro_sup.cmp

sprite_ogro_inf.cmp: sprite_ogro_inf.asm
	pasmo sprite_ogro_inf.asm sprite_ogro_inf.bin
	apack  sprite_ogro_inf.bin sprite_ogro_inf.cmp

sprite_ogro_sup.cmp: sprite_ogro_sup.asm
	pasmo sprite_ogro_sup.asm sprite_ogro_sup.bin
	apack  sprite_ogro_sup.bin sprite_ogro_sup.cmp

sprite_esqueleto.cmp: sprite_esqueleto.asm
	pasmo sprite_esqueleto.asm sprite_esqueleto.bin
	apack  sprite_esqueleto.bin sprite_esqueleto.cmp

sprite_troll.cmp: sprite_troll.asm
	pasmo sprite_troll.asm sprite_troll.bin
	apack  sprite_troll.bin sprite_troll.cmp

sprite_orc.cmp: sprite_orc.asm
	pasmo sprite_orc.asm sprite_orc.bin
	apack  sprite_orc.bin sprite_orc.cmp

sprite_mummy.cmp: sprite_mummy.asm
	pasmo sprite_mummy.asm sprite_mummy.bin
	apack  sprite_mummy.bin sprite_mummy.cmp

sprite_rollingstone.cmp: sprite_rollingstone.asm
	pasmo sprite_rollingstone.asm sprite_rollingstone.bin
	apack  sprite_rollingstone.bin sprite_rollingstone.cmp

sprite_golem_inf.cmp: sprite_golem_inf.asm
	pasmo sprite_golem_inf.asm sprite_golem_inf.bin
	apack  sprite_golem_inf.bin sprite_golem_inf.cmp 

sprite_golem_sup.cmp: sprite_golem_sup.asm
	pasmo sprite_golem_sup.asm sprite_golem_sup.bin
	apack  sprite_golem_sup.bin sprite_golem_sup.cmp

barbaro_sword.cmp: barbaro_sword.asm
	pasmo barbaro_sword.asm barbaro_sword.bin
	apack  barbaro_sword.bin barbaro_sword.cmp

barbaro_eclipse.cmp: barbaro_eclipse.asm
	pasmo barbaro_eclipse.asm barbaro_eclipse.bin
	apack  barbaro_eclipse.bin barbaro_eclipse.cmp

barbaro_axe.cmp: barbaro_axe.asm
	pasmo barbaro_axe.asm barbaro_axe.bin
	apack  barbaro_axe.bin barbaro_axe.cmp

barbaro_blade.cmp: barbaro_blade.asm
	pasmo barbaro_blade.asm barbaro_blade.bin
	apack  barbaro_blade.bin barbaro_blade.cmp

menu_screen.cmp: menu_screen.scr
	apack  menu_screen.scr menu_screen.cmp

intro_marco.cmp: intro_marco.scr
	apack  intro_marco.scr intro_marco.cmp
credits.cmp: credits.scr
	apack  credits.scr credits.cmp
intro01a.px.cmp: intro01a.px
	apack  intro01a.px intro01a.px.cmp
intro02a.px.cmp: intro02a.px
	apack  intro02a.px intro02a.px.cmp
intro03a.px.cmp: intro03a.px
	apack  intro03a.px intro03a.px.cmp
intro04a.px.cmp: intro04a.px
	apack  intro04a.px intro04a.px.cmp
intro05a.px.cmp: intro05a.px
	apack  intro05a.px intro05a.px.cmp
intro01a.at.cmp: intro01a.at
	apack  intro01a.at intro01a.at.cmp
intro02a.at.cmp: intro02a.at
	apack  intro02a.at intro02a.at.cmp
intro03a.at.cmp: intro03a.at
	apack  intro03a.at intro03a.at.cmp
intro04a.at.cmp: intro04a.at
	apack  intro04a.at intro04a.at.cmp
intro05a.at.cmp: intro05a.at
	apack  intro05a.at intro05a.at.cmp

final02a.px.cmp: final02a.px
	apack  final02a.px final02a.px.cmp
final02a.at.cmp: final02a.at
	apack  final02a.at final02a.at.cmp
final03a.px.cmp: final03a.px
	apack  final03a.px final03a.px.cmp
final03a.at.cmp: final03a.at
	apack  final03a.at final03a.at.cmp

dandanator/nmiroutine.bin: dandanator/nmiroutine.asm dandanator/print_routines.asm dandanator/charset.bin dandanator/pic-fw.bin
	pasmo -I ./dandanator ./dandanator/nmiroutine.asm ./dandanator/nmiroutine.bin
	
	
#######################################

clean:
	del *.bin
	del *.sym
	del *.pck
	del *.cmp
	del *.bak
	del *.128
	del *.zx7	

	del "Sword of Ianna.mld"
	del "Sword of Ianna.rom"

	
mld: ianna.mld-win-48
	del *.zx7
	zx7 "dandanator multiload Ianna.scr" "dandanator multiload Ianna.scr.zx7"
	zx7 loading.scr loading.scr.zx7
	
	fcut ianna48k.bin 0000 6000 ianna-48-p1.bin
	fcut ianna48k.bin 6000 3e00 ianna-48-p3.bin
	zx7 ianna-48-p1.bin ianna48.p1.zx7	
	zx7 ianna-48-p3.bin ianna48.p3.zx7	
	fcut ianna128k.bin 0000 6000 ianna-128-p1.bin

	zx7 ianna-128-p1.bin ianna128.p1.zx7	
	zx7 ram3.128 ram3.128.zx7	

	zx7 menu.128 menu.128.zx7
	fcut menu.128.zx7 0000 0e70 menu.1.128
	fcut menu.128.zx7 0e70 014f menu.2.128
	fcut menu.128.zx7 0fbf 05f4 menu.3.128
	fcut menu.128.zx7 15b3 07fb menu.4.128
	fcut menu.128.zx7 1d72 0123 menu.5.128
	fcut menu.128.zx7 1e95 0035 menu.6.128
	fcut menu.128.zx7 1eca 00e8 menu.7.128
	fcut menu.128.zx7 1fb2 07eb menu.8.128
	fcut menu.128.zx7 279d 027a menu.9.128
	fcut menu.128.zx7 2a17 02cb menu.10.128
	fcut menu.128.zx7 2ce2 08ca menu.11.128
	fcut menu.128.zx7 35ac 0130 menu.12.128
	
	sjasmplus --nologo dandanator_Ianna.asm
	
rom: ianna.mld-win-48 dandanator/nmiroutine.bin

	fcut ianna48k.bin 0000 2000 ianna-48-rom-p1.bin
	fcut ianna48k.bin 2000 4000 ianna-48-rom-p2.bin
	fcut ianna48k.bin 6000 3e00 ianna-48-rom-p3.bin
	
	fcut ianna128k.bin 0000 2000 ianna-128-rom-p1.bin
	fcut ianna128k.bin 2000 4000 ianna-128-rom-p2.bin

	sjasmplus --nologo dandanator_Ianna-r.asm

ianna.mld-win-48: ianna-cart.bin48 ianna-cart.bin level1.map level2.map level3.map level4.map level5.map level6.map level7.map level8.map level9.map level0.map menu48k.asm marcador.scr menu_screen.cmp barbaro_sword.cmp barbaro_eclipse.cmp barbaro_axe.cmp barbaro_blade.cmp intro48k.asm intro.bin.win ram3.128

	pasmo menu48k.asm menu48k.bin menu-cart-48k.sym
	pasmo menu.asm menu.128 menu-128k.sym

ianna.spr.win: sprite_esqueleto.cmp sprite_orc.cmp sprite_mummy.cmp sprite_troll.cmp sprite_rollingstone.cmp sprite_golem_inf.cmp sprite_golem_sup.cmp sprite_caballerorenegado.cmp sprite_dalgurak.cmp sprite_demonio_inf.cmp sprite_demonio_sup.cmp sprite_minotauro_inf.cmp sprite_minotauro_sup.cmp sprite_ogro_inf.cmp sprite_ogro_sup.cmp

intro.bin.win: intro_marco.cmp intro01a.px.cmp intro01a.at.cmp intro02a.px.cmp intro02a.at.cmp intro03a.px.cmp intro03a.at.cmp intro04a.px.cmp intro04a.at.cmp intro05a.px.cmp intro05a.at.cmp final02a.px.cmp final02a.at.cmp final03a.px.cmp final03a.at.cmp credits.cmp music-intro.mus music-end.mus music-credits.mus
	copy /b /y intro_marco.cmp+intro01a.px.cmp+intro02a.px.cmp+intro03a.px.cmp+intro04a.px.cmp+intro05a.px.cmp+intro01a.at.cmp+intro02a.at.cmp+intro03a.at.cmp+intro04a.at.cmp+intro05a.at.cmp+intro02a.px.cmp+final02a.px.cmp+final03a.px.cmp+intro02a.at.cmp+final02a.at.cmp+final03a.at.cmp+credits.cmp+music-intro.mus+music-end.mus+music-credits.mus intro.bin

ianna-cart.bin48: ianna48k.asm ianna.spr.win tiles48k.asm drawsprite48k.asm input48k.asm im248k.asm rambank48k.asm entities48k.asm scripts48k.asm sprite48k.asm sprite_barbaro.asm sprite_esqueleto.asm objects48k.asm depack.asm io-48k.asm music48k.asm score48k.asm ram3.128
	pasmo  -E IO_DRIVER=4 ianna48k.asm ianna48k.bin ianna48k.sym

ianna-cart.bin: ianna.asm tiles.asm drawsprite.asm input.asm im2.asm rambank.asm entities.asm scripts.asm sprite.asm sprite_barbaro.asm sprite_esqueleto.asm objects.asm depack.asm io-cart.asm ram3.sym music.asm score.asm io.asm
	pasmo -E IO_DRIVER=4 ianna.asm ianna128k.bin ianna.sym

ram3.sym: ram3.128
ram3.128: ram3.asm atPlayer.speccy.asm iannafx.mus music-nomusic.pck music-level1.pck music-level3.pck music-level4.pck music-level5.pck music-level6.pck music-level7.pck music-level8.pck music-gameover.pck music-menu.pck
	pasmo ram3.asm ram3.128 ram3.sym

