	output "Sword of Ianna.mld"
	include "ianna48k.sym" 		;<<< todas las posicones del IANNA para poder imprimir algunos datos al compilar este asm
;Algunas definiciones de variables del sistema
	define  tr $ffff &
	define  BANKM $5b5c
	define  BANK678 $5b67

;Algunos defines para el fichero MDL
	define MLD48k  $83
	define MLD128k  $88
	define MLD2A  $C8	
	define LenFiladatos 8
	define romgrabado	1
	define esun128k 24575
	define traineractivado  24574

rom1	
	org 0
	include "inicio_rom.asm"					;incluye definidos los RST
	ld sp, 24573
	ld bc, $7ffd
	ld de, $1110
	ld hl, $C000
	out (c),d
	ld a, (hl)
	out (c),e
	cpl
	ld (hl),a
	cpl
	out (c),d
	cp (hl)
	ld (hl),a
	jr nz, es48k
	ld a, $10
	out (c),a
	ld (BANKM),a
	ld a, 1
	jr es128k
es48k
	xor a
es128k
	ld (esun128k), a

	ld hl, movercodigo					
	ld de, codigo						
	ld bc, endcommandos-codigo			
	ldir								;movemos la tabla de datos y el cargador a la memoria donde no se vaya a modificar

	call MENUBEGIN						;The routine run from THIS SLOT
	di
;	ld a, $FB
;  	IN A, ($FE)						; leemos fila QWERT
;	BIT 4, A                		; comprabamos la tecla T
;	jr nz,  notrainer
;	ld a, 1
;	jr activatrainer
;notrainer
;	xor a
;activatrainer
;	ld (traineractivado), a
	jp  codigocargador					;saltamos al codigo en la memoria principal

movercodigo
	DISP #5d00 
codigo
	display "MLDoffset2 ",/d,$
MLDoffset2	
	defb 0
	display "Sectorgrabar ",/d,$
sectorgrabar
	defb 0
	display "Romsectorgabar ",/d,$
romsectorgrabar
	defb 0
	display "HLsectorgrabar ",/d,$
hlsectorgrabar
	defw 0
	display "Save Prefs ",/d,$
saveprefs
	di
	push af
	push bc
	push de
	push hl

	ld a, (romsectorgrabar)				;cogemos el offset del MLD
	call enviacomandosimple				;la paginamos
	ld a, (sectorgrabar)
	ld e, a 							;lo dejamos en E para selecionar el sector
	ld a, 48							;comando borrar epprom
	ld d, 16							;en D comando borrar sector y en E el numero de sector
	call enviacomandomultiple
	ld hl, (hlsectorgrabar)
	call borrarsector
	ld a, 48							;comando grabar epprom
	ld d, 32							;en D comando grabar sector y en E el numero de secto calculado anteriormente
	call enviacomandomultiple
	pop hl
	ld de, (hlsectorgrabar)
	ld bc, 16							;4096
	call grabareprom
	call grabarepromnull
	
	ld a, (MLDoffset2)					;cogemos el offset del MLD
	inc a								;ponemos el primer slot 
	call enviacomandosimple				;la paginamos
	pop de
	pop bc
	pop af
	ret
	
	display "Envia c simple ",/d,$
enviacomandosimple
	ld hl, 1							;para comando simple iniciamos hl = 1
comando
	ld b, a								;ponemos en b el contador de pulsos
buclecambiarom
	nop  								;12 t-states 
	nop
	nop
	ld (hl),a							;hacemos el pulso hl=1 para comando, hl=2 para data1, hl=3 para data2 (compatible ZesarUX)
	djnz buclecambiarom
	ld b, 48							;hacemos una pausa para permitir el reconocimiento del envio
pausacomando
	djnz pausacomando
	ret	

	;display "Envia c multiple ",/d,$
