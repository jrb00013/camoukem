.text
.align 4
.global mlkem_poly_copy
.type mlkem_poly_copy, %function
mlkem_poly_copy:
    mov     w2, #256
1:
    ld1     {v0.8h}, [x1], #16
    st1     {v0.8h}, [x0], #16
    subs    w2, w2, #8
    b.ne    1b
    ret
.size mlkem_poly_copy, .-mlkem_poly_copy
