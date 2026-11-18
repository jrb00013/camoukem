.text
.align 4
.global mlkem_cmov
.type mlkem_cmov, %function
/* void mlkem_cmov(uint8_t *r, const uint8_t *x, size_t len, uint8_t b)
   Constant-time: if b==1 copy x->r else leave r. b must be 0 or 1. */
mlkem_cmov:
    /* w3 = b */
    neg     w3, w3                   /* 0 -> 0; 1 -> 0xFFFFFFFF */
    cbz     x2, 2f
1:
    ldrb    w4, [x0]
    ldrb    w5, [x1], #1
    eor     w5, w5, w4
    and     w5, w5, w3
    eor     w4, w4, w5
    strb    w4, [x0], #1
    subs    x2, x2, #1
    b.ne    1b
2:
    ret
.size mlkem_cmov, .-mlkem_cmov
