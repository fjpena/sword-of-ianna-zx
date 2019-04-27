setrambank1: 
			 ld a, (romatbank1)
			 ld b, a
             jr setrambank

setrambank6: 
			di
			ld a, (I.MLDoffset2)
			ld b, 4						;rom bank con el menú de la ram6 definido en el MLD
			add a, b 
			ld b, a
			call setrambank
			ei
			ret

setrambank:	
			push hl
			ld a, b
			ld (rombank),a
			call I.enviacomandosimple				;la paginamos
			pop hl
			ret
