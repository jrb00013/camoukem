#include "params.inc"
.text
.align 4
.global mlkem_basemul_acc
.type mlkem_basemul_acc, %function
/* void mlkem_basemul_acc(int16_t r[2], const int16_t a[2], const int16_t b[2], int16_t zeta)
   r += basemul(a,b,zeta) */
mlkem_basemul_acc:
    stp     x29, x30, [sp, #-32]!
    stp     x19, x20, [sp, #16]
    mov     x19, x0
    /* save zeta */
    mov     w20, w3
    /* compute into stack temp */
    sub     sp, sp, #16
    mov     x0, sp
    /* a,b already in x1,x2; zeta in w20 -> w3 */
    mov     w3, w20
    bl      mlkem_basemul
    ldrsh   w0, [x19]
    ldrsh   w1, [sp]
    add     w0, w0, w1
    sxth    w0, w0
    strh    w0, [x19]
    ldrsh   w0, [x19, #2]
    ldrsh   w1, [sp, #2]
    add     w0, w0, w1
    sxth    w0, w0
    strh    w0, [x19, #2]
    add     sp, sp, #16
    ldp     x19, x20, [sp, #16]
    ldp     x29, x30, [sp], #32
    ret
.size mlkem_basemul_acc, .-mlkem_basemul_acc
