	output ianna-cart.rom

	org 0
rom0
	DISP 0
	incbin "cartboot.bin"
	incbin "ianna-0.bin"
	block 16384-$,0
	ENT
rom1
	DISP 0
	incbin "ianna-1.bin"
	block 16384-$,0
	ENT
rom2
	DISP 0
	incbin "ianna-2.bin"
	block 16384-$,0
	ENT
rom3
	DISP 0
	incbin "menu.bin" 		;ianna-3-rom	
	block 16384-$,0
	ENT
rom4	
	DISP 0
	incbin "ram3.bin"		;ianna-4.rom	
	block 16384-$,0
	ENT
rom5	
	DISP 0
	incbin "ianna-5.bin"		;ianna-5.rom			
	block 16384-$,0
	ENT
rom6	
	DISP 0
	incbin "level1.map"
	incbin "level0.map"		;ianna-6.rom
	block 16384-$,0
	ENT
rom7	
	DISP 0
	incbin "level2.map" 		;ianna-7.rom	
	block 16384-$,0
	ENT
rom8	
	DISP 0
	incbin "level3.map" 	
	block 16384-$,0
	ENT
rom9	
	DISP 0
	incbin "level4.map" 	
	block 16384-$,0
	ENT
rom10	
	DISP 0
	incbin "level5.map" 	
	block 16384-$,0
	ENT
rom11
	DISP 0
	incbin "level6.map" 	
	block 16384-$,0
	ENT
rom12
	DISP 0
	incbin "level7.map" 	
	block 16384-$,0
	ENT
rom13	
	DISP 0
	incbin "level8.map" 
	block 16384-$,0
	ENT
rom14
	DISP 0
	incbin "ianna-14.bin"		
	block 16384-$,0
	ENT
rom15	
	DISP 0
	incbin "level9.map"
	block 16384-$,0
	ENT
rom16	
	DISP 0
	incbin "intro.bin"
	block 16384-$,0
	ENT
rom17	
	DISP 0
	incbin "loading.scr"
	block 16384-$,0
	ENT
rom18	
	DISP 0
	incbin "eeprom_writer.bin"
	block 16384-$,0
	ENT

rom19
	DISP 0
	
	block 16384-$,0
	ENT
rom20
	DISP 0
	
	block 16384-$,0
	ENT
rom21
	DISP 0
	
	block 16384-$,0
	ENT
rom22
	DISP 0
	
	block 16384-$,0
	ENT
rom23
	DISP 0
	
	block 16384-$,0
	ENT
rom24
	DISP 0
	
	block 16384-$,0
	ENT
rom25
	DISP 0
	
	block 16384-$,0
	ENT
rom26
	DISP 0
	
	block 16384-$,0
	ENT
rom27
	DISP 0
	
	block 16384-$,0
	ENT
rom28
	DISP 0
	
	block 16384-$,0
	ENT
rom29
	DISP 0
	
	block 16384-$,0
	ENT
rom30
	DISP 0
	
	block 16384-$,0
	ENT
rom31
	DISP 0
	incbin "dandanator/eewriter_slot31"
	block 16384-$,0
	ENT

/*	
	block 16384-$,0-endmensaje+mensaje,$ff
mensaje
	defb "MLD created by Spirax 2018"
endmensaje
	ENT
	
*/
