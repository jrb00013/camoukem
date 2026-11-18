# Math roadmap

Learn in this order. Each step unlocks the next.

| Stage | Math | Why |
| --- | --- | --- |
| 1 | Modular arithmetic mod \(q=3329\) | Every Kyber coefficient |
| 2 | Polynomials / ring \(R_q\) | Kyber state |
| 3 | NTT as “FFT over \(\mathbb{Z}_q\)” | Hot path + asm target |
| 4 | MLWE intuition (noisy linear equations) | Why the scheme exists |
| 5 | Arithmetic masking + ISW mul gadgets | First-order protection |
| 6 | Hamming-weight leakage + correlation | Sim-CPA |
| 7 | Higher-order combination functions | HOCPA / order-2 masking |
| 8 | Cyclic group \( \mathbb{F}_q^\times \), discrete log as “angle” | Spatial / θ-domain ideas |
| 9 | AArch64 NEON programming | Orin kernels |

See also [09-spatial-theta-masking.md](09-spatial-theta-masking.md) for the beyond-masking research direction.
