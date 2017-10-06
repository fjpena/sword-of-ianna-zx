; tab(8)
; Arkos Tracker Player V1.0 - Spectrum / Pentagon version.
;   Code by Targhan/Arkos
;   Speccy port / source re-layout by Grim/Arkos
;
; Compile fine with Pasmo v0.5.4.beta2
; Manual and informations available at http://arkostracker.cpcscene.com/
; I know, I know... I'm a tab-indent-zealot =)

;*** Configuration switches ****************************************************

		; Switch between Speccy or Pentagon AY3 Tone table
		; 1 = Spectrum / any other value = Pentagon
atCNF_ZXPT	equ 1

		; Enable/Disable sound effect support.
		; 0 = Disabled / any other value = Enabled
atCNF_SFX	equ 1

		; Enable/Disable volume fade support.
		; 0 = Disabled / any other value = Enabled
atCNF_FADE	equ 0

;*** Player API ****************************************************************

		; Initialize the player
		; - Routine: atInit
		; - Input:
		;	DE = Song data address

		; Play one tick of the music
		; - Routine: atPlay
		; - Output:
		;	_All_ CPU registers might be modified.

		; Stop all sounds (reset the AY3)
		; - Routine: atStop

;*** Optionnal sound effect API ************************************************

		; Initialize sound effects
		; - Routine: atSfxInit
		; - Input:
		;	DE = Song data address
		
		; Trigger a sound effect on a channel
		; - Routine: atSfxPlay
		; - Input:
		;	 A = Channel (0,1 or 2)
		;	 L = Sound effect number (>0)
		;	 H = Volume (0 to 15)
		;	 E = Note key (0 to 143)
		;	 D = Speed
		;	BC = Pitch offset
		; If the speed parameter is 0, the original intrument speed is used. Any value between
		; 1 and 255 will over-ride the default speed (1 being the fastest).

		; Stop any sound effect on a given channel
		; - Routine: atSfxStop
		; - Input:
		;	A = Channel (0,1 or 2)
		

		; Stop sound effect on all the 3 channels.
		; - Routine: atSfxStopAll
		
;*** Optionnal fade API ********************************************************

		; Set the amount by which the song volume is decreased.
		; - Routine: atFade
		; - Input:
		;	A = volume decrease (0 = no fade, 15+ = enjoy the silence)


;*** Player mighty code ********************************************************

; Internal constant, do not change
_atDEF_R13RetrigValue		equ #FE

atPlay:
				xor a
				ld (_atVAR_digidrum),a		;Reset the Digidrum flag.

; If Speed counter is over, we have to read the Pattern further.
_atVAR_SongSpeedCtr		ld a,1
				dec a
				jp nz,_atSetSongSpeedCtr

; Do we have to move to the next song position or continue in the same pattern?
_atVAR_patternHeightCtr			ld a,1
					dec a
					jr nz,_atSetPatternHeightCtr

					; Pattern Over. We have to read the Linker.
					; Get the Transpositions, if they have changed,
					; or detect the Song Ending !

_atVAR_Linker					ld hl,0
						ld a,(hl)
						inc hl
						rra
						jr nc,_atSongContinue
							; Get the song loop position
							ld a,(hl)
							inc hl
							ld h,(hl)
							ld l,a
							ld a,(hl)	; We know the Song won't restart now,
							inc hl		; so we can skip the first bit.
							rra
_atSongContinue
						rra
						jr nc,_atKeepTrCh1
							ld de,_atVAR_TranspCh1 + 1
							ldi
_atKeepTrCh1
				  		rra
						jr nc,_atKeepTrCh2
							ld de,_atVAR_TranspCh2 + 1
							ldi
_atKeepTrCh2
						rra
						jr nc,_atKeepTrCh3
							ld de,_atVAR_TranspCh3 + 1
							ldi
_atKeepTrCh3
						; Get the Tracks addresses.
						ld de,_atVAR_Track1Ptr + 1
						ldi
						ldi
						ld de,_atVAR_Track2Ptr + 1
						ldi
						ldi
						ld de,_atVAR_Track3Ptr + 1
						ldi
						ldi
					
						; Get the Special Track address, if it has changed.
						rra
						jr nc,_atKeepPatternHeight
							ld de,_atVAR_PatternHeight + 1
							ldi
_atKeepPatternHeight
						rra
						jr nc,_atReplaySpecialTrack
							; Load a new special track
							ld e,(hl)
							inc hl
							ld d,(hl)
							inc hl
							ld (_atVAR_SpecialTrackAddr + 1),de
_atReplaySpecialTrack
						ld (_atVAR_Linker + 1),hl
_atVAR_SpecialTrackAddr 			ld hl,0
						ld (_atVAR_SpecialTrackPtr + 1),hl
			
						; Reset the SpecialTrack/Tracks line counter.
						; We can't rely on the song data, because the
						; Pattern Height is not related to the Tracks Height.
						ld a,1
						ld (_atVAR_WaitSpecialTrack + 1),a
						ld (_atVAR_WaitTrack1 + 1),a
						ld (_atVAR_WaitTrack2 + 1),a
						ld (_atVAR_WaitTrack3 + 1),a

_atVAR_PatternHeight				ld a,1
_atSetPatternHeightCtr
					ld (_atVAR_patternHeightCtr + 1),a


;*** Read Special Track ********************************************************

_atVAR_WaitSpecialTrack			ld a,1
					dec a
					jr nz,_atSpecialTrackWait

_atVAR_SpecialTrackPtr				ld hl,0
						ld a,(hl)
						inc hl
						srl a				;Data (1) or Wait (0) ?
						jr nc,_atSpecialTrack_waitCmd	;If Wait, A contains the Wait value.
							srl a			;Speed (0) or Digidrum (1) ?
							; First, we don't test the Effect Type, but only the Escape Code (=0)
							jr nz,_atSpecialTrackNoEscCode
								ld a,(hl)
								inc hl
_atSpecialTrackNoEscCode
							; Now, we test the Effect type, since the Carry didn't change.
							jr nc,_atSpecialTrack_speedCmd
								ld (_atVAR_digidrum),a
								jp _atSpecialTrack_proceed
