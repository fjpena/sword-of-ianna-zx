	output "Sword of Ianna.rom"
	include "ianna48k.sym" 		;<<< todas las posicones del IANNA para poder imprimir algunos datos al compilar este asm
	define NMI_ROM=1

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

	xor a
	ld (23400),a	  	; Clear NMI Counter
	ld (23401),a
	ei
	halt				;sincronizamos con trazo
	di
	ld hl, $5800
	ld de, $5801
	ld (hl), l
	ld bc, $2ff
	ldir				;borramos atributos
	ld hl, $4000
	ld de, $4001
	ld (hl),l
	ld bc, $17ff
	ldir				;borramos datos pantalla
	
	ld bc, $7ffd		;Puerto para el cambio de banco de memoria en un 128k
	ld de, $1110		;puertos a intercambiar
	ld hl, $C000		;dirección donde comprobar si hemos cambiado de banco
	out (c),d			;ponemos el banco de memoria apuntado por D
	ld a, (hl)			;ponemos en A lo que hay ahora en el banco
	out (c),e			;cambiamos de Banco al apuntado por E
	cpl					;invertimos A
	ld (hl),a			;ponemos en HL el valor de A invertido
	cpl					;volvemos a invertir A lo dejamos al valor original
	out (c),d			;cambiamos al banco de memoria apuntado por D
	cp (hl)				;comparamos el valor de A con el contenido de HL 
	;					(si estamos en un 48k no habra cambiado el banco y abra modificado la memoria principal)
	ld (hl),a			;en caso de que estemos en un 48k restauramos el valor de HL
	jr nz, es48k		;si no eran iguales estamos en un 48k y saltamos para seguir en modo 48k
	ld a, $10			;si estamos en un 128k, volvemos a paginar para actualizar la variable del sistema
	out (c),a
	ld (BANKM),a
	ld a, 1				;ponemos a 1 nuestro marcador de 128k
	jr es128k
es48k
	xor a				;ponemos a 0 nuestro marcador de 128k ya que estamos en un 48k
es128k
	ld (esun128k), a	;actualizamos nuestra variable para usarla despues en ejecución

	ld hl, movercodigo					
	ld de, codigo						
	ld bc, endcommandos-codigo			
	ldir				;movemos la tabla de datos y el cargador a la memoria donde no se vaya a modificar

	jp  codigocargador	;saltamos al codigo en la memoria principal


movercodigo				;esta etiqueta esta en la ROM
	DISP #5d00 					;Desplazamos el codigo para que el compilador lo compile en su posicion de RAM
codigo					;esta etiqueta se corresponde con memoria principal en RAM $5D00
MLDoffset2		display "MLDoffset2 ",/d,$
	defb 0

sectorgrabar	display "Sectorgrabar ",/d,$
	defb 0

romsectorgrabar	display "Romsectorgabar ",/d,$
	defb 0

hlsectorgrabar	display "HLsectorgrabar ",/d,$
	defw 0
	
saveprefs		display "Save Prefs ",/d,$	;HL origen en memoria a grabar
	di										;preserva el resto de registros
	push af
	push bc
	push de
	push hl								;guardamos origen de datos a grabar

	ld a, (romsectorgrabar)				;cogemos el offset del MLD
	call enviacomandosimple				;la paginamos
	ld a, (sectorgrabar)
	ld e, a 							;lo dejamos en E para selecionar el sector
	ld a, 48							;comando borrar epprom
	ld d, 16							;en D comando borrar sector y en E el numero de sector
	call enviacomandomultiple
	ld hl, (hlsectorgrabar)				;HL inicio del sector a borrar
	call borrarsector
	ld a, 48							;comando grabar epprom
	ld d, 32							;en D comando grabar sector y en E el numero de sector calculado anteriormente
	call enviacomandomultiple
	pop hl								;recuperamos origen de datos a grabar
	ld de, (hlsectorgrabar)				;DE = direccion destino en ROM
	ld bc, 16							;tamaño de datos a grabar
	call grabareprom					;graba los datos
	call grabarepromnull				;completa el slot de grabado con $FF
	
	ld a, (MLDoffset2)					;cogemos el offset del MLD
	inc a								;ponemos el primer slot 
	call enviacomandosimple				;la paginamos
	pop de
	pop bc
	pop af	
	ret									;recuperamos el resto de registros y volvemos
	
	
enviacomandosimple	display "Envia c simple ",/d,$
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
	
