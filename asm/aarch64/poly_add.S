.text
.align 4
.global mlkem_poly_add
.type mlkem_poly_add, %function
/* void mlkem_poly_add(int16_t *r, const int16_t *a, const int16_t *b) */
mlkem_poly_add:
    mov     w3, #256
1:
    ld1     {v0.8h}, [x1], #16
    ld1     {v1.8h}, [x2], #16
    add     v2.8h, v0.8h, v1.8h
    st1     {v2.8h}, [x0], #16
    subs    w3, w3, #8
    b.ne    1b
    ret
.size mlkem_poly_add, .-mlkem_poly_add