_atSpecialTrack_speedCmd
							ld (_atVAR_SongSpeed + 1),a
_atSpecialTrack_proceed
							ld a,1
_atSpecialTrack_waitCmd
						ld (_atVAR_SpecialTrackPtr + 1),hl
_atSpecialTrackWait
					ld (_atVAR_WaitSpecialTrack + 1),a


;*** Read Track 1 **************************************************************

_atVAR_WaitTrack1 			ld a,1
					dec a
					jr nz,_atTrack1Wait


_atVAR_Track1Ptr 			ld hl,0
					call _atReadTrack
					ld (_atVAR_Track1Ptr + 1),hl
					jr c,_atTrack1Wait
					
						; No Wait command. Can be a Note and/or Effects.
						ld a,d	; Make a copy of the flags+Volume in A, not to temper with the original.
						rra	; Volume ? If bit 4 was 1, then volume exists on b3-b0
						jr nc,_atTrack1_keepVolume
							and %1111
							ld (_atVAR_Track1Volume),a
_atTrack1_keepVolume
						rl d	; New Pitch ?
						jr nc,_atTrack1_keepPitch
							ld (_atVAR_Track1PitchAdd + 1),ix
_atTrack1_keepPitch
						rl d	; Note ? If no Note, we don't have to test if a new Instrument is here.
						jr nc,_atTrack1_keepNote
							ld a,e
							; Transpose Note according to the Transposition in the Linker.
_atVAR_TranspCh1					add a,0
							ld (_atVAR_Track1Note),a
							; Reset the TrackPitch.
							ld hl,0
							ld (_atVAR_Track1Pitch + 1),hl
							; New Instrument ?
							rl d
							jr c,_atTrack1LoadInstrument
								; Same Instrument. We recover its address to restart it.
_atVAR_Track1InstAddr						ld hl,0	
								ld a,(_atVAR_Track1InstSpeed + 1)
								ld (_atVAR_Track1InstSpeedCtr + 1),a
								jp _atTrack1SetInstrumentPtr

_atTrack1LoadInstrument					; New Instrument. We have to get its new address, and Speed.
							ld l,b					; H is already set to 0 before.
							add hl,hl
_atVAR_Track1InstrumentLUT				ld bc,0
							add hl,bc
							ld a,(hl)				; Get Instrument address.
							inc hl
							ld h,(hl)
							ld l,a
							ld a,(hl)				; Get Instrument speed.
							inc hl
							ld (_atVAR_Track1InstSpeed + 1),a
							ld (_atVAR_Track1InstSpeedCtr + 1),a
							ld a,(hl)
							or a					; Get IsRetrig?. Code it only if different to 0, else next Instruments are going to overwrite it.
							jr z,$+5
								ld (_atVAR_R13Lock + 1),a	; Poke &FE as previous R13 value
							inc hl
							ld (_atVAR_Track1InstAddr + 1),hl	; When using the Instrument again, no need to give the Speed, it is skipped.
_atTrack1SetInstrumentPtr
							ld (_atVAR_Track1InstrumentPtr + 1),hl
_atTrack1_keepNote
						ld a,1
_atTrack1Wait
					ld (_atVAR_WaitTrack1 + 1),a


;*** Read Track 2 **************************************************************

_atVAR_WaitTrack2			ld a,1
					dec a
					jr nz,_atTrack2Wait
					
					
_atVAR_Track2Ptr			ld hl,0
					call _atReadTrack
					ld (_atVAR_Track2Ptr + 1),hl
					jr c,_atTrack2Wait

						; No Wait command. Can be a Note and/or Effects.
						; Make a copy of the flags+Volume in A, not to temper with the original.
						ld a,d
						rra	; Volume ? If bit 4 was 1, then volume exists on b3-b0
						jr nc,_atTrack2_keepVolume
							and %1111
							ld (_atVAR_Track2Volume),a
_atTrack2_keepVolume
						rl d				; New Pitch ?
						jr nc,_atTrack2_keepPitch
							ld (_atVAR_Track2PitchAdd + 1),ix
_atTrack2_keepPitch

						rl d				; Note ? If no Note, we don't have to test if a new Instrument is here.
						jr nc,_atTrack2_keepNote
						
							; Transpose Note according to the Transposition in the Linker.
							ld a,e
_atVAR_TranspCh2					add a,0
							ld (_atVAR_Track2Note),a
							; Reset the TrackPitch.
							ld hl,0
							ld (_atVAR_Track2Pitch + 1),hl
							; New Instrument ?
							rl d
							jr c,_atTrack2LoadInstrument
								; Same Instrument. We recover its address to restart it.
_atVAR_Track2InstAddr						ld hl,0
								ld a,(_atVAR_Track2InstSpeed + 1)
								ld (_atVAR_Track2InstSpeedCtr + 1),a
								jp _atTrack2SetInstrumentPtr

_atTrack2LoadInstrument					; New Instrument. We have to get its new address, and Speed.
							ld l,b					; H is already set to 0 before.
							add hl,hl
_atVAR_Track2InstrumentLUT				ld bc,0
							add hl,bc
							ld a,(hl)				; Get Instrument address.
							inc hl
							ld h,(hl)
							ld l,a
							ld a,(hl)				; Get Instrument speed.
							inc hl
							ld (_atVAR_Track2InstSpeed + 1),a
							ld (_atVAR_Track2InstSpeedCtr + 1),a
							ld a,(hl)
							or a					; Get IsRetrig?. Code it only if different to 0, else next Instruments are going to overwrite it.
							jr z,$+5
								ld (_atVAR_R13Lock + 1),a	; Poke &FE as previous R13 value
							inc hl
							ld (_atVAR_Track2InstAddr + 1),hl	; When using the Instrument again, no need to give the Speed, it is skipped.
_atTrack2SetInstrumentPtr
							ld (_atVAR_Track2InstrumentPtr + 1),hl
_atTrack2_keepNote
						ld a,1
_atTrack2Wait
					ld (_atVAR_WaitTrack2 + 1),a


;*** Read Track 3 **************************************************************

