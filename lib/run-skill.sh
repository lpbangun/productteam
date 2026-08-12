#!/usr/bin/env bash
# run-skill.sh — invoke first-party product skills via the real provider seam.
# Usage: run-skill.sh <skill> <target> [out-dir]
# Skills: critique | benchmark | design-sprint
# No templates-as-answers. Every artifact is model output from provider_ask.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/provider.sh
source "$ROOT/lib/provider.sh"

SKILL="${1:-}"
TARGET="${2:-}"
OUT="${3:-}"

die() { printf 'productteam skill: %s\n' "$1" >&2; exit 1; }

[[ -n "$SKILL" && -n "$TARGET" ]] || die "usage: productteam skill <critique|benchmark|design-sprint> <repo-or-client> [out-dir]"

case "$SKILL" in
  critique|benchmark|design-sprint) ;;
  *) die "unknown skill '$SKILL' (critique|benchmark|design-sprint)" ;;
esac

SKILL_DIR="$ROOT/skills/$SKILL"
[[ -f "$SKILL_DIR/SKILL.md" ]] || die "missing $SKILL_DIR/SKILL.md"

REPO=""
if [[ -d "$TARGET" ]]; then
  REPO="$(cd "$TARGET" && pwd)"
elif [[ -d "$ROOT/state/engagements/$TARGET" ]]; then
  REPO=$(awk -F': ' '/^Repo:/{print $2; exit}' "$ROOT/state/engagements/$TARGET/engagement.md")
elif [[ "$TARGET" == harness-evolution || "$TARGET" == harness ]]; then
  REPO="$ROOT"
elif [[ -d "/home/logani/projects/$TARGET" ]]; then
  REPO="/home/logani/projects/$TARGET"
else
  die "cannot resolve target '$TARGET' to a repo"
fi
[[ -d "$REPO" ]] || die "repo not found: $REPO"

TS=$(date -u +%Y%m%dT%H%M%SZ)
RUNTIME=$(runtime_default 2>/dev/null || true)
[[ -n "$RUNTIME" ]] || die "no coding runtime found — run productteam agents, install one, or set CONSULT_PROVIDER"

if [[ -z "$OUT" ]]; then
  OUT="$ROOT/state/harness-evolution/runs/skills/${SKILL}-${TS}"
fi
mkdir -p "$OUT"
cp "$SKILL_DIR/SKILL.md" "$OUT/SKILL.md"

NAME=$(basename "$REPO")
GUIDANCE=""
[[ -f "$REPO/GUIDANCE.md" ]] && GUIDANCE=$(cat "$REPO/GUIDANCE.md")
README=""
[[ -f "$REPO/README.md" ]] && README=$(head -80 "$REPO/README.md")
TREE=$(find "$REPO" -maxdepth 3 -type f ! -path '*/.git/*' ! -path '*/node_modules/*' ! -path '*/dist/*' ! -path '*/__pycache__/*' 2>/dev/null | head -80)

skill_header() {
  printf 'Runtime: %s\nTimestamp: %s\nRepo: %s\nSkill: %s\n' "$RUNTIME" "$TS" "$REPO" "$SKILL"
}

case "$SKILL" in
  critique)
    prompt=$(cat <<EOF
You are running the /critique skill for the Product Consulting Harness.
Write a product critique of the repository below. Cite at least two real
file paths that appear in the tree. If GUIDANCE.md is present, use at least
one distinctive term from it. Prefer deletion over addition. No filler.

$(skill_header)

## GUIDANCE.md
$GUIDANCE

## README (excerpt)
$README

## Tree (depth ≤3)
$TREE

Output markdown with sections: Product clarity, Target user, Friction,
Prioritized recommendations (each citing a path), Evidence.
EOF
)
    reply=$(provider_ask "$prompt" "$REPO") || die "provider_ask failed (runtime=$RUNTIME) — no artifact written"
    {
      printf '# Product critique — %s\n\n' "$NAME"
      skill_header
      printf '\n%s\n' "$reply"
    } > "$OUT/critique.md"
    printf '%s\n' "$OUT/critique.md"
    ;;
  benchmark)
    prompt=$(cat <<EOF
You are running the /benchmark skill. Draft a FROZEN-style benchmark contract
for this specific repository — not a generic six-item starter list.
Name dimensions that reflect THIS project's domain and GUIDANCE.md risks.
Cite at least two real paths from the tree in the contract body.
Include acceptance threshold ≥9.0 and "no mocks" validation.

$(skill_header)

## GUIDANCE.md
$GUIDANCE

## README (excerpt)
$README

## Tree
$TREE

Output:
1) A markdown BENCHMARK-CONTRACT body
2) After a line that is exactly ---JSON---
3) A JSON object: {"contract":"<name>-v1","dimensions":["..."],"target":9.0}
EOF
)
    reply=$(provider_ask "$prompt" "$REPO") || die "provider_ask failed (runtime=$RUNTIME) — no artifact written"
    md="$reply"
    json_part=""
    if grep -q '^---JSON---$' <<<"$reply"; then
      md=$(sed '/^---JSON---$/,$d' <<<"$reply")
      json_part=$(sed -n '/^---JSON---$/,$p' <<<"$reply" | sed '1d')
    fi
    {
      printf '# BENCHMARK-CONTRACT — %s\n\n' "$NAME"
      skill_header
      printf '\n%s\n' "$md"
      if [[ -n "$json_part" ]]; then
        printf '\n## Machine-readable dimensions\n\n```json\n'
        printf '%s\n' "$json_part" | jq -c --arg r "$RUNTIME" --arg t "$TS" --arg s "$REPO" \
          '. + {runtime:$r, frozen:$t, subject:$s, skill:"benchmark", source:"BENCHMARK-CONTRACT.md"}' 2>/dev/null \
          || printf '%s\n' "$json_part"
        printf '```\n'
      fi
    } > "$OUT/BENCHMARK-CONTRACT.md"
    # No separate contract.json — no-mock-provider requires Runtime: on every
    # *.json, which cannot be valid JSON. Dimensions stay in the markdown.
    printf '%s\n' "$OUT/BENCHMARK-CONTRACT.md"
    ;;
  design-sprint)
    prompt=$(cat <<EOF
You are running the /design-sprint skill. Propose one bounded product direction
for this repository. Cite at least two real paths from the tree. Reflect
GUIDANCE.md language. Smallest diff. No vision rewrite.

$(skill_header)

## GUIDANCE.md
$GUIDANCE

## README (excerpt)
$README

## Tree
$TREE

Output markdown: Problem, Users, Direction, Scope in/out, Milestones, Risks,
Validation, Expected impact.
EOF
)
    reply=$(provider_ask "$prompt" "$REPO") || die "provider_ask failed (runtime=$RUNTIME) — no artifact written"
    {
      printf '# Design sprint — %s\n\n' "$NAME"
      skill_header
      printf '\n%s\n' "$reply"
    } > "$OUT/design-sprint.md"
    printf '%s\n' "$OUT/design-sprint.md"
    ;;
esac

printf 'productteam skill: wrote artifacts under %s (runtime=%s)\n' "$OUT" "$RUNTIME" >&2
