#!/usr/bin/env bash
# cli-interface-parity — frozen benchmark probes for the ProductTeam
# CLI (contract cli-interface-20260812-v3).
#
# Verifies the objective, observable layer of the frozen contract
# `state/harness-evolution/runs/cli-interface-20260812/CLI-BENCHMARK-CONTRACT.md`:
#   1. signature           — frozen contract hash matches FREEZE-SHA.txt
#   2. help surface        — help/-h/--help exit 0; names all 32 commands
#   3. D1 reachability     — checks on a cold checkout; non-destructive guard
#   4. D3 README parity    — README documents every help-listed command
#   5. chat reachability   — non-TTY refusal with TTY remedy
#   6. D6a registry        — help --json membership derived + cross-checked
#                            against the frozen classification table
#   7. chat classification — PTY /help palette and per-unsupported
#                            unknown/reason behavior, driven by the registry
#                            when available, frozen fallback at baseline
#   8. D2 slash forwarding — /score /bench --iter via PTY; CLI controls
#   9. D5 quoted argv      — /provider "codex" parses; embedded text inert
#  10. JSON boundary       — existing --json surfaces parse
#  11. D6b status --json   — engagement list
#  12. D4 onboarding       — current score syntax (--iter)
#  13. D7 bench/run        — honest on summary-shaped scores (no jq exit 5)
#  14. CLI argv safety     — multi-word round-trip; empty rejected
#  15. ANSI/NO_COLOR       — no ANSI outside a color TTY
#  16. exit-code honesty   — unknown command / usage errors non-zero
#
# Failing baseline (iter 1, 2026-08-12): probes 3, 4, 6, 8, 9, 11, 12, 13
# fail on the verified D1–D7 defects listed in the contract's baseline
# section. Probes are suitable unchanged after repair: each asserts the
# repaired observable contract, not implementation source text. Chat
# supported/unsupported/chat-only membership is DERIVED from the help --json
# registry when present and cross-checked against the frozen classification
# table; PTY palette/unknown expectations use the registry when available and
# fall back to the frozen classification only while the registry is absent
# (i.e. the failing baseline).
#
# Run from repo root: tests/cli-interface-parity.sh
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
C="$ROOT/bin/productteam"
RUN="$ROOT/state/harness-evolution/runs/cli-interface-20260812"
fail=0
ok()   { printf '  PASS  %s\n' "$1"; }
bad()  { printf '  FAIL  %s\n' "$1"; fail=1; }

export CONSULT_STATE_ROOT
CONSULT_STATE_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/cli-parity.XXXXXX")"
export CONSULT_NO_SPLASH=1
PWNED="/tmp/cli-parity-pwned-$$"
trap 'rm -rf "$CONSULT_STATE_ROOT" "${CONSULT_STYLE_DIR:-}" "$PWNED" "$ROOT/tmp/workspaces/onboarding-flight-control"' EXIT

# Frozen command table (help is the canonical surface).
commands=(agents baseline bench card chat checks direction escalation gate gh
  harness-checks help inspect judge memory onboarding open org pool
  project-memory report role run run-loop runtime score skill smoke splash
  status style tui workspace)
# Frozen classification table (contract §2). The registry must agree; used as
# baseline-safe fallback while help --json is absent.
frozen_palette=(help status agents runtime onboarding splash judge score checks
  bench report run memory org gh skill smoke harness-checks workers provider
  clear export exit quit)
frozen_unsupported=(chat open baseline workspace gate direction escalation
  inspect role card style project-memory pool run-loop tui)
frozen_chat_only=(provider workers clear export exit quit)

printf '\n  cli-interface parity v3 (frozen contract %s)\n\n' 'cli-interface-20260812-v3'

