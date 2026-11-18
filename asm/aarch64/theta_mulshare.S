#include "params.inc"
.text
.align 4
.global mlkem_theta_mulshare
.type mlkem_theta_mulshare, %function
/* void mlkem_theta_mulshare(int16_t *f0, int16_t *f1,
 *                           const int16_t *s, const int16_t *u_poly)
 * Multiplicative 2-share (θ-gauge): f0=u, f1=s*u^{-1} mod q (u!=0). */
mlkem_theta_mulshare:
    mov     w4, #0
1:
    ldrsh   w5, [x2, w4, uxtw #1]
    ldrsh   w6, [x3, w4, uxtw #1]
    cbz     w6, .Lzero
    strh    w6, [x0, w4, uxtw #1]
    /* inv = u^(q-2) mod q via binary exp with udiv reduction */
    mov     w7, w6                   /* base */
    mov     w8, #3327                /* exp */
    mov     w9, #1                   /* result */
.Lpow:
    tst     w8, #1
    beq     .Lsq
    mul     w10, w9, w7
    mov     w12, #MLKEM_Q
    udiv    w11, w10, w12
    msub    w9, w11, w12, w10
.Lsq:
    mul     w10, w7, w7
    mov     w12, #MLKEM_Q
    udiv    w11, w10, w12
    msub    w7, w11, w12, w10
    lsr     w8, w8, #1
    cbnz    w8, .Lpow
    mul     w10, w5, w9
    mov     w12, #MLKEM_Q
    udiv    w11, w10, w12
    msub    w10, w11, w12, w10
    strh    w10, [x1, w4, uxtw #1]
    b       .Lnext
.Lzero:
    mov     w6, #1
    strh    w6, [x0, w4, uxtw #1]
    strh    w5, [x1, w4, uxtw #1]
.Lnext:
    add     w4, w4, #1
    cmp     w4, #MLKEM_N
    b.lo    1b
    ret
.size mlkem_theta_mulshare, .-mlkem_theta_mulshare
