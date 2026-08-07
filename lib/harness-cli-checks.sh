#!/usr/bin/env bash
# harness-cli-checks.sh — deterministic check runner for contract harness-cli-v1.
#
# Usage:  bash lib/harness-cli-checks.sh [iter-dir]
#
# Scores the Product Consulting Harness CLI itself (bin/productteam + lib/ + docs +
# tests) against the 49 frozen check ids in
# state/engagements/harness-cli/checks/CHECK-CATALOG.md. Writes
# <iter-dir>/checks.json and exits 0 only when every check passed.
#
# Env:
#   CONSULT_SKIP_LIVE=1     Record the 5 LIVE checks as fail/skipped and mark
#                           the run kind=partial. Fast loops only — a partial
#                           run can never converge (contract §Convergence).
#   CONSULT_CHECKS_PROBE=1  Self-test mode: emit all 49 ids as deliberate
#                           failures and exit non-zero, to prove the JSON
#                           writer and exit code are honest. Used by the
#                           harness-cli-checks-runner check. Runs no checks.
#
# This runner is deliberately NOT called from tests/consult-smoke.sh: smoke
# must stay instant and provider-free (MEMORY.md; tests/consult-smoke.sh:48).
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONSULT="$ROOT/bin/productteam"
ENG="$ROOT/state/engagements/harness-cli"
CONTRACT_JSON="$ENG/contract.json"
CLAIM_MAP="$ENG/checks/claim-map.json"
PROJ_A="$ENG/tmp-projects/proj-a"
PROJ_B="$ENG/tmp-projects/proj-b"
SELF="$ROOT/lib/harness-cli-checks.sh"

ITER_DIR="${1:-$ENG/runs/.latest}"
mkdir -p "$ITER_DIR"
OUT="$ITER_DIR/checks.json"
EVID="$ITER_DIR/evidence"
mkdir -p "$EVID" "$EVID/skills"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

RESULTS="$TMP/results.tsv"
: > "$RESULTS"

if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  B=$'\e[1m' D=$'\e[2m' R=$'\e[0m'
else
  B='' D='' R=''
fi

# ── recording ────────────────────────────────────────────────────────
record() { # $1=id $2=pass|fail $3=skipped(0|1) $4=detail
  local id="$1" status="$2" skipped="$3" detail="$4"
  detail=$(printf '%s' "$detail" | tr '\t\n' '  ' | sed -E 's/  +/ /g')
  printf '%s\t%s\t%s\t%s\n' "$id" "$status" "$skipped" "$detail" >> "$RESULTS"
  local mark='FAIL'
  [[ "$status" == pass ]] && mark='pass'
  [[ "$skipped" == 1 ]] && mark='skip'
  printf '  %-4s %-34s %s%s%s\n' "$mark" "$id" "$D" "${detail:0:78}" "$R"
}

# ── writer (shared by probe mode and the real run) ───────────────────
write_json() { # $1=kind
  python3 - "$RESULTS" "$OUT" "$CONTRACT_JSON" "$1" <<'PY'
import json, sys, datetime

results_path, out_path, contract_path, kind = sys.argv[1:5]

checks = {}
with open(results_path) as f:
    for line in f:
        p = line.rstrip("\n").split("\t", 3)
        if len(p) < 3:
            continue
        cid, status, skipped = p[0], p[1], p[2] == "1"
        entry = {"status": status, "detail": p[3] if len(p) > 3 else ""}
        if skipped:
            entry["skipped"] = True
        checks[cid] = entry

contract = json.load(open(contract_path))
dims = contract["dimensions"]
spec = contract["checks"]

expected = {cid for d in dims for cid in spec[d]["ids"]}
missing = sorted(expected - set(checks))
extra = sorted(set(checks) - expected)


def band(n, passed, gates_ok):
    """Normative band table from contract.json / BENCHMARK-CONTRACT.md."""
    if passed == n:
        return 9.5
    if gates_ok and n - passed == 1:
        return 8.0
    if gates_ok and passed / n >= 0.6:
        return 7.0
    if gates_ok:
        return 5.5
    if passed >= 2:
        return 4.0
    return 2.0


dimensions = {}
for d in dims:
    ids = spec[d]["ids"]
    gates = spec[d]["gates"]
    ok = [i for i in ids if checks.get(i, {}).get("status") == "pass"]
    gates_ok = all(checks.get(g, {}).get("status") == "pass" for g in gates)
    dimensions[d] = {
        "passed": len(ok),
        "total": len(ids),
        "gates": gates,
        "gates_ok": gates_ok,
        "failed_ids": [i for i in ids if i not in ok],
        "score": band(len(ids), len(ok), gates_ok),
    }

passed = sum(1 for c in checks.values() if c["status"] == "pass")
skipped = sum(1 for c in checks.values() if c.get("skipped"))
failed = len(checks) - passed
overall = round(sum(v["score"] for v in dimensions.values()) / len(dimensions), 1)

payload = {
    "contract": contract["contract"],
    "suite": "harness-cli",
    "runner": "lib/harness-cli-checks.sh",
    "ts": datetime.datetime.now().astimezone().isoformat(timespec="seconds"),
    "kind": kind,
    "live_executed": skipped == 0,
    "live_checks": contract.get("live_checks", []),
    "checks": checks,
    "passed": passed,
    "failed": failed,
    "skipped": skipped,
    "skip_note": (
        "Skipped LIVE checks are recorded status=fail with skipped=true, per the "
        "frozen runner contract in checks/CHECK-CATALOG.md. A run with any skip "
        "is kind=partial and cannot converge."
    ),
    "id_coverage": {"expected": len(expected), "recorded": len(checks),
                    "missing": missing, "unexpected": extra},
    "dimensions": dimensions,
    "overall": overall,
    "validation": "real-commands",
}
with open(out_path, "w") as f:
    json.dump(payload, f, indent=2)
    f.write("\n")

print(f"\n  {passed} passed · {failed} failed ({skipped} skipped) · "
      f"overall {overall} · kind={kind}")
if missing:
    print(f"  MISSING IDS ({len(missing)}): {', '.join(missing)}")
if extra:
    print(f"  UNEXPECTED IDS ({len(extra)}): {', '.join(extra)}")
print(f"  → {out_path}")
sys.exit(0 if (failed == 0 and not missing and not extra) else 1)
PY
}

all_ids() {
  jq -r '.dimensions[] as $d | .checks[$d].ids[]' "$CONTRACT_JSON"
}

# ── probe mode: prove the writer + exit code are honest, run nothing ──
if [[ "${CONSULT_CHECKS_PROBE:-}" == 1 ]]; then
  printf '\n  %sharness-cli-checks — PROBE mode (deliberate failures)%s\n\n' "$B" "$R"
  while read -r id; do
    [[ -n "$id" ]] && record "$id" fail 0 'probe: deliberate failure (exit-code honesty self-test)'
  done < <(all_ids)
  write_json probe
  exit $?
fi

LIVE_IDS=$(jq -r '.live_checks[]' "$CONTRACT_JSON")
SKIP_LIVE="${CONSULT_SKIP_LIVE:-0}"

is_live() { grep -qxF "$1" <<<"$LIVE_IDS"; }

# ── shared helpers ───────────────────────────────────────────────────
strip_ansi() { sed -E $'s/\x1b\\[[0-9;?]*[a-zA-Z]//g'; }

esc_count() { # $1=file → number of ANSI CSI sequences
  local n; n=$(grep -c $'\e\\[' "$1" 2>/dev/null); printf '%s' "${n:-0}"
}

DOCS_SET=("$ROOT/README.md" "$ROOT/ARCHITECTURE.md" "$ROOT/AGENTS.md"
          "$ROOT/JUDGMENT.md" "$ROOT/CONSTITUTION.md")
while IFS= read -r f; do DOCS_SET+=("$f"); done < <(find "$ROOT/docs" -name '*.md' 2>/dev/null | sort)

# CLI_SURFACE — what a user actually drives. This runner is excluded: it is
# engagement measurement scaffold (BENCHMARK-CONTRACT.md §Baseline guard), not
# CLI surface, and scanning it would make every source scan match its own
# check patterns. SCRIPTS keeps the runner, because it must parse and must not
# introduce a dependency.
CLI_SURFACE=("$CONSULT")
SCRIPTS=("$CONSULT")
for f in "$ROOT"/lib/*.sh; do
  [[ -f "$f" ]] || continue
  SCRIPTS+=("$f")
  [[ "$f" == "$SELF" ]] && continue
  CLI_SURFACE+=("$f")
done
for f in "$ROOT"/tests/*.sh; do [[ -f "$f" ]] && SCRIPTS+=("$f"); done
SELF_EXEMPT="lib/$(basename "$SELF") exempt from CLI-surface scans (measurement scaffold)"

in_docs() { grep -qF -- "$1" "${DOCS_SET[@]}" 2>/dev/null; }

help_out() { NO_COLOR=1 "$CONSULT" help 2>/dev/null | strip_ansi; }

help_tokens() {
  help_out | sed -nE 's/^[[:space:]]*productteam[[:space:]]+([a-z][a-z0-9-]*).*/\1/p' | sort -u
}

dispatch_tokens() {
  awk '/^main\(\) \{/{m=1; next} m && /^\}/{exit} m' "$CONSULT" \
    | sed -nE 's/^[[:space:]]{4}([a-z0-9|_-]+)\).*/\1/p' \
    | tr '|' '\n' | grep -vE '^(-h|--help)$' | sort -u
}

readme_tokens() {
  sed -nE 's@.*bin/productteam[[:space:]]+([a-z][a-z0-9-]*).*@\1@p' "$ROOT/README.md" | sort -u
}

# Known coding-agent name lexicon. Used to find *declared agent lists* in
# source, both for catalog sizing and for detecting a second hard-coded list.
AGENT_LEXICON='agent|cursor-agent|cursor|claude|codex|opencode|gemini|aider|goose|cline|continue|copilot|crush|amp|droid|devin|plandex|mentat|gptme|kilo|roo|windsurf|zed|qwen|ollama|sgpt|warp|factory|sweep|smol'

agent_list_lines() { # files… → "file:line:count:names"
  python3 - "$AGENT_LEXICON" "$@" <<'PY'
import re, sys
lex = set(sys.argv[1].split("|"))
word = re.compile(r"[A-Za-z][A-Za-z0-9-]*")
for path in sys.argv[2:]:
    try:
        lines = open(path, encoding="utf-8", errors="replace").read().splitlines()
    except OSError:
        continue
    for n, line in enumerate(lines, 1):
        names = []
        for w in word.findall(line):
            if w in lex and w not in names:
                names.append(w)
        if len(names) >= 3:
            print(f"{path}:{n}:{len(names)}:{','.join(names)}")
PY
}

# Splash frame analysis. Node glyph set is documented here so the renderer has
# a fixed target; a renderer may also declare SPLASH_NODE_GLYPH / CONSULT_SPLASH_NODE.
NODE_GLYPHS='▣▢◫⊞⊟⊡⌗⎕▤▥▦▧⬓⬒◰◱◲◳▞▚'
EDGE_GLYPHS='─│╱╲┼·'

