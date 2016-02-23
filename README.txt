

Designers         Guido Bertoni, Joan Daemen, Michaël Peeters, and Gilles Van Assche.
Series            (SHA-0), SHA-1, SHA-2, SHA-3
Certification     FIPS PUB 202
Digest sizes      arbitrary
Structure         sponge construction

  Copyright © 2015, 2016 Odzhan. All Rights Reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

  1. Redistributions of source code must retain the above copyright
  notice, this list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.

  3. The name of the author may not be used to endorse or promote products
  derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY AUTHORS "AS IS" AND ANY EXPRESS OR
  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
  ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
  POSSIBILITY OF SUCH DAMAGE.
  
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
    
    
[ history

Feb 2016
  * Fixed bugs
  * Changed the way state is updated
  
Jan 2016
  * Fixed errors in assembly code
  * Now using round constant function instead of 64-bit values
  * converted 32-bit code to YASM/NASM syntax. (64-bit to do)
  
May 2015
  * simplified buffering/padding in SHA3_Update and SHA3_Final
  * corrected errors in SHA3_Transform and SHA3_Final pointed out by mpancorbo

April 2015
  * first release, sha3_transform is based on keccak.c written 
    in 19-Nov-11 by Markku-Juhani O. Saarinen <mjos@iki.fi>
    
  * using similar api to openssl : sha3_init, sha3_update and sha3_final
  