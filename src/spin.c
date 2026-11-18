#include "mlkem_asm.h"

/* θ-gauge: r = reduce(u * a). Asm does mul; we reduce. */
void mlkem_spin_apply(int16_t *r, const int16_t *a, int16_t u) {
    mlkem_spin_mul(r, a, u);
    mlkem_poly_reduce(r);
    mlkem_poly_csubq(r);
}
