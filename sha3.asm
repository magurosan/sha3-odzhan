; mark_description "Intel(R) C++ Compiler XE for applications running on IA-32, Version 15.0.0.108 Build 20140726";
; mark_description "-Fa -O2 -Os -Gr -c -DINTRINSICS";
	.686P
 	.387
	OPTION DOTNAME
	ASSUME	CS:FLAT,DS:FLAT,SS:FLAT
;ident "-defaultlib:libcpmt"
_TEXT	SEGMENT  DWORD PUBLIC FLAT  'CODE'
;	COMDAT @SHA3_Update@12
TXTST0:
; -- Begin  @SHA3_Update@12
;@SHA3_Update@12	ENDS
_TEXT	ENDS
_TEXT	SEGMENT  DWORD PUBLIC FLAT  'CODE'
;	COMDAT @SHA3_Update@12
; mark_begin;
IF @Version GE 800
  .MMX
ELSEIF @Version GE 612
  .MMX
  MMWORD TEXTEQU <QWORD>
ENDIF
IF @Version GE 800
  .XMM
ELSEIF @Version GE 614
  .XMM
  XMMWORD TEXTEQU <OWORD>
ENDIF

	PUBLIC @SHA3_Update@12
@SHA3_Update@12	PROC NEAR 
; parameter 1: ecx
; parameter 2: edx
; parameter 3: 20 + esp
.B1.1:                          ; Preds .B1.0
        push      esi                                           ;109.60
        push      edi                                           ;109.60
        push      ebx                                           ;109.60
        push      ebp                                           ;109.60
        mov       ebp, edx                                      ;109.60
        mov       edi, DWORD PTR [20+esp]                       ;109.6
        mov       ebx, ecx                                      ;109.60
        test      edi, edi                                      ;113.15
        jbe       .B1.8         ; Prob 10%                      ;113.15
                                ; LOE ebx ebp edi
.B1.2:                          ; Preds .B1.1
        xor       esi, esi                                      ;113.8
        mov       edx, DWORD PTR [200+ebx]                      ;115.20
                                ; LOE edx ebx ebp esi edi
.B1.3:                          ; Preds .B1.6 .B1.2
        mov       al, BYTE PTR [esi+ebp]                        ;115.47
        mov       BYTE PTR [216+edx+ebx], al                    ;115.5
        mov       edx, DWORD PTR [200+ebx]                      ;115.20
        inc       edx                                           ;115.20
        mov       DWORD PTR [200+ebx], edx                      ;115.20
        cmp       edx, DWORD PTR [212+ebx]                      ;117.23
        jne       .B1.6         ; Prob 78%                      ;117.23
                                ; LOE edx ebx ebp esi edi
.B1.4:                          ; Preds .B1.3
        mov       ecx, ebx                                      ;118.7
        call      @SHA3_Transform@4                             ;118.7
                                ; LOE ebx ebp esi
.B1.5:                          ; Preds .B1.4
        xor       edx, edx                                      ;119.7
        mov       edi, DWORD PTR [20+esp]                       ;
        mov       DWORD PTR [200+ebx], edx                      ;119.7
                                ; LOE edx ebx ebp esi edi
.B1.6:                          ; Preds .B1.5 .B1.3
        inc       esi                                           ;113.22
        cmp       esi, edi                                      ;113.15
        jb        .B1.3         ; Prob 82%                      ;113.15
                                ; LOE edx ebx ebp esi edi
.B1.8:                          ; Preds .B1.6 .B1.1
        pop       ebp                                           ;122.1
        pop       ebx                                           ;122.1
        pop       edi                                           ;122.1
        pop       esi                                           ;122.1
        ret       4                                             ;122.1
                                ; LOE
