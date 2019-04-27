	;entramos en DE con la posicion de la pantalla donde poner PRESS A KEY

pulsatecla	
	ld hl, press_a_key	
	
	ld b,8
bucleb
	ld c,6
	push de
buclec
	ld a, (de)
	and (hl)
	inc hl
	or (hl)
	ld (de),a
	inc de
	inc hl
	dec c
	jr nz, buclec
	pop de
	inc d
	djnz bucleb
	ret
waitkp:						;esperamos a que se pulse una tecla
	xor a                        
	in a, ($FE)
	or $E0
	inc a
	jr z, waitkp
	ret

press_a_key
	defb $80,$00,$00,$00,$03,$00,$83,$00,$80,$00,$03,$00
	defb $80,$3B,$00,$BB,$03,$B8,$83,$38,$80,$2B,$03,$A8
	defb $80,$2A,$00,$A2,$03,$20,$83,$28,$80,$2A,$03,$28
	defb $80,$3B,$00,$33,$03,$B8,$83,$38,$80,$33,$03,$10
	defb $80,$22,$00,$A0,$03,$88,$83,$28,$80,$2A,$07,$10
	defb $80,$22,$00,$BB,$03,$B8,$83,$28,$80,$2B,$07,$90
	defb $88,$00,$00,$00,$03,$00,$83,$00,$80,$00,$07,$00
	defb $ff,$00,$ff,$00,$ff,$00,$ff,$00,$ff,$00,$ff,$00
