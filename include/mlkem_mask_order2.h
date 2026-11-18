#ifndef MLKEM_MASK_ORDER2_H
#define MLKEM_MASK_ORDER2_H
#include "mlkem_asm.h"
typedef struct { mlkem_poly s0,s1,s2; } mlkem_masked3_poly;
void mlkem_mask3_share(mlkem_masked3_poly *out, const int16_t *s, const int16_t *r0, const int16_t *r1);
#endif
