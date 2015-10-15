

// SHA-3 in C
// Odzhan

#ifndef SHA3_H
#define SHA3_H

#include <stdint.h>

#define SHA3_ROUNDS       24
#define SHA3_STATE_LEN    25

#define SHA3_224                 0
#define SHA3_224_DIGEST_LENGTH  28
#define SHA3_224_CBLOCK        144

#define SHA3_256                 1
#define SHA3_256_DIGEST_LENGTH  32
#define SHA3_256_CBLOCK        136

#define SHA3_384                 2
#define SHA3_384_DIGEST_LENGTH  48
#define SHA3_384_CBLOCK        104

#define SHA3_512                 3
#define SHA3_512_DIGEST_LENGTH  64
#define SHA3_512_CBLOCK         72

#define MIN(X, Y) (((X) < (Y)) ? (X) : (Y))

#pragma pack(push, 1)
typedef struct _SHA3_CTX {
  union {
    uint8_t v8[SHA3_STATE_LEN*8];
    uint32_t v32[SHA3_STATE_LEN*4];
    uint64_t v64[SHA3_STATE_LEN];
  } state;
  
  uint32_t index;
  uint32_t dgstlen;
  uint32_t rounds;
  uint32_t blklen;
  
  union {
    uint8_t v8[256];
    uint32_t v32[256/4];
    uint64_t v64[256/8];
  } blk;
} SHA3_CTX;
#pragma pack(pop)

#ifdef __cplusplus
extern "C" {
#endif

  void SHA3_Init (SHA3_CTX *, int);
  void SHA3_Update (SHA3_CTX*, void *, uint32_t);
  void SHA3_Final (void*, SHA3_CTX*);

#ifdef __cplusplus
}
#endif

#endif