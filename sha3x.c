

// SHA-3 in C
// Odzhan

#include "sha3x.h"

const uint32_t keccakf_rndc[24] = 
{ 0x00000001, 0x00008082, 0x0000808a,
  0x80008000, 0x0000808b, 0x80000001,
  0x80008081, 0x00008009, 0x0000008a,
  0x00000088, 0x80008009, 0x8000000a,
  0x8000808b, 0x0000008b, 0x00008089,
  0x00008003, 0x00008002, 0x00000080, 
  0x0000800a, 0x8000000a, 0x80008081,
  0x00008080, 0x80000001, 0x80008008
};

const int keccakf_rotc[24] = 
{ 1,  3,  6,  10, 15, 21, 28, 36/2, 45/2, 55/2, 2,  14, 
  27, 41/2, 56/2, 8,  25, 43/2, 62/2, 18, 39/2, 61/2, 20, 44/2 };

const int keccakf_piln[24] = 
{ 10, 7,  11, 17, 18, 3, 5,  16, 8,  21, 24, 4, 
  15, 23, 19, 13, 12, 2, 20, 14, 22, 9,  6,  1  };

void SHA3_Transform (SHA3_CTX *ctx)
{
  uint32_t i, j, round;
  uint32_t t, bc[5];
  uint32_t *st=(uint32_t*)ctx->state.v32;
  
  // xor state with block
  for (i=0; i<ctx->buflen; i++) {
    ctx->state.v8[i] ^= ctx->buffer.v8[i];
  }
  
  for (round = 0; round < ctx->rounds; round++) 
  {
    // Theta
    for (i=0; i<5; i++) {     
      bc[i] = st[i] ^ st[i + 5] ^ st[i + 10] ^ st[i + 15] ^ st[i + 20];
    }
    for (i=0; i<5; i++) {
      t = bc[(i + 4) % 5] ^ ROTL32(bc[(i + 1) % 5], 1);
      for (j = 0; j < 25; j += 5) {
        st[j + i] ^= t;
      }
    }

    // Rho Pi
    t = st[1];
    for (i = 0; i < 24; i++) {
      j = keccakf_piln[i];
      bc[0] = st[j];
      st[j] = ROTL32(t, keccakf_rotc[i]);
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
    ctx->state.v32[i] = 0;
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