enviacomandomultiple
	ld hl, 1							;iniciamos hl a 1 para enviar el primer comando
	call comando	
	inc hl								;ponemos hl a 2 para enviar data 1 almacenado en d
	ld a, d
	call comando
	inc hl								;ponemos hl a 3 para enviar el data 2 almacenado en e
	ld a, e
	call comando
	ld (0), a							;enviamos un pulso a 0 para ejecutar el comando
	jr pausacomando	- 2					;y hacemos una pausa para que lo interprete

	display "Bloquea dandanator ",/d,$
bloqueardandanator
	ld a, 46
	ld de,$0101
	jr enviacomandomultiple				;bloquea el dandanator
	display "Activa dandanator ",/d,$
activardandanator
	ld a, 46
	ld de,$1010
	jr enviacomandomultiple				;Activamos el dandanator


grabareprom			
	push bc
	call comandograbar
	ld a, (hl)
	ld (de),a
	inc hl
	inc de
	pop bc
	dec bc
	ld a,b							
	or c
	jr nz, grabareprom
	ret

grabarepromnull			
	call comandograbar
	ld a, $FF
	ld (de),a
	inc de
	ld a, d
	and $0F	
	or e						
	jr nz, grabarepromnull
	ret

comandograbar
	ld bc, $1555				
	ld a, $AA
	ld (bc),A
	ld bc, $2AAA
	ld a, $55
	ld (bc),A
	ld bc, $1555	
	ld a, $A0
	ld (bc),A	
	ret
	
borrarsector
	ld bc, $1555				; Five Step Command to allow Sector Erase
	ld a, $AA
	ld (bc),a			
	ld bc, $2AAA				
	ld a, $55
	ld (bc),a	
	ld bc, $1555				
	ld a, $80
	ld (bc),a
	ld bc, $1555				
	ld a, $AA
	ld (bc),a
	ld bc, $2AAA				
	ld a, $55
	ld (bc),a
	ld a, $30					; Actual sector erase		
	ld (hl),a
	ld bc,1400					; wait over 25 ms for Sector erase to complete (datasheet pag 13) -> 1400*18us= 25,2 ms
waitset							; Loop ts = 64ts -> aprox 18us on 128k machines
	ex (sp),hl					; 19ts
	ex (sp),hl					; 19ts
	dec bc						; 6ts
	ld a,b						; 4ts
	or c						; 4ts
	jr nz, waitset				; 12ts / 7ts
	ret							; 10ts

	display "Inicio Cargador ",/d,$
codigocargador
	call activardandanator
	ld a, (MLDoffset)
	ld (MLDoffset2), a
	inc a
	ld (romsectorgrabar), a
	dec a
	add a, a								;multiplicamos el numero de rom x 4 para conocer el primer sector de la rom donde esta la partida guardada
	add a, a
	ld e, 2								;y le sumamos 2 ya que vamos a usar el sector ..x. de la rom selecionada
	add a, e
	ld (sectorgrabar), a
	ld hl, $2000						;direccion de inicio de las preferencias
	ld (hlsectorgrabar), hl		
	
	ld ix, b_pantalla
	ld b, 1							    ;ponemos la cantidad de bloques a procesar
	call bucle1							;procesa el numero de bloques y copia o descomprime

	ld a, (MLDoffset2)					
	inc a
	call enviacomandosimple				;ponemos la rom1 para las rutinas de pantalla
	xor a
	call cortinaborrado
	call cortinadoble
	di

	ld a, (esun128k)
	or a
	jr nz, continuacargacomo128
	ld de, 16816
	ld hl, graficoen48k
	ld b, 5
buclegrafico48k
	ld a, (hl)
	ld (de), a
	inc de
	inc hl
	ld a, (hl)
	ld (de), a
	inc hl
	dec de
	inc d
	djnz buclegrafico48k
	ld ix, b_principal48				;ponemos el puntero para los bloques a cargar de 48k
	ld b, 2								;ponemos la cantidad de bloques a procesar
	jr continuaconcargacomun
