#!/usr/bin/env bash
# osint-loop-checks.sh — deterministic checks for contract osint-loop-v1.
# Usage: bash lib/osint-loop-checks.sh <check-dir> <workspace-path>
set -uo pipefail

CHECK_DIR="${1:?check-dir required}"
REPO="${2:?workspace path required}"
mkdir -p "$CHECK_DIR"
OUT="$CHECK_DIR/checks.json"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EDIR="$ROOT/state/engagements/osint-loop-research"

if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  B=$'\e[1m' D=$'\e[2m' R=$'\e[0m'
else
  B='' D='' R=''
fi

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
RESULTS="$TMP/results.tsv"
: > "$RESULTS"

record() {
  local id="$1" status="$2" detail="$3"
  detail=$(printf '%s' "$detail" | tr '\t\n' '  ' | sed -E 's/  +/ /g')
  printf '%s\t%s\t%s\n' "$id" "$status" "$detail" >> "$RESULTS"
  local mark='FAIL'
  [[ "$status" == pass ]] && mark='pass'
  printf '  %-4s %-28s %s%s%s\n' "$mark" "$id" "$D" "${detail:0:90}" "$R"
}

printf '\n  %sosint-loop-v1 checks — %s%s\n\n' "$B" "$REPO" "$R"

# Isolate runtime dirs for check runs so we never touch owner/workspace dirty state.
RUN="$TMP/osint-run"
mkdir -p "$RUN"
cp -a "$REPO/loops" "$RUN/"
[[ -d "$REPO/tools" ]] && cp -a "$REPO/tools" "$RUN/"
[[ -d "$REPO/skills" ]] && cp -a "$REPO/skills" "$RUN/"
[[ -f "$REPO/requirements.txt" ]] && cp -a "$REPO/requirements.txt" "$RUN/"
[[ -f "$REPO/README.md" ]] && cp -a "$REPO/README.md" "$RUN/"
mkdir -p "$RUN/evidence" "$RUN/output" "$RUN/.tmp"
: > "$RUN/evidence/evidence.jsonl"

# Execute product checks against the isolated copy.
REPO_EXEC="$RUN"

run_check() {
  local id="$1"; shift
  local out rc
  set +e
  out=$(cd "$REPO_EXEC" && bash -c "$*" 2>&1)
  rc=$?
  set -e
  if [[ $rc -eq 0 ]]; then
    record "$id" pass "$(printf '%s' "$out" | head -1)"
  else
    record "$id" fail "$(printf '%s' "$out" | head -1)"
  fi
}

run_check cli-module-help 'python3 -m loops.main_loop --help | head -1'
run_check cli-flags-parse 'python3 -m loops.main_loop --help | grep -q -- --resume && python3 -m loops.main_loop --help | grep -q -- --max-iterations && echo ok'

run_check cold-run-exits-zero '
  rm -rf .tmp output && mkdir -p .tmp output evidence
  python3 -m loops.main_loop --target "Fixture Person" --family "Anchor One" --max-iterations 1 >/tmp/osint-cold.out 2>&1
  test -f output/dossier.md && test -f output/evidence_summary.md && test -f output/termination.json && echo ok
'

run_check cold-run-target-generic '
  test -f output/dossier.md || exit 1
  grep -q "Fixture Person" output/dossier.md || exit 1
  if grep -q "Shane Lowe (professional usage)" output/dossier.md; then echo hardcoded; exit 1; fi
  echo ok
'

run_check ingest-target-generic '
  # Planner/ingest modules must not hardcode Shane; planned queries for Fixture Person must cite that target.
  for f in loops/discovery_loop.py loops/archive_loop.py loops/image_intel.py loops/blackhat_loop.py; do
    if grep -q "Shane Patrick Arthur Lowe" "$f"; then echo "hardcoded in $f"; exit 1; fi
    if grep -qE "\"Shane Lowe\"|spa_lowe" "$f"; then echo "hardcoded alias in $f"; exit 1; fi
  done
  python3 - <<'"'"'PY'"'"'
