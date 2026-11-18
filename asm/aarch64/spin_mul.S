#include "params.inc"
.text
.align 4
.global mlkem_spin_mul
.type mlkem_spin_mul, %function
/* void mlkem_spin_mul(int16_t *r, const int16_t *a, int16_t u)
   r[i] = a[i] * u  (raw product in int16 — caller reduce). θ-gauge spin. */
mlkem_spin_mul:
    /* w2 has u in low 16 bits when called as int16 — AAPCS puts in w2 */
    dup     v3.8h, w2
    mov     w3, #256
1:
    ld1     {v0.8h}, [x1], #16
    mul     v1.8h, v0.8h, v3.8h
    st1     {v1.8h}, [x0], #16
    subs    w3, w3, #8
    b.ne    1b
    ret
.size mlkem_spin_mul, .-mlkem_spin_mul
