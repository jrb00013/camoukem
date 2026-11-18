# Architecture — masked ML-KEM AArch64 NEON

## Goal

Ship a **real assembly-first** ML-KEM-768 arithmetic stack for Jetson Orin (AArch64 + NEON), with:

1. Unmasked poly/NTT kernels in `.S`
2. Order-1 arithmetic masking layer calling those kernels per share
3. Unit-spin (θ-gauge) hooks for spatial-domain research
4. C only as thin harness / KATs / sim-HOCPA driver — **hot path is assembly**

## Layout

```text
asm/aarch64/          # hand-written AArch64 NEON (.S)
  params.inc          # q, n, QINV, macros
  poly_add.S
  poly_sub.S
  poly_reduce.S
  ntt.S
  intt.S
  basemul.S
  montgomery.S
  spin_mul.S          # mul-by-unit gauge
  mask_refresh.S      # share refresh helpers
include/              # C ABI headers matching asm
src/                  # thin C: tests, benches, mask orchestration
tests/                # host-runnable checks (cross-run via qemu optional)
sim/                  # leakage sim hooks (C)
Makefile              # CROSS=aarch64-linux-gnu-
```

## Data model

- Coefficient: `int16_t` in `[0,q)` or centered — kernels document range
- Poly: `int16_t[256]` (`N=256`, `q=3329`)
- Order-1 mask: two polys `(s0,s1)` with `(s0+s1) mod q == s`
- Spin: `spun = u * s mod q` for nonzero paths; asm does vector mul+reduce

## Call convention (AAPCS64)

| Arg | Role |
| --- | --- |
| `x0` | dst poly pointer |
| `x1` | src0 / lhs |
| `x2` | src1 / rhs / scalar unit (spin) |
| `x3` | optional length / twiddle ptr |

NEON: `v0`–`v7` scratch; no callee-saved NEON assumed unless noted.

## Build targets

| Target | Meaning |
| --- | --- |
| `libmlkem_neon.a` | all `.S` objects |
| `test_poly` | poly add/sub/reduce self-test |
| `test_ntt` | NTT/INTT roundtrip vs C ref |
| `bench_ntt` | cycle counter (CNTVCT) on Orin |

Cross-build from x86: `make CROSS_COMPILE=aarch64-linux-gnu-`

## Security note

Research / learning code. Not FIPS-validated. Not production KEM.
