#!/usr/bin/env bash
# judgment-gate-smoke — real CLI probe of the durable judgment gates.
# Temporary engagements only; cleans up after itself. No mocks, no fixtures.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
C="$ROOT/bin/consult"
TMP=$(mktemp -d)
CLIENT="gate-smoke-$$"
ENGAGEMENT="$ROOT/state/engagements/$CLIENT"
cleanup() { rm -rf "$ENGAGEMENT" "$TMP"; }
trap cleanup EXIT

mkdir -p "$ENGAGEMENT"
cat > "$ENGAGEMENT/engagement.md" <<EOF
# Gate smoke engagement
Mode: **Guided**
EOF

set_mode() { "$C" judge "$CLIENT" set "$1" >/dev/null; }
expect_refuse() { # $1=expect-refuse-desc, rest = consult args; returns 0 if command refused
  local desc="$1"; shift
  if "$C" "$@" >"$TMP/out" 2>&1; then
    printf 'FAIL %s — unexpectedly allowed\n' "$desc" >&2
    cat "$TMP/out" >&2
    exit 1
  fi
}
expect_pass() { # $1=expect-pass-desc, rest = consult args
  local desc="$1"; shift
  if ! "$C" "$@" >"$TMP/out" 2>&1; then
    printf 'FAIL %s — unexpectedly refused\n' "$desc" >&2
    cat "$TMP/out" >&2
    exit 1
  fi
}

# --- Guided: refuse until selection, pass after select, status JSON ---
expect_refuse 'guided-refuse' gate "$CLIENT" implement
grep -q "no selection recorded for $CLIENT" "$TMP/out"
printf 'PASS gate-guided-refuse\n'

expect_pass 'guided-select' gate "$CLIENT" select 'build operator docs first'
[[ -f "$ENGAGEMENT/judgment/selection.json" ]]
jq -e --arg d 'build operator docs first' '.direction == $d and (.selected_by | length > 0) and (.ts | length > 0) and .decision == "allowed"' "$ENGAGEMENT/judgment/selection.json" >/dev/null

expect_pass 'guided-implement' gate "$CLIENT" implement 'build operator docs first'
expect_refuse 'guided-implement-wrong-direction' gate "$CLIENT" implement 'some other direction'
grep -q 'bound direction' "$TMP/out"

expect_pass 'guided-status' gate "$CLIENT" status
status=$(cat "$TMP/out")
jq -e --arg c "$CLIENT" '.client == $c and .mode == "Guided" and .allowed == true and .decision == "allowed" and .bound_direction == "build operator docs first" and (.artifact | endswith("selection.json")) and (.artifact_ts | length > 0) and .present.selection_present == true and .present.direction_present == true and .present.selected_by_present == true' <<<"$status" >/dev/null
printf 'PASS gate-guided-pass\n'

# --- Directive: refuse until durable direction, pass after direct ---
set_mode Directive
expect_refuse 'directive-refuse' gate "$CLIENT" implement
grep -q "no directive recorded for $CLIENT" "$TMP/out"
printf 'PASS gate-directive-refuse\n'

expect_pass 'directive-direct' gate "$CLIENT" direct 'implement the smallest diff'
[[ -f "$ENGAGEMENT/judgment/directive.json" ]]
jq -e '.direction == "implement the smallest diff" and .decision == "allowed" and (.ts | length > 0) and (.risks | type) == "array" and (.risks | length) == 0' "$ENGAGEMENT/judgment/directive.json" >/dev/null

expect_pass 'directive-implement' gate "$CLIENT" implement 'implement the smallest diff'
expect_pass 'directive-status' gate "$CLIENT" status
status=$(cat "$TMP/out")
jq -e '.mode == "Directive" and .allowed == true and .decision == "allowed" and .present.directive_present == true and .present.direction_present == true and .present.decision_present == true and .present.risks_recorded == true' <<<"$status" >/dev/null
printf 'PASS gate-directive-pass\n'