_atVAR_WaitTrack3 			ld a,1
					dec a
					jr nz,_atTrack3Wait
					
					
_atVAR_Track3Ptr			ld hl,0
					call _atReadTrack
					ld (_atVAR_Track3Ptr + 1),hl
					jr c,_atTrack3Wait

						; No Wait command. Can be a Note and/or Effects.
						; Make a copy of the flags+Volume in A, not to temper with the original.
						ld a,d
						rra	; Volume ? If bit 4 was 1, then volume exists on b3-b0
						jr nc,_atTrack3_keepVolume
							and %1111
							ld (_atVAR_Track3Volume),a
_atTrack3_keepVolume
						rl d	; New Pitch ?
						jr nc,_atTrack3_keepPitch
							ld (_atVAR_Track3PitchAdd + 1),ix
_atTrack3_keepPitch
						rl d	; Note ? If no Note, we don't have to test if a new Instrument is here.
						jr nc,_atTrack3_keepNote
						
							;Transpose Note according to the Transposition in the Linker.
							ld a,e
_atVAR_TranspCh3					add a,0
							ld (_atVAR_Track3Note),a
							;Reset the TrackPitch.
							ld hl,0	
							ld (_atVAR_Track3Pitch + 1),hl
							;New Instrument ?
							rl d
							jr c,_atTrack3LoadInstrument
								;Same Instrument. We recover its address to restart it.
_atVAR_Track3InstAddr						ld hl,0	
								;Reset the Instrument Speed Counter. Never seemed useful...
								ld a,(_atVAR_Track3InstSpeed + 1)
								ld (_atVAR_Track3InstSpeedCtr + 1),a
								jp _atTrack3SetInstrumentPtr

_atTrack3LoadInstrument					;New Instrument. We have to get its new address, and Speed.
							ld l,b					;H is already set to 0 before.
							add hl,hl
_atVAR_Track3InstrumentLUT				ld bc,0
							add hl,bc
							ld a,(hl)				;Get Instrument address.
							inc hl
							ld h,(hl)
							ld l,a
							ld a,(hl)				;Get Instrument speed.
							inc hl
							ld (_atVAR_Track3InstSpeed + 1),a
							ld (_atVAR_Track3InstSpeedCtr + 1),a
							ld a,(hl)
							or a					; Get IsRetrig?. Code it only if different to 0, else next Instruments are going to overwrite it.
							jr z,$+5
								ld (_atVAR_R13Lock + 1),a	; Poke &FE as previous R13 value
							inc hl
							ld (_atVAR_Track3InstAddr + 1),hl	; When using the Instrument again, no need to give the Speed, it is skipped.
_atTrack3SetInstrumentPtr
							ld (_atVAR_Track3InstrumentPtr + 1),hl
_atTrack3_keepNote
						ld a,1
_atTrack3Wait
					ld (_atVAR_WaitTrack3 + 1),a

_atVAR_SongSpeed 			ld a,1
_atSetSongSpeedCtr		ld (_atVAR_SongSpeedCtr + 1),a



;*** Play Sound on Track 3 *****************************************************
; Plays the sound on each frame, but only save the forwarded Instrument pointer when Instrument Speed is reached.
; This is needed because TrackPitch is involved in the Software Frequency/Hardware Frequency calculation, and is calculated every frame.

				ld iy,_atVAR_AY3Registers + 4
_atVAR_Track3Pitch		ld hl,0
_atVAR_Track3PitchAdd		ld de,0
				add hl,de
				ld (_atVAR_Track3Pitch + 1),hl
				sra h	;Shift the Pitch to slow its speed.
				rr l
				sra h
				rr l
				ex de,hl
				exx

_atVAR_Track3Volume		equ $+2
_atVAR_Track3Note		equ $+1
				ld de,0	;D=Inverted Volume E=Note
_atVAR_Track3InstrumentPtr	ld hl,0
				call _atPlaySound

_atVAR_Track3InstSpeedCtr	ld a,1
				dec a
				jr nz,_atSoundTrack3_noForward
					ld (_atVAR_Track3InstrumentPtr + 1),hl
_atVAR_Track3InstSpeed			ld a,6
_atSoundTrack3_noForward
				ld (_atVAR_Track3InstSpeedCtr + 1),a


; Play Sound Effects on Track 3 (compiled only if SFX support is enabled)
				if atCNF_SFX

_atVAR_SfxTrack3_pitch			ld de,0
					exx
_atVAR_SfxTrack3_instrument		ld hl,0	;If 0, no sound effect.
					ld a,l
					or h
					jr z,_atNoSfxTrack3
					
						ld de,0	;D=Inverted Volume E=Note
						
						ld a,1
						ld (PLY_PS_EndSound_SFX + 1),a
						call _atPlaySound
						xor a
						ld (PLY_PS_EndSound_SFX + 1),a
						ld a,l				;If the new address is 0, the instrument is over. Speed is set in the process, we don't care.
						or h
						jr z,_atVAR_SfxTrack3_setInstrumentAddr

_atVAR_SfxTrack3_instrumentSpeedCtr			ld a,1
							dec a
							jr nz,_atSfxTrack3_noForward
_atVAR_SfxTrack3_setInstrumentAddr
								ld (_atVAR_SfxTrack3_instrument + 1),hl
_atVAR_SfxTrack3_instrumentSpeed				ld a,6
_atSfxTrack3_noForward
					ld (_atVAR_SfxTrack3_instrumentSpeedCtr + 1),a

_atNoSfxTrack3
				endif
				

				; Update AY3-Reg7 with Track3 flags
				ld a,ixl
				ex af,af'

;Play the Sound on Track 2
;-------------------------
				ld iy,_atVAR_AY3Registers + 2
_atVAR_Track2Pitch 		ld hl,0
_atVAR_Track2PitchAdd		ld de,0
				add hl,de
				ld (_atVAR_Track2Pitch + 1),hl
				sra h				;Shift the Pitch to slow its speed.
				rr l
				sra h
				rr l
				ex de,hl
				exx

_atVAR_Track2Volume		equ $+2
_atVAR_Track2Note		equ $+1
				ld de,0		;D=Inverted Volume E=Note