# ── 1. signature: frozen contract hash must match FREEZE-SHA.txt ────────────
if [[ -f "$RUN/CLI-BENCHMARK-CONTRACT.md" && -f "$RUN/FREEZE-SHA.txt" ]]; then
  want=$(cut -d' ' -f1 "$RUN/FREEZE-SHA.txt" | tr -d '[:space:]')
  got=$(sha256sum "$RUN/CLI-BENCHMARK-CONTRACT.md" | cut -d' ' -f1)
  if [[ -n "$want" && "$want" == "$got" ]]; then
    ok 'frozen contract hash matches FREEZE-SHA.txt'
  else
    bad "frozen contract hash mismatch (freeze: ${want:-missing}, actual: $got)"
  fi
else
  bad 'frozen contract or FREEZE-SHA.txt missing'
fi

# ── 2. reachability: help surface exits 0, every top-level command named ─────
"$C" help >/dev/null 2>&1 && ok 'help exits 0' || bad 'help exits 0'
"$C" -h >/dev/null 2>&1 && ok '-h exits 0' || bad '-h exits 0'
"$C" --help >/dev/null 2>&1 && ok '--help exits 0' || bad '--help exits 0'
help_out="$("$C" help 2>/dev/null)"
missing=0
for cmd in "${commands[@]}"; do
  grep -q "productteam $cmd" <<<"$help_out" || { missing=1; bad "help names $cmd"; }
done
[[ $missing == 0 ]] && ok 'help names all 33 top-level commands'

# ── 3. D1 — reachability on a cold checkout + non-destructive recovery ───────
if "$C" checks onboarding-flight-control >/tmp/cli-parity-checks.out 2>&1; then
  ok 'checks onboarding-flight-control exits 0'
else
  rc=$?
  msg=$(grep -m1 'workspace-metadata-mismatch\|error:' /tmp/cli-parity-checks.out || true)
  bad "checks onboarding-flight-control exits 0 (rc=$rc — ${msg:-no message})"
fi
# Non-destructive guard (v3 D1 policy): recovery may recreate metadata only
# when the recorded path is absent; it must never delete/reset an existing
# path. A marker dir at the would-be workspace path must survive a checks
# attempt byte-identical. (tmp/ is gitignored; removed on exit.)
WS="$ROOT/tmp/workspaces/onboarding-flight-control"
mkdir -p "$WS" && printf 'keep-me\n' > "$WS/.cli-parity-marker"
"$C" checks onboarding-flight-control >/dev/null 2>&1 || true
if [[ -f "$WS/.cli-parity-marker" && "$(cat "$WS/.cli-parity-marker")" == 'keep-me' ]]; then
  ok 'workspace recovery is non-destructive (existing path untouched)'
else
  bad 'workspace recovery is non-destructive (existing path touched/deleted)'
fi

# ── 4. D3 — help/README command parity ───────────────────────────────────────
readme_missing=0
for cmd in "${commands[@]}"; do
  grep -qE "productteam $cmd([ .]|$)" "$ROOT/README.md" || { readme_missing=1; bad "README documents $cmd"; }
done
[[ $readme_missing == 0 ]] && ok 'README documents every help-listed command'

# ── 5. chat reachability: non-TTY must refuse honestly ───────────────────────
if "$C" chat </dev/null >/dev/null 2>&1; then
  bad 'chat refuses non-TTY (exit non-zero)'
else
  msg=$("$C" chat </dev/null 2>&1 || true)
  grep -q 'TTY' <<<"$msg" && ok 'chat refuses non-TTY with TTY remedy' || bad 'chat refusal names TTY remedy'
fi

