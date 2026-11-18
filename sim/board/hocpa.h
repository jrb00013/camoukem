#ifndef MASKLAMP_HOCPA_H
#define MASKLAMP_HOCPA_H

#include "board.h"
#include <stdint.h>

/* hyp_op: 0 = (hyp + pub) & 0xff, 1 = hyp ^ pub */
double hocpa_order1_pub(const board_t *b, const uint8_t *pub, int poi, int hyp, int hyp_op);
double hocpa_order2_pub(const board_t *b, const uint8_t *pub, int poi0, int poi1, int hyp,
                        int hyp_op);
int hocpa_rank_order1_pub(const board_t *b, const uint8_t *pub, int poi, int hyp_max, int hyp_op,
                          double *best_corr);
int hocpa_rank_order2_pub(const board_t *b, const uint8_t *pub, int poi0, int poi1, int hyp_max,
                          int hyp_op, double *best_corr);

#endif
