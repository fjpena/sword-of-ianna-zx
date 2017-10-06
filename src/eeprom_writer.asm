; ----------------------------------------------------------------------------------------  
; ZX Dandanator! Mini - Eeprom Write SST39SF040 Unit to be included in In Sword of Ianna
;
;
; Dandare - Aug 2017
; ----------------------------------------------------------------------------------------  	

RAMADDREXEC	EQU 16384+4096					; <---- ALL THIS MUST BE RUN FROM RAM, SELECT RAM ADDRESS TO COPY ALL THIS CODE										
RETURNINGSLOT EQU 1						; THIS CODE CHANGES SLOT TO 30, MUST RETURN TO SLOT NUMBER ??
SEC2SAVE2 	EQU 120						; Magic Number, fixed sector for storing data (0-127. 120 is first 4KB of slot 30 (0-31)

ORG RAMADDREXEC						; Change all labels to this address

SAVESECT:	LD A,SEC2SAVE2				; Fixed sector to erase
			CALL SSTSECERASE			; Erase Sector
			LD A, SEC2SAVE2				; Fixed sector to save to
			POP HL						; Get source of data in RAM to save
			CALL SSTSECTPROG			; Program Sector
			
RETURNSLOT: LD A,40						; Prepare returning to slot
			LD D,RETURNINGSLOT			; Using special command 40, fast change
			LD E,0
			CALL SENDSPCMD
			
POPREGS:	POP DE						; Restore registers, only HL is used
			POP BC
			POP AF
			
CONFIRM:	CALL SENDCONF				; Send confirmation pulse to return to slot
			RET							; Return to calling address 					
; ----------------------------------------------------------------------------------------					




; ----------------------------------------------------------------------------------------
; ERASE SECTOR 
;     A  = Sector number (39SF040 has 128 4k sectors)
;
; ************  MUST BE RUN FROM RAM, DI, AND WITH EXTERNAL EEPROM PAGED IN  *************
;
; ----------------------------------------------------------------------------------------
SSTSECERASE:PUSH AF						; Save Sector Number
			AND 3						; Get Sector within Page
			SLA A						; Move to A13,A12 in HL
			SLA A
			SLA A
			SLA A
			LD H,A		
			LD L,0
			POP AF						; Get Sector Number Back
			PUSH HL						; Save Address of sector
			
			LD E,A						; Put PIC in Sector Erase Sector Mode
			LD A,48						; Special Command 48, External eeprom operations			
			LD D,16						; 16, Sector erase (sectorn contained in E)
			CALL SENDSPCMD
			CALL SENDCONF				; Send Confirmation pulse
							
			POP HL						; Get Sector Address Back (pushed from HL)
			
SE_Step1:	LD BC, J5555				; Five Step Command to allow Sector Erase
			LD A, $AA
			LD (BC),A			
SE_Step2:	LD BC, J2AAA				
			LD A, $55
			LD (BC),A	
SE_Step3:	LD BC, J5555				
			LD A, $80
			LD (BC),A
SE_Step4:	LD BC, J5555				
			LD A, $AA
			LD (BC),A
SE_Step5:	LD BC, J2AAA				
			LD A, $55
			LD (BC),A
SE_Step6:	LD A, $30					; Actual sector erase		
			LD (HL),A
			
			LD BC,1400					; wait over 25 ms for Sector erase to complete (datasheet pag 13) -> 1400*18us= 25,2 ms
WAITSEC:								; Loop ts = 64ts -> aprox 18us on 128k machines
			EX (SP),HL					; 19ts
			EX (SP),HL					; 19ts
			DEC BC						; 6ts
			LD A,B						; 4ts
			OR C						; 4ts
			JR NZ, WAITSEC				; 12ts / 7ts
			
			RET							; 10ts
; ----------------------------------------------------------------------------------------



; ----------------------------------------------------------------------------------------
; PROGRAM Sector
;    A  = Sector number (39SF040 has 128 4k sectors)
;	 HL = RAM Address of sector to program : Source of data
;
; ************  MUST BE RUN FROM RAM, DI, AND WITH EXTERNAL EEPROM PAGED IN  *************
; ... Sector must be erased first
; ----------------------------------------------------------------------------------------
SSTSECTPROG:PUSH HL						; Save Ram Address
			PUSH AF						; Save Sector Number
			LD E,A						; Put PIC in Sector Program Mode
			LD A,48						; Special Command 48, External eeprom operations			
			LD D,32						; 32, Sector Program
			CALL SENDSPCMD
			CALL SENDCONF				; Send Confirmation pulse
			POP AF						; Get sector number back in A
			POP HL						; Get RAMAddress Back					
			AND 3						; Get two least significant bits of sector number
			SLA A						; Move these bits to A13-A12
			SLA A
			SLA A
			SLA A
			LD D,A						; DE is the beginning of the write area (4k sector aligned) within Slot.
			LD E,0
			
SECTLP:									; Sector Loop 4096 bytes
			
PB_Step1:	LD BC, J5555				; Three Step Command to allow byte-write
			LD A, $AA
			LD (BC),A
PB_Step2: 	LD BC, J2AAA
			LD A, $55
			LD (BC),A
PB_Step3: 	LD BC, J5555
			LD A, $A0
			LD (BC),A	
PB_Step4:	LD A,(HL)					; Write actual byte
			LD (DE),A
										; Datasheet asks for 14us write time, but loop takes longer between actual writes
			INC HL						; Next Data byte
			INC DE						; Next Byte in sector
			LD A,D						; Check for 4096 iterations (D=0x_0, E=0x00)
			AND 15						; Get 4 lower bits
			OR E						; Now also check for a 0x00 in E
			JR NZ, SECTLP
		
			RET
; ----------------------------------------------------------------------------------------





; ----------------------------------------------------------------------------------------
; Send Special Command to Dandanator - Sends Command (a), Data 1 (d) and Data 2 (e)- Prepare for Pulse
; Destroys HL, B.
; Uses Extra 2 bytes on Stack
;
;   ********************  MUST BE RUN FROM RAM IF CHANGING SLOTS ********************
;
; ----------------------------------------------------------------------------------------
SENDSPCMD:	LD HL,DDNTRADDRCMD			; HL=0 Command (ZESARUX)
			CALL SENDNRCMD				; Send command 	

			INC HL						; HL=1 Data 1 (ZESARUX)
			LD A,D						; Data 1
			CALL SENDNRCMD				; Send Data 1

			INC HL						; HL=2 Data2 (ZESARUX)
			LD A,E						; Data 2
			JP SENDNRCMD				; Send Data 2

										; Now about 0,5ms to confirm command with a pulse to DDNTRADDRCONF
; ----------------------------------------------------------------------------------------



; ----------------------------------------------------------------------------------------
; Send Normal Command to Dandanator - Sends Command/Data
;     A  = Cmd/Data, 
;	  HL = port number:  1 for cmd, 2 for data1, 3 for data2, (0 for confirmation) (ZESARUX) 
; Destroys B
; NOTE: 0 is signaled by 256 pulses.
;
;    		********************  MUST BE RUN FROM RAM  ********************
;
; ----------------------------------------------------------------------------------------
SENDNRCMD:	LD B,A	
NRCMDLOOP:	NOP		  					; Some time to avoid very fast pulses
			NOP
			NOP
			LD (HL),A					; Send Pulse			
			DJNZ NRCMDLOOP
	
			LD B, PAUSELOOPSN
WAITXCMD:	DJNZ WAITXCMD				; Wait command detection timeout and Command execution 
			RET							
; ----------------------------------------------------------------------------------------



; ----------------------------------------------------------------------------------------
; Send Confirmation Pulse to dandanator and wait a bit - Also Pause Routine
; ----------------------------------------------------------------------------------------

SENDCONF:	LD (0),A
PAUSE: 		PUSH BC
			LD B,PAUSELOOPSN
WAITPAUSE:	DJNZ WAITPAUSE
			POP BC
			RET			
; ----------------------------------------------------------------------------------------
ENDCODE: 								; End of this code

PAUSELOOPSN 	EQU 40					; Adjusted for both timings (old & new firmware).
DDNTRADDRCMD 	EQU 1
J5555			EQU $1555				; Jedec $5555 with a15,a14=0 to force rom write (PIC will set page 1 so final address will be $5555)
J2AAA			EQU	$2AAA				; Jedec $2AAA, Pic will select page 0