# ── 6. D6a — registry metadata: help --json membership (derived + cross-check)
# Derive supported / unsupported / chat_only MEMBERSHIP from the registry.
# Cross-check against the frozen classification table; name every mismatch.
reg_supported=() reg_unsupported=() reg_chat_only=()
if reg=$(timeout 30 "$C" help --json 2>/dev/null | jq -e . 2>/dev/null); then
  mapfile -t reg_supported < <(jq -r '.commands[] | select(.chat_supported == true) | .name' <<<"$reg" | sort)
  mapfile -t reg_unsupported < <(jq -r '.commands[] | select(.chat_supported == false) | .name' <<<"$reg" | sort)
  mapfile -t reg_chat_only < <(jq -r '.chat_only[]?' <<<"$reg" | sort)
  exp_supported=()
  for v in "${frozen_palette[@]}"; do
    for co in "${frozen_chat_only[@]}"; do [[ "$v" == "$co" ]] && continue 2; done
    exp_supported+=("$v")
  done
  exp_supported_sorted=$(printf '%s\n' "${exp_supported[@]}" | sort)
  sup_sorted=$(printf '%s\n' "${reg_supported[@]}")
  unsup_sorted=$(printf '%s\n' "${reg_unsupported[@]}")
  frozen_unsup_sorted=$(printf '%s\n' "${frozen_unsupported[@]}" | sort)
  co_sorted=$(printf '%s\n' "${reg_chat_only[@]}")
  frozen_co_sorted=$(printf '%s\n' "${frozen_chat_only[@]}" | sort)
  mism=0
  # command table membership: registry names must equal the frozen 33
  reg_names=$(jq -r '.commands[]?.name' <<<"$reg" | sort | tr '\n' ' ')
  exp_names=$(printf '%s\n' "${commands[@]}" | sort | tr '\n' ' ')
  [[ "$reg_names" == "$exp_names" ]] || { mism=1; bad "help --json registry names match the 33-command table"; }
  # supported membership: registry chat_supported=true == frozen palette minus chat_only
  if [[ "$sup_sorted" == "$exp_supported_sorted" ]]; then :; else
    mism=1
    miss=$(comm -23 <(printf '%s\n' "$exp_supported_sorted") <(printf '%s\n' "$sup_sorted") | tr '\n' ' ')
    extra=$(comm -13 <(printf '%s\n' "$exp_supported_sorted") <(printf '%s\n' "$sup_sorted") | tr '\n' ' ')
    bad "help --json chat_supported membership matches classification (missing: ${miss:-none}, unexpected: ${extra:-none})"
  fi
  # unsupported membership: registry chat_supported=false == frozen 15
  if [[ "$unsup_sorted" == "$frozen_unsup_sorted" ]]; then :; else
    mism=1
    miss=$(comm -23 <(printf '%s\n' "$frozen_unsup_sorted") <(printf '%s\n' "$unsup_sorted") | tr '\n' ' ')
    extra=$(comm -13 <(printf '%s\n' "$frozen_unsup_sorted") <(printf '%s\n' "$unsup_sorted") | tr '\n' ' ')
    bad "help --json chat_supported=false membership matches frozen 15 (missing: ${miss:-none}, unexpected: ${extra:-none})"
  fi
  # chat_only membership: registry chat_only == frozen 6
  if [[ "$co_sorted" == "$frozen_co_sorted" ]]; then :; else
    mism=1
    miss=$(comm -23 <(printf '%s\n' "$frozen_co_sorted") <(printf '%s\n' "$co_sorted") | tr '\n' ' ')
    extra=$(comm -13 <(printf '%s\n' "$frozen_co_sorted") <(printf '%s\n' "$co_sorted") | tr '\n' ' ')
    bad "help --json chat_only membership matches frozen 6 (missing: ${miss:-none}, unexpected: ${extra:-none})"
  fi
  # per-command attributes: every command needs a usage string
  for cmd in "${commands[@]}"; do
    u=$(jq -r --arg n "$cmd" '.commands[] | select(.name == $n) | .usage // ""' <<<"$reg")
    [[ -n "$u" ]] || { mism=1; bad "help --json registry has usage for $cmd"; }
  done
  # reason behavior: every unsupported command needs a non-empty chat_reason
  for cmd in "${frozen_unsupported[@]}"; do
    r=$(jq -r --arg n "$cmd" '.commands[] | select(.name == $n) | .chat_reason // ""' <<<"$reg")
    [[ -n "$r" ]] || { mism=1; bad "help --json registry has chat_reason for unsupported $cmd"; }
  done
  [[ $mism == 0 ]] && ok 'help --json registry membership matches frozen classification (33/18/15/6)'
