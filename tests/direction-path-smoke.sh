#!/usr/bin/env bash
# direction-path-smoke — Guided propose → select → rebut → seal gate path.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
C="$ROOT/bin/consult"
TMP=$(mktemp -d)
CLIENT="direction-smoke-$$"
EDIR="$ROOT/state/engagements/$CLIENT"
SOURCE="$TMP/client"
cleanup() {
  "$C" workspace "$CLIENT" remove >/dev/null 2>&1 || true
  rm -rf "$EDIR" "$TMP"
}
trap cleanup EXIT

mkdir -p "$SOURCE" "$EDIR/judgment"
git -C "$SOURCE" init -q
git -C "$SOURCE" config user.email direction-smoke@example.invalid
git -C "$SOURCE" config user.name 'Direction Smoke'
printf '# stub\n' > "$SOURCE/README.md"
git -C "$SOURCE" add README.md
git -C "$SOURCE" commit -qm initial

cat > "$EDIR/engagement.md" <<EOF
# Direction path smoke
Mode: **Guided**
Repo: $SOURCE
Mission: Prove Guided direction team path.
EOF
cat > "$EDIR/contract.json" <<'EOF'
{"contract":"direction-smoke-v1","scorer":"provider"}
EOF

expect_refuse() {
  local label="$1"; shift
  if "$C" "$@" >"$TMP/out" 2>&1; then
    printf 'FAIL %s unexpectedly passed\n' "$label" >&2
    cat "$TMP/out" >&2
    exit 1
  fi
}
expect_pass() {
  local label="$1"; shift
  if ! "$C" "$@" >"$TMP/out" 2>&1; then
    printf 'FAIL %s unexpectedly refused\n' "$label" >&2
    cat "$TMP/out" >&2
    exit 1
  fi
}

# Guided implement refuses without selection (existing behavior)
expect_refuse guided-implement-no-selection gate "$CLIENT" implement
grep -q 'no selection recorded' "$TMP/out"
printf 'PASS direction-guided-implement-refuse\n'

# propose without Guided refuses
"$C" judge "$CLIENT" set Directive >/dev/null
expect_refuse propose-not-guided direction "$CLIENT" propose \
  --title 'T' --tradeoffs 'X' --lift 'correctness'
grep -q 'requires Guided mode' "$TMP/out"
printf 'PASS direction-propose-not-guided\n'

"$C" judge "$CLIENT" set Guided >/dev/null

# propose three directions
expect_pass propose-d1 direction "$CLIENT" propose \
  --title 'Harden CLI gates' --tradeoffs 'More files, clearer UX' \
  --lift 'correctness: fewer silent failures' --evidence lib/judgment-gate.sh --by Meridian
expect_pass propose-d2 direction "$CLIENT" propose \
  --title 'Shrink onboarding' --tradeoffs 'Less hand-holding' \
  --lift 'usability: faster cold start' --by Kai
expect_pass propose-d3 direction "$CLIENT" propose \
  --title 'Document judgment modes' --tradeoffs 'Docs churn' \
  --lift 'documentation: JUDGMENT.md clarity' --by Meridian

# propose 4th when max=3 refuses
expect_refuse propose-max direction "$CLIENT" propose \
  --title 'Fourth idea' --tradeoffs 'Too many' --lift 'none'
grep -q 'max 3' "$TMP/out"
printf 'PASS direction-propose-max\n'

# list shows named proposers
list_out=$("$C" direction "$CLIENT" list)
grep -q 'Meridian' <<<"$list_out"
grep -q 'Kai' <<<"$list_out"
grep -q 'proposers: Kai (Principal), Meridian (Analyst)' <<<"$list_out"
jq -e '.proposed_by | map(.display_name) | index("Kai") != null and index("Meridian") != null' \
  "$EDIR/judgment/proposals.json" >/dev/null
# --json must be machine-clean (no human banner) so scripts can jq it
"$C" direction "$CLIENT" list --json | jq -e '.directions | length == 3 and .[0].id == "d1"' >/dev/null
printf 'PASS direction-list-named-proposers\n'