import sys
sys.path.insert(0, "loops")
from discovery_loop import DiscoveryLoop
from blackhat_loop import BlackhatLoop
from evidence_store import EvidenceStore
import tempfile
store = EvidenceStore(tempfile.mkdtemp())
d = DiscoveryLoop(store, 1)
plan = d.run_discovery("Fixture Person", ["Anchor One"], [])
blob = " ".join(plan.get("queries", []))
assert "Fixture Person" in blob or "Fixture" in blob, plan.get("queries", [])[:5]
assert "Shane" not in blob, blob[:200]
bh = BlackhatLoop(store, 1)
alias = bh._plan_alias_inference("Fixture Person", ["Anchor One"])
ablob = " ".join(alias.get("queries", [])) + " ".join(alias.get("possible_aliases", []))
assert "Shane" not in ablob and "spa_lowe" not in ablob, ablob[:200]
assert "Fixture" in ablob or "Person" in ablob, ablob[:200]
print("ok")
PY
'

run_check resume-refuse-at-max '
  set +e
  out=$(python3 -m loops.main_loop --target "Fixture Person" --resume --max-iterations 1 2>&1)
  rc=$?
  set -e
  test "$rc" -eq 2 || { echo "expected exit 2 got $rc"; exit 1; }
  printf "%s" "$out" | grep -qiE "max-iterations|already stopped|raise" || { echo "missing message"; exit 1; }
  echo ok
'

run_check resume-continue-raised-max '
  python3 -m loops.main_loop --target "Fixture Person" --resume --max-iterations 2 >/tmp/osint-resume.out 2>&1
  test -f output/termination.json || exit 1
  python3 -c "import json; d=json.load(open(\"output/termination.json\")); assert d.get(\"iteration\")==2, d; print(\"ok\")"
'

run_check termination-artifact '
  python3 - <<'"'"'PY'"'"'
import json
from pathlib import Path
p = Path("output/termination.json")
d = json.loads(p.read_text())
for k in ("should_stop", "reasons", "checks", "iteration", "status"):
    assert k in d, f"missing {k}"
assert isinstance(d["checks"], dict) and d["checks"], "checks empty"
assert "max_iterations" in d["checks"]
print("ok")
PY
'

run_check termination-matches-engine '
  python3 - <<'"'"'PY'"'"'
import json
d = json.load(open("output/termination.json"))
c = d["checks"]
formula = (
    c["no_new_data_streak"]["met"]
    or (c["location_confidence"]["met"] and c["professional_confidence"]["met"])
    or c["max_iterations"]["met"]
    or (c["family_source_diversity"]["met"] and c["high_confidence_coverage"]["met"])
    or c["diminishing_returns"]["met"]
)
assert bool(d["should_stop"]) == bool(formula), (d["should_stop"], formula)
print("ok")
PY
'

run_check readme-stop-aligned '
  f=README.md
  grep -qi "termination" "$f" || grep -qi "Maximum iteration" "$f" || exit 1
  grep -qiE "no new|consecutive|location|professional|family" "$f" || exit 1
  test -f loops/termination_engine.py && echo ok
'

run_check evidence-persist-upgrade '
  python3 - <<'"'"'PY'"'"'
import sys, tempfile
sys.path.insert(0, "loops")
from evidence_store import EvidenceStore, EvidenceItem
from verification_loop import VerificationLoop

td = tempfile.mkdtemp()
store = EvidenceStore(td)
for i, url in enumerate(["https://example.com/a", "https://example.com/b"], 1):
    store.add(EvidenceItem(
        fact_id=f"f{i}", timestamp="2026-08-11T00:00:00Z", target="Fixture Person",
        category="identity", claim="Fixture Person is a public figure",
        source_url=url, source_title=f"src{i}", date_accessed="2026-08-11",
        excerpt="excerpt", confidence=50, verification_status="single_source",
        related_names=[], notes="", iteration=1,
    ))
v = VerificationLoop(store, iteration=1)
result = v.run_verification("Fixture Person", ["Anchor One"])
assert result["upgraded_facts"], result
item = EvidenceStore(td).get_by_fact_id("f1")
assert item is not None
assert item.verification_status == "multi_source", item.verification_status
assert item.confidence >= 65, item.confidence
print("ok")
PY
'

run_check evidence-provenance-fields '
  python3 - <<'"'"'PY'"'"'
import sys, tempfile
sys.path.insert(0, "loops")
from evidence_store import EvidenceStore, EvidenceItem
td = tempfile.mkdtemp()
store = EvidenceStore(td)
store.add(EvidenceItem(
    fact_id="p1", timestamp="2026-08-11T00:00:00Z", target="Fixture Person",
    category="general", claim="claim", source_url="https://example.com/x",
    source_title="t", date_accessed="2026-08-11", excerpt="ex", confidence=40,
    verification_status="unverified",
))
item = EvidenceStore(td).get_by_fact_id("p1")
assert item.source_url and item.date_accessed and item.excerpt
assert 0 <= item.confidence <= 100
assert item.verification_status in {"single_source","multi_source","contradicted","unverified"}
print("ok")
PY
'

