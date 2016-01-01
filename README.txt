

                    SHA-3 in C and x86 assembly

[ intro

If you're searching for a highly optimized implementation of SHA-3, the 
source code included here is not suitable since it has been written with 
instructions which cannot be executed in parallel on x86 CPU.

The design of how blocks are processed also slows down computation so I 
would advise you look at an alternative library.

What this code does do is reduce the amount of space required but of 
course, it could be improved further. Since SHA-3 will be around for
many years to come, I will definitely work on improving the code to
reduce *size*

The code is public domain, feel free to do with as you wish. 


[ assembling 32-bit code

  * JWASM/MASM
    jwasm -coff -Cp -c src\x86\sha3.asm
    ml /coff /Cp /c src\x86\sha3.asm
  
  * YASM/NASM
    yasm -fwin32 -osha3x.obj src\x86\sha3x.asm
    nasm -fwin32 -osha3x.obj src\x86\sha3x.asm
  
  
[ assembling 64-bit code

  * JWASM/MASM
    jwasm -c src\x64\sha3.asm
    ml64 /c src\x64\sha3.asm
  
  * YASM/NASM (todo)
    
    
[ updates

Jan 2016
  * Fixed errors in assembly code
  * converted syntax to YASM/NASM
  
May 2015
  * simplified buffering/padding in SHA3_Update and SHA3_Final
  * corrected errors in SHA3_Transform and SHA3_Final pointed out by mpancorbo

April 2015
  * first release
  
@Odzhan
May 2015