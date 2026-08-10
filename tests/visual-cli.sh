#!/usr/bin/env bash
# visual-cli — executable benchmark for the eight requested CLI visual features.
# Run from repo root: tests/visual-cli.sh [out.json]
#   - evaluates all eight contract ids in state/harness-evolution/visual-contract.json
#     against real CLI/source/state surfaces; it never substitutes a provider
#   - validates (but does not invoke) a live transcript from CONSULT_LIVE_PROOF
#     or the output directory's live-chat-cycle.typescript
#   - emits visible PASS/FAIL rows and writes optional JSON
#   - exits nonzero until 8/8, no skips, and the live proof all pass
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
C="$ROOT/bin/productteam"
OUT="${1:-}"
CONTRACT="$ROOT/state/harness-evolution/visual-contract.json"

# ── helpers ─────────────────────────────────────────────────────────
fail=0
declare -A RESULT
pass() { RESULT["$1"]="pass"; printf '  PASS  %-24s %s\n' "$1" "$2"; }
failc() { RESULT["$1"]="fail"; fail=1; printf '  FAIL  %-24s %s\n' "$1" "$2"; }

# Accent hue literals only; bold/dim/reset are structural, not accent colors.
accent_codes() {
  grep -hoE '\\e\[(3[0-7]|9[0-7])m' "$ROOT"/bin/productteam "$ROOT"/lib/*.sh 2>/dev/null | sort -u
}

pty_chat() { # $1=commands $2=provider(optional) → real CLI transcript via stdlib PTY
  python3 - "$C" "$1" "${2:-}" <<'PY'
import errno, os, pty, sys

cli, commands, provider = sys.argv[1:4]
pid, fd = pty.fork()
if pid == 0:
    env = os.environ.copy()
    if provider:
        env["CONSULT_PROVIDER"] = provider
    os.execve(cli, [cli, "chat"], env)

os.write(fd, commands.encode())
chunks = []
while True:
    try:
        chunks.append(os.read(fd, 65536))
    except OSError as exc:
        if exc.errno != errno.EIO:
            raise
        break
os.close(fd)
_, status = os.waitpid(pid, 0)
sys.stdout.buffer.write(b"".join(chunks))
raise SystemExit(os.waitstatus_to_exitcode(status))
PY
}

# ── 1. role-chrome ──────────────────────────────────────────────────
id=role-chrome
roles=$(NO_COLOR=1 bash -c '
  source "$1/lib/theme.sh"
  for role in Principal Analyst Builder Critic; do role_chrome "$role"; printf "\n"; done
' _ "$ROOT")
chat_roles=$(pty_chat $'hello\n/exit\n' /nonexistent 2>&1)
if [[ $(sort -u <<<"$roles" | grep -c .) -eq 4 ]] \
   && grep -q '◆ Principal' <<<"$chat_roles" \
   && grep -q '◇ Analyst' <<<"$chat_roles"; then
  pass "$id" 'four distinct role tags; Principal prompt and Analyst return card'
else
  failc "$id" 'role tags are not structurally distinct or absent from chat turns'
fi

# ── 2. worker-strip ─────────────────────────────────────────────────
id=worker-strip
worker_root=$(mktemp -d)
worker_out=$(NO_COLOR=1 bash -c '
  STATE_ROOT="$1"; source "$2/lib/theme.sh"; source "$2/lib/activity.sh"
  activity_init >/dev/null
  wid=$(activity_start Analyst "scoring contract" agent "$STATE_ROOT/runs/score.json")
  activity_update "$wid" running
  activity_update "$wid" done "$STATE_ROOT/runs/score.json"
  activity_strip
  printf "BACKING=%s\n" "$(_act_session_dir)/workers.tsv"
  test -f "$(_act_session_dir)/workers.tsv"
' _ "$worker_root" "$ROOT" 2>&1)
if grep -q 'done' <<<"$worker_out" \
   && grep -q 'Analyst' <<<"$worker_out" \
   && grep -q 'scoring contract' <<<"$worker_out" \
   && grep -q 'agent' <<<"$worker_out" \
   && grep -qE 'BACKING=.*/runs/session-[^/]+/workers.tsv' <<<"$worker_out" \
   && grep -qE 'pending\\|running\\|done\\|failed' "$ROOT/lib/activity.sh"; then
  pass "$id" 'isolated runs/session worker log renders role, mission, provider, done'
else
  failc "$id" 'worker state is not file-backed under runs or strip fields are incomplete'
fi
rm -rf "$worker_root"

# ── 3. live-loading-card ────────────────────────────────────────────
id=live-loading-card
chat_out="$chat_roles"
if grep -q '…' <<<"$chat_out" \
   && grep -q '/nonexistent' <<<"$chat_out" \
   && grep -qE '[0-9]+s' <<<"$chat_out" \
   && grep -q 'hello' <<<"$chat_out" \
   && grep -q 'failed' <<<"$chat_out" \
   && grep -q '◇ Analyst' <<<"$chat_out" \
   && grep -q 'productteam: provider /nonexistent is not a usable executable' <<<"$chat_out" \
   && grep -q 'activity_spinner' "$ROOT/lib/repl.sh"; then
  pass "$id" 'loading fields + elapsed failure card; live success proof remains required'
else
  failc "$id" 'loading mission/provider/elapsed or compact role card is missing'
fi

# ── 4. two-accent-language ───────────────────────────────────────────
id=two-accent-language
codes=$(accent_codes)
badges=$(NO_COLOR=1 bash -c '
  source "$1/lib/theme.sh"
  for state in success error progress escalate pending running done failed; do
    status_badge "$state"; printf "\n"
  done
' _ "$ROOT")
if [[ $(grep -c . <<<"$codes") -eq 2 ]] \
   && grep -qF '\e[31m' <<<"$codes" \
   && grep -qF '\e[32m' <<<"$codes" \
   && grep -q '✓ success' <<<"$badges" \
   && grep -q '✗ error' <<<"$badges" \
   && grep -q '… progress' <<<"$badges" \
   && grep -q '▲ escalate' <<<"$badges" \
   && grep -q '○ pending' <<<"$badges"; then
  pass "$id" 'two accent hues + legible glyph language for every semantic state'
else
  failc "$id" 'accent budget or semantic status renderer contract failed'
fi

# ── 5. evidence-path-highlight ───────────────────────────────────────
id=evidence-path-highlight
bench_flat=$("$C" bench harness-cli 2>&1)
bench_nested=$("$C" bench onboarding-flight-control 2>&1)
run_out=$("$C" run harness-cli 1 2>&1)
if grep -qE '[+][0-9]+\.[0-9]+ checks\.json:' <<<"$bench_flat" \
   && grep -qE '[+][0-9]+\.[0-9]+ checks\.json:' <<<"$run_out" \
   && grep -q 'HISTORY' <<<"$bench_nested" \
   && grep -q 'render_markdown_lite' "$C" \
   && grep -q 'render_evidence' "$C"; then
  pass "$id" 'flat+nested histories render; real deltas sit beside evidence paths'
else
  failc "$id" 'score schema normalization, delta, or evidence path rendering failed'
fi

# ── 6. markdown-lite ─────────────────────────────────────────────────
id=markdown-lite
md_sample=$(mktemp)
printf '# Heading\n**Verdict:** PASS\n```sh\necho ok\n```\n' > "$md_sample"
md_out=$(B='<B>' D='<D>' R='<R>' G='<G>' RD='<RD>' bash -c '
  source "$1/lib/render.sh"; render_markdown_lite "$2"
' _ "$ROOT" "$md_sample")
rm -f "$md_sample"
if grep -q '<G>Heading' <<<"$md_out" \
   && grep -q '<B>Verdict: PASS' <<<"$md_out" \
   && grep -q '<D>```' <<<"$md_out" \
   && grep -q 'echo ok' <<<"$md_out" \
   && grep -q 'render_markdown_lite "$1"' "$ROOT/lib/repl.sh" \
   && grep -q 'render_markdown_lite "$d/runs/$last/report.md"' "$C"; then
  pass "$id" 'heading, verdict, fence, and body render without content loss'
else
  failc "$id" 'markdown-lite renderer or chat/report integration is incomplete'
fi

# ── 7. session-footer ────────────────────────────────────────────────
id=session-footer
footer_out=$(pty_chat $'/bench harness-cli\n/exit\n' 2>&1)
if grep -q 'engagement: — · mode: — · provider:' <<<"$footer_out" \
   && grep -qE 'engagement: harness-cli .* mode: .* provider: .* last-iter: iter-1 .* overall: 9\.5' <<<"$footer_out" \
   && grep -q '◆ Principal.*›' <<<"$footer_out"; then
  pass "$id" 'five-field status line redraws above prompt and refreshes after /bench'
else
  failc "$id" 'status line fields, prompt placement, or /bench refresh is missing'
fi

# ── 8. agents-provider-cycle ─────────────────────────────────────────
id=agents-provider-cycle
agents_out=$(pty_chat $'/provider\n/agents\n/exit\n' 2>&1)
if grep -q 'provider →' <<<"$agents_out" \
   && grep -q '(selected)' <<<"$agents_out" \
   && grep -q 'missing ·' <<<"$agents_out" \
   && grep -q 'runtime_cycle' "$ROOT/lib/repl.sh" \
   && grep -q 'AGENT_CATALOG' "$ROOT/lib/provider.sh"; then
  pass "$id" '/provider cycles installed catalog; /agents shows selected and missing'
else
  failc "$id" 'provider cycle dispatch or installed/missing/selected presence is incomplete'
fi

# ── result + required live proof ─────────────────────────────────────
passed=0
for k in role-chrome worker-strip live-loading-card two-accent-language \
         evidence-path-highlight markdown-lite session-footer agents-provider-cycle; do
  [[ "${RESULT[$k]:-}" == pass ]] && passed=$((passed + 1))
done
skipped=0
live_path="${CONSULT_LIVE_PROOF:-}"
if [[ -z "$live_path" && -n "$OUT" ]]; then
  live_path="$(dirname "$OUT")/live-chat-cycle.typescript"
fi
live_status=missing
if [[ -n "$live_path" && -f "$live_path" ]]; then
  if grep -q 'provider →' "$live_path" \
     && grep -q '(selected)' "$live_path" \
     && grep -q '✓ done.*Analyst' "$live_path" \
     && grep -q 'LIVE-CYCLE-OK' "$live_path"; then
    live_status=pass
  else
    live_status=fail
  fi
fi
converged=false
if [[ $passed -eq 8 && "$live_status" == pass ]]; then
  converged=true
fi
printf '\n  %d/8 pass · %d fail · %d skipped · live provider proof %s\n' \
  "$passed" "$((8 - passed - skipped))" "$skipped" "$live_status"
if [[ -n "$OUT" ]]; then
  {
    printf '{\n'
    printf '  "contract": "visual-cli-v1",\n'
    printf '  "ts": "%s",\n' "$(date +%F)"
    printf '  "passed": %d,\n  "failed": %d,\n  "skipped": %d,\n' "$passed" "$((8 - passed - skipped))" "$skipped"
    printf '  "converged": %s,\n' "$converged"
    printf '  "results": {\n'
    first=1
    for k in role-chrome worker-strip live-loading-card two-accent-language \
             evidence-path-highlight markdown-lite session-footer agents-provider-cycle; do
      [[ $first -eq 0 ]] && printf ',\n'
      first=0
      printf '    "%s": "%s"' "$k" "${RESULT[$k]:-fail}"
    done
    printf '\n  },\n'
    printf '  "live_provider_proof": {"required": true, "status": "%s", "path": "%s"}\n' \
      "$live_status" "$live_path"
    printf '}\n'
  } > "$OUT"
  printf '  result → %s\n' "$OUT"
fi
[[ "$converged" == true ]] && exit 0
exit 1
