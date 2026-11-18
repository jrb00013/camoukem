# Project plan (software-first, Orin)

## Thesis

> Higher-order masked ML-KEM-768 with AArch64 NEON kernels and software-simulated HOCPA evaluation on Jetson Orin.

Optional research extension: **spatial / θ-domain encoding** of shares ([09-spatial-theta-masking.md](09-spatial-theta-masking.md)).

## Phases

### A — Unmasked truth
- ML-KEM-768 KATs
- C reference on Orin
- Unmasked NEON NTT stub

### B — Order-1 masking
- Arithmetic 2-share polys
- Masked NTT / basemul gadgets
- Full decaps still correct

### C — NEON asm
- Butterflies, reduce, basemul in AArch64 NEON
- Cycle benches vs masked C

### D — Order-2 + sim-HOCPA
- Lift critical gadgets to 3 shares
- HW(+noise) trace simulator
- Attempt HOCPA; publish trace counts

### E — Spatial / θ stretch (research)
- Encode nonzero residues via group angle
- Random “spin” (multiply by unit) as share transport
- Compare leakage sim vs arithmetic masking alone

## Success criteria

- KATs pass at every phase
- DudeCT / no secret branches at `-O2`+
- Honest sim-HOCPA numbers
- Documented domain of validity (what model you beat)
