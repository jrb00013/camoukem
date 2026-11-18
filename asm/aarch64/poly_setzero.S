.text
.align 4
.global mlkem_poly_setzero
.type mlkem_poly_setzero, %function
mlkem_poly_setzero:
    movi    v0.8h, #0
    mov     w1, #256
1:
    st1     {v0.8h}, [x0], #16
    subs    w1, w1, #8
    b.ne    1b
    ret
.size mlkem_poly_setzero, .-mlkem_poly_setzero
