	;se llama con 	HL= direccion de la pila
	;				DE= direccion de los datos
	; necesita tener definido "guardasp defw 0" en la memoria principal
	;habilita interrupciones vuelve con EI activado
	define velocidad 4				    ;numero de caracteres para sincronizar con pantalla

reordena
	ei									;habiliita interrupciones
	ld (guardasp) , sp					;guardamos el STACK
	ld sp, hl							;ponemos en el stack la pila de direcciones
	ld c, velocidad
bucleordena1piladisco
	pop hl								;recuperamos la primera direccion de pantalla
	ld a,h								;comprobamos que no es 0
	or l
	jr z, finpiladisco					;si es 0 salta a finalizar
	ld b,8								;ponemos un bucle de 8 lineas por caracter
bucleordena2piladisco
	ld a,(de)							;cogemos el dato a colocar de la lista de datos
	ld (hl),a							;lo colocamos en pantalla
	inc h								;pasamos a la siguiente linea del caracter
	inc de								;pasamos al siguiente dato 
	djnz bucleordena2piladisco			;continuamos hasta completar las 8 lineas del caracter
	dec sp								;decrementamos el stack dos veces
	dec sp								;para recuperar otra vez la direccion de pantalla
	pop hl								;recuperamos la direccion para calcular la posicion de atributos
	ld a,h								;cogemos h para calcular
	and %00011000						;24 dejamos solo los bits 3 y 4 que marcan en que 1/2 está
	rra									;movemos los bits 3 veces a la derecha asi será 1, 2 o 3
	rra
	rra
	or #58								;le añadimos la direccion de atributos #5800 
	ld h,a								;lo ponemos en H y HL tendra la direccion completa
	ld a,(de)							;cogemos el dato de la lista de datos
	ld (hl),a							;y lo ponemos en pantalla
	inc de								;incrementamos el valor de la lista de datos
	;ld a, $7f
	;in a, ($FE)
	;bit 0, a
	;jr z, bucleordena1piladisco
	dec c
	jr nz, bucleordena1piladisco
	ld c, velocidad
	halt								;pausa
	jr bucleordena1piladisco			;seguinmos con el siguiente caracter

finpiladisco
	ld sp , (guardasp)					;recuperamos el STACK original
	ret									;regresamos ojo estamos con EI