; mark_end;
@SHA3_Update@12 ENDP
;@SHA3_Update@12	ENDS
_TEXT	ENDS
_DATA	SEGMENT  DWORD PUBLIC FLAT  'DATA'
_DATA	ENDS
; -- End  @SHA3_Update@12
_TEXT	SEGMENT  DWORD PUBLIC FLAT  'CODE'
;	COMDAT @SHA3_Transform@4
TXTST1:
; -- Begin  @SHA3_Transform@4
;@SHA3_Transform@4	ENDS
_TEXT	ENDS
_TEXT	SEGMENT  DWORD PUBLIC FLAT  'CODE'
;	COMDAT @SHA3_Transform@4
; mark_begin;

	PUBLIC @SHA3_Transform@4
@SHA3_Transform@4	PROC NEAR 
; parameter 1: ecx
.B2.1:                          ; Preds .B2.0
        push      esi                                           ;30.1
        push      edi                                           ;30.1
        push      ebx                                           ;30.1
        push      ebp                                           ;30.1
        sub       esp, 48                                       ;30.1
        cmp       DWORD PTR [212+ecx], 0                        ;36.15
        jbe       .B2.5         ; Prob 10%                      ;36.15
                                ; LOE ecx
.B2.2:                          ; Preds .B2.1
        xor       edx, edx                                      ;36.8
                                ; LOE edx ecx
.B2.3:                          ; Preds .B2.3 .B2.2
        mov       al, BYTE PTR [216+edx+ecx]                    ;37.25
        xor       BYTE PTR [edx+ecx], al                        ;37.5
        inc       edx                                           ;36.28
        cmp       edx, DWORD PTR [212+ecx]                      ;36.15
        jb        .B2.3         ; Prob 82%                      ;36.15
                                ; LOE edx ecx
.B2.5:                          ; Preds .B2.3 .B2.1
        cmp       DWORD PTR [208+ecx], 0                        ;40.27
        jbe       .B2.23        ; Prob 10%                      ;40.27
                                ; LOE ecx
.B2.6:                          ; Preds .B2.5
        mov       DWORD PTR [44+esp], 0                         ;40.3
        pcmpeqd   xmm0, xmm0                                    ;40.3
                                ; LOE ecx xmm0
.B2.7:                          ; Preds .B2.21 .B2.6
        inc       DWORD PTR [44+esp]                            ;40.3
        xor       eax, eax                                      ;43.5
                                ; LOE eax ecx xmm0
.B2.8:                          ; Preds .B2.8 .B2.7
        movq      xmm5, QWORD PTR [ecx+eax*8]                   ;44.15
        movq      xmm1, QWORD PTR [40+ecx+eax*8]                ;44.23
        movq      xmm2, QWORD PTR [80+ecx+eax*8]                ;44.35
        pxor      xmm5, xmm1                                    ;44.23
        movq      xmm3, QWORD PTR [120+ecx+eax*8]               ;44.48
        pxor      xmm5, xmm2                                    ;44.35
        movq      xmm4, QWORD PTR [160+ecx+eax*8]               ;44.61
        pxor      xmm5, xmm3                                    ;44.48
        pxor      xmm5, xmm4                                    ;44.61
        movq      QWORD PTR [esp+eax*8], xmm5                   ;44.7
        inc       eax                                           ;43.5
        cmp       eax, 5                                        ;43.5
        jb        .B2.8         ; Prob 79%                      ;43.5
                                ; LOE eax ecx xmm0
.B2.9:                          ; Preds .B2.8
        xor       ebp, ebp                                      ;46.5
                                ; LOE ecx ebp xmm0
.B2.10:                         ; Preds .B2.12 .B2.9
        mov       eax, -858993459                               ;47.29
        lea       esi, DWORD PTR [1+ebp]                        ;47.29
        mul       esi                                           ;47.29
        shr       edx, 2                                        ;47.29
        lea       ebx, DWORD PTR [4+ebp]                        ;47.19
        mov       eax, -858993459                               ;47.24
        lea       edi, DWORD PTR [edx+edx*4]                    ;47.29
        mul       ebx                                           ;47.24
        shr       edx, 2                                        ;47.24
        neg       edi                                           ;47.29
        add       edi, esi                                      ;47.29
        lea       eax, DWORD PTR [edx+edx*4]                    ;47.24
        sub       ebx, eax                                      ;47.24
        lea       edx, DWORD PTR [ecx+ebp*8]                    ;49.9
        movq      xmm1, QWORD PTR [esp+edi*8]                   ;47.29
        movdqa    xmm2, xmm1                                    ;47.29
        psrlq     xmm1, 63                                      ;47.29
        psllq     xmm2, 1                                       ;47.29
        movq      xmm3, QWORD PTR [esp+ebx*8]                   ;47.11
        por       xmm2, xmm1                                    ;47.29
        pxor      xmm3, xmm2                                    ;47.29
        xor       ebx, ebx                                      ;48.7
                                ; LOE edx ecx ebx esi xmm0 xmm3
