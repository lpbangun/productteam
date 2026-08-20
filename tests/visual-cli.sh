#!/usr/bin/env bash
# visual-cli — executable benchmark for the fourteen requested CLI visual features.
# Run from repo root: tests/visual-cli.sh [out.json]
#   - evaluates all fourteen contract ids in state/harness-evolution/visual-contract.json
#     against real CLI/source/state surfaces; it never substitutes a provider
#   - validates (but does not invoke) a live transcript from CONSULT_LIVE_PROOF
#     or the output directory's live-chat-cycle.typescript
#   - emits visible PASS/FAIL rows and writes optional JSON
#   - exits nonzero until 14/14, no skips, and the live proof all pass
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
# Strip ANSI so dim mode chips (mode: <dim>—</dim>) still match the
# five-field footer contract. This is a chat-PTY probe, not a TUI change.
footer_flat=$(printf '%s' "$footer_out" | sed $'s/\x1b\[[0-9;]*[A-Za-z]//g')
if grep -q 'engagement: — · mode: — · provider:' <<<"$footer_flat" \
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

# ── 9. grouped-check-progress ────────────────────────────────────────
# One collapsed summary line derived from the real result JSON the runner
# wrote (checks{} status counts, min scores{} key) — never from progress
# counters. Runs the real ofc-v1 runner against a temporary engagement +
# repo fixture; npm scripts are plain echo stubs, so the fixture is
# deterministic and needs no install.
id=grouped-check-progress
grp_root=$(mktemp -d)
grp_eng="$grp_root/engagements/ofc-demo"
grp_repo="$grp_root/repo"
mkdir -p "$grp_eng/runs" "$grp_repo/src"
printf '{"contract":"ofc-v1","scorer":"checks"}\n' > "$grp_eng/contract.json"
printf '{"name":"ofc-demo","scripts":{"build":"echo built","test":"echo ok"}}\n' > "$grp_repo/package.json"
printf 'Fictional prototype\n' > "$grp_repo/README.md"
printf 'export const MAYA_ID="m1";\nexport const STORAGE_KEY="k";\n// Fictional prototype — Local-only, not a real AI\n// People Ops · Manager · New Hire\n' > "$grp_repo/src/App.tsx"
printf 'export function deriveSupport() {}\n' > "$grp_repo/src/domain.ts"
printf 'export {}\n' > "$grp_repo/src/extra-a.ts"
printf 'export {}\n' > "$grp_repo/src/extra-b.ts"
printf 'export {}\n' > "$grp_repo/src/extra-c.ts"
grp_out=$(NO_COLOR=1 bash "$ROOT/lib/run-checks.sh" ofc-demo "$grp_eng" "$grp_repo" 2>&1)
grp_json="$grp_eng/runs/.checks-latest.json"
grp_expected=$(jq -r --arg c ofc-demo '
  ([.checks | to_entries[] | select(.value.status == "pass")] | length) as $p
  | (.checks | length) as $t
  | (.scores | to_entries | min_by(.value.score) | .key) as $w
  | "checks ▸ \($c) · \($p)/\($t) · weakest: \($w)"
' "$grp_json" 2>/dev/null || true)
if [[ -f "$grp_json" ]] \
   && [[ -n "$grp_expected" ]] \
   && [[ "$(tail -1 <<<"$grp_out")" == "$grp_expected" ]]; then
  pass "$id" "grouped summary '$grp_expected' matches real JSON counts/weakest"
else
  failc "$id" 'grouped checks line does not match counts/weakest derived from result JSON'
fi
rm -rf "$grp_root"

# ── 10. judgment-mode-badge ─────────────────────────────────────────
# Exactly Guided|Directive|Challenge|Override; Override reuses the
# existing escalate styling (▲) instead of a third hue — the two-accent
# budget is already enforced by two-accent-language.
id=judgment-mode-badge
jmodes=$(NO_COLOR=1 bash -c '
  source "$1/lib/theme.sh"; source "$1/lib/provider.sh"; source "$1/lib/repl.sh"
  for m in Guided Directive Challenge Override; do judgment_badge "$m"; printf "\n"; done
' _ "$ROOT")
jmodes_words=$(sed -E 's/^[^ ]+ //' <<<"$jmodes" | sort -u)
if [[ "$jmodes_words" == "$(printf 'Challenge\nDirective\nGuided\nOverride')" ]] \
   && grep -q '^▲ Override' <<<"$jmodes" \
   && ! grep -qE '^▲ (Guided|Directive|Challenge)' <<<"$jmodes"; then
  pass "$id" 'mode vocabulary renders dim chips; Override reuses escalate styling'
else
  failc "$id" 'judgment mode badge vocabulary or Override escalate styling is missing'
fi

# ── 11. honest-partial-output ───────────────────────────────────────
# Real temporary executable provider that writes a prefix then sleeps;
# SIGINT goes to the foreground process group like a real Ctrl+C. Assert
# artifact bytes preserved at the printed path, worker marked failed,
# honest partial wording, REPL alive after interrupt, clean /exit.
id=honest-partial-output
sig_root=$(mktemp -d)
sig_home="$sig_root/home"
sig_prov="$sig_root/bin/slow-provider"
mkdir -p "$sig_root/bin" "$sig_home"
cat > "$sig_prov" <<'PROV'
#!/usr/bin/env bash
printf '%s\n' "$$" > "$CONSULT_STATE_ROOT/provider.pid"
printf 'partial analysis begins\n'
sleep 30 &
printf '%s\n' "$!" > "$CONSULT_STATE_ROOT/provider-child.pid"
wait
PROV
chmod +x "$sig_prov"
sig_out=$( CONSULT_STATE_ROOT="$sig_home" CONSULT_PROVIDER="$sig_prov" python3 - "$C" <<'PY' 2>&1
import os, pty, select, signal, sys, time, glob

cli = sys.argv[1]
pid, fd = pty.fork()
if pid == 0:
    os.execve(cli, [cli, "chat"], os.environ)

def drain(timeout=0.25):
    out = b""
    deadline = time.monotonic() + timeout
    while True:
        remaining = deadline - time.monotonic()
        if remaining <= 0:
            break
        r, _, _ = select.select([fd], [], [], remaining)
        if not r:
            break
        try:
            chunk = os.read(fd, 65536)
        except OSError:
            break
        if not chunk:
            break
        out += chunk
    return out

state_root = os.environ["CONSULT_STATE_ROOT"]
out = drain(1.0)
os.write(fd, b"hello\n")
interrupted = False
deadline = time.time() + 20
while time.time() < deadline and not interrupted:
    out += drain(0.2)
    for a in glob.glob(state_root + "/runs/session-*/artifacts/*.txt"):
        if os.path.getsize(a) > 0:
            try:
                os.killpg(pid, signal.SIGINT)
                interrupted = True
            except OSError:
                pass
            break
out += drain(2.0)
try:
    os.write(fd, b"/exit\n")
except OSError:
    pass
deadline = time.time() + 15
status = None
while time.time() < deadline:
    out += drain(0.4)
    try:
        done, st = os.waitpid(pid, os.WNOHANG)
        if done:
            status = st
            break
    except ChildProcessError:
        status = 0
        break
if status is None:
    try:
        os.killpg(pid, signal.SIGKILL)
    except OSError:
        pass
    try:
        _, status = os.waitpid(pid, 0)
    except ChildProcessError:
        status = 0
sys.stdout.buffer.write(out)
sys.exit(os.waitstatus_to_exitcode(status) if status is not None else 1)
PY
)
sig_rc=$?
sig_art=$(ls "$sig_home"/runs/session-*/artifacts/*.txt 2>/dev/null | head -1)
sig_tsv=$(ls "$sig_home"/runs/session-*/workers.tsv 2>/dev/null | head -1)
sig_provider_pid=$(cat "$sig_home/provider.pid" 2>/dev/null || true)
sig_child_pid=$(cat "$sig_home/provider-child.pid" 2>/dev/null || true)
sleep 1
if [[ $sig_rc -eq 0 && -n "$sig_art" && -f "$sig_art" ]] \
   && grep -qF 'partial analysis begins' "$sig_art" \
   && [[ -n "$sig_tsv" ]] \
   && awk -F'\t' '$3=="failed"{c++} END{exit !(c>=1)}' "$sig_tsv" \
   && grep -qF 'Ctrl+C leaves partial on disk' <<<"$sig_out" \
   && grep -qF 'Ctrl+C — partial output left on disk' <<<"$sig_out" \
   && grep -qi 'working' <<<"$sig_out" \
   && grep -qF "$sig_art" <<<"$sig_out" \
   && [[ -n "$sig_provider_pid" && -n "$sig_child_pid" ]] \
   && ! ps -p "$sig_provider_pid" >/dev/null 2>&1 \
   && ! ps -p "$sig_child_pid" >/dev/null 2>&1; then
  pass "$id" 'SIGINT keeps REPL alive; artifact bytes/path preserved; worker marked failed'
else
  failc "$id" 'SIGINT run did not preserve the partial artifact, mark the worker failed, and exit cleanly'
fi
rm -rf "$sig_root"

# ── 12. slash-palette-hints ─────────────────────────────────────────
# One canonical command array shared by /help and prefix hints; the hint
# list updates live during readline entry as the slash prefix is typed
# (no alternate screen). The PTY probe types `/c` then `h` and requires
# the live hint to list checks and clear, then narrow to checks only.
id=slash-palette-hints
pal_root=$(mktemp -d)
pal_seg1="$pal_root/seg1"
pal_seg2="$pal_root/seg2"
pal_out=$(PAL_SEG1="$pal_seg1" PAL_SEG2="$pal_seg2" python3 - "$C" <<'PY' 2>&1
import os, pty, select, sys, time

cli = sys.argv[1]
pid, fd = pty.fork()
if pid == 0:
    os.execve(cli, [cli, "chat"], os.environ)

def drain(timeout=0.3):
    out = b""
    while True:
        r, _, _ = select.select([fd], [], [], timeout)
        if not r:
            break
        try:
            chunk = os.read(fd, 65536)
        except OSError:
            break
        if not chunk:
            break
        out += chunk
    return out

out = drain(1.0)
os.write(fd, b"/")
out += drain(0.6)
os.write(fd, b"c")
seg = b""
deadline = time.time() + 10
while time.time() < deadline and b"checks" not in seg:
    seg += drain(0.2)
out += seg
os.write(fd, b"h")
seg2 = b""
deadline = time.time() + 10
while time.time() < deadline and b"checks" not in seg2:
    seg2 += drain(0.2)
out += seg2
time.sleep(0.4)
out += drain(0.5)
os.write(fd, b"\r")
out += drain(1.0)
os.write(fd, b"/bench\r")
out += drain(1.0)
os.write(fd, b"/exit\r")
out += drain(0.5)
with open(os.environ["PAL_SEG1"], "wb") as f:
    f.write(seg)
with open(os.environ["PAL_SEG2"], "wb") as f:
    f.write(seg2)
try:
    os.close(fd)
except OSError:
    pass
_, status = os.waitpid(pid, 0)
sys.stdout.buffer.write(out)
sys.exit(os.waitstatus_to_exitcode(status))
PY
)
pal_rc=$?
pal_seg1_txt=$(cat "$pal_seg1" 2>/dev/null)
pal_seg2_txt=$(cat "$pal_seg2" 2>/dev/null)
help_verbs=$(pty_chat $'/help\n/exit\n' 2>&1 | grep -oE '/[a-z][a-z-]*' | tr -d '/' | sort -u)
missing_verbs=$(NO_COLOR=1 bash -c '
  source "$1/lib/theme.sh"; source "$1/lib/provider.sh"; source "$1/lib/repl.sh"
  for v in $2; do
    r=$(repl_slash_hints "$v" 2>/dev/null || true)
    grep -qF "$v" <<<"$r" || printf "%s\n" "$v"
  done
' _ "$ROOT" "$help_verbs")
if [[ $pal_rc -eq 0 ]] \
   && grep -qF 'checks' <<<"$pal_seg1_txt" \
   && grep -qF 'clear' <<<"$pal_seg1_txt" \
   && grep -qF 'checks' <<<"$pal_seg2_txt" \
   && ! grep -qF 'clear' <<<"$pal_seg2_txt" \
   && ! grep -qF $'\e[?1049h' <<<"$pal_out" \
   && grep -q 'repl_slash_verbs=' "$ROOT/lib/repl.sh" \
   && grep -q 'repl_slash_hints' "$ROOT/lib/repl.sh" \
   && [[ -z "$missing_verbs" ]]; then
  pass "$id" 'live prefix hints narrow while typing; help and hints share one verb array'
else
  failc "$id" 'slash palette does not update live per prefix or diverges from the help verbs'
fi
rm -rf "$pal_root"

# ── 13. transcript-export ───────────────────────────────────────────
# Timestamped separators between turns, honest raw markdown recorded,
# and /export writing under ${STATE_ROOT}/sessions/ with the path printed.
# The provider is a real deterministic markdown-answering executable.
id=transcript-export
exp_root=$(mktemp -d)
exp_prov="$exp_root/provider.sh"
printf '#!/usr/bin/env bash\nprintf "%%s\\n" "# Heading" "**Verdict:** PASS" "- one"\n' > "$exp_prov"
chmod +x "$exp_prov"
exp_out=$( CONSULT_STATE_ROOT="$exp_root" CONSULT_PROVIDER="$exp_prov" pty_chat $'hello\n/export\n/exit\n' 2>&1 )
exp_file=$(ls "$exp_root"/sessions/chat-*.md 2>/dev/null | head -1)
if [[ -n "$exp_file" ]] \
   && grep -q 'hello' "$exp_file" \
   && grep -q '# Heading' "$exp_file" \
   && grep -qF '**Verdict:** PASS' "$exp_file" \
   && grep -qE '── [0-9]{2}:[0-9]{2}:[0-9]{2} · user ──' "$exp_file" \
   && grep -qE '── [0-9]{2}:[0-9]{2}:[0-9]{2} · assistant ──' "$exp_file" \
   && grep -qF "$exp_file" <<<"$exp_out"; then
  pass "$id" "timestamped export under sessions/ with both turns, honest markdown, printed path"
else
  failc "$id" 'transcript export path, turn separators, or honest markdown content is missing'
fi
rm -rf "$exp_root"

# ── 14. header-score-spark ──────────────────────────────────────────
# The prompt-adjacent chrome shows the selected engagement's score trend
# as a sparkline computed from the real history.jsonl overalls with the
# documented spark() formula; the five v1 footer fields remain (checked
# by session-footer).
id=header-score-spark
spark_hist="$ROOT/state/engagements/harness-cli/history.jsonl"
spark_expected=$(jq -r '.overall' "$spark_hist" 2>/dev/null | python3 -c '
import sys
b = "▁▂▃▄▅▆▇█"
print("".join(b[max(0, min(7, int(float(v.strip()) / 10 * 7.99)))] for v in sys.stdin if v.strip()))
')
spark_out=$(pty_chat $'/bench harness-cli\n/exit\n' 2>&1)
if [[ -n "$spark_expected" ]] \
   && grep -qE "history: .*$spark_expected" <<<"$spark_out" \
   && grep -q 'mode: .*Directive' <<<"$spark_out"; then
  pass "$id" "chrome spark '$spark_expected' matches real history.jsonl; mode badge present"
else
  failc "$id" 'prompt-adjacent chrome lacks the history-derived spark or the mode badge'
fi

# ── result + required live proof ─────────────────────────────────────
passed=0
for k in role-chrome worker-strip live-loading-card two-accent-language \
         evidence-path-highlight markdown-lite session-footer agents-provider-cycle \
         grouped-check-progress judgment-mode-badge honest-partial-output \
         slash-palette-hints transcript-export header-score-spark; do
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
if [[ $passed -eq 14 && "$live_status" == pass ]]; then
  converged=true
fi
printf '\n  %d/14 pass · %d fail · %d skipped · live provider proof %s\n' \
  "$passed" "$((14 - passed - skipped))" "$skipped" "$live_status"
if [[ -n "$OUT" ]]; then
  {
    printf '{\n'
    printf '  "contract": "visual-cli-v2",\n'
    printf '  "ts": "%s",\n' "$(date +%F)"
    printf '  "passed": %d,\n  "failed": %d,\n  "skipped": %d,\n' "$passed" "$((14 - passed - skipped))" "$skipped"
    printf '  "converged": %s,\n' "$converged"
    printf '  "results": {\n'
    first=1
    for k in role-chrome worker-strip live-loading-card two-accent-language \
             evidence-path-highlight markdown-lite session-footer agents-provider-cycle \
             grouped-check-progress judgment-mode-badge honest-partial-output \
             slash-palette-hints transcript-export header-score-spark; do
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
