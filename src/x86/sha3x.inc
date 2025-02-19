

; SHA-3 for NASM/YASM
; Odzhan

%ifndef SHA3_H
%define SHA3_H

%define SHA3_ROUNDS	            24
%define SHA3_STATE_LEN	        25

%define SHA3_224	              56
%define SHA3_224_DIGEST_LENGTH	28
%define SHA3_224_CBLOCK	       144

%define SHA3_256	              64
%define SHA3_256_DIGEST_LENGTH	32
%define SHA3_256_CBLOCK	       136

%define SHA3_384	              96
%define SHA3_384_DIGEST_LENGTH	48
%define SHA3_384_CBLOCK	       104

%define SHA3_512	             128
%define SHA3_512_DIGEST_LENGTH	64
%define SHA3_512_CBLOCK	        72

struc SHA3_CTX 
  outlen	resd 1
  buflen	resd 1
  index	  resd 1
  
  state   resq 25
  .size:
endstruc

  ;SHA3_Init proto :ptr SHA3_CTX, :DWORD
  ;SHA3_Update proto :ptr SHA3_CTX, :DWORD
  ;SHA3_Final proto :DWORD, :ptr SHA3_CTX

%endif