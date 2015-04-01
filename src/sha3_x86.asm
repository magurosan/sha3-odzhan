

; SHA-3 in x86/MMX assembly
; Odzhan

.686
.mmx
.model flat, C

r   equ <ebx>
i   equ <ecx>
j   equ <edx>
t   equ <mm0>
_st equ <esi>
_bc equ <edi>

include sha3.inc

.code

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

; ***********************************************
; ***********************************************
  public SHA3_Init
  public _SHA3_Init
_SHA3_Init:
SHA3_Init proc ctx:dword, sha_type:dword
    pushad
    mov    edi, ctx
    mov    edx, sha_type
    mov    ebx, edi
    mov    ecx, sizeof SHA3_CTX
    xor    eax, eax
    rep    stosb

    mov    al, SHA3_224_BLK_LEN
    mov    cl, SHA3_224_HASH_LEN
    dec    edx
    js     exit_init
    
    mov    al, SHA3_256_BLK_LEN
    mov    cl, SHA3_256_HASH_LEN
    jz     exit_init
    
    mov    al, SHA3_384_BLK_LEN
    mov    cl, SHA3_384_HASH_LEN
    dec    edx
    jz     exit_init
    
    mov    al, SHA3_512_BLK_LEN
    mov    cl, SHA3_512_HASH_LEN
exit_init:
    mov    [ebx][SHA3_CTX.blklen ], eax
    mov    [ebx][SHA3_CTX.dgstlen], ecx
    mov    [ebx][SHA3_CTX.rounds ], SHA3_ROUNDS
    popad
    ret
SHA3_Init endp

; ***********************************************
; ***********************************************
  public SHA3_Update
  public _SHA3_Update
_SHA3_Update:
SHA3_Update proc ctx:dword, data:ptr byte, len:dword
    pushad
    mov    ebx, ctx
    mov    edx, [ebx][SHA3_CTX.index]
    mov    esi, data
    mov    eax, len
    .while 1
      ; r = MIN(len, ctx->blklen - idx);
      mov    ecx, [ebx][SHA3_CTX.blklen]
      sub    ecx, edx
      cmp    ecx, eax
      cmovae ecx, eax
      ; memcpy ((void*)&ctx->blk[idx], p, r);
      lea    edi, [ebx][SHA3_CTX.blk][edx]
      ; idx += r
      add    edx, ecx
      ; len -= r
      sub    eax, ecx
      rep    movsb
      ; if ((idx + r) < ctx->blklen) break;
      .break .if edx < [ebx][SHA3_CTX.blklen]
      push   ebx
      call   SHA3_Transform
      pop    edx
      xor    edx, edx
    .endw
    mov   [ebx][SHA3_CTX.index], edx
    popad
    ret
SHA3_Update endp

; ***********************************************
; ***********************************************
  public SHA3_Final
  public _SHA3_Final
_SHA3_Final:
SHA3_Final proc dgst:ptr byte, ctx:dword
    pushad

    mov    esi, ctx
    mov    edi, dgst
    
    lea    eax, [esi][SHA3_CTX.blk]
    mov    ebx, [esi][SHA3_CTX.index]
    mov    ecx, [esi][SHA3_CTX.blklen]
    mov    byte ptr[eax+ebx], 6
    or     byte ptr[eax+ecx-1], 80h
    
    push   esi
    call   SHA3_Transform
    pop    eax
    
    mov    ecx, [esi][SHA3_CTX.dgstlen]
    rep    movsb
    popad
    ret
SHA3_Final endp

; ***********************************************
; ***********************************************
  public SHA3_Transform
  public _SHA3_Transform
_SHA3_Transform:
SHA3_Transform proc ctx:dword
    local bc[5]:qword
    local rnds :dword
    
    pushad
    
    mov    ebx, ctx
    mov    eax, [ebx][SHA3_CTX.rounds]
    mov    rnds, eax
    lea    edi, [ebx][SHA3_CTX.state]
    lea    esi, [ebx][SHA3_CTX.blk]
    mov    ecx, [ebx][SHA3_CTX.blklen]
    shr    ecx, 3    ; /= 8
    pxor   mm1, mm1
