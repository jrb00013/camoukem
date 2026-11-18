.text
.align 4
.global mlkem_mask3_share_asm
.type mlkem_mask3_share_asm, %function
/* void mlkem_mask3_share_asm(int16_t *s0, int16_t *s1, int16_t *s2,
                              const int16_t *s, const int16_t *r0, const int16_t *r1)
   s0=r0; s1=r1; s2=s-r0-r1 */
mlkem_mask3_share_asm:
    mov     w6, #256
1:
    ld1     {v0.8h}, [x4], #16       /* r0 */
    ld1     {v1.8h}, [x5], #16       /* r1 */
    ld1     {v2.8h}, [x3], #16       /* s */
    st1     {v0.8h}, [x0], #16
    st1     {v1.8h}, [x1], #16
    sub     v3.8h, v2.8h, v0.8h
    sub     v3.8h, v3.8h, v1.8h
    st1     {v3.8h}, [x2], #16
    subs    w6, w6, #8
    b.ne    1b
    ret
.size mlkem_mask3_share_asm, .-mlkem_mask3_share_asm

.global mlkem_mask3_unshare_asm
.type mlkem_mask3_unshare_asm, %function
/* void mlkem_mask3_unshare_asm(int16_t *out, const int16_t *s0,
                                const int16_t *s1, const int16_t *s2) */
mlkem_mask3_unshare_asm:
    mov     w4, #256
1:
    ld1     {v0.8h}, [x1], #16
    ld1     {v1.8h}, [x2], #16
    ld1     {v2.8h}, [x3], #16
    add     v3.8h, v0.8h, v1.8h
    add     v3.8h, v3.8h, v2.8h
    st1     {v3.8h}, [x0], #16
    subs    w4, w4, #8
    b.ne    1b
    ret
.size mlkem_mask3_unshare_asm, .-mlkem_mask3_unshare_asm
