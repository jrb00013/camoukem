.text
.align 4
.global mlkem_poly_frombytes
.type mlkem_poly_frombytes, %function
/* void mlkem_poly_frombytes(int16_t r[256], const uint8_t a[384])
   Kyber poly_frombytes: 3 bytes -> 2 coeffs */
mlkem_poly_frombytes:
    mov     w2, #128                 /* 128 pairs */
1:
    ldrb    w3, [x1], #1
    ldrb    w4, [x1], #1
    ldrb    w5, [x1], #1
    /* r0 = a0 | ((a1 & 0x0f) << 8) */
    and     w6, w4, #0x0f
    orr     w6, w3, w6, lsl #8
    sxth    w6, w6
    strh    w6, [x0], #2
    /* r1 = (a1 >> 4) | (a2 << 4) */
    lsr     w6, w4, #4
    orr     w6, w6, w5, lsl #4
    sxth    w6, w6
    strh    w6, [x0], #2
    subs    w2, w2, #1
    b.ne    1b
    ret
.size mlkem_poly_frombytes, .-mlkem_poly_frombytes
