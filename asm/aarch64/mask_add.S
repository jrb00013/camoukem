.text
.align 4
.global mlkem_mask_poly_add_asm
.type mlkem_mask_poly_add_asm, %function
/* void mlkem_mask_poly_add_asm(int16_t *r0, int16_t *r1,
                                const int16_t *a0, const int16_t *a1,
                                const int16_t *b0, const int16_t *b1)
   Order-1 sharewise add fully in asm. AAPCS: x0..x5 */
mlkem_mask_poly_add_asm:
    mov     w6, #256
1:
    ld1     {v0.8h}, [x2], #16
    ld1     {v1.8h}, [x4], #16
    add     v2.8h, v0.8h, v1.8h
    st1     {v2.8h}, [x0], #16
    ld1     {v0.8h}, [x3], #16
    ld1     {v1.8h}, [x5], #16
    add     v2.8h, v0.8h, v1.8h
    st1     {v2.8h}, [x1], #16
    subs    w6, w6, #8
    b.ne    1b
    ret
.size mlkem_mask_poly_add_asm, .-mlkem_mask_poly_add_asm
