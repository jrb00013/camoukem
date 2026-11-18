#include "mlkem_asm.h"
#include <stdint.h>

/* C oracle matching pq-crystals/kyber NTT — used to verify asm. */
extern const int16_t mlkem_zetas[128];

#define Q MLKEM_Q
#define QINV 62209

static int16_t montgomery_reduce(int32_t a) {
    int16_t t = (int16_t)a * (int16_t)QINV;
    t = (a - (int32_t)t * Q) >> 16;
    return t;
}

static int16_t barrett_reduce(int16_t a) {
    int16_t t = ((int32_t)a * 20159) >> 26;
    return a - t * Q;
}

static int16_t fqmul(int16_t a, int16_t b) {
    return montgomery_reduce((int32_t)a * b);
}

void mlkem_ref_ntt(int16_t r[MLKEM_N]) {
    unsigned int len, start, j, k = 1;
    for (len = 128; len >= 2; len >>= 1) {
        for (start = 0; start < MLKEM_N; start = j + len) {
            int16_t zeta = mlkem_zetas[k++];
            for (j = start; j < start + len; j++) {
                int16_t t = fqmul(zeta, r[j + len]);
                r[j + len] = r[j] - t;
                r[j] = r[j] + t;
            }
        }
    }
}

void mlkem_ref_invntt(int16_t r[MLKEM_N]) {
    unsigned int start, len, j, k = 127;
    const int16_t f = 1441;
    for (len = 2; len <= 128; len <<= 1) {
        for (start = 0; start < MLKEM_N; start = j + len) {
            int16_t zeta = mlkem_zetas[k--];
            for (j = start; j < start + len; j++) {
                int16_t t = r[j];
                r[j] = barrett_reduce(t + r[j + len]);
                r[j + len] = r[j + len] - t;
                r[j + len] = fqmul(zeta, r[j + len]);
            }
        }
    }
    for (j = 0; j < MLKEM_N; j++)
        r[j] = fqmul(r[j], f);
}
