

// Test unit for SHA-3 in C
// Odzhan

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <sys/stat.h>
#include <time.h>

#include "sha3.h"

char *text[] =
{ "",
  "a",
  "abc",
  "message digest",
  "abcdefghijklmnopqrstuvwxyz",
  "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789",
  "12345678901234567890123456789012345678901234567890123456789012345678901234567890"
};

char *SHA3_dgst[] =
{ "a7ffc6f8bf1ed76651c14756a061d662f580ff4de43b49fa82d80a4b80f8434a",
  "80084bf2fba02475726feb2cab2d8215eab14bc6bdd8bfb2c8151257032ecd8b",
  "3a985da74fe225b2045c172d6bd390bd855f086e3e9d525b46bfe24511431532",
  "edcdb2069366e75243860c18c3a11465eca34bce6143d30c8665cefcfd32bffd",
  "7cab2dc765e21b241dbc1c255ce620b29f527c6d5e7f5f843e56288f0d707521",
  "a79d6a9da47f04a3b9a9323ec9991f2105d4c78a7bc7beeb103855a7a11dfb9f",
  "293e5ce4ce54ee71990ab06e511b7ccd62722b1beb414f5ff65c8274e0f5be1d"
};

size_t hex2bin (void *bin, char hex[]) {
  size_t len, i;
  int x;
  uint8_t *p=(uint8_t*)bin;
  
  len = strlen (hex);
  
  if ((len & 1) != 0) {
    return 0; 
  }
  
  for (i=0; i<len; i++) {
    if (isxdigit((int)hex[i]) == 0) {
      return 0; 
    }
  }
  
  for (i=0; i<len / 2; i++) {
    sscanf (&hex[i * 2], "%2x", &x);
    p[i] = (uint8_t)x;
  } 
  return len / 2;
} 

int run_tests (void)
{
  uint8_t  dgst[256], tv[256];
  int      i, fails=0;
  SHA3_CTX ctx;
  
  for (i=0; i<sizeof(text)/sizeof(char*); i++)
  {
    SHA3_Init (&ctx, SHA3_256);
    SHA3_Update (&ctx, text[i], strlen (text[i]));
    SHA3_Final (dgst, &ctx);
    
    hex2bin (tv, SHA3_dgst[i]);
    
    if (memcmp (dgst, tv, ctx.outlen) != 0) {
      printf ("\nFailed for string \"%s\"", text[i]);
      ++fails;
    }
  }
  return fails;
}

// print digest
void SHA3_print (uint8_t dgst[], size_t len)
{
  size_t i;
  for (i=0; i<len; i++) {
    printf ("%02x", dgst[i]);
  }
  putchar ('\n');
}

// generate SHA-3 hash of string
void SHA3_string (char *str, int type)
{
  SHA3_CTX ctx;
  size_t   i;
  uint8_t  dgst[256];
  char     *hdrs[]={ "SHA3-224", "SHA3-256", "SHA3-384", "SHA3-512" };

  type=(type > SHA3_512) ? SHA3_256 : type;
  
  printf ("\n%s(\"%s\")\n0x", hdrs[type], str);
  
  SHA3_Init (&ctx, type);
  SHA3_Update (&ctx, str, strlen (str));
  SHA3_Final (dgst, &ctx);
  
  SHA3_print (dgst, ctx.outlen);
}

void progress (uint64_t fs_complete, uint64_t fs_total)
{
  int           days=0, hours=0, minutes=0;
  uint64_t      t, pct, speed, seconds=0;
  static time_t start=0;
  
  if (start==0) {
    start=time(0);
    return;
  }
  
  pct = (100*fs_complete)/fs_total;
  
  t = (time(0) - start);
  
  if (t != 0) {
    seconds = (fs_total - fs_complete) / (fs_complete / t);
    speed   = (fs_complete / t);
    
    days=0;
    hours=0;
    minutes=0;
    
    if (seconds>=60) {
      minutes = (seconds / 60);
      seconds %= 60;
      if (minutes>=60) {
        hours = minutes / 60;
        minutes %= 60;
        if (hours>=24) {
          days = hours/24;
          hours %= 24;
        }
      }
    }
  printf ("\rProcessed %llu MB out of %llu MB %llu MB/s : %llu%% complete. ETA: %03d:%02d:%02d:%02d    ",
    fs_complete/1000/1000, fs_total/1000/1000, speed/1000/1000, pct, days, hours, minutes, (int)seconds);
  }
}

// generate SHA-3 hash of file
void SHA3_file (char fn[], int type)
{
  FILE     *fd;
  SHA3_CTX ctx;
  size_t   len;
  uint8_t  buf[4096+1], dgst[256];
  struct stat st;
  uint32_t cmp=0, total=0;
  
  fd = fopen (fn, "rb");
  
  if (fd!=NULL)
  {
    stat (fn, &st);
    total=st.st_size;
    
    SHA3_Init (&ctx, type);
    
    while (len = fread (buf, 1, 4096, fd)) {
      cmp += len;
      if (total > 10000000 && (cmp % 10000000)==0 || cmp==total) {
        progress (cmp, total);
      }
      SHA3_Update (&ctx, buf, len);
    }
    SHA3_Final (dgst, &ctx);

    fclose (fd);

    printf ("\n  [ SHA3-%d (%s) = ", ctx.outlen*8, fn);
    SHA3_print (dgst, ctx.outlen);
  } else {
    printf ("  [ unable to open %s\n", fn);
  }
}

char* getparam (int argc, char *argv[], int *i)
{
  int n=*i;
  if (argv[n][2] != 0) {
    return &argv[n][2];
  }
  if ((n+1) < argc) {
    *i=n+1;
    return argv[n+1];
  }
  printf ("  [ %c%c requires parameter\n", argv[n][0], argv[n][1]);
  exit (0);
}

void usage (void)
{
  int i;
  
  printf ("\n  usage: sha3_test -t <type> -f <file> -s <string>\n");
  printf ("\n  -t <type>   Type is 0=SHA3-224, 1=SHA3-256 (default), 2=SHA3-384, 3=SHA3-512");
  printf ("\n  -s <string> Derive SHA3 hash of <string>");
  printf ("\n  -f <file>   Derive SHA3 hash of <file>");
  printf ("\n  -x          Run tests\n");
  exit (0);
}

int main (int argc, char *argv[])
{
  char opt;
  int i, test=0, type=SHA3_256, wc=0;
  char *file=NULL, *str=NULL;
  
  // for each argument
  for (i=1; i<argc; i++)
  {
    // is this option?
    if (argv[i][0]=='-' || argv[i][1]=='/')
    {
      // get option value
      opt=argv[i][1];
      switch (opt)
      {
        case 's':
          str=getparam (argc, argv, &i);
          break;
        case 'f':
          file=getparam (argc, argv, &i);
          break;
        case 't':
          type=atoi(getparam (argc, argv, &i));
          break;
        case 'x':
          test=1;
          break;
        default:
          usage ();
          break;
      }
    }
    // if this is path, set wildcard to true
    if (wc==0) {
      wc=i;
    }
  }
  
  if (test) {
    if (!run_tests()) {
      printf ("\n  [ self-test OK!\n");
    }
  } else if (str!=NULL) {
    SHA3_string (str, type);
  } else if (file!=NULL || wc!=0) {
    if (wc!=0) {
      while (argv[wc]!=NULL) {
        SHA3_file (argv[wc++], type);
      }
    } else {
      SHA3_file (file, type);
    }
  } else {
    usage ();
  }
  return 0;
}
