.text
.align 4
.global mlkem_hw16_asm
.type mlkem_hw16_asm, %function
/* int mlkem_hw16_asm(int16_t x) — Hamming weight for sim-HOCPA */
mlkem_hw16_asm:
    and     w0, w0, #0xffff
    /* CNT instruction on AArch64 for set bits in 32-bit */
    fmov    s0, w0
    /* use generic loop for portability across assemblers */
    mov     w1, #0
1:
    cbz     w0, 2f
    and     w2, w0, #1
    add     w1, w1, w2
    lsr     w0, w0, #1
    b       1b
2:
    mov     w0, w1
    ret
.size mlkem_hw16_asm, .-mlkem_hw16_asm

.global mlkem_hw_poly
.type mlkem_hw_poly, %function
/* void mlkem_hw_poly(uint8_t out[256], const int16_t in[256]) */
mlkem_hw_poly:
    mov     w2, #0
1:
    ldrsh   w3, [x1, w2, uxtw #1]
    and     w3, w3, #0xffff
    mov     w4, #0
    mov     w5, w3
2:
    cbz     w5, 3f
    and     w6, w5, #1
    add     w4, w4, w6
    lsr     w5, w5, #1
    b       2b
3:
    strb    w4, [x0, w2, uxtw]
    add     w2, w2, #1
    cmp     w2, #256
    b.lo    1b
    ret
.size mlkem_hw_poly, .-mlkem_hw_poly
