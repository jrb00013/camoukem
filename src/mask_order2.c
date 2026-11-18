#include "mlkem_mask_order2.h"
void mlkem_mask3_share(mlkem_masked3_poly *out, const int16_t *s, const int16_t *r0, const int16_t *r1){
 mlkem_poly_copy(out->s0,r0); mlkem_poly_copy(out->s1,r1);
 mlkem_poly_sub(out->s2,s,r0); mlkem_poly_sub(out->s2,out->s2,r1);
 mlkem_poly_reduce(out->s0); mlkem_poly_reduce(out->s1); mlkem_poly_reduce(out->s2);
}
