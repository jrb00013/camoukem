#include "mlkem_asm.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void mlkem_ref_ntt(int16_t r[MLKEM_N]);
void mlkem_ref_invntt(int16_t r[MLKEM_N]);

static void die(const char *m) { fprintf(stderr, "FAIL %s\n", m); exit(1); }

int main(void) {
    mlkem_poly a, b, c;
    int i;
    for (i = 0; i < MLKEM_N; i++)
        a[i] = (int16_t)((i * 13 + 7) % MLKEM_Q);
    memcpy(b, a, sizeof a);
    memcpy(c, a, sizeof a);
    mlkem_ntt(b);
    mlkem_ref_ntt(c);
    for (i = 0; i < MLKEM_N; i++)
        if (b[i] != c[i]) {
            fprintf(stderr, "mismatch at %d asm=%d ref=%d\n", i, b[i], c[i]);
            die("ntt");
        }
    mlkem_invntt(b);
    /* After invntt, related to original up to mont factors — compare to ref inv */
    memcpy(c, a, sizeof a);
    mlkem_ref_ntt(c);
    mlkem_ref_invntt(c);
    mlkem_ntt(a);
    mlkem_invntt(a);
    for (i = 0; i < MLKEM_N; i++)
        if (a[i] != c[i]) {
            fprintf(stderr, "inv mismatch %d asm=%d ref=%d\n", i, a[i], c[i]);
            die("invntt");
        }
    puts("test_ntt ok");
    return 0;
}
