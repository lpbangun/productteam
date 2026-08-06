#!/usr/bin/env bash
# consult-smoke — CLI smoke tests for the Product Consulting Harness.
# Run from repo root: tests/consult-smoke.sh
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
C="$ROOT/bin/consult"
fail=0
ok() { printf '  PASS  %s\n' "$1"; }
bad() { printf '  FAIL  %s\n' "$1"; fail=1; }

printf '\n  consult smoke\n\n'

"$C" help >/dev/null && ok 'help' || bad 'help'
"$C" status >/dev/null && ok 'status' || bad 'status'
"$C" org >/dev/null && ok 'org' || bad 'org'
"$C" memory >/dev/null && ok 'memory' || bad 'memory'
"$C" judge onboarding-flight-control >/dev/null && ok 'judge show' || bad 'judge show'
"$C" bench onboarding-flight-control >/dev/null && ok 'bench' || bad 'bench'
bench_out=$("$C" bench onboarding-flight-control) || true
if grep -q 'ofc-v1' <<<"$bench_out"; then ok 'bench contract id'; else bad 'bench contract id'; fi
"$C" checks onboarding-flight-control >/dev/null && ok 'checks' || bad 'checks'
"$C" help | grep -q 'score' && ok 'help lists score' || bad 'help lists score'
# Wrong-path refusals
if "$C" bench agcode-learning run >/dev/null 2>&1; then
  # provider scorer may succeed if claude/agent available — only test OFC refuses provider path
  :
fi
if "$C" bench onboarding-flight-control run >/dev/null 2>&1; then bad 'ofc refuses provider run'; else ok 'ofc refuses provider run'; fi
if "$C" checks agcode-learning >/dev/null 2>&1; then bad 'agcode refuses checks'; else ok 'agcode refuses checks'; fi

# unknown command should fail honestly
if "$C" notacommand >/dev/null 2>&1; then bad 'unknown rejects'; else ok 'unknown rejects'; fi

# help mentions judgment modes
if "$C" help | grep -q 'judge'; then ok 'help lists judge'; else bad 'help lists judge'; fi

if (( fail == 0 )); then
  printf '\n  all smoke checks passed\n\n'
  exit 0
fi
printf '\n  %s smoke check(s) failed\n\n' "$fail"
exit 1