_atVAR_Track2InstrumentPtr	ld hl,0
				call _atPlaySound

_atVAR_Track2InstSpeedCtr	ld a,1
				dec a
				jr nz,_atSoundTrack2_noForward
					ld (_atVAR_Track2InstrumentPtr + 1),hl
_atVAR_Track2InstSpeed			ld a,6
_atSoundTrack2_noForward
				ld (_atVAR_Track2InstSpeedCtr + 1),a



; Play Sound Effects on Track 2 (compiled only if SFX support is enabled)
				if atCNF_SFX

_atVAR_SfxTrack2_pitch			ld de,0
					exx
_atVAR_SfxTrack2_instrument		ld hl,0	; If 0, no sound effect.
					ld a,l
					or h
					jr z,_atNoSfxTrack2
					
						ld de,0	; D=Inverted Volume E=Note
						
						ld a,1
						ld (PLY_PS_EndSound_SFX + 1),a
						call _atPlaySound
						xor a
						ld (PLY_PS_EndSound_SFX + 1),a
						ld a,l	;If the new address is 0, the instrument is over. Speed is set in the process, we don't care.
						or h
						jr z,_atVAR_SfxTrack2_setInstrumentAddr

_atVAR_SfxTrack2_instrumentSpeedCtr			ld a,1
							dec a
							jr nz,_atSfxTrack2_noForward
_atVAR_SfxTrack2_setInstrumentAddr
								ld (_atVAR_SfxTrack2_instrument + 1),hl
_atVAR_SfxTrack2_instrumentSpeed				ld a,6
_atSfxTrack2_noForward
							ld (_atVAR_SfxTrack2_instrumentSpeedCtr + 1),a
_atNoSfxTrack2

				endif
				

				ex af,af'
				add a,a			;Mix Reg7 from Track2 with Track3, making room first.
				or ixl
				rla
				ex af,af'



;Play the Sound on Track 1
;-------------------------

				ld iy,_atVAR_AY3Registers
_atVAR_Track1Pitch		ld hl,0
_atVAR_Track1PitchAdd		ld de,0
				add hl,de
				ld (_atVAR_Track1Pitch + 1),hl
				sra h				;Shift the Pitch to slow its speed.
				rr l
				sra h
				rr l
				ex de,hl
				exx

_atVAR_Track1Volume		equ $+2
_atVAR_Track1Note		equ $+1
				ld de,0				;D=Inverted Volume E=Note
_atVAR_Track1InstrumentPtr	ld hl,0
				call _atPlaySound

_atVAR_Track1InstSpeedCtr	ld a,1
				dec a
				jr nz,_atSoundTrack1_noForward
				ld (_atVAR_Track1InstrumentPtr + 1),hl
_atVAR_Track1InstSpeed		ld a,6
_atSoundTrack1_noForward
				ld (_atVAR_Track1InstSpeedCtr + 1),a




;***************************************
;Play Sound Effects on Track 1 (only assembled used if atCNF_SFX is set to one)
;***************************************
				if atCNF_SFX


_atVAR_SfxTrack1_pitch			ld de,0
					exx
_atVAR_SfxTrack1_instrument		ld hl,0	;If 0, no sound effect.
					ld a,l
					or h
					jr z,_atNoSfxTrack1
					
_atVAR_SfxTrack1_volume				equ $+2
_atVAR_SfxTrack1_note				equ $+1
						ld de,0	;D=Inverted Volume E=Note
					
						ld a,1
						ld (PLY_PS_EndSound_SFX + 1),a
						call _atPlaySound
						xor a
						ld (PLY_PS_EndSound_SFX + 1),a
						ld a,l				;If the new address is 0, the instrument is over. Speed is set in the process, we don't care.
						or h
						jr z,_atSfxTrack1_setInstrumentAddr

_atVAR_SfxTrack1_instrumentSpeedCtr			ld a,1
							dec a
							jr nz,_atSfxTrack1_noForward
_atSfxTrack1_setInstrumentAddr
								ld (_atVAR_SfxTrack1_instrument + 1),hl
_atVAR_SfxTrack1_instrumentSpeed				ld a,6
_atSfxTrack1_noForward
							ld (_atVAR_SfxTrack1_instrumentSpeedCtr + 1),a
_atNoSfxTrack1
				endif
				
				; 
				ex af,af'
				or ixl

;*** Update AY3 Registers (platform specific) **********************************

				; Update AY3 registers (unrolled)
				; - Input:
				;	A = AY3 Register 7 value
_atAY3Update
				ex af,af'	; save R7
				
				ld hl,_atVAR_AY3Registers
				ld de,#BFFF
				ld bc,#FFFD
				
				xor a		; R0
				out (c),a
				ld b,d
				outi
				ld b,e
				
				inc a		; R1
				out (c),a
				ld b,d
				outi
				ld b,e
				
				inc a		; R2
				out (c),a
				ld b,d
				outi
				ld b,e
				
				inc a		; R3
				out (c),a
				ld b,d
				outi
				ld b,e
				
				inc a		; R4
				out (c),a
				ld b,d
				outi
				ld b,e
				
				inc a		; R5
				out (c),a
				ld b,d
				outi
				ld b,e
				
				inc a		; R6
				out (c),a
				ld b,d
				outi
				ld b,e
				
				inc a		; R7
				out (c),a
				ld b,d
				ex af,af'
				out (c),a	; R7 value is held in AF'
				ex af,af'	; not in the registers buffer
				ld b,e
				
				inc a		; R8
				out (c),a
				ld b,d
				if atCNF_FADE
					ex af,af'
					dec b
					ld a,(hl)
					inc hl
_azVAR_FadeChA				equ $+1
					sub 0
					jr nc,$+3
					xor a
					out (c),a
					ex af,af'
				else
					outi
				endif
				inc hl		; skip digidrum id byte
				ld b,e
				
				inc a		; R9
				out (c),a
				ld b,d
				if atCNF_FADE
					ex af,af'
					dec b
					ld a,(hl)
					inc hl
