org $fe00


bank1               equ  07FFDh    ;"horizontal" and RAM switch port
bankm               equ  05B5Ch    ;associated system variable
bank2               equ  01FFDh    ;"vertical" switch port
bank678             equ  05B67h    ;associated system variable

select              equ  01601h    ;BASIC routine to open stream
dos_ref_xdpb        equ  0151h     ;
dd_write_sector     equ  0166h     ;see part 27 of this chapter
dd_login            equ  0175h     ;

DOS_EST_1346    equ $13F
DOS_OPEN        equ $106
DOS_READ        equ $112
DOS_CLOSE       equ $109
DOS_REF_XDPB    equ $151
DD_LOGIN        equ $175
DD_READ_SECTOR  equ $163
DD_L_OFF_MOTOR  equ $19c



bootsector:

;
;Bootstrap will load into page 3 at address FE00h. The code will be entered at
;FE10h.
;
;Before it is written to track 0, sector 1, the bootstrap has byte 15
;changed so that it will checksum to 3 mod 256.
;
;Boot will switch the memory so that the 48 BASIC ROM is at the bottom.
;Next up is page 5 - the screen, then page 2, and the top will keep
;page 3, as it would be unwise to switch out the bootstrap. BASIC
;routines can be called with any RAM page switched in at the top, but
;the stack shouldn't be in the TSTACK area.


bootstart:
;
;The bootstrap sector contains the 16 bytes disk specification at the start.
;The following values are for a AMSTRAD PCW range CF2/Spectrum +3 format disk.
;
     db   0                   ;+3 format
     db   0                   ;single sided
     db   40                  ;40 tracks per side
     db   9                   ;9 sectors per track

     db   2                   ;log2(512)-7 = sector size
     db   1                   ;1 reserved track
     db   3                   ;blocks
     db   2                   ;2 directory blocks

     db   02Ah                ;gap length (r/w)
     db   052h                ;page length (format)
     ds   5,0                 ;5 reserved bytes

cksum:         db   -62        ;checksum must = 3 mod 256 for the sector
;
;The bootstrap will be entered here with the 4, 7, 6, 3 RAM pages switched in.
;To print something, we need 48 BASIC in at the bottom, page 5 (the screen and
;system variables) next up. The next page will be 0, and the top will be kept
;as page 3 because it still contains the bootstrap and stack (stack is FE00h on
;entry).
;
     di
     ld   a,(bankm)
     and  0F8h
     or   3                   ;RAM page 3 (as it holds bootstrap)
     res  4,a                 ;left-hand ROMs
     ld   bc,bank1
     ld   (bankm),a
     out  (c),a               ;switch RAM and horizontal ROM
     ld   a,(bank678)
     and  0F8h
     or   4                   ;set bit 2 and reset bit 0 (gives ROM 3)
     ld   bc,bank2
     ld   (bank678),a
     out  (c),a               ;should now have R2,5,2,3

     ; we will now copy the boot code elsewhere, so we can page out RAM 3
     ld de, 32768
     ld hl, start
     ld bc, endroutine-start
     ldir
     jp 32768			; and transfer control!

start:
        ld sp, 23999
        ld b, 7         ; RAM 7, ROM 3 (+3DOS)

        ld A, ($5B5C)
        and $E8
        or b
        ld BC, $7FFD
        ld ($5b5c), a   ; save in the BASIC variable
        out (c), a
        ei

deact_ramdisk:
        ld hl, $0000
        ld de, $0000
        call DOS_EST_1346
        jp nc, 0        ; reset if failed

open_disk:
        ld a, 'A'               ; drive A
        call DOS_REF_XDPB       ; make IX point to XDPB A: (necessary for calling DD routines)
        jp nc, 0                ; reset if failed
        ld c, 0
        push ix
        call DD_LOGIN           ; log in disk in unit 0
        pop ix
        jp nc, 0                ; reset if failed


; Read a single sector for the stage2, and transfer control there
        ld b, 0                 ; RAM 0 in $C000
        ld c, 0                 ; Unit 0
        ld d, 0                ; Track 0 (will be between 0 and 39)
        ld e, 1                 ; Sector 2 (will be between 0 and 8)
        ld hl, 24000            ; read to 24000, for example

        call DD_READ_SECTOR
        call DD_L_OFF_MOTOR     ; stop motor

        jp 24000		; and jump there

	

cliff:
     ds   512-(cliff-bootstart),0  ;fill to end of sector with 0s
endroutine:
