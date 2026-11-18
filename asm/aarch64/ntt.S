#include "params.inc"
.text
.align 4
.global mlkem_ntt
.type mlkem_ntt, %function
/* void mlkem_ntt(int16_t *r) — Kyber forward NTT */
mlkem_ntt:
    stp     x29, x30, [sp, #-80]!
    mov     x29, sp
    stp     x19, x20, [sp, #16]
    stp     x21, x22, [sp, #32]
    stp     x23, x24, [sp, #48]
    stp     x25, x26, [sp, #64]
    mov     x19, x0
    adrp    x20, mlkem_zetas
    add     x20, x20, :lo12:mlkem_zetas
    mov     w21, #1                  /* k */
    mov     w22, #128                /* len */
.Llen:
    mov     w23, #0                  /* start */
.Lstart:
    add     x0, x20, w21, uxtw #1
    ldrsh   w24, [x0]                /* zeta */
    add     w21, w21, #1
    mov     w25, w23                 /* j */
    add     w26, w23, w22            /* start+len */
.Lj:
    /* load r[j+len] */
    add     w0, w25, w22
    add     x1, x19, w0, uxtw #1
    ldrsh   w2, [x1]
    /* t = mont_reduce(zeta * r[j+len]) */
    smull   x3, w24, w2
    mov     w4, #MLKEM_QINV
    uxth    w5, w3
    mul     w5, w5, w4
    sxth    w5, w5
    mov     w6, #MLKEM_Q
    smsubl  x3, w5, w6, x3
    asr     x3, x3, #16
    sxth    w3, w3                   /* t */
    /* r[j] */
    add     x1, x19, w25, uxtw #1
    ldrsh   w7, [x1]
    sub     w8, w7, w3
    add     w9, w7, w3
    sxth    w8, w8
    sxth    w9, w9
    add     w0, w25, w22
    add     x1, x19, w0, uxtw #1
    strh    w8, [x1]
    add     x1, x19, w25, uxtw #1
    strh    w9, [x1]
    add     w25, w25, #1
    cmp     w25, w26
    b.lo    .Lj
    /* start = j + len */
    add     w23, w25, w22
    cmp     w23, #MLKEM_N
    b.lo    .Lstart
    lsr     w22, w22, #1
    cmp     w22, #1
    b.hi    .Llen
    ldp     x19, x20, [sp, #16]
    ldp     x21, x22, [sp, #32]
    ldp     x23, x24, [sp, #48]
    ldp     x25, x26, [sp, #64]
    ldp     x29, x30, [sp], #80
    ret
.size mlkem_ntt, .-mlkem_ntt
