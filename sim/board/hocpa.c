#include "board.h"
#include "hocpa.h"
#include <math.h>
#include <stdlib.h>

static int popcount16(uint16_t x) {
    int c = 0;
    while (x) {
        c += x & 1;
        x >>= 1;
    }
    return c;
}

static double pearson(const double *x, const double *y, int n) {
    double sx = 0, sy = 0, sxx = 0, syy = 0, sxy = 0;
    int i;
    for (i = 0; i < n; i++) {
        sx += x[i];
        sy += y[i];
    }
    sx /= n;
    sy /= n;
    for (i = 0; i < n; i++) {
        double dx = x[i] - sx;
        double dy = y[i] - sy;
        sxx += dx * dx;
        syy += dy * dy;
        sxy += dx * dy;
    }
    if (sxx <= 1e-12 || syy <= 1e-12)
        return 0;
    return sxy / sqrt(sxx * syy);
}

/* Order-1 CPA: x = leakage[poi], y = HW(hyp OP pub[i]) — pub must vary */
double hocpa_order1_pub(const board_t *b, const uint8_t *pub, int poi, int hyp, int hyp_op) {
    int n = b->n_traces;
    double *x = calloc((size_t)n, sizeof(double));
    double *y = calloc((size_t)n, sizeof(double));
    int i;
    double corr;
    if (!x || !y) {
        free(x);
        free(y);
        return 0;
    }
    for (i = 0; i < n; i++) {
        uint8_t v;
        x[i] = b->traces[i].samples[poi];
        if (hyp_op == 0)
            v = (uint8_t)((hyp + pub[i]) & 0xff); /* add */
        else
            v = (uint8_t)(hyp ^ pub[i]); /* xor */
        y[i] = (double)popcount16(v);
    }
    corr = pearson(x, y, n);
    free(x);
    free(y);
    return corr;
}

/* Order-2: centered product of two POIs vs HW(hyp OP pub) */
double hocpa_order2_pub(const board_t *b, const uint8_t *pub, int poi0, int poi1, int hyp,
                        int hyp_op) {
    int n = b->n_traces;
    double *x = calloc((size_t)n, sizeof(double));
    double *y = calloc((size_t)n, sizeof(double));
    double mean0 = 0, mean1 = 0;
    int i;
    double corr;
    if (!x || !y) {
        free(x);
        free(y);
        return 0;
    }
    for (i = 0; i < n; i++) {
        mean0 += b->traces[i].samples[poi0];
        mean1 += b->traces[i].samples[poi1];
    }
    mean0 /= n;
    mean1 /= n;
    for (i = 0; i < n; i++) {
        uint8_t v;
        double a = b->traces[i].samples[poi0] - mean0;
        double c = b->traces[i].samples[poi1] - mean1;
        x[i] = a * c;
        if (hyp_op == 0)
            v = (uint8_t)((hyp + pub[i]) & 0xff);
        else
            v = (uint8_t)(hyp ^ pub[i]);
        y[i] = (double)popcount16(v);
    }
    corr = pearson(x, y, n);
    free(x);
    free(y);
    return corr;
}

int hocpa_rank_order1_pub(const board_t *b, const uint8_t *pub, int poi, int hyp_max, int hyp_op,
                          double *best_corr) {
    int h, best_h = -1;
    double best = -1;
    for (h = 0; h < hyp_max; h++) {
        double c = fabs(hocpa_order1_pub(b, pub, poi, h, hyp_op));
        if (c > best) {
            best = c;
            best_h = h;
        }
    }
    if (best_corr)
        *best_corr = best;
    return best_h;
}

int hocpa_rank_order2_pub(const board_t *b, const uint8_t *pub, int poi0, int poi1, int hyp_max,
                          int hyp_op, double *best_corr) {
    int h, best_h = -1;
    double best = -1;
    for (h = 0; h < hyp_max; h++) {
        double c = fabs(hocpa_order2_pub(b, pub, poi0, poi1, h, hyp_op));
        if (c > best) {
            best = c;
            best_h = h;
        }
    }
    if (best_corr)
        *best_corr = best;
    return best_h;
}
