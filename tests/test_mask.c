#include "mlkem_mask.h"
#include <stdio.h>
#include <stdlib.h>

static void die(const char *m) { fprintf(stderr, "FAIL %s\n", m); exit(1); }

int main(void) {
    mlkem_poly s, r, out;
    mlkem_masked_poly m;
    int i;
    for (i = 0; i < MLKEM_N; i++) {
        s[i] = (int16_t)((i * 5) % MLKEM_Q);
        r[i] = (int16_t)((i * 11 + 2) % MLKEM_Q);
    }
    mlkem_mask_share(&m, s, r);
    mlkem_mask_unshare(out, &m);
    for (i = 0; i < MLKEM_N; i++) {
        int16_t expect = (int16_t)((s[i] % MLKEM_Q + MLKEM_Q) % MLKEM_Q);
        int16_t got = (int16_t)((out[i] % MLKEM_Q + MLKEM_Q) % MLKEM_Q);
        if (got != expect) die("unshare");
    }
    puts("test_mask ok");
    return 0;
}
