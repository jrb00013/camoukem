# Beyond additive masking: spatial / θ-domain encoding

**Idea (user):** don’t only split secrets into additive shares — *integrate* pieces, *spin* their logic (invert / rotate), and represent magnitude-like values in a **spatial / angular** domain: **\(r\) as \(\theta\)**.

This note applies three lenses:

1. **Locksmith genius** — reframe the SCA blocker  
2. **Applied math** — invent the structure before equations harden  
3. **Math-bitch** — one governing formulation + tiered claims  

It is a **research direction**, not a claim that this already replaces ISW masking.

---

## Locksmith genius

### 1. Reframe the Reality

The usual question:

> “How do I split \(s\) so HW(\(s\)) doesn’t leak?”

That accepts the attacker’s coordinate system: **the secret is a register integer whose Hamming weight is meaningful.**

Change the question:

> “How do I store a *representation* of \(s\) such that the physically leaked functional (HW, transitions, EM) is **almost independent of \(s\)** — even before multi-share probing games — because \(s\) lives in a different geometric chart?”

Masking fights leakage **in the same chart** (additive shares of the same integer).  
Spatial / θ encoding **changes the chart**. The blocker “HOCPA eats my shares” becomes less central if the map from secret → leaked observable is redesigned.

### 2. The Outsider Loop

Outsider connection: **\( \mathbb{F}_q^\times \) is already a circle.**

For Kyber, \(q = 3329\) is prime, so \(\mathbb{F}_q\) is a field and

\[
\mathbb{F}_q^\times \cong \mathbb{Z}/(q-1)\mathbb{Z}
\]

as cyclic groups. Every nonzero residue \(r\) has a discrete logarithm (“angle”)

\[
r = g^{\theta} \pmod{q}
\]

for a fixed generator \(g\). That is literally **\(r\) represented as \(\theta\)**.

“Spin their logic around” becomes: multiply by a random unit \(u \in \mathbb{F}_q^\times\)

\[
r \mapsto u\cdot r \pmod{q}
\]

which is a **rotation of the angle** \(\theta \mapsto \theta + \log_g u\).  
“Invert” becomes the group inverse \(r \mapsto r^{-1}\) (angle \(\theta \mapsto -\theta\)).

NTT is already a **spatial/frequency** change of basis on the polynomial. Combining:

- random **ring automorphism / twiddle spin** in NTT domain, plus  
- **multiplicative / angular** encoding of nonzero coeffs, plus  
- classical additive shares  

is an outsider stack: geometry + masking, not masking alone.

### 3. The System Fix

Long-term: define a **representation layer** \(\mathcal{R}\) above Kyber arithmetic:

- secrets never sit as naked \(\mathbb{Z}_q\) coefficients in hot loops  
- all public ops lift through \(\mathcal{R}\) with proven (or simulated) leakage maps  
- NEON kernels operate on the chosen chart (additive shares, angular, or hybrid)  
- HOCPA evaluates the **chart**, not only the share count  

Then “order-d masking” is one module inside a larger **leakage-aware coordinate system**, not the whole defense.

---

## Applied math (discovery mode)

### System (plain language)

You have secret numbers on a chip. The chip glows a little (power) when it wiggles those numbers. Attackers guess the secret by matching the glow. People usually break the secret into random pieces that add up. You want something else: glue pieces differently, flip/rotate how they mean, and talk about the secret as a **direction/angle** in a space instead of a raw count.

### Inventory

| Kind | Items |
| --- | --- |
| **Entities** | coefficients in \(\mathbb{Z}_q\); polynomials; NTT-domain values; random units; shares; CPU registers; leakage samples |
| **Actions** | add/mul mod \(q\); NTT butterfly; encode/decode to θ; spin by unit; invert; refresh randomness; emit leakage |
| **Measurable** | HW(register); cycle counts; correlation scores; #traces to key recovery; share count \(d+1\) |
| **Constraints** | must decaps correctly (KATs); \(q=3329\); timing CT; encode must be invertible on used domain; 0 is special (no log) |

### Representations

1. **Diagram:** secret → encoder \(\mathcal{R}\) → spun shares → NEON ops → decoder → same shared secret  
2. **Sequence:** refresh → spin → NTT → basemul → inv-spin → combine  
3. **Hand example:** \(q=3329\), \(s=7\), generator \(g\), \(\theta=\log_g 7\), spin by \(u\), check \(u^{-1}(u\cdot 7)=7\)

### Candidate invariants

