#include "params.inc"
.text
.align 4
.global mlkem_basemul
.type mlkem_basemul, %function
/* void mlkem_basemul(int16_t *r, const int16_t *a, const int16_t *b, int16_t zeta)
   r[0]=a0*b1+a1*b0; r[0]=fqmul(r[0],zeta) wait — Kyber:
   r[0] = fqmul(a[1], b[1]); r[0] = fqmul(r[0], zeta); r[0] += fqmul(a[0], b[0]);
   r[1] = fqmul(a[0], b[1]); r[1] += fqmul(a[1], b[0]);
*/
mlkem_basemul:
    /* w3 = zeta */
    ldrsh   w4, [x1]          /* a0 */
    ldrsh   w5, [x1, #2]      /* a1 */
    ldrsh   w6, [x2]          /* b0 */
    ldrsh   w7, [x2, #2]      /* b1 */
    /* fqmul helper inline macro-ish */
    /* t = fqmul(a1,b1) */
    smull   x9, w5, w7
    mov     w10, #MLKEM_QINV
    uxth    w11, w9
    mul     w11, w11, w10
    sxth    w11, w11
    mov     w12, #MLKEM_Q
    smsubl  x9, w11, w12, x9
    asr     x9, x9, #16
    sxth    w9, w9
    /* fqmul(t, zeta) */
    smull   x9, w9, w3
    uxth    w11, w9
    mul     w11, w11, w10
    sxth    w11, w11
    smsubl  x9, w11, w12, x9
    asr     x9, x9, #16
    sxth    w9, w9
    /* + fqmul(a0,b0) */
    smull   x13, w4, w6
    uxth    w11, w13
    mul     w11, w11, w10
    sxth    w11, w11
    smsubl  x13, w11, w12, x13
    asr     x13, x13, #16
    sxth    w13, w13
    add     w9, w9, w13
    sxth    w9, w9
    strh    w9, [x0]
    /* r1 = fqmul(a0,b1)+fqmul(a1,b0) */
    smull   x9, w4, w7
    uxth    w11, w9
    mul     w11, w11, w10
    sxth    w11, w11
    smsubl  x9, w11, w12, x9
    asr     x9, x9, #16
    sxth    w9, w9
    smull   x13, w5, w6
    uxth    w11, w13
    mul     w11, w11, w10
    sxth    w11, w11
    smsubl  x13, w11, w12, x13
    asr     x13, x13, #16
    sxth    w13, w13
    add     w9, w9, w13
    sxth    w9, w9
    strh    w9, [x0, #2]
    ret
.size mlkem_basemul, .-mlkem_basemul
