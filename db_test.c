

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

int crypto_hash_sha3256(uint8_t *h, const uint8_t *m, uint64_t n);

int main (int argc, char *argv[])
{
  uint8_t out[32];
  int i;
  
  if (argc!=2) { printf ("\nusage: db_test <text>\n"); }
  
  crypto_hash_sha3256 (out, argv[1], strlen(argv[1]));
  
  printf ("\nSHA3-256: ");
  for (i=0; i<32; i++) printf ("%02x", out[i]);
  return 0;
}