_azVAR_FadeChB				equ $+1
					sub 0
					jr nc,$+3
					xor a
					out (c),a
					ex af,af'
				else
					outi
				endif
				inc hl		; skip wasted byte
				ld b,e
				
				inc a		; R10
				out (c),a
				ld b,d
				if atCNF_FADE
					ex af,af'
					dec b
					ld a,(hl)
					inc hl
_azVAR_FadeChC				equ $+1
					sub 0
					jr nc,$+3
					xor a
					out (c),a
					ex af,af'
				else
					outi
				endif
				ld b,e
				
				inc a		; R11
				out (c),a
				ld b,d
				outi
				ld b,e
				
				inc a		; R12
				out (c),a
				ld b,d
				outi
				ld b,e
		
				inc a		; R13
				out (c),a
				ld a,(hl)
_atVAR_R13Lock			cp 255
				ret z
				
				ld b,d
				out (c),a
				ld (_atVAR_R13Lock + 1),a
				ret




_atVAR_AY3Registers

_atVAR_Reg0			db 0
_atVAR_Reg1			db 0
_atVAR_Reg2			db 0
_atVAR_Reg3			db 0
_atVAR_Reg4			db 0
_atVAR_Reg5			db 0
_atVAR_Reg6			db 0
_atVAR_Reg8			db 0		;+7

; Digidrum ID triggered by the song (0=no digidrum)
_atVAR_digidrum			db 0

_atVAR_Reg9			db 0		;+9
				db 0
_atVAR_Reg10			db 0		;+11
_atVAR_Reg11			db 0
_atVAR_Reg12			db 0
_atVAR_Reg13			db 0



;(nbGrim - these sound routines need some tweaks imo)

;Plays a sound stream.
;HL=Pointer on Instrument Data
;IY=Pointer on Register code (volume, frequency).
;E=Note
;D=Inverted Volume
;DE'=TrackPitch

;RET=
;HL=New Instrument pointer.
;IXL=Reg7 mask (x00x)

;Also used inside =
;B,C=read byte/second byte.
;IXH=Save original Note (only used for Independant mode).


_atPlaySound
				ld b,(hl)
				inc hl
				rr b
				jp c,PLY_PS_Hard

;**************
;Software Sound
;**************
				;Second Byte needed ?
				rr b
				jp c,PLY_PS_S_SecondByteNeeded

				;No second byte needed. We need to check if Volume is null or not.
				ld a,b
				and %1111
				jr nz,PLY_PS_S_SoundOn

				;Null Volume. It means no Sound. We stop the Sound, the Noise, and it's over.
				ld (iy+7),a			;We have to make the volume to 0, because if a bass Hard was activated before, we have to stop it.
				ld ixl,%1001
				ret

PLY_PS_S_SoundOn
				;Volume is here, no Second Byte needed. It means we have a simple Software sound (Sound = On, Noise = Off)
				;We have to test Arpeggio and Pitch, however.
				ld ixl,%1000

				sub d						;Code Volume.
				jr nc,$+3
				xor a
				ld (iy+7),a

				rr b						;Needed for the subroutine to get the good flags.
				call _atSound_calcFrequency
				ld (iy+0),l					;Code Frequency.
				ld (iy+1),h
				exx
				ret
	


PLY_PS_S_SecondByteNeeded
				ld ixl,%1000	;By defaut, No Noise, Sound.

				;Second Byte needed.
				ld c,(hl)
				inc hl

				;Noise ?
				ld a,c
				and %11111
				jp z,PLY_PS_S_SBN_NoNoise
				ld (_atVAR_Reg6),a
				ld ixl,%0000					;Open Noise Channel.
PLY_PS_S_SBN_NoNoise

				;Here we have either Volume and/or Sound. So first we need to read the Volume.
				ld a,b
				and %1111
				sub d						;Code Volume.
				jr nc,$+3
				xor a
				ld (iy+7),a

				;Sound ?
				bit 5,c
				jp nz,PLY_PS_S_SBN_Sound
				;No Sound. Stop here.
				inc ixl						;Set Sound bit to stop the Sound.
				ret

PLY_PS_S_SBN_Sound
				;Manual Frequency ?
				rr b						;Needed for the subroutine to get the good flags.
				bit 6,c
				call _atSound_getFrequency
				ld (iy+0),l					;Code Frequency.
				ld (iy+1),h
				exx
				ret




;**********
;Hard Sound
;**********
PLY_PS_Hard
				;We don't set the Volume to 16 now because we may have reached the end of the sound !

				rr b						;Test Retrig here, it is common to every Hard sounds.
				jr nc,PLY_PS_Hard_NoRetrig
					ld a,(_atVAR_Track1InstSpeedCtr + 1)	;Retrig only if it is the first step in this line of Instrument !
					ld c,a
					ld a,(_atVAR_Track1InstSpeed + 1)
					cp c
					jr nz,PLY_PS_Hard_NoRetrig
						ld a,_atDEF_R13RetrigValue
						ld (_atVAR_R13Lock + 1),a
PLY_PS_Hard_NoRetrig

				;Independant/Loop or Software/Hardware Dependent ?
				bit 1,b				;We don't shift the bits, so that we can use the same code (Frequency calculation) several times.
				jp nz,PLY_PS_Hard_LoopOrIndependent

				;Hardware Sound.
				ld (iy+7),16					;Set Volume
				ld ixl,%1000					;Sound is always On here (only Independence mode can switch it off).

				;This code is common to both Software and Hardware Dependent.
				ld c,(hl)			;Get Second Byte.
				inc hl
				ld a,c				;Get the Hardware Envelope waveform.
				and %1111			;We don't care about the bit 7-4, but we have to clear them, else the waveform might be reset.
				ld (_atVAR_Reg13),a

				bit 0,b
				jp z,PLY_PS_HardwareDependent

;******************
;Software Dependent
;******************

				;Calculate the Software frequency
				bit 4-2,b		;Manual Frequency ? -2 Because the byte has been shifted previously.
				call _atSound_getFrequency
				ld (iy+0),l		;Code Software Frequency.
				ld (iy+1),h
				exx

				;Shift the Frequency.
				ld a,c
				rra
				rra			;Shift=Shift*4. The shift is inverted in memory (7 - Editor Shift).
				and %11100
				ld (PLY_PS_SD_Shift + 1),a
				ld a,b			;Used to get the HardwarePitch flag within the second registers set.
				exx

