;
;  Copyright © 2015, 2016 Odzhan, Peter Ferrie. All Rights Reserved.
;
;  Redistribution and use in source and binary forms, with or without
;  modification, are permitted provided that the following conditions are
;  met:
;
;  1. Redistributions of source code must retain the above copyright
;  notice, this list of conditions and the following disclaimer.
;
;  2. Redistributions in binary form must reproduce the above copyright
;  notice, this list of conditions and the following disclaimer in the
;  documentation and/or other materials provided with the distribution.
;
;  3. The name of the author may not be used to endorse or promote products
;  derived from this software without specific prior written permission.
;
;  THIS SOFTWARE IS PROVIDED BY AUTHORS "AS IS" AND ANY EXPRESS OR
;  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
;  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
;  DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
;  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
;  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
;  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
;  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
;  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
;  ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
;  POSSIBILITY OF SUCH DAMAGE.

; -----------------------------------------------
; SHA-3 in x86 assembly
;
; Written by Odzhan and Peter Ferrie
;
; Derived/influenced from code by Markku-Juhani O. Saarinen
;
; size: 486 bytes
;
; global calls use cdecl convention
;
; -----------------------------------------------
  bits 32
  
  %include 'sha3x.inc'

  %ifndef BIN
    global _SHA3_Initx
    global _SHA3_Updatex
    global _SHA3_Finalx
  %endif
  
; ***********************************************
;
; SHA3_Init (&ctx, int);
;
; ***********************************************
_SHA3_Initx:
    pushad
    mov    edi, [esp+32+4]    ; context
    mov    eax, [esp+32+8]    ; outlen
    stosd                     ; ctx->outlen=outlen
    add    eax, eax           ; *= 2
    push   (SHA3_STATE_LEN*8)/2
    pop    ecx
    add    ecx, ecx           ; ecx=200
    neg    eax                ; negate
    add    eax, ecx           ; add 200
    stosd                     ; buflen = 200 - (2 * outlen)
    xor    eax, eax
    stosd                     ; index=0
    rep    stosb              ; zero the state buffer
    popad
    ret

; ***********************************************
;
; SHA3_Update (SHA3_CTX*, void*, uint32_t);
;
; ***********************************************
_SHA3_Updatex:
    pushad
    lea    esi, [esp+32+4]
    lodsd
    push   eax               ; save ctx
    lodsd
    xchg   ebx, eax          ; ebx = input
    lodsd
    xchg   ecx, eax          ; ecx = len
    pop    esi               ; esi = ctx
    jecxz  upd_l2
    
    lodsd                    ; skip ctx->outlen
    lodsd                    ;
    xchg   eax, ebp          ; ebp = ctx->buflen
    push   esi               ; save ptr to ctx->index
    lodsd                    ; eax = ctx->index
upd_l0:
    cmp    eax, ebp          ; buffer full?
    jne    upd_l1
    call   SHA3_Transform    ; compress, expects ctx->state in esi
    xor    eax, eax          ; index = 0
upd_l1:
    mov    dl, [ebx]         ; absorb byte
    inc    ebx    
    xor    byte[esi+eax], dl
    inc    eax               ; increase index
    loop   upd_l0
    pop    edi
    stosd
upd_l2:
    popad
    ret
  
; ***********************************************
;
; SHA3_Final (void*, SHA3_CTX*);
;
; ***********************************************
_SHA3_Finalx:
    pushad
    mov    esi, [esp+32+8]      ; esi=ctx
    mov    ebx, esi
    lodsd
    xchg   ecx, eax             ; edx=ctx->outlen
    lodsd
    xchg   edx, eax             ; ecx=ctx->buflen
    lodsd                       ; eax=ctx->index
    xor    byte[esi+eax], 6     ; ctx->state.v8[ctx->index] ^= 6;
    xor    byte[esi+edx-1], 80h ; ctx->state.v8[ctx->buflen-1] |= 0x80;
    call   SHA3_Transform       ; SHA3_Transform (ctx->state);
    mov    edi, [esp+32+4]      ; edi=out
    rep    movsb                ; memcpy (out, ctx->state.v8, ctx->outlen);
    popad
    ret

%define r    ebp
%define i    ecx
%define lfsr edx
%define j    ebx
%define t    mm0
%define _st  esi
%define _bc  edi

struc SHA3_WS
  bc   resq 5
endstruc

; rotate mm0 left by bits in eax
; uses mm2, mm3 and mm4
rotl64:
    movq   mm2, mm0
    movd   mm3, eax    ; move count into mm2
    sub    eax, 64     ; calculate how much to rotate right
    neg    eax         ; 64 - eax
    movd   mm4, eax
    psllq  mm0, mm3    ; shift left by n
    psrlq  mm2, mm4    ; shift right by 64-n
    por    mm0, mm2    ; mm0 has the result
    ret

rc:
    pxor   mm0, mm0        ; c=0
    pxor   mm1, mm1        ; 
    push   1
    pop    eax             ; i=1
    movd   mm1, eax
rc_l00:
    test   dl, 1           ; (t & 1)
    jz     rc_l01
    ; ecx = (i - 1)
    lea    ecx, [eax-1]
    movd   mm2, ecx
    movq   mm3, mm1
    ; 1ULL << (i - 1)
    psllq  mm3, mm2
    pxor   mm0, mm3        ; c ^= 1ULL << (i - 1)
rc_l01:
    add    dl, dl          ; t += t
    jnc    rc_l02
    xor    dl, 71h