# select by id binds proposal_id
expect_pass select-by-id gate "$CLIENT" select d1 Kai
jq -e '.direction == "Harden CLI gates" and .proposal_id == "d1" and .display_name == "Kai"' \
  "$EDIR/judgment/selection.json" >/dev/null
printf 'PASS direction-select-by-id\n'

# Builder seal refuses without critic rebuttal (Guided)
printf 'Implement Harden CLI gates with smallest diff.\n' > "$TMP/builder-input.txt"
expect_refuse seal-no-rebuttal role "$CLIENT" seal 1 "$TMP/builder-input.txt"
grep -q 'missing Critic rebuttal' "$TMP/out"
printf 'PASS direction-seal-no-rebuttal\n'

# Builder seal refuses when REJECT
"$C" direction "$CLIENT" rebut 1 REJECT 'Scope too wide for one iter.' >/dev/null
expect_refuse seal-reject role "$CLIENT" seal 1 "$TMP/builder-input.txt"
grep -q 'verdict REJECT' "$TMP/out"
printf 'PASS direction-seal-reject\n'

# Builder seal refuses when input omits bound direction
"$C" direction "$CLIENT" rebut 1 ACCEPT 'Proceed with smallest slice.' >/dev/null
printf 'Unrelated task without citing direction.\n' > "$TMP/bad-input.txt"
expect_refuse seal-no-direction-cite role "$CLIENT" seal 1 "$TMP/bad-input.txt"
grep -q 'must cite bound direction' "$TMP/out"
printf 'PASS direction-seal-no-direction-cite\n'

# Builder seal passes after ACCEPT + input cites direction
expect_pass seal-ok role "$CLIENT" seal 1 "$TMP/builder-input.txt"
[[ -f "$EDIR/roles/iter-1/Builder/seal.json" ]]
printf 'PASS direction-seal-accept\n'

# Builder invoke refuses without seal on an iter that already has Critic rebuttal
"$C" direction "$CLIENT" rebut 2 ACCEPT 'Pending seal.' >/dev/null
expect_refuse builder-no-seal role "$CLIENT" invoke Builder 2
grep -q 'missing sealed Builder input' "$TMP/out"
printf 'PASS direction-builder-no-seal\n'
printf 'Implement Harden CLI gates: add one test.\n' > "$TMP/builder-2.txt"
expect_pass seal-2 role "$CLIENT" seal 2 "$TMP/builder-2.txt"
if CONSULT_PROVIDER=/nonexistent/direction-provider "$C" role "$CLIENT" invoke Builder 2 >"$TMP/out" 2>&1; then
  printf 'FAIL builder-invoke unexpectedly passed without provider\n' >&2
  exit 1
fi
grep -q 'provider' "$TMP/out"
jq -e '.exit != 0' "$EDIR/roles/iter-2/Builder/attempt-1/result.json" >/dev/null
printf 'PASS direction-builder-invoke-after-seal\n'

# Challenge/Override gates still enforced (minimal)
expect_refuse challenge-without-record gate "$CLIENT" challenge 'bad' 'good' 'evidence/x'
grep -q 'requires Challenge' "$TMP/out"
"$C" judge "$CLIENT" set Challenge >/dev/null
expect_pass challenge-write gate "$CLIENT" challenge 'ship AI' 'keep prototype' 'evidence/advisor.json'
expect_refuse challenge-harmful gate "$CLIENT" implement 'ship AI'
grep -q 'harmful path' "$TMP/out"
printf 'PASS direction-challenge-still-enforced\n'

"$C" judge "$CLIENT" set Override >/dev/null
expect_refuse override-empty gate "$CLIENT" override 'go' '' 'crit' 'ev'
grep -q 'non-empty' "$TMP/out"
printf 'PASS direction-override-still-enforced\n'

printf 'direction-path smoke: all gates exercised\n'
