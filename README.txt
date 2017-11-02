The Sword of Ianna (ZX Spectrum)
................................

This is the full source code, including artwork, for ZX Spectrum version of our
game, The Sword of Ianna.

Versions
........

There are several versions, that differ on the I/O driver:

* +3DOS: ianna-3dos.dsk (720KB disk version), ianna-sidea.dsk/ianna-sideb.sdk
  (180 KB version)
* ESXDOS: sword.hdf and esxdos/ directory
* Cartridge (Dandanator): ianna-cart.rom
* Cartridge (Kartusho v4, still unfinished): ianna-if2.rom

Compiling
.........

The makefile has been created for Linux. It will probably work on Mac OS X
without many changes. There is an outdated makefile.win file included, too.
Feel free to send a PR to fix that :).

You can just run "make ianna-3dos.dsk" to get the +3DOS version. You will need
some tools to build:

- The pasmo assembler (http://pasmo.speccy.org/)
- The mkp3fs, specform and tapget utilities
  (http://www.seasip.info/ZX/taptools-1.0.8.tar.gz). Make sure libdsk
  (http://www.seasip.info/Unix/LibDsk/) is installed before you try compiling
  the utilities.
- zmakebas (http://rus.members.beeb.net/zmakebas.html)
- The apack compressor. I use the version from http://www.smspower.org/maxim/uploads/SMSSoftware/aplib12.zip?sid=23bcb2a72f8a461be5cad0f46f7c3681,
  renamed to "apack" and run via Wine.
- The fill16k utility, from the tools/ directory.
- hdfmonkey for the ESXDOS virtual disk file (https://github.com/gasman/hdfmonkey)
- dskgen for an unfinished +3 sector-based loader (https://github.com/AugustoRuiz/dskgen)

If you want to make modifications, you will realize there are quite a few
hardcoded values in each io-* file, as well as inside some other asm files.
It is a bit cumbersome, I know. Feel free to contact me if you need help.

License
.......

Please refer to the LICENSE file included in this repository.