splash_stats() { # $1=file → "frames=N nodes=N edges=N"
  python3 - "$1" "$NODE_GLYPHS" "$EDGE_GLYPHS" <<'PY'
import re, sys
raw = open(sys.argv[1], encoding="utf-8", errors="replace").read()
nodes, edges = set(sys.argv[2]), set(sys.argv[3])
ascii_nodes = re.findall(r"\[[#o*+]\]|\([#o*+]\)", raw)
# Frames are separated by a screen clear, a form feed, or an explicit marker.
parts = re.split(r"\x1b\[2J|\x1b\[H\x1b\[J|\f|^-{2,}\s*frame\b.*$",
                 raw, flags=re.IGNORECASE | re.MULTILINE)
plain = re.sub(r"\x1b\[[0-9;?]*[a-zA-Z]", "", raw)
frames = [p for p in parts if p.strip()]
print("frames=%d nodes=%d edges=%d" % (
    len(frames),
    sum(plain.count(g) for g in nodes) + len(ascii_nodes),
    sum(plain.count(g) for g in edges),
))
PY
}

stat_of() { sed -nE "s/.*\\b$2=([0-9]+).*/\\1/p" <<<"$1"; }

# Cited-path extraction: which paths named in an artifact exist under a repo.
cited_paths() { # $1=artifact $2=repo → prints existing repo-relative paths
  python3 - "$1" "$2" <<'PY'
import os, re, sys
art, repo = sys.argv[1], os.path.abspath(sys.argv[2])
text = open(art, encoding="utf-8", errors="replace").read()
cands = set(re.findall(r"[A-Za-z0-9_./-]+\.[A-Za-z0-9]{1,6}", text))
cands |= set(re.findall(r"[A-Za-z0-9_-]+/[A-Za-z0-9_./-]+", text))
found = set()
for c in cands:
    c = c.strip("./")
    if not c:
        continue
    rel = c[len(os.path.basename(repo)) + 1:] if c.startswith(os.path.basename(repo) + "/") else c
    for probe in {c, rel, c.split(os.path.basename(repo) + "/")[-1]}:
        p = os.path.join(repo, probe)
        if os.path.isfile(p) and os.path.abspath(p).startswith(repo + os.sep):
            found.add(os.path.relpath(p, repo))
for p in sorted(found):
    print(p)
PY
}

# Terms present in one project's GUIDANCE.md and in neither the other
# project's guidance nor the skill template source. Derived, never declared,
# so a template cannot accidentally satisfy it.
unique_guidance_terms() { # $1=own guidance $2=other guidance
  python3 - "$1" "$2" "$ROOT/lib/run-skill.sh" <<'PY'
import re, sys
def toks(p):
    try:
        return set(re.findall(r"[a-z][a-z-]{5,}", open(p, encoding="utf-8", errors="replace").read().lower()))
    except OSError:
        return set()
own, other, tmpl = toks(sys.argv[1]), toks(sys.argv[2]), toks(sys.argv[3])
for t in sorted(own - other - tmpl):
    print(t)
PY
}

jaccard() { # $1 $2 files → similarity, 3 decimals
  python3 - "$1" "$2" <<'PY'
import re, sys
def toks(p):
    return set(re.findall(r"[A-Za-z][A-Za-z0-9_-]{2,}", open(p, encoding="utf-8", errors="replace").read().lower()))
a, b = toks(sys.argv[1]), toks(sys.argv[2])
print("0.000" if not (a | b) else "%.3f" % (len(a & b) / len(a | b)))
PY
}

names_runtime() { # $1=artifact → 0 if it names the runtime binary that produced it
  grep -qiE '^[[:space:]]*[*_`]*(runtime|provider)[*_`]*[[:space:]]*[:=]' "$1" 2>/dev/null
}

# Seams the catalog requires to be observable. Each is discovered from source,
# never assumed, so the check reports honestly when it does not exist yet.
state_root_var() {
  local v
  for v in CONSULT_STATE_ROOT CONSULT_HOME CONSULT_STATE_DIR; do
    grep -qF "$v" "${CLI_SURFACE[@]}" 2>/dev/null && { printf '%s' "$v"; return 0; }
  done
  return 1
}

noninteractive_form() { # prints "env:NAME" or "flag:--name"
  local v f
  for v in CONSULT_NONINTERACTIVE CONSULT_YES CONSULT_ASSUME_YES CONSULT_NO_INPUT; do
    grep -qF "$v" "$CONSULT" 2>/dev/null && { printf 'env:%s' "$v"; return 0; }
  done
  for f in --non-interactive --yes --no-input; do
    grep -qF -- "$f" "$CONSULT" 2>/dev/null && { printf 'flag:%s' "$f"; return 0; }
  done
  return 1
}

splash_optout() {
  local v f
  for v in CONSULT_NO_SPLASH CONSULT_SPLASH; do
    grep -qF "$v" "${CLI_SURFACE[@]}" 2>/dev/null && { printf 'env:%s' "$v"; return 0; }
  done
  for f in --no-splash --quiet; do
    grep -qF -- "$f" "$CONSULT" 2>/dev/null && { printf 'flag:%s' "$f"; return 0; }
  done
  return 1
}

# Run the CLI with an isolated state root when the seam exists, so cold-start
# probes never touch the invoking user's real state.
isolated() { # $1=state dir, rest = productteam args
  local dir="$1"; shift
  mkdir -p "$dir"
  local var; var=$(state_root_var 2>/dev/null || true)
  if [[ -n "$var" ]]; then
    env "$var=$dir" NO_COLOR=1 timeout 60 "$CONSULT" "$@" </dev/null 2>&1
  else
    env NO_COLOR=1 timeout 60 "$CONSULT" "$@" </dev/null 2>&1
  fi
}

# ── smoke runs once; three checks consume the result ──────────────────
# CONSULT_SMOKE_SKIP_CLIENT=1 because the client sub-check builds the sibling
# product repo, which leaves a tsconfig.tsbuildinfo behind. Modifying a sibling
# repo is critical failure #6, so the scoring run must not trigger it.
# lib/harness-checks.sh:56 sets the same flag for the same reason.
SMOKE_OUT="$TMP/smoke.txt"
NO_COLOR=1 CONSULT_SMOKE_SKIP_CLIENT=1 timeout 300 bash "$ROOT/tests/consult-smoke.sh" \
  >"$SMOKE_OUT" 2>&1 </dev/null
SMOKE_RC=$?
cp "$SMOKE_OUT" "$EVID/smoke.txt"

# ═════════════════════════════════════════════════════════════════════
# 1. visual-cli-clarity
# ═════════════════════════════════════════════════════════════════════

theme_hits() { grep -nH $'\\\\e\\[' "${CLI_SURFACE[@]}" 2>/dev/null; }

chk_cli_theme_single_source() {
  local hits defs nondefs files
  hits=$(theme_hits)
  [[ -n "$hits" ]] || { echo "no ANSI escape literal found anywhere — nothing to centralise"; return 0; }
  # A definition line assigns escapes to variables (the theme block). Anything
  # else means an escape is baked into a printf format string.
  defs=$(grep -E "^[^:]+:[0-9]+:[[:space:]]*([A-Za-z_]+=\\\$'\\\\e\[[^']*'[[:space:]]*)+\$" <<<"$hits")
  nondefs=$(comm -23 <(sort <<<"$hits") <(sort <<<"$defs"))
  files=$(cut -d: -f1 <<<"$defs" | sort -u)
  local nfiles; nfiles=$(grep -c . <<<"$files")
  if [[ -n "$nondefs" ]]; then
    echo "escape literal outside a theme definition: $(tr '\n' ' ' <<<"$nondefs" | cut -c1-160)"
    return 1
  fi
  if (( nfiles != 1 )); then
    echo "theme defined in $nfiles files (need exactly 1): $(tr '\n' ' ' <<<"$files" | sed "s@$ROOT/@@g")"
    return 1
  fi
  echo "single theme source: $(sed "s@$ROOT/@@" <<<"$files")"
}

chk_cli_monochrome_chrome() {
  local missing=''
  _need() { # $1=label $2=file $3..=anchors
    local label="$1" file="$2"; shift 2
    local a
    for a in "$@"; do
      grep -qF -- "$a" "$file" || missing+="$label:'$a' "
    done
  }
  NO_COLOR=1 timeout 60 "$CONSULT" status </dev/null 2>&1 | strip_ansi > "$TMP/m-status"
  NO_COLOR=1 timeout 60 "$CONSULT" help   </dev/null 2>&1 | strip_ansi > "$TMP/m-help"
  NO_COLOR=1 timeout 60 "$CONSULT" org    </dev/null 2>&1 | strip_ansi > "$TMP/m-org"
  NO_COLOR=1 timeout 60 "$CONSULT" bench harness-cli </dev/null 2>&1 | strip_ansi > "$TMP/m-bench"
  _need status "$TMP/m-status" 'Product Consulting Harness'
  _need help   "$TMP/m-help"   'Commands' 'productteam help'
  _need org    "$TMP/m-org"    'Loop' 'Autonomy'
  _need bench  "$TMP/m-bench"  'Benchmark' 'Contract'
  # Monochrome primitives must exist, so structure never depends on hue.
  grep -qE "=\\\$'\\\\e\[(1|2|0)m'" "$CONSULT" || missing+='theme:bold/dim/reset '
  [[ -z "$missing" ]] || { echo "structure lost without color — $missing"; return 1; }
  echo 'all headings survive color stripping in status/help/org/bench; bold+dim+reset defined'
}

chk_cli_accent_budget() {
  local codes n
  codes=$(theme_hits | grep -oE '\\e\[(3[0-7]|9[0-7])m' | sort -u | tr '\n' ' ')
  n=$(wc -w <<<"$codes")
  (( n <= 2 )) || { echo "$n distinct accent hues (budget 2): $codes"; return 1; }
  echo "${n} accent hue(s): ${codes:-none}"
}

chk_cli_no_color_clean() {
  local c bad='' n f state="$TMP/nc-state"
  for c in status help org memory runtime agents bench report smoke splash onboarding; do
    f="$TMP/nc-$c"
    if [[ "$c" == smoke ]]; then
      cp "$SMOKE_OUT" "$f"
    else
      # Isolated state root when the seam exists: splash/onboarding must not
      # touch the caller's real state just to be measured.
      isolated "$state" "$c" > "$f" 2>&1
    fi
    n=$(esc_count "$f")
    (( n == 0 )) || bad+="$c=$n "
  done
  [[ -z "$bad" ]] || { echo "NO_COLOR=1 still emitted escapes: $bad"; return 1; }
  echo 'zero escape sequences under NO_COLOR=1 for all 11 top-level commands'
}

