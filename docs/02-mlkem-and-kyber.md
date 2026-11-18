# ML-KEM-768 and Kyber

## Names

| Name | What it is |
| --- | --- |
| **Kyber** | Original scheme name (NIST PQC competition) |
| **ML-KEM** | NIST standardized name (FIPS 203, August 2024) |
| **ML-KEM-512 / 768 / 1024** | Parameter sets (roughly increasing security / size / cost) |

This guide targets **ML-KEM-768** — the middle set, widely discussed for internet hybrids (e.g. with X25519).

---

## What a KEM does

A **Key Encapsulation Mechanism** lets Alice send Bob a fresh shared secret using Bob’s public key.

Typical API shape:

1. `KeyGen → (pk, sk)`  
2. `Encaps(pk) → (ciphertext, shared_secret)`  
3. `Decaps(sk, ciphertext) → shared_secret`

If everything is honest and correct, both sides get the same `shared_secret`.

Unlike classical RSA “encrypt the key,” KEMs are designed as their own primitive (and Kyber’s security proof uses an FO-style transform around a quieter public-key encryption core).

---

## Why post-quantum

RSA and elliptic-curve Diffie–Hellman fall to **Shor’s algorithm** on a large quantum computer.  
Kyber/ML-KEM is built from **Module-LWE** (noisy linear algebra over polynomial rings), which is believed to resist known quantum attacks (confidence comes from lattice cryptanalysis, not from “quantum-proof” marketing).

---

## The math objects (intuition only)

- Integers mod **\(q = 3329\)**  
- Polynomials of degree \(< 256\): elements of  
  \[
  R_q = \mathbb{Z}_q[x] / (x^{256} + 1)
  \]
- Vectors / matrices of those polynomials (the “module” in Module-LWE)  
- **Noise** (small random coefficients) that hides the secret  

Public key ≈ “noisy linear samples.”  
Secret key ≈ the small secret vector that generated them.

You can implement long before you can prove hardness.

---

## Where secrets live (why masking matters)

For side-channels, the dangerous path is usually **decapsulation** (and for signatures, signing). The device holds `sk` and manipulates secret-dependent polynomials.

Hot operations:

- NTT / INTT of secret-related polys  
- basemul / polynomial multiplication  
- decoding / compression steps  
- FO re-encryption and comparison  

Those are exactly where **masking** and **asm** concentrate.

---

## What “correct” means for your project

Before any masking claim:

1. Match **NIST KATs** (known answer tests) for ML-KEM-768  
2. Encaps/decaps round-trip works with random keys  
3. Bit-identical to a trusted reference (pqclean / official vectors) for test inputs  

Masking that breaks KATs is just a broken KEM.

---

## Related standards (context)

| Standard | Primitive |
| --- | --- |
| FIPS 203 | ML-KEM (Kyber) |
| FIPS 204 | ML-DSA (Dilithium) — signatures; later phase |
| FIPS 205 | SLH-DSA (SPHINCS+) — hash-based signatures |

This guide’s implementation thesis is **ML-KEM only** until masking + NEON + sim-HOCPA are solid.
