#include "mlkem_mask.h"

void mlkem_mask_share(mlkem_masked_poly *out, const int16_t *s, const int16_t *rand_poly) {
    mlkem_poly_copy(out->s0, rand_poly);
    mlkem_poly_sub(out->s1, s, rand_poly);
    mlkem_poly_reduce(out->s0);
    mlkem_poly_reduce(out->s1);
    mlkem_poly_csubq(out->s0);
    mlkem_poly_csubq(out->s1);
}

void mlkem_mask_unshare(int16_t *out, const mlkem_masked_poly *in) {
    mlkem_poly_add(out, in->s0, in->s1);
    mlkem_poly_reduce(out);
    mlkem_poly_csubq(out);
}

void mlkem_mask_poly_add(mlkem_masked_poly *r, const mlkem_masked_poly *a, const mlkem_masked_poly *b) {
    mlkem_poly_add(r->s0, a->s0, b->s0);
    mlkem_poly_add(r->s1, a->s1, b->s1);
    mlkem_poly_reduce(r->s0);
    mlkem_poly_reduce(r->s1);
}

void mlkem_mask_poly_ntt(mlkem_masked_poly *a) {
    mlkem_ntt(a->s0);
    mlkem_ntt(a->s1);
}
