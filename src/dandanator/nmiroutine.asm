
;		OUTPUT nmiroutine.bin

		ORG 0x0066						; NMI address
		
; ----------------------------------------------------------------------------------------
; NMI ROUTINE @ 0x0066 - NMI Subrutine is used for PIC Firmware Upgrade
; ----------------------------------------------------------------------------------------
NMI:    	POP BC						; Discard Caller Address to avoid Stack overflow
			LD A,(NMICNT)				; Load current Counter
			LD C,A
			LD A,(NMICNT+1)
			LD B,A
			OR C						; Check for first NMI
			JR NZ, NOFIRSTNMI
			PUSH BC
			
			CALL CLS					; Clear Screen
			XOR A
			LD (STROKEFLAG),A			; Texts not Crossed out
			OUT ($FE),A					; Border 0
			
BOXPTR:     LD DE,7
			LD B,11
			LD C, 3
			CALL CRtoATTR
			LD A,9						; INK 1 Paper 1 Bright 0 Flash 0	
			LD B,11						; Y Steps
ALLLINES:	LD C,B
			LD B,25 					; X Steps
LINEPTR:	LD (HL),A
			INC HL
			DJNZ LINEPTR	
			ADD HL,DE
			LD B,C
			DJNZ ALLLINES		

UPGRADEPRT:	LD A, 87					; INK 7 Paper 2 Bright1 Flash 0
			LD B,12						; PRINT AT 6,12 x,y
			LD C,4
			CALL PREP_PRT				; Update Attribute var &Screen & Attributes pointers
			LD IX, UPFWPICTXT1			; Update Firmware text
			CALL PRINTSTR				; Print String
			
NOTOUCHPRT: LD A, 79					; INK 7 Paper 1 Bright1 Flash 0
			LD B,16						; PRINT AT 9,16 x,y
			LD C,9
			CALL PREP_PRT				; Update Attribute var &Screen & Attributes pointers
			LD IX, UPFWPICTXT2			; Update Firmware text
			CALL PRINTSTR				; Print String
			
PROGRESSPRT:LD A, 63					; INK 7 Paper 7 Bright0 Flash 0
			LD B,20						; PRINT AT 6,16 x,y
			LD C,9
			CALL PREP_PRT				; Update Attribute var &Screen & Attributes pointers
			LD IX, UPFWPICTXT3			; Update Firmware text
			CALL PRINTSTR				; Print String
			POP BC
NOFIRSTNMI:			
			LD HL,PICFWRAMADDR
			ADD HL,BC					; HL Points to Data to send
			INC BC						; Count Up
			LD A,C						; Save count back to RAM
			LD (NMICNT),A
			LD A,B
			LD (NMICNT+1),A	
			
PROGBAR:	PUSH HL						; Save Pointer to active Data byte to Send
			ADD A,9
			LD C,A						; Update upgrade bar every 256 bytes
			LD B, 20
			CALL CRtoATTR				; Get Attr Coordinates
			LD A, 100					; INK 4, Paper 4, Bright 1, Flash 0
			LD (HL),A					; Update Attributes in progress bar
			POP HL
					
PULSEBACK:  LD A,(HL)					; Load Data byte to send
			OR A
			JR Z, NMI_DLOCK				; Do not send anything if 0 (otherwise it will send 256 (which is also ok))
			LD B,A
PULSELP:	LD (DDNTRADDRCMD),A			; Send Pulse (any Dandanator Memory addr since ZesarUX wont be emulating this part)
			PUSH HL						; Not to fast pulses - Delay 
			POP HL
			DJNZ PULSELP				; Loop to complete pulses=Data byte value		
NMI_DLOCK:  JR NMI_DLOCK				; Will wait here until another NMI Call			
			RETN						; Return Control to Program (Will never reach this code)
; ----------------------------------------------------------------------------------------

		INCLUDE "print_routines.asm"

UPFWPICTXT1:DEFM "PIC uC Firmware Update", 0
UPFWPICTXT2:DEFM "Hands Off! :)", 0
UPFWPICTXT3:DEFM "             " , 0  

PICFWRAMADDR:	DEFM 	"DNTRMFW-Up" ; Magic String identifying firmware to the bootloader
				incbin 	"pic-fw.bin"


NMICNT			EQU 23400						; NMI Counter for PIC Firmware Upgrade (2 bytes)
DDNTRADDRCONF 	EQU 0							; Address for (Command - Data 1 - Data 2) Confirmation to Dandanator Mini (ZesarUX)
DDNTRADDRCMD 	EQU 1							; Address for Command to Dandanator Mini (ZesarUX) (Already defined on cartload.asm)
DDNTRADDRDAT1 	EQU 2							; Address for Data 1 to Dandanator Mini (ZesarUX)
DDNTRADDRDAT2 	EQU 3							; Address for Data 2 to Dandanator Mini (ZesarUX)
