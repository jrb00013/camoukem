/*
 * krivox simulated higher-order SCA board
 * Real AArch64 asm share kernels + HW ADC model + HOCPA with public inputs.
 */
#include "board.h"
#include "hocpa.h"
#include "mlkem_asm.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void mlkem_mask_share_asm(int16_t *s0, int16_t *s1, const int16_t *s, const int16_t *rand);
void mlkem_mask3_share_asm(int16_t *s0, int16_t *s1, int16_t *s2, const int16_t *s,
                           const int16_t *r0, const int16_t *r1);

static void usage(const char *argv0) {
    fprintf(stderr,
            "krivox board_sim — simulated HO masking SCA board\n\n"
            "Usage:\n"
            "  %s [--traces N] [--noise SIGMA] [--seed S]\n\n"
            "See sim/board/circuit.md\n",
            argv0);
}

int main(int argc, char **argv) {
    board_t board;
    int ntraces = 128;
    double noise = 0.35;
    uint32_t seed = 0x27182818u;
    int i;
    uint8_t secret;
    uint8_t *pub = NULL;
    double c_base, c1, c2, c2b;
    int g_base, g1, g2, g2b;

    for (i = 1; i < argc; i++) {
        if (!strcmp(argv[i], "--help") || !strcmp(argv[i], "-h")) {
            usage(argv[0]);
            return 0;
        } else if (!strcmp(argv[i], "--traces") && i + 1 < argc) {
            ntraces = atoi(argv[++i]);
        } else if (!strcmp(argv[i], "--noise") && i + 1 < argc) {
            noise = atof(argv[++i]);
        } else if (!strcmp(argv[i], "--seed") && i + 1 < argc) {
            seed = (uint32_t)strtoul(argv[++i], NULL, 0);
        } else if (!strcmp(argv[i], "--coeffs")) {
            if (i + 1 < argc)
                i++; /* ignore legacy flag */
        } else {
            usage(argv[0]);
            return 1;
        }
    }
    if (ntraces < 16)
        ntraces = 16;
    if (ntraces > BOARD_MAX_TRACES)
        ntraces = BOARD_MAX_TRACES;

    board_init(&board, noise, seed);
    secret = (uint8_t)(board_rng_u32(&board) & 0xff);
    pub = calloc((size_t)ntraces, 1);
    if (!pub)
        return 1;

    printf("krivox board_sim\n");
    printf("  traces=%d noise=%.2f seed=0x%x secret=0x%02x\n", ntraces, noise, seed, secret);
    printf("  model: v = secret XOR pub[i]; leak shares of v via asm masking\n");
    printf("  circuit: sim/board/circuit.md\n\n");

    /* -------- baseline: unmasked HW(v) -------- */
    board_reset_traces(&board);
    for (i = 0; i < ntraces; i++) {
        board_trace_t *tr = &board.traces[i];
        uint8_t v;
        memset(tr, 0, sizeof(*tr));
        pub[i] = (uint8_t)(board_rng_u32(&board) & 0xff);
        v = (uint8_t)(secret ^ pub[i]);
        tr->trigger_start = 0;
        board_emit_hw(&board, tr, (int16_t)v);
        tr->trigger_end = tr->n_samples;
        board.n_traces++;
    }
    g_base = hocpa_rank_order1_pub(&board, pub, 0, 256, 1, &c_base);
    printf("[unmasked baseline]\n");
    printf("  CPA order-1: best=0x%02x |corr|=%.4f  %s\n\n", g_base, c_base,
           g_base == secret ? "MATCH" : "miss");

    /* -------- order-1 mask (2 shares) via asm -------- */
    board_reset_traces(&board);
    for (i = 0; i < ntraces; i++) {
        mlkem_poly s, r, s0, s1;
        board_trace_t *tr = &board.traces[i];
        uint8_t v = (uint8_t)(secret ^ pub[i]);
        memset(tr, 0, sizeof(*tr));
        memset(s, 0, sizeof s);
        memset(r, 0, sizeof r);
        s[0] = (int16_t)v;
        r[0] = (int16_t)(board_rng_u32(&board) & 0xff);
        mlkem_mask_share_asm(s0, s1, s, r);
        tr->trigger_start = 0;
        board_emit_hw(&board, tr, s0[0]); /* poi 0 */
        board_emit_hw(&board, tr, s1[0]); /* poi 1 */
        tr->trigger_end = tr->n_samples;
        board.n_traces++;
    }
    g1 = hocpa_rank_order1_pub(&board, pub, 0, 256, 1, &c1);
    g2 = hocpa_rank_order2_pub(&board, pub, 0, 1, 256, 1, &c2);
    printf("[order-1 mask / 2-share asm]\n");
    printf("  CPA  on share0:  best=0x%02x |corr|=%.4f  %s\n", g1, c1,
           g1 == secret ? "MATCH" : "miss (expected)");
    printf("  HOCPA share0×1:  best=0x%02x |corr|=%.4f  %s\n\n", g2, c2,
           g2 == secret ? "MATCH" : "miss");

    /* -------- order-2 mask (3 shares) via asm -------- */
    board_reset_traces(&board);
    for (i = 0; i < ntraces; i++) {
        mlkem_poly s, r0, r1, s0, s1, s2;
        board_trace_t *tr = &board.traces[i];
        uint8_t v = (uint8_t)(secret ^ pub[i]);
        memset(tr, 0, sizeof(*tr));
        memset(s, 0, sizeof s);
        memset(r0, 0, sizeof r0);
        memset(r1, 0, sizeof r1);
        s[0] = (int16_t)v;
        r0[0] = (int16_t)(board_rng_u32(&board) & 0xff);
        r1[0] = (int16_t)(board_rng_u32(&board) & 0xff);
        mlkem_mask3_share_asm(s0, s1, s2, s, r0, r1);
        board_emit_hw(&board, tr, s0[0]);
        board_emit_hw(&board, tr, s1[0]);
        board_emit_hw(&board, tr, s2[0]);
        board.n_traces++;
    }
    g1 = hocpa_rank_order1_pub(&board, pub, 0, 256, 1, &c1);
    g2 = hocpa_rank_order2_pub(&board, pub, 0, 1, 256, 1, &c2);
    g2b = hocpa_rank_order2_pub(&board, pub, 0, 2, 256, 1, &c2b);
    printf("[order-2 mask / 3-share asm]\n");
    printf("  CPA  on share0:  best=0x%02x |corr|=%.4f  %s\n", g1, c1,
           g1 == secret ? "MATCH" : "miss (expected)");
    printf("  HOCPA 0×1:       best=0x%02x |corr|=%.4f  %s\n", g2, c2,
           g2 == secret ? "MATCH" : "miss");
    printf("  HOCPA 0×2:       best=0x%02x |corr|=%.4f  %s\n\n", g2b, c2b,
           g2b == secret ? "MATCH" : "miss");

    printf("OK — full simulated shunt/ADC board exercised real krivox asm.\n");
    free(pub);
    return 0;
}
