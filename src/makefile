
all:  ianna.tap ianna-3dos.dsk sword.hdf ianna-cart.rom ianna-dan.rom ianna-if2.rom

# ianna-sect.dsk vendrá cuando todo esté listo :)

clean: 
	rm -f *.bin
	rm -f *.sym
	rm -f *.cmp
	rm -f *~
	rm -f *.pck
	rm -f *.rom
	rm -f *.hdf
	rm -f *.tzx
	rm -f *.dsk
	rm -f *.tap
	rm -f *.dat
	rm -f ianna.spr
	rm -f diskload.bin.zxb
	rm -f ianna.gam
	rm -f loader
	rm -f disk
	rm -f *.file

#ianna.tzx: ianna.bin map.bin
#	export PACKER=/usr/local/bin/apack; buildtzx -l 1 -i template.txt -o ianna.tzx -n "SwordOfIanna"

ianna.tap: ianna-tap.bin level1.map level2.map level3.map level4.map level5.map level6.map level7.map level8.map level9.map level0.map ram3.bin ianna.spr menu.asm marcador.scr menu_screen.cmp barbaro_sword.cmp barbaro_eclipse.cmp barbaro_axe.cmp barbaro_blade.cmp intro.asm intro.bin loading.scr sizes_files.sym loader_tap
	cat ianna-tap.sym > ianna.sym
	pasmo menu.asm menu.bin menu-tap.sym
	cat ianna-tap.bin > ianna.bin
	cat SwordOfIanna.tap > SwordOfIanna_Full.tap
	./gentap --out SwordOfIanna.tap 255 loading.scr 255 ram3.bin 255 menu.bin 255 ianna.bin	10 level1.map 11 level2.map 12 level3.map 13 level4.map 14 level5.map 15 level6.map 16 level7.map 17 level8.map 18 level0.map 19 level9.map 20 sprite_esqueleto.cmp 21 sprite_orc.cmp 22 sprite_mummy.cmp 23 sprite_troll.cmp 24 sprite_rollingstone.cmp 25 sprite_caballerorenegado.cmp 26 sprite_dalgurak.cmp 27 sprite_golem_inf.cmp 28 sprite_ogro_inf.cmp 29 sprite_minotauro_inf.cmp 30 sprite_demonio_inf.cmp 31 sprite_golem_sup.cmp 32 sprite_ogro_sup.cmp 33 sprite_minotauro_sup.cmp 34 sprite_demonio_sup.cmp 40 intro_marco.cmp 41 intro_screens.file 42 intro_end.file 43 credits.cmp 44 music-intro.mus 45 music-end.mus 46 music-credits.mus
	./gentap --out SwordOfIanna_Full.tap 255 loading.scr 255 ram3.bin 255 menu.bin 255 ianna.bin 18 level0.map 20 sprite_esqueleto.cmp 21 sprite_orc.cmp 22 sprite_mummy.cmp 23 sprite_troll.cmp 24 sprite_rollingstone.cmp 44 music-intro.mus 40 intro_marco.cmp 41 intro_screens.file 10 level1.map 20 sprite_esqueleto.cmp 21 sprite_orc.cmp 22 sprite_mummy.cmp 24 sprite_rollingstone.cmp 11 level2.map 20 sprite_esqueleto.cmp 21 sprite_orc.cmp 23 sprite_troll.cmp 24 sprite_rollingstone.cmp 27 sprite_golem_inf.cmp 31 sprite_golem_sup.cmp 12 level3.map 21 sprite_orc.cmp 23 sprite_troll.cmp 24 sprite_rollingstone.cmp 25 sprite_caballerorenegado.cmp 28 sprite_ogro_inf.cmp 32 sprite_ogro_sup.cmp 13 level4.map 20 sprite_esqueleto.cmp 21 sprite_orc.cmp 22 sprite_mummy.cmp 25 sprite_caballerorenegado.cmp 29 sprite_minotauro_inf.cmp 30 sprite_demonio_inf.cmp 33 sprite_minotauro_sup.cmp 34 sprite_demonio_sup.cmp 14 level5.map 20 sprite_esqueleto.cmp 23 sprite_troll.cmp 25 sprite_caballerorenegado.cmp 27 sprite_golem_inf.cmp 31 sprite_golem_sup.cmp 15 level6.map 20 sprite_esqueleto.cmp 21 sprite_orc.cmp 23 sprite_troll.cmp 25 sprite_caballerorenegado.cmp 29 sprite_minotauro_inf.cmp 30 sprite_demonio_inf.cmp 33 sprite_minotauro_sup.cmp 34 sprite_demonio_sup.cmp 16 level7.map 20 sprite_esqueleto.cmp 17 level8.map 23 sprite_troll.cmp 25 sprite_caballerorenegado.cmp 26 sprite_dalgurak.cmp 27 sprite_golem_inf.cmp 30 sprite_demonio_inf.cmp 31 sprite_golem_sup.cmp 34 sprite_demonio_sup.cmp 19 level9.map 23 sprite_troll.cmp 28 sprite_ogro_inf.cmp 32 sprite_ogro_sup.cmp 45 music-end.mus 42 intro_end.file 46 music-credits.mus 43 credits.cmp