else
  bad 'help --json emits a parseable command registry (got prose or exit != 0)'
  # registry absent: baseline-safe fallback for the PTY probes below
  reg_supported=(); for v in "${frozen_palette[@]}"; do
    for co in "${frozen_chat_only[@]}"; do [[ "$v" == "$co" ]] && continue 2; done
    reg_supported+=("$v")
  done
  reg_unsupported=("${frozen_unsupported[@]}")
  reg_chat_only=("${frozen_chat_only[@]}")
fi

# ── 7. chat classification via real PTY (registry-driven, frozen fallback) ──
# 7a. /help palette membership; 7b. per-unsupported unknown behavior.
UNSUP_EXPECTED="${reg_unsupported[*]}"
pty_cls=$(UNSUP="$UNSUP_EXPECTED" CMD="$C" timeout 50 python3 - <<'PYEOF'
import os, pty, select, sys, time, tempfile
cli = os.environ['CMD']; unsup = os.environ['UNSUP'].split()
env = dict(os.environ)
for k in ('NO_COLOR', 'CONSULT_NO_SPLASH'): env.pop(k, None)
env['CONSULT_STATE_ROOT'] = tempfile.mkdtemp()
pid, fd = pty.fork()
if pid == 0:
    os.execvpe(cli, [cli, 'chat'], env)
out = b''
def pump(seconds):
    global out
    end = time.time() + seconds
    while time.time() < end:
        r, _, _ = select.select([fd], [], [], 0.1)
        if fd in r:
            try:
                d = os.read(fd, 4096)
                if not d: return False
                out += d
            except OSError: return False
    return True
time.sleep(1.0); pump(0.4)
os.write(fd, b'/help\n'); pump(1.0)
for v in unsup:
    os.write(fd, ('/%s x\n' % v).encode()); pump(0.2)
os.write(fd, b'/exit\n'); pump(1.0)
try: os.waitpid(pid, 0)
except ChildProcessError: pass
txt = out.decode('utf-8', 'replace').replace('\r', '')
vparts = []
for line in txt.splitlines():
    s = line.strip()
    if s.startswith('/help /status') or '/exit /quit' in s:
        vparts.append(s)
if vparts:
    sys.stdout.write('VLINE:' + ' '.join(vparts) + '\n')
for v in unsup:
    sys.stdout.write('U:%s:%d\n' % (v, ('unknown /%s ' % v) in txt))
PYEOF
)
# 7a. palette membership: every expected verb appears in /help
palette_line=$(sed -n 's/^VLINE://p' <<<"$pty_cls" | head -1)
palette_ok=1
exp_palette=("${reg_supported[@]}" "${reg_chat_only[@]}")
for v in "${exp_palette[@]}"; do
  grep -qE "/$v([ ]|$)" <<<"$palette_line" || { palette_ok=0; bad "/help lists /$v"; }
done
[[ $palette_ok == 1 ]] && ok "/help lists the full palette ($(printf '%s ' "${exp_palette[@]}" | wc -w | tr -d ' ') verbs: registry-derived)"
# 7b. per-unsupported unknown behavior
unknown_ok=1
for v in "${reg_unsupported[@]}"; do
  u=$(sed -n "s/^U:$v:\([01]\)$/\1/p" <<<"$pty_cls")
  [[ "$u" == 1 ]] || { unknown_ok=0; bad "unsupported /$v yields 'unknown /$v — /help'"; }
done
[[ $unknown_ok == 1 ]] && ok "all ${#reg_unsupported[@]} unsupported commands classify honestly in chat"

# ── 8. D2 — slash argument forwarding via real PTY (no provider invocation) ──
# CLI controls prove the honest downstream outcome is a stamp refusal, not a
# missing-iter error; the slash probe must reach that same downstream state.
score_ctl=$(timeout 30 "$C" score onboarding-flight-control --iter 0 2>&1 || true)
bench_ctl=$(timeout 30 "$C" bench harness-evolution run --iter 7 2>&1 || true)
if grep -q 'missing Analyst stamp' <<<"$score_ctl" && ! grep -q 'requires --iter' <<<"$score_ctl"; then
  ok 'CLI control: score --iter 0 reaches stamp refusal (not missing-iter)'