continuacargacomo128
	ld ix, b_principal128				;ponemos el puntero para los bloques a cargar de 128k
	ld b, 16								;ponemos la cantidad de bloques a procesar

continuaconcargacomun
	call bucle1							;procesa el numero de bloques y copia o descomprime

arrancajuego
	ld a, (MLDoffset2)					
	inc a
	call enviacomandosimple				;ponemos la rom1 para el pulsa tecla

	ld de, 20616						;posición en pantalla para el mensaje press a key
	call pulsatecla						;solo imprime 

	ld a, (esun128k)
	or a
	jr nz, continuateclacomo128

	;estamos en modo 48k
	ld a, (MLDoffset2)
	inc a
	ld (rombank), a						;definimos el rombank actual a partir de aqui se va a usar esta variable 
										;para actualizar la rom en la que estamos en modo 48k
	ld a, 1 							
	call Music_Play						;cargamos y reprducimos musica Intro permitiendo break con tecla

;	ld a, (traineractivado)				;comprobamos si hay que activar el trainer cambiando el JR ;)
;	or a								;solo en modo 48k y en el MLD
;	jr z, continuateclacomun			;salta al inicio del juego
;	xor a
;	ld (trainer),a						;activamos el trainer
	jr continuateclacomun				;salta al inicio del juego	

	;estamos en 128k
continuateclacomo128
	ld a, 1								;ponemos borde azul mientras esperamos
	out ($FE), a
	call waitkp							;en 128k espera a que se pulse una tecla
	
	;seguimos comun
continuateclacomun
	xor a
	out ($FE), a						;ponemos borde negro
	jp 24576							;salta al inicio del juego

bucle1
	push bc								;guardamos el contador de bloques a procesar
	call recolecta						;lo pasamos a la memoria
	ld a, b								;comprobamos BC
	or c
	jr z, descomprimirbloque			;si es 0 esta comprimido saltamos a descomprimir
	ldir								;si no es 0 copiamos BC bytes a la memoria
	jr sincompresion					;y nos saltamos la compresion
descomprimirbloque	
	call dzx7							;lo descomprimimos a memoria
sincompresion
	ld bc, LenFiladatos					;ponemos el tamaño de cada puntero de informacion
	add ix, bc							;pasamos al siguiente puntero
	pop bc								;recuperamos el contador
	djnz bucle1							;y seguimos hasta procesar todos los bloques
	ret									

recolecta	
	ld a, (ix+0)						;el generador de roms nos ha modificado la tabla con el slot correcto
	call enviacomandosimple				;lo paginamos a rom
	ld b, (ix+7)						;B = pagina de RAM
	ld a, (esun128k)
	or a
	call nz, cambiabanco				;solo la cambiamos si es un 128k
	ld l, (ix+1)						;cogemos origen en rom
	ld h, (ix+2)
	ld e, (ix+3)						;cogemos destino en ram
	ld d, (ix+4)						
	ld c, (ix+5)						;cogemos tamaño, si tamaño es 0 hay que descomprimir
	ld b, (ix+6)								
	ret

cambiabanco
	ld a, (BANKM)						;recuperamos el estado actual de la variable del sistema
	and %11101000   					;dejamos todos los bits como estan excepto la rom y la memoria
	or b								;y le añadimos lo que queremos cambiar
	ld (BANKM), a						;lo guardamos en la variable del sistema
	ld bc, $7ffd						;ponemos el puerto de salida
	out (c), a							;y ejecutamos el cambio
	ret

	
tabladatos
;	display " tabladatos ",/D,tabladatos
;	display " posicion rom ",/d,tabladatos-codigo+movercodigo

