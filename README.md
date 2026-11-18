# krivox

AArch64 / NEON masked ML-KEM research lab: hand-written `.S` kernels and a full software HO-SCA board (shunt → ADC → HOCPA) running real asm under qemu.

Owned by [`jrb00013`](https://github.com/jrb00013).

## Quick start

```bash
./scripts/krivox check
./scripts/krivox test
./scripts/krivox sim --traces 200 --noise 0.2
```

Cross GCC: `$HOME/toolchains` Arm GNU if present. On Orin: `make CROSS_COMPILE=`.

## Layout

| Path | Role |
| --- | --- |
| `asm/aarch64/*.S` | Poly / NTT / share / θ / Keccak |
| `sim/board/` | Simulated attack board + HOCPA |
| `./scripts/krivox` | CLI |

Circuit: [`sim/board/circuit.md`](sim/board/circuit.md)

Experimental. Not production crypto. CC0-1.0
