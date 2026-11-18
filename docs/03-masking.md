# Masking for Kyber / ML-KEM

## Goal

Stop a side-channel attacker from learning secrets by watching power, EM, or similar leakage of intermediate CPU values.

**Idea:** never store the secret \(s\) alone. Store random shares that only reconstruct \(s\) when combined.

---

## Arithmetic vs Boolean masking

### Arithmetic (main tool for Kyber polys)

\[
s \equiv s_0 + s_1 + \cdots + s_d \pmod{q}
\]

Natural because Kyber coefficients live in \(\mathbb{Z}_q\).

### Boolean (common for AES / Keccak bits)

\[
s = s_0 \oplus s_1 \oplus \cdots \oplus s_d
\]

Kyber also uses **SHAKE/Keccak** (hashing, PRF, FO). Those parts often need **Boolean** masking, plus conversions between Boolean and arithmetic domains. Conversions are a classic footgun (leaky or slow).

---

## First-order example (2 shares)

```text
Input:  secret s, modulus q
Pick:   r uniform in 0..q-1
Output: s0 = r
        s1 = (s - r) mod q

Invariant: (s0 + s1) mod q == s
```

**Masked add** is easy: add sharewise.

```text
(c0, c1) = (a0+b0 mod q, a1+b1 mod q)
```

**Masked multiply** is hard: the cross terms mix shares and need **fresh randomness** (ISW-style gadgets) so the result’s shares don’t leak \(a\cdot b\) through intermediates.

---

## What must be masked in ML-KEM

Anything that depends on the secret key (or on values that are statistically close to it) during decaps:

- secret polynomials and their NTT forms  
- products involving secrets  
- decoding of noisy shared values when secret-dependent  
- FO-related re-encrypt/compare paths that would otherwise leak through compression  

Public polynomials and public ciphertext pieces are not secrets — but **mixing** public and secret values still needs care so gadgets don’t reintroduce leakage.

---

## Cost

Masking is not free:

- **More CPU** — especially masked mul, Keccak, conversions  
- **More RAM** — each share is another polynomial buffer  
- **More RNG** — share refresh and ISW randomness  
- **More bugs** — wrong gadget ⇒ looks random but still leaks, or fails KATs  

That is why **asm on NTT/basemul/reduce** matters: you claw back performance on the hottest loops.

---

## “Complete” vs “partial” masking

| Level | Meaning |
| --- | --- |
| Partial | Only NTT shuffled, or only some ops masked |
| First-order complete | Full decaps path protected at order 1 |
| Higher-order | Critical gadgets lifted to order 2+ |

Published “Masking Kyber” work (TCHES) emphasized **complete** first- and higher-order implementations — that is the bar this project aspires to, software-first.

---

## Mental checklist before you claim “masked”

1. Shares never recombine early in the clear  
2. Fresh randomness for every mul gadget that needs it  
3. RNG quality is not `rand() % q` in production ambitions  
4. Still passes KATs  
5. You have *some* leakage story (sim HOCPA, TVLA, or formal gadgets)
