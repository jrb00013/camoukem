# Jetson Orin native: make CROSS_COMPILE=
# x86 lab: auto-detects $HOME/toolchains Arm GNU (no Docker required)
HOME_TC := $(HOME)/toolchains/aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-
ifeq ($(origin CROSS_COMPILE),undefined)
  ifneq ($(wildcard $(HOME_TC)gcc),)
    CROSS_COMPILE := $(HOME_TC)
  else
    CROSS_COMPILE := aarch64-linux-gnu-
  endif
endif

CC      := $(CROSS_COMPILE)gcc
AS      := $(CROSS_COMPILE)gcc
AR      := $(CROSS_COMPILE)ar
CFLAGS  := -O2 -Wall -Wextra -std=c11 -Iinclude -Isim/board -fno-tree-vectorize
ASFLAGS := -Iasm/aarch64
LDFLAGS := -static
LDLIBS  := -lm

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
	asm/aarch64/ntt_neon.S \
	asm/aarch64/intt.S \
	asm/aarch64/basemul.S \
	asm/aarch64/basemul_acc.S \
	asm/aarch64/spin_mul.S \
	asm/aarch64/mask_refresh.S \
	asm/aarch64/mask_share.S \
	asm/aarch64/mask_unshare.S \
	asm/aarch64/mask_add.S \
	asm/aarch64/mask_order2.S \
	asm/aarch64/theta_mulshare.S \
	asm/aarch64/poly_frombytes.S \
	asm/aarch64/poly_tobytes.S \
	asm/aarch64/poly_compress.S \
	asm/aarch64/poly_cbd2.S \
	asm/aarch64/cmov.S \
	asm/aarch64/hw_leak.S \
	asm/aarch64/keccak_f1600.S \
	asm/aarch64/cntvct.S

ASM_OBJS := $(ASM_SRCS:.S=.o)
LIB := libmlkem_neon.a

.PHONY: all clean test asmcheck sim

all: $(LIB) tests/test_poly tests/test_ntt tests/test_mask tests/test_spin tests/test_asm_mask smoke sim/board/board_sim

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
tests/test_asm_mask: tests/test_asm_mask.o $(LIB)
	$(CC) $(LDFLAGS) -o $@ $^
smoke: src/main_smoke.o src/mask_order1.o src/spin.o $(LIB)
	$(CC) $(LDFLAGS) -o $@ $^ $(LDLIBS)

sim/board/%.o: sim/board/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

sim/board/board_sim: sim/board/board_sim.o sim/board/board.o sim/board/hocpa.o $(LIB)
	$(CC) $(LDFLAGS) -o $@ $^ $(LDLIBS)

sim: sim/board/board_sim
	@QEMU=$$(command -v qemu-aarch64 || command -v qemu-aarch64-static || true); \
	if [ -z "$$QEMU" ]; then echo "need qemu-aarch64"; exit 1; fi; \
	$$QEMU ./sim/board/board_sim --traces 64 --coeffs 8

asmcheck:
	@echo "ASM files: $$(ls asm/aarch64/*.S | wc -l)"
	@echo "ASM lines: $$(cat asm/aarch64/*.S asm/aarch64/*.inc 2>/dev/null | wc -l)"

test: all
	@QEMU=$$(command -v qemu-aarch64 || command -v qemu-aarch64-static || true); \
	if [ -z "$$QEMU" ]; then echo "Install qemu-user to run aarch64 tests on x86"; exit 1; fi; \
	$$QEMU ./tests/test_poly && \
	$$QEMU ./tests/test_ntt && \
	$$QEMU ./tests/test_mask && \
	$$QEMU ./tests/test_spin && \
	$$QEMU ./tests/test_asm_mask && \
	$$QEMU ./smoke && \
	$$QEMU ./sim/board/board_sim --traces 32 --coeffs 4 >/dev/null && \
	echo "ALL TESTS PASSED"

clean:
	rm -f $(ASM_OBJS) src/*.o tests/*.o sim/board/*.o $(LIB) \
	  tests/test_poly tests/test_ntt tests/test_mask tests/test_spin tests/test_asm_mask smoke \
	  sim/board/board_sim
