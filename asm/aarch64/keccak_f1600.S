.text
.align 4
.global mlkem_keccak_f1600
.type mlkem_keccak_f1600, %function
/* void mlkem_keccak_f1600(uint64_t A[25])
   Full Keccak-f[1600], AArch64 asm (research SHAKE/FO path). */
mlkem_keccak_f1600:
    stp     x29, x30, [sp, #-96]!
    mov     x29, sp
    stp     x19, x20, [sp, #16]
    stp     x21, x22, [sp, #32]
    stp     x23, x24, [sp, #48]
    stp     x25, x26, [sp, #64]
    stp     x27, x28, [sp, #80]
    mov     x19, x0                  /* A */
    mov     w20, #0                  /* round */
.Lround:
    /* ---- θ: C[x] ---- */
    mov     w21, #0
.LthetaC:
    add     x0, x19, w21, uxtw #3
    ldr     x1, [x0]
    ldr     x2, [x0, #40]
    eor     x1, x1, x2
    ldr     x2, [x0, #80]
    eor     x1, x1, x2
    ldr     x2, [x0, #120]
    eor     x1, x1, x2
    ldr     x2, [x0, #160]
    eor     x1, x1, x2
    /* stash C on stack below frame: use [sp,#-40] area — allocate */
    add     w21, w21, #1
    cmp     w21, #5
    /* Store C in callee registers bank via stack tmp at sp-48 */
    b.ne    .LthetaC
    /* Re-do θ with stack array */
    sub     sp, sp, #48              /* C[5] + D[5] space (40) + pad */
    mov     w21, #0
.LthetaC2:
    add     x0, x19, w21, uxtw #3
    ldr     x1, [x0]
    ldr     x2, [x0, #40]
    eor     x1, x1, x2
    ldr     x2, [x0, #80]
    eor     x1, x1, x2
    ldr     x2, [x0, #120]
    eor     x1, x1, x2
    ldr     x2, [x0, #160]
    eor     x1, x1, x2
    str     x1, [sp, w21, uxtw #3]
    add     w21, w21, #1
    cmp     w21, #5
    b.lo    .LthetaC2
    mov     w21, #0
.LthetaD:
    /* D = C[x-1] ^ rotl(C[x+1],1) */
    add     w22, w21, #4
    mov     w23, #5
    udiv    w24, w22, w23
    msub    w22, w24, w23, w22
    ldr     x1, [sp, w22, uxtw #3]
    add     w22, w21, #1
    udiv    w24, w22, w23
    msub    w22, w24, w23, w22
    ldr     x2, [sp, w22, uxtw #3]
    ror     x2, x2, #63
    eor     x1, x1, x2
    mov     w25, #0
.LthetaA:
    mov     w23, #5
    madd    w24, w25, w23, w21
    add     x0, x19, w24, uxtw #3
    ldr     x2, [x0]
    eor     x2, x2, x1
    str     x2, [x0]
    add     w25, w25, #1
    cmp     w25, #5
    b.lo    .LthetaA
    add     w21, w21, #1
    cmp     w21, #5
    b.lo    .LthetaD
    add     sp, sp, #48

    /* ---- ρ π ---- */
    sub     sp, sp, #200
    mov     w21, #0
.Lcopy:
    ldr     x1, [x19, w21, uxtw #3]
    str     x1, [sp, w21, uxtw #3]
    add     w21, w21, #1
    cmp     w21, #25
    b.lo    .Lcopy
    adrp    x26, keccak_piln
    add     x26, x26, :lo12:keccak_piln
    adrp    x27, keccak_rotc
    add     x27, x27, :lo12:keccak_rotc
    ldr     x1, [sp, #8]             /* current = A[1] */
    mov     w21, #0
.Lrp:
    ldrb    w22, [x26, w21, uxtw]
    ldr     x2, [sp, w22, uxtw #3]
    ldrb    w23, [x27, w21, uxtw]
    mov     w24, #64
    sub     w24, w24, w23
    ror     x1, x1, x24
    str     x1, [sp, w22, uxtw #3]
    mov     x1, x2
    add     w21, w21, #1
    cmp     w21, #24
    b.lo    .Lrp

    /* ---- χ ---- */
    mov     w21, #0                  /* y */
.Lchy:
    mov     w25, #5
    /* load row into x1..x5 on stack at offset 200 — use registers */
    madd    w0, w21, w25, wzr
    ldr     x1, [sp, w0, uxtw #3]
    add     w0, w0, #1
    ldr     x2, [sp, w0, uxtw #3]
    add     w0, w0, #1
    ldr     x3, [sp, w0, uxtw #3]
    add     w0, w0, #1
    ldr     x4, [sp, w0, uxtw #3]
    add     w0, w0, #1
    ldr     x5, [sp, w0, uxtw #3]
    /* A'[x] = A[x] ^ ((~A[x+1]) & A[x+2]) */
    bic     x6, x3, x2
    eor     x6, x1, x6
    bic     x7, x4, x3
    eor     x7, x2, x7
    bic     x8, x5, x4
    eor     x8, x3, x8
    bic     x9, x1, x5
    eor     x9, x4, x9
    bic     x10, x2, x1
    eor     x10, x5, x10
    madd    w0, w21, w25, wzr
    str     x6, [sp, w0, uxtw #3]
    add     w0, w0, #1
    str     x7, [sp, w0, uxtw #3]
    add     w0, w0, #1
    str     x8, [sp, w0, uxtw #3]
    add     w0, w0, #1
    str     x9, [sp, w0, uxtw #3]
    add     w0, w0, #1
    str     x10, [sp, w0, uxtw #3]
    add     w21, w21, #1
    cmp     w21, #5
    b.lo    .Lchy

    /* ---- ι ---- */
    adrp    x26, keccak_rc
    add     x26, x26, :lo12:keccak_rc
    ldr     x1, [x26, w20, uxtw #3]
    ldr     x2, [sp]
    eor     x2, x2, x1
    str     x2, [sp]

    mov     w21, #0
.Lwrite:
    ldr     x1, [sp, w21, uxtw #3]
    str     x1, [x19, w21, uxtw #3]
    add     w21, w21, #1
    cmp     w21, #25
    b.lo    .Lwrite
    add     sp, sp, #200

    add     w20, w20, #1
    cmp     w20, #24
    b.lo    .Lround

    ldp     x19, x20, [sp, #16]
    ldp     x21, x22, [sp, #32]
    ldp     x23, x24, [sp, #48]
    ldp     x25, x26, [sp, #64]
    ldp     x27, x28, [sp, #80]
    ldp     x29, x30, [sp], #96
    ret
.size mlkem_keccak_f1600, .-mlkem_keccak_f1600

.align 3
keccak_rc:
    .quad 0x0000000000000001, 0x0000000000008082, 0x800000000000808A, 0x8000000080008000
    .quad 0x000000000000808B, 0x0000000080000001, 0x8000000080008081, 0x8000000000008009
    .quad 0x000000000000008A, 0x0000000000000088, 0x0000000080008009, 0x000000008000000A
    .quad 0x000000008000808B, 0x800000000000008B, 0x8000000000008089, 0x8000000000008003
    .quad 0x8000000000008002, 0x8000000000000080, 0x000000000000800A, 0x800000008000000A
    .quad 0x8000000080008081, 0x8000000000008080, 0x0000000080000001, 0x8000000080008008
keccak_piln:
    .byte 10,7,11,17,18,3,5,16,8,21,24,4,15,23,19,13,12,2,20,14,22,9,6,1
keccak_rotc:
    .byte 1,3,6,10,15,21,28,36,45,55,2,14,27,41,56,8,25,43,62,18,39,61,20,44
