# Higher-order masked ML-KEM-768 (learning guide)

**Thesis target**

> Higher-order masked ML-KEM-768 with AArch64 NEON kernels and software-simulated HOCPA evaluation on Jetson Orin.

This repo documents what that means, the math to learn, and a software-first project path. It is a **study + design guide**, not a production crypto library.

Owned by [`jrb00013`](https://github.com/jrb00013).

---

## Plain-English one-liner

Build NIST’s post-quantum key exchange (**ML-KEM / Kyber**), protect secret values by splitting them into random shares (**masking**), harden that against attackers who combine multiple leaks (**higher-order**), speed the hot math with **ARM NEON assembly** on a **Jetson Orin**, and test the protection with **fake power traces + HOCPA** in software (no oscilloscope required).

---

## Read in this order

| # | Doc | What you get |
| --- | --- | --- |
| 1 | [docs/00-glossary.md](docs/00-glossary.md) | Every buzzword in the thesis sentence |
| 2 | [docs/01-what-higher-order-means.md](docs/01-what-higher-order-means.md) | Not differential equations — multi-leak SCA |
| 3 | [docs/02-mlkem-and-kyber.md](docs/02-mlkem-and-kyber.md) | What ML-KEM-768 is |
| 4 | [docs/03-masking.md](docs/03-masking.md) | Shares, arithmetic vs Boolean, order |
| 5 | [docs/04-ntt-and-neon.md](docs/04-ntt-and-neon.md) | NTT + AArch64 NEON kernels |
| 6 | [docs/05-hocpa-and-simulation.md](docs/05-hocpa-and-simulation.md) | Software-simulated attacks |
| 7 | [docs/06-math-roadmap.md](docs/06-math-roadmap.md) | Math prerequisites by topic |
| 8 | [docs/07-project-plan.md](docs/07-project-plan.md) | Phased build plan (Orin-first, software-only) |
| 9 | [docs/08-frontier-context.md](docs/08-frontier-context.md) | Why this gap still matters in 2025–2026 |
| 10 | [docs/09-spatial-theta-masking.md](docs/09-spatial-theta-masking.md) | Beyond masking: spin / θ-domain / spatial chart |
| 11 | [examples/masked_add_mod_q.py](examples/masked_add_mod_q.py) | Tiny hands-on: 2-share add mod 3329 |
| 12 | [examples/unit_spin_mod_q.py](examples/unit_spin_mod_q.py) | Random unit spin (θ-gauge without explicit log) |

Supporting notes live under [`refs/`](refs/).

---

## Hardware roles (software-first)

| Machine | Role |
| --- | --- |
| **Jetson Orin** | Main build, NEON asm, benches, attack simulation |
| **ESP32** | Optional second ISA port / IoT demo |
| **STM32 / ChipWhisperer** | Optional later — physical TVLA (not required for this guide’s software path) |

---

## Status

Documentation and learning path. Implementation code may be added later under `src/` once the study path is underway.

## License

CC0-1.0 for docs and examples unless noted otherwise. Do **not** treat example code as production cryptography.
