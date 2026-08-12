#!/usr/bin/env bash
# run-loop-smoke — overnight loop driver: limits, resume, hard stops, dry-run honesty.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
C="$ROOT/bin/productteam"
TMP=$(mktemp -d)
CLIENT="run-loop-smoke-$$"
GATE_CLIENT="run-loop-gate-$$"
ESC_CLIENT="run-loop-esc-$$"
LIFT_CLIENT="run-loop-lift-$$"
EDIR="$ROOT/state/engagements/$CLIENT"
GDIR="$ROOT/state/engagements/$GATE_CLIENT"
EDIR2="$ROOT/state/engagements/$ESC_CLIENT"
LDIR="$ROOT/state/engagements/$LIFT_CLIENT"
SOURCE="$TMP/client"

cleanup() {
  rm -rf "$EDIR" "$GDIR" "$EDIR2" "$LDIR" "$TMP"
}
trap cleanup EXIT

mkdir -p "$SOURCE" "$EDIR" "$GDIR" "$EDIR2" "$LDIR"
git -C "$SOURCE" init -q
git -C "$SOURCE" config user.email run-loop@example.invalid
git -C "$SOURCE" config user.name 'Run Loop Smoke'
printf '# stub\n' > "$SOURCE/README.md"
git -C "$SOURCE" add README.md
git -C "$SOURCE" commit -qm initial

stub_engagement() {
  local dir="$1" mode="${2:-Directive}"
  cat > "$dir/engagement.md" <<EOF
# Run loop smoke
Mode: **$mode**
Repo: $SOURCE
Vision: Overnight loop smoke client.
EOF
  echo '{"contract":"run-loop-v1","scorer":"provider"}' > "$dir/contract.json"
  mkdir -p "$dir/judgment"
  case "$mode" in
    Directive)
      jq -n --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        '{mode:"Directive",direction:"continue smoke loop",decision:"accepted",ts:$ts}' \
        > "$dir/judgment/directive.json"
      ;;
    Override)
      jq -n --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        '{mode:"Override",direction:"continue smoke",critic_record:"recorded",evidence_record:"recorded",ts:$ts,
          risks:["test"],non_waivers:{critic:true,evidence:true,frozen_contract:true}}' \
        > "$dir/judgment/override.json"
      ;;
  esac
}

stub_engagement "$EDIR" Directive
stub_engagement "$GDIR" Guided
stub_engagement "$EDIR2" Directive
stub_engagement "$LDIR" Directive

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

# refuse without max flags
expect_refuse no-max-hours run-loop "$CLIENT" --max-iters 2
grep -q 'requires explicit --max-hours' "$TMP/out"
expect_refuse no-max-iters run-loop "$CLIENT" --max-hours 1
grep -q 'requires explicit --max-hours' "$TMP/out"
expect_refuse no-client run-loop --max-hours 1 --max-iters 1
grep -q 'usage: productteam run-loop' "$TMP/out"
printf 'PASS run-loop-refuse-missing-flags\n'

# dry-run completes iters writing progress/heartbeat/log
expect_pass dry-run run-loop "$CLIENT" --max-hours 6 --max-iters 2 --dry-run --no-provider
prog="$EDIR/loop/progress.json"
[[ -f "$prog" && -f "$EDIR/loop/heartbeat" && -f "$EDIR/loop/run.log" ]]
jq -e '.status == "completed" and .stop_reason == "max-iters" and .iter == 2' "$prog" >/dev/null
grep -q 'iter 1: inspect complete' "$EDIR/loop/run.log"
grep -q 'iter 2: complete' "$EDIR/loop/run.log"
printf 'PASS run-loop-dry-run-progress\n'

# no auto-implement: dry-run never creates Builder seal
if find "$EDIR/roles" -name seal.json 2>/dev/null | grep -q .; then
  printf 'FAIL dry-run created Builder seal\n' >&2
  exit 1
fi
printf 'PASS run-loop-no-auto-builder-seal\n'

# kill/resume
RESUME_CLIENT="run-loop-resume-$$"
RDIR="$ROOT/state/engagements/$RESUME_CLIENT"
mkdir -p "$RDIR"
stub_engagement "$RDIR" Directive
CONSULT_LOOP_PHASE_SLEEP=0.4 "$C" run-loop "$RESUME_CLIENT" --max-hours 6 --max-iters 5 --dry-run --no-provider &
pid=$!
sleep 0.6
kill -TERM "$pid" 2>/dev/null || true
wait "$pid" 2>/dev/null || true
rprog="$RDIR/loop/progress.json"
jq -e '.status == "paused" and .stop_reason == "killed-resume-pending"' "$rprog" >/dev/null
expect_pass resume run-loop "$RESUME_CLIENT" --max-hours 6 --max-iters 5 --dry-run --no-provider --resume
jq -e '.status == "completed" and .stop_reason == "max-iters"' "$rprog" >/dev/null
grep -q 'resume from iter' "$RDIR/loop/run.log"
printf 'PASS run-loop-kill-resume\n'
rm -rf "$RDIR"

