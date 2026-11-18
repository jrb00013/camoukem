#include "mlkem_asm.h"
#include "mlkem_bench.h"
#include <stdio.h>
int main(void){ mlkem_poly a; int i; for(i=0;i<256;i++) a[i]=i; uint64_t t0=mlkem_cntvct(); mlkem_ntt(a); uint64_t t1=mlkem_cntvct(); printf("ntt ticks %llu\n", (unsigned long long)(t1-t0)); return 0; }