chk_cli_plain_pipe_safe() {
  local f="$TMP/hc-pipe.txt" n longest
  timeout 60 "$CONSULT" status </dev/null > "$f" 2>&1
  n=$(esc_count "$f")
  longest=$(strip_ansi < "$f" | awk '{ if (length($0) > m) m = length($0) } END { print m+0 }')
  (( n == 0 )) || { echo "piped status emitted $n escape sequences"; return 1; }
  (( longest <= 100 )) || { echo "longest piped line ${longest} cols (max 100)"; return 1; }
  echo "piped status: 0 escapes, longest line ${longest} cols"
}

# ═════════════════════════════════════════════════════════════════════
# 2. splash-animation
# ═════════════════════════════════════════════════════════════════════

SPLASH_SRC=()
for f in "${CLI_SURFACE[@]}"; do
  grep -qE 'splash|SPLASH' "$f" 2>/dev/null && SPLASH_SRC+=("$f")
done

chk_splash_command_exists() {
  help_out | grep -qE 'productteam[[:space:]]+(splash|login)' \
    || { echo 'no splash/login command in productteam help'; return 1; }
  local cmd; cmd=$(help_out | sed -nE 's/^[[:space:]]*productteam[[:space:]]+(splash|login).*/\1/p' | head -1)
  isolated "$TMP/sp-exists" "$cmd" > "$TMP/splash-exists" 2>&1
  local rc=$?
  (( rc == 0 )) || { echo "productteam $cmd exited $rc"; return 1; }
  echo "productteam $cmd listed in help and exits 0"
}

