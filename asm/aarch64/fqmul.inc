/* Montgomery fqmul: dest_w = mont_reduce(a_w * b_w)
   Clobbers: x9-x12 matching temps — caller sets a in \aw, b in \bw, result \rw */
.macro FQMUL rw, aw, bw
    smull   x9, \aw, \bw
    mov     w10, #62209
    uxth    w11, w9
    mul     w11, w11, w10
    sxth    w11, w11
    mov     w12, #3329
    smsubl  x9, w11, w12, x9
    asr     x9, x9, #16
    sxth    \rw, w9
.endm