b_principal48
	defb 2					;rom
	defw ianna_p1			;hl		bloue principal de 48k
	defw 24576				;de
	defw 0					;bc
	defb $10				;ram	ignorado pero necesario para que toda la tabla sea del mismo tamaño

	defb 5					;rom
	defw ianna_p3			;hl		el bloque de prites es compartido en 48k y 128k
	defw 49152				;de
	defw 0					;bc
	defb $10				;ram	ignorado pero necesario para que toda la tabla sea del mismo tamaño

b_principal128
	defb 15					;rom
	defw menu128.1			;hl		
	defw 32768				;de		cargamos los trozitos del menu en 32768 para descomprimir despues en la ram 6 a 49152
	defw endmenu128.1-menu128.1	;bc
	defb $16				;ram

	defb 14					;rom
	defw menu128.2			;hl		
	defw 32768+3696			;de
	defw endmenu128.2-menu128.2	;bc
	defb $16				;ram

	defb 13					;rom
	defw menu128.3			;hl		
	defw 32768+4031			;de
	defw endmenu128.3-menu128.3	;bc
	defb $16				;ram

	defb 12					;rom
	defw menu128.4			;hl		
	defw 32768+5555			;de
	defw endmenu128.4-menu128.4	;bc
	defb $16				;ram

	defb 11					;rom
	defw menu128.5			;hl		
	defw 32768+7538			;de
	defw endmenu128.5-menu128.5	;bc
	defb $16				;ram

	defb 10					;rom
	defw menu128.6			;hl		
	defw 32768+7829			;de
	defw endmenu128.6-menu128.6	;bc
	defb $16				;ram

	defb 8					;rom
	defw menu128.7			;hl		
	defw 32768+7882			;de
	defw endmenu128.7-menu128.7	;bc
	defb $16				;ram

	defb 7					;rom
	defw menu128.8			;hl		
	defw 32768+8114			;de
	defw endmenu128.8-menu128.8	;bc
	defb $16				;ram

	defb 5					;rom
	defw menu128.9			;hl		
	defw 32768+10141		;de
	defw endmenu128.9-menu128.9	;bc
	defb $16				;ram

	defb 3					;rom
	defw menu128.10			;hl		
	defw 32768+10775		;de
	defw endmenu128.10-menu128.10	;bc
	defb $16				;ram

	defb 1					;rom
	defw menu128.11			;hl		
	defw 32768+11490			;de
	defw endmenu128.11-menu128.11	;bc
	defb $16				;ram

	defb 1					;rom
	defw menu128.12			;hl		
	defw 32768+13740		;de
	defw endmenu128.12-menu128.12	;bc
	defb $16				;ram

	defb 1					;rom	
	defw 32768				;hl		
	defw 49152				;de		descomprimimos el menu en el banco 6 
	defw 0					;bc
	defb $16				;ram

	defb 15					;rom
	defw ram3128			;hl		ram 3 Musica en 128k
	defw 49152				;de
	defw 0					;bc
	defb $13				;ram


	defb 13					;rom
	defw ianna128p1			;hl		bloque principal de 128k
	defw 24576				;de
	defw 0					;bc
	defb $10				;ram

	defb 5					;rom
	defw ianna_p3			;hl		el bloque de sprites compartido por 48k pero en 128k se carga en el banco 0
	defw 49152				;de
	defw 0					;bc
	defb $10				;ram


b_pantalla
	defb 2					;rom
	defw pantalla			;hl
	defw 49152				;de
	defw 0					;bc
	defb $10				;ram	ignorado en modo 48k pero usado en modo 128k

tabladatosEND

dzx7
	include "dzx7_turbo.asm"

	display "End Codigo ",/D,$
;	display "Total Bytes tabla+codigo ",/D, $-codigo
endcommandos
	ENT


screenzx7
	incbin "dandanator multiload Ianna.scr.zx7"	;pantalla multiload comprimida que tambien mostrara el generador de roms JAVA
screenzx7end

	include "menuanim.asm"				;incluye las lineas animdas de MAD3001
	include "efectos.asm"				;incluye efectos cortinas
	include "press_a_key.asm"			;incluye impresion de "press a key" con pausa

