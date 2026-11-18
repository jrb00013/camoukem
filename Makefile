CROSS_COMPILE ?= aarch64-linux-gnu-
CC      := $(CROSS_COMPILE)gcc
AS      := $(CROSS_COMPILE)gcc
AR      := $(CROSS_COMPILE)ar
CFLAGS  := -O2 -Wall -Wextra -std=c11 -Iinclude -fno-tree-vectorize
ASFLAGS := -Iasm/aarch64
LDFLAGS := -static

ASM_SRCS := \
	asm/aarch64/poly_add.S \
	asm/aarch64/poly_sub.S \
	asm/aarch64/poly_setzero.S \
	asm/aarch64/poly_copy.S \
	asm/aarch64/poly_neg.S \
	asm/aarch64/poly_reduce.S \
	asm/aarch64/poly_csubq.S \
	asm/aarch64/montgomery.S \
	asm/aarch64/ntt_zetas.S \
	asm/aarch64/ntt.S \
	asm/aarch64/intt.S \
	asm/aarch64/basemul.S \
	asm/aarch64/spin_mul.S \
	asm/aarch64/mask_refresh.S \
	asm/aarch64/cntvct.S

ASM_OBJS := $(ASM_SRCS:.S=.o)

LIB := libmlkem_neon.a

.PHONY: all clean test smoke

all: $(LIB) tests/test_poly tests/test_ntt tests/test_mask tests/test_spin smoke

$(LIB): $(ASM_OBJS)
	$(AR) rcs $@ $^

asm/aarch64/%.o: asm/aarch64/%.S
	$(AS) $(ASFLAGS) -c -o $@ $<

src/%.o: src/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

tests/%.o: tests/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

tests/test_poly: tests/test_poly.o $(LIB)
	$(CC) $(LDFLAGS) -o $@ $^

tests/test_ntt: tests/test_ntt.o src/ref_ntt.o $(LIB)
	$(CC) $(LDFLAGS) -o $@ $^

tests/test_mask: tests/test_mask.o src/mask_order1.o $(LIB)
	$(CC) $(LDFLAGS) -o $@ $^

tests/test_spin: tests/test_spin.o src/spin.o $(LIB)
	$(CC) $(LDFLAGS) -o $@ $^

smoke: src/main_smoke.o src/mask_order1.o src/spin.o $(LIB)
	$(CC) $(LDFLAGS) -o $@ $^

test: all
	@command -v qemu-aarch64 >/dev/null && QEMU=qemu-aarch64 || QEMU=qemu-aarch64-static; \
	$$QEMU ./tests/test_poly && \
	$$QEMU ./tests/test_ntt && \
	$$QEMU ./tests/test_mask && \
	$$QEMU ./tests/test_spin && \
	$$QEMU ./smoke && echo "ALL TESTS PASSED"

clean:
	rm -f $(ASM_OBJS) src/*.o tests/*.o $(LIB) tests/test_poly tests/test_ntt tests/test_mask tests/test_spin smoke
