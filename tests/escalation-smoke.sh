#!/usr/bin/env bash
# Real CLI block → pause → owner-authorized resume → inspect probe.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
C="$ROOT/bin/consult"
TMP=$(mktemp -d)
CLIENT="escalation-smoke-$$"
MISSING="inspect-missing-$$"
DIR="$ROOT/state/engagements/$CLIENT"
MISSING_DIR="$ROOT/state/engagements/$MISSING"
MEMORY="$TMP/MEMORY.md"
cleanup() { rm -rf "$DIR" "$MISSING_DIR" "$TMP"; }
trap cleanup EXIT
mkdir -p "$DIR" "$MISSING_DIR"
printf '# Test memory\n\n## Lessons\n' > "$MEMORY"
cat > "$DIR/engagement.md" <<EOF
# Escalation smoke
Mode: **Directive**
EOF
cat > "$MISSING_DIR/engagement.md" <<EOF
# Missing-input inspect smoke
Mode: **Guided**
EOF
consult() { CONSULT_MEMORY_FILE="$MEMORY" "$C" "$@"; }
expect_refuse() {
  local label="$1"; shift
  if consult "$@" >"$TMP/out" 2>&1; then
    printf 'FAIL %s unexpectedly passed\n' "$label" >&2
    exit 1
  fi
}
expect_pass() {
  local label="$1"; shift
  if ! consult "$@" >"$TMP/out" 2>&1; then
    printf 'FAIL %s unexpectedly refused\n' "$label" >&2
    cat "$TMP/out" >&2
    exit 1
  fi
}

expect_pass directive gate "$CLIENT" direct 'continue accepted implementation'
expect_pass preblock gate "$CLIENT" implement 'continue accepted implementation'
expect_pass block escalation "$CLIENT" block owner-1 'Owner must choose deployment policy' 'keep local only' 'allow gated remote'
[[ -f "$DIR/escalations.json" && -f "$DIR/pause.json" ]]
token=$(jq -r '.[0].resume_token' "$DIR/escalations.json")
jq -e '. | length == 1 and .[0].status == "blocked" and (.[0].options | length) == 2 and (.[0].resume_token | length) > 0' "$DIR/escalations.json" >/dev/null
jq -e '.paused == true and .status == "paused" and .id == "owner-1"' "$DIR/pause.json" >/dev/null
printf 'PASS escalation-block-state\n'

expect_refuse implement-paused gate "$CLIENT" implement 'continue accepted implementation'
grep -q "progress blocked for $CLIENT" "$TMP/out"
expect_refuse checks-paused checks "$CLIENT"
grep -q 'owner-1\|pause.json' "$TMP/out"
printf 'PASS escalation-pauses-progress\n'

expect_pass inspect-paused inspect "$CLIENT"
pack="$DIR/inspect-pack.json"
jq -e '.pause.paused == true and .escalations.open == 1 and (.next_suggested_action | contains("authorized resume")) and has("history")' "$pack" >/dev/null

expect_refuse no-auth escalation "$CLIENT" resume owner-1 "$token"
grep -q 'missing authorization file' "$TMP/out"
printf 'PASS escalation-resume-refuse\n'

cat > "$DIR/authorize-resume.json" <<EOF
{"id":"owner-1","token":"wrong","authorized_by":"owner","decision":"keep local only"}
EOF
expect_refuse wrong-auth escalation "$CLIENT" resume owner-1 "$token"
grep -q 'do not exactly match' "$TMP/out"
cat > "$DIR/authorize-resume.json" <<EOF
{"id":"owner-1","token":"$token","authorized_by":"owner","decision":"keep local only"}
EOF
expect_pass authorized escalation "$CLIENT" resume owner-1 "$token"
jq -e '.[0].status == "resolved" and (.[0].resolved_at | length) > 0' "$DIR/escalations.json" >/dev/null
jq -e '.paused == false and .status == "resumed" and (.resumed_at | length) > 0' "$DIR/pause.json" >/dev/null
jq -e '.status == "consumed" and (.consumed_at | length) > 0' "$DIR/authorize-resume.json" >/dev/null
jq -e '.event == "resumed" and .escalation_resolved == true and .auth_consumed == true' "$DIR/continuation.json" >/dev/null
expect_refuse auth-reuse escalation "$CLIENT" resume owner-1 "$token"
printf 'PASS escalation-resume-authorized\n'

grep -q "$CLIENT authorized resume" "$MEMORY"
printf 'PASS escalation-memory-continuation\n'
expect_pass implement-resumed gate "$CLIENT" implement 'continue accepted implementation'

expect_pass inspect-resumed inspect "$CLIENT"
cp "$pack" "$TMP/pack-1.json"
expect_pass inspect-regenerated inspect "$CLIENT"
cmp "$pack" "$TMP/pack-1.json" >/dev/null
jq -e '.pause.paused == false and .escalations.open == 0 and .escalations.resolved == 1 and .continuation.event == "resumed" and (.next_suggested_action | contains("first measurement"))' "$pack" >/dev/null
printf 'PASS inspect-pack-regenerable\n'

expect_pass inspect-missing inspect "$MISSING"
missing_pack="$MISSING_DIR/inspect-pack.json"
jq -e '.escalations.missing == true and .pause.missing == true and .scores.missing == true and .history.missing == true and .lessons.missing == true and .continuation.missing == true and (.missing | index("escalations.json")) != null and (.missing | index("history.jsonl")) != null' "$missing_pack" >/dev/null
printf 'PASS inspect-pack-missing-honest\n'