PLY_PS_SD_Shift 		jr $+2
				srl h
				rr l
				srl h
				rr l
				srl h
				rr l
				srl h
				rr l
				srl h
				rr l
				srl h
				rr l
				srl h
				rr l
				jr nc,$+3
				inc hl

				;Hardware Pitch ?
				bit 7-2,a
				jr z,PLY_PS_SD_NoHardwarePitch
					exx						;Get Pitch and add it to the just calculated Hardware Frequency.
					ld a,(hl)
					inc hl
					exx
					add a,l						;Slow. Can be optimised ? Probably never used anyway.....
					ld l,a
					exx
					ld a,(hl)
					inc hl
					exx
					adc a,h
					ld h,a
PLY_PS_SD_NoHardwarePitch
				ld (_atVAR_Reg11),hl
				exx


				;This code is also used by Hardware Dependent.
PLY_PS_SD_Noise
				;Noise ?
				bit 7,c
				ret z
				ld a,(hl)
				inc hl
				ld (_atVAR_Reg6),a
				ld ixl,%0000
				ret




;******************
;Hardware Dependent
;******************
PLY_PS_HardwareDependent
				;Calculate the Hardware frequency
				bit 4-2,b			;Manual Hardware Frequency ? -2 Because the byte has been shifted previously.
				call _atSound_getFrequency
				ld (_atVAR_Reg11),hl		;Code Hardware Frequency.
				exx

				;Shift the Hardware Frequency.
				ld a,c
				rra
				rra			;Shift=Shift*4. The shift is inverted in memory (7 - Editor Shift).
				and %11100
				ld (PLY_PS_HD_Shift + 1),a
				ld a,b			;Used to get the Software flag within the second registers set.
				exx


PLY_PS_HD_Shift 		jr $+2
				sla l
				rl h
				sla l
				rl h
				sla l
				rl h
				sla l
				rl h
				sla l
				rl h
				sla l
				rl h
				sla l
				rl h

				;Software Pitch ?
				bit 7-2,a
				jr z,PLY_PS_HD_NoSoftwarePitch
					exx						;Get Pitch and add it to the just calculated Software Frequency.
					ld a,(hl)
					inc hl
					exx
					add a,l
					ld l,a						;Slow. Can be optimised ? Probably never used anyway.....
					exx
					ld a,(hl)
					inc hl
					exx
					adc a,h
					ld h,a
PLY_PS_HD_NoSoftwarePitch
				ld (iy+0),l					;Code Frequency.
				ld (iy+1),h
				exx

				;Go to manage Noise, common to Software Dependent.
				jp PLY_PS_SD_Noise

PLY_PS_Hard_LoopOrIndependent
				bit 0,b					;We mustn't shift it to get the result in the Carry, as it would be mess the structure
				jp z,PLY_PS_Independent			;of the flags, making it uncompatible with the common code.

				;The sound has ended.
				;If Sound Effects activated, we mark the "end of sound" by returning a 0 as an address.
				if atCNF_SFX
PLY_PS_EndSound_SFX ld a,0			;Is the sound played is a SFX (1) or a normal sound (0) ?
					or a
					jr nz,PLY_PS_EndSFX
				endif

				;The sound has ended. Read the new pointer and restart instrument.
				ld a,(hl)
				inc hl
				ld h,(hl)
				ld l,a
				jp _atPlaySound
				
				if atCNF_SFX
PLY_PS_EndSFX
					ld hl,0
					ret
				endif




;***********
;Independent
;***********
PLY_PS_Independent
				ld (iy+7),16			;Set Volume
			
				;Sound ?
				bit 7-2,b			;-2 Because the byte has been shifted previously.
				jp nz,PLY_PS_I_SoundOn
					;No Sound ! It means we don't care about the software frequency (manual frequency, arpeggio, pitch).
					ld ixl,%1001
					jp PLY_PS_I_SkipSoftwareFrequencyCalculation

PLY_PS_I_SoundOn
				ld ixl,%1000			;Sound is on.
				ld ixh,e			;Save the original note for the Hardware frequency, because a Software Arpeggio will modify it.

				;Calculate the Software frequency
				bit 4-2,b			;Manual Frequency ? -2 Because the byte has been shifted previously.
				call _atSound_getFrequency
				ld (iy+0),l			;Code Software Frequency.
				ld (iy+1),h
				exx

				ld e,ixh
PLY_PS_I_SkipSoftwareFrequencyCalculation

				ld b,(hl)			;Get Second Byte.
				inc hl
				ld a,b				;Get the Hardware Envelope waveform.
				and %1111			;We don't care about the bit 7-4, but we have to clear them, else the waveform might be reset.
				ld (_atVAR_Reg13),a

				;Calculate the Hardware frequency
				rr b				;Must shift it to match the expected data of the subroutine.
				rr b
				bit 4-2,b			;Manual Hardware Frequency ? -2 Because the byte has been shifted previously.
				call _atSound_getFrequency
				ld (_atVAR_Reg11),hl		;Code Hardware Frequency.
				exx

				;Noise ? We can't use the previous common code, because the setting of the Noise is different, since Independent can have no Sound.
				bit 7-2,b
				ret z
				ld a,(hl)
				inc hl
				ld (_atVAR_Reg6),a
				ld a,ixl	;Set the Noise bit.
				res 3,a
				ld ixl,a
				ret



