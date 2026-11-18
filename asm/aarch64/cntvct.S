.text
.align 4
.global mlkem_cntvct
.type mlkem_cntvct, %function
mlkem_cntvct:
    mrs x0, CNTVCT_EL0
    ret
.size mlkem_cntvct, .-mlkem_cntvct
