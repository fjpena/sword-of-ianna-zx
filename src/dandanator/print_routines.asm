;-----------------------------------------------------------------------------------------
; PREP_PRT - Updates Print_Attr, SCR & ATTR Vars
;-----------------------------------------------------------------------------------------
PREP_PRT:	LD (PRINT_ATTR),A			; Set Attribute
			CALL CRtoSCREEN
			CALL CRtoATTR
			RET			
;-----------------------------------------------------------------------------------------

			
			
;-----------------------------------------------------------------------------------------
; CRtoSCREEN - Converts a scr char coord into a SCREEN Address   b,c = y,x positions
;-----------------------------------------------------------------------------------------
CRtoSCREEN:	;PUSH DE						
			LD A,C
            AND 31
            LD L,A
            LD A,B
            LD D,A
        	AND 24
            ADD A,64
            LD H,A
            LD A,D
            AND 7
            RRC A
            RRC A
            RRC A
            OR L
            LD L,A
            ;POP DE
            LD (SCR_CUR_PTR),HL			; Update Variable
            RET
; ---------------------------------------------------------------------------------------- 



;-----------------------------------------------------------------------------------------
; CRtoATTR - Converts a screen char coord  into a ATTR Address  b,c = y,x positions
;-----------------------------------------------------------------------------------------
CRtoATTR:	LD A,B
            RRCA
            RRCA
            RRCA
            LD L,A
            AND 3
            ADD A,88
            LD H,A
            LD A,L
            AND 224
            LD L,A
            LD A,C
            AND 00011111b
            ADD A,L
            LD L,A
            LD (SCR_ATTR_PTR),HL		; Update Variable
            RET
; ----------------------------------------------------------------------------------------



; ----------------------------------------------------------------------------------------   
; PRINTCHNUM - Prints Char Number N
;----------------------------------------------------------------------------------------- 
PRINTCHNUM:	SUB 32						; Adjust Ascii to charset
			LD H,0						; Multiply value by 8 to get to right Char in Charset
			LD L,A
			ADD HL,HL
			ADD HL,HL
			ADD HL,HL
			PUSH HL						; LD DE,HL
			POP DE
			LD IY, CHARSETADDR
			ADD IY,DE
			CALL PRINTCHAR
			RET
; ----------------------------------------------------------------------------------------


		
; ----------------------------------------------------------------------------------------   
; PRINTCHAR - Prints Char  (IY points to the char. Uses HL as last Cur Pointer)
; ----------------------------------------------------------------------------------------  
PRINTCHAR:	LD B,8						; 8 Lines per char
            LD HL, (SCR_CUR_PTR)		; Load Cursor Pointer y,x 
            INC HL						; move Cursor pointer var to next position
            LD (SCR_CUR_PTR),HL			; update Cursor pointer to next position
            DEC HL						; Restore HL to current printing position
            LD A,(STROKEFLAG)			; Get if text should be crossed out
            SLA A
            SLA A						; Move bit to position 2 (check iteration 4)
            LD C,A						; Save to C
BYTEPCHAR:	LD A,C
			CP B
			LD A, (IY)					; Get Char to be printed, first line
			JR NZ, NOSTROKELINE
			LD A,255
NOSTROKELINE: 
			LD (HL),A					; Move to Printing location           
            INC H						; inc H so next line in char (ZX Spectrum Screen RAM)
            INC IY						; next line to be printed
            DJNZ BYTEPCHAR				; Repeat 8 lines
            LD A,(PRINT_ATTR) 			; Load Attributes to print char with
            LD HL, (SCR_ATTR_PTR)		
            LD (HL),A
            LD HL, SCR_ATTR_PTR			; Get pointer to ATTR
            INC (HL)					; Move Attribute cursor to next char
            RET
; ----------------------------------------------------------------------------------------  



; ----------------------------------------------------------------------------------------   
; PRINTSTR - Prints String - IX Points to the String start
; ----------------------------------------------------------------------------------------      
PRINTSTR:   LD A,(IX)					; A Contains first char to print
			OR A						; check for end of string (0)
			JR Z, FINSTR				; Finish printing if 0
			SUB 32						; ASCII to Charset, which begins on 32
			LD H,0						; Multiply value by 8 to get to right Char in Charset
			LD L,A
			ADD HL,HL
			ADD HL,HL
			ADD HL,HL
			PUSH HL						; LD DE,HL
			POP DE
			LD IY,CHARSETADDR			; Load Charset first Char
			ADD IY,DE					; Move to Char to be printed
			CALL PRINTCHAR				; Print Char
			INC IX						; Move to next char in string
			JR PRINTSTR					; Start over printing sequence	
FINSTR:		RET
; ----------------------------------------------------------------------------------------  



; ----------------------------------------------------------------------------------------   
; INK2PAPER - moves ink of attribute stored in (PRINT_ATTR) to paper and sets ink to 0
; 				Sets bright 1 and flash 0
; ---------------------------------------------------------------------------------------- 
INK2PAPER:	LD A, (PRINT_ATTR)		    ; Get storedAttribute         
            AND 7						; get Attr INK in A
			SLA A
			SLA A
			SLA A						; move Ink to Paper
			OR 64						; ink 0 bright 1
			LD (PRINT_ATTR),A		    ; Get storedAttribute     
			RET
; ---------------------------------------------------------------------------------------- 

; ----------------------------------------------------------------------------------------   
; CLS Main Screen by erasing attributes
; ----------------------------------------------------------------------------------------
CLS:		;EI							; Wait vertical retrace
			;HALT
			;DI
			LD BC,SCRATTRSIZE - 1 		; CLS Screen by writing attributes to 0
        	LD HL,RAMAREASCR+SCRPIXSIZE	
        	LD (HL),0	
        	LD DE,	RAMAREASCR+SCRPIXSIZE+1		; Why Pasmo does not allow LD DE, HL ??
        	;INC E
        	LDIR
        	RET
 ; ----------------------------------------------------------------------------------------      
 
CHARSETADDR: incbin "charset.bin"
 
SCR_CUR_PTR 	EQU	65000						; Cursor Pointer in Screen (2 bytes) (HL)
SCR_ATTR_PTR 	EQU 65002						; Attr Pointer in Screen (2 bytes) (HL)
PRINT_ATTR		EQU 65007						; Attribute used by printchar routine (1 byte)
STROKEFLAG		EQU 65084						; Text print should be crossed out if <> 0 (1 byte)

RAMAREASCR		EQU 16384						; Screen Address
SCRPIXSIZE		EQU 6144						; Size of pixels in screen
SCRATTRSIZE		EQU 768							; Size of attributes in screen
