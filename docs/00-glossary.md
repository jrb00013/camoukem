# Glossary

Quick definitions for the project thesis and related jargon.

## Thesis terms

| Term | Meaning here |
| --- | --- |
| **ML-KEM** | NIST FIPS 203 name for Kyber — a post-quantum **key encapsulation mechanism** |
| **ML-KEM-768** | Middle parameter set (common for TLS hybrids) |
| **Masked / masking** | Split every secret into random **shares** so the CPU never holds the full secret alone |
| **Higher-order** | Side-channel sense: attacker combines **multiple** leaks; masking uses **more shares** to resist that. **Not** higher-order DEs or higher-order functions |
| **AArch64** | 64-bit ARM instruction set (Jetson Orin, many phones) |
| **NEON** | ARM SIMD: one instruction operates on many data lanes |
| **Kernel** | Tight hand-written function (NTT butterfly, reduce) — not the Linux kernel |
| **HOCPA** | Higher-Order Correlation Power Analysis — CPA that combines multiple leak points |
| **Software-simulated** | Fake power traces from a leakage model (e.g. Hamming weight + noise), not a scope |
| **Jetson Orin** | NVIDIA ARM board used as build / bench / sim-attack host |

## Crypto building blocks

| Term | Meaning |
| --- | --- |
| **KEM** | Key Encapsulation Mechanism — encapsulate a shared secret to a public key |
| **PQC** | Post-quantum cryptography — meant to resist quantum attacks on RSA/ECC |
| **Lattice** | Discrete grid in high dimension; Kyber’s hardness lives here |
| **MLWE / Module-LWE** | Hard problem underlying Kyber/Dilithium |
| **NTT** | Number Theoretic Transform — FFT-like transform over integers mod \(q\) |
| **Polynomial ring** | Kyber works in \(R_q = \mathbb{Z}_q[x]/(x^{256}+1)\) with \(q = 3329\) |
| **AEAD** | Authenticated encryption with associated data (AES-GCM, etc.) |
| **FIPS 203 / 204 / 205** | NIST standards: ML-KEM, ML-DSA (Dilithium), SLH-DSA (SPHINCS+) |

## Side-channel terms

| Term | Meaning |
| --- | --- |
| **SCA** | Side-channel attack — power, EM, timing, cache, etc. |
| **CPA** | Correlation Power Analysis |
| **DPA** | Differential Power Analysis |
| **HO / higher-order (SCA)** | Attack or protection involving multiple intermediate values |
| **First-order masking** | Typically **2 shares**; stops simple single-point leakage |
| **Second-order masking** | Typically **3 shares**; aimed at 2nd-order attacks |
| **TVLA** | Test Vector Leakage Assessment — statistical leak check (fixed vs random) |
| **Constant-time (CT)** | No secret-dependent branches or memory indexes |
| **Hamming weight (HW)** | Number of `1` bits — common simple leakage model |
| **Probing model / ISW** | Theoretical model: attacker “probes” wires; ISW = classic secure-mul construction |
| **Boolean masking** | Shares combine with XOR |
| **Arithmetic masking** | Shares combine with `+` mod \(q\) (natural for Kyber polys) |

## Implementation terms

| Term | Meaning |
| --- | --- |
| **basemul** | Small multiplies in the (incomplete) NTT domain |
| **Montgomery / Plantard reduction** | Fast modular reduction tricks used in asm |
| **KAT** | Known Answer Test — NIST test vectors |
| **pqclean / pqm4** | Reference / Cortex-M optimized PQC implementations |
| **DudeCT / ctgrind** | Tools to hunt timing leaks in binaries |
| **Share refresh** | Re-randomize shares without changing their sum/XOR |

## Related frontier terms (context)

| Term | Meaning |
| --- | --- |
| **ML-DSA** | Dilithium — lattice signatures (FIPS 204) |
| **SLH-DSA** | SPHINCS+ — hash-based signatures (FIPS 205) |
| **Falcon / FN-DSA** | Compact lattice signatures; hard to SCA-harden |
| **Ascon** | NIST lightweight AEAD/hash (SP 800-232) |
| **AES-GCM-SIV** | Misuse-resistant AEAD (nonce reuse less catastrophic than GCM) |
