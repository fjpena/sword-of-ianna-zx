scroffset
	
MENUBEGIN
		;Interrupts Disabled before enter here...
		;Interrupts Enabled when exits.... be sure IM1 and RST28 routine ready on zone 0-#3fff
			di
		;First copy the initial values to variables in RAM
			ld	hl,slot0countdown	;source of slot 0
			ld	de,countdown		;destination as defined in DIPS #xxxx
			ld	bc,TablaCos-slot0countdown
			ldir
		;Now uncompress the screen to the scratch area
			ld	hl,screenzx7
			ld	de,finLineas
			call	dzx7	;DZX7.dzx7_turbo	;uncompress it directly to buffer
			
			xor a
			out (254),a
			
		;Show the full screen (copy from buffer to screen)
			ld	hl,finLineas
			ld	de,#4000
			ld	bc,#1b00
			ei		;enable ints
			halt	;sync to screen prior to copy

			ldir	;Copy screen after Vertical Blank (after Halt)
			
			halt	;sync to screen prior to begin loop
loopix
			ld	b,totLineas	;Number of lines to "animate"
			ld	ix,Lineas	;IX will point to 1st line
loopixin
			push	bc
			call	clrline		;clear line
			inc	ix
			inc	ix				;Next line
			pop		bc
			djnz	loopixin	;one line less
			
			halt
			halt			;additional halt so image is showed at 25fps (and countdown 25fps)
			
			ld	b,totLineas	;Number of lines to "animate"
			ld	ix,Lineas	;IX will point to 1st line
loopix2in
			push	bc
			call	restline;Restore data in this line
			inc	ix
			inc	ix			;Next line
			pop		bc
			djnz	loopix2in	;one line less
			
			;check for pressing any key to exit
			xor a
			in	a,(#FE)
			and #1F			;filter only keys
			xor #1F			;filter only keys, apply mask for checking all rows/cols
			RET NZ			;if key pressed (A<>0) then exit
;			halt			;wait until this frame is showed in screen
			
			ld	a,(countdown)	;Time countdown
			and a				;check if it's zero
			RET Z			;if countdown arrived zero then exit
			dec a
			ld	(countdown),a
	
		
			jr	loopix		;repeat loop
		
;Clear line of screen. Only rows 2 to 28 [0..31] is cleared
clrline
			ld	hl,(ix)		;NEW ADDRESS
			ld	a,(hl)		;LOW BYTE OF new address
			inc	a			;+1
			jr	nz,clrcont
			ld	hl,TablaCos	;if low byte was #FF then it was end of table, begin again
			ld	(ix),hl		;update address to begin
			
clrcont
			;load BC with offset for this line
			ld	c,(hl)
			inc	hl
			ld	b,(hl)

		;clear the selected line
			ld	hl,#4000+2
			add	hl,bc
			ld	d,h
			ld	e,l
			inc	e
					
			ld	bc,32-5-1			;Copy 32-5-1 bytes
			ld	(hl),0				;clear first byte
			ldir					;and clear the others bytes
			ret

;Restore line of screen	from buffer. Only rows 2 to 28 [0..31] is restored
restline
			ld	hl,(ix)		;Address of offset info
			;load BC with offset for this line
			ld	c,(hl)
			inc	hl
			ld	b,(hl)
			inc	hl
			ld	(ix),hl		;update new address for next line offset
			
			;Now restore the line cleared
			;Calculate line destination
			ld	hl,#4000+2
			add	hl,bc
			ex	de,hl
			;Calculate line source
			ld	hl,finLineas+2
			add	hl,bc
			
			ld	bc,32-5			;Copy 32-5 bytes
			ldir

			RET
slot0countdown
			DISP #8000
countdown	defb	25*10	;Halts*2 prior to exit
Lineas		;Define as many lines as desired (defw per line)
			;  Be sure is aligned in even numbers respect to TablaCos: TablaCos + evennumber
			defw TablaCos
			defw TablaCos+(5*2)
			defw TablaCos+(11*2)
			defw TablaCos+(23*2)
finLineas	;we will uncompress the screen in this area #8xxx 
			
			ENT
totLineas	equ	((finLineas-Lineas)/2)			

TablaCos
			defw #6C0, #5C0, #5C0, #5C0, #4C0, #4C0, #3C0, #2C0, #1C0, #0C0
			defw #7A0, #5A0, #4A0, #3A0, #2A0, #0A0, #780, #680, #580, #480
			defw #380, #380, #280, #280, #280, #280, #280, #280, #280, #380
			defw #380, #480, #580, #680, #780, #0A0, #2A0, #3A0, #4A0, #5A0
			defw #7A0, #0C0, #1C0, #2C0, #3C0, #4C0, #4C0, #5C0, #5C0, #5C0

			defw #FFFF
							
;screenzx7
;			incbin "multiload.scr.zx7"
;screenzx7end
;	MODULE DZX7
;			include "dzx7_turbo.asm"
;	ENDMODULE
MENUEND

scroffsetend
