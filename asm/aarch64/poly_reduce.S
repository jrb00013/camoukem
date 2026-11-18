#include "params.inc"
.text
.align 4
.global mlkem_poly_reduce
.type mlkem_poly_reduce, %function
/* Barrett-style reduce each coeff into [0,q) approx then finalize with csubq path.
   For each h: r = a - ((a * 20159) >> 26) * q  (Kyber barrett constant 20159) */
mlkem_poly_reduce:
    mov     w1, #256
    mov     w2, #20159
    mov     w3, #MLKEM_Q
    dup     v4.8h, w2
    dup     v5.8h, w3
1:
    ld1     {v0.8h}, [x0]
    smull   v1.4s, v0.4h, v4.4h
    smull2  v2.4s, v0.8h, v4.8h
    sshr    v1.4s, v1.4s, #26
    sshr    v2.4s, v2.4s, #26
    xtn     v1.4h, v1.4s
    xtn2    v1.8h, v2.4s
    mls     v0.8h, v1.8h, v5.8h
    st1     {v0.8h}, [x0], #16
    subs    w1, w1, #8
    b.ne    1b
    ret
.size mlkem_poly_reduce, .-mlkem_poly_reduce
