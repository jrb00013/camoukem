#include <stdint.h>

/* Software Hamming-weight leakage model for HOCPA sims. */
int mlkem_hw16(int16_t x) {
    uint16_t u = (uint16_t)x;
    int c = 0;
    while (u) {
        c += u & 1;
        u >>= 1;
    }
    return c;
}
