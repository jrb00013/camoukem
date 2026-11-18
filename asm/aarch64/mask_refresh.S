.text
.align 4
.global mlkem_mask_refresh_pair
.type mlkem_mask_refresh_pair, %function
/* void mlkem_mask_refresh_pair(int16_t *s0, int16_t *s1, const int16_t *noise)
   s0 += noise; s1 -= noise;  (share refresh, no mod — caller reduce) */
mlkem_mask_refresh_pair:
    mov     w3, #256
1:
    ld1     {v0.8h}, [x0]
    ld1     {v1.8h}, [x1]
    ld1     {v2.8h}, [x2], #16
    add     v0.8h, v0.8h, v2.8h
    sub     v1.8h, v1.8h, v2.8h
    st1     {v0.8h}, [x0], #16
    st1     {v1.8h}, [x1], #16
    subs    w3, w3, #8
    b.ne    1b
    ret
.size mlkem_mask_refresh_pair, .-mlkem_mask_refresh_pair
