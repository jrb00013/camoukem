.text
.align 4
.global mlkem_mask_unshare_asm
.type mlkem_mask_unshare_asm, %function
/* void mlkem_mask_unshare_asm(int16_t *out, const int16_t *s0, const int16_t *s1) */
mlkem_mask_unshare_asm:
    mov     w3, #256
1:
    ld1     {v0.8h}, [x1], #16
    ld1     {v1.8h}, [x2], #16
    add     v2.8h, v0.8h, v1.8h
    st1     {v2.8h}, [x0], #16
    subs    w3, w3, #8
    b.ne    1b
    ret
.size mlkem_mask_unshare_asm, .-mlkem_mask_unshare_asm
