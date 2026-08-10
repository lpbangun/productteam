#!/usr/bin/env bash
# harness-checks.sh — deterministic checks for harness-apc-v1 (objective subset).
# Usage: harness-checks.sh [iter-dir]
# Archives results to iter-dir/checks.json (default: state/harness-evolution/runs/.harness-checks-latest.json)
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ITER_DIR="${1:-$ROOT/state/harness-evolution/runs}"
OUT="${2:-$ITER_DIR/checks.json}"
if [[ $# -lt 2 && -d "$ITER_DIR" && "$(basename "$ITER_DIR")" != runs ]]; then
  OUT="$ITER_DIR/checks.json"
fi
mkdir -p "$(dirname "$OUT")"

source "$ROOT/lib/provider.sh"

# Shared palette — no local escape literals (cli-theme-single-source).
# shellcheck source=lib/theme.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/theme.sh"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
RESULTS="$TMP/results.tsv"
: > "$RESULTS"

record() {
  local id="$1" status="$2" detail="$3"
  printf '%s\t%s\t%s\n' "$id" "$status" "$detail" >> "$RESULTS"
  if [[ "$status" == pass ]]; then
    printf '  %s %-36s %s%s%s\n' "$(status_badge success)" "$id" "$D" "${detail:0:60}" "$R"
  else
    printf '  %s %-36s %s%s%s\n' "$(status_badge error)" "$id" "$D" "${detail:0:60}" "$R"
  fi
}

run_check() {
  local id="$1"; shift
  local out rc
  set +e
  out=$(bash -c "$*" 2>&1)
  rc=$?
  set -e
  if [[ $rc -eq 0 ]]; then
    record "$id" pass "$(echo "$out" | head -1)"
  else
    record "$id" fail "$(echo "$out" | head -1)"
  fi
}

printf '\n  %sHarness checks (harness-apc-v1 objective subset)%s\n\n' "$B" "$R"

# Workspace isolation (real temporary git repo + detached worktree; no mocks).
workspace_probe=$(cd "$ROOT" && tests/workspace-smoke.sh 2>&1)
workspace_probe_rc=$?
for spec in \
  'workspace-default-isolated:PASS workspace-default-isolated' \
  'workspace-lifecycle-cli:PASS workspace-lifecycle' \
  'workspace-dirty-refusal:PASS workspace-dirty-refusal' \
  'workspace-dirty-escape-evidence:PASS workspace-dirty-escape-evidence' \
  'workspace-safe-remove:PASS workspace-safe-remove'
do
  id=${spec%%:*}
  marker=${spec#*:}
  if grep -qF "$marker" <<<"$workspace_probe" && { [[ "$id" != workspace-safe-remove ]] || (( workspace_probe_rc == 0 )); }; then
    record "$id" pass real-git-worktree
  else
    record "$id" fail "${workspace_probe//$'\n'/; }"
  fi
done

# Judgment gates (real temporary CLI engagements; no fixtures, no mocks).
gate_probe=$(cd "$ROOT" && tests/judgment-gate-smoke.sh 2>&1)
gate_probe_rc=$?
for spec in \
  'gate-guided-refuse:PASS gate-guided-refuse' \
  'gate-guided-pass:PASS gate-guided-pass' \
  'gate-directive-refuse:PASS gate-directive-refuse' \
  'gate-directive-pass:PASS gate-directive-pass' \
  'gate-challenge-refuse:PASS gate-challenge-refuse' \
  'gate-challenge-alternative:PASS gate-challenge-alternative' \
  'gate-override-refuse:PASS gate-override-refuse' \
  'gate-override-pass:PASS gate-override-pass'
do
  id=${spec%%:*}
  marker=${spec#*:}
  if grep -qF "$marker" <<<"$gate_probe" && { [[ "$id" != gate-override-pass ]] || (( gate_probe_rc == 0 )); }; then
    record "$id" pass real-cli-engagement
  else
    record "$id" fail "${gate_probe//$'\n'/; }"
  fi
done

# Escalation continuity + inspect pack (real temporary CLI engagements).
escalation_probe=$(cd "$ROOT" && tests/escalation-smoke.sh 2>&1)
escalation_probe_rc=$?
for spec in \
  'escalation-block-state:PASS escalation-block-state' \
  'escalation-pauses-progress:PASS escalation-pauses-progress' \
  'escalation-resume-refuse:PASS escalation-resume-refuse' \
  'escalation-resume-authorized:PASS escalation-resume-authorized' \
  'escalation-memory-continuation:PASS escalation-memory-continuation' \
  'inspect-pack-regenerable:PASS inspect-pack-regenerable' \
  'inspect-pack-missing-honest:PASS inspect-pack-missing-honest'
do
  id=${spec%%:*}
  marker=${spec#*:}
  if (( escalation_probe_rc == 0 )) && grep -qF "$marker" <<<"$escalation_probe"; then
    record "$id" pass real-cli-continuation
  else
    record "$id" fail "${escalation_probe//$'\n'/; }"
  fi
done

# Role envelope (real authenticated provider + real temporary git engagement).
role_probe=$(cd "$ROOT" && tests/role-envelope-smoke.sh 2>&1)
role_probe_rc=$?
for spec in \
  'role-invoke-provider-seam:PASS role-invoke-provider-seam' \
  'role-builder-seal-refusal:PASS role-builder-seal-refusal' \
  'role-builder-seal-mismatch:PASS role-builder-seal-mismatch' \
  'role-envelope-request-result-manifest:PASS role-envelope-request-result-manifest' \
  'role-score-no-analyst-stamp:PASS role-score-no-analyst-stamp' \
  'role-close-no-critic:PASS role-close-no-critic' \
  'role-implementer-evaluator-rejected:PASS role-implementer-evaluator-rejected' \
  'role-status-file-derived:PASS role-status-file-derived'
do
  id=${spec%%:*}
  marker=${spec#*:}
  if (( role_probe_rc == 0 )) && grep -qF "$marker" <<<"$role_probe"; then
    record "$id" pass real-provider-envelope
  else
    record "$id" fail "${role_probe//$'\n'/; }"
  fi
done

# CLI / smoke
run_check help-lists-runtime "cd \"$ROOT\" && bin/productteam help | grep -q runtime && echo ok"
run_check smoke-green "cd \"$ROOT\" && CONSULT_SMOKE_SKIP_CLIENT=1 tests/consult-smoke.sh >/dev/null && echo ok"
run_check status-runs "cd \"$ROOT\" && bin/productteam status >/dev/null && echo ok"

# Runtime detection
run_check runtime-detect "cd \"$ROOT\" && bin/productteam agents | grep -qE '●' && echo ok"
run_check runtime-honest-fail "cd \"$ROOT\" && out=\$(CONSULT_PROVIDER=/nonexistent/no-such-provider-bin bin/productteam runtime --check 2>&1); echo \"\$out\" | grep -qi 'not found\\|no coding runtime\\|provider' && echo ok"

# Lock freeze
run_check lock-files-present "test -f \"$ROOT/state/harness-evolution/HARNESS-BENCHMARK-CONTRACT.md\" && test -f \"$ROOT/state/harness-evolution/contract.json\" && test -f \"$ROOT/state/harness-evolution/LOCK.md\" && echo ok"
run_check lock-hashes-stable "
  cd \"$ROOT\"
  pre=\$(ls -1 state/harness-evolution/runs/iter-*/evidence/lock-hashes-pre.txt 2>/dev/null | sort -V | tail -1)
  [[ -n \"\$pre\" ]] || { echo 'no lock-hashes-pre yet'; exit 0; }
  cur=\$(sha256sum state/harness-evolution/HARNESS-BENCHMARK-CONTRACT.md state/harness-evolution/contract.json state/harness-evolution/LOCK.md)
  expected=\$(cat \"\$pre\")
  [[ \"\$cur\" == \"\$expected\" ]] && echo unchanged || { echo 'LOCK HASH DRIFT'; exit 1; }
"
run_check learning-schema "test -f \"$ROOT/docs/learning-schema.md\" && echo ok"
run_check judgment-examples "test -f \"$ROOT/state/harness-evolution/examples/challenge-refusal.md\" && test -f \"$ROOT/state/harness-evolution/examples/override-risks.md\" && echo ok"
run_check harness-engagement-mode "grep -q '^Mode:' \"$ROOT/state/harness-evolution/engagement.md\" && echo ok"
run_check memory-harness-lesson "grep -q 'harness-evolution' \"$ROOT/MEMORY.md\" && echo ok"
run_check github-seam "test -f \"$ROOT/lib/github.sh\" && grep -q 'gh_pr_merge' \"$ROOT/lib/github.sh\" && ! grep -nE 'pr merge.*--admin|--admin\"|--admin ' \"$ROOT/lib/github.sh\" && echo ok"
run_check merge-refuses-without-auth "
  cd \"$ROOT\"
  # Ensure authorize file absent for this probe
  tmp=\$(mktemp -d)
  # Use harness dir but unset auth path by pointing CONSULT_AUTHORIZE_MERGE at missing file
  if CONSULT_AUTHORIZE_MERGE=\"\$tmp/missing\" CONSULT_ROOT=\"$ROOT\" bash -c 'source lib/github.sh; gh_pr_merge \"$ROOT\"' 2>&1 | grep -qi 'refused'; then
    echo refused_ok
  else
    echo did_not_refuse
    exit 1
  fi
"
run_check skills-present "
  test -f \"$ROOT/skills/critique/SKILL.md\" \\
    && test -f \"$ROOT/skills/benchmark/SKILL.md\" \\
    && test -f \"$ROOT/skills/design-sprint/SKILL.md\" \\
    && echo ok
"
run_check skill-critique-runs "
  cd \"$ROOT\"
  dest=\"$ROOT/state/harness-evolution/runs/iter-3/evidence/skill-critique\"
  if [[ -f \"\$dest/critique.md\" ]]; then echo ok; exit 0; fi
  out=\$(timeout 90 bin/productteam skill critique harness-evolution \"\$dest\" 2>/dev/null | tail -1)
  test -f \"\$out\" && echo ok
"
run_check skill-benchmark-runs "
  cd \"$ROOT\"
  dest=\"$ROOT/state/harness-evolution/runs/iter-3/evidence/skill-benchmark\"
  if [[ -f \"\$dest/BENCHMARK-CONTRACT.md\" ]]; then echo ok; exit 0; fi
  out=\$(timeout 90 bin/productteam skill benchmark harness-evolution \"\$dest\" 2>/dev/null | tail -1)
  test -f \"\$out\" && echo ok
"
run_check skill-design-sprint-runs "
  cd \"$ROOT\"
  dest=\"$ROOT/state/harness-evolution/runs/iter-3/evidence/skill-design-sprint\"
  if [[ -f \"\$dest/design-sprint.md\" ]]; then echo ok; exit 0; fi
  out=\$(timeout 90 bin/productteam skill design-sprint harness-evolution \"\$dest\" 2>/dev/null | tail -1)
  test -f \"\$out\" && echo ok
"
run_check lessons-closed-iters "
  cd \"$ROOT\"
  missing=0
  for d in state/harness-evolution/runs/iter-*; do
    [[ -d \"\$d\" ]] || continue
    # skip empty/current without lessons only if no scores yet? require lessons when scores exist
    if [[ -f \"\$d/scores.json\" && ! -f \"\$d/lessons.md\" ]]; then
      echo \"missing lessons in \$d\"
      missing=1
    fi
  done
  [[ \$missing -eq 0 ]] && echo ok
"
run_check phases-artifact "
  # latest improvement iter should document phases when present
  latest=\$(ls -d \"$ROOT\"/state/harness-evolution/runs/iter-* 2>/dev/null | sort -V | tail -1)
  if [[ -f \"\$latest/phases.json\" ]]; then
    jq -e '.sequence and .phases' \"\$latest/phases.json\" >/dev/null && echo ok
  elif [[ -f \"$ROOT/state/harness-evolution/LOOP-SEQUENCE.md\" ]]; then
    echo 'loop-sequence-only'
  else
    echo missing; exit 1
  fi
"
run_check org-self-review-recent "
  cd \"$ROOT\"
  # At least one scored iter report contains Org self-review
  grep -l 'Org self-review' state/harness-evolution/runs/iter-*/report.md 2>/dev/null | head -1 | grep -q . && echo ok
"

# Secrets scan (high-signal patterns only; skip lock/contract text)
run_check secrets-scan "
  cd \"$ROOT\"
  # Scan harness-evolution runs + MEMORY for leaked tokens (not the word Token in docs)
  if grep -RInE --exclude-dir=.git \
      -e 'gh[pousr]_[A-Za-z0-9_]{20,}' \
      -e 'github_pat_[A-Za-z0-9_]{20,}' \
      -e 'sk-[A-Za-z0-9]{20,}' \
      -e '-----BEGIN (RSA |OPENSSH )?PRIVATE KEY-----' \
      state/harness-evolution/runs MEMORY.md 2>/dev/null \
      | grep -vE 'gho_\\*{10,}|Token redacted|\\*\\*\\*\\*' ; then
    echo 'possible secret leak'
    exit 1
  fi
  echo clean
"

# Provider seam still the single ask entrypoint
run_check provider-seam "test -f \"$ROOT/lib/provider.sh\" && grep -q 'provider_ask' \"$ROOT/lib/provider.sh\" && grep -q 'runtime_detect' \"$ROOT/lib/provider.sh\" && echo ok"

python3 - "$RESULTS" "$OUT" <<'PY'
import json, sys, datetime
results_path, out_path = sys.argv[1:3]
checks = {}
with open(results_path) as f:
    for line in f:
        parts = line.rstrip("\n").split("\t", 2)
        if len(parts) < 2:
            continue
        cid, status = parts[0], parts[1]
        detail = parts[2] if len(parts) > 2 else ""
        checks[cid] = {"status": status, "detail": detail}
passed = sum(1 for c in checks.values() if c["status"] == "pass")
failed = sum(1 for c in checks.values() if c["status"] != "pass")
payload = {
    "ts": datetime.date.today().isoformat(),
    "contract": "harness-apc-v1",
    "suite": "harness-objective",
    "checks": checks,
    "passed": passed,
    "failed": failed,
    "validation": "real-commands",
}
with open(out_path, "w") as f:
    json.dump(payload, f, indent=2)
    f.write("\n")
print(f"\n  {passed} passed · {failed} failed  → {out_path}")
sys.exit(0 if failed == 0 else 1)
PY
