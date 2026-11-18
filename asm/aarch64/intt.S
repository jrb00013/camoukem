#include "params.inc"
.text
.align 4
.global mlkem_invntt
.type mlkem_invntt, %function
/* void mlkem_invntt(int16_t *r) — Kyber inverse NTT */
mlkem_invntt:
    stp     x29, x30, [sp, #-80]!
    mov     x29, sp
    stp     x19, x20, [sp, #16]
    stp     x21, x22, [sp, #32]
    stp     x23, x24, [sp, #48]
    stp     x25, x26, [sp, #64]
    mov     x19, x0
    adrp    x20, mlkem_zetas
    add     x20, x20, :lo12:mlkem_zetas
    mov     w21, #127                /* k */
    mov     w22, #2                  /* len */
.Llen:
    mov     w23, #0
.Lstart:
    add     x0, x20, w21, uxtw #1
    ldrsh   w24, [x0]
    sub     w21, w21, #1
    mov     w25, w23
    add     w26, w23, w22
.Lj:
    add     x1, x19, w25, uxtw #1
    ldrsh   w7, [x1]                 /* t = r[j] */
    add     w0, w25, w22
    add     x2, x19, w0, uxtw #1
    ldrsh   w8, [x2]                 /* r[j+len] */
    add     w9, w7, w8               /* t + r[j+len] */
    sxth    w9, w9
    /* barrett_reduce(w9) */
    mov     w3, #20159
    smull   x4, w9, w3
    asr     x4, x4, #26
    mov     w5, #MLKEM_Q
    msub    w9, w4, w5, w9
    sxth    w9, w9
    strh    w9, [x1]
    sub     w8, w8, w7
    sxth    w8, w8
    /* fqmul(zeta, r[j+len]) */
    smull   x3, w24, w8
    mov     w4, #MLKEM_QINV
    uxth    w5, w3
    mul     w5, w5, w4
    sxth    w5, w5
    mov     w6, #MLKEM_Q
    smsubl  x3, w5, w6, x3
    asr     x3, x3, #16
    sxth    w3, w3
    strh    w3, [x2]
    add     w25, w25, #1
    cmp     w25, w26
    b.lo    .Lj
    add     w23, w25, w22
    cmp     w23, #MLKEM_N
    b.lo    .Lstart
    lsl     w22, w22, #1
    cmp     w22, #128
    b.ls    .Llen
    /* * f = 1441 */
    mov     w24, #1441
    mov     w25, #0
.Lscale:
    add     x1, x19, w25, uxtw #1
    ldrsh   w8, [x1]
    smull   x3, w24, w8
    mov     w4, #MLKEM_QINV
    uxth    w5, w3
    mul     w5, w5, w4
    sxth    w5, w5
    mov     w6, #MLKEM_Q
    smsubl  x3, w5, w6, x3
    asr     x3, x3, #16
    sxth    w3, w3
    strh    w3, [x1]
    add     w25, w25, #1
    cmp     w25, #MLKEM_N
    b.lo    .Lscale
    ldp     x19, x20, [sp, #16]
    ldp     x21, x22, [sp, #32]
    ldp     x23, x24, [sp, #48]
    ldp     x25, x26, [sp, #64]
    ldp     x29, x30, [sp], #80
    ret
.size mlkem_invntt, .-mlkem_invntt
