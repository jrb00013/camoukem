# HOCPA and software-simulated evaluation

## CPA in one line

Guess a secret fragment → predict an intermediate value → correlate prediction with leakage. Best guess wins.

## Higher-order CPA (HOCPA)

Because of masking, one intermediate is random-looking. HOCPA **combines** leakage from multiple points (or processed share pairs), then correlates.

That is the attack class that broke published 2nd/3rd-order masked Kyber/Dilithium on Cortex-M4 in recent work.

## Software simulation (no scope)

Pretend the chip leaks:

\[
L(x) = \mathrm{HW}(x) + \mathcal{N}(0,\sigma^2)
\]

or a more faithful model later. Run your masked code, emit synthetic traces, run HOCPA offline on the Orin.

**What this proves:** resistance under the *chosen leakage model*.  
**What it does not prove:** resistance on every real MCU with every probe setup.

For a software-first thesis, sim-HOCPA is the correct evaluation spine.