# --- Challenge: harmful always refused, safer alternative only pass ---
set_mode Challenge
expect_refuse 'challenge-refuse-missing' gate "$CLIENT" implement
expect_pass 'challenge-write' gate "$CLIENT" challenge 'add real AI integration' 'keep local prototype, document limits' 'evidence/advisor-verdict.json'
[[ -f "$ENGAGEMENT/judgment/challenge.json" ]]
jq -e '.harmful == "add real AI integration" and .safer_alternative == "keep local prototype, document limits" and (.evidence | length > 0) and .decision == "refused"' "$ENGAGEMENT/judgment/challenge.json" >/dev/null

expect_refuse 'challenge-refuse-harmful' gate "$CLIENT" implement 'add real AI integration'
grep -q 'challenged harmful path' "$TMP/out"
expect_pass 'challenge-status-refused' gate "$CLIENT" status
status=$(cat "$TMP/out")
jq -e '.mode == "Challenge" and .allowed == false and .decision == "refused" and .present.challenge_present == true and .present.selection_matches == false' <<<"$status" >/dev/null
printf 'PASS gate-challenge-refuse\n'

expect_pass 'challenge-select-alternative' gate "$CLIENT" select 'keep local prototype, document limits'
expect_pass 'challenge-implement-alternative' gate "$CLIENT" implement 'keep local prototype, document limits'
expect_pass 'challenge-status-allowed' gate "$CLIENT" status
status=$(cat "$TMP/out")
jq -e '.mode == "Challenge" and .allowed == true and .decision == "allowed" and .bound_direction == "keep local prototype, document limits" and .present.selection_matches == true' <<<"$status" >/dev/null
printf 'PASS gate-challenge-alternative\n'

# --- Override: empty risk refused (no durable write), non-waiver tamper refused, full pass ---
set_mode Override
expect_refuse 'override-empty-risk' gate "$CLIENT" override 'ship anyway' '' 'critic/record' 'evidence/record'
[[ ! -f "$ENGAGEMENT/judgment/override.json" ]]
grep -q 'non-empty' "$TMP/out"
printf 'PASS gate-override-refuse\n'

expect_pass 'override-full' gate "$CLIENT" override 'ship anyway' 'flaky lint may hide a regression' 'critic/record' 'evidence/record'
[[ -f "$ENGAGEMENT/judgment/override.json" ]]
jq -e '.direction == "ship anyway" and (.risks | length) == 1 and .risks[0] == "flaky lint may hide a regression" and .critic_record == "critic/record" and .evidence_record == "evidence/record" and .non_waivers.critic == true and .non_waivers.evidence == true and .non_waivers.frozen_contract == true' "$ENGAGEMENT/judgment/override.json" >/dev/null

expect_pass 'override-implement' gate "$CLIENT" implement 'ship anyway'
expect_pass 'override-allowed-status' gate "$CLIENT" status
status=$(cat "$TMP/out")
jq -e '.mode == "Override" and .allowed == true and .decision == "allowed" and .present.non_waivers_present == true' <<<"$status" >/dev/null

# Tamper with the durable file: drop the frozen-contract non-waiver → must refuse, no re-write.
jq '.non_waivers.frozen_contract = false' "$ENGAGEMENT/judgment/override.json" > "$TMP/tampered.json"
mv "$TMP/tampered.json" "$ENGAGEMENT/judgment/override.json"
expect_refuse 'override-tamper-non-waiver' gate "$CLIENT" implement 'ship anyway'
grep -q 'non-waivable' "$TMP/out"
expect_pass 'override-status' gate "$CLIENT" status
status=$(cat "$TMP/out")
jq -e '.mode == "Override" and .allowed == false and .decision == "refused" and .present.override_present == true and .present.non_waivers_present == false' <<<"$status" >/dev/null
printf 'PASS gate-override-pass\n'

printf 'gate smoke: all 8 gate paths exercised\n'