rc_l02:
    add    al, al          ; i += i
    jns    rc_l00
    ret
  
; ***********************************************
;
; SHA3_Transform (SHA3_CTX*);
;
; expects ctx->state in esi
; ***********************************************
SHA3_Transform:
    pushad
    
    ; set up workspace
    sub    esp, SHA3_WS_size
    mov    _bc, esp
    xor    r, r
    
    push   1
    pop    lfsr
s3_l02:
    ; Theta
    ; for (i = 0; i < 5; i++)     
    ;   bc[i] = st[i + 0 ] ^ 
    ;           st[i + 5 ] ^ 
    ;           st[i + 10] ^ 
    ;           st[i + 15] ^ 
    ;           st[i + 20]; 
    xor    i, i
s3_l03:
    movq    t, [_st+8*i+20*8]
    pxor    t, [_st+8*i+15*8]
    pxor    t, [_st+8*i+10*8]
    pxor    t, [_st+8*i+ 5*8]
    pxor    t, [_st+8*i     ]
    movq    [_bc+8*i        ], t
    inc     i
    cmp     i, 5
    jnz     s3_l03
      
    ; for (i = 0; i < 5; i++) {
    ;   t = bc[(i + 4) % 5] ^ ROTL64(bc[(i+1)%5], 1);
    ;   for (j = 0; j < 25; j += 5)
    ;     st[j + i] ^= t;
    ; }
    ; ************************************
    ; for (i = 0; i < 5; i++)
    xor    i, i
s3_l04:
    ; t = ROTL64(bc[(i + 1) % 5], 1)
    movzx  eax, byte [keccakf_mod5 + i + 1]
    movq   t, [_bc+8*eax]
    push   1
    pop    eax
    call   rotl64
    ; bc[(i + 4) % 5]
    mov    al, byte [keccakf_mod5 + i + 4]
    pxor   t, [_bc+8*eax]
    ; for (j = 0; j < 25; j += 5)
    xor    j, j
s3_l05:
    ; st[j + i] ^= t;
    lea    eax, [j+i]
    movq   mm1, [_st+8*eax]
    pxor   mm1, t
    movq   [_st+8*eax], mm1
    add    j, 5
    cmp    j, 25
    jnz    s3_l05
    
    inc    i
    cmp    i, 5
    jnz    s3_l04
            
    ; // Rho Pi
    ; t = st[1];
    ; for (i = 0; i < 24; i++) {
    ;   j = keccakf_piln[i];
    ;   bc[0] = st[j];
    ;   st[j] = ROTL64(t, keccakf_rotc[i]);
    ;   t = bc[0];
    ; }
    ; *************************************
    ; t = st[1]
    movq   t, [_st+8]
    xor    i, i
    ; for (i = 0; i < 24; i++)
s3_l06:
    ; j = keccakf_piln[i];
    movzx  j, byte [keccakf_piln + i]
    ; bc[0] = st[j];
    movq   mm5, [_st+8*j]
    movq   [_bc], mm5
    ; st[j] = ROTL64(t, keccakf_rotc[i]);
    movzx  eax, byte [keccakf_rotc + i]
    call   rotl64
    movq   [_st+8*j], t
    movq   t, mm5
    inc    i
    cmp    i, 24
    jnz    s3_l06
      
    ; // Chi
    ; for (j = 0; j < 25; j += 5) {
    ;   for (i = 0; i < 5; i++)
    ;     bc[i] = st[j + i];
    ;   for (i = 0; i < 5; i++)
    ;     st[j + i] ^= (~bc[(i+1)%5]) & bc[(i+2)%5];
    ; }
    ; *********************************
    ; for (j=0; j<25; j+=5)
    xor    j, j
s3_l07:
    ; for (i=0; i<5; i++)
    xor    i, i
s3_l08:
    ; bc[i] = st[j + i];
    lea    eax, [j+i]
    movq   t, [_st+8*eax]
    movq   [_bc+8*i], t
    inc    i
    cmp    i, 5
    jnz    s3_l08
        
    ; for (i=0; i<5; i++)
    xor    i, i
s3_l09:
    ; st[j + i] ^= (~bc[(i+1)%5]) & bc[(i+2)%5];
    movzx  eax, byte [keccakf_mod5 + i + 1]
    movq   t, [_bc+8*eax]
    mov    al, byte [keccakf_mod5 + i + 2]
    pandn  t, [_bc+8*eax]
    lea    eax, [j+i]
    pxor   t, [_st+8*eax]
    movq   [_st+8*eax], t
    inc    i
    cmp    i, 5
    jnz    s3_l09
    
    add    j, 5
    cmp    j, 25
    jnz    s3_l07
           
    ; // Iota
    ; st[0] ^= keccakf_rndc[round];
    movq    mm4, [_st]
    call    rc
    pxor    mm4, t
    movq    [_st], mm4
    
    inc     r
    cmp     r, SHA3_ROUNDS
    jnz     s3_l02
    
    add    esp, SHA3_WS_size
    popad
    ret
    
keccakf_rotc:
  db 1,  3,  6,  10, 15, 21, 28, 36, 45, 55, 2,  14
  db 27, 41, 56, 8,  25, 43, 62, 18, 39, 61, 20, 44

keccakf_piln:
  db 10, 7,  11, 17, 18, 3, 5,  16, 8,  21, 24, 4 
  db 15, 23, 19, 13, 12, 2, 20, 14, 22, 9,  6,  1
  
keccakf_mod5:
  db 0, 1, 2, 3, 4, 0, 1, 2, 3, 4