else
  bad 'CLI control: score --iter 0 reaches stamp refusal (not missing-iter)'
fi
if grep -q 'missing Analyst stamp' <<<"$bench_ctl" && ! grep -q 'requires --iter' <<<"$bench_ctl"; then
  ok 'CLI control: bench run --iter 7 reaches stamp refusal (not missing-iter)'
else
  bad 'CLI control: bench run --iter 7 reaches stamp refusal (not missing-iter)'
fi

pty_slash() { # $1=slash line → RESULT lines
  SLASH="$1" CMD="$C" timeout 50 python3 - <<'PYEOF'
import os, pty, select, sys, time, tempfile
mode = os.environ['SLASH']; cli = os.environ['CMD']
env = dict(os.environ)
for k in ('NO_COLOR', 'CONSULT_NO_SPLASH'): env.pop(k, None)
env['CONSULT_STATE_ROOT'] = tempfile.mkdtemp()
pid, fd = pty.fork()
if pid == 0:
    os.execvpe(cli, [cli, 'chat'], env)
out = b''
def pump(seconds):
    global out
    end = time.time() + seconds
    while time.time() < end:
        r, _, _ = select.select([fd], [], [], 0.1)
        if fd in r:
            try:
                d = os.read(fd, 4096)
                if not d: return False
                out += d
            except OSError: return False
    return True
def alive():
    try:
        return os.waitpid(pid, os.WNOHANG)[0] == 0
    except ChildProcessError:
        return False
def drain(seconds=4):
    global out
    end = time.time() + seconds
    while time.time() < end:
        r, _, _ = select.select([fd], [], [], 0.15)
        if fd in r:
            try:
                d = os.read(fd, 4096)
                if not d: break
                out += d
            except OSError:
                try:
                    while True:
                        d = os.read(fd, 4096)
                        if not d: break
                        out += d
                except OSError:
                    pass
                break
        elif not alive():
            break
    if alive():
        try: os.write(fd, b'/exit\n')
        except OSError: pass
        pump(1.0)
    try: os.waitpid(pid, 0)
    except ChildProcessError: pass
    return out.decode('utf-8', 'replace').replace('\r', '')
time.sleep(1.0); pump(0.4)
os.write(fd, os.environ['SLASH'].encode() + b'\n')
txt = drain(4)
sys.stdout.write('R:stamp=%d reqiter=%d\n' % (
    ('missing Analyst stamp' in txt), ('requires --iter' in txt)))
PYEOF
}
res=$(pty_slash '/score onboarding-flight-control --iter 0')
stamp=$(sed -n 's/^R:stamp=\([01]\).*/\1/p' <<<"$res")
reqit=$(sed -n 's/^R:.*reqiter=\([01]\)$/\1/p' <<<"$res")
if [[ "$stamp" == 1 && "$reqit" == 0 ]]; then
  ok '/score <client> --iter <n> forwards --iter (reaches stamp refusal)'
else
  bad "/score <client> --iter <n> forwards --iter (stamp=$stamp requires_iter=$reqit — session dies on missing --iter)"
fi
res=$(pty_slash '/bench harness-evolution run --iter 7')
stamp=$(sed -n 's/^R:stamp=\([01]\).*/\1/p' <<<"$res")
reqit=$(sed -n 's/^R:.*reqiter=\([01]\)$/\1/p' <<<"$res")
if [[ "$stamp" == 1 && "$reqit" == 0 ]]; then
  ok '/bench <client> run --iter <n> forwards --iter (reaches stamp refusal)'
else
  bad "/bench <client> run --iter <n> forwards --iter (stamp=$stamp requires_iter=$reqit — session dies on missing --iter)"
fi

