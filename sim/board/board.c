#include "board.h"
#include <math.h>
#include <string.h>

static int popcount16(uint16_t x) {
    int c = 0;
    while (x) {
        c += x & 1;
        x >>= 1;
    }
    return c;
}

/* Simple xorshift */
uint32_t board_rng_u32(board_t *b) {
    uint32_t x = b->rng;
    x ^= x << 13;
    x ^= x >> 17;
    x ^= x << 5;
    b->rng = x ? x : 0xA5A5A5A5u;
    return b->rng;
}

int16_t board_rng_coef(board_t *b) {
    return (int16_t)(board_rng_u32(b) % 3329);
}

void board_init(board_t *b, double noise_sigma, uint32_t seed) {
    memset(b, 0, sizeof(*b));
    b->noise_sigma = noise_sigma;
    b->rng = seed ? seed : 1u;
}

void board_reset_traces(board_t *b) {
    b->n_traces = 0;
}

/* Box-Muller using board RNG */
static double board_gauss(board_t *b) {
    double u1 = (board_rng_u32(b) + 1.0) / 4294967296.0;
    double u2 = (board_rng_u32(b) + 1.0) / 4294967296.0;
    return sqrt(-2.0 * log(u1)) * cos(2.0 * 3.14159265358979323846 * u2);
}

void board_emit_hw(board_t *b, board_trace_t *tr, int16_t word) {
    if (tr->n_samples >= BOARD_MAX_SAMPLES)
        return;
    double v = (double)popcount16((uint16_t)word);
    v += board_gauss(b) * b->noise_sigma;
    if (v > 32767)
        v = 32767;
    if (v < -32768)
        v = -32768;
    tr->samples[tr->n_samples++] = (int16_t)lround(v);
}

void board_emit_poly(board_t *b, board_trace_t *tr, const int16_t *poly, int max_coeffs) {
    int i;
    int n = max_coeffs < BOARD_N ? max_coeffs : BOARD_N;
    for (i = 0; i < n; i++)
        board_emit_hw(b, tr, poly[i]);
}
