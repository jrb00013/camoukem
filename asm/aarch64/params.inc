/* ML-KEM-768 field params — AArch64 NEON asm include */
.equ MLKEM_N, 256
.equ MLKEM_Q, 3329
/* -q^{-1} mod 2^16 for Montgomery (Kyber/ML-KEM) */
.equ MLKEM_QINV, 62209
.equ MLKEM_MONT, 1353   /* 2^16 mod q */

.macro POLY_PTR dst, src
    mov \dst, \src
.endm