# gate-block: Guided with no selection
expect_pass gate-block-start run-loop "$GATE_CLIENT" --max-hours 1 --max-iters 3 --dry-run --no-provider
gprog="$GDIR/loop/progress.json"
jq -e '.stop_reason == "gate-block"' "$gprog" >/dev/null
grep -q 'no selection recorded' "$GDIR/loop/run.log"
printf 'PASS run-loop-gate-block\n'

# escalation stop when paused
cat > "$EDIR2/engagement.md" <<EOF
# Escalation loop smoke
Mode: **Directive**
Repo: $SOURCE
EOF
"$C" escalation "$ESC_CLIENT" block esc-1 'policy hold' 'wait' 'abort' >/dev/null
expect_pass esc-stop run-loop "$ESC_CLIENT" --max-hours 1 --max-iters 3 --dry-run --no-provider
eprog="$EDIR2/loop/progress.json"
jq -e '.stop_reason == "escalation"' "$eprog" >/dev/null
grep -q 'progress blocked' "$EDIR2/loop/run.log"
printf 'PASS run-loop-escalation-stop\n'

# max-iters stop (already covered by dry-run; explicit single iter)
MAX_CLIENT="run-loop-maxi-$$"
MDIR="$ROOT/state/engagements/$MAX_CLIENT"
mkdir -p "$MDIR"
stub_engagement "$MDIR" Directive
expect_pass max-iters run-loop "$MAX_CLIENT" --max-hours 6 --max-iters 1 --dry-run --no-provider
jq -e '.iter == 1 and .stop_reason == "max-iters"' "$MDIR/loop/progress.json" >/dev/null
printf 'PASS run-loop-max-iters\n'
rm -rf "$MDIR"

# max-hours via CONSULT_LOOP_TEST_SECONDS
TIME_CLIENT="run-loop-time-$$"
TDIR="$ROOT/state/engagements/$TIME_CLIENT"
mkdir -p "$TDIR"
stub_engagement "$TDIR" Directive
CONSULT_LOOP_TEST_SECONDS=1 CONSULT_LOOP_PHASE_SLEEP=0.5 \
  "$C" run-loop "$TIME_CLIENT" --max-hours 6 --max-iters 99 --dry-run --no-provider || true
jq -e '.stop_reason == "max-hours"' "$TDIR/loop/progress.json" >/dev/null
printf 'PASS run-loop-max-hours-test-seconds\n'
rm -rf "$TDIR"

# no-lift streak stop
mkdir -p "$LDIR/runs/iter-1" "$LDIR/runs/iter-2"
echo '{"ts":"2026-08-11","iter":1,"kind":"iteration","overall":7.0,"scores":{}}' > "$LDIR/runs/iter-1/scores.json"
echo '{"ts":"2026-08-11","iter":2,"kind":"iteration","overall":7.0,"scores":{}}' > "$LDIR/runs/iter-2/scores.json"
CONSULT_NO_LIFT_STREAK=1
expect_pass no-lift run-loop "$LIFT_CLIENT" --max-hours 6 --max-iters 5 --dry-run --no-provider
unset CONSULT_NO_LIFT_STREAK
jq -e '.stop_reason == "no-lift"' "$LDIR/loop/progress.json" >/dev/null
printf 'PASS run-loop-no-lift\n'

# critic-reject stop (Guided + REJECT rebuttal for iter 1)
REJECT_CLIENT="run-loop-reject-$$"
RDIR="$ROOT/state/engagements/$REJECT_CLIENT"
mkdir -p "$RDIR/judgment"
stub_engagement "$RDIR" Guided
jq -n '{mode:"Guided",direction:"Harden gates",proposal_id:"d1",selected_by:"Kai",display_name:"Kai",ts:"2026-08-11T08:00:00Z"}' \
  > "$RDIR/judgment/selection.json"
jq -n '{mode:"Guided",iter:1,verdict:"REJECT",rebuttal:"scope too wide",ts:"2026-08-11T08:00:00Z"}' \
  > "$RDIR/judgment/critic-rebuttal.json"
expect_pass critic-reject run-loop "$REJECT_CLIENT" --max-hours 1 --max-iters 3 --dry-run --no-provider
jq -e '.stop_reason == "critic-reject"' "$RDIR/loop/progress.json" >/dev/null
printf 'PASS run-loop-critic-reject\n'
rm -rf "$RDIR"

printf 'PASS run-loop-smoke-all\n'