;Subroutine that =
;If Manual Frequency? (Flag Z off), read frequency (Word) and adds the TrackPitch (DE').
;Else, Auto Frequency.
;	if Arpeggio? = 1 (bit 3 from B), read it (Byte).
;	if Pitch? = 1 (bit 4 from B), read it (Word).
;	Calculate the frequency according to the Note (E) + Arpeggio + TrackPitch (DE').

;HL = Pointer on Instrument data.
;DE'= TrackPitch.

;RET=
;HL = Pointer on Instrument moved forward.
;HL'= Frequency
;	RETURN IN AUXILIARY REGISTERS
_atSound_getFrequency:
				jr nz,_atSound_getFrequency_manual
_atSound_calcFrequency:
				;Pitch ?
				bit 5-1,b
				jr z,_atSound_calcFrequency_noPitch
					ld a,(hl)
					inc hl
					exx
					add a,e						;If Pitch found, add it directly to the TrackPitch.
					ld e,a
					exx
					ld a,(hl)
					inc hl
					exx
					adc a,d
					ld d,a
					exx
					
_atSound_calcFrequency_noPitch
				;Arpeggio ?
				ld a,e
				bit 4-1,b
				jr z,_atSound_calcFrequency_noArp
					add a,(hl)					;Add Arpeggio to Note.
					inc hl						; possible overflow?
					cp 144
					jr c,$+4
					ld a,143
_atSound_calcFrequency_noArp
				;Frequency calculation.
				exx
				ld l,a
				ld h,0
				add hl,hl
				ld bc,_atLUT_notePeriods
				add hl,bc
				ld a,(hl)
				inc hl
				ld h,(hl)
				ld l,a
				add hl,de					;Add TrackPitch + InstrumentPitch (if any).
				ret

_atSound_getFrequency_manual
				;Manual Frequency. We read it, no need to read Pitch and Arpeggio.
				;However, we add TrackPitch to the read Frequency, and that's all.
				ld a,(hl)
				inc hl
				exx
				add a,e						;Add TrackPitch LSB.
				ld l,a
				exx
				ld a,(hl)
				inc hl
				exx
				adc a,d						;Add TrackPitch HSB.
				ld h,a
				ret
				


;*** Read and decode track data ************************************************

				; Read Track.
				; Input:
				;	HL=Track Pointer.
				
				; Output:
				;	HL = Updated Track Pointer.
				;	Carry = 1 => Wait A lines.
				;		then A = Wait (0(=256)-127)
				;	Carry = 0 => Line not empty.
				;	 D = Parameters + Volume.
				;	 E = Note
				;	 B = Instrument. 0=RST
				;	IX = PitchAdd. Only used if Pitch? = 1.
_atReadTrack
				ld a,(hl)
				inc hl
				srl a			;Full Optimisation ? If yes = Note only, no Pitch, no Volume, Same Instrument.
				jr c,_atReadTrack_FullOptimisation
					sub 32			;0-31 = Wait.
					jr c,_atReadTrack_Wait
					jr nz,_atReadTrack_NoEscapeCode
						ld a,(hl)
						inc hl
						inc a
_atReadTrack_NoEscapeCode
					dec a		;0 (32-32) = Escape Code for more Notes (parameters will be read)
					ld e,a		;Save Note.

					;Read Parameters
_atReadTrack_ReadParameters
					ld a,(hl)
					ld d,a			;Save Parameters.
					inc hl
					rla			;Pitch ?
					jr nc,_atReadTrack_Pitch_End
						ld b,(hl)	;Get PitchAdd
						ld ixl,b
						inc hl
						ld b,(hl)
						ld ixh,b
						inc hl
_atReadTrack_Pitch_End
					rla			;Skip IsNote? flag.
					rla			;New Instrument ?
					ret nc
					ld b,(hl)
					inc hl
					or a			;Remove Carry, as the player interpret it as a Wait command.
					ret

_atReadTrack_Wait
					add a,32
					ret
_atReadTrack_FullOptimisation
				;Note only, no Pitch, no Volume, Same Instrument.
				ld d,%01000000			;[7] Note only.
				sub 1				;[7]
				ld e,a				;[4]
				ret nc				;[5/11]
				ld e,(hl)			;[7] Escape Code found (0). Read Note.
				inc hl				;[6]
				or a				;[4]
				ret				;[10]


;*** note/Periods lookup table *************************************************

_atLUT_notePeriods
				if atCNF_ZXPT
;					dw 4095,4095,4095,4095,4095,4095,4095,4095,4095,4030,3804,3591
					dw 3804,3591
					dw 3389,3199,3019,2850,2690,2539,2397,2262,2135,2015,1902,1795
					dw 1695,1599,1510,1425,1345,1270,1198,1131,1068,1008,951,898
					dw 847,800,755,712,673,635,599,566,534,504,476,449
					dw 424,400,377,356,336,317,300,283,267,252,238,224
					dw 212,200,189,178,168,159,150,141,133,126,119,112
					dw 106,100,94,89,84,79,75,71,67,63,59,56
					dw 53,50,47,45,42,40,37,35,33,31,30,28
					dw 26,25,24,22,21,20,19,18,17,16,15,14
					dw 13,12,12,11,11,10,9,9,8,8,7,7
					dw 7,6,6,6,5,5,5,4,4,4,4,4
					dw 3,3,3,3,3,2,2,2,2,2,2,2
					dw 2,2,2,2,2,2,2,2,2,2
				else
					dw 4095,4095,4095,4095,4095,4095,4095,4095,4095,3977,3754,3543
					dw 3344,3157,2980,2812,2655,2506,2365,2232,2107,1989,1877,1772
					dw 1672,1578,1490,1406,1327,1253,1182,1116,1053,994,939,886
					dw 836,789,745,703,664,626,591,558,527,497,469,443
					dw 418,395,372,352,332,313,296,279,263,249,235,221
					dw 209,197,186,176,166,157,148,140,132,124,117,111
					dw 105,99,93,88,83,78,74,70,66,62,59,55
					dw 52,49,47,44,41,39,37,35,33,31,29,28
					dw 26,25,23,22,21,20,18,17,16,16,15,14
					dw 13,12,12,11,10,10,9,9,8,8,7,7
					dw 7,6,6,5,5,5,5,4,4,4,4,3
					dw 3,3,3,3,3,2,2,2,2,2,2,2
				endif

;*** Player controls ***********************************************************

				; Initialize player
				;  Input:
				;	DE = song data address
atInit:
				ld hl,9				;Skip Header, SampleChannel, YM Clock (DB*3), and Replay Frequency.
				add hl,de
		
				ld de,_atVAR_SongSpeed + 1
				ldi				;Copy Speed.
				ld c,(hl)			;Get Instruments chunk size.
				inc hl
				ld b,(hl)
				inc hl
				ld (_atVAR_Track1InstrumentLUT + 1),hl
				ld (_atVAR_Track2InstrumentLUT + 1),hl
				ld (_atVAR_Track3InstrumentLUT + 1),hl
	
				add hl,bc			;Skip Instruments to go to the Linker address.
				;Get the pre-Linker information of the first pattern.
				ld de,_atVAR_PatternHeight + 1
				ldi
				ld de,_atVAR_TranspCh1 + 1
				ldi
				ld de,_atVAR_TranspCh2 + 1
				ldi
				ld de,_atVAR_TranspCh3 + 1
				ldi
				ld de,_atVAR_SpecialTrackAddr + 1
				ldi
				ldi
				ld (_atVAR_Linker + 1),hl	;Get the Linker address.
	
				ld a,1
				ld (_atVAR_SongSpeedCtr + 1),a
				ld (_atVAR_patternHeightCtr + 1),a
	
				ld a,#ff
				ld (_atVAR_Reg13),a
		
				;Set the Instruments pointers to Instrument 0 data (Header has to be skipped).
				ld hl,(_atVAR_Track1InstrumentLUT + 1)
				ld e,(hl)
				inc hl
				ld d,(hl)
				ex de,hl
				inc hl				;Skip Instrument 0 Header.
				inc hl
				ld (_atVAR_Track1InstrumentPtr + 1),hl
				ld (_atVAR_Track2InstrumentPtr + 1),hl
				ld (_atVAR_Track3InstrumentPtr + 1),hl
				ret



				;Stop the music, cut the channels.
atStop:
				ld hl,_atVAR_Reg8	; Clear R8,R9 and R10 to zero
				ld bc,#0300
				ld (hl),c
				inc hl
				djnz $-2
				ld a,%00111111		; Disable Tone and Noise on all channels
				jp _atAY3Update


;*** Optionnal Sound effect API ************************************************

				if atCNF_SFX
	
					;Initialize the Sound Effects.
					; DE = SFX Music.
atSfxInit:
					;Find the Instrument Table.
					ld hl,12
					add hl,de
					ld (_atSfxPlay_InstrumentTable + 1),hl
	
					;Clear the three channels of any sound effect.
atSfxStopAll:
					ld hl,0
					ld (_atVAR_SfxTrack1_instrument + 1),hl
					ld (_atVAR_SfxTrack2_instrument + 1),hl
					ld (_atVAR_SfxTrack3_instrument + 1),hl
					ret


_atDEF_SfxOffset_pitch			equ 0
_atDEF_SfxOffset_volume			equ _atVAR_SfxTrack1_volume		- _atVAR_SfxTrack1_pitch
_atDEF_SfxOffset_note			equ _atVAR_SfxTrack1_note		- _atVAR_SfxTrack1_pitch
_atDEF_SfxOffset_instrument		equ _atVAR_SfxTrack1_instrument		- _atVAR_SfxTrack1_pitch
_atDEF_SfxOffset_speed			equ _atVAR_SfxTrack1_instrumentSpeed	- _atVAR_SfxTrack1_pitch
_atDEF_SfxOffset_speedCtr		equ _atVAR_SfxTrack1_instrumentSpeedCtr	- _atVAR_SfxTrack1_pitch


					;Plays a Sound Effects along with the music.
					; Input
					;	A = No Channel (0,1,2)
					;	L = SFX Number (>0)
					;	H = Volume (0...F)
					;	E = Note (0...143)
					;	D = Speed (0 = As original, 1...255 = new Speed (1 is fastest))
					;	BC = Inverted Pitch (-#FFFF -> FFFF). 0 is no pitch. The higher the pitch, the lower the sound.
atSfxPlay:
					ld ix,_atVAR_SfxTrack1_pitch
					dec a
					jp m,_atSfxPlay_Selected
						ld ix,_atVAR_SfxTrack2_pitch
						jr z,_atSfxPlay_Selected
							ld ix,_atVAR_SfxTrack3_pitch
	
_atSfxPlay_Selected
					ld (ix + _atDEF_SfxOffset_pitch + 1),c	;Set Pitch
					ld (ix + _atDEF_SfxOffset_pitch + 2),b
					ld a,e					;Set Note
					ld (ix + _atDEF_SfxOffset_note),a
					ld a,15					;Set Volume
					sub h
					ld (ix + _atDEF_SfxOffset_volume),a
					ld h,0					;Set Instrument Address
					add hl,hl
_atSfxPlay_InstrumentTable		ld bc,0
					add hl,bc
					ld a,(hl)
					inc hl
					ld h,(hl)
					ld l,a
					ld a,d					;Read Speed or use the user's one ?
					or a
					jr nz,_atSfxPlay_UserSpeed
						ld a,(hl)			;Get Speed
_atSfxPlay_UserSpeed
					ld (ix + _atDEF_SfxOffset_speed + 1),a
					ld (ix + _atDEF_SfxOffset_speedCtr + 1),a
					inc hl					;Skip Retrig
					inc hl
					ld (ix + _atDEF_SfxOffset_instrument + 1),l
					ld (ix + _atDEF_SfxOffset_instrument + 2),h
					ret

					;Stops a sound effect on the selected channel
					;A = No Channel (0,1,2)
atSfxStop:
					ld hl,_atVAR_SfxTrack1_instrument + 1
					dec a
					jp m,_atSfxStop_ChannelFound
						ld hl,_atVAR_SfxTrack2_instrument + 1
						jr z,_atSfxStop_ChannelFound + 1
							ld hl,_atVAR_SfxTrack3_instrument + 1
_atSfxStop_ChannelFound
					xor a
					ld (hl),a
					inc hl
					ld (hl),a
					ret

				endif

;*** Optionnal Fade API ********************************************************

			if atCNF_FADE
atFade:
				ld (_azVAR_FadeChA),a
				ld (_azVAR_FadeChB),a
				ld (_azVAR_FadeChC),a
				ret
			endif