xor_blk:
    movq   mm0, [esi]
    pxor   mm0, [edi]
    movq   [edi], mm0
    movq   [esi], mm1   ; zero buffer
    add    esi, 8
    add    edi, 8
    dec    ecx
    jnz    xor_blk
    
    lea    _st, [ebx][SHA3_CTX.state]
    lea    _bc, bc
    xor    r, r
    
    .repeat
      ; Theta
      ; for (i = 0; i < 5; i++)     
      ;   bc[i] = st[i + 0 ] ^ 
      ;           st[i + 5 ] ^ 
      ;           st[i + 10] ^ 
      ;           st[i + 15] ^ 
      ;           st[i + 20]; 
      xor    i, i
      .repeat
        movq    t, [_st+8*i+20*8]
        pxor    t, [_st+8*i+15*8]
        pxor    t, [_st+8*i+10*8]
        pxor    t, [_st+8*i+5*8]
        pxor    t, [_st+8*i]
        movq    [_bc+8*i], t
        inc     i
        cmp     i, 5
      .until zero?
      
      ; for (i = 0; i < 5; i++) {
      ;   t = bc[(i + 4) % 5] ^ ROTL64(bc[(i+1)%5], 1);
      ;   for (j = 0; j < 25; j += 5)
      ;     st[j + i] ^= t;
      ; }
      ; ************************************
      ; for (i = 0; i < 5; i++)
      xor    i, i
      .repeat
        ; t = ROTL64(bc[(i + 1) % 5], 1)
        movzx  eax, byte ptr keccakf_mod5[i+1]
        movq   t, [_bc+8*eax]
        mov    eax, 1
        call   rotl64
        ; bc[(i + 4) % 5]
        mov    al, byte ptr keccakf_mod5[i+4]
        pxor   t, [_bc+8*eax]
        ; for (j = 0; j < 25; j += 5)
        xor    j, j
        .repeat
          ; st[j + i] ^= t;
          lea    eax, [j+i]
          movq   mm1, [_st+8*eax]
          pxor   mm1, t
          movq   [_st+8*eax], mm1
          add    j, 5
          cmp    j, 25
        .until zero?
        inc    i
        cmp    i, 5
      .until zero?
            
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
      .repeat
        ; j = keccakf_piln[i];
        movzx  j, byte ptr keccakf_piln[i]
        ; bc[0] = st[j];
        movq   mm5, [_st+8*j]
        movq   [_bc], mm5
        ; st[j] = ROTL64(t, keccakf_rotc[i]);
        movzx  eax, byte ptr keccakf_rotc[i]
        call   rotl64
        movq   [_st+8*j], t
        movq   t, mm5
        inc    i
        cmp    i, 24
      .until zero?
      
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
      .repeat
        ; for (i=0; i<5; i++)
        xor    i, i
        .repeat
          ; bc[i] = st[j + i];
          lea    eax, [j+i]
          movq   t, [_st+8*eax]
          movq   [_bc+8*i], t
          inc    i
          cmp    i, 5
        .until zero?
        
        ; for (i=0; i<5; i++)
        xor    i, i
        .repeat
          ; st[j + i] ^= (~bc[(i+1)%5]) & bc[(i+2)%5];
          movzx  eax, byte ptr keccakf_mod5[i+1]
          movq   t, [_bc+8*eax]
          mov    al, byte ptr keccakf_mod5[i+2]
          pandn  t, [_bc+8*eax]
          lea    eax, [j+i]
          pxor   t, [_st+8*eax]
          movq   [_st+8*eax], t
          inc    i
          cmp    i, 5
        .until zero?
        add    j, 5
        cmp    j, 25
      .until zero?
           
      ; // Iota
      ; st[0] ^= keccakf_rndc[round];
      movq    t, [_st]
      pxor    t, keccakf_rndc[8*r]
      movq    [_st], t
    
      inc  r
    .until r == rnds
    popad
    ret
SHA3_Transform endp

keccakf_rotc label dword
  db 1,  3,  6,  10, 15, 21, 28, 36, 45, 55, 2,  14
  db 27, 41, 56, 8,  25, 43, 62, 18, 39, 61, 20, 44

keccakf_piln label dword
  db 10, 7,  11, 17, 18, 3, 5,  16, 8,  21, 24, 4 
  db 15, 23, 19, 13, 12, 2, 20, 14, 22, 9,  6,  1
  
keccakf_mod5 label dword
  db 0, 1, 2, 3, 4, 0, 1, 2, 3, 4

; these are generated using linear feedback shift register
keccakf_rndc label qword
  dq 00000000000000001h, 00000000000008082h, 0800000000000808ah
  dq 08000000080008000h, 0000000000000808bh, 00000000080000001h
  dq 08000000080008081h, 08000000000008009h, 0000000000000008ah
  dq 00000000000000088h, 00000000080008009h, 0000000008000000ah
  dq 0000000008000808bh, 0800000000000008bh, 08000000000008089h
  dq 08000000000008003h, 08000000000008002h, 08000000000000080h 
  dq 0000000000000800ah, 0800000008000000ah, 08000000080008081h
  dq 08000000000008080h, 00000000080000001h, 08000000080008008h
  
  end