graficoen48k
	defb %01000010,%01000000
	defb %01010101,%01010000
	defb %01110010,%01100000
	defb %00010101,%01010000
	defb %00010010,%01010000
endgraficoen48k


menu128.12
	incbin "menu.12.128"
endmenu128.12
	
	display "Hasta guardado ",/D,$," Quedan ",/d,$2000-$	," Libres";muestra la direccion por la que vamos para ver cuanto espacio queda al compilar

	block $2000 - $,$FF						;bloqueamos el resto de la rom hasta el inicio del sector para grabar
guardarpreferencias
;	display "las preferencias las guarda en rom 1 en ",/d,$
	defb "aqui es donde vamos a grabar "

	block $3000 - $,$AA							;bloqueamos todo el sector de grabacion con $AA


musicdeath
	include "music 9 - player death.asm"
endmusicdeath
	display ">> Music 0 Death  > ",/D,musicdeath ," ",/d,endmusicdeath-musicdeath, " bytes"

musicmenu
	include "music menu.asm"
endmusicmenu
	display ">> Music 1 Menu   > ",/D,musicmenu ," ",/d,endmusicmenu-musicmenu, " bytes"

musicintro0
	include "music intro0.asm"
endmusicintro0
	display ">> Music 2 intro0 > ",/D,musicintro0 ," ",/d,endmusicintro0-musicintro0, " bytes"

musicintro1
	include "music intro1.asm"
endmusicintro1
	display ">> Music 3 intro1 > ",/D,musicintro1 ," ",/d,endmusicintro1-musicintro1, " bytes"

musicintro2
	include "music intro2.asm"
endmusicintro2
	display ">> Music 4 intro2 > ",/D,musicintro2 ," ",/d,endmusicintro2-musicintro2, " bytes"

musicintro3
	include "music intro3.asm"
endmusicintro3
	display ">> Music 5 intro3 > ",/D,musicintro3 ," ",/d,endmusicintro3-musicintro3, " bytes"

musicintro4
	include "music intro4.asm"
endmusicintro4
	display ">> Music 6 intro4 > ",/D,musicintro4 ," ",/d,endmusicintro4-musicintro4, " bytes"

musicend1
	include "music end1.asm"
endmusicend1
	display ">> Music 7 End1   > ",/D,musicend1 ," ",/d,endmusicend1-musicend1, " bytes"

musicend2
	include "music end2.asm"
endmusicend2
	display ">> Music 8 End2   > ",/D,musicend2 ," ",/d,endmusicend2-musicend2, " bytes"

menu128.11
	incbin "menu.11.128"
endmenu128.11


	display "Fin rom 1 ",/D,$," Quedan ",/d,16362-$	," Libres";muestra la direccion por la que vamos para ver cuanto espacio queda al compilar
	block 16362 - $,$ff								;bloqueamos el resto de la rom hasta la definicion del MLD
MLDoffset 
	DEFB 0 											;Value to be modified by java generator
MLDtype 
	DEFB MLD48k 									;MLD48k / MLD128k / MLD2A (+2A/+2B/+3)
nsectores 
	DEFB 0											;Num. sectores requeridos para grabar datos (0=no usado, 1..4=n. sectores)
sector0 
	DEFB 0											;1º sector donde graba datos 4Kb
													;La rutina que copia las otras a RAM debería ajustar
													;el sector a ese valor, y el slot a (sector0/4)+1
sector1
	DEFB 0 											;2º sector donde graba datos 4Kb
sector2 
	DEFB 0 											;3º sector donde graba datos 4Kb
sector3 
	DEFB 0 											;4º sector donde graba datos 4Kb
	DEFW tabladatos-codigo+movercodigo				;Offset tabla de datos
	DEFW LenFiladatos 								;Longitud de cada fila de la tabla de datos
