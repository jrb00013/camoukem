#include "params.inc"
.text
.align 4
.global mlkem_poly_csubq
.type mlkem_poly_csubq, %function
/* a = a - q if a >= q (constant-time NEON) */
mlkem_poly_csubq:
    mov     w1, #256
    mov     w2, #MLKEM_Q
    dup     v3.8h, w2
1:
    ld1     {v0.8h}, [x0]
    cmge    v2.8h, v0.8h, v3.8h
    and     v1.16b, v3.16b, v2.16b
    sub     v0.8h, v0.8h, v1.8h
    st1     {v0.8h}, [x0], #16
    subs    w1, w1, #8
    b.ne    1b
    ret
.size mlkem_poly_csubq, .-mlkem_poly_csubq
