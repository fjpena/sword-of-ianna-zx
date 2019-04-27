;	output "inicio_rom.bin"
;	org 0
	di									;desactivamos interrupciones
	im 1								;ponemos el im a 1 para luego
	jp saltarse_RST						;saltamos al inicio en $100
	
	;Skip RST routines
				defs #8-$,#FF
RUT8:
				defs #10-$,#FF
RUT10:
				defs #18-$,#FF
RUT18:
				defs #20-$,#FF
RUT20:
				defs #28-$,#FF
RUT28:
				defs #30-$,#FF
RUT30:
				defs #38-$,#FF
KEYRUT:			DI
				;ver si se hace algo con la key routine o para la musica del menu multiload
				EI
				RET
				
				defs #52-$,$FF
				ret

				defs #66-$,#FF
NMI:			;ver si se hace algo con la NMI
	IFDEF NMI_ROM
	display "NMI=1" 
nmi_isr: 
				incbin "dandanator/nmiroutine.bin"
	ELSE
	display "NMI=0" 
				retn
				defs $80-$,$FF
	ENDIF

saltarse_RST