.B2.11:                         ; Preds .B2.11 .B2.10
        lea       eax, DWORD PTR [ebx+ebx*4]                    ;49.16
        inc       ebx                                           ;48.7
        movq      xmm1, QWORD PTR [edx+eax*8]                   ;49.9
        cmp       ebx, 5                                        ;48.7
        pxor      xmm1, xmm3                                    ;49.9
        movq      QWORD PTR [edx+eax*8], xmm1                   ;49.9
        jb        .B2.11        ; Prob 79%                      ;48.7
                                ; LOE edx ecx ebx esi xmm0 xmm3
.B2.12:                         ; Preds .B2.11
        mov       ebp, esi                                      ;46.5
        cmp       esi, 5                                        ;46.5
        jb        .B2.10        ; Prob 79%                      ;46.5
                                ; LOE ecx ebp xmm0
.B2.13:                         ; Preds .B2.12
        movq      xmm4, QWORD PTR [8+ecx]                       ;54.9
        xor       ebx, ebx                                      ;55.5
                                ; LOE ecx ebx xmm0 xmm4
.B2.14:                         ; Preds .B2.14 .B2.13
        mov       eax, DWORD PTR [_keccakf_rotc+ebx*4]          ;58.15
        movdqa    xmm3, xmm4                                    ;58.15
        mov       edx, DWORD PTR [_keccakf_piln+ebx*4]          ;56.11
        inc       ebx                                           ;55.5
        movd      xmm1, eax                                     ;58.15
        neg       eax                                           ;58.15
        add       eax, 64                                       ;58.15
        psllq     xmm3, xmm1                                    ;58.15
        movq      xmm5, QWORD PTR [ecx+edx*8]                   ;57.15
        cmp       ebx, 24                                       ;55.5
        movd      xmm2, eax                                     ;58.15
        psrlq     xmm4, xmm2                                    ;58.15
        por       xmm3, xmm4                                    ;58.15
        movdqa    xmm4, xmm5                                    ;59.7
        movq      QWORD PTR [ecx+edx*8], xmm3                   ;58.7
        jb        .B2.14        ; Prob 95%                      ;55.5
                                ; LOE ecx ebx xmm0 xmm4 xmm5
.B2.15:                         ; Preds .B2.14
        movq      QWORD PTR [esp], xmm5                         ;57.7
        mov       DWORD PTR [40+esp], 0                         ;63.5
                                ; LOE ecx xmm0
.B2.16:                         ; Preds .B2.20 .B2.15
        mov       eax, DWORD PTR [40+esp]                       ;65.24
        xor       ebx, ebx                                      ;64.7
        lea       edx, DWORD PTR [eax+eax*4]                    ;65.24
        lea       edi, DWORD PTR [ecx+edx*8]                    ;65.17
                                ; LOE ecx ebx edi xmm0
.B2.17:                         ; Preds .B2.17 .B2.16
        movq      xmm1, QWORD PTR [edi+ebx*8]                   ;65.17
        movq      QWORD PTR [esp+ebx*8], xmm1                   ;65.9
        inc       ebx                                           ;64.7
        cmp       ebx, 5                                        ;64.7
        jb        .B2.17        ; Prob 79%                      ;64.7
                                ; LOE ecx ebx edi xmm0
.B2.18:                         ; Preds .B2.17
        xor       ebp, ebp                                      ;67.7
                                ; LOE ecx ebp edi xmm0