# ── 9. D5 — quoted slash argv without eval (real PTY) ────────────────────────
rm -f "$PWNED"
res=$(PWNED="$PWNED" CMD="$C" timeout 50 python3 - <<'PYEOF'
import os, pty, select, sys, time, tempfile
cli = os.environ['CMD']
env = dict(os.environ)
for k in ('NO_COLOR', 'CONSULT_NO_SPLASH'): env.pop(k, None)
env['CONSULT_STATE_ROOT'] = tempfile.mkdtemp()
pid, fd = pty.fork()
if pid == 0:
    os.execvpe(cli, [cli, 'chat'], env)
out = b''
def pump(seconds):
    global out
    end = time.time() + seconds
    while time.time() < end:
        r, _, _ = select.select([fd], [], [], 0.1)
        if fd in r:
            try:
                d = os.read(fd, 4096)
                if not d: return False
                out += d
            except OSError: return False
    return True
time.sleep(1.0); pump(0.4)
os.write(fd, b'/provider "codex"\n'); pump(1.0)
os.write(fd, ('/provider x;touch %s\n' % os.environ['PWNED']).encode()); pump(1.0)
os.write(fd, b'/exit\n'); pump(1.0)
try: os.waitpid(pid, 0)
except ChildProcessError: pass
txt = out.decode('utf-8', 'replace').replace('\r', '')
sys.stdout.write('PQUOTE:ok=%d\n' % ('provider \u2192 codex' in txt))
sys.stdout.write('PINJ:file=%d\n' % os.path.exists(os.environ['PWNED']))
PYEOF
)
qok=$(sed -n 's/^PQUOTE:ok=\([01]\)$/\1/p' <<<"$res")
if [[ "$qok" == 1 ]]; then
  ok 'quoted slash argv parsed as one value (/provider "codex" → codex)'
else
  bad 'quoted slash argv parsed as one value (/provider "codex" mangles quotes)'
fi
if grep -q '^PINJ:file=1$' <<<"$res" || [[ -e "$PWNED" ]]; then
  bad 'slash line with embedded ;$(...) is inert (nothing executed)'
else
  ok 'slash line with embedded ;$(...) is inert (nothing executed)'
fi

# ── 10. machine-readable boundary: existing --json surfaces parse ────────────
json_ok=1
for spec in "agents --json" "card list --json" "style show --json" "pool list --json" "project-memory show onboarding-flight-control --json" "escalation onboarding-flight-control status"; do
  if jq -e . >/dev/null 2>&1 <<<"$(timeout 30 "$C" $spec 2>/dev/null)"; then :; else json_ok=0; bad "JSON parses: $spec"; fi
done
[[ $json_ok == 1 ]] && ok 'existing machine-readable surfaces emit valid JSON'

# ── 11. D6b — frontend boundary: status --json engagement list ───────────────
if sj=$(timeout 30 "$C" status --json 2>/dev/null | jq -e . 2>/dev/null); then
  clients=$(jq -r '.engagements[]?.client' <<<"$sj" | sort | tr '\n' ' ')
  if grep -q 'onboarding-flight-control' <<<"$clients" && grep -q 'harness-evolution' <<<"$clients"; then
    ok 'status --json lists engagements (incl. onboarding-flight-control, harness-evolution)'
  else
    bad "status --json engagement list missing clients (got: ${clients:-none})"
  fi
else
  bad 'status --json emits a parseable engagement list (got prose or exit != 0)'
fi

# ── 12. D4 — stale onboarding score syntax ───────────────────────────────────
onb=$(timeout 60 "$C" onboarding --yes 2>&1 || true)
if grep -q 'score <client> --iter' <<<"$onb"; then
  ok 'onboarding next-step uses current score syntax (--iter)'
else
  bad 'onboarding next-step uses current score syntax (prints stale "score <client>")'
fi

# ── 13. D7 — honest bench/run on summary-shaped scores (no raw jq, no exit 5)
for spec in "bench harness-evolution" "run harness-evolution 7"; do
  out=$(timeout 30 "$C" $spec 2>&1); rc=$?
  if [[ $rc -ne 5 ]] && ! grep -q 'jq: error' <<<"$out"; then
    ok "$spec handles summary-shaped scores honestly (rc=$rc)"
  else
    bad "$spec handles summary-shaped scores honestly (rc=$rc, raw jq traceback)"
  fi
