#!/usr/bin/env bash
# consult-smoke — CLI smoke tests for the Product Consulting Harness.
# Run from repo root: tests/consult-smoke.sh
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
C="$ROOT/bin/productteam"
fail=0
ok() { printf '  PASS  %s\n' "$1"; }
bad() { printf '  FAIL  %s\n' "$1"; fail=1; }

printf '\n  productteam smoke\n\n'

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
"$C" help | grep -q 'productteam gh' && ok 'help lists gh' || bad 'help lists gh'
"$C" help | grep -q 'productteam skill' && ok 'help lists skill' || bad 'help lists skill'
"$C" help | grep -q 'productteam chat' && ok 'help lists chat' || bad 'help lists chat'
[[ -f "$ROOT/lib/repl.sh" ]] && ok 'repl.sh present' || bad 'repl.sh present'
if "$C" chat </dev/null >/dev/null 2>&1; then bad 'chat refuses non-TTY'; else ok 'chat refuses non-TTY'; fi
[[ -f "$ROOT/skills/critique/SKILL.md" ]] && ok 'skill critique present' || bad 'skill critique present'
[[ -f "$ROOT/skills/benchmark/SKILL.md" ]] && ok 'skill benchmark present' || bad 'skill benchmark present'
[[ -f "$ROOT/skills/design-sprint/SKILL.md" ]] && ok 'skill design-sprint present' || bad 'skill design-sprint present'
"$C" runtime >/dev/null && ok 'runtime' || bad 'runtime'
"$C" judge harness-evolution >/dev/null && ok 'judge harness-evolution' || bad 'judge harness-evolution'
"$C" gh preflight "$ROOT" >/dev/null && ok 'gh preflight' || bad 'gh preflight'
# merge without auth must refuse
if CONSULT_AUTHORIZE_MERGE=/tmp/productteam-no-auth-$$ "$C" gh merge "$ROOT" >/dev/null 2>&1; then
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
if "$C" help | grep -q 'gate <client> status|implement'; then ok 'help lists gate'; else bad 'help lists gate'; fi

# Build 3 surface: escalation lifecycle + file-derived inspect
if "$C" help | grep -q 'escalation <client> block'; then ok 'help lists escalation'; else bad 'help lists escalation'; fi
if "$C" help | grep -q 'resume <id> <token>'; then ok 'help lists resume'; else bad 'help lists resume'; fi
if "$C" help | grep -q 'inspect <client>'; then ok 'help lists inspect'; else bad 'help lists inspect'; fi
"$C" escalation onboarding-flight-control status >/dev/null && ok 'escalation status' || bad 'escalation status'
# Escalation status on a client with no escalation state is a valid machine payload (exit 0).
esc_status=$("$C" escalation onboarding-flight-control status)
if jq -e '.missing == true and .paused == false and (.open | type) == "array"' <<<"$esc_status" >/dev/null; then
  ok 'escalation status missing honesty'
else
  bad 'escalation status missing honesty'
fi
# Full real block → refuse → authorized resume lifecycle lives in escalation-smoke.sh
if "$ROOT/tests/escalation-smoke.sh" >/dev/null; then
  ok 'escalation real lifecycle (block/refuse/resume/inspect)'
else
  bad 'escalation real lifecycle (block/refuse/resume/inspect)'
fi

# Build 4 surface: status is file-derived and never invokes a provider.
if "$C" help | grep -q 'role <client> invoke'; then ok 'help lists role'; else bad 'help lists role'; fi
# Prefer a client with no role envelopes yet; OFC may already have closed iters.
role_client=agcode-learning
if [[ -d "$ROOT/state/engagements/agcode-learning/roles" ]]; then
  role_client=harness-cli
fi
role_status=$("$C" role "$role_client" status)
if jq -e '(.asked|type)=="array" and (.ran|type)=="array" and (.produced|type)=="array" and (.missing|type)=="array" and ((.asked|length) + (.missing|length)) >= 1' <<<"$role_status" >/dev/null; then
  ok 'role status file-derived'
else
  bad 'role status file-derived'
fi
# Explicit missing honesty on a disposable slug that has engagement stub only when present;
# otherwise assert OFC status still returns valid JSON with produced roles.
ofc_role=$("$C" role onboarding-flight-control status 2)
if jq -e '.iter == 2 and (.produced|length) == 3 and (.missing|length) == 0' <<<"$ofc_role" >/dev/null; then
  ok 'role status closed-iter honesty'
else
  bad 'role status closed-iter honesty'
fi

# learning schema + judgment examples
[[ -f "$ROOT/docs/learning-schema.md" ]] && ok 'learning schema' || bad 'learning schema'
[[ -f "$ROOT/state/harness-evolution/examples/challenge-refusal.md" ]] && ok 'challenge example' || bad 'challenge example'
[[ -f "$ROOT/state/harness-evolution/examples/override-risks.md" ]] && ok 'override example' || bad 'override example'

if "$ROOT/tests/workspace-smoke.sh" >/dev/null; then
  ok 'workspace isolation real-worktree refuse/pass'
else
  bad 'workspace isolation real-worktree refuse/pass'
fi

if "$ROOT/tests/open-baseline-smoke.sh" >/dev/null; then
  ok 'open→baseline cold bootstrap refuse/pass'
else
  bad 'open→baseline cold bootstrap refuse/pass'
fi

if (( fail == 0 )); then
  printf '\n  all smoke checks passed\n\n'
  exit 0
fi
printf '\n  %s smoke check(s) failed\n\n' "$fail"
exit 1
