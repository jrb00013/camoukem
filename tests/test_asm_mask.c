#include "mlkem_asm.h"
#include <stdio.h>
#include <stdlib.h>

void mlkem_mask_share_asm(int16_t *s0, int16_t *s1, const int16_t *s, const int16_t *rand);
void mlkem_mask_unshare_asm(int16_t *out, const int16_t *s0, const int16_t *s1);
void mlkem_mask3_share_asm(int16_t *s0, int16_t *s1, int16_t *s2, const int16_t *s,
                           const int16_t *r0, const int16_t *r1);
void mlkem_mask3_unshare_asm(int16_t *out, const int16_t *s0, const int16_t *s1, const int16_t *s2);

static void die(const char *m) { fprintf(stderr, "FAIL %s\n", m); exit(1); }

int main(void) {
    mlkem_poly s, r, r1, s0, s1, s2, out;
    int i;
    for (i = 0; i < MLKEM_N; i++) {
        s[i] = (int16_t)((i * 3) % MLKEM_Q);
        r[i] = (int16_t)((i * 7 + 1) % MLKEM_Q);
        r1[i] = (int16_t)((i * 11 + 5) % MLKEM_Q);
    }
    mlkem_mask_share_asm(s0, s1, s, r);
    mlkem_mask_unshare_asm(out, s0, s1);
    mlkem_poly_reduce(out);
    mlkem_poly_csubq(out);
    for (i = 0; i < MLKEM_N; i++) {
        int16_t a = (int16_t)((out[i] % MLKEM_Q + MLKEM_Q) % MLKEM_Q);
        int16_t b = (int16_t)((s[i] % MLKEM_Q + MLKEM_Q) % MLKEM_Q);
        if (a != b) die("o1");
    }
    mlkem_mask3_share_asm(s0, s1, s2, s, r, r1);
    mlkem_mask3_unshare_asm(out, s0, s1, s2);
    mlkem_poly_reduce(out);
    mlkem_poly_csubq(out);
    for (i = 0; i < MLKEM_N; i++) {
        int16_t a = (int16_t)((out[i] % MLKEM_Q + MLKEM_Q) % MLKEM_Q);
        int16_t b = (int16_t)((s[i] % MLKEM_Q + MLKEM_Q) % MLKEM_Q);
        if (a != b) die("o2");
    }
    puts("test_asm_mask ok");
    return 0;
}