enviacomandomultiple	display "Envia c multiple ",/d,$
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

	
bloqueardandanator	display "Bloquea dandanator ",/d,$
	ld a, 46
	ld de,$0101
	jr enviacomandomultiple				;bloquea el dandanator
	
activardandanator	display "Activa dandanator ",/d,$
	ld a, 46
	ld de,$1010
	jr enviacomandomultiple				;Activamos el dandanator


grabareprom								;BC = cantidad de datos a guardar
	push bc								;HL = direccion de origen en memoria
	call comandograbar					;DE = direccion destino en ROM
	ld a, (hl)
	ld (de), a
	inc hl
	inc de
	pop bc
	dec bc
	ld a, b							
	or c
	jr nz, grabareprom
	ret

grabarepromnull							;HL = direccion de origen en memoria
	call comandograbar					;DE = direccion destion en ROM
	ld a, $FF							;Se va a grabar el resto del slots con FF hasta completar los 4096 bytes 0x1000
	ld (de), a
	inc de
	ld a, d
	and $0F	
	or e						
	jr nz, grabarepromnull
	ret

comandograbar
	ld bc, $1555				
	ld a, $AA
	ld (bc), A
	ld bc, $2AAA
	ld a, $55
	ld (bc), A
	ld bc, $1555	
	ld a, $A0
	ld (bc), A	
	ret
	
borrarsector
	ld bc, $1555				; Five Step Command to allow Sector Erase
	ld a, $AA
	ld (bc), a			
	ld bc, $2AAA				
	ld a, $55
	ld (bc), a	
	ld bc, $1555				
	ld a, $80
	ld (bc), a
	ld bc, $1555				
	ld a, $AA
	ld (bc), a
	ld bc, $2AAA				
	ld a, $55
	ld (bc), a
	ld a, $30					; Actual sector erase		
	ld (hl), a
	ld bc,1400					; wait over 25 ms for Sector erase to complete (datasheet pag 13) -> 1400*18us= 25,2 ms
waitset							; Loop ts = 64ts -> aprox 18us on 128k machines
	ex (sp), hl					; 19ts
	ex (sp), hl					; 19ts
	dec bc						; 6ts
	ld a, b						; 4ts
	or c						; 4ts
	jr nz, waitset				; 12ts / 7ts
	ret							; 10ts

	
codigocargador		display "Inicio Cargador ",/d,$

    ld a, 41		  ; 41,1,0 Normal boot on slot 1
	ld de, $0100
	call enviacomandomultiple
	
	ld a, 42		  ; 42,1,1 Button 1 to reset to slot 1
	ld de, $0101
	call enviacomandomultiple
	
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
	ld hl, $2000						;direccion de inicio de grabación de las preferencias
	ld (hlsectorgrabar), hl		

    call check_init_stored_parameters 	; Check if "R" is pressed to initialize user preferences
	call check_joystick_loader 		  	; Loader will be available even in a 48k spectrum

	ld a, 39		; Command 39 sets current rom Slot as reset slot
	call enviacomandosimple  

	
	ld ix, b_pantalla
	ld b, 1							    ;ponemos la cantidad de bloques a procesar
	call bucle1							;procesa el numero de bloques y copia o descomprime

	ld a, (MLDoffset2)					
	inc a
	call enviacomandosimple				;ponemos la rom1 para las rutinas de pantalla
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
	ld b, 3								;ponemos la cantidad de bloques a procesar
	jr continuaconcargacomun
continuacargacomo128
	ld ix, b_principal128				;ponemos el puntero para los bloques a cargar de 128k
	ld b, 5								;ponemos la cantidad de bloques a procesar

continuaconcargacomun
	call bucle1							;procesa el numero de bloques y copia o descomprime

arrancajuego
	ld a, (MLDoffset2)					
	inc a
	call enviacomandosimple				;ponemos la rom1 para el pulsa tecla

	ld de, 20616						;posición en pantalla para el mensaje press a key
	call pulsatecla						;imprime y espera que se pulse una tecla

	ld a, (esun128k)
	or a
	jr nz, continuateclacomo128

	;estamos en modo 48k
	ld a, (MLDoffset2)
	inc a
	ld (rombank), a						;definimos el rombank actual a partir de aqui se va a usar esta variable 
										;para actualizar la rom en la que estamos

	ld a, 1 							;cargamos musica Intro
	call Music_Play
	jr continuateclacomun				;salta al inicio del juego	

