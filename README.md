# masked-mlkem-guide

**Assembly-first ML-KEM-768** for Jetson Orin (AArch64 + NEON): poly/NTT kernels, order-1 arithmetic masking, θ-gauge unit spin, software HOCPA hooks.

Owned by [`jrb00013`](https://github.com/jrb00013).

> Higher-order masked ML-KEM-768 with AArch64 NEON kernels and software-simulated HOCPA evaluation on Jetson Orin.

## Build (cross from x86)

```bash
# needs aarch64-linux-gnu-gcc + qemu-user
make clean && make all && make test
```

Docker (no host cross toolchain):

```bash
docker run --rm -v "$PWD":/work -w /work ubuntu:24.04 bash -lc \
  'apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
   gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu qemu-user make && make test'
```

On Orin natively: `make CROSS_COMPILE= all test`

## Layout

| Path | Role |
| --- | --- |
| `asm/aarch64/*.S` | Hand-written kernels (add/sub/NTT/basemul/spin/mask refresh) |
| `include/` | C ABI |
| `src/` | Thin orchestration (mask, spin, smoke) + C NTT oracle |
| `tests/` | QEMU-run self-tests |
| `sim/` | HW leakage / HOCPA stubs |
| `docs/` | Learning path + θ-domain research note |
| `ARCHITECTURE.md` | Full design |

## Status

Real AArch64 assembly library `libmlkem_neon.a` with passing `test_poly`, `test_ntt`, `test_mask`, `test_spin`, `smoke`.

Research / learning code — **not** production cryptography.

## License

CC0-1.0