sizes_files.sym: level1.map level2.map level3.map level4.map level5.map level6.map level7.map level8.map level9.map level0.map ianna.spr intro.bin sizes_files.asm
	cat intro01a.px.cmp intro02a.px.cmp intro03a.px.cmp intro04a.px.cmp intro05a.px.cmp intro01a.at.cmp intro02a.at.cmp intro03a.at.cmp intro04a.at.cmp intro05a.at.cmp > intro_screens.file
	cat intro02a.px.cmp final02a.px.cmp final03a.px.cmp intro02a.at.cmp final02a.at.cmp final03a.at.cmp > intro_end.file
	pasmo sizes_files.asm nul.bin sizes_files.sym

loader_tap:
	zmakebas -a 10 -n IANNA -o SwordOfIanna.tap loader_tap.bas
	apack 48k.scr 48k.cmp 
	pasmo tapeload.asm tapeload.bin 
	./gentap --out SwordOfIanna.tap --name loader --addr 0x5e24 0xFF tapeload.bin

ianna-tap.bin: ianna.asm tiles.asm drawsprite.asm input.asm im2.asm rambank.asm entities.asm scripts.asm sprite.asm sprite_barbaro.asm sprite_esqueleto.asm objects.asm depack.asm sizes_files.sym io-tap.asm ram3.sym music.asm score.asm io.asm 
	pasmo -E IO_DRIVER=6 ianna.asm ianna-tap.bin ianna-tap.sym


ianna-3dos.dsk: sizes_files.sym ianna-3dos.bin level1.map level2.map level3.map level4.map level5.map level6.map level7.map level8.map level9.map level0.map ram3.bin diskload.bin.zxb disk  ianna.spr menu.asm marcador.scr menu_screen.cmp barbaro_sword.cmp barbaro_eclipse.cmp barbaro_axe.cmp barbaro_blade.cmp intro.asm intro.bin loading.scr
	cat ianna-3dos.sym > ianna.sym
	pasmo menu.asm menu.bin menu-3dos.sym
	cat ianna-3dos.bin > ianna.bin
	cat level1.map level2.map level3.map level4.map level5.map level6.map > ianna.dat
	cat level7.map level8.map level0.map level9.map > ianna2.dat
	cat loading.scr ram3.bin menu.bin ianna.bin > ianna.gam
	mkp3fs -720 -cpmonly ianna-3dos.dsk disk ianna.gam ianna.dat ianna2.dat ianna.spr diskload.bin.zxb intro.bin
	mkp3fs -180 -cpmonly ianna-sidea.dsk disk ianna.gam diskload.bin.zxb
	mkp3fs -180 -cpmonly ianna-sideb.dsk ianna.dat ianna2.dat ianna.spr intro.bin

ianna-sect.dsk: ianna-sect.bin level1.map level2.map level3.map level4.map level5.map level6.map level7.map level8.map level9.map level0.map ram3.bin stage2.bin bootsector.bin ianna.spr menu.asm marcador.scr menu_screen.cmp barbaro_sword.cmp barbaro_eclipse.cmp barbaro_axe.cmp barbaro_blade.cmp intro.asm intro.bin
	cat ianna-sect.sym > ianna.sym
	pasmo menu.asm menu.bin menu-sect.sym
	cat ianna-sect.bin > ianna.bin
	cat ram3.bin ianna.bin > ianna.gam
