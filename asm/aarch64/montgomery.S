#include "params.inc"
.text
.align 4
.global mlkem_poly_tomont
.type mlkem_poly_tomont, %function
/* Convert poly to Montgomery domain: a -> a * MONT mod q (NEON lane-wise). */
mlkem_poly_tomont:
    mov     w1, #256
    mov     w2, #MLKEM_MONT
    mov     w3, #MLKEM_QINV
    mov     w4, #MLKEM_Q
    dup     v4.8h, w2
    dup     v5.8h, w3
    dup     v6.8h, w4
1:
    ld1     {v0.8h}, [x0]
    /* t = (int32)a * MONT; m = (int16)t * QINV; t = t + (int32)m * Q; r = t >> 16 */
    smull   v1.4s, v0.4h, v4.4h
    smull2  v2.4s, v0.8h, v4.8h
    xtn     v7.4h, v1.4s
    xtn2    v7.8h, v2.4s
    mul     v7.8h, v7.8h, v5.8h
    smlal   v1.4s, v7.4h, v6.4h
    smlal2  v2.4s, v7.8h, v6.8h
    sshr    v1.4s, v1.4s, #16
    sshr    v2.4s, v2.4s, #16
    xtn     v0.4h, v1.4s
    xtn2    v0.8h, v2.4s
    st1     {v0.8h}, [x0], #16
    subs    w1, w1, #8
    b.ne    1b
    ret
.size mlkem_poly_tomont, .-mlkem_poly_tomont
