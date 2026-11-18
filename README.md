# masklamp

AArch64 / NEON masked ML-KEM research lab — higher-order share kernels, θ-gauge spin, and a **full software SCA board** (shunt + ADC + HOCPA) that runs the real `.S` firmware under qemu.

Owned by [`jrb00013`](https://github.com/jrb00013).

## Quick start

```bash
./scripts/masklamp check      # build + kernel tests + board sim smoke
./scripts/masklamp test      # asm self-tests only
./scripts/masklamp sim       # full simulated HO-SCA board
./scripts/masklamp sim-quick # faster board smoke
```

Needs: Arm aarch64 cross GCC (auto-detects `$HOME/toolchains/...`) and `qemu-aarch64` on x86. On Jetson Orin: `make CROSS_COMPILE=`.

## What you get

| Piece | What it is |
| --- | --- |
| `asm/aarch64/*.S` | Hand-written poly/NTT/mask/θ/Keccak kernels |
| `sim/board/` | Simulated attack board + circuit model + HOCPA |
| `./scripts/masklamp` | One CLI for build / test / simulate |

## Simulated board

Models shunt → amp → ADC, GPIO trigger, and 1st/2nd-order CPA against order-1 and order-2 asm masking.

```bash
./scripts/masklamp sim --traces 128 --noise 0.25 --coeffs 8
```

Details: [`sim/board/circuit.md`](sim/board/circuit.md)

## Layout

```text
asm/aarch64/   # the product
sim/board/     # full HO SCA board simulation
src/ tests/    # thin harness
docs/          # design notes (not a tutorial series)
```

## Status

Experimental research. Not production crypto.

## License

CC0-1.0
