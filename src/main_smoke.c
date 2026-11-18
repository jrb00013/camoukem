#include "mlkem_asm.h"
#include "mlkem_mask.h"
#include "mlkem_spin.h"
#include <stdio.h>

int main(void) {
    mlkem_poly a, b, c, z;
    mlkem_masked_poly ma, mb, mc;
    int i;
    for (i = 0; i < MLKEM_N; i++) {
        a[i] = (int16_t)(i % MLKEM_Q);
        b[i] = (int16_t)((3 * i) % MLKEM_Q);
        z[i] = (int16_t)((7 * i + 1) % MLKEM_Q);
    }
    mlkem_poly_add(c, a, b);
    mlkem_poly_reduce(c);
    mlkem_mask_share(&ma, a, z);
    mlkem_mask_share(&mb, b, z);
    mlkem_mask_poly_add(&mc, &ma, &mb);
    mlkem_mask_unshare(c, &mc);
    mlkem_spin_apply(c, a, 5);
    puts("smoke ok");
    return 0;
}