continuateclacomo128
	ld a, 1								;ponemos borde azul mientras esperamos
	out ($FE), a
	call waitkp
	
continuateclacomun
	xor a
	out ($FE), a						;ponemos borde negro
	jp 24576							;salta al inicio del juego

bucle1
	push bc								;guardamos el contador de bloques a procesar
	call recolecta						;lo pasamos a la memoria
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
	ldir
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
	defw endianna_p1-ianna_p1	;bc
	defb $10				;ram	ignorado pero necesario para que toda la tabla sea del mismo tamaño

	defb 17					;rom
	defw ianna_p2			;hl		bloue principal de 48k
	defw 32768				;de
	defw endianna_p2-ianna_p2	;bc
	defb $10				;ram	ignorado pero necesario para que toda la tabla sea del mismo tamaño

	defb 18					;rom
	defw ianna_p3			;hl		el bloque de prites es compartido en 48k y 128k
	defw 49152				;de
	defw endianna_p3-ianna_p3	;bc
	defb $10				;ram	ignorado pero necesario para que toda la tabla sea del mismo tamaño

b_principal128
	defb 16					;rom
	defw menu128			;hl		
	defw 49152				;de		
	defw endmenu128-menu128	;bc
	defb $16				;ram

	defb 15					;rom
	defw ram3128			;hl		ram 3 Musica en 128k
	defw 49152				;de
	defw endram3128-ram3128	;bc
	defb $13				;ram


	defb 13					;rom
	defw ianna128p1			;hl		bloque principal de 128k
	defw 24576				;de
	defw endianna128p1-ianna128p1	;bc
	defb $10				;ram

	defb 19					;rom
	defw ianna128p2			;hl		bloque principal de 128k
	defw 32768				;de
	defw endianna128p2-ianna128p2	;bc
	defb $10				;ram

	defb 18					;rom
	defw ianna_p3			;hl		el bloque de sprites compartido por 48k pero en 128k se carga en el banco 0
	defw 49152				;de
	defw endianna_p3-ianna_p3	;bc
	defb $10				;ram


b_pantalla
	defb 2					;rom
	defw pantalla			;hl
	defw 49152				;de
	defw endpantalla-pantalla	;bc
	defb $10				;ram	ignorado en modo 48k pero usado en modo 128k

tabladatosEND


check_init_stored_parameters: ; check for "R" key pressed on boot
	ld a, $fb	; A10=0
	in a, ($fe)
	bit 3,a
	ret nz			
	ld a ,2
	out ($fe),a	

koff:
	ld a, $fb	; A10=0
	in a, ($fe)	; Wait until key is released
	bit 3,a
	jr z, koff
	
clear_stored_parameters:	
	xor a
	out ($FE), a
	ld hl, $4000	;aqui llegamos con la pantalla recien borrada por lo que la podemos usar como origen para borrar las prefs
	jp saveprefs	
	
check_joystick_loader: ; check for "L" key pressed on boot
	ld 	a, $bf 	; A14=0
	in 	a, ($fe)
	bit 1, a
	ret nz
		
joystick_loader:
	ld a, 40	; 40,32,1 special command selects bank 32 and resets
	ld de, $2001
	jp enviacomandomultiple


	display "End Codigo ",/D,$
;	display "Total Bytes tabla+codigo ",/D, $-codigo
endcommandos
	ENT					;restauramos la direccion de compilación




	display "Hasta guardado ",/D,$," Quedan ",/d,$2000-$	," Libres";muestra la direccion por la que vamos para ver cuanto espacio queda al compilar

	block $2000 - $,$FF						;bloqueamos el resto de la rom hasta el inicio del sector para grabar
guardarpreferencias
;	display "las preferencias las guarda en rom 1 en ",/d,$
	defb "sector grabacion"

	block $3000 - $,$FF						;bloqueamos todo el sector de grabacion con $FF


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

	include "efectos.asm"				;incluye efectos cortinas
	include "press_a_key.asm"			;incluye impresion de "press a key" con pausa

graficoen48k
	defb %01000010,%01000000
	defb %01010101,%01010000
	defb %01110010,%01100000
	defb %00010101,%01010000
	defb %00010010,%01010000
endgraficoen48k



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
	DEFW 0;screenzx7				 				;addr=begin screen zx7
	DEFW 0;screenzx7end-screenzx7 					;size=len screen zx7

	DEFB "MLD",0 ;MLDn n=version

slotnend