#	mono DSKGen.exe ianna_sect.xml
	dskgen -o ianna-sect.dsk --config ianna_sect.json

sword.hdf: ianna-esxdos.bin level1.map level2.map level3.map level4.map level5.map level6.map level7.map level8.map level9.map level0.map ram3.bin esxload.bin loader ianna.spr menu.asm marcador.scr menu_screen.cmp barbaro_sword.cmp barbaro_eclipse.cmp barbaro_axe.cmp barbaro_blade.cmp intro.asm intro.bin loading.scr
	cat ianna-esxdos.sym > ianna.sym
	pasmo menu.asm menu.bin menu-esxdos.sym
	cat ianna-esxdos.bin > ianna.bin
	cat level1.map level2.map level3.map level4.map level5.map level6.map > ianna.dat
	cat level7.map level8.map level0.map level9.map > ianna2.dat
	cat loading.scr ram3.bin menu.bin ianna.bin > ianna.gam	
	hdfmonkey create sword.hdf 64M Ianna
	hdfmonkey format sword.hdf Ianna
	hdfmonkey mkdir sword.hdf sword
	hdfmonkey put sword.hdf esxdos/*    /
	hdfmonkey put sword.hdf loader      /sword/loader.bas
	hdfmonkey put sword.hdf ianna.spr   /sword
	hdfmonkey put sword.hdf ianna.dat   /sword
	hdfmonkey put sword.hdf ianna2.dat  /sword
	hdfmonkey put sword.hdf ianna.gam   /sword
	hdfmonkey put sword.hdf esxload.bin /sword
	hdfmonkey put sword.hdf intro.bin   /sword
	mkdir -p iannasd
	cp loader iannasd/loader.bas
	cp ianna.spr iannasd/ianna.spr
	cp ianna.dat iannasd/ianna.dat
	cp ianna2.dat iannasd/ianna2.dat
	cp ianna.gam iannasd/ianna.gam
	cp esxload.bin iannasd/esxload.bin
	cp intro.bin iannasd/intro.bin


stage2.bin: diskload-sect.asm
	pasmo diskload-sect.asm stage2.bin

disk: loader.bas
	zmakebas -a 10 -n disk -o disk.tap loader.bas
	tapget disk.tap disk

loader: loader-esxdos.bas
	zmakebas -a 10 -n loader -o loader-esxdos.tap loader-esxdos.bas
	tapget loader-esxdos.tap loader

diskload.bin.zxb: diskload.bin
	specform diskload.bin

diskload.bin: diskload.asm
	pasmo diskload.asm diskload.bin	

esxloader.bin: esxloader.asm
	pasmo esxloader.asm esxloader.bin

esxload.bin: esxloader.bin
	specform esxloader.bin
	mv esxloader.bin.zxb esxload.bin

bootsector.bin: bootsector.asm
	pasmo bootsector.asm bootsector.bin

ianna-3dos.bin: ianna.asm tiles.asm drawsprite.asm input.asm im2.asm rambank.asm entities.asm scripts.asm sprite.asm sprite_barbaro.asm sprite_esqueleto.asm objects.asm depack.asm io-3dos.asm ram3.sym music.asm score.asm io.asm
	pasmo -E IO_DRIVER=1 ianna.asm ianna-3dos.bin ianna-3dos.sym

ianna-sect.bin: ianna.asm tiles.asm drawsprite.asm input.asm im2.asm rambank.asm entities.asm scripts.asm sprite.asm sprite_barbaro.asm sprite_esqueleto.asm objects.asm depack.asm io-sect.asm ram3.sym music.asm score.asm io.asm
	pasmo -E IO_DRIVER=2 ianna.asm ianna-sect.bin ianna-sect.sym

ianna-esxdos.bin: ianna.asm tiles.asm drawsprite.asm input.asm im2.asm rambank.asm entities.asm scripts.asm sprite.asm sprite_barbaro.asm sprite_esqueleto.asm objects.asm depack.asm io-esxdos.asm ram3.sym music.asm score.asm io.asm
	pasmo -E IO_DRIVER=3 ianna.asm ianna-esxdos.bin ianna-esxdos.sym

ianna-cart.bin: ianna.asm tiles.asm drawsprite.asm input.asm im2.asm rambank.asm entities.asm scripts.asm sprite.asm sprite_barbaro.asm sprite_esqueleto.asm objects.asm depack.asm io-cart.asm ram3.sym music.asm score.asm io.asm
	pasmo -E IO_DRIVER=4 ianna.asm ianna-cart.bin ianna-cart.sym

ianna-dan.rom: ianna-cart.rom dandanator/eewriter_slot31
	dd if=/dev/zero of=tmpfile.bin bs=16384 count=31
	cat ianna-cart.rom tmpfile.bin | dd bs=16384 count=31 of=tmpfile2.bin
	cat tmpfile2.bin dandanator/eewriter_slot31 > ianna-dan.rom

ram3.sym: ram3.bin
ram3.bin: ram3.asm atPlayer.speccy.asm iannafx.mus music-nomusic.pck music-level1.pck music-level3.pck music-level4.pck music-level5.pck music-level6.pck music-level7.pck music-level8.pck music-gameover.pck music-menu.pck
	pasmo ram3.asm ram3.bin ram3.sym

music-nomusic.pck: music-nomusic.mus
	apack music-nomusic.mus music-nomusic.pck

music-level1.pck: music-level1.mus
	apack music-level1.mus music-level1.pck

music-level3.pck: music-level3.mus
	apack music-level3.mus music-level3.pck

music-level4.pck: music-level4.mus
	apack music-level4.mus music-level4.pck

music-level5.pck: music-level5.mus
	apack music-level5.mus music-level5.pck

music-level6.pck: music-level6.mus
	apack music-level6.mus music-level6.pck

music-level7.pck: music-level7.mus
	apack music-level7.mus music-level7.pck

music-level8.pck: music-level8.mus
	apack music-level8.mus music-level8.pck

music-gameover.pck: music-gameover.mus
	apack music-gameover.mus music-gameover.pck

music-menu.pck: music-menu.mus
	apack music-menu.mus music-menu.pck

ianna.spr: sprite_esqueleto.cmp sprite_orc.cmp sprite_mummy.cmp sprite_troll.cmp sprite_rollingstone.cmp sprite_golem_inf.cmp sprite_golem_sup.cmp sprite_caballerorenegado.cmp sprite_dalgurak.cmp sprite_demonio_inf.cmp sprite_demonio_sup.cmp sprite_minotauro_inf.cmp sprite_minotauro_sup.cmp sprite_ogro_inf.cmp sprite_ogro_sup.cmp
	cat sprite_esqueleto.cmp sprite_orc.cmp sprite_mummy.cmp sprite_troll.cmp sprite_rollingstone.cmp sprite_caballerorenegado.cmp sprite_dalgurak.cmp sprite_golem_inf.cmp  sprite_ogro_inf.cmp sprite_minotauro_inf.cmp  sprite_demonio_inf.cmp sprite_golem_sup.cmp sprite_ogro_sup.cmp sprite_minotauro_sup.cmp sprite_demonio_sup.cmp  > ianna.spr

sprite_caballerorenegado.cmp: sprite_caballerorenegado.asm
	pasmo sprite_caballerorenegado.asm sprite_caballerorenegado.bin
	apack sprite_caballerorenegado.bin sprite_caballerorenegado.cmp

sprite_dalgurak.cmp: sprite_dalgurak.asm
	pasmo sprite_dalgurak.asm sprite_dalgurak.bin
	apack sprite_dalgurak.bin sprite_dalgurak.cmp

sprite_demonio_inf.cmp: sprite_demonio_inf.asm
	pasmo sprite_demonio_inf.asm sprite_demonio_inf.bin
	apack sprite_demonio_inf.bin sprite_demonio_inf.cmp

sprite_demonio_sup.cmp: sprite_demonio_sup.asm
	pasmo sprite_demonio_sup.asm sprite_demonio_sup.bin
	apack sprite_demonio_sup.bin sprite_demonio_sup.cmp

sprite_minotauro_inf.cmp: sprite_minotauro_inf.asm
	pasmo sprite_minotauro_inf.asm sprite_minotauro_inf.bin
	apack sprite_minotauro_inf.bin sprite_minotauro_inf.cmp

sprite_minotauro_sup.cmp: sprite_minotauro_sup.asm
	pasmo sprite_minotauro_sup.asm sprite_minotauro_sup.bin
	apack sprite_minotauro_sup.bin sprite_minotauro_sup.cmp

sprite_ogro_inf.cmp: sprite_ogro_inf.asm
	pasmo sprite_ogro_inf.asm sprite_ogro_inf.bin
	apack sprite_ogro_inf.bin sprite_ogro_inf.cmp

sprite_ogro_sup.cmp: sprite_ogro_sup.asm
	pasmo sprite_ogro_sup.asm sprite_ogro_sup.bin
	apack sprite_ogro_sup.bin sprite_ogro_sup.cmp

sprite_esqueleto.cmp: sprite_esqueleto.asm
	pasmo sprite_esqueleto.asm sprite_esqueleto.bin
	apack sprite_esqueleto.bin sprite_esqueleto.cmp

sprite_troll.cmp: sprite_troll.asm
	pasmo sprite_troll.asm sprite_troll.bin
	apack sprite_troll.bin sprite_troll.cmp

sprite_orc.cmp: sprite_orc.asm
	pasmo sprite_orc.asm sprite_orc.bin
	apack sprite_orc.bin sprite_orc.cmp

sprite_mummy.cmp: sprite_mummy.asm
	pasmo sprite_mummy.asm sprite_mummy.bin
	apack sprite_mummy.bin sprite_mummy.cmp

sprite_rollingstone.cmp: sprite_rollingstone.asm
	pasmo sprite_rollingstone.asm sprite_rollingstone.bin
	apack sprite_rollingstone.bin sprite_rollingstone.cmp

sprite_golem_inf.cmp: sprite_golem_inf.asm
	pasmo sprite_golem_inf.asm sprite_golem_inf.bin
	apack sprite_golem_inf.bin sprite_golem_inf.cmp 

sprite_golem_sup.cmp: sprite_golem_sup.asm
	pasmo sprite_golem_sup.asm sprite_golem_sup.bin
	apack sprite_golem_sup.bin sprite_golem_sup.cmp

barbaro_sword.cmp: barbaro_sword.asm
	pasmo barbaro_sword.asm barbaro_sword.bin
	apack barbaro_sword.bin barbaro_sword.cmp

barbaro_eclipse.cmp: barbaro_eclipse.asm
	pasmo barbaro_eclipse.asm barbaro_eclipse.bin
	apack barbaro_eclipse.bin barbaro_eclipse.cmp

barbaro_axe.cmp: barbaro_axe.asm
	pasmo barbaro_axe.asm barbaro_axe.bin
	apack barbaro_axe.bin barbaro_axe.cmp

barbaro_blade.cmp: barbaro_blade.asm
	pasmo barbaro_blade.asm barbaro_blade.bin
	apack barbaro_blade.bin barbaro_blade.cmp

menu_screen.cmp: menu_screen.scr
	apack menu_screen.scr menu_screen.cmp


dandanator/nmiroutine.bin: dandanator/nmiroutine.asm dandanator/print_routines.asm dandanator/charset.bin dandanator/pic-fw.bin
	cd dandanator && pasmo nmiroutine.asm nmiroutine.bin && cd -

eeprom_writer.bin: eeprom_writer.asm
	pasmo eeprom_writer.asm eeprom_writer.bin eeprom_writer.sym

cartload.bin: cartload.asm
	pasmo cartload.asm cartload.bin cartload.sym

48k.pck: 48k.scr
	apack 48k.scr 48k.pck

cartboot.bin: cartboot.asm cartload.bin 48k.pck dandanator/nmiroutine.bin dandanator/eeprom_writer_offset.asm
	pasmo cartboot.asm cartboot.bin

intro_marco.cmp: intro_marco.scr
	apack intro_marco.scr intro_marco.cmp
credits.cmp: credits.scr
	apack credits.scr credits.cmp
intro01a.px.cmp: intro01a.px
	apack intro01a.px intro01a.px.cmp
intro02a.px.cmp: intro02a.px
	apack intro02a.px intro02a.px.cmp
intro03a.px.cmp: intro03a.px
	apack intro03a.px intro03a.px.cmp
intro04a.px.cmp: intro04a.px
	apack intro04a.px intro04a.px.cmp
intro05a.px.cmp: intro05a.px
	apack intro05a.px intro05a.px.cmp
intro01a.at.cmp: intro01a.at
	apack intro01a.at intro01a.at.cmp
intro02a.at.cmp: intro02a.at
	apack intro02a.at intro02a.at.cmp
intro03a.at.cmp: intro03a.at
	apack intro03a.at intro03a.at.cmp
intro04a.at.cmp: intro04a.at
	apack intro04a.at intro04a.at.cmp
intro05a.at.cmp: intro05a.at
	apack intro05a.at intro05a.at.cmp

final02a.px.cmp: final02a.px
	apack final02a.px final02a.px.cmp
final02a.at.cmp: final02a.at
	apack final02a.at final02a.at.cmp
final03a.px.cmp: final03a.px
	apack final03a.px final03a.px.cmp
final03a.at.cmp: final03a.at
	apack final03a.at final03a.at.cmp

intro.bin: intro_marco.cmp intro01a.px.cmp intro01a.at.cmp intro02a.px.cmp intro02a.at.cmp intro03a.px.cmp intro03a.at.cmp intro04a.px.cmp intro04a.at.cmp intro05a.px.cmp intro05a.at.cmp final02a.px.cmp final02a.at.cmp final03a.px.cmp final03a.at.cmp credits.cmp music-intro.mus music-end.mus music-credits.mus
	cat intro_marco.cmp intro01a.px.cmp intro02a.px.cmp intro03a.px.cmp intro04a.px.cmp intro05a.px.cmp intro01a.at.cmp intro02a.at.cmp intro03a.at.cmp intro04a.at.cmp intro05a.at.cmp intro02a.px.cmp final02a.px.cmp final03a.px.cmp intro02a.at.cmp final02a.at.cmp final03a.at.cmp credits.cmp music-intro.mus music-end.mus music-credits.mus > intro.bin

ianna-cart.rom: cartboot.bin ianna-cart.bin level1.map level2.map level3.map level4.map level5.map level6.map level7.map level8.map level9.map level0.map ram3.bin ianna.spr menu.asm marcador.scr menu_screen.cmp barbaro_sword.cmp barbaro_eclipse.cmp barbaro_axe.cmp barbaro_blade.cmp intro.asm intro.bin loading.scr eeprom_writer.bin
	cat ianna-cart.sym > ianna.sym
	pasmo menu.asm menu.bin menu-cart.sym
	dd if=ianna-cart.bin of=tmpfile.bin bs=1 count=8192
	cat cartboot.bin tmpfile.bin > tmpfile2.bin
	fill16k tmpfile2.bin ianna-0.rom
	rm -f tmpfile.bin tmpfile2.bin
	dd if=ianna-cart.bin of=ianna-1.rom bs=1 count=16384 skip=8192
	dd if=ianna-cart.bin of=tmpfile.bin bs=1 count=15872 skip=24576
	fill16k tmpfile.bin ianna-2.rom
	rm -f tmpfile.bin
	fill16k menu.bin ianna-3.rom
	fill16k ram3.bin ianna-4.rom
	dd if=ianna.spr of=tmpfile.bin bs=1 count=14327
	fill16k tmpfile.bin ianna-5.rom
	cat level1.map level0.map > tmpfile.bin
	fill16k tmpfile.bin ianna-6.rom
	rm -f tmpfile.bin
	fill16k level2.map ianna-7.rom
	fill16k level3.map ianna-8.rom
	fill16k level4.map ianna-9.rom
	fill16k level5.map ianna-10.rom
	fill16k level6.map ianna-11.rom
	fill16k level7.map ianna-12.rom
	fill16k level8.map ianna-13.rom
	fill16k level9.map ianna-15.rom
	dd if=ianna.spr of=tmpfile.bin bs=1 skip=14327
	fill16k tmpfile.bin ianna-14.rom
	rm -f tmpfile.bin
	fill16k intro.bin ianna-16.rom
	fill16k loading.scr ianna-17.rom
	fill16k eeprom_writer.bin ianna-18.rom
	cat ianna-0.rom ianna-1.rom ianna-2.rom ianna-3.rom ianna-4.rom ianna-5.rom ianna-6.rom ianna-7.rom ianna-8.rom ianna-9.rom ianna-10.rom ianna-11.rom ianna-12.rom ianna-13.rom ianna-14.rom ianna-15.rom ianna-16.rom ianna-17.rom ianna-18.rom > ianna-cart.rom


if2load.bin: if2load.asm
	pasmo if2load.asm if2load.bin if2load.sym

if2boot.bin: if2boot.asm if2load.bin 48k.pck
	pasmo if2boot.asm if2boot.bin

ianna-if2.bin: ianna.asm tiles.asm drawsprite.asm input.asm im2.asm rambank.asm entities.asm scripts.asm sprite.asm sprite_barbaro.asm sprite_esqueleto.asm objects.asm depack.asm io-if2.asm ram3.sym music.asm score.asm io.asm
	pasmo -E IO_DRIVER=5 ianna.asm ianna-if2.bin ianna-if2.sym

ianna-if2.rom: if2boot.bin ianna-if2.bin level1.map level2.map level3.map level4.map level5.map level6.map level7.map level8.map level9.map level0.map ram3.bin ianna.spr menu.asm marcador.scr menu_screen.cmp barbaro_sword.cmp barbaro_eclipse.cmp barbaro_axe.cmp barbaro_blade.cmp intro.asm intro.bin loading.scr
	cat ianna-if2.sym > ianna.sym
	pasmo menu.asm menu.bin menu-if2.sym
	dd if=ianna-if2.bin of=tmpfile.bin bs=1 count=8188
	cat if2boot.bin tmpfile.bin > tmpfile2.bin
	fill16k tmpfile2.bin ianna-0.rom
	rm -f tmpfile.bin tmpfile2.bin
	dd if=ianna-if2.bin of=tmpfile.bin bs=1 count=16380 skip=8188
	fill16k tmpfile.bin ianna-1.rom
	rm -f tmpfile.bin
	dd if=ianna-if2.bin of=tmpfile.bin bs=1 count=15880 skip=24568
	fill16k tmpfile.bin ianna-2.rom
	rm -f tmpfile.bin
	fill16k menu.bin ianna-3.rom
	fill16k ram3.bin ianna-4.rom
	dd if=ianna.spr of=tmpfile.bin bs=1 count=14327
	fill16k tmpfile.bin ianna-5.rom
	cat level1.map level0.map > tmpfile.bin
	fill16k tmpfile.bin ianna-6.rom
	rm -f tmpfile.bin
	fill16k level2.map ianna-7.rom
	fill16k level3.map ianna-8.rom
	fill16k level4.map ianna-9.rom
	fill16k level5.map ianna-10.rom
	fill16k level6.map ianna-11.rom
	fill16k level7.map ianna-12.rom
	fill16k level8.map ianna-13.rom
	fill16k level9.map ianna-15.rom
	dd if=ianna.spr of=tmpfile.bin bs=1 skip=14327
	fill16k tmpfile.bin ianna-14.rom
	rm -f tmpfile.bin
	fill16k intro.bin ianna-16.rom
	fill16k loading.scr ianna-17.rom
	cat ianna-0.rom ianna-1.rom ianna-2.rom ianna-3.rom ianna-4.rom ianna-5.rom ianna-6.rom ianna-7.rom ianna-8.rom ianna-9.rom ianna-10.rom ianna-11.rom ianna-12.rom ianna-13.rom ianna-14.rom ianna-15.rom ianna-16.rom ianna-17.rom > ianna-if2.rom
