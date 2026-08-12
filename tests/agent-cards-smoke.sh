#!/usr/bin/env bash
# agent-cards-smoke — list/show/seed + role envelope display_name wiring.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
C="$ROOT/bin/productteam"
TMP=$(mktemp -d)
CLIENT="card-smoke-$$"
EDIR="$ROOT/state/engagements/$CLIENT"
SOURCE="$TMP/client"
cleanup() {
  "$C" workspace "$CLIENT" remove >/dev/null 2>&1 || true
  rm -rf "$EDIR" "$TMP"
}
trap cleanup EXIT

expect_refuse() {
  local label="$1"; shift
  if "$C" "$@" >"$TMP/out" 2>&1; then
    printf 'FAIL %s unexpectedly passed\n' "$label" >&2
    exit 1
  fi
}

# Permanent cards present
count=$("$C" card list --json | jq 'length')
[[ "$count" -eq 4 ]] || { printf 'FAIL list expected 4 permanent cards, got %s\n' "$count" >&2; exit 1; }
printf 'PASS card-list-four-permanent\n'

# Show by display name and role
show_md=$("$C" card show Meridian)
grep -q 'Meridian' <<<"$show_md"
"$C" card show Analyst --json | jq -e '.display_name == "Meridian" and .role == "Analyst"' >/dev/null
printf 'PASS card-show-name-and-role\n'

# Missing card refuses
expect_refuse card-missing card show NotARealCard
grep -qi 'unknown agent card' "$TMP/out"
printf 'PASS card-show-missing-refuses\n'

# Seed specialist into engagement
mkdir -p "$SOURCE"
git -C "$SOURCE" init -q
git -C "$SOURCE" config user.email card-smoke@example.invalid
git -C "$SOURCE" config user.name 'Card Smoke'
printf '# stub\n' > "$SOURCE/README.md"
git -C "$SOURCE" add README.md
git -C "$SOURCE" commit -qm initial
mkdir -p "$EDIR"
cat > "$EDIR/engagement.md" <<EOF
# Card smoke
Mode: **Directive**
Repo: $SOURCE
Mission: Agent card smoke engagement.
EOF
cat > "$EDIR/contract.json" <<'EOF'
{"contract":"card-smoke-v1","scorer":"provider"}
EOF
"$C" card seed-specialist "$CLIENT" Scout >"$TMP/seed.out"
[[ -f "$EDIR/agents/specialist.json" && -f "$EDIR/agents/specialist.md" ]]
jq -e '.display_name == "Scout" and .kind == "specialist"' "$EDIR/agents/specialist.json" >/dev/null
"$C" card show Scout "$CLIENT" --json | jq -e '.display_name == "Scout" and .kind == "specialist"' >/dev/null
show_scout=$("$C" card show Scout "$CLIENT")
grep -q 'Scout' <<<"$show_scout"
printf 'PASS card-seed-specialist\n'

# Role invoke with missing provider still records display_name on envelope
"$C" gate "$CLIENT" direct 'Card smoke task.' smoke >/dev/null 2>&1 || true
if CONSULT_PROVIDER=/nonexistent/card-provider "$C" role "$CLIENT" invoke Analyst 7 'Return CARD_SMOKE.' >"$TMP/out" 2>&1; then
  printf 'FAIL role-invoke unexpectedly passed\n' >&2
  exit 1
fi
failed="$EDIR/roles/iter-7/Analyst/attempt-1"
[[ -f "$failed/request.json" ]]
jq -e '.display_name == "Meridian" and .card_id == "analyst" and (.traits | length) >= 1 and (.voice | length) > 0' \
  "$failed/request.json" >/dev/null
status=$("$C" role "$CLIENT" status 7)
jq -e '[.asked[] | select(.role == "Analyst")][0] | .display_name == "Meridian" and (.characteristics | length) >= 1' \
  <<<"$status" >/dev/null
printf 'PASS role-envelope-display-name\n'

printf 'PASS agent-cards-smoke\n'