rom2
	DISP 0
ianna_p1
	incbin "ianna-48-rom-p1.bin"
endianna_p1

pantalla
	incbin "loading.scr"
endpantalla

	display "Fin rom 2 ",/D,$," Quedan ",/d,16384-$ , " Libres"	;muestra la direccion por la que vamos para ver cuanto espacio queda al compilar
	block 16384-$,$ff
	ENT

rom3
	DISP 0
	incbin "intro.bin"

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

	display "Fin rom 12 ",/D,$," Quedan ",/d,16384-$, " Libres"
	block 16384-$,$FF
	ENT
rom13
	DISP 0
;	display "Inicio Rom 13 "
	incbin "level0.map"		;ianna-6.rom

ianna128p1
	incbin "ianna-128-rom-p1.bin"
endianna128p1

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

	display "Fin rom 14 ",/D,$," Quedan ",/d,16384-$, " Libres"
	block 16384-$,$FF
	ENT

rom15
	DISP 0

ram3128
	incbin"ram3.128"
endram3128

	display "Fin rom 15 ",/D,$," Quedan ",/d,16384-$, " Libres"
	block 16384-$,$FF
	ENT

rom16	
	DISP 0
menu128
	incbin "menu.128"
endmenu128

	display "Fin rom 16 ",/D,$," Quedan ",/d,16384-$, " Libres"

	block 16384-$,$ff
	ENT

rom17	
	DISP 0
ianna_p2
	incbin "ianna-48-rom-p2.bin"
endianna_p2

	display "Fin rom 17 ",/D,$," Quedan ",/d,16384-$, " Libres"
	block 16384-$,$FF
	ENT


rom18	
	DISP 0
ianna_p3
	incbin "ianna-48-rom-p3.bin"
endianna_p3
	display "Fin rom 18 ",/D,$," Quedan ",/d,16384-$, " Libres"
	block 16384-$,$ff
	ENT


rom19	
	DISP 0
ianna128p2
	incbin "ianna-128-rom-p2.bin"
endianna128p2
	display "Fin rom 19 ",/D,$," Quedan ",/d,16384-$, " Libres"
	block 16384-$,$ff
	ENT

	
rom20
	DISP 0

	display "Fin rom 20 ",/D,$," Quedan ",/d,16384-$, " Libres"

	block 16384-$,$ff
	ENT
rom21
	DISP 0
	display "Fin rom 21 ",/D,$," Quedan ",/d,16384-$, " Libres"
	
	block 16384-$,$ff
	ENT
	
rom22
	DISP 0
	display "Fin rom 22 ",/D,$," Quedan ",/d,16384-$, " Libres"
	
	block 16384-$,$FF
	ENT
rom23
	DISP 0
	display "Fin rom 23 ",/D,$," Quedan ",/d,16384-$, " Libres"
	
	block 16384-$,$FF
	ENT
rom24
	DISP 0
	display "Fin rom 24 ",/D,$," Quedan ",/d,16384-$, " Libres"

	block 16384-$,$FF
	ENT
rom25
	DISP 0
	display "Fin rom 25 ",/D,$," Quedan ",/d,16384-$, " Libres"

	block 16384-$,$FF
	ENT


rom26
	DISP 0
	display "Fin rom 26 ",/D,$," Quedan ",/d,16384-$, " Libres"
	
	block 16384-$,$FF
	ENT

rom27
	DISP 0

	display "Fin rom 27 ",/D,$," Quedan ",/d,16384-$, " Libres"
	block 16384-$,$FF
	ENT


rom28
	DISP 0

	display "Fin rom 28 ",/D,$," Quedan ",/d,16384-$, " Libres"
	block 16384-$,$FF
	ENT
rom29
	DISP 0

	display "Fin rom 29 ",/D,$," Quedan ",/d,16384-$, " Libres"
	block 16384-$,$FF
	ENT
rom30
	DISP 0
	
	display "Fin rom 30 ",/D,$," Quedan ",/d,16384-$, " Libres"
	block 16384-$,$FF
	ENT
rom31
	DISP 0
	
	display "Fin rom 31 ",/D,$," Quedan ",/d,16384-$, " Libres"
	block 16384-$,$FF
	ENT
rom32
	DISP 0
	incbin "dandanator\eewriter_slot31"
	
	display "Fin rom 32 ",/D,$," Quedan ",/d,16384-$, " Libres"
	block 16384-$,$ff
	ENT

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
	