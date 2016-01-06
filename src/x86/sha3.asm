

; SHA-3 in x86/MMX assembly for MASM/JWASM
; Odzhan
;
; 569 bytes
;
.686
.mmx
.model flat, C

option prologue:none
option epilogue:none
option casemap:none

include sha3.inc

  public SHA3_Init
  public SHA3_Update
  public SHA3_Final
  
.code

; ***********************************************
;
; SHA3_Init (&ctx, int);
;
; ***********************************************
SHA3_Init proc
    pushad
    mov    edi, [esp+32+4]    ; context
    mov    edx, [esp+32+8]    ; type
    
    ; memset (ctx, 0, sizeof SHA3_CTX);
    mov    ebx, edi
    mov    ecx, sizeof SHA3_CTX
    xor    eax, eax
    rep    stosb

    mov    al, SHA3_224_CBLOCK
    mov    cl, SHA3_224_DIGEST_LENGTH
    dec    edx
    js     exit_init
    
    mov    al, SHA3_256_CBLOCK
    mov    cl, SHA3_256_DIGEST_LENGTH
    jz     exit_init
    
    mov    al, SHA3_384_CBLOCK
    mov    cl, SHA3_384_DIGEST_LENGTH
    dec    edx
    jz     exit_init
    
    mov    al, SHA3_512_CBLOCK
    mov    cl, SHA3_512_DIGEST_LENGTH
exit_init:
    mov    [ebx+SHA3_CTX.buflen ], eax
    mov    [ebx+SHA3_CTX.outlen ], ecx
    mov    byte ptr[ebx+SHA3_CTX.rounds ], SHA3_ROUNDS
    popad
    ret
SHA3_Init endp

; ***********************************************
;
; SHA3_Update (SHA3_CTX*, void*, uint32_t);
;
; ***********************************************
SHA3_Update proc
    pushad

    lea    esi, [esp+32+4]
    lodsd
    ; ebx = ctx
    xchg   ebx, eax
    lodsd
    ; ecx = input
    xchg   ecx, eax
    lodsd
    ; ecx = len
    xchg   ecx, eax
    ; esi = input
    xchg   esi, eax
    jecxz  upd_l02
    
    lea    edi, [ebx+SHA3_CTX.buffer.v8]
    mov    edx, [ebx+SHA3_CTX.index ]
upd_l00:
    ; absorb byte
    lodsb
    mov    byte ptr[edi+edx], al
    inc    edx
    ; buffer full?
    cmp    edx, [ebx+SHA3_CTX.buflen]
    jne    upd_l01
    ; compress
    call   SHA3_Transform
    cdq
upd_l01:
    loop   upd_l00
    mov    [ebx+SHA3_CTX.index], edx
upd_l02:
    popad
    ret
SHA3_Update endp

; ***********************************************
;
; SHA3_Final (void*, SHA3_CTX*);
;
; ***********************************************
SHA3_Final proc
    pushad

    mov    ebx, [esp+32+8] ; ctx
    mov    edi, [esp+32+4] ; dgst
    
    mov    eax, [ebx+SHA3_CTX.buflen]
    mov    ecx, [ebx+SHA3_CTX.index ]
    lea    esi, [ebx+SHA3_CTX.buffer.v8]
    ; ctx->buffer.v8[ctx->index++] = 6;
    mov    byte ptr[esi+ecx], 6
    inc    ecx
    ; while (ctx->index < ctx->buflen) {
    ;   ctx->buffer.v8[ctx->index++] = 0;
    ; }
zero_buffer:
    cmp    ecx, eax
    jae    exit_zero
    
    mov    byte ptr[esi+ecx], 0
    inc    ecx
    jmp    zero_buffer
exit_zero:
    ; ctx->buffer.v8[ctx->buflen-1] |= 0x80;
    or    byte ptr[esi+eax-1], 80h
    ; SHA3_Transform (ctx);
    call   SHA3_Transform
    ; memcpy (dgst, ctx->state.v8, ctx->dgstlen);
    mov    ecx, [ebx+SHA3_CTX.outlen ]
    lea    esi, [ebx+SHA3_CTX.state.v8]
    rep    movsb
    popad
    ret
SHA3_Final endp

r    equ <ebx>
i    equ <ecx>
lfsr equ <edx>
j    equ <ebp>
t    equ <mm0>
_st  equ <esi>
_bc  equ <edi>

SHA3_WS struct
  bc   qword 5 dup (?)
  rnds dword ?
SHA3_WS ends

; rotate mm0 left by bits in eax
; uses mm2, mm3 and mm4
rotl64 proc
    movq   mm2, mm0
    movd   mm3, eax    ; move count into mm2
    sub    eax, 64     ; calculate how much to rotate right
    neg    eax         ; 64 - eax
    movd   mm4, eax
    psllq  mm0, mm3    ; shift left by n
    psrlq  mm2, mm4    ; shift right by 64-n
    por    mm0, mm2    ; mm0 has the result
    ret
rotl64 endp

; Primitive polynomial over GF(2): x^8+x^6+x^5+x^4+1
; expects edx to have lfsr input
rc proc
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
rc endp

; ***********************************************
;
; SHA3_Transform (SHA3_CTX*);
;
; ***********************************************
SHA3_Transform:
    pushad
    
    ; set up workspace
    sub    esp, sizeof SHA3_WS
    
    mov    eax, [ebx+SHA3_CTX.rounds]
    mov    [esp+SHA3_WS.rnds], eax
    
    lea    esi, [ebx+SHA3_CTX.buffer]
    lea    edi, [ebx+SHA3_CTX.state ]
    mov    ecx, [ebx+SHA3_CTX.buflen]
s3_l01:
    mov    al, [esi]
    xor    [edi], al
    cmpsb
    loop   s3_l01
    
    lea    _st, [ebx+SHA3_CTX.state]
    lea    _bc, [esp+SHA3_WS.bc]
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
    movzx  eax, byte ptr[keccakf_mod5 + i + 1]
    movq   t, [_bc+8*eax]
    mov    eax, 1
    call   rotl64
    ; bc[(i + 4) % 5]
    mov    al, byte ptr[keccakf_mod5 + i + 4]
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
    movzx  j, byte ptr[keccakf_piln + i]
    ; bc[0] = st[j];
    movq   mm5, [_st+8*j]
    movq   [_bc], mm5
    ; st[j] = ROTL64(t, keccakf_rotc[i]);
    movzx  eax, byte ptr[keccakf_rotc + i]
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
    movzx  eax, byte ptr[keccakf_mod5 + i + 1]
    movq   t, [_bc+8*eax]
    mov    al, byte ptr[keccakf_mod5 + i + 2]
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
    cmp     r, [esp+SHA3_WS.rnds]
    jnz     s3_l02
    
    add    esp, sizeof SHA3_WS
    popad
    ret

keccakf_rotc label dword
  db 1,  3,  6,  10, 15, 21, 28, 36, 45, 55, 2,  14
  db 27, 41, 56, 8,  25, 43, 62, 18, 39, 61, 20, 44

keccakf_piln label dword
  db 10, 7,  11, 17, 18, 3, 5,  16, 8,  21, 24, 4 
  db 15, 23, 19, 13, 12, 2, 20, 14, 22, 9,  6,  1
  
keccakf_mod5 label dword
  db 0, 1, 2, 3, 4, 0, 1, 2, 3, 4

  end