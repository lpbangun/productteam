#!/usr/bin/env bash
# Real provider + real git worktree proof for the Build 4 role envelope.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
C="$ROOT/bin/consult"
TMP=$(mktemp -d)
CLIENT="role-smoke-$$"
EDIR="$ROOT/state/engagements/$CLIENT"
SOURCE="$TMP/client"
cleanup() {
  "$C" workspace "$CLIENT" remove >/dev/null 2>&1 || true
  rm -rf "$EDIR" "$TMP"
}
trap cleanup EXIT

mkdir -p "$SOURCE" "$EDIR"
cat > "$SOURCE/README.md" <<'EOF'
# Role envelope acceptance client

A deliberately tiny repository used only for a real authenticated single-turn
role and scoring probe. It has no daemon, database, or runtime service.
EOF
git -C "$SOURCE" init -q
git -C "$SOURCE" config user.email role-smoke@example.invalid
git -C "$SOURCE" config user.name 'Role Smoke'
git -C "$SOURCE" add README.md
git -C "$SOURCE" commit -qm initial
cat > "$EDIR/engagement.md" <<EOF
# Role envelope smoke
Mode: **Directive**
Repo: $SOURCE
Mission: Prove one single-turn role envelope.
EOF
cat > "$EDIR/contract.json" <<'EOF'
{"contract":"role-smoke-v1","scorer":"provider"}
EOF
cat > "$EDIR/BENCHMARK-CONTRACT.md" <<'EOF'
# Frozen role smoke contract
Score the tiny repository honestly. Evidence must cite README.md.
EOF
"$C" gate "$CLIENT" direct 'Prove one single-turn role envelope.' 'temporary acceptance repository' >/dev/null

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

# A provider refusal is real (missing executable), leaves a complete failed envelope.
"$C" runtime --check >/dev/null
if CONSULT_PROVIDER=/nonexistent/role-provider "$C" role "$CLIENT" invoke Analyst 9 'Return ANALYST_FAIL.' >"$TMP/out" 2>&1; then
  printf 'FAIL provider-missing unexpectedly passed\n' >&2
  exit 1
fi
failed="$EDIR/roles/iter-9/Analyst/attempt-1"
[[ -f "$failed/request.json" && -f "$failed/result.json" && -f "$failed/manifest.json" ]]
jq -e '.exit != 0 and (.refusal_reason | contains("provider"))' "$failed/result.json" >/dev/null
printf 'PASS role-invoke-provider-seam\n'

# Builder refuses before provider when no seal; the refusal itself is enveloped.
expect_refuse builder-no-seal role "$CLIENT" invoke Builder 1
grep -q 'missing sealed Builder input' "$TMP/out"
jq -e '.exit != 0 and (.refusal_reason | contains("missing sealed Builder input"))' "$EDIR/roles/iter-1/Builder/attempt-1/result.json" >/dev/null
printf 'PASS role-builder-seal-refusal\n'

# A sealed file is write-once and tamper-evident.
printf 'Return exactly BUILDER_TAMPER_TEST.\n' > "$TMP/tamper-input.txt"
expect_pass seal-tamper role "$CLIENT" seal 2 "$TMP/tamper-input.txt"
expect_refuse seal-twice role "$CLIENT" seal 2 "$TMP/tamper-input.txt"
grep -q 'already sealed' "$TMP/out"
printf 'changed\n' >> "$TMP/tamper-input.txt"
expect_refuse seal-mismatch role "$CLIENT" invoke Builder 2
grep -q 'hash mismatch' "$TMP/out"
printf 'PASS role-builder-seal-mismatch\n'

# Main iteration. First use one identity for Analyst and Builder to prove collision.
CONSULT_ROLE_IDENTITY=shared "$C" role "$CLIENT" invoke Analyst 0 'Return exactly ANALYST_OK.' >"$TMP/analyst-1.out"
# Analyst stamp exists, but no Critic envelope: close must refuse by name.
expect_refuse close-no-critic role "$CLIENT" close 0
grep -q 'missing complete Critic envelope' "$TMP/out"
printf 'PASS role-close-no-critic\n'