| Candidate | Status |
| --- | --- |
| Decoded value \(= s\) after all spins/shares | **must be exact conserved** (correctness invariant) |
| Uniformity of each stored share / angle | desired statistical invariant under refresh |
| HW(\(g^\theta\)) as function of \(\theta\) | **not** invariant — this is the leakage curve you design against |
| NTT twiddle structure | structural invariant of the ring |

**Break attempt:** θ-encoding fails at \(0\) (no discrete log). Any scheme must special-case zeros or stay in a representation that includes 0 (e.g. projective / affine: store \((a,b)\) with \(a\cdot s + b\), or store \((\theta, \mathsf{iszero})\)).

### Candidate symmetries

- **Relabel shares** — still required for masking-like security  
- **Multiply by unit (circle rotation)** — symmetry of \(\mathbb{F}_q^\times\); correctness depends only on undoing the spin  
- **NTT basis change** — unitary-like (invertible) symmetry of the poly ring  
- **Description symmetry:** additive chart vs angular chart — same secret, different observables  

What forms get ruled out: any encoding whose decode is not a group homomorphism / known inverse on the nose (breaks KATs).

### Dimensionless / scaling groups

Leakage security isn’t physics units, but you still get ratios:

- \(\tau = N_{\text{traces to break}} / N_{\text{traces unmasked}}\) — security gain  
- \(\kappa = \text{cycles maskedθ} / \text{cycles unmasked}\) — cost  
- \(\sigma\) = noise level in sim model  

Useful plot: \(\tau(\kappa)\) — gain per slowdown. A θ-scheme that doubles \(\kappa\) but doesn’t raise \(\tau\) is a failed chart change.

### Candidate state variables

Obvious: raw coefficient \(s\).  
Better Markov state for leakage design: **\((\theta, u, \mathbf{shares})\)** or affine \((a,b)\).  
History summary that matters: last refresh seed (must not be predictable).

### Conceptual model (category first)

Not an ODE. This is:

- **finite-field / cyclic-group encoding** +  
- **invertible random gauge (spin)** +  
- optional **additive ISW masking** in the chosen chart +  
- **empirical leakage map** \(L\circ\mathrm{repr}\)

### Domain of validity

Works best for **nonzero** frequent intermediates, sim-HW models, software-first Orin.  
Fails or needs patches for: exact zero coeffs, Boolean Keccak world, claims of physical SCA security without traces, “order-d probing security” proofs that ignore the new encode gadgets.

### Failed guesses worth recording

| Guess | Why it fails | What it taught |
| --- | --- | --- |
| “Just store float θ = 2π s/q” | Not exact in \(\mathbb{Z}_q\); decode error destroys KEM | Stay discrete: \(\theta\in\mathbb{Z}/(q-1)\) |
| “Polar (r,θ) with r=|s|” | On \(\mathbb{Z}_q\), absolute value isn’t the field structure | Use multiplicative angle, not ℝ-polar |
| “Spin replaces masking” | Single spun value still leaks a deterministic fn of s | Spin is a **chart/gauge**; still need randomness + shares |
| “NTT alone is spatial masking” | NTT is public linear; doesn’t hide secrets by itself | NTT is a place to *apply* spins/shares, not a mask |

---

## Math-bitch: governing formulation

### Constraint table

| # | Requirement | Becomes | Carrier |
| --- | --- | --- | --- |
| c₁ | Correct decaps / KATs | exact decode invariant | invertible encode \(\mathcal{E}\), decode \(\mathcal{D}\) |
| c₂ | Secret not stored naked | representation map | \(\mathcal{R}(s; \rho)\) with randomness \(\rho\) |
| c₃ | “r as θ” | angular chart on \(\mathbb{F}_q^\times\) | discrete log / exp base \(g\) |
| c₄ | “spin / invert logic” | random gauge | multiply by \(u\in\mathbb{F}_q^\times\); optional \(s\mapsto s^{-1}\) involution |
| c₅ | Integrate pieces | multi-factor or hybrid share | multiplicative shares and/or additive shares in chart |
| c₆ | Resist HOCPA (sim) | leakage nearly independent of s | objective on mutual information / correlation |
| c₇ | Implementable in NEON | word-level ops | table-free CT exp/log or avoid explicit log |

### Objects

