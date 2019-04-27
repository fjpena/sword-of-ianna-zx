	org 0000


start:
	di
	im 1
	xor a
	ld (23400),a	  ; Clear NMI Counter
	ld (23401),a
	; The following code is taken from the Spectrum 128 ROM!
    LD   BC,$692B     ;
L0004:  
	DEC  BC           ; Delay about 0.2s to allow screen switching mechanism to settle.
    LD   A,B          ;
    OR   C            ;
    JR   NZ,L0004     ; [There is no RST $08. No instruction fetch at $0008 hence ZX Interface 1 will not be paged in from this ROM. Credit: Paul Farrow].
    ld sp, 23999
    call set_dandanator_boot_condition ; sets button and boot parameters for dandanator
    call check_init_stored_parameters ; Check if "R" is pressed to initialize user preferences
	call check_joystick_loader ; Loader will be available even in a 48k spectrum
	call detect_128
	and a
	jp z, fail_48k
	ld a,1
	out ($fe), a	  ; Blue border
	ld hl, start_code
	ld bc, 256			; It is actually less, but hey, it doesn't hurt
	ld de, 24000
	ldir
	jp 24000

	org 0x0038 ; Just 1 byte remaining. Dont add anything above this
int_isr:				; INT Address
	ei
	reti

	
	org 0x0066				; NMI Address
nmi_isr: 
	incbin "dandanator/nmiroutine.bin"
	
set_dandanator_boot_condition:
    ld a, 41		  ; 41,1,0 Normal boot on slot 1
	ld d, 1
	ld e, 0
	call SENDSPCMDR
	call SENDCONF
	
	ld a, 42		  ; 42,1,1 Button 1 to reset to slot 1
	ld d, 1
	ld e, 1
	call SENDSPCMDR
	call SENDCONF	
	ret	

check_init_stored_parameters: ; check for "R" key pressed on boot
	ld a, $fb	; A10=0
	in a, ($fe)
	bit 3,a
	ret nz			

	ld a ,2
	out ($fe),a	
koff:
	ld a, $fb	; A10=0
	in a, ($fe)	; Wait until key is released
	bit 3,a
	jr z, koff
	
clear_stored_parameters:	
	xor a
	ld bc, 4095	; create a empty (0x00) block of 4096 bytes
	ld hl, 40000
	push hl
	ld de, 40001
	ld (hl),a
	ldir
	pop hl
	call SAVEPREFS	; zero-out prefs area
	ret

check_joystick_loader: ; check for "L" key pressed on boot
	ld 	a, $bf 	; A14=0
	in 	a, ($fe)
	bit 	1, a
	ret nz
		
joystick_loader:
	ld a, 40	; 40,32,1 special command selects bank 32 and resets
	ld d, 32
	ld e, 1
	call SENDSPCMDR
	call SENDCONF
waitreset: jr waitreset	


start_code: INCBIN "cartload.bin"

; A: nueva página RAM a poner en $C000 - $FFFF
; Asumimos interrupciones deshabilitadas, ojito!!!!!!
setrambank:
		ld bc, $7ffd		; Puerto en el que escribir
   		out	(c),a		;Direccionar
		ret		

; Detect if we have a 128K or a 48K model
;
; RETURN: A=0:48K, 1:128K
detect_128:
	xor a
	call setrambank			; switch to RAM bank 0
	ld hl, $ff30
	ld (hl), 0			; 0 in RAM bank 0
	ld a, 6
	call setrambank			; switch to RAM bank 6
	ld (hl), 1			; 1 in RAM bank 6
	xor a
	call setrambank			; switch to RAM bank 0
	ld a, ($ff30)
	cp 1
	jr z, is_48
is_128:
	ld a, 1
	ret
is_48:
	xor a
	ret

fail_48k:
	xor a
	out ($fe), a
	ld hl, fail_screen
	call depackscr
	halt



depackscr:	ld	de,16384
; aPPack decompressor
; original source by dwedit
; very slightly adapted by utopian
; optimized by Metalbrain

;hl = source
;de = dest

depack:		ld	ixl,128
apbranch1:	ldi
aploop0:	ld	ixh,1		;LWM = 0
aploop:		call 	ap_getbit
		jr 	nc,apbranch1
		call 	ap_getbit2
		jr 	nc,apbranch2
		ld 	bc,16
		call 	ap_getbit2
		jr 	nc,apbranch3
apget4bits:	call 	ap_getbit2
		rl 	c
		jr	nc,apget4bits
		ld	a,b
		jr 	z,apwritebyte
		and	a
		ex 	de,hl 		;write a previous byte (1-15 away from dest)
		sbc 	hl,bc
		ld 	a,(hl)
		add	hl,bc
		ex 	de,hl
apwritebyte:	ld 	(de),a		;write a 0
		inc 	de
		jr	aploop0
apbranch3:	ld 	c,(hl)		;use 7 bit offset, length = 2 or 3
		rr 	c
		ret 	z		;if a zero is encountered here, it is EOF
		inc 	hl
		ld	a,2
		adc	a,b
		push 	hl
		push	bc
		pop	iy
		ld 	h,d
		ld 	l,e
		sbc 	hl,bc
		ld 	c,a
		jr	ap_finishup2
apbranch2:	call 	ap_getgamma	;use a gamma code * 256 for offset, another gamma code for length
		dec 	c
		ld	a,c
		sub	ixh
		jr 	z,ap_r0_gamma		;if gamma code is 2, use old r0 offset,
		dec 	a
		;do I even need this code?
		;bc=bc*256+(hl), lazy 16bit way
		ld 	b,a
		ld 	c,(hl)
		inc 	hl
		push	bc
		pop	iy

		push 	bc
		
		call 	ap_getgamma

		ex 	(sp),hl		;bc = len, hl=offs
		push 	de
		ex 	de,hl

		ld	a,4
		cp	d
		jr 	nc,apskip2
		inc 	bc
		or	a
apskip2:	ld 	hl,127
		sbc 	hl,de
		jr 	c,apskip3
		inc 	bc
		inc 	bc
apskip3:	pop 	hl		;bc = len, de = offs, hl=junk
		push 	hl
		or 	a
ap_finishup:	sbc 	hl,de
		pop 	de		;hl=dest-offs, bc=len, de = dest
ap_finishup2:	ldir
		pop 	hl
		ld	ixh,b
		jr 	aploop

ap_r0_gamma:	call 	ap_getgamma		;and a new gamma code for length
		push 	hl
		push 	de
		ex	de,hl

		push	iy
		pop	de
		jr 	ap_finishup


ap_getbit:	ld	a,ixl
ap_getbit2:	add	a,a
		jr   	nz,ap_endbit
		ld	a,(hl)
		inc	hl
		rla
ap_endbit:	ld	ixl,a
		ret

ap_getgamma:	ld 	bc,1
ap_getgammaloop: call 	ap_getbit
		rl 	c
		rl 	b
		call 	ap_getbit2
		jr 	c,ap_getgammaloop
		ret

fail_screen: INCBIN "48k.pck"

include "dandanator/eeprom_writer_offset.asm"


end_cartboot:

org 8191
	db 0		; so it is exactly 8192 bytes
