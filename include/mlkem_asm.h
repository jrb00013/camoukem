#ifndef MLKEM_ASM_H
#define MLKEM_ASM_H

#include <stdint.h>

#define MLKEM_N 256
#define MLKEM_Q 3329

typedef int16_t mlkem_poly[MLKEM_N];

/* AArch64 NEON kernels — see asm/aarch64/ */
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
void mlkem_basemul(int16_t *r, const int16_t *a, const int16_t *b, int16_t zeta);
void mlkem_spin_mul(int16_t *r, const int16_t *a, int16_t u);
void mlkem_mask_refresh_pair(int16_t *s0, int16_t *s1, const int16_t *noise);

#endif

void mlkem_ref_ntt(int16_t r[MLKEM_N]);
void mlkem_ref_invntt(int16_t r[MLKEM_N]);
