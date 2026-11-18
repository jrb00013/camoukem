#include "params.inc"
.text
.align 4
.global mlkem_poly_compress_d4
.type mlkem_poly_compress_d4, %function
/* void mlkem_poly_compress_d4(uint8_t r[128], const int16_t a[256])
   4-bit compress (ML-KEM-512 style helper; research). */
mlkem_poly_compress_d4:
    mov     w2, #128
    mov     w3, #MLKEM_Q
1:
    ldrsh   w4, [x1], #2
    ldrsh   w5, [x1], #2
    /* round(u * 16 / q) = ((u << 4) + q/2) / q */
    lsl     w6, w4, #4
    add     w6, w6, w3, lsr #1
    udiv    w6, w6, w3
    and     w6, w6, #0x0f
    lsl     w7, w5, #4
    add     w7, w7, w3, lsr #1
    udiv    w7, w7, w3
    and     w7, w7, #0x0f
    orr     w6, w6, w7, lsl #4
    strb    w6, [x0], #1
    subs    w2, w2, #1
    b.ne    1b
    ret
.size mlkem_poly_compress_d4, .-mlkem_poly_compress_d4