done

# ── 14. CLI argv safety: multi-word round-trip, empty rejected ───────────────
CONSULT_STYLE_DIR="$(mktemp -d "${TMPDIR:-/tmp}/cli-parity-style.XXXXXX")"
export CONSULT_STYLE_DIR
if "$C" style init >/dev/null 2>&1 && "$C" style append taste "alpha beta gamma" >/dev/null 2>&1; then
  got=$("$C" style show --json 2>/dev/null | jq -r '.taste[]' | grep -c '^alpha beta gamma$')
  [[ "$got" -ge 1 ]] && ok 'multi-word argv round-trips byte-identical' || bad 'multi-word argv round-trips byte-identical'
  if "$C" style append never "" >/dev/null 2>&1; then bad 'empty argv rejected'; else ok 'empty argv rejected'; fi
else
  bad 'isolated style init+append works'
fi

# ── 15. non-TTY/redirected and NO_COLOR: no ANSI outside a color TTY ─────────
ansi=0
"$C" help | grep -q "$(printf '\033')" && ansi=1
"$C" splash 2>/dev/null | grep -q "$(printf '\033')" && ansi=1
[[ $ansi == 0 ]] && ok 'redirected output carries no ANSI' || bad 'redirected output carries no ANSI'
pty_esc() { # $1=NO_COLOR value or '-' to unset → escape count
  local val="$1"
  NOCOLOR_OPT="$val" CMD="$C" timeout 50 python3 - <<'PYEOF'
import os, pty, select, sys, time, tempfile
cli = os.environ['CMD']
env = dict(os.environ)
for k in ('NO_COLOR', 'CONSULT_NO_SPLASH'): env.pop(k, None)
env['CONSULT_STATE_ROOT'] = tempfile.mkdtemp(); env['TERM'] = 'xterm-256color'
if os.environ['NOCOLOR_OPT'] != '-': env['NO_COLOR'] = os.environ['NOCOLOR_OPT']
pid, fd = pty.fork()
if pid == 0:
    os.execvpe(cli, [cli, 'help'], env)
out = b''
while True:
    r, _, _ = select.select([fd], [], [], 0.2)
    if fd in r:
        try:
            d = os.read(fd, 4096)
            if not d: break
            out += d
        except OSError: break
    try:
        if os.waitpid(pid, os.WNOHANG)[0]: break
    except ChildProcessError: break
sys.stdout.write(str(out.count(b'\x1b')))
PYEOF
}
pty_color=$(pty_esc -)
pty_nocolor=$(pty_esc 1)
if [[ "$pty_color" =~ ^[0-9]+$ && "$pty_color" -gt 0 ]]; then ok 'color TTY emits ANSI'; else bad "color TTY emits ANSI (got '$pty_color')"; fi
if [[ "$pty_nocolor" =~ ^[0-9]+$ && "$pty_nocolor" == 0 ]]; then ok 'NO_COLOR=1 suppresses ANSI on TTY'; else bad "NO_COLOR=1 suppresses ANSI on TTY (got '$pty_nocolor')"; fi

# ── 16. exit-code honesty: unknown command and usage errors are non-zero ─────
if "$C" not-a-command >/dev/null 2>&1; then bad 'unknown command exits non-zero'; else ok 'unknown command exits non-zero'; fi
if "$C" open >/dev/null 2>&1; then bad 'usage error exits non-zero (open)'; else ok 'usage error exits non-zero (open)'; fi
if "$C" run-loop >/dev/null 2>&1; then bad 'usage error exits non-zero (run-loop)'; else ok 'usage error exits non-zero (run-loop)'; fi

printf '\n  %s\n' "$([ $fail == 0 ] && echo 'cli-interface parity v3: PASS' || echo 'cli-interface parity v3: FAIL (frozen-baseline defects expected at iter 1)')"
exit $fail
