# masked-mlkem-guide

```text
   ███╗   ███╗██╗     ██╗  ██╗███████╗███╗   ███╗
   ████╗ ████║██║     ██║ ██╔╝██╔════╝████╗ ████║
   ██╔████╔██║██║     █████╔╝ █████╗  ██╔████╔██║
   ██║╚██╔╝██║██║     ██╔═██╗ ██╔══╝  ██║╚██╔╝██║
   ██║ ╚═╝ ██║███████╗██║  ██╗███████╗██║ ╚═╝ ██║
   ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝
        AArch64 · NEON · Masking · θ-gauge
```

**Experimental research repo: higher-order masked ML-KEM-768 with the hot path in hand-written AArch64 assembly.**

Owned by [`jrb00013`](https://github.com/jrb00013).

This is not a tutorial clone of Kyber in C. The GitHub language bar is meant to read **Assembly**. Kernels live under `asm/aarch64/*.S`.

## Thesis

> Higher-order masked ML-KEM-768 · AArch64 NEON · θ-domain spin · software-sim HOCPA — on Jetson Orin.

## What is assembly here

| Kernel | File | Research angle |
| --- | --- | --- |
| Poly add/sub/neg/copy/zero | `poly_*.S` | NEON 8×int16 |
| Barrett / csubq / tomont | `poly_reduce.S`, `montgomery.S` | CT reduction |
| NTT / INTT / NEON NTT | `ntt.S`, `intt.S`, `ntt_neon.S` | Lattice hot path |
| Basemul (+acc) | `basemul.S`, `basemul_acc.S` | NTT-domain mul |
| Order-1/2 mask share | `mask_share.S`, `mask_order2.S` | SCA shares in asm |
| θ multiplicative shares | `theta_mulshare.S` | Spatial / angle chart |
| Unit spin | `spin_mul.S` | Gauge randomization |
| CBD2 / compress / serdes | `poly_cbd2.S`, `poly_compress.S`, … | Sampling & wire |
| Keccak-f[1600] | `keccak_f1600.S` | SHAKE/FO path in asm |
| HW leak map | `hw_leak.S` | Sim-HOCPA traces |
| CT cmov | `cmov.S` | FO compare helper |

C under `src/` / `tests/` is a thin harness only (linguist-vendored via `.gitattributes`).

## Build (no Docker required)

```bash
# uses $HOME/toolchains Arm GNU if present; on Orin: make CROSS_COMPILE=
make clean && make asmcheck && make all
make test   # needs qemu-aarch64 on x86
```

## Docs

[`ARCHITECTURE.md`](ARCHITECTURE.md) · [`docs/09-spatial-theta-masking.md`](docs/09-spatial-theta-masking.md)

## Status

Research / learning. **Not** production cryptography. Pushing asm-only gadgets, θ-domain shares, HOCPA simulation, NEON NTT.

## License

CC0-1.0
