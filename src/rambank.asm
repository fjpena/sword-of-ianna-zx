; B: new RAM page to put in  $C000 - $FFFF
; Assumes interrupts are disabled (except setrambank6)
setrambank4: ld b, 4
             jr setrambank
setrambank1: ld b, 1
             jr setrambank
setrambank7: ld b, 7
			 jr setrambank
setrambank6: 
		di
		ld b, 6
		call setrambank
        ei
		ret
setrambank0:	ld b, 0
setrambank:	ld a, (23388)		;Sistem var with the previous value
		and $f8			;Preserve the high bits
		or b			;Set RAM page in B
		ld bc, $7ffd		;Port to write to
     	ld	(23388),a	;Update system var
     	out	(c),a		;Go
		ret		

setrambank0_with_di:
        di
        call setrambank0
        ei
        ret

; B: new RAM page to put in  $C000 - $FFFF
; Assumes interrupts are disabled

setrambank_p3:	ld a, (23388)		;Sistem var with the previous value
		and $e8			;Preserve the high bits
		or b			;Set RAM page in B
		ld bc, $7ffd		;Port to write to
   		ld	(23388),a	;Update system var
   		out	(c),a		;Go
		ret

; Switch the visible screen
; Assumes interrupts are disabled
		
switchscreen:	ld	a,(23388)	;Sistem var with the previous value
     		xor	8		;switch screen
     		ld	bc,32765	;Port to write to
     		ld	(23388),a	;Update system var
     		out	(c),a		;Switch
		ret			

