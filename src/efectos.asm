	define colorborde   %00000000		;color del borde para usar con el beep de cortinillas

	define sonido 1						;a 1 hace beep en cada coulumna al hacer las cortinas al centro
	;									;a 0 quita el sonido
	
	define difuminado 0					;1 activa "difuminar" efecto de difuminado
	define cortina_doble 1				;1 activa "cortinadoble" las cortinillas salteadas dobles, se llama con la pantalla completa en 49152 $C000 
	define cortina_borrado 1			;1 activa "cortinaborrado" borrado de pantalla con cortinillas salteadas dobles, se llama con A = color de borrado
	define scrollcortinacentro 0		;1 activa "cortinacentro" scroll al centro
	define reordena49 0					;1 activa "reordena" , se llama con HL= direccion de la pila de direcciones y con la pantalla completa en 49152 $C000 
		define sizepausaordena 6				;define pausa para reordena

iniciorutina
	
	if cortina_doble = 1
cortinadoble
	ei
	ld de, 32					
	ld c, e						; 32 Columnas (de la 0 a la 31)
buclecortinadoblec
	dec c					
	call printlineacortinadoble
	call printlineacortinadoble
		if sonido=1
	call soundbeep
		endif
	dec c
	jr nz, buclecortinadoblec
	ret

printlineacortinadoble
	halt								;4	Syncronizamos con Interrupcion
	ld h, $c0							;7	en H $C0 -> $C000 = 49152 
	ld l, c								;4	en L la columna
	ld b, 216							;7	contador de lineas+atributos 192+24
bucleprintbytecortinadoble
	ld a, (hl)							;7  a = contenido de HL
	res 7, h 							;8  reseteamos el bit7 H = $40
	ld (hl), a							;7  ponemos a en HL
	set 7, h							;8  ponemos el bit 7 H = $C0
	add hl, de							;11 sumamos 32 para pasar a siguiente linea
	djnz bucleprintbytecortinadoble		;12 + 5
	;		total bucle =216 x 53 + 5 = 11453
	ld a, c								;4	cogemos de C la columna
	cpl									;4	invertimos A
	and 31								;7	dejamos solo los bits del 0-4 (valor 0 a 31)
	ld c, a								;4  lo dejamos en C
	ret									;10
	;					Total Printlinea = 11504
		endif

	if cortina_borrado = 1
cortinaborrado
	ei
	ex af,af
	ld de, 32					
	ld c, e						; 32 Columnas (de la 0 a la 31)
buclecortinaborradoc
	dec c					
	call printlineacortinaborrado
	call printlineacortinaborrado
		if sonido=1
	call soundbeep
		endif
	dec c
	jr nz, buclecortinaborradoc
	ret

printlineacortinaborrado
	halt								;4	Syncronizamos con Interrupcion
	ld h, $40							;7	en H $C0 -> $C000 = 49152 
	ld l, c								;4	en L la columna
	ld b, 192							;7	contador de lineas 192
bucleprintbytecortinaborradolinea
	ld (hl), 0							;7  borramos el contenido de HL
	add hl, de							;11 sumamos 32 para pasar a siguiente linea
	djnz bucleprintbytecortinaborradolinea		
	ld b,24 							;7 contador de attribuos 24
	ex af, af
bucleprintbytecortinaborradoattributo
	ld (hl), a							
	add hl, de							;11 sumamos 32 para pasar a siguiente linea
	djnz bucleprintbytecortinaborradoattributo		
	ex af, af
	
	ld a, c								;4	cogemos de C la columna
	cpl									;4	invertimos A
	and 31								;7	dejamos solo los bits del 0-4 (valor 0 a 31)
	ld c, a								;4  lo dejamos en C
	ret									;10
	
		endif
	
	
		if difuminado=1			;inicio seccion difuminado
difuminar
	ei
	ld b, 8
bucledifuminar1
	ld hl, $4000
	halt
bucledifuminar2
	sra (hl)
	inc hl
	ld a, h
	cp $58
	jr nz, bucledifuminar2
	djnz bucledifuminar1
	ret
		endif					;fin de seccion difuminado


		if scrollcortinacentro = 1	;inicio seccion scrollcortinacentro
cortinacentro
	ei
	ld de, $20
	ld c, $01
borradocortina	
	ld b, $0F
buclecolumnas
	push bc
	ld h, $40
	ld l, b
	call cortinalineaizda		
	ld h, $40
	ld a, b
	cpl
	and 31
	ld l, a
	call cortinalineadcha
	pop bc
	djnz buclecolumnas
nextcolum
	ld a, c
	dec a
	jr nz, noborrarfinallinea
	ld hl, $4000
	call cortinaborra
	ld hl, $401F
	call cortinaborra
noborrarfinallinea
		if sonido=1
	call soundbeep
		endif
	halt
	inc c
	ld a, c
	cp $11
	jr nz, borradocortina
	ret

cortinalineaizda
	ld a,216						
buclecortinalineaizda
	dec l
	ld c, (hl)
	inc l
	ld (hl),c
	add hl,de
	dec a							
	jr nz, buclecortinalineaizda	
	ret								
	
cortinalineadcha
	ld a, 216					
buclecortinalineadcha
	inc l							
	ld c, (hl)
	dec l
	ld (hl), c
	add hl, de						
	dec a							
	jr nz, buclecortinalineadcha	
	ret								
	
cortinaborra
	ld a, 216					
buclecortinaborra
	ld (hl), 0
	add hl, de						
	dec a							
	jr nz, buclecortinaborra	
	ret								
		endif  		;fin de seccion scrollcortinacentro

		if sonido=1
soundbeep
	ld a, colorborde
	ld b, 2						;ponemos el valor del bucle solo un pequeño chasquido
buclebeep1
    set 4, a					;activamos el altavoz en cada pasada del bucle.
	out ($FE), a				;lo pasamos al puerto
    djnz buclebeep1
	res 4, a					;dejamos desactivado el altavoz al acabar el bucle
	out ($FE), a				;lo pasamos al puerto
	ret	
		endif
	
		if reordena49 = 1		;inicio seccion reordena
reordena
	ei									;habiliita interrupciones
	ld c, sizepausaordena
bucleordena1pila
	ld e, (hl)
	inc hl
	ld a, e
	or (hl)
	ret z								;si es 0 finaliza
	ld d, (hl)
	
	ld b,8								;ponemos un bucle de 8 lineas por caracter
bucleordena2pila
	call printbyteordena
	inc d								;pasamos a la siguiente linea del caracter
	djnz bucleordena2pila				;continuamos hasta completar las 8 lineas del caracter

	ld a, (hl)
	inc hl
	and %00011000						;24 dejamos solo los bits 3 y 4 que marcan en que 1/2 está
	rra									;movemos los bits 3 veces a la derecha asi será 1, 2 o 3
	rra
	rra
	or #58								;le añadimos la direccion de atributos #5800 
	ld d, a								;lo ponemos en D y ahora DE tendra la direccion completa
	call printbyteordena						
	
	dec c
	jr nz, bucleordena1pila
	ld c, sizepausaordena
	halt
	jr bucleordena1pila					;seguinmos con el siguiente caracter

printbyteordena
	set 7, d							;8  ponemos el bit 7 D = $C0
	ld a, (de)							;7  a = contenido de DE
	res 7, d 							;8  reseteamos el bit7 D = $40
	ld (de), a							;7  ponemos a en DE
	ret	
		endif
		
	;display "Bytes Rutinas efectos ",/d, $-iniciorutina
