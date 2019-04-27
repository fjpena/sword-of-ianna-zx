The Sword of Ianna (ZX Spectrum)
................................

This is the full source code, including artwork, for ZX Spectrum 48K cartridge
version of our game, The Sword of Ianna.

Additional credits for the 48k version:
.......................................

- Conversion: Spirax
- 48K sound routine (anteater): Utz
- MLD code: Mad3001 / DanDare

Compiling
.........

The makefile for this version has been created for Windows.

You will need some tools to build:

- The pasmo assembler (http://pasmo.speccy.org/)
- The apack compressor. I use the version from http://www.smspower.org/maxim/uploads/SMSSoftware/aplib12.zip?sid=23bcb2a72f8a461be5cad0f46f7c3681,
  renamed to "apack" and run via Wine.
- The fill16k utility, from the tools/ directory.
- zx7 (http://www.worldofspectrum.org/infoseekid.cgi?id=0027996)
- fcut.exe
- GNU make for Windows
- sjasmplus (https://github.com/sjasmplus/sjasmplus)

"make" cleans up everything and generated both the MLD and ROM files.

If you only want the MLD file: "make mld". Similarly, if you only want the ROM: "make rom".

License
.......

Please refer to the LICENSE file included in this repository.
