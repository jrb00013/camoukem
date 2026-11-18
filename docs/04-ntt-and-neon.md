# NTT and AArch64 NEON kernels

## Why NTT exists

Kyber multiplies polynomials in \(R_q = \mathbb{Z}_q[x]/(x^{256}+1)\).

Schoolbook multiply is \(O(n^2)\).  
**NTT** (Number Theoretic Transform) is the crypto twin of the **FFT**:

1. Transform each poly → NTT domain  
2. Multiply **pointwise** (cheap)  
3. Inverse NTT → product in the ring  

Almost every optimized Kyber spends a large fraction of cycles in NTT / INTT / basemul / modular reduction.

---

## What an “NTT kernel” is

A **kernel** here is a tight routine, often assembly:

- butterfly (Cooley–Tukey / Gentleman–Sande style steps)  
- twiddle-factor multiply  
- Montgomery or Plantard **reduction** mod \(q=3329\)  
- **basemul** for Kyber’s incomplete-NTT domain multiplies  

These are the functions attackers also love: lots of secret-dependent intermediates in registers.

---

## AArch64 + NEON (Jetson Orin)

| Term | Meaning |
| --- | --- |
| **AArch64** | 64-bit ARM ISA |
| **NEON** | SIMD extension — operate on 64-bit or 128-bit vectors of lanes |

Example intuition (not exact asm):

```text
Instead of:
  for i in 0..7: c[i] = (a[i] * b[i]) % q

NEON idea:
  load 4 lanes of a, 4 lanes of b
  multiply lanes
  reduce lanes
  store
```

On Orin, NEON is the natural “full advanced assembly” surface for a **software-first** project.

### What to write in asm first

1. Unmasked NTT butterflies + reduce (correctness + cycles)  
2. basemul  
3. Adapt to **share-wise** execution for masking (each share is another poly; sometimes you can SIMD across lanes/shares carefully)  
4. Only later: Boolean-masked Keccak (often the new bottleneck)

### What not to asm

- Full FO protocol glue  
- File I/O, hex parsers, test harnesses  

Asm the 5% of code that is 90% of time and leakage interest.

---

## Reduction choices matter

Common techniques:

- **Montgomery reduction**  
- **Plantard reduction**  

They are fast. They can also create **value-dependent leakage shapes** (sign, central representation, etc.). Papers have exploited reduction choices in SCA against lattice implementations.

For a learning project: pick one, document it, keep it constant-time, and note it in your threat notes.

---

## Correctness rules for asm

1. Match C reference bit-for-bit on KATs  
2. No secret-dependent branches  
3. No secret-dependent table lookups  
4. Clear sensitive registers where ABI allows  
5. Benchmark with a named compiler × flags × CPU (e.g. Orin’s Cortex-A cores)

---

## Dual-ISA optional path

| Target | Asm flavor |
| --- | --- |
| Jetson Orin | AArch64 NEON (primary) |
| ESP32-C3/C6 | RISC-V (optional port) |
| Classic ESP32 | Xtensa (optional; more awkward) |
| STM32 (later) | Thumb-2, pqm4-comparable |

Primary thesis stays **Orin NEON**. Extra ISAs are portfolio spice, not the core claim.