printf 'Return exactly BUILDER_OK.\n' > "$TMP/builder-input.txt"
expect_pass seal-main role "$CLIENT" seal 0 "$TMP/builder-input.txt"
CONSULT_ROLE_IDENTITY=shared "$C" role "$CLIENT" invoke Builder 0 >"$TMP/builder.out"
expect_refuse score-collision score "$CLIENT" --iter 0
grep -q 'implementer = evaluator (shared)' "$TMP/out"
expect_refuse close-collision role "$CLIENT" close 0
grep -q 'implementer = evaluator (shared)' "$TMP/out"
printf 'PASS role-implementer-evaluator-rejected\n'

# Missing Analyst stamp blocks the actual provider score path before provider/workspace work.
expect_refuse score-no-analyst bench "$CLIENT" run --iter 3
grep -q 'missing Analyst stamp' "$TMP/out"
printf 'PASS role-score-no-analyst-stamp\n'

# A distinct Analyst supersedes the stamp; Critic and scoring use the same real provider seam.
CONSULT_ROLE_IDENTITY=analyst "$C" role "$CLIENT" invoke Analyst 0 'Return exactly ANALYST_DISTINCT.' >"$TMP/analyst-2.out"
CONSULT_ROLE_IDENTITY=critic "$C" role "$CLIENT" invoke Critic 0 'Return exactly CRITIC_OK.' >"$TMP/critic.out"
"$C" bench "$CLIENT" run --iter 0 >"$TMP/score.out"
"$C" role "$CLIENT" close 0 >"$TMP/close.out"
jq -e '.iter == 0 and .decision == "closed" and .implementer_identity == "shared" and .evaluator_identity == "analyst"' "$EDIR/roles/iter-0/close.json" >/dev/null

# Every role has a cryptographically indexed request/result/manifest envelope.
for role in Analyst Builder Critic; do
  ad=$(printf '%s\n' "$EDIR/roles/iter-0/$role"/attempt-* | sort -V | tail -1)
  [[ -f "$ad/request.json" && -f "$ad/result.json" && -f "$ad/manifest.json" ]]
  req=$(sha256sum "$ad/request.json" | cut -d' ' -f1)
  res=$(sha256sum "$ad/result.json" | cut -d' ' -f1)
  jq -e --arg role "$role" --arg req "$req" --arg res "$res" \
    '.role == $role and .provider and .requested_at and .ran_at and (.exit == 0) and .request_sha256 == $req and .result_sha256 == $res' "$ad/manifest.json" >/dev/null
done
printf 'PASS role-envelope-request-result-manifest\n'

# Status is derived from those files, valid after fresh CLI processes, and byte-stable.
"$C" role "$CLIENT" status 0 > "$TMP/status-1.json"
"$C" role "$CLIENT" status 0 > "$TMP/status-2.json"
cmp "$TMP/status-1.json" "$TMP/status-2.json" >/dev/null
jq -e '.iter == 0 and (.asked | length) == 3 and (.ran | length) == 3 and (.produced | length) == 3 and (.missing | length) == 0 and ([.asked[] | select(.role == "Builder")][0].task | contains("BUILDER_OK")) and ([.ran[] | .provider] | all(length > 0)) and ([.produced[] | .request_sha256, .result_sha256] | all(test("^[0-9a-f]{64}$")))' "$TMP/status-1.json" >/dev/null
! grep -qiE 'chat|transcript|conversation|process' "$TMP/status-1.json"
printf 'PASS role-status-file-derived\n'

# Happy score is explicitly bound to the same Analyst-stamped iteration.
jq -e '.iter == 0 and .evaluator == "analyst" and (.analyst_stamp | endswith("roles/iter-0/Analyst/stamp.json")) and (.scores | length) == 9' "$EDIR/runs/iter-0/scores.json" >/dev/null
printf 'PASS role-authorship-happy-path\n'
