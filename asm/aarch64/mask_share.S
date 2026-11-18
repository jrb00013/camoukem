.text
.align 4
.global mlkem_mask_share_asm
.type mlkem_mask_share_asm, %function
/* void mlkem_mask_share_asm(int16_t *s0, int16_t *s1,
                             const int16_t *s, const int16_t *rand)
   s0 = rand; s1 = s - rand  (caller reduces) */
mlkem_mask_share_asm:
    mov     w4, #256
1:
    ld1     {v0.8h}, [x3], #16       /* rand */
    ld1     {v1.8h}, [x2], #16       /* s */
    st1     {v0.8h}, [x0], #16       /* s0 */
    sub     v2.8h, v1.8h, v0.8h
    st1     {v2.8h}, [x1], #16       /* s1 */
    subs    w4, w4, #8
    b.ne    1b
    ret
.size mlkem_mask_share_asm, .-mlkem_mask_share_asm
