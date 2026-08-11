#!/usr/bin/env bash
# Real cold open → baseline bootstrap for Mission 3.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
C="$ROOT/bin/productteam"
TMP=$(mktemp -d)
CLIENT="bootstrap-smoke-$$"
EDIR="$ROOT/state/engagements/$CLIENT"
SOURCE="$TMP/client"
cleanup() {
  "$C" workspace "$CLIENT" remove >/dev/null 2>&1 || true
  rm -rf "$EDIR" "$TMP"
}
trap cleanup EXIT

mkdir -p "$SOURCE"
cat > "$SOURCE/README.md" <<'EOF'
# Bootstrap smoke client

Tiny sibling used only to prove productteam open → baseline without hand-writing
engagement trees.
EOF
git -C "$SOURCE" init -q
git -C "$SOURCE" config user.email bootstrap-smoke@example.invalid
git -C "$SOURCE" config user.name 'Bootstrap Smoke'
git -C "$SOURCE" add README.md
git -C "$SOURCE" commit -qm initial

expect_refuse() {
  local label="$1"; shift
  if CONSULT_NO_SPLASH=1 "$C" "$@" >"$TMP/out" 2>&1; then
    printf 'FAIL %s unexpectedly passed\n' "$label" >&2
    cat "$TMP/out" >&2
    exit 1
  fi
}

# Named refuses
expect_refuse open-repo-missing open "$CLIENT" --repo "$TMP/no-such-repo"
grep -q 'open-repo-missing' "$TMP/out"
printf 'PASS open-repo-missing\n'

expect_refuse open-repo-relative open "$CLIENT" --repo relative/path
grep -q 'open-repo-not-absolute' "$TMP/out"
printf 'PASS open-repo-not-absolute\n'

# Cold open (checks scorer, no runner → honest deferred baseline)
CONSULT_NO_SPLASH=1 "$C" open "$CLIENT" --repo "$SOURCE" --scorer checks --mode Guided --mission 'Prove open→baseline' >/dev/null
[[ -f "$EDIR/engagement.md" && -f "$EDIR/contract.json" && -f "$EDIR/open-stamp.json" && -f "$EDIR/BENCHMARK-CONTRACT.md" ]]
jq -e '.frozen and .scorer == "checks"' "$EDIR/contract.json" >/dev/null
grep -q "Repo: $SOURCE" "$EDIR/engagement.md"
CONSULT_NO_SPLASH=1 "$C" workspace "$CLIENT" status | jq -e '.exists == true and .path != .source_repo' >/dev/null
printf 'PASS open-cold-stub\n'

expect_refuse open-exists open "$CLIENT" --repo "$SOURCE"
grep -q 'open-exists' "$TMP/out"
printf 'PASS open-exists\n'

# Baseline honest default (no checks_runner)
CONSULT_NO_SPLASH=1 "$C" baseline "$CLIENT" >/dev/null
jq -e '.iter == 0 and .kind == "baseline" and .deferred == true and .overall == null and (.reason|contains("no checks_runner"))' \
  "$EDIR/runs/iter-0/scores.json" >/dev/null
jq -e '.operation == "baseline" and .path and .sha' "$EDIR/runs/iter-0/workspace.json" >/dev/null
printf 'PASS baseline-honest-default\n'

expect_refuse baseline-exists baseline "$CLIENT"
grep -q 'baseline-exists' "$TMP/out"
printf 'PASS baseline-exists\n'

# Provider open refuses cold baseline with named reason
CLIENT2="bootstrap-prov-$$"
EDIR2="$ROOT/state/engagements/$CLIENT2"
cleanup2() { "$C" workspace "$CLIENT2" remove >/dev/null 2>&1 || true; rm -rf "$EDIR2"; }
trap 'cleanup; cleanup2' EXIT
CONSULT_NO_SPLASH=1 "$C" open "$CLIENT2" --repo "$SOURCE" --scorer provider >/dev/null
expect_refuse baseline-provider baseline "$CLIENT2"
grep -q 'baseline-provider-requires-analyst' "$TMP/out"
printf 'PASS baseline-provider-requires-analyst\n'

printf 'PASS open-baseline-smoke\n'