\[
\begin{aligned}
&q = 3329,\quad
\mathbb{F}_q,\quad
g\in\mathbb{F}_q^\times\ \text{generator},\quad
s\in\mathbb{F}_q, \\
&\rho = (u, r_0,\ldots,r_d)\ \text{fresh randomness},\quad
L:\{\text{register words}\}\to\mathbb{R}\ \text{leakage}.
\end{aligned}
\]

### Master representation (hybrid angular–additive)

For nonzero \(s\) (zero handled by a flag or affine lift):

\[
\begin{aligned}
\theta &= \log_g(s), \\
\tilde\theta_0 &= \theta + \log_g(u) + a_0, \\
\tilde\theta_i &= a_i \quad (i=1,\ldots,d),\quad
\sum_{i=0}^d a_i \equiv 0 \pmod{q-1}, \\
\text{store } &\big(g^{\tilde\theta_0},\ldots,g^{\tilde\theta_d}\big)
= \big(u\, s\cdot g^{a_0},\ g^{a_1},\ldots,g^{a_d}\big).
\end{aligned}
\]

Decode:

\[
\mathcal{D} = u^{-1}\prod_{i=0}^d \mathrm{store}_i
= s
\quad\text{when }\sum a_i = 0.
\]

(Equivalent multiplicative-share view: factors whose product is \(s\), with a public spin absorbed into the gauge \(u\).)

### Leakage objective (what you optimize in sim)

\[
\mathcal{J}(\mathcal{R})
=
\mathbb{E}\big[\mathrm{Corr}\big(L(\mathcal{R}(s;\rho)),\ \phi(s)\big)^2\big]
+
\lambda\,\kappa(\mathcal{R})
-
\mu\,\tau(\mathcal{R})
\]

- \(\phi(s)\): attacker prediction (HW(s), HW(s·t), …)  
- \(\kappa\): cycle overhead  
- \(\tau\): traces-to-break under fixed HOCPA  
- Want **small correlation**, **bounded \(\kappa\)**, **large \(\tau\)**

Stationarity is experimental: search encodings/gadgets that minimize \(\mathcal{J}\) under KAT hard constraint \(c_1\).

### Bit / security ledger (honesty)

| Claim | Tier | Status |
| --- | --- | --- |
| Discrete log chart exists on \(\mathbb{F}_q^\times\) | **T0** | definitional |
| Spin-by-unit preserves correctness | **T1** | easy group proof |
| Hybrid θ + additive shares improves sim-HOCPA vs additive alone | **T4/T5** | must measure — not assumed |
| Probing-model security at order \(d\) | **T1 only after gadget proofs** | open for new encode ops |
| Real-chip SCA security | **not claimed** in software-first thesis | needs physical eval |

**Reduction gate:** \(u=1\), \(d=0\) → naked \(s\). \(u=1\), additive-only in value domain → classical masking. Good.

**Null-space gate:** explicit \(\log_g\) tables can leak via addresses — forbidden in CT asm; prefer **never materialize \(\theta\)** and only use mul-by-unit + multiplicative shares (angle stays implicit).

### Practical NEON-friendly form (avoid explicit log)

Store multiplicative shares directly:

\[
s \equiv u^{-1}\prod_{i=0}^{d} s_i \pmod{q}
\quad\text{(nonzero case)}
\]

“θ-domain” is the **interpretation** (\(s_i = g^{\theta_i}\)); the **implementation** is modular multiplies — NEON-friendly — with CT inverse for \(u\) / share refresh.

Additive ISW masking remains for paths where mul-shares are awkward; conversions are the hard gadgets (as in classical literature).

---

## How this pushes the original thesis

| Layer | Role |
| --- | --- |
| Classical higher-order masking | probing resistance in a fixed chart |
| Unit spin / NTT-domain gauge | randomize geometric presentation |
| Multiplicative / θ interpretation | change HW–secret relationship |
| Sim-HOCPA on Orin | score whether the chart change actually helps |
| NEON kernels | make hybrid representation affordable |

**Recommended build order:** finish order-1 additive masked ML-KEM + NEON + sim-HOCPA **first**. Then A/B test a **multiplicative-share + random unit spin** path on the same simulator. If \(\tau\) rises at equal \(\kappa\), you have a real result. If not, the geometry was a beautiful failed guess — and that is still publishable learning.

---

## One-sentence summary

You’re not replacing masking with vibes — you’re proposing a **change of coordinates on \(\mathbb{F}_q^\times\)** (angle / spin) plus share product structure, so leakage sees a different function of the secret; the Orin project becomes the lab that **measures** whether that coordinate change buys HOCPA hardeness beyond share-count alone.
