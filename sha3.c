

// SHA-3 in C
// Odzhan

#include "sha3.h"

const uint64_t keccakf_rndc[24] = 
{ 0x0000000000000001, 0x0000000000008082, 0x800000000000808a,
  0x8000000080008000, 0x000000000000808b, 0x0000000080000001,
  0x8000000080008081, 0x8000000000008009, 0x000000000000008a,
  0x0000000000000088, 0x0000000080008009, 0x000000008000000a,
  0x000000008000808b, 0x800000000000008b, 0x8000000000008089,
  0x8000000000008003, 0x8000000000008002, 0x8000000000000080, 
  0x000000000000800a, 0x800000008000000a, 0x8000000080008081,
  0x8000000000008080, 0x0000000080000001, 0x8000000080008008
};

const int keccakf_rotc[24] = 
{ 1,  3,  6,  10, 15, 21, 28, 36, 45, 55, 2,  14, 
  27, 41, 56, 8,  25, 43, 62, 18, 39, 61, 20, 44 };

const int keccakf_piln[24] = 
{ 10, 7,  11, 17, 18, 3, 5,  16, 8,  21, 24, 4, 
  15, 23, 19, 13, 12, 2, 20, 14, 22, 9,  6,  1  };

#define ROTL64(x, y) (((x) << (y)) | ((x) >> (64 - (y))))

void SHA3_Transform (SHA3_CTX *ctx)
{
  uint32_t i, j, round;
  uint64_t t, bc[5];
  uint64_t *st=(uint64_t*)ctx->state.v64;
  
  // xor state with block
  for (i=0; i<ctx->buflen; i++) {
    ctx->state.v8[i] ^= ctx->buffer.v8[i];
  }
  
  for (round = 0; round < ctx->rounds; round++) 
  {
    // Theta
    for (i=0; i<5; i++) {     
      bc[i] = st[i] 
            ^ st[i + 5] 
            ^ st[i + 10] 
            ^ st[i + 15] 
            ^ st[i + 20];
    }
    for (i=0; i<5; i++) {
      t = bc[(i + 4) % 5] ^ ROTL64(bc[(i + 1) % 5], 1);
      for (j = 0; j < 25; j += 5) {
        st[j + i] ^= t;
      }
    }

    // Rho Pi
    t = st[1];
    for (i = 0; i < 24; i++) {
      j = keccakf_piln[i];
      bc[0] = st[j];
      st[j] = ROTL64(t, keccakf_rotc[i]);
      t = bc[0];
    }

    //  Chi
    for (j = 0; j < 25; j += 5) {
      for (i = 0; i < 5; i++) {
        bc[i] = st[j + i];
      }
      for (i = 0; i < 5; i++) {
        st[j + i] ^= (~bc[(i + 1) % 5]) & bc[(i + 2) % 5];
      }
    }
    
    //  Iota
    st[0] ^= keccakf_rndc[round];
  }
}

void SHA3_Init (SHA3_CTX *ctx, int type)
{
  uint32_t i;
  
  ctx->rounds = SHA3_ROUNDS;
  ctx->index  = 0;
  
  for (i=0; i<SHA3_STATE_LEN; i++) {
    ctx->state.v64[i] = 0;
  }
  
  switch (type)
  {
    case SHA3_224:
      ctx->buflen = SHA3_224_CBLOCK;
      ctx->outlen = SHA3_224_DIGEST_LENGTH;
      break;
    case SHA3_384:
      ctx->buflen = SHA3_384_CBLOCK;
      ctx->outlen = SHA3_384_DIGEST_LENGTH;
      break;
    case SHA3_512:
      ctx->buflen = SHA3_512_CBLOCK;
      ctx->outlen = SHA3_512_DIGEST_LENGTH;
      break;
    default:
      ctx->buflen = SHA3_256_CBLOCK;
      ctx->outlen = SHA3_256_DIGEST_LENGTH;
      break;
  }   
}

void SHA3_Update (SHA3_CTX* ctx, void *in, uint32_t inlen) {
  uint32_t i;
  
  // update buffer and state
  for (i=0; i<inlen; i++) {
    // absorb byte
    ctx->buffer.v8[ctx->index++] = ((uint8_t*)in)[i];
    
    if (ctx->index == ctx->buflen) {
      SHA3_Transform (ctx);
      ctx->index = 0;
    }
  }
}

void SHA3_Final (void* out, SHA3_CTX* ctx)
{
  uint32_t i;
  // absorb 3 bits, Keccak uses 1
  ctx->buffer.v8[ctx->index++] = 6;
  // fill remaining space with zeros
  while (ctx->index < ctx->buflen) {
    ctx->buffer.v8[ctx->index++] = 0;
  }
  // absorb end bit
  ctx->buffer.v8[ctx->buflen-1] |= 0x80;
  // update context
  SHA3_Transform (ctx);
  // copy digest to buffer
  for (i=0; i<ctx->outlen; i++) {
    ((uint8_t*)out)[i] = ctx->state.v8[i];
  }
}
