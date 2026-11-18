.text
.align 4
.global mlkem_poly_tobytes
.type mlkem_poly_tobytes, %function
/* void mlkem_poly_tobytes(uint8_t r[384], const int16_t a[256]) */
mlkem_poly_tobytes:
    mov     w2, #128
1:
    ldrsh   w3, [x1], #2
    ldrsh   w4, [x1], #2
    /* assume already [0,q) */
    strb    w3, [x0], #1
    lsr     w5, w3, #8
    and     w6, w4, #0x0f
    orr     w5, w5, w6, lsl #4
    strb    w5, [x0], #1
    lsr     w5, w4, #4
    strb    w5, [x0], #1
    subs    w2, w2, #1
    b.ne    1b
    ret
.size mlkem_poly_tobytes, .-mlkem_poly_tobytes
