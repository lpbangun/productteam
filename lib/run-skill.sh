#!/usr/bin/env bash
# run-skill.sh — invoke first-party product skills.
# Usage: run-skill.sh <skill> <target> [out-dir]
# Skills: critique | benchmark | design-sprint
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL="${1:-}"
TARGET="${2:-}"
OUT="${3:-}"

die() { printf 'consult skill: %s\n' "$1" >&2; exit 1; }

[[ -n "$SKILL" && -n "$TARGET" ]] || die "usage: consult skill <critique|benchmark|design-sprint> <repo-or-client> [out-dir]"

case "$SKILL" in
  critique|benchmark|design-sprint) ;;
  *) die "unknown skill '$SKILL' (critique|benchmark|design-sprint)" ;;
esac

SKILL_DIR="$ROOT/skills/$SKILL"
[[ -f "$SKILL_DIR/SKILL.md" ]] || die "missing $SKILL_DIR/SKILL.md"

# Resolve target to a repo path
REPO=""
if [[ -d "$TARGET" ]]; then
  REPO="$(cd "$TARGET" && pwd)"
elif [[ -d "$ROOT/state/engagements/$TARGET" ]]; then
  REPO=$(awk -F': ' '/^Repo:/{print $2; exit}' "$ROOT/state/engagements/$TARGET/engagement.md")
elif [[ "$TARGET" == harness-evolution || "$TARGET" == harness ]]; then
  REPO="$ROOT"
else
  # sibling under projects
  if [[ -d "/home/logani/projects/$TARGET" ]]; then
    REPO="/home/logani/projects/$TARGET"
  else
    die "cannot resolve target '$TARGET' to a repo"
  fi
fi
[[ -d "$REPO" ]] || die "repo not found: $REPO"

TS=$(date -u +%Y%m%dT%H%M%SZ)
if [[ -z "$OUT" ]]; then
  OUT="$ROOT/state/harness-evolution/runs/skills/${SKILL}-${TS}"
fi
mkdir -p "$OUT"
cp "$SKILL_DIR/SKILL.md" "$OUT/SKILL.md"

NAME=$(basename "$REPO")
README=""
[[ -f "$REPO/README.md" ]] && README=$(head -80 "$REPO/README.md")
TREE=$(find "$REPO" -maxdepth 2 -type f ! -path '*/.git/*' ! -path '*/node_modules/*' ! -path '*/dist/*' 2>/dev/null | head -60)

case "$SKILL" in
  critique)
    cat > "$OUT/critique.md" <<EOF
# Product critique — $NAME

**Skill:** /critique · **Repo:** $REPO · **When:** $TS

## Method
Structured audit from README + shallow tree. Findings cite paths.

## Product clarity
$( [[ -f "$REPO/README.md" ]] && echo "README present — skim first 80 lines for identity/audience." || echo "Missing README.md — clarity at risk." )

## Target user
Infer from README "Who" / audience sections; flag if absent.

## UX / navigation / onboarding
Inspect entry docs and primary UI/docs paths in the tree below.

## Accessibility
Note whether a11y tests or guidance exist in tree.

## Product direction / friction / priorities / risks
Prioritize by impact-per-change. Prefer deletion. Do not rewrite vision.

## Tree (depth 2, truncated)
\`\`\`
$TREE
\`\`\`

## README excerpt
\`\`\`
$README
\`\`\`

## Prioritized recommendations
1. (Fill from evidence above — highest leverage first)
2. …
3. …

## Evidence rule
Every recommendation must cite a path from this repo.
EOF
    printf '%s\n' "$OUT/critique.md"
    ;;
  benchmark)
    cat > "$OUT/BENCHMARK-CONTRACT.md" <<EOF
# BENCHMARK-CONTRACT — $NAME (FROZEN draft)

**Frozen:** $TS · **Subject:** $REPO

Implementers must not amend mid-run. Proposals → proposed-benchmark-changes.md.

## What success means
Measurable improvement on the dimensions below without changing product vision.

## Dimensions (starter — tailor with evidence)
1. correctness
2. usability
3. documentation
4. developer-experience
5. product-clarity
6. simplicity

## Scoring
0–10 one decimal. Score without path/check evidence is void.
- ≤5 broken/missing
- 6–8 usable with gaps
- 9–10 excellent with evidence

## Acceptance threshold
Every dimension ≥ 8.0 (adjust per engagement before freeze).

## Failure conditions
Secrets in artifacts; fake/mocked validation; vision rewrite; no Critic verdict.

## Validation methods
Real tests/builds/docs checks against $REPO. No mocks.

## Convergence
All dimensions ≥ threshold on one scored iteration + Critic accept.
EOF
    cat > "$OUT/contract.json" <<EOF
{
  "contract": "${NAME}-v1",
  "frozen": "$TS",
  "subject": "$REPO",
  "target": 8.0,
  "dimensions": ["correctness","usability","documentation","developer-experience","product-clarity","simplicity"],
  "source": "BENCHMARK-CONTRACT.md",
  "skill": "benchmark"
}
EOF
    printf '%s\n' "$OUT/BENCHMARK-CONTRACT.md"
    ;;
  design-sprint)
    cat > "$OUT/design-sprint.md" <<EOF
# Design sprint — $NAME

**Skill:** /design-sprint · **Repo:** $REPO · **When:** $TS

## Problem framing
What friction blocks users from the product's promised value?

## Target users
Who is this for (from README / evidence)? Who is it deliberately not for?

## Product direction
One sentence direction that respects existing vision.

## Implementation scope
Smallest diff that can move a frozen benchmark. List in/out of scope.

## Milestones
1. Inspect + lock benchmark
2. Implement bounded improvement
3. Real tests + review
4. PR (+ merge only if gates pass)

## Risks
Vision drift · scope creep · secrets · flaky validation

## Validation plan
Command-level evidence (test/build/docs checks) archived in run dir.

## Expected impact
Which benchmark dimensions should rise, and why?

## Evidence base
\`\`\`
$TREE
\`\`\`
EOF
    printf '%s\n' "$OUT/design-sprint.md"
    ;;
esac

printf 'consult skill: wrote artifacts under %s\n' "$OUT" >&2