NumDatos 
	DEFW (tabladatosEND-tabladatos)/LenFiladatos 	;Num.filas de datos
SlotOffset 
	DEFB 0 											;Slot is in +1 (byte offset in row). Indica en que byte dentro de la fila de datos está el byte de slot
	DEFW screenzx7	;-MENUBEGIN+scroffset 				;addr=begin screen zx7
	DEFW screenzx7end-screenzx7 					;size=len screen zx7

	DEFB "MLD",0 ;MLDn n=version

slotnend

rom2
	DISP 0
ianna_p1
	incbin "ianna48.p1.zx7"
endianna_p1

pantalla
	incbin "loading.scr.zx7"
endpantalla

	display "Fin rom 2 ",/D,$," Quedan ",/d,16384-$ , " Libres"	;muestra la direccion por la que vamos para ver cuanto espacio queda al compilar
	block 16384-$,$ff
	ENT

rom3
	DISP 0
	incbin "intro.bin"

menu128.10
	incbin "menu.10.128"
endmenu128.10
	display "Fin rom 3 ",/D,$," Quedan ",/d,16384-$, " Libres"
	block 16384-$,$ff
	ENT

rom4
	DISP 0
	incbin "menu48k.bin"

	display "Fin rom 4 ",/D,$," Quedan ",/d,16384-$, " Libres"
	block 16384-$,$ff
	ENT

rom5	
	DISP 0
	incbin "level1.map"

sprite_rollingstone
	incbin "sprite_rollingstone.cmp"
;	display "sprite_rollingstone > start ", /d, sprite_rollingstone, " , " , /d, $-sprite_rollingstone, " Bytes"

ianna_p3
	incbin "ianna48.p3.zx7"

menu128.9
	incbin "menu.9.128"
endmenu128.9
	display "Fin rom 5 ",/D,$," Quedan ",/d,16384-$, " Libres"
	block 16384-$,$AA
	ENT

rom6	
	DISP 0
;	display "Inicio rom 6 ",/d,$
	incbin "level2.map" 		;ianna-7.rom	

sprite_golem_inf
	incbin sprite_golem_inf.cmp
;	display "sprite_golem_inf > start ", /d, sprite_golem_inf, " , " , /d, $-sprite_golem_inf, " Bytes"

sprite_minotauro_sup
	incbin sprite_minotauro_sup.cmp
;	display "sprite_minotauro_sup > start ", /d, sprite_minotauro_sup, " , " , /d, $-sprite_minotauro_sup, " Bytes"
	
	display "Fin rom 6 ",/D,$," Quedan ",/d,16384-$, " Libres"
	block 16384-$,$FF
	ENT
rom7	
	DISP 0
	incbin "level3.map"

sprite_esqueleto
	incbin "sprite_esqueleto.cmp"
	;display "sprite_esqueleto > start ", /d, sprite_esqueleto, " , " , /d, $-sprite_esqueleto, " Bytes"

menu128.8
	incbin "menu.8.128"
endmenu128.8

	display "Fin rom 7 ",/D,$," Quedan ",/d,16384-$, " Libres"
	block 16384-$,$FF
	ENT
rom8	
	DISP 0
;	display "Inicio Rom 8 "
	incbin "level4.map" 

sprite_ogro_inf
	incbin sprite_ogro_inf.cmp
;	display "sprite_ogro_inf > start ", /d, sprite_ogro_inf, " , " , /d, $-sprite_ogro_inf, " Bytes"

sprite_golem_sup
	incbin sprite_golem_sup.cmp
;	display "sprite_golem_sup > start ", /d, sprite_golem_sup, " , " , /d, $-sprite_golem_sup, " Bytes"

menu128.7
	incbin "menu.7.128"
endmenu128.7
	display "Fin rom 8 ",/D,$," Quedan ",/d,16384-$, " Libres"
	block 16384-$,$FF
	ENT
rom9	
	DISP 0
	;display "Inicio Rom 9 "
	incbin "level5.map" 

