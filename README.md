# camoukem

AArch64 / NEON masked ML-KEM lab — hand-written `.S` kernels plus a full software HO-SCA board (shunt → ADC → HOCPA) that runs the real asm under qemu.

Owned by [`jrb00013`](https://github.com/jrb00013).

## Quick start

```bash
./scripts/camoukem check
./scripts/camoukem test
./scripts/camoukem sim --traces 200 --noise 0.2
```

Needs aarch64 cross GCC (`$HOME/toolchains/...` auto-detected) and `qemu-aarch64` on x86. On Orin: `make CROSS_COMPILE=`.

## Pieces

| Path | Role |
| --- | --- |
| `asm/aarch64/*.S` | Poly / NTT / share / θ / Keccak kernels |
| `sim/board/` | Simulated attack board + circuit + HOCPA |
| `./scripts/camoukem` | CLI (`check` / `test` / `sim`) |

Circuit model: [`sim/board/circuit.md`](sim/board/circuit.md)

## Status

Experimental. Not production crypto.

## License

CC0-1.0
