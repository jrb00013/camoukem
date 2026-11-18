#include "mlkem_version.h"
#include <stdio.h>
int main(void){ printf("v%d.%d.%d\n", MLKEM_NEON_VERSION_MAJOR, MLKEM_NEON_VERSION_MINOR, MLKEM_NEON_VERSION_PATCH); return 0; }