.B2.19:                         ; Preds .B2.19 .B2.18
        mov       eax, -858993459                               ;68.37
        lea       esi, DWORD PTR [1+ebp]                        ;68.32
        mul       esi                                           ;68.37
        shr       edx, 2                                        ;68.37
        mov       eax, -858993459                               ;68.56
        movq      xmm3, QWORD PTR [edi+ebp*8]                   ;68.9
        lea       ebx, DWORD PTR [edx+edx*4]                    ;68.37
        neg       ebx                                           ;68.37
        add       ebx, esi                                      ;68.37
        movq      xmm2, QWORD PTR [esp+ebx*8]                   ;68.24
        lea       ebx, DWORD PTR [2+ebp]                        ;68.51
        mul       ebx                                           ;68.56
        shr       edx, 2                                        ;68.56
        pandn     xmm2, xmm0                                    ;68.24
        lea       eax, DWORD PTR [edx+edx*4]                    ;68.56
        sub       ebx, eax                                      ;68.56
        cmp       esi, 5                                        ;67.7
        movq      xmm1, QWORD PTR [esp+ebx*8]                   ;68.43
        pand      xmm2, xmm1                                    ;68.43
        pxor      xmm3, xmm2                                    ;68.9
        movq      QWORD PTR [edi+ebp*8], xmm3                   ;68.9
        mov       ebp, esi                                      ;67.7
        jb        .B2.19        ; Prob 79%                      ;67.7
                                ; LOE ecx ebp edi xmm0
.B2.20:                         ; Preds .B2.19
        mov       eax, DWORD PTR [40+esp]                       ;63.5
        inc       eax                                           ;63.5
        mov       DWORD PTR [40+esp], eax                       ;63.5
        cmp       eax, 5                                        ;63.5
        jb        .B2.16        ; Prob 79%                      ;63.5
                                ; LOE ecx xmm0
.B2.21:                         ; Preds .B2.20
        mov       eax, DWORD PTR [44+esp]                       ;73.14
        movq      xmm2, QWORD PTR [ecx]                         ;73.5
        cmp       eax, DWORD PTR [208+ecx]                      ;40.27
        movq      xmm1, QWORD PTR [_keccakf_rndc-8+eax*8]       ;73.14
        pxor      xmm2, xmm1                                    ;73.5
        movq      QWORD PTR [ecx], xmm2                         ;73.5
        jb        .B2.7         ; Prob 95%                      ;40.27
                                ; LOE ecx xmm0
.B2.23:                         ; Preds .B2.21 .B2.5
        add       esp, 48                                       ;75.1
        pop       ebp                                           ;75.1
        pop       ebx                                           ;75.1
        pop       edi                                           ;75.1
        pop       esi                                           ;75.1
        ret                                                     ;75.1
                                ; LOE
; mark_end;
@SHA3_Transform@4 ENDP
;@SHA3_Transform@4	ENDS
_TEXT	ENDS
_DATA	SEGMENT  DWORD PUBLIC FLAT  'DATA'
_DATA	ENDS
; -- End  @SHA3_Transform@4
_TEXT	SEGMENT  DWORD PUBLIC FLAT  'CODE'
;	COMDAT @SHA3_Final@8
TXTST2:
; -- Begin  @SHA3_Final@8
;@SHA3_Final@8	ENDS
_TEXT	ENDS
_TEXT	SEGMENT  DWORD PUBLIC FLAT  'CODE'
;	COMDAT @SHA3_Final@8
; mark_begin;

	PUBLIC @SHA3_Final@8
@SHA3_Final@8	PROC NEAR 
; parameter 1: ecx
; parameter 2: edx
.B3.1:                          ; Preds .B3.0
        push      ebx                                           ;125.1
        push      ebp                                           ;125.1
        mov       ebp, edx                                      ;125.1
        mov       ebx, ecx                                      ;125.1
        mov       eax, DWORD PTR [200+ebp]                      ;128.18
        mov       BYTE PTR [216+eax+ebp], 6                     ;128.3
        mov       eax, DWORD PTR [200+ebp]                      ;128.18
        inc       eax                                           ;128.18
        mov       edx, DWORD PTR [212+ebp]                      ;130.23
        cmp       eax, edx                                      ;130.23
        mov       DWORD PTR [200+ebp], eax                      ;128.18
        jae       .B3.5         ; Prob 10%                      ;130.23
                                ; LOE eax edx ebx ebp esi edi
