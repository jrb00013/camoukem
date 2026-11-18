#ifndef MLKEM_ASM_H
#define MLKEM_ASM_H

#include <stddef.h>
#include <stdint.h>

#define MLKEM_N 256
#define MLKEM_Q 3329

typedef int16_t mlkem_poly[MLKEM_N];

/* AArch64 NEON / scalar asm kernels — see asm/aarch64/ */
void mlkem_poly_add(int16_t *r, const int16_t *a, const int16_t *b);
void mlkem_poly_sub(int16_t *r, const int16_t *a, const int16_t *b);
void mlkem_poly_setzero(int16_t *r);
void mlkem_poly_copy(int16_t *r, const int16_t *a);
void mlkem_poly_neg(int16_t *r, const int16_t *a);
void mlkem_poly_reduce(int16_t *r);
void mlkem_poly_csubq(int16_t *r);
void mlkem_poly_tomont(int16_t *r);
void mlkem_ntt(int16_t *r);
void mlkem_invntt(int16_t *r);
void mlkem_ntt_neon(int16_t *r);
void mlkem_basemul(int16_t *r, const int16_t *a, const int16_t *b, int16_t zeta);
void mlkem_basemul_acc(int16_t *r, const int16_t *a, const int16_t *b, int16_t zeta);
void mlkem_spin_mul(int16_t *r, const int16_t *a, int16_t u);
void mlkem_mask_refresh_pair(int16_t *s0, int16_t *s1, const int16_t *noise);
void mlkem_poly_frombytes(int16_t *r, const uint8_t *a);
void mlkem_poly_tobytes(uint8_t *r, const int16_t *a);
void mlkem_poly_compress_d4(uint8_t *r, const int16_t *a);
void mlkem_poly_cbd2(int16_t *r, const uint8_t *buf);
void mlkem_cmov(uint8_t *r, const uint8_t *x, size_t len, uint8_t b);
void mlkem_keccak_f1600(uint64_t state[25]);
int mlkem_hw16_asm(int16_t x);
void mlkem_hw_poly(uint8_t *out, const int16_t *in);
void mlkem_theta_mulshare(int16_t *f0, int16_t *f1, const int16_t *s, const int16_t *u);

void mlkem_ref_ntt(int16_t r[MLKEM_N]);
void mlkem_ref_invntt(int16_t r[MLKEM_N]);

#endif
