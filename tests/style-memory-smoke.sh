#!/usr/bin/env bash
# style-memory-smoke — org style + project memory + inspect/role wiring.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
C="$ROOT/bin/productteam"
TMP=$(mktemp -d)
STYLE_TMP="$TMP/style"
CLIENT="style-smoke-$$"
EDIR="$ROOT/state/engagements/$CLIENT"
SOURCE="$TMP/client"
export CONSULT_STYLE_DIR="$STYLE_TMP"

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

# Bootstrap disposable engagement
mkdir -p "$SOURCE"
git -C "$SOURCE" init -q
git -C "$SOURCE" config user.email style-smoke@example.invalid
git -C "$SOURCE" config user.name 'Style Smoke'
printf '# stub\n' > "$SOURCE/README.md"
git -C "$SOURCE" add README.md
git -C "$SOURCE" commit -qm initial
mkdir -p "$EDIR"
cat > "$EDIR/engagement.md" <<EOF
# Style smoke
Mode: **Directive**
Repo: $SOURCE
Mission: Style memory smoke engagement.
EOF
cat > "$EDIR/contract.json" <<'EOF'
{"contract":"style-smoke-v1","scorer":"provider"}
EOF

# Missing style → inspect honest
"$C" inspect "$CLIENT" >/dev/null
pack="$EDIR/inspect-pack.json"
jq -e '.style.missing == true and .style.pointer == null' "$pack" >/dev/null
grep -q 'style missing' <<<"$(jq -r .next_suggested_action "$pack")" || \
  grep -q 'style init' <<<"$(jq -r .next_suggested_action "$pack")"
printf 'PASS inspect-style-missing\n'

# style init → inspect missing=false
"$C" style init >/dev/null
[[ -f "$STYLE_TMP/style.md" && -f "$STYLE_TMP/style.json" ]]
"$C" inspect "$CLIENT" >/dev/null
jq -e '.style.missing == false and (.style.taste | length) >= 1' "$pack" >/dev/null
printf 'PASS style-init-inspect-present\n'

# append taste → inspect includes line
UNIQUE="style-smoke-unique-taste-$$"
"$C" style append taste "$UNIQUE" >/dev/null
"$C" inspect "$CLIENT" >/dev/null
jq -e --arg u "$UNIQUE" '[.style.taste[] | select(. == $u)] | length == 1' "$pack" >/dev/null
printf 'PASS style-append-inspect\n'

# project memory append + inspect
PM="project-memory-line-$$"
"$C" project-memory append "$CLIENT" "$PM" >/dev/null
"$C" inspect "$CLIENT" >/dev/null
jq -e --arg p "$PM" '.project_memory.missing == false and (.project_memory.excerpt | contains($p))' "$pack" >/dev/null
printf 'PASS project-memory-inspect\n'

# role invoke records style_pointer / style_missing on envelope
"$C" gate "$CLIENT" direct 'Style smoke task.' smoke >/dev/null 2>&1 || true
if CONSULT_PROVIDER=/nonexistent/style-provider "$C" role "$CLIENT" invoke Analyst 3 'Return STYLE_SMOKE.' >"$TMP/out" 2>&1; then
  printf 'FAIL role-invoke unexpectedly passed\n' >&2
  exit 1
fi
req="$EDIR/roles/iter-3/Analyst/attempt-1/request.json"
[[ -f "$req" ]]
jq -e '.style_missing == false and (.style_pointer | test("style.md"))' "$req" >/dev/null
printf 'PASS role-request-style-fields\n'

# missing style on role envelope
mv "$STYLE_TMP/style.md" "$STYLE_TMP/style.md.bak"
mv "$STYLE_TMP/style.json" "$STYLE_TMP/style.json.bak"
if CONSULT_PROVIDER=/nonexistent/style-provider "$C" role "$CLIENT" invoke Analyst 4 'Return STYLE_MISSING.' >"$TMP/out" 2>&1; then
  printf 'FAIL role-invoke-missing unexpectedly passed\n' >&2
  exit 1
fi
req="$EDIR/roles/iter-4/Analyst/attempt-1/request.json"
jq -e '.style_missing == true and .style_pointer == null' "$req" >/dev/null
mv "$STYLE_TMP/style.md.bak" "$STYLE_TMP/style.md"
mv "$STYLE_TMP/style.json.bak" "$STYLE_TMP/style.json"
printf 'PASS role-request-style-missing\n'

# rewrite refuses without owner flag
expect_refuse style-rewrite-refuse style rewrite
grep -qi 'refused' "$TMP/out"
expect_refuse style-rewrite-owner style rewrite --i-am-owner
grep -qi 'refused' "$TMP/out"
printf 'PASS style-rewrite-refuses\n'

printf 'PASS style-memory-smoke\n'