.B3.3:                          ; Preds .B3.1 .B3.3
        mov       BYTE PTR [216+eax+ebp], 0                     ;131.5
        mov       eax, DWORD PTR [200+ebp]                      ;131.20
        inc       eax                                           ;131.20
        mov       edx, DWORD PTR [212+ebp]                      ;130.23
        cmp       eax, edx                                      ;130.23
        mov       DWORD PTR [200+ebp], eax                      ;131.20
        jb        .B3.3         ; Prob 82%                      ;130.23
                                ; LOE eax edx ebx ebp esi edi
.B3.5:                          ; Preds .B3.3 .B3.1
        mov       ecx, ebp                                      ;136.3
        or        BYTE PTR [215+edx+ebp], -128                  ;134.3
        call      @SHA3_Transform@4                             ;136.3
                                ; LOE ebx ebp esi edi
.B3.6:                          ; Preds .B3.5
        cmp       DWORD PTR [204+ebp], 0                        ;138.15
        jbe       .B3.10        ; Prob 10%                      ;138.15
                                ; LOE ebx ebp esi edi
.B3.7:                          ; Preds .B3.6
        xor       edx, edx                                      ;138.8
                                ; LOE edx ebx ebp esi edi
.B3.8:                          ; Preds .B3.8 .B3.7
        mov       al, BYTE PTR [edx+ebp]                        ;139.26
        mov       BYTE PTR [edx+ebx], al                        ;139.16
        inc       edx                                           ;138.28
        cmp       edx, DWORD PTR [204+ebp]                      ;138.15
        jb        .B3.8         ; Prob 82%                      ;138.15
                                ; LOE edx ebx ebp esi edi
.B3.10:                         ; Preds .B3.8 .B3.6
        pop       ebp                                           ;141.1
        pop       ebx                                           ;141.1
        ret                                                     ;141.1
                                ; LOE
; mark_end;
@SHA3_Final@8 ENDP
;@SHA3_Final@8	ENDS
_TEXT	ENDS
_DATA	SEGMENT  DWORD PUBLIC FLAT  'DATA'
_DATA	ENDS
; -- End  @SHA3_Final@8
_TEXT	SEGMENT  DWORD PUBLIC FLAT  'CODE'
;	COMDAT @SHA3_Init@8
TXTST3:
; -- Begin  @SHA3_Init@8
;@SHA3_Init@8	ENDS
_TEXT	ENDS
_TEXT	SEGMENT  DWORD PUBLIC FLAT  'CODE'
;	COMDAT @SHA3_Init@8
; mark_begin;

	PUBLIC @SHA3_Init@8
@SHA3_Init@8	PROC NEAR 
; parameter 1: ecx
; parameter 2: edx
.B4.1:                          ; Preds .B4.0
        push      edi                                           ;78.1
        push      ebp                                           ;78.1
        mov       ebp, ecx                                      ;78.1
        mov       edi, ebp                                      ;85.5
        xor       eax, eax                                      ;85.5
        push      50                                            ;85.5
        pop       ecx                                           ;85.5
        mov       DWORD PTR [208+ebp], 24                       ;81.3
        mov       DWORD PTR [200+ebp], 0                        ;82.3
        rep   stosd                                             ;85.5
                                ; LOE edx ebx ebp esi
.B4.2:                          ; Preds .B4.1
        test      edx, edx                                      ;88.11
        je        .B4.8         ; Prob 25%                      ;88.11
                                ; LOE edx ebx ebp esi
.B4.3:                          ; Preds .B4.2
        cmp       edx, 2                                        ;88.11
        je        .B4.7         ; Prob 33%                      ;88.11
                                ; LOE edx ebx ebp esi
