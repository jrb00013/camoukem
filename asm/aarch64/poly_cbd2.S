#include "params.inc"
.text
.align 4
.global mlkem_poly_cbd2
.type mlkem_poly_cbd2, %function
/* void mlkem_poly_cbd2(int16_t r[256], const uint8_t buf[128])
   CBD eta=2 from Kyber. */
mlkem_poly_cbd2:
    mov     w2, #0                   /* i coeff pairs from bytes */
    mov     w3, #0                   /* coeff index */
1:
    ldrb    w4, [x1, w2, uxtw]
    /* expand 8 bits -> 4 coeffs? actually 2 bits per sample, 4 samples/byte? 
       Kyber CBD2: 2 bytes -> 4 coeffs? No — load 4 bytes for 8 coeffs typically.
       Use 2-bit nibbles: for each byte, 4 coeffs of eta=2 via bit pairs. */
    mov     w5, #0
2:
    lsr     w6, w4, w5
    and     w7, w6, #1
    lsr     w8, w6, #1
    and     w8, w8, #1
    add     w7, w7, w8               /* a */
    lsr     w8, w6, #2
    and     w9, w8, #1
    lsr     w10, w6, #3
    and     w10, w10, #1
    add     w9, w9, w10              /* b */
    sub     w7, w7, w9
    sxth    w7, w7
    strh    w7, [x0, w3, uxtw #1]
    add     w3, w3, #1
    add     w5, w5, #4
    cmp     w5, #8
    b.lo    2b
    add     w2, w2, #1
    cmp     w3, #MLKEM_N
    b.lo    1b
    ret
.size mlkem_poly_cbd2, .-mlkem_poly_cbd2
