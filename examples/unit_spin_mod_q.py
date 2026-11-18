#!/usr/bin/env python3
"""Demo: random unit 'spin' on F_q — the implementable shadow of θ-domain thinking.

s' = u * s  (mod q), decode = u_inv * s'.
Angle picture: if s = g^θ then s' = g^{θ + log u} (rotation on the circle F_q*).

Not production crypto. Learning only. Zero needs a special case (no inverse/log).
"""

from __future__ import annotations

import random

Q = 3329


def modinv(x: int, q: int = Q) -> int:
    if x % q == 0:
        raise ZeroDivisionError("no inverse of 0")
    return pow(x, q - 2, q)


def spin(s: int, rng: random.Random) -> tuple[int, int]:
    """Return (u, spun) with spun = u*s mod q, u nonzero."""
    u = rng.randrange(1, Q)
    return u, (u * s) % Q


def unspin(u: int, spun: int) -> int:
    return (modinv(u) * spun) % Q


def main() -> None:
    rng = random.Random(1)
    for s in (7, 1, 3328):
        u, spun = spin(s, rng)
        assert unspin(u, spun) == s
        print(f"s={s:4d}  u={u:4d}  spun={spun:4d}  recovered={unspin(u, spun)}")
    print("ok — spin is a correctness-preserving gauge; alone it is NOT masking")


if __name__ == "__main__":
    main()