.B4.4:                          ; Preds .B4.3
        cmp       edx, 3                                        ;88.11
        jne       .B4.6         ; Prob 50%                      ;88.11
                                ; LOE ebx ebp esi
.B4.5:                          ; Preds .B4.4
        mov       DWORD PTR [212+ebp], 72                       ;99.7
        mov       DWORD PTR [204+ebp], 64                       ;100.7
        jmp       .B4.9         ; Prob 100%                     ;100.7
                                ; LOE ebx esi
.B4.6:                          ; Preds .B4.4
        mov       DWORD PTR [212+ebp], 136                      ;103.7
        mov       DWORD PTR [204+ebp], 32                       ;104.7
        jmp       .B4.9         ; Prob 100%                     ;104.7
                                ; LOE ebx esi
.B4.7:                          ; Preds .B4.3
        mov       DWORD PTR [212+ebp], 104                      ;95.7
        mov       DWORD PTR [204+ebp], 48                       ;96.7
        jmp       .B4.9         ; Prob 100%                     ;96.7
                                ; LOE ebx esi
.B4.8:                          ; Preds .B4.2
        mov       DWORD PTR [212+ebp], 144                      ;91.7
        mov       DWORD PTR [204+ebp], 28                       ;92.7
                                ; LOE ebx esi
.B4.9:                          ; Preds .B4.8 .B4.7 .B4.5 .B4.6
        pop       ebp                                           ;107.1
        pop       edi                                           ;107.1
        ret                                                     ;107.1
                                ; LOE
; mark_end;
@SHA3_Init@8 ENDP
;@SHA3_Init@8	ENDS
_TEXT	ENDS
_DATA	SEGMENT  DWORD PUBLIC FLAT  'DATA'
_DATA	ENDS
; -- End  @SHA3_Init@8
_RDATA	SEGMENT  DWORD PUBLIC FLAT READ  'DATA'
	PUBLIC _keccakf_rndc
_keccakf_rndc	DD	000000001H,000000000H
	DD	000008082H,000000000H
	DD	00000808aH,080000000H
	DD	080008000H,080000000H
	DD	00000808bH,000000000H
	DD	080000001H,000000000H
	DD	080008081H,080000000H
	DD	000008009H,080000000H
	DD	00000008aH,000000000H
	DD	000000088H,000000000H
	DD	080008009H,000000000H
	DD	08000000aH,000000000H
	DD	08000808bH,000000000H
	DD	00000008bH,080000000H
	DD	000008089H,080000000H
	DD	000008003H,080000000H
	DD	000008002H,080000000H
	DD	000000080H,080000000H
	DD	00000800aH,000000000H
	DD	08000000aH,080000000H
	DD	080008081H,080000000H
	DD	000008080H,080000000H
	DD	080000001H,000000000H
	DD	080008008H,080000000H
	PUBLIC _keccakf_rotc
_keccakf_rotc	DD	1
	DD	3
	DD	6
	DD	10
	DD	15
	DD	21
	DD	28
	DD	36
	DD	45
	DD	55
	DD	2
	DD	14
	DD	27
	DD	41
	DD	56
	DD	8
	DD	25
	DD	43
	DD	62
	DD	18
	DD	39
	DD	61
	DD	20
	DD	44
	PUBLIC _keccakf_piln
_keccakf_piln	DD	10
	DD	7
	DD	11
	DD	17
	DD	18
	DD	3
	DD	5
	DD	16
	DD	8
	DD	21
	DD	24
	DD	4
	DD	15
	DD	23
	DD	19
	DD	13
	DD	12
	DD	2
	DD	20
	DD	14
	DD	22
	DD	9
	DD	6
	DD	1
_RDATA	ENDS
_DATA	SEGMENT  DWORD PUBLIC FLAT  'DATA'
_DATA	ENDS
	INCLUDELIB <libmmt>
	INCLUDELIB <LIBCMT>
	INCLUDELIB <libirc>
	INCLUDELIB <svml_dispmt>
	INCLUDELIB <OLDNAMES>
	INCLUDELIB <libdecimal>
	END
