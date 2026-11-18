.text
.align 4
.global mlkem_poly_neg
.type mlkem_poly_neg, %function
mlkem_poly_neg:
    mov     w2, #256
1:
    ld1     {v0.8h}, [x1], #16
    neg     v1.8h, v0.8h
    st1     {v1.8h}, [x0], #16
    subs    w2, w2, #8
    b.ne    1b
    ret
.size mlkem_poly_neg, .-mlkem_poly_neg
