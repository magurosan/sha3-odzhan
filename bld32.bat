@echo off
yasm -fwin32 src\x86\sha3x.asm -o sha3x.obj
yasm -fbin -DBIN src\x86\sha3x.asm -o sha3x.bin
cl /nologo /O2 /DUSE_ASM test.c sha3x.obj setargv.obj
del *.obj