sprite_orc
	incbin "sprite_orc.cmp"
	;display "sprite_orc > start ", /d, sprite_orc, " , " , /d, $-sprite_orc, " Bytes"

	display "Fin rom 9 ",/D,$," Quedan ",/d,16384-$, " Libres"
	block 16384-$,$FF
	ENT
rom10	
	DISP 0
;	display "Inicio Rom 10 "
	incbin "level6.map" 

sprite_ogro_sup
	incbin "sprite_ogro_sup.cmp"
;	display "sprite_ogro_sup > start ", /d, sprite_ogro_sup, " , " , /d, $-sprite_ogro_sup, " Bytes"

sprite_demonio_sup
	incbin "sprite_demonio_sup.cmp"
;	display "sprite_demonio_sup > start ", /d, sprite_demonio_sup, " , " , /d, $-sprite_demonio_sup, " Bytes"
menu128.6
	incbin "menu.6.128"
endmenu128.6

	display "Fin rom 10 ",/D,$," Quedan ",/d,16384-$, " Libres"
	block 16384-$,$FF
	ENT
rom11	
	DISP 0
	;display "Inicio Rom 11 "
	incbin "level7.map" 

sprite_minotauro_inf
	incbin sprite_minotauro_inf.cmp
;	display "sprite_minotauro_inf > start ", /d, sprite_minotauro_inf, " , " , /d, $-sprite_minotauro_inf, " Bytes"

sprite_demonio_inf
	incbin 	sprite_demonio_inf.cmp
;	display "sprite_demonio_inf > start ", /d, sprite_demonio_inf, " , " , /d, $-sprite_demonio_inf, " Bytes"
menu128.5
	incbin "menu.5.128"
endmenu128.5

	display "Fin rom 11 ",/D,$," Quedan ",/d,16384-$, " Libres"
	block 16384-$,$FF
	ENT
rom12
	DISP 0
;	display "Inicio Rom 12 "
	incbin "level8.map" 

sprite_mummy
	incbin "sprite_mummy.cmp"
;	display "sprite_mummy > start ", /d, sprite_mummy, " , " , /d, $-sprite_mummy, " Bytes"
menu128.4
	incbin "menu.4.128"
endmenu128.4

	display "Fin rom 12 ",/D,$," Quedan ",/d,16384-$, " Libres"
	block 16384-$,$FF
	ENT
rom13
	DISP 0
;	display "Inicio Rom 13 "
	incbin "level0.map"		;ianna-6.rom

ianna128p1
	incbin "ianna128.p1.zx7"
menu128.3
	incbin "menu.3.128"
endmenu128.3


	display "Fin rom 13 ",/D,$," Quedan ",/d,16384-$, " Libres"
	block 16384-$,$FF
	ENT

rom14	
	DISP 0
;	display "Inicio Rom 14 "

	incbin "level9.map"

sprite_caballerorenegado
	incbin "sprite_caballerorenegado.cmp"
;	display "sprite_caballerorenegado > start ", /d, sprite_caballerorenegado, " , " , /d, $-sprite_caballerorenegado, " Bytes"

sprite_dalgurak
	incbin "sprite_dalgurak.cmp"
;	display "sprite_dalgurak > start ", /d, sprite_dalgurak, " , " , /d, $-sprite_dalgurak, " Bytes"

sprite_troll
	incbin "sprite_troll.cmp"
;	display "sprite_troll > start ", /d, sprite_troll, " , " , /d, $-sprite_troll, " Bytes"
menu128.2
	incbin "menu.2.128"
endmenu128.2

	display "Fin rom 14 ",/D,$," Quedan ",/d,16384-$, " Libres"
	block 16384-$,$FF
	ENT

rom15
	DISP 0

ram3128
	incbin"ram3.128.zx7"
endram3128
menu128.1
	incbin "menu.1.128"
