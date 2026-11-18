#ifndef MLKEM_MASK_H
#define MLKEM_MASK_H

#include "mlkem_asm.h"

/* Order-1 arithmetic shares: s ≡ s0 + s1 (mod q) */
typedef struct {
    mlkem_poly s0;
    mlkem_poly s1;
} mlkem_masked_poly;

void mlkem_mask_share(mlkem_masked_poly *out, const int16_t *s, const int16_t *rand_poly);
void mlkem_mask_unshare(int16_t *out, const mlkem_masked_poly *in);
void mlkem_mask_poly_add(mlkem_masked_poly *r, const mlkem_masked_poly *a, const mlkem_masked_poly *b);
void mlkem_mask_poly_ntt(mlkem_masked_poly *a);

#endif
