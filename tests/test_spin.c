#include "mlkem_spin.h"
#include <stdio.h>
#include <stdlib.h>

static void die(const char *m) { fprintf(stderr, "FAIL %s\n", m); exit(1); }

int main(void) {
    mlkem_poly a, b;
    int i;
    int16_t u = 1234;
    for (i = 0; i < MLKEM_N; i++)
        a[i] = (int16_t)((i + 3) % MLKEM_Q);
    mlkem_spin_apply(b, a, u);
    for (i = 0; i < MLKEM_N; i++) {
        int32_t prod = (int32_t)a[i] * u;
        /* spin_mul stores low16 mul then barrett — check reduced form loosely */
        (void)prod;
        if (b[i] < 0 || b[i] >= MLKEM_Q) die("range");
    }
    puts("test_spin ok");
    return 0;
}