run_check output-inspectable '
  test -f output/dossier.md && test -f output/evidence_summary.md && test -f output/termination.json
  grep -q "Fixture Person" output/dossier.md
  python3 -c "import json; json.load(open(\"output/termination.json\")); print(\"ok\")"
'

run_check boundedness-honored '
  rm -rf .tmp output && mkdir -p .tmp output evidence
  python3 -m loops.main_loop --target "Bound Person" --max-iterations 1 >/tmp/osint-bound.out 2>&1
  python3 -c "import json; d=json.load(open(\"output/termination.json\")); assert d[\"iteration\"]==1; assert d[\"checks\"][\"max_iterations\"][\"met\"] is True; print(\"ok\")"
'

run_check no-unbounded-mission '
  if grep -qiE "don.t stop|do not stop until|find contact|never stop" README.md loops/*.py 2>/dev/null; then
    echo found-unbounded-language; exit 1
  fi
  echo ok
'

# Score dimensions from check ids
python3 - "$RESULTS" "$OUT" "$EDIR/contract.json" <<'PY'
import json, sys, datetime
results_path, out_path, contract_path = sys.argv[1:4]
checks = {}
with open(results_path) as f:
    for line in f:
        parts = line.rstrip("\n").split("\t", 2)
        if len(parts) < 2:
            continue
        cid, status = parts[0], parts[1]
        detail = parts[2] if len(parts) > 2 else ""
        checks[cid] = {"status": status, "detail": detail}

DIMS = {
    "cli-runnable": ["cli-module-help", "cli-flags-parse"],
    "cold-run": ["cold-run-exits-zero", "cold-run-target-generic", "ingest-target-generic"],
    "resume-semantics": ["resume-refuse-at-max", "resume-continue-raised-max"],
    "termination-fidelity": ["termination-artifact", "termination-matches-engine", "readme-stop-aligned"],
    "evidence-integrity": ["evidence-persist-upgrade", "evidence-provenance-fields"],
    "output-inspectability": ["output-inspectable"],
    "boundedness": ["boundedness-honored", "no-unbounded-mission"],
}

scores = {}
for dim, ids in DIMS.items():
    n = sum(1 for i in ids if checks.get(i, {}).get("status") == "pass")
    total = len(ids)
    failed = [i for i in ids if checks.get(i, {}).get("status") != "pass"]
    if n == total:
        sc = 9.5
    elif n == 0:
        sc = 2.0
    else:
        sc = round(4.0 + 5.0 * n / total, 1)
    scores[dim] = {
        "score": sc,
        "evidence": f"{n}/{total} checks pass" + ("; fail: " + ", ".join(failed) if failed else ""),
        "passed": n,
        "total": total,
        "failed": failed,
    }

overall = round(sum(s["score"] for s in scores.values()) / len(scores), 1)
contract = json.load(open(contract_path))
payload = {
    "ts": datetime.date.today().isoformat(),
    "client": "osint-loop-research",
    "contract": contract.get("contract", "osint-loop-v1"),
    "checks": checks,
    "scores": scores,
    "overall": overall,
}
with open(out_path, "w") as f:
    json.dump(payload, f, indent=2)
    f.write("\n")
# Also publish to engagement latest for score publish path
import os
latest = os.path.join(os.path.dirname(out_path), "..", ".checks-latest.json")
# check-dir is runs/check-*, parent is runs/
runs_dir = os.path.dirname(out_path)
if os.path.basename(runs_dir).startswith("check-"):
    latest = os.path.join(os.path.dirname(runs_dir), ".checks-latest.json")
with open(latest, "w") as f:
    json.dump(payload, f, indent=2)
    f.write("\n")
n_pass = sum(1 for c in checks.values() if c["status"] == "pass")
print(f"\n  overall {overall}  → {out_path}")
print(f"checks ▸ osint-loop-research · {n_pass}/{len(checks)} · weakest: {min(scores, key=lambda d: scores[d]['score'])}")
failed = sum(1 for c in checks.values() if c["status"] != "pass")
sys.exit(1 if failed else 0)
PY
