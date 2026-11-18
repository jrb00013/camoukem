# Why this gap still matters (2025–2026)

- FIPS 203 ML-KEM is standardized and deploying (often hybrid with X25519).
- Unmasked / merely “constant-time” code fails under power analysis on embedded.
- First- and higher-order masked Kyber exists in the literature — and **HOCPA still breaks** many of those implementations on Cortex-M4 with thousands of traces.
- The remaining push is not “invent Kyber again.” It is:
  - cheaper / stronger gadgets,
  - asm that does not reintroduce leakage,
  - evaluation under realistic (or honestly simulated) leakage,
  - and optionally **new encodings** of secrets that change what the physical leakage sees ([09](09-spatial-theta-masking.md)).

Classical assembly skills matter because the bottleneck moved from paper algorithms to **binaries that survive leakage**.
