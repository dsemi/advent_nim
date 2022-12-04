#include <openssl/md5.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <x86intrin.h>

typedef uint16_t v16hi __attribute__ ((vector_size (32)));
typedef uint8_t v32qi __attribute__ ((vector_size (32)));

union Sum {
  __m128i i128;
  uint8_t md[16];
};

union Result {
  v16hi h;
  v32qi q;
  char hex[32];
};

void md5sum(const char *str, size_t len, union Result *v, size_t stretch) {
  union Sum u;
  MD5(str, len, u.md);
  v->h = (v16hi) _mm256_cvtepu8_epi16(u.i128);
  v->h = (v->h >> 4) | ((v->h << 8) & 0xf00);
  v->q += '0' + (39 & (v->q > 9));
  for (size_t i = 0; i < stretch; i++) {
    MD5((const unsigned char*) v->hex, 32, u.md);
    v->h = (v16hi) _mm256_cvtepu8_epi16(u.i128);
    v->h = (v->h >> 4) | ((v->h << 8) & 0xf00);
    v->q += '0' + (39 & (v->q > 9));
  }
}
