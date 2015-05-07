;--- include file created by h2incx v0.99.20 (copyright 2005-2009 japheth)
;--- source file: c:\github\sha3\sha3.h, last modified: 5/7/2015 16:36
;--- cmdline used for creation:  sha3.h

ifndef SHA3_H
SHA3_H	EQU	<>
	include stdint.inc
SHA3_ROUNDS	EQU	24
SHA3_STATE_LEN	EQU	25
SHA3_224	EQU	0
SHA3_224_DIGEST_LENGTH	EQU	28
SHA3_224_CBLOCK	EQU	144
SHA3_256	EQU	1
SHA3_256_DIGEST_LENGTH	EQU	32
SHA3_256_CBLOCK	EQU	136
SHA3_384	EQU	2
SHA3_384_DIGEST_LENGTH	EQU	48
SHA3_384_CBLOCK	EQU	104
SHA3_512	EQU	3
SHA3_512_DIGEST_LENGTH	EQU	64
SHA3_512_CBLOCK	EQU	72
MIN macro X,Y
	exitm <( ( ( X ) < ( Y ) ) ? ( X ) : ( Y ) ) >
	endm
;#pragma pack ( push , 1 ) 
SHA3_CTX	struct 
union state
v8	uint8_t SHA3_STATE_LEN*8 dup (?)
v32	uint32_t SHA3_STATE_LEN*4 dup (?)
v64	uint64_t SHA3_STATE_LEN dup (?)
ends
index	uint32_t	?
dgstlen	size_t	?
rounds	uint32_t	?
blklen	size_t	?
union blk
v8	uint8_t 256 dup (?)
v32	uint32_t 256/4 dup (?)
v64	uint32_t 256/8 dup (?)
ends
SHA3_CTX	ends

;#pragma pack ( pop ) 
ifdef __cplusplus
;extern "C"
;{
endif 
SHA3_Init proto  :ptr SHA3_CTX, :DWORD
SHA3_Update proto  :ptr SHA3_CTX, :ptr , :size_t
SHA3_Final proto  :ptr , :ptr SHA3_CTX
ifdef __cplusplus
;}
endif 
endif 

;--- errors: 0
;--- end of file ---