endmenu128.1

	display "Fin rom 15 ",/D,$," Quedan ",/d,16384-$, " Libres"
	block 16384-$,$FF
	ENT
/*
rom16	
	DISP 0
menu128
	incbin "menu.128"
endmenu128

	display "Fin rom 16 ",/D,$," Quedan ",/d,16384-$-endmensaje+mensaje, " Libres"

	block 16384-$-endmensaje+mensaje,$ff
mensaje
	defb "MLD created by Spirax 2018"
endmensaje
	ENT
*/
	if  END_PAGE2 < $7800 
			display "END_PAGE2:      ",/A,END_PAGE2 ," Quedan ",/d,$7800 - END_PAGE2," Bytes libres"
	endif

	if  END_CODE_PAGE3 < $AC80
			display "END_CODE_PAGE3: ",/A,END_CODE_PAGE3 ," Quedan ",/d,$AC80 - END_CODE_PAGE3," Bytes libres"
	endif

	if END_PAGE2 > $7800 
		display "END_PAGE2:      ",/A,END_PAGE2
		display ">>>>>>>>>>>>>>>>> Error END_PAGE2 es mayor de $7800 <<<<<<<<<<<<<<<<<"
	endif

	if END_CODE_PAGE3 > $AC80
		display "END_CODE_PAGE3: ",/A,END_CODE_PAGE3 
		display ">>>>>>>>>>>>>> Error END_CODE_PAGE3 es mayor de $AC80 <<<<<<<<<<<<<<<"
	endif

/*
rom17	
	DISP 0
	incbin "ianna-48-p3.bin"
	display "Fin rom 17 ",/D,$," Quedan ",/d,16384-$, " Libres"
	block 16384-$,$FF
	ENT


rom18	
	DISP 0

	display "Fin rom 18 ",/D,$," Quedan ",/d,16384-$, " Libres"
	block 16384-$,$E5
	ENT


rom19	
	DISP 0

	display "Fin rom 19 ",/D,$," Quedan ",/d,16384-$, " Libres"
	block 16384-$,$E5
	ENT

	
rom20
	DISP 0

	display "Fin rom 20 ",/D,$," Quedan ",/d,16384-$, " Libres"

	block 16384-$,$E5
	ENT
rom21
	DISP 0
	display "Fin rom 21 ",/D,$," Quedan ",/d,16384-$, " Libres"
	
	block 16384-$,$E5
	ENT
rom22
	DISP 0
	display "Fin rom 22 ",/D,$," Quedan ",/d,16384-$, " Libres"
	
	block 16384-$,$E5
	ENT
rom23
	DISP 0
	display "Fin rom 23 ",/D,$," Quedan ",/d,16384-$, " Libres"
	
	block 16384-$,$E5
	ENT
rom24
	DISP 0
	display "Fin rom 24 ",/D,$," Quedan ",/d,16384-$, " Libres"

	block 16384-$,$E5
	ENT
rom25
	DISP 0
	display "Fin rom 25 ",/D,$," Quedan ",/d,16384-$, " Libres"

	block 16384-$,$E5
	ENT


rom26
	DISP 0
	display "Fin rom 26 ",/D,$," Quedan ",/d,16384-$, " Libres"
	
	block 16384-$,$E5
	ENT

rom27
	DISP 0
	display "Fin rom 27 ",/D,$," Quedan ",/d,16384-$, " Libres"
	
	block 16384-$,$E5
	ENT


rom28
	DISP 0
	
	block 16384-$,$FF
	ENT
rom29
	DISP 0
	
	block 16384-$,$FF
	ENT
rom30
	DISP 0
	
	block 16384-$,$FF
	ENT
rom31
	DISP 0
	
	block 16384-$,$FF
	ENT
rom32
	DISP 0
	
	block 16384-$-endmensaje+mensaje,$ff
mensaje
	defb "MLD created by Spirax 2018"
endmensaje
	ENT
*/