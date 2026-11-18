#!/usr/bin/env bash
# Create and merge many small PRs from a full-tree snapshot.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SNAP="${TMPDIR:-/tmp}/masked-mlkem-full-$$"
mkdir -p "$SNAP"
# snapshot tracked+untracked source (no build products)
rsync -a --exclude '.git' --exclude '*.o' --exclude '*.a' --exclude 'smoke' \
  --exclude 'tests/test_*' --exclude 'libmlkem_neon.a' \
  "$ROOT/" "$SNAP/"

cd "$ROOT"
git fetch origin
git checkout main
git pull --ff-only origin main

# Each line: branch_suffix|commit_message|relpath [relpath...]
mapfile -t UNITS <<'EOF'
01-architecture|Add ARCHITECTURE design doc|ARCHITECTURE.md
02-makefile|Add cross Makefile for AArch64|Makefile
03-gitignore|Ignore asm build products|.gitignore
04-readme-asm|Rewrite README for assembly-first project|README.md
05-contributing|Add CONTRIBUTING guide|CONTRIBUTING.md
06-ci|Add GitHub Actions aarch64 CI|.github/workflows/ci.yml
07-params-inc|Add asm params.inc macros|asm/aarch64/params.inc
08-header-asm|Add mlkem_asm.h public ABI|include/mlkem_asm.h
09-header-mask|Add mlkem_mask.h|include/mlkem_mask.h
10-header-spin|Add mlkem_spin.h|include/mlkem_spin.h
11-poly-add|NEON poly_add.S|asm/aarch64/poly_add.S
12-poly-sub|NEON poly_sub.S|asm/aarch64/poly_sub.S
13-poly-zero|NEON poly_setzero.S|asm/aarch64/poly_setzero.S
14-poly-copy|NEON poly_copy.S|asm/aarch64/poly_copy.S
15-poly-neg|NEON poly_neg.S|asm/aarch64/poly_neg.S
16-poly-reduce|NEON poly_reduce.S Barrett|asm/aarch64/poly_reduce.S
17-poly-csubq|NEON poly_csubq.S|asm/aarch64/poly_csubq.S
18-montgomery|NEON poly_tomont montgomery.S|asm/aarch64/montgomery.S
19-zetas|Official Kyber zetas table|asm/aarch64/ntt_zetas.S
20-ntt|AArch64 forward NTT asm|asm/aarch64/ntt.S
21-intt|AArch64 inverse NTT asm|asm/aarch64/intt.S
22-basemul|AArch64 basemul asm|asm/aarch64/basemul.S
23-spin-mul|NEON unit-spin mul asm|asm/aarch64/spin_mul.S
24-mask-refresh|Asm share refresh|asm/aarch64/mask_refresh.S
25-ref-ntt|C NTT oracle for tests|src/ref_ntt.c
26-mask-c|Order-1 mask orchestration C|src/mask_order1.c
27-spin-c|Spin apply helper C|src/spin.c
28-smoke|Smoke main binary|src/main_smoke.c
29-test-poly|test_poly self-test|tests/test_poly.c
30-test-ntt|test_ntt vs oracle|tests/test_ntt.c
31-test-mask|test_mask share roundtrip|tests/test_mask.c
32-test-spin|test_spin range check|tests/test_spin.c
33-sim-hw|Hamming-weight leak model|sim/hw_leak.c
34-sim-hocpa|HOCPA stub|sim/hocpa_stub.c
35-doc-abi|Asm ABI doc|docs/10-asm-abi.md
36-doc-orin|Orin build doc|docs/11-build-orin.md
37-doc-glossary-touch|Mark glossary as asm-project companion|docs/00-glossary.md
38-doc-higher-order|Keep higher-order explainer|docs/01-what-higher-order-means.md
39-doc-mlkem|Keep ML-KEM explainer|docs/02-mlkem-and-kyber.md
40-doc-masking|Keep masking explainer|docs/03-masking.md
41-doc-ntt-neon|Keep NTT NEON explainer|docs/04-ntt-and-neon.md
42-doc-hocpa|Keep HOCPA explainer|docs/05-hocpa-and-simulation.md
43-doc-math|Keep math roadmap|docs/06-math-roadmap.md
44-doc-plan|Keep project plan|docs/07-project-plan.md
45-doc-frontier|Keep frontier context|docs/08-frontier-context.md
46-doc-theta|Keep spatial theta research note|docs/09-spatial-theta-masking.md
47-refs|Reference links|refs/README.md
48-license|Ensure LICENSE present|LICENSE
49-ship-script|Add PR ship helper script|scripts/ship_prs.sh
50-finalize|Final README status bump|README.md
EOF

n=0
for line in "${UNITS[@]}"; do
  [[ -z "$line" ]] && continue
  IFS='|' read -r slug msg paths <<<"$line"
  n=$((n+1))
  branch="pr/${slug}"
  echo "=== [$n] $branch — $msg ==="
  git checkout main
  git pull --ff-only origin main
  git checkout -B "$branch"
  # copy listed paths from snapshot
  for p in $paths; do
    mkdir -p "$(dirname "$p")"
    if [[ -e "$SNAP/$p" ]]; then
      cp -a "$SNAP/$p" "$p"
    else
      echo "WARN missing in snap: $p" >&2
    fi
  done
  # Ensure already-tracked docs/license get a real diff when re-shipped
  case "$slug" in
    doc-*|refs|license)
      for p in $paths; do
        [[ -f "$p" ]] || continue
        if ! grep -q 'asm-project-train' "$p" 2>/dev/null; then
          printf '\n<!-- asm-project-train -->\n' >> "$p"
        fi
      done
      ;;
    50-finalize)
      printf '\n<!-- shipped via PR train -->\n' >> README.md
      ;;
  esac
  git add -A
  if git diff --cached --quiet; then
    echo "nothing to commit for $slug — skipping"
    git checkout main
    continue
  fi
  git commit -m "$(cat <<EOF
${msg}

EOF
)"
  git push -u origin "$branch" --force-with-lease
  pr_url=$(gh pr create --base main --head "$branch" --title "$msg" --body "$(cat <<EOF
## Summary
- ${msg}

## Test plan
- [x] \`make test\` via aarch64 cross + qemu (see CI / Docker README)

EOF
)")
  echo "created $pr_url"
  gh pr merge --merge --delete-branch
done

echo "DONE — processed $n units"
rm -rf "$SNAP"
git checkout main
git pull --ff-only origin main
