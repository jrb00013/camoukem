#ifndef KRIVOX_BOARD_H
#define KRIVOX_BOARD_H

#include <stdint.h>
#include <stddef.h>

#define BOARD_N 256
#define BOARD_MAX_TRACES 256
#define BOARD_MAX_SAMPLES 4096

typedef struct {
    int16_t samples[BOARD_MAX_SAMPLES];
    int n_samples;
    int trigger_start;
    int trigger_end;
} board_trace_t;

typedef struct {
    board_trace_t traces[BOARD_MAX_TRACES];
    int n_traces;
    double noise_sigma;
    uint32_t rng;
} board_t;

void board_init(board_t *b, double noise_sigma, uint32_t seed);
void board_reset_traces(board_t *b);
void board_emit_hw(board_t *b, board_trace_t *tr, int16_t word);
void board_emit_poly(board_t *b, board_trace_t *tr, const int16_t *poly, int max_coeffs);
uint32_t board_rng_u32(board_t *b);
int16_t board_rng_coef(board_t *b);

#endif
