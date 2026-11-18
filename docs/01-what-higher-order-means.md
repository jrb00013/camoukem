# What “higher-order” means (and what it does not)

## Short answer

In this project, **higher-order** is a **side-channel** term.

It means:

> The attacker looks at **more than one** leaky intermediate value at once  
> (and your masking uses **enough shares** that this becomes hard).

It does **not** mean:

- higher-order differential equations  
- higher-order functions (map/filter style)  
- Big-O “higher order” asymptotics  

Same English words. Different field.

---

## Order of an attack

Imagine the chip leaks something correlated with the Hamming weight of a register.

| Attack order | Attacker does | Simple picture |
| --- | --- | --- |
| **1st-order** | Uses leakage from **one** value | “Power when we handled \(x\)” |
| **2nd-order** | Combines leakage from **two** values | “Power at \(x\) and at \(y\), then combine” |
| **3rd-order** | Combines **three** | Harder; needs more traces |

Masking is designed so that **any single share looks random**. One probe is not enough. An attacker who can combine two probes needs stronger masking.

---

## Order of a masking scheme

| Masking | Typical shares | Aimed at stopping |
| --- | --- | --- |
| Unmasked | 1 (the secret itself) | nothing SCA-wise |
| **First-order** masked | 2 | 1st-order attacks |
| **Second-order** masked | 3 | 2nd-order attacks |
| “Higher-order” (umbrella) | 3+ | multi-leak attacks in general |

Rule of thumb people use:

> To resist \(d\)-th order probing attacks, you often need \(d+1\) shares  
> (exact theorems depend on the security model and gadgets).

So when someone says **higher-order masked Kyber**, they mean Kyber where secrets are split into **enough shares** that basic single-point power analysis is not enough — and usually they implement **order-2 or order-3** gadgets for the hard operations (mul, compression, etc.).

---

## Toy numeric picture

Secret \(s = 7\), modulus \(q = 3329\).

**Unmasked:** CPU holds `7`. Leakage can correlate with 7.

**First-order (2 shares):** pick random \(r\)

\[
s_0 = r, \quad s_1 = (s - r) \bmod q
\]

Example: \(s_0 = 100\), \(s_1 = 3236\) because \(100 + 3236 = 3336 \equiv 7 \pmod{3329}\).

Looking at only \(s_0\) tells you almost nothing about \(s\).

**Second-order attack idea:** somehow use information about **both** \(s_0\) and \(s_1\) (or two related intermediates) and recombine statistically.

**Second-order masking:** use three shares \(s_0+s_1+s_2 \equiv s\), so the attacker needs an even richer combination of leaks.

---

## Why papers still break “higher-order” masked Kyber

Protection level is a **claim under a model**. Real chips leak in messy ways. Published work (2024–2025) recovered keys from 2nd/3rd-order masked Kyber/Dilithium on Cortex-M4 with thousands of traces using **HOCPA** and related methods.

So “higher-order masked” is **necessary but not automatically sufficient**. Your project’s job is to implement it carefully, measure (or simulate) attacks, and report honest numbers.

---

## How to say it out loud

> “Higher-order” here means multi-share masking against multi-point side-channel attacks — not calculus.