chk_splash_graph_nodes_edges() {
  (( ${#SPLASH_SRC[@]} )) || { echo 'no splash renderer source found in the CLI surface'; return 1; }
  isolated "$TMP/sp-graph" splash > "$TMP/splash-frame" 2>&1 || true
  [[ -s "$TMP/splash-frame" ]] || { echo 'splash produced no output'; return 1; }
  cp "$TMP/splash-frame" "$EVID/splash-frame.txt"
  local s nodes edges
  s=$(splash_stats "$TMP/splash-frame"); nodes=$(stat_of "$s" nodes); edges=$(stat_of "$s" edges)
  local has_nodes=0 has_edges=0
  grep -qE '(NODES|nodes)[[:space:]]*=\(' "${SPLASH_SRC[@]}" && has_nodes=1
  grep -qE '(EDGES|edges)[[:space:]]*=\(' "${SPLASH_SRC[@]}" && has_edges=1
  local why=''
  (( nodes >= 6 )) || why+="only $nodes node glyphs (need 6; set: $NODE_GLYPHS or [#]/(o)) "
  (( edges >= 5 )) || why+="only $edges edge glyphs (need 5; set: $EDGE_GLYPHS) "
  (( has_nodes )) || why+='renderer declares no nodes list '
  (( has_edges )) || why+='renderer declares no edges list '
  [[ -z "$why" ]] || { echo "$why"; return 1; }
  echo "frame has $nodes node glyphs, $edges edge glyphs; renderer declares nodes+edges lists"
}

chk_splash_frames_animate() {
  (( ${#SPLASH_SRC[@]} )) || { echo 'no splash renderer source found in the CLI surface'; return 1; }
  local best=0 f
  for probe in 'env:CONSULT_SPLASH_FRAMES=all' 'env:CONSULT_SPLASH_DUMP=1' 'flag:--frames'; do
    f="$TMP/splash-frames-${probe//[^a-zA-Z0-9]/_}"
    if [[ "$probe" == env:* ]]; then
      env "${probe#env:}" NO_COLOR=1 timeout 30 "$CONSULT" splash </dev/null > "$f" 2>&1
    else
      NO_COLOR=1 timeout 30 "$CONSULT" splash "${probe#flag:}" </dev/null > "$f" 2>&1
    fi
    local n; n=$(stat_of "$(splash_stats "$f")" frames)
    (( ${n:-0} > best )) && best=$n
  done
  local has_count=0 has_delay=0
  grep -qE '(SPLASH_FRAME_COUNT|SPLASH_FRAMES|FRAME_COUNT)=' "${SPLASH_SRC[@]}" && has_count=1
  grep -qE '(SPLASH_FRAME_DELAY|SPLASH_DELAY|FRAME_DELAY)=' "${SPLASH_SRC[@]}" && has_delay=1
  local why=''
  (( best >= 3 )) || why+="max $best distinct frames from any frame-dump probe (need 3) "
  (( has_count )) || why+='no named frame-count constant '
  (( has_delay )) || why+='no named inter-frame-delay constant '
  [[ -z "$why" ]] || { echo "$why"; return 1; }
  echo "$best frames dumped; frame-count and delay are named constants"
}

chk_splash_bounded_noninteractive() {
  local why='' optout
  local t0 t1 ms
  t0=$(date +%s%N)
  isolated "$TMP/sp-bound" splash > "$TMP/splash-piped" 2>&1
  local rc=$?
  t1=$(date +%s%N)
  ms=$(( (t1 - t0) / 1000000 ))
  (( rc == 0 )) || why+="splash exited $rc "
  (( ms <= 2000 )) || why+="took ${ms}ms (budget 2000ms) "
  local frames; frames=$(stat_of "$(splash_stats "$TMP/splash-piped")" frames)
  (( ${frames:-0} == 1 )) || why+="piped run produced ${frames:-0} frames (need exactly 1 static frame) "
  if optout=$(splash_optout); then
    local f="$TMP/splash-optout"
    if [[ "$optout" == env:* ]]; then
      env "${optout#env:}=1" NO_COLOR=1 timeout 30 "$CONSULT" splash </dev/null > "$f" 2>&1
    else
      NO_COLOR=1 timeout 30 "$CONSULT" splash "${optout#flag:}" </dev/null > "$f" 2>&1
    fi
    local n; n=$(stat_of "$(splash_stats "$f")" nodes)
    (( ${n:-0} == 0 )) || why+="opt-out ${optout} still rendered $n node glyphs "
    in_docs "${optout#*:}" || why+="opt-out ${optout#*:} not documented in README/ARCHITECTURE/docs "
  else
    why+='no splash opt-out flag or CONSULT_* env var found '
  fi
  # Never reads stdin: stdin is already /dev/null above; also assert no `read`
  # in the renderer path.
  if (( ${#SPLASH_SRC[@]} )) && grep -qE '^[[:space:]]*read[[:space:]]' "${SPLASH_SRC[@]}" 2>/dev/null; then
    why+='renderer source calls read (may block on stdin) '
  fi
  [[ -z "$why" ]] || { echo "$why"; return 1; }
  echo "piped splash: ${ms}ms, 1 static frame, opt-out ${optout} documented"
}

chk_splash_first_run_hook() {
  local var; var=$(state_root_var) \
    || { echo 'no state-root override (CONSULT_STATE_ROOT|CONSULT_HOME|CONSULT_STATE_DIR) — first-run cannot be observed'; return 1; }
  local dir="$TMP/first-run"; mkdir -p "$dir"
  env "$var=$dir" NO_COLOR=1 timeout 60 "$CONSULT" </dev/null > "$TMP/fr1" 2>&1
  env "$var=$dir" NO_COLOR=1 timeout 60 "$CONSULT" </dev/null > "$TMP/fr2" 2>&1
  local n1 n2 marker
  n1=$(stat_of "$(splash_stats "$TMP/fr1")" nodes)
  n2=$(stat_of "$(splash_stats "$TMP/fr2")" nodes)
  marker=$(find "$dir" -type f 2>/dev/null | head -5 | tr '\n' ' ')
  local why=''
  (( ${n1:-0} >= 2 )) || why+="first run rendered no splash frame (nodes=${n1:-0}) "
  (( ${n2:-0} == 0 )) || why+="splash replayed on the second run (nodes=${n2:-0}) "
  [[ -n "$marker" ]] || why+="no first-run marker written under \$$var "
  [[ -z "$why" ]] || { echo "$why"; return 1; }
  echo "first run renders, second does not; marker under \$$var: $marker"
}

# ═════════════════════════════════════════════════════════════════════
# 3. onboarding-ease
# ═════════════════════════════════════════════════════════════════════

onboarding_cmd() {
  help_out | sed -nE 's/^[[:space:]]*productteam[[:space:]]+(onboarding|onboard|init).*/\1/p' | head -1
}

# Cold-start transcript is produced once and reused by three checks.
ONBOARD_TRANSCRIPT="$TMP/onboard.txt"
ONBOARD_RC=99
onboard_run() { # $1=state dir → transcript on stdout
  local dir="$1" cmd form
  cmd=$(onboarding_cmd); [[ -n "$cmd" ]] || return 127
  form=$(noninteractive_form 2>/dev/null || true)
  local var; var=$(state_root_var 2>/dev/null || true)
  local -a envs=(NO_COLOR=1)
  [[ -n "$var" ]] && envs+=("$var=$dir")
  [[ "$form" == env:* ]] && envs+=("${form#env:}=1")
  local -a args=("$cmd")
  [[ "$form" == flag:* ]] && args+=("${form#flag:}")
  mkdir -p "$dir"
  env "${envs[@]}" timeout 120 "$CONSULT" "${args[@]}" </dev/null
}

chk_onboarding_command_exists() {
  local cmd; cmd=$(onboarding_cmd)
  [[ -n "$cmd" ]] || { echo "no onboarding|onboard|init command in productteam help"; return 1; }
  grep -qE "productteam[[:space:]]+$cmd\b" "$ROOT/README.md" \
    || { echo "productteam $cmd is in help but not in README.md"; return 1; }
  echo "productteam $cmd present in help and README.md"
}

chk_onboarding_cold_start() {
  local why='' var form
  var=$(state_root_var 2>/dev/null || true)
  form=$(noninteractive_form 2>/dev/null || true)
  [[ -n "$var" ]]  || why+='no documented state-root override seam '
  [[ -n "$form" ]] || why+='no documented non-interactive form (flag or CONSULT_* env) '
  [[ -n "$var" ]]  && { in_docs "$var"  || why+="$var not documented in README/ARCHITECTURE/docs "; }
  [[ -n "$form" ]] && { in_docs "${form#*:}" || why+="${form#*:} not documented in README/ARCHITECTURE/docs "; }
  onboard_run "$TMP/ob-cold" > "$ONBOARD_TRANSCRIPT" 2>"$TMP/ob-cold.err"
  ONBOARD_RC=$?
  cat "$TMP/ob-cold.err" >> "$ONBOARD_TRANSCRIPT" 2>/dev/null
  cp "$ONBOARD_TRANSCRIPT" "$EVID/onboarding-cold.txt"
  (( ONBOARD_RC == 0 )) || why+="cold run exited $ONBOARD_RC "
  grep -qE 'Traceback|line [0-9]+: ' "$TMP/ob-cold.err" 2>/dev/null \
    && why+='stderr contains a traceback or shell line error '
  [[ -z "$why" ]] || { echo "$why"; return 1; }
  echo "cold non-interactive run exit 0 with \$$var isolated; transcript in evidence/onboarding-cold.txt"
}

chk_onboarding_steps_explicit() {
  [[ -s "$ONBOARD_TRANSCRIPT" ]] || { echo 'no onboarding transcript (cold start did not run)'; return 1; }
  local n; n=$(grep -cE '^[[:space:]]*[1-5][.)]' "$ONBOARD_TRANSCRIPT")
  (( n >= 1 && n <= 5 )) || { echo "$n numbered steps (need 1-5)"; return 1; }
  local missing='' topic
  while IFS='|' read -r label pat; do
    grep -qiE "$pat" "$ONBOARD_TRANSCRIPT" || missing+="$label "
  done <<'TOPICS'
detect-agents|detect|agents? (found|present)|runtimes?
choose-provider|provider|CONSULT_PROVIDER
first-engagement|engagement|client
first-score|score|bench|checks
next-command|productteam [a-z]
TOPICS
  [[ -z "$missing" ]] || { echo "$n steps but topics not covered: $missing"; return 1; }
  echo "$n numbered steps covering agents, provider, engagement, score, next command"
}

chk_onboarding_idempotent() {
  local cmd; cmd=$(onboarding_cmd)
  [[ -n "$cmd" ]] || { echo 'no onboarding command to re-run'; return 1; }
  local dir="$TMP/ob-idem"
  onboard_run "$dir" > "$TMP/idem1" 2>&1; local rc1=$?
  ( cd "$dir" && find . -type f -exec sha256sum {} + 2>/dev/null | sort ) > "$TMP/snap1"
  onboard_run "$dir" > "$TMP/idem2" 2>&1; local rc2=$?
  ( cd "$dir" && find . -type f -exec sha256sum {} + 2>/dev/null | sort ) > "$TMP/snap2"
  local why=''
  (( rc1 == 0 )) || why+="first run exited $rc1 "
  (( rc2 == 0 )) || why+="second run exited $rc2 "
  diff -q "$TMP/snap1" "$TMP/snap2" >/dev/null 2>&1 \
    || why+="state root changed on re-run: $(diff "$TMP/snap1" "$TMP/snap2" | head -3 | tr '\n' ' ') "
  grep -qiE 'already|configured|up to date|nothing to do' "$TMP/idem2" \
    || why+='second run does not report already-configured '
  [[ -z "$why" ]] || { echo "$why"; return 1; }
  echo 'second run reports already-configured; state root byte-identical'
}

chk_onboarding_next_action() {
  [[ -s "$ONBOARD_TRANSCRIPT" ]] || { echo 'no onboarding transcript (cold start did not run)'; return 1; }
  local last
  last=$(grep -oE 'productteam [a-z][a-z0-9-]*( [A-Za-z0-9._/-]+)?' "$ONBOARD_TRANSCRIPT" | tail -1)
  [[ -n "$last" ]] || { echo 'final output names no concrete productteam command'; return 1; }
  # shellcheck disable=SC2086
  local out rc
  out=$(NO_COLOR=1 timeout 120 "$CONSULT" ${last#productteam } </dev/null 2>&1); rc=$?
  if (( rc == 0 )); then
    echo "next action '$last' exits 0"
    return 0
  fi
  if grep -qiE 'error:|usage:|missing|no |not found|unknown|refus' <<<"$out"; then
    echo "next action '$last' exits $rc with a named refusal"
    return 0
  fi
  echo "next action '$last' exited $rc with no named refusal: $(head -1 <<<"$out")"
  return 1
}

# ═════════════════════════════════════════════════════════════════════
# 4. agent-detection
# ═════════════════════════════════════════════════════════════════════

detect_cmd() {
  local c
  for c in agents runtime; do
    help_out | grep -qE "productteam[[:space:]]+$c\b" && { printf '%s' "$c"; return 0; }
  done
  return 1
}

# The declared agent catalog: the largest agent-name list in lib/provider.sh.
catalog_entries() {
  local best; best=$(agent_list_lines "$ROOT/lib/provider.sh" | sort -t: -k3 -rn | head -1)
  [[ -n "$best" ]] || return 1
  cut -d: -f4- <<<"$best" | tr ',' '\n' | grep -v '^$' | sort -u
}

detect_rows() { # $1=stripped output file → row count
  grep -cE '(^|[[:space:]])(●|○|✓|✗)[[:space:]]|\b(found|missing)\b' "$1" 2>/dev/null || true
}

chk_detect_command_exists() {
  local c; c=$(detect_cmd) || { echo 'neither productteam agents nor productteam runtime is listed in help'; return 1; }
  local f="$TMP/detect-$c"
  NO_COLOR=1 timeout 60 "$CONSULT" "$c" </dev/null 2>&1 | strip_ansi > "$f"
  local rc=${PIPESTATUS[0]}
  cp "$f" "$EVID/agent-detection.txt"
  (( rc == 0 )) || { echo "productteam $c exited $rc"; return 1; }
  local rows size
  rows=$(detect_rows "$f")
  size=$(catalog_entries | grep -c . || true)
  (( size > 0 )) || { echo 'no agent catalog list found in lib/provider.sh'; return 1; }
  (( rows == size )) || { echo "productteam $c printed $rows rows for a $size-entry catalog"; return 1; }
  local missing='' n
  while read -r n; do grep -qF "$n" "$f" || missing+="$n "; done < <(catalog_entries)
  [[ -z "$missing" ]] || { echo "catalog entries absent from output: $missing"; return 1; }
  echo "productteam $c: $rows rows, one per catalog entry ($size), exit 0"
}

chk_detect_covers_known_agents() {
  local lists n size
  lists=$(agent_list_lines "${CLI_SURFACE[@]}")
  n=$(grep -c . <<<"$lists" || true)
  size=$(catalog_entries | grep -c . || true)
  local why=''
  (( size >= 10 )) || why+="catalog names $size agents (need 10) "
  (( n == 1 )) || why+="$n hard-coded agent lists (need exactly 1): $(sed "s@$ROOT/@@g" <<<"$lists" | cut -d: -f1,2 | tr '\n' ' ') "
  [[ -z "$why" ]] || { echo "$why"; return 1; }
  echo "$size-agent catalog declared in exactly one place"
}

chk_detect_beyond_path() {
  local c; c=$(detect_cmd) || { echo 'no detection command'; return 1; }
  # Find a real catalog agent that lives outside the stripped PATH, so the
  # probe is meaningful rather than vacuous.
  local off='' name p
  while read -r name; do
    p=$(command -v "$name" 2>/dev/null) || continue
    [[ "$p" == /usr/bin/* || "$p" == /bin/* ]] && continue
    off="$name@$p"; break
  done < <(catalog_entries)
  [[ -n "$off" ]] || { echo 'no catalog agent installed outside /usr/bin:/bin — cannot test off-PATH scanning on this device'; return 1; }
  local f="$TMP/detect-strippath"
  env -u CONSULT_PROVIDER PATH=/usr/bin:/bin NO_COLOR=1 timeout 60 "$CONSULT" "$c" </dev/null 2>&1 | strip_ansi > "$f"
  local hit
  hit=$(grep -E "^.*${off%%@*}.*(/[A-Za-z0-9._/-]+)" "$f" | grep -vE 'missing|not on PATH' | head -1)
  [[ -n "$hit" ]] || { echo "with PATH=/usr/bin:/bin, ${off%%@*} (installed at ${off#*@}) is not reported found with its path"; return 1; }
  echo "off-PATH agent reported with absolute path: $(tr -s ' ' <<<"$hit" | cut -c1-90)"
}

chk_detect_no_false_positive() {
  local c; c=$(detect_cmd) || { echo 'no detection command'; return 1; }
  local shadow="$TMP/shadow-path"; mkdir -p "$shadow"
  local victim; victim=$(catalog_entries | head -1)
  [[ -n "$victim" ]] || { echo 'no catalog entries'; return 1; }
  # A non-executable file named after a catalog agent must not count as found.
  printf '#!/bin/sh\necho nope\n' > "$shadow/$victim"; chmod 000 "$shadow/$victim"
  local f="$TMP/detect-falsepos"
  env -u CONSULT_PROVIDER PATH="$shadow:/usr/bin:/bin" NO_COLOR=1 timeout 60 "$CONSULT" "$c" </dev/null 2>&1 | strip_ansi > "$f"
  local row
  row=$(grep -E "(^|[^a-z])$victim([^a-z]|$)" "$f" | head -1)
  local why=''
  if grep -qE "$shadow" "$f"; then why+="reported the non-executable shadow file as found: $(tr -s ' ' <<<"$row") "; fi
  grep -qE "$victim.*(missing|not on PATH)" "$f" \
    || why+="$victim not reported missing when only a non-executable file exists: '$(tr -s ' ' <<<"$row")' "
  # A fabricated name must never be reported found.
  local fake='zzz-not-an-agent'
  grep -qE "$fake.*found" "$f" && why+='fabricated agent name reported found '
  [[ -z "$why" ]] || { echo "$why"; return 1; }
  echo "non-executable $victim reported missing; no fabricated agent reported found"
}

chk_detect_machine_readable() {
  local c; c=$(detect_cmd) || { echo 'no detection command'; return 1; }
  local f="$TMP/detect.json"
  NO_COLOR=1 timeout 60 "$CONSULT" "$c" --json </dev/null > "$f" 2>"$TMP/detect.json.err"
  local rc=$?
  (( rc == 0 )) || { echo "productteam $c --json exited $rc: $(head -1 "$TMP/detect.json.err")"; return 1; }
  jq -e 'type == "array" and length > 0' "$f" >/dev/null 2>&1 \
    || { echo "productteam $c --json is not a non-empty JSON array"; return 1; }
  jq -e 'all(.[]; has("name") and has("status") and has("path"))' "$f" >/dev/null 2>&1 \
    || { echo 'JSON objects lack name/status/path'; return 1; }
  cp "$f" "$EVID/agents.json"
  echo "productteam $c --json: $(jq -r 'length' "$f") objects with name/status/path"
}

chk_detect_versions() {
  local c; c=$(detect_cmd) || { echo 'no detection command'; return 1; }
  local f="$TMP/detect-ver" t0 t1 ms
  t0=$(date +%s%N)
  NO_COLOR=1 timeout 30 "$CONSULT" "$c" </dev/null 2>&1 | strip_ansi > "$f"
  t1=$(date +%s%N); ms=$(( (t1 - t0) / 1000000 ))
  local why=''
  (( ms <= 10000 )) || why+="detection took ${ms}ms (budget 10000ms) "
  local bad=0 row
  while IFS= read -r row; do
    grep -qE '[0-9]+\.[0-9]+|unknown' <<<"$row" || { bad=$((bad+1)); }
  done < <(grep -E '(●|✓).*|\bfound\b' "$f" | grep -vE 'missing|not on PATH')
  (( bad == 0 )) || why+="$bad found row(s) show neither a version nor 'unknown' "
  [[ -z "$why" ]] || { echo "$why"; return 1; }
  echo "every found row carries a version or 'unknown'; detection ${ms}ms"
}

# ═════════════════════════════════════════════════════════════════════
# 5. feature-reachability
# ═════════════════════════════════════════════════════════════════════

chk_help_lists_every_command() {
  help_tokens > "$TMP/help-tokens"
  dispatch_tokens > "$TMP/dispatch-tokens"
  local only_help only_disp
  only_help=$(comm -23 "$TMP/help-tokens" "$TMP/dispatch-tokens" | tr '\n' ' ')
  only_disp=$(comm -13 "$TMP/help-tokens" "$TMP/dispatch-tokens" | tr '\n' ' ')
  [[ -z "$only_help$only_disp" ]] \
    || { echo "help/dispatch drift — phantom in help: ${only_help:-none}; orphan in dispatch: ${only_disp:-none}"; return 1; }
  echo "help and dispatch agree on $(wc -l < "$TMP/dispatch-tokens" | tr -d ' ') commands"
}

safe_args() {
  case "$1" in
    judge|score|checks|bench|report) printf 'harness-cli' ;;
    run)                             printf 'harness-cli 0' ;;
    gh)                              printf 'preflight %s' "$ROOT" ;;
    skill)                           printf 'critique %s %s' "$PROJ_A" "$TMP/skill-safe" ;;
    harness-checks)                  printf '%s' "$TMP/hc-safe" ;;
    *)                               printf '' ;;
  esac
}

chk_every_command_exits_zero() {
  local table="$EVID/command-exit-table.txt" cmd args out rc bad=''
  : > "$table"
  # `productteam harness-checks` regenerates artifacts under a hard-coded closed
  # iteration path (lib/harness-checks.sh:98-109) regardless of the iter dir it
  # is given. Exercising the command is required here; rewriting a closed
  # iteration's evidence is not, so it is snapshotted and put back.
  local frozen_evidence="$ROOT/state/harness-evolution/runs/iter-3/evidence"
  local snapshot="$TMP/iter3-evidence"
  [[ -d "$frozen_evidence" ]] && cp -a "$frozen_evidence" "$snapshot"
  while read -r cmd; do
    [[ -n "$cmd" ]] || continue
    args=$(safe_args "$cmd")
    if [[ "$cmd" == smoke ]]; then
      out=$(cat "$SMOKE_OUT"); rc=$SMOKE_RC
    else
      # shellcheck disable=SC2086
      out=$(isolated "$TMP/cmd-state" "$cmd" $args 2>&1); rc=$?
    fi
    printf '%-16s exit=%-3s %s\n' "$cmd ${args:0:0}" "$rc" "$(head -1 <<<"$out" | tr -s ' ' | cut -c1-70)" >> "$table"
    if grep -qE 'unbound variable|command not found|Traceback \(most recent call last\)|Syntax error' <<<"$out"; then
      bad+="$cmd(crash) "
    elif (( rc >= 124 )); then
      bad+="$cmd(exit=$rc timeout/signal) "
    elif (( rc != 0 )) && ! grep -qiE 'error:|usage:|missing|no |not found|unknown|refus|cannot' <<<"$out"; then
      bad+="$cmd(exit=$rc, unnamed failure) "
    fi
  done < <(dispatch_tokens)
  if [[ -d "$snapshot" ]]; then
    rm -rf "$frozen_evidence" && cp -a "$snapshot" "$frozen_evidence"
  fi
  [[ -z "$bad" ]] || { echo "$bad(table: evidence/command-exit-table.txt)"; return 1; }
  echo "all $(grep -c . "$table") dispatch commands exit 0 or refuse by name (evidence/command-exit-table.txt)"
}

chk_core_features_reachable() {
  local missing_help='' missing_readme='' t
  for t in status judge score checks bench report memory org gh skill smoke onboarding splash help; do
    help_out | grep -qE "productteam[[:space:]]+$t\b" || missing_help+="$t "
    grep -qE "productteam[[:space:]]+$t\b" "$ROOT/README.md" || missing_readme+="$t "
  done
  # agents/runtime counts as one feature satisfied by either name.
  if ! help_out | grep -qE 'productteam[[:space:]]+(agents|runtime)\b'; then missing_help+='agents|runtime '; fi
  if ! grep -qE "productteam[[:space:]]+(agents|runtime)\b" "$ROOT/README.md"; then missing_readme+='agents|runtime '; fi
  [[ -z "$missing_help$missing_readme" ]] \
    || { echo "absent from help: ${missing_help:-none}; absent from README: ${missing_readme:-none}"; return 1; }
  echo 'all 15 core features present in both productteam help and README.md'
}

chk_unknown_command_honest() {
  local out rc
  out=$(NO_COLOR=1 timeout 30 "$CONSULT" notacommand </dev/null 2>&1); rc=$?
  (( rc != 0 )) || { echo 'unknown command exited 0'; return 1; }
  grep -qiE 'help|did you mean' <<<"$out" || { echo "message suggests nothing: $(head -1 <<<"$out")"; return 1; }
  echo "unknown command exits $rc and points at productteam help"
}

chk_no_hidden_env_requirements() {
  local names undoc='' n
  names=$(grep -ohE '\$\{?CONSULT_[A-Z_]+' "${CLI_SURFACE[@]}" 2>/dev/null \
            | sed -E 's/^\$\{?//' | sort -u)
  [[ -n "$names" ]] || { echo 'no CONSULT_* env vars read'; return 0; }
  while read -r n; do
    [[ -n "$n" ]] || continue
    in_docs "$n" && continue
    # A documented prefix glob (e.g. CONSULT_PR_*) covers its members.
    local prefix covered=0 p
    prefix="$n"
    while [[ "$prefix" == *_* ]]; do
      prefix="${prefix%_*}"
      in_docs "${prefix}_*" && { covered=1; break; }
    done
    (( covered )) || undoc+="$n "
  done <<<"$names"
  [[ -z "$undoc" ]] || { echo "env vars read but undocumented in README/ARCHITECTURE/docs: $undoc"; return 1; }
  echo "all $(grep -c . <<<"$names") CONSULT_* env vars documented"
}

# ═════════════════════════════════════════════════════════════════════
# 6. skills-llm-reality
# ═════════════════════════════════════════════════════════════════════

RUNTIME_BIN=''
chk_provider_live_answer() {
  local art="$EVID/skills/provider-live.txt" reply rc
  RUNTIME_BIN=$(bash -c "source '$ROOT/lib/provider.sh'; runtime_default" 2>/dev/null || true)
  [[ -n "$RUNTIME_BIN" ]] || { echo 'runtime_default resolved no runtime — install agent|claude|codex|opencode|gemini or set CONSULT_PROVIDER'; return 1; }
  reply=$(timeout 300 bash -c "source '$ROOT/lib/provider.sh'; provider_ask 'Reply with exactly: CONSULT-LIVE-OK'" </dev/null 2>&1)
  rc=$?
  {
    printf 'runtime: %s\n' "$RUNTIME_BIN"
    printf 'runtime-path: %s\n' "$(command -v "$RUNTIME_BIN" 2>/dev/null || printf '%s' "$RUNTIME_BIN")"
    printf 'ts: %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf 'prompt: Reply with exactly: CONSULT-LIVE-OK\n'
    printf 'exit: %s\n--- reply ---\n%s\n' "$rc" "$reply"
  } > "$art"
  grep -q 'CONSULT-LIVE-OK' <<<"$reply" \
    || { echo "provider_ask via $RUNTIME_BIN exited $rc without the sentinel: $(head -1 <<<"$reply")"; return 1; }
  echo "live reply from $RUNTIME_BIN contains CONSULT-LIVE-OK (evidence/skills/provider-live.txt)"
}

proj_field() { sed -nE "s/^$2:[[:space:]]*(.+)$/\1/p" "$1/GUIDANCE.md" | head -1; }

proj_sources() { # $1=project dir → source basenames (code + manifests, not docs)
  find "$1" -type f \
    \( -name '*.js' -o -name '*.mjs' -o -name '*.ts' -o -name '*.py' -o -name '*.go' \
       -o -name '*.rs' -o -name '*.rb' -o -name '*.java' -o -name '*.sh' \
       -o -name 'package.json' -o -name 'pyproject.toml' -o -name 'Cargo.toml' -o -name 'go.mod' \) \
    2>/dev/null -printf '%f\n' | sort -u
}

chk_tmp_projects_two_varying() {
  local why='' p
  for p in "$PROJ_A" "$PROJ_B"; do
    [[ -d "$p" ]] || { why+="missing $(basename "$p") "; continue; }
    [[ -f "$p/GUIDANCE.md" ]] || why+="missing $(basename "$p")/GUIDANCE.md "
  done
  [[ -z "$why" ]] || { echo "$why"; return 1; }
  local la lb da db
  la=$(proj_field "$PROJ_A" Language); lb=$(proj_field "$PROJ_B" Language)
  da=$(proj_field "$PROJ_A" Domain);   db=$(proj_field "$PROJ_B" Domain)
  [[ -n "$la" && -n "$lb" ]] || why+='a GUIDANCE.md lacks a Language: field '
  [[ -n "$da" && -n "$db" ]] || why+='a GUIDANCE.md lacks a Domain: field '
  [[ "$la" != "$lb" ]] || why+="same Language ($la) "
  [[ "$da" != "$db" ]] || why+="same Domain ($da) "
  local shared
  shared=$(comm -12 <(proj_sources "$PROJ_A") <(proj_sources "$PROJ_B") | tr '\n' ' ')
  [[ -z "$shared" ]] || why+="shared source filenames: $shared "
  local ua ub
  ua=$(unique_guidance_terms "$PROJ_A/GUIDANCE.md" "$PROJ_B/GUIDANCE.md" | grep -c . || true)
  ub=$(unique_guidance_terms "$PROJ_B/GUIDANCE.md" "$PROJ_A/GUIDANCE.md" | grep -c . || true)
  (( ua >= 5 && ub >= 5 )) || why+="guidance files barely differ (unique terms a=$ua b=$ub) "
  [[ -z "$why" ]] || { echo "$why"; return 1; }
  echo "proj-a[$la/$da] vs proj-b[$lb/$db]; disjoint source filenames; $ua/$ub unique guidance terms"
}

chk_skill_uses_provider_seam() {
  local f="$ROOT/lib/run-skill.sh"
  [[ -f "$f" ]] || { echo "missing $f"; return 1; }
  local n; n=$(grep -c 'provider_ask' "$f" || true)
  (( n >= 1 )) || { echo 'lib/run-skill.sh never calls provider_ask — skills emit templates, not model output'; return 1; }
  # Every skill branch must go through the seam, and none may write an
  # artifact when the provider fails.
  local missing
  missing=$(python3 - "$f" <<'PY'
import re, sys
src = open(sys.argv[1], encoding="utf-8", errors="replace").read()
skills = ["critique", "benchmark", "design-sprint"]
missing = []
for s in skills:
    m = re.search(rf"^\s*{re.escape(s)}\)(.*?)(^\s*;;)", src, re.S | re.M)
    body = m.group(1) if m else ""
    if "provider_ask" not in body:
        missing.append(s)
print(" ".join(missing))
PY
)
  [[ -z "$missing" ]] || { echo "skill branch(es) without provider_ask: $missing"; return 1; }
  # An artifact written on the failure path would let a skill answer without a model.
  grep -nE 'provider_ask.*\|\|[[:space:]]*(true|:)' "$f" >/dev/null 2>&1 \
    && { echo 'provider_ask failure is swallowed (|| true) — a skill could emit an artifact with no reply'; return 1; }
  echo "all three skill branches call provider_ask ($n call sites); no swallowed provider failure"
}

# Live skill artifacts. Produced once each, reused across checks.
run_skill_live() { # $1=skill $2=project dir $3=label → artifact path on stdout
  local skill="$1" proj="$2" label="$3"
  local out="$EVID/skills/$label"
  rm -rf "$out"; mkdir -p "$out"
  NO_COLOR=1 timeout 600 "$CONSULT" skill "$skill" "$proj" "$out" </dev/null > "$out/.stdout" 2> "$out/.stderr"
  local art
  art=$(find "$out" -maxdepth 1 -type f -name '*.md' ! -name 'SKILL.md' 2>/dev/null | head -1)
  [[ -n "$art" ]] || art=$(find "$out" -maxdepth 1 -type f -name '*.json' 2>/dev/null | head -1)
  printf '%s' "$art"
}

skill_artifact_checks() { # $1=artifact $2=project dir $3=other project dir
  local art="$1" proj="$2" other="$3" why=''
  [[ -n "$art" && -f "$art" ]] && return_paths=1 || { printf 'no artifact produced'; return 1; }
  local n_own n_cross
  n_own=$(cited_paths "$art" "$proj" | grep -c . || true)
  n_cross=$(cited_paths "$art" "$other" | grep -vxF -f <(cited_paths "$art" "$proj") 2>/dev/null | grep -c . || true)
  (( n_own >= 2 )) || why+="cites $n_own real paths from $(basename "$proj") (need 2) "
  local term hit=''
  while read -r term; do
    [[ -n "$term" ]] || continue
    grep -qiF -- "$term" "$art" && { hit="$term"; break; }
  done < <(unique_guidance_terms "$proj/GUIDANCE.md" "$other/GUIDANCE.md")
  [[ -n "$hit" ]] || why+="no term unique to $(basename "$proj")/GUIDANCE.md appears in the artifact "
  names_runtime "$art" || why+='artifact names no runtime binary (reality rule) '
  if [[ -n "$why" ]]; then printf '%s' "$why"; return 1; fi
  printf '%s cites %s own paths, guidance term "%s", runtime named' "$(basename "$art")" "$n_own" "$hit"
}

ART_CRIT_A=''; ART_CRIT_B=''; ART_BENCH_B=''; ART_SPRINT=''

chk_skill_critique_live_project_a() {
  ART_CRIT_A=$(run_skill_live critique "$PROJ_A" critique-proj-a)
  local msg; msg=$(skill_artifact_checks "$ART_CRIT_A" "$PROJ_A" "$PROJ_B"); local rc=$?
  echo "$msg"; return $rc
}

chk_skill_benchmark_live_project_b() {
  ART_BENCH_B=$(run_skill_live benchmark "$PROJ_B" benchmark-proj-b)
  [[ -n "$ART_BENCH_B" && -f "$ART_BENCH_B" ]] || { echo 'no benchmark artifact produced'; return 1; }
  local why='' dims
  # The generic starter list is the template's, not this project's.
  dims=$(grep -oiE '^[[:space:]]*[0-9]+\.[[:space:]]*[a-z-]+' "$ART_BENCH_B" | sed -E 's/.*[[:space:]]//' | sort -u | tr '\n' ' ')
  local generic='correctness developer-experience documentation product-clarity simplicity usability '
  [[ "$dims" == "$generic" ]] && why+='dimension list is the generic six-item starter, unchanged '
  local n_own
  n_own=$(cited_paths "$ART_BENCH_B" "$PROJ_B" | grep -c . || true)
  (( n_own >= 2 )) || why+="cites $n_own real proj-b paths (need 2) "
  names_runtime "$ART_BENCH_B" || why+='artifact names no runtime binary (reality rule) '
  local term hit=''
  while read -r term; do
    [[ -n "$term" ]] || continue
    grep -qiF -- "$term" "$ART_BENCH_B" && { hit="$term"; break; }
  done < <(unique_guidance_terms "$PROJ_B/GUIDANCE.md" "$PROJ_A/GUIDANCE.md")
  [[ -n "$hit" ]] || why+='no proj-b-specific guidance term in the contract '
  [[ -z "$why" ]] || { echo "$why"; return 1; }
  echo "proj-b contract: dimensions [$dims], $n_own real paths, term \"$hit\", runtime named"
}

chk_skill_design_sprint_live() {
  ART_SPRINT=$(run_skill_live design-sprint "$PROJ_A" design-sprint-proj-a)
  local msg; msg=$(skill_artifact_checks "$ART_SPRINT" "$PROJ_A" "$PROJ_B"); local rc=$?
  echo "$msg"; return $rc
}

chk_skills_outputs_project_specific() {
  [[ -n "$ART_CRIT_A" && -f "$ART_CRIT_A" ]] || ART_CRIT_A=$(run_skill_live critique "$PROJ_A" critique-proj-a)
  ART_CRIT_B=$(run_skill_live critique "$PROJ_B" critique-proj-b)
  [[ -n "$ART_CRIT_A" && -f "$ART_CRIT_A" && -n "$ART_CRIT_B" && -f "$ART_CRIT_B" ]] \
    || { echo 'critique did not produce an artifact for both projects'; return 1; }
  # The catalog's measure is Jaccard < 0.6 plus zero cross-project citations.
  # A template that interpolates each project's tree can clear this alone; that
  # loophole is closed by this dimension's gates (skill-uses-provider-seam,
  # no-mock-provider) and by the per-project artifact checks, which require a
  # named runtime and a derived guidance term. Kept literal on purpose.
  local j why='' xa xb
  j=$(jaccard "$ART_CRIT_A" "$ART_CRIT_B")
  awk -v v="$j" 'BEGIN{exit !(v < 0.6)}' || why+="token Jaccard similarity $j (need < 0.6) — shared boilerplate skeleton "
  xa=$(cited_paths "$ART_CRIT_A" "$PROJ_B" | grep -vxF -f <(cited_paths "$ART_CRIT_A" "$PROJ_A") 2>/dev/null | grep -c . || true)
  xb=$(cited_paths "$ART_CRIT_B" "$PROJ_A" | grep -vxF -f <(cited_paths "$ART_CRIT_B" "$PROJ_B") 2>/dev/null | grep -c . || true)
  (( xa == 0 && xb == 0 )) || why+="cross-project path citations a->b=$xa b->a=$xb "
  [[ -z "$why" ]] || { echo "$why"; return 1; }
  echo "same skill, two projects: Jaccard $j, zero cross-project path citations"
}

chk_no_mock_provider() {
  local hits filtered
  hits=$(grep -inE 'mock|fixture|canned|FAKE_PROVIDER|stub_reply' "${CLI_SURFACE[@]}" \
           "$ROOT"/tests/*.sh 2>/dev/null || true)
  # Comment lines and explicit prohibitions ("no mocks", "never mock") are not
  # provider-substitute code paths.
  filtered=$(grep -vE ':[0-9]+:[[:space:]]*#' <<<"$hits" \
             | grep -viE 'no mock|no api keys|not a mock|never mock|without mock|no Critic|fake/mocked validation' || true)
  [[ -z "$filtered" ]] || { echo "possible provider substitute: $(sed "s@$ROOT/@@g" <<<"$filtered" | head -2 | tr '\n' ' ' | cut -c1-160)"; return 1; }
  # The runner is exempt from the scan above, so close that loophole directly:
  # it may not redefine the seam nor point CONSULT_PROVIDER at a real binary.
  grep -qE '^[[:space:]]*(provider_ask|runtime_default|runtime_detect)[[:space:]]*\(\)' "$SELF" \
    && { echo 'the checks runner redefines the provider seam'; return 1; }
  local pp
  while read -r pp; do
    [[ -n "$pp" && -x "$pp" ]] && { echo "the checks runner points CONSULT_PROVIDER at an executable ($pp)"; return 1; }
  done < <(grep -ohE 'CONSULT_PROVIDER=[^ ")]+' "$SELF" | sed 's/^CONSULT_PROVIDER=//')
  local bad='' art
  while IFS= read -r art; do
    [[ -n "$art" ]] || continue
    names_runtime "$art" || bad+="$(basename "$(dirname "$art")")/$(basename "$art") "
  done < <(find "$EVID/skills" -type f \( -name '*.md' -o -name '*.txt' -o -name '*.json' \) ! -name 'SKILL.md' 2>/dev/null | sort)
  [[ -z "$bad" ]] || { echo "skill artifact(s) name no runtime binary: $bad"; return 1; }
  echo "no provider substitute in bin|lib|tests; every skill artifact names its runtime; $SELF_EXEMPT"
}

# ═════════════════════════════════════════════════════════════════════
# 7. documentation
# ═════════════════════════════════════════════════════════════════════

chk_readme_matches_cli() {
  help_tokens > "$TMP/help-tokens2"
  readme_tokens > "$TMP/readme-tokens"
  dispatch_tokens > "$TMP/dispatch-tokens2"
  local absent phantom
  absent=$(comm -23 "$TMP/help-tokens2" "$TMP/readme-tokens" | tr '\n' ' ')
  phantom=$(comm -23 "$TMP/readme-tokens" "$TMP/dispatch-tokens2" | tr '\n' ' ')
  [[ -z "$absent$phantom" ]] \
    || { echo "in help but not README: ${absent:-none}; in README but not dispatched: ${phantom:-none}"; return 1; }
  echo "README covers every help command; README claims no command that is not dispatched"
}

chk_readme_onboarding_section() {
  local sec
  sec=$(awk '/^#+[[:space:]]*(First run|Getting started|Quickstart)/{f=1; print; next} f && /^#+ /{exit} f' "$ROOT/README.md")
  [[ -n "$sec" ]] || { echo 'no First run|Getting started|Quickstart heading in README.md'; return 1; }
  local fenced missing='' t
  fenced=$(awk '/^```/{f=!f; next} f' <<<"$sec")
  for t in onboarding splash 'agents\|runtime'; do
    grep -qE "$t" <<<"$fenced" || missing+="$(tr -d '\\' <<<"$t") "
  done
  [[ -z "$missing" ]] || { echo "first-run section has no copy-pasteable command for: $missing"; return 1; }
  echo 'first-run section covers onboarding, splash and agent detection in fenced blocks'
}

chk_docs_cli_not_tui() {
  local product_hits eng_hits bad=''
  product_hits=$(grep -rinE '\bTUI\b' \
      "$ROOT/README.md" "$ROOT/ARCHITECTURE.md" "$ROOT/AGENTS.md" "$ROOT/JUDGMENT.md" \
      "$ROOT/CONSTITUTION.md" "$ROOT/docs" "$ROOT/skills" \
      "${CLI_SURFACE[@]}" "$ROOT"/tests/*.sh 2>/dev/null || true)
  [[ -z "$product_hits" ]] || { echo "TUI framing in the product path set: $(sed "s@$ROOT/@@g" <<<"$product_hits" | head -2 | tr '\n' ' ' | cut -c1-150)"; return 1; }
  # Inside the engagement dir a hit is allowed only when the line negates it.
  # The repo root path and git branch happen to end in "-tui"; a path or branch
  # token is not product framing, so those hits are exempted by name.
  eng_hits=$(grep -rinE '\bTUI\b' "$ENG" 2>/dev/null || true)
  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    grep -qiE 'not|no |mis-scope|out of scope' <<<"$line" && continue
    grep -qiE 'fix-new-user-tui|Fix/New-User-TUI' <<<"$line" && continue
    bad+="$(sed "s@$ROOT/@@" <<<"$line" | cut -c1-90) | "
  done <<<"$eng_hits"
  [[ -z "$bad" ]] || { echo "engagement lines mention TUI without negating it: $bad"; return 1; }
  echo "no TUI framing in the product path set; every engagement mention negates it; $SELF_EXEMPT"
}

chk_docs_no_stale_paths() {
  local docs=("$ROOT/README.md" "$ROOT/ARCHITECTURE.md" "$ROOT/AGENTS.md")
  while IFS= read -r f; do docs+=("$f"); done < <(find "$ROOT/docs" -name '*.md' 2>/dev/null | sort)
  local stale rc
  stale=$(python3 - "$ROOT" "${docs[@]}" <<'PY'
import os, re, subprocess, sys
root, docs = sys.argv[1], sys.argv[2:]
shape = re.compile(r"^[A-Za-z0-9_.][A-Za-z0-9_./*-]*$")
# A path named only to say it does not exist ("no nested `clients/` tree") is
# not a stale reference.
negation = re.compile(r"\b(no|not|never|without|deliberately|absence|absent)\b", re.I)

basenames = set()
for dirpath, dirnames, filenames in os.walk(root):
    dirnames[:] = [d for d in dirnames if d != ".git"]
    basenames.update(filenames)

bad = []
for d in docs:
    if not os.path.isfile(d):
        continue
    for line in open(d, encoding="utf-8", errors="replace"):
        if negation.search(line):
            continue
        for tok in re.findall(r"`([^`\n]+)`", line):
            tok = tok.strip()
            if not shape.match(tok) or tok.startswith("/"):
                continue
            if "*" in tok:
                base = tok.split("*")[0].rstrip("/")
                if not base or os.path.exists(os.path.join(root, base)):
                    continue
                bad.append(f"{os.path.relpath(d, root)}:`{tok}`")
                continue
            if "/" in tok:
                probe = tok.rstrip("/")
                # Trailing placeholder segments (iter-N, <client>, {id}) stand
                # for a value, so the documented prefix is what must resolve.
                placeholder = re.compile(r"^(iter-)?N$|^<.+>$|^\{.+\}$|^\.\.\.$")
                parts = probe.split("/")
                while parts and placeholder.match(parts[-1]):
                    parts.pop()
                probe = "/".join(parts)
                if probe and not os.path.exists(os.path.join(root, probe)):
                    bad.append(f"{os.path.relpath(d, root)}:`{tok}`")
            elif re.search(r"\.(md|sh|json|jsonl|ts|js|py|toml)$", tok):
                # A bare filename is a generic reference (e.g. `contract.json`
                # lives under each engagement); it resolves if it exists anywhere.
                if tok not in basenames:
                    bad.append(f"{os.path.relpath(d, root)}:`{tok}`")
print(" ".join(sorted(set(bad))))
PY
)
  rc=$?
  (( rc == 0 )) || { echo "path extractor failed: $(head -1 <<<"$stale")"; return 1; }
  [[ -z "$stale" ]] || { echo "unresolvable repo paths in docs: $stale"; return 1; }
  echo 'every backticked repo-relative path in README/ARCHITECTURE/AGENTS/docs resolves on disk'
}

chk_docs_skills_live() {
  local f="$ROOT/docs/skills.md"
  [[ -f "$f" ]] || { echo 'missing docs/skills.md'; return 1; }
  local why=''
  grep -qiE 'real (provider|model|agent|llm) call|real provider' "$f" || why+="does not state skills make real provider calls "
  grep -qiE 'no mocks|without mocks|never mocked' "$f" || why+='does not state there are no mocks '
  grep -qF 'tmp-projects' "$f" || why+='does not point at the tmp-project verification '
  [[ -z "$why" ]] || { echo "docs/skills.md $why"; return 1; }
  echo 'docs/skills.md states real provider calls, no mocks, and cites tmp-projects'
}

# ═════════════════════════════════════════════════════════════════════
# 8. developer-experience
# ═════════════════════════════════════════════════════════════════════

chk_smoke_green() {
  (( SMOKE_RC == 0 )) || { echo "tests/consult-smoke.sh exited $SMOKE_RC: $(grep -m2 'FAIL' "$SMOKE_OUT" | tr '\n' ' ')"; return 1; }
  echo "tests/consult-smoke.sh exit 0 ($(grep -c 'PASS' "$SMOKE_OUT" || true) checks, CONSULT_SMOKE_SKIP_CLIENT=1 so no sibling repo is built; evidence/smoke.txt)"
}

chk_harness_cli_checks_runner() {
  [[ -f "$SELF" ]] || { echo "missing lib/harness-cli-checks.sh"; return 1; }
  bash -n "$SELF" 2>"$TMP/self-parse" || { echo "does not parse: $(head -1 "$TMP/self-parse")"; return 1; }
  local d="$TMP/runner-probe"; mkdir -p "$d"
  CONSULT_CHECKS_PROBE=1 timeout 120 bash "$SELF" "$d" >"$TMP/probe.out" 2>&1
  local rc=$?
  (( rc != 0 )) || { echo 'deliberately failing probe exited 0 — runner does not fail honestly'; return 1; }
  [[ -f "$d/checks.json" ]] || { echo 'probe wrote no checks.json in the given iter dir'; return 1; }
  local n; n=$(jq -r '.checks | length' "$d/checks.json" 2>/dev/null || echo 0)
  (( n == 49 )) || { echo "checks.json holds $n ids, contract declares 49"; return 1; }
  jq -e '.contract == "harness-cli-v1"' "$d/checks.json" >/dev/null 2>&1 \
    || { echo 'checks.json does not name contract harness-cli-v1'; return 1; }
  echo "runner writes 49 ids + dimensions to <iter-dir>/checks.json; failing probe exits $rc"
}

chk_checks_dispatch_routes_engagement() {
  local out rc
  out=$(NO_COLOR=1 timeout 180 "$CONSULT" checks harness-cli </dev/null 2>&1 | strip_ansi); rc=$?
  printf '%s\n' "$out" > "$EVID/checks-dispatch.txt"
  local why=''
  grep -qF 'harness-cli-v1' <<<"$out" || why+='output never names contract harness-cli-v1 '
  grep -qE 'maya-intro-flow|ofc-v1' <<<"$out" && why+='output contains ofc-v1 check ids (wrong suite) '
  local score_out
  score_out=$(NO_COLOR=1 timeout 180 "$CONSULT" score harness-cli </dev/null 2>&1 | strip_ansi)
  grep -qF 'harness-cli-v1' <<<"$score_out" || why+='productteam score harness-cli does not reach this suite '
  [[ -z "$why" ]] || { echo "$why"; return 1; }
  echo 'productteam checks|score harness-cli both run the harness-cli-v1 suite'
}

chk_no_new_runtime_deps() {
  local report rc
  report=$(python3 - "$CONTRACT_JSON" "${SCRIPTS[@]}" <<'PY'
import json, re, shutil, sys

contract = json.load(open(sys.argv[1]))
allow = set(contract["dependency_allowlist"])

# The allowlist entry `bash` is read as "the shell environment": its builtins
# and keywords plus the POSIX/coreutils utilities every bash install ships.
# Anything outside that and the allowlist is a genuinely new dependency.
BUILTINS = set("""
: . [ alias bg bind break builtin caller case cd command compgen complete compopt
continue declare dirs disown do done echo elif else enable esac eval exec exit
export false fc fg fi for function getopts hash help history if in jobs kill let
local logout mapfile popd printf pushd pwd read readarray readonly return select
set shift shopt source suspend test then time times trap true type typeset ulimit
umask unalias unset until wait while
""".split())
COREUTILS = set("""
awk basename cat chmod chown cksum cmp comm cp csplit cut date dd df diff dirname
du env expand expr find fold grep head id join ln logname ls md5sum mkdir mkfifo
mktemp mv nl od paste patch pr printenv ps readlink realpath rm rmdir sed seq
sha1sum sha256sum sleep sort split stat stty tac tail tee timeout touch tr true
tsort tty uname unexpand uniq wc who xargs yes
""".split())
AGENTS = set("agent cursor cursor-agent claude codex opencode gemini".split())
# A client product's own toolchain is not a harness dependency, but it may only
# be invoked from the client-facing check/validation paths. Anywhere else (e.g.
# bin/productteam) it would be a real new dependency and is reported as such.
CLIENT_TOOLCHAIN = set("npm npx node yarn pnpm".split())
CLIENT_PATHS = ("lib/run-checks.sh", "lib/github.sh")

funcs, cmds = set(), {}
for path in sys.argv[2:]:
    src = open(path, encoding="utf-8", errors="replace").read().splitlines()
    for line in src:
        m = re.match(r"^\s*([A-Za-z_][A-Za-z0-9_]*)\s*\(\)\s*\{?", line)
        if m:
            funcs.add(m.group(1))

for path in sys.argv[2:]:
    lines = open(path, encoding="utf-8", errors="replace").read().splitlines()
    heredoc = None
    for line in lines:
        if heredoc is not None:
            if line.strip() == heredoc:
                heredoc = None
            continue
        h = re.search(r"<<-?\s*'?\"?([A-Za-z_][A-Za-z0-9_]*)'?\"?", line)
        if h:
            heredoc = h.group(1)
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        # Single-quoted spans are literal data (prose, patterns, lexicons), not
        # command positions. Double-quoted spans can still hold shell code, but
        # a `|` inside them is nearly always regex alternation, and arithmetic
        # `(( … ))` holds variables, not commands.
        stripped = re.sub(r"'[^']*'", " ", stripped)
        stripped = re.sub(r"\(\([^()]*\)\)", " ", stripped)
        stripped = re.sub(r'"[^"]*"',
                          lambda m: m.group(0).replace("|", " "), stripped)
        for seg in re.split(r"[;|&]{1,2}|\$\(|`|\bthen\b|\bdo\b|\belse\b|\{|\}|\(\(|\[\[", stripped):
            seg = seg.strip()
            seg = re.sub(r"^(?:[A-Za-z_][A-Za-z0-9_]*=(?:\"[^\"]*\"|'[^']*'|\S*)\s+)+", "", seg)
            seg = re.sub(r"^(?:!|\d?[<>]+\S+)\s*", "", seg)
            tok = seg.split()[0] if seg.split() else ""
            if re.fullmatch(r"[a-z][a-z0-9_.-]*", tok or ""):
                cmds.setdefault(tok, []).append(path)

# A runtime dependency has to be a real executable. A leftover token that
# resolves to nothing on PATH is tokenizer noise, not a dependency.
unknown, client = [], []
for t, paths in cmds.items():
    if t in BUILTINS or t in COREUTILS or t in allow or t in AGENTS or t in funcs:
        continue
    if not shutil.which(t):
        continue
    if t in CLIENT_TOOLCHAIN and all(p.endswith(CLIENT_PATHS) for p in paths):
        client.append(t)
    else:
        unknown.append(f"{t}({','.join(sorted({p.rsplit('/', 1)[-1] for p in paths}))})")
baseline = sorted(t for t in cmds if t in COREUTILS and t not in allow)
print("UNKNOWN=" + ",".join(sorted(unknown)))
print("BASELINE=" + ",".join(baseline))
print("CLIENT=" + ",".join(sorted(client)))
PY
)
  rc=$?
  (( rc == 0 )) && grep -q '^UNKNOWN=' <<<"$report" \
    || { echo "dependency extractor failed: $(head -2 <<<"$report" | tr '\n' ' ')"; return 1; }
  local unknown baseline client
  unknown=$(sed -n 's/^UNKNOWN=//p' <<<"$report")
  baseline=$(sed -n 's/^BASELINE=//p' <<<"$report")
  client=$(sed -n 's/^CLIENT=//p' <<<"$report")
  [[ -z "$unknown" ]] || { echo "non-allowlisted commands invoked: $unknown"; return 1; }
  echo "allowlist held; coreutils/POSIX baseline treated as bash (${baseline:-none}); client toolchain confined to run-checks/github (${client:-none})"
}

chk_errors_name_the_fix() {
  local bad='' out
  _probe() { # $1=label, rest=command
    local label="$1"; shift
    out=$("$@" </dev/null 2>&1)
    local cause=0 remedy=0
    grep -qiE 'unknown|missing|not found|no |refus|cannot|failed|invalid' <<<"$out" && cause=1
    grep -qE 'productteam [a-z]|install|Install|[Cc]reate|set CONSULT|CONSULT_[A-Z_]+|usage:|try:' <<<"$out" && remedy=1
    (( cause )) || bad+="$label(no cause) "
    (( remedy )) || bad+="$label(no remedy) "
  }
  _probe unknown-command env NO_COLOR=1 timeout 30 "$CONSULT" notacommand
  _probe missing-engagement env NO_COLOR=1 timeout 30 "$CONSULT" bench zzz-no-such-engagement
  _probe missing-provider env NO_COLOR=1 CONSULT_PROVIDER=/nonexistent/no-such-provider-bin timeout 30 "$CONSULT" runtime --check
  _probe merge-unauthorized env NO_COLOR=1 CONSULT_AUTHORIZE_MERGE="$TMP/no-such-auth" timeout 60 "$CONSULT" gh merge "$ROOT"
  [[ -z "$bad" ]] || { echo "refusals missing cause or remedy: $bad"; return 1; }
  echo 'all 4 failure paths name both a cause and a remedy'
}

chk_scripts_parse_clean() {
  local bad='' f
  for f in "${SCRIPTS[@]}"; do
    bash -n "$f" 2>"$TMP/parse.err" || bad+="$(basename "$f"): $(head -1 "$TMP/parse.err" | cut -c1-60) "
  done
  [[ -z "$bad" ]] || { echo "bash -n failures: $bad"; return 1; }
  local sc='shellcheck not installed (optional)'
  if command -v shellcheck >/dev/null 2>&1; then
    local out
    out=$(shellcheck -S error "${SCRIPTS[@]}" 2>&1)
    [[ -z "$out" ]] || { echo "shellcheck error-severity findings: $(head -2 <<<"$out" | tr '\n' ' ')"; return 1; }
    sc='shellcheck -S error clean'
  fi
  echo "bash -n clean over ${#SCRIPTS[@]} scripts; $sc"
}

# ═════════════════════════════════════════════════════════════════════
# 9. product-clarity
# ═════════════════════════════════════════════════════════════════════

chk_status_states_identity() {
  local head6
  head6=$(NO_COLOR=1 timeout 60 "$CONSULT" </dev/null 2>&1 | strip_ansi | grep -v '^[[:space:]]*$' | head -6)
  grep -qF 'Product Consulting Harness' <<<"$head6" \
    || { echo 'product name absent from the first 6 output lines'; return 1; }
  grep -qiE 'product judgment|judgment layer|product consulting|CLI-first' <<<"$head6" \
    || { echo "no identity phrase in the first 6 lines: $(tr '\n' ' ' <<<"$head6" | cut -c1-100)"; return 1; }
  echo "identity stated in the first 6 lines: $(tr -s ' \n' ' ' <<<"$head6" | cut -c1-90)"
}

chk_non_goals_visible() {
  local cli readme why=''
  cli=$( { help_out; NO_COLOR=1 timeout 60 "$CONSULT" org </dev/null 2>&1 | strip_ansi; } )
  readme=$(cat "$ROOT/README.md")
  local pat='non-goal|not a |is not |does not|deliberately not|no daemon|no database|no plugin|what it is not|does NOT exist'
  grep -qiE "$pat" <<<"$cli"    || why+='no explicit non-goals in productteam help or org '
  grep -qiE "$pat" <<<"$readme" || why+='no explicit non-goals in README.md '
  [[ -z "$why" ]] || { echo "$why"; return 1; }
  echo 'non-goals stated both in the CLI (help/org) and README.md'
}

chk_engagement_scope_explicit() {
  local f="$ENG/engagement.md" why=''
  [[ -f "$f" ]] || { echo "missing $f"; return 1; }
  grep -qiE 'in scope' "$f"     || why+='no in-scope section '
  grep -qiE 'out of scope' "$f" || why+='no out-of-scope section '
  grep -qF 'CLI' "$f"           || why+='does not name the CLI as the surface '
  grep -qiE 'sibling|JobOS|Job App' "$f" || why+='does not exclude sibling products '
  [[ -z "$why" ]] || { echo "engagement.md $why"; return 1; }
  echo 'engagement.md keeps in/out-of-scope, names the CLI, excludes sibling products'
}

chk_no_overclaim() {
  [[ -f "$CLAIM_MAP" ]] || { echo "missing $CLAIM_MAP"; return 1; }
  jq -e '.claims | type == "array" and length > 0' "$CLAIM_MAP" >/dev/null 2>&1 \
    || { echo 'claim map does not parse or has no claims'; return 1; }
  help_out > "$TMP/help-for-claims"
  python3 - "$CLAIM_MAP" "$RESULTS" "$ROOT" "$TMP/help-for-claims" "$CONTRACT_JSON" <<'PY'
import json, os, sys

cmap = json.load(open(sys.argv[1]))
status = {}
with open(sys.argv[2]) as f:
    for line in f:
        p = line.rstrip("\n").split("\t", 3)
        if len(p) >= 2:
            status[p[0]] = p[1]
root, help_path, contract_path = sys.argv[3], sys.argv[4], sys.argv[5]
help_text = open(help_path, encoding="utf-8", errors="replace").read()
known = {i for d in json.load(open(contract_path))["checks"].values() for i in d["ids"]}

problems, active = [], 0
for row in cmap["claims"]:
    marker, src, ids = row.get("marker", ""), row.get("source", ""), row.get("checks", [])
    text = help_text if src == "help" else (
        open(os.path.join(root, src), encoding="utf-8", errors="replace").read()
        if os.path.isfile(os.path.join(root, src)) else "")
    if not marker or marker not in text:
        continue                      # claim not being made — nothing to overclaim
    active += 1
    if not ids:
        problems.append(f"[{src}] '{marker}' names no check id")
        continue
    for cid in ids:
        if cid not in known:
            problems.append(f"[{src}] '{marker}' names unknown id {cid}")
        elif status.get(cid) != "pass":
            problems.append(f"'{marker}' -> {cid}={status.get(cid, 'absent')}")

if problems:
    print(f"{active} active claim(s); unbacked: " + "; ".join(problems[:6])
          + (f" (+{len(problems)-6} more)" if len(problems) > 6 else ""))
    sys.exit(1)
print(f"all {active} active capability claims map to passing check ids")
PY
}

# ═════════════════════════════════════════════════════════════════════
# driver
# ═════════════════════════════════════════════════════════════════════
run_one() { # $1=id
  local id="$1" fn="chk_${1//-/_}" out rc
  if [[ "$SKIP_LIVE" == 1 ]] && is_live "$id"; then
    record "$id" fail 1 "skipped (CONSULT_SKIP_LIVE=1) — run without it for a scored run"
    return
  fi
  if ! declare -F "$fn" >/dev/null 2>&1; then
    record "$id" fail 0 "not implemented in $(basename "$SELF")"
    return
  fi
  out=$("$fn" 2>&1); rc=$?
  [[ -n "$out" ]] || out='(no detail)'
  if (( rc == 0 )); then record "$id" pass 0 "$out"; else record "$id" fail 0 "$out"; fi
}

printf '\n  %sharness-cli-v1 — 49 deterministic checks%s\n' "$B" "$R"
printf '  %ssubject: bin/productteam + lib/ + docs/ + tests/ · iter dir: %s%s\n' \
  "$D" "${ITER_DIR#"$ROOT"/}" "$R"
[[ "$SKIP_LIVE" == 1 ]] && printf '  %sCONSULT_SKIP_LIVE=1 — live checks recorded as fail/skipped; run is partial%s\n' "$D" "$R"
printf '\n'

for dim in $(jq -r '.dimensions[]' "$CONTRACT_JSON"); do
  printf '  %s%s%s\n' "$B" "$dim" "$R"
  for id in $(jq -r --arg d "$dim" '.checks[$d].ids[]' "$CONTRACT_JSON"); do
    # no-overclaim reads every other result, so it runs last.
    [[ "$id" == no-overclaim ]] && continue
    run_one "$id"
  done
  printf '\n'
done
printf '  %sproduct-clarity (deferred)%s\n' "$B" "$R"
run_one no-overclaim
printf '\n'

kind='full'
[[ "$SKIP_LIVE" == 1 ]] && kind='partial'
write_json "$kind"
exit $?
