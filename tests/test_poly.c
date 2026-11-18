#include "mlkem_asm.h"
#include <stdio.h>
#include <stdlib.h>

static void die(const char *m) { fprintf(stderr, "FAIL %s\n", m); exit(1); }

int main(void) {
    mlkem_poly a, b, c, d;
    int i;
    for (i = 0; i < MLKEM_N; i++) {
        a[i] = (int16_t)((i * 17) % MLKEM_Q);
        b[i] = (int16_t)((i * 9 + 3) % MLKEM_Q);
    }
    mlkem_poly_add(c, a, b);
    for (i = 0; i < MLKEM_N; i++)
        if ((int16_t)(a[i] + b[i]) != c[i]) die("add");
    mlkem_poly_sub(d, c, b);
    for (i = 0; i < MLKEM_N; i++)
        if (d[i] != a[i]) die("sub");
    mlkem_poly_setzero(c);
    for (i = 0; i < MLKEM_N; i++)
        if (c[i] != 0) die("zero");
    mlkem_poly_copy(c, a);
    mlkem_poly_neg(d, a);
    for (i = 0; i < MLKEM_N; i++)
        if (d[i] != (int16_t)(-a[i])) die("neg");
    puts("test_poly ok");
    return 0;
}
