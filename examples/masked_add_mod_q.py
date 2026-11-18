#!/usr/bin/env python3
"""Tiny demo: first-order arithmetic masking for add mod q=3329 (Kyber prime).

Not production crypto. For learning only.
"""

from __future__ import annotations

import random

Q = 3329


def share(s: int, rng: random.Random) -> tuple[int, int]:
    s0 = rng.randrange(Q)
    s1 = (s - s0) % Q
    return s0, s1


def unshare(s0: int, s1: int) -> int:
    return (s0 + s1) % Q


def masked_add(a: tuple[int, int], b: tuple[int, int]) -> tuple[int, int]:
    return (a[0] + b[0]) % Q, (a[1] + b[1]) % Q


def main() -> None:
    rng = random.Random(0)
    a, b = 7, 100
    sa, sb = share(a, rng), share(b, rng)
    sc = masked_add(sa, sb)
    assert unshare(*sc) == (a + b) % Q
    print(f"a={a} shares={sa}")
    print(f"b={b} shares={sb}")
    print(f"a+b={(a+b)%Q} masked_sum_shares={sc} recomposed={unshare(*sc)}")
    print("ok")


if __name__ == "__main__":
    main()
