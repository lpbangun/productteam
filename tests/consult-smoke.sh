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
"$C" help | grep -q 'score' && ok 'help lists score' || bad 'help lists score'
"$C" help | grep -q 'runtime' && ok 'help lists runtime' || bad 'help lists runtime'
"$C" help | grep -q 'harness-checks' && ok 'help lists harness-checks' || bad 'help lists harness-checks'
"$C" help | grep -q 'consult gh' && ok 'help lists gh' || bad 'help lists gh'
"$C" help | grep -q 'consult skill' && ok 'help lists skill' || bad 'help lists skill'
[[ -f "$ROOT/skills/critique/SKILL.md" ]] && ok 'skill critique present' || bad 'skill critique present'
[[ -f "$ROOT/skills/benchmark/SKILL.md" ]] && ok 'skill benchmark present' || bad 'skill benchmark present'
[[ -f "$ROOT/skills/design-sprint/SKILL.md" ]] && ok 'skill design-sprint present' || bad 'skill design-sprint present'
"$C" runtime >/dev/null && ok 'runtime' || bad 'runtime'
"$C" judge harness-evolution >/dev/null && ok 'judge harness-evolution' || bad 'judge harness-evolution'
"$C" gh preflight "$ROOT" >/dev/null && ok 'gh preflight' || bad 'gh preflight'
# merge without auth must refuse
if CONSULT_AUTHORIZE_MERGE=/tmp/consult-no-auth-$$ "$C" gh merge "$ROOT" >/dev/null 2>&1; then
  bad 'gh merge refuses without auth'
else
  ok 'gh merge refuses without auth'
fi
if CONSULT_PROVIDER=/nonexistent/no-such-provider-bin "$C" runtime --check >/dev/null 2>&1; then
  bad 'runtime --check refuses missing provider'
else
  ok 'runtime --check refuses missing provider'
fi
if [[ "${CONSULT_SMOKE_SKIP_CLIENT:-}" == 1 ]]; then
  ok 'client checks skipped (CONSULT_SMOKE_SKIP_CLIENT)'
else
  "$C" checks onboarding-flight-control >/dev/null && ok 'checks' || bad 'checks'
fi
# Wrong-path refusals (never invoke provider scoring here — it hangs)
if "$C" bench onboarding-flight-control run >/dev/null 2>&1; then bad 'ofc refuses provider run'; else ok 'ofc refuses provider run'; fi
if "$C" checks agcode-learning >/dev/null 2>&1; then bad 'agcode refuses checks'; else ok 'agcode refuses checks'; fi

# unknown command should fail honestly
if "$C" notacommand >/dev/null 2>&1; then bad 'unknown rejects'; else ok 'unknown rejects'; fi

# help mentions judgment modes
if "$C" help | grep -q 'judge'; then ok 'help lists judge'; else bad 'help lists judge'; fi

# learning schema + judgment examples
[[ -f "$ROOT/docs/learning-schema.md" ]] && ok 'learning schema' || bad 'learning schema'
[[ -f "$ROOT/state/harness-evolution/examples/challenge-refusal.md" ]] && ok 'challenge example' || bad 'challenge example'
[[ -f "$ROOT/state/harness-evolution/examples/override-risks.md" ]] && ok 'override example' || bad 'override example'

if (( fail == 0 )); then
  printf '\n  all smoke checks passed\n\n'
  exit 0
fi
printf '\n  %s smoke check(s) failed\n\n' "$fail"
exit 1
