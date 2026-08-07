#!/usr/bin/env bash
# run-checks.sh — deterministic ofc-v1 contract checks.
# Usage: run-checks.sh <client> <engagement_dir> <repo>
set -uo pipefail
CLIENT="$1"
EDIR="$2"
REPO="$3"
OUT="$EDIR/runs/.checks-latest.json"
mkdir -p "$EDIR/runs" /tmp

# Scorer gate — this runner is for scorer=checks (ofc-v1 today)
if [[ -f "$EDIR/contract.json" ]]; then
  scorer=$(jq -r '.scorer // empty' "$EDIR/contract.json")
  cid=$(jq -r '.contract // empty' "$EDIR/contract.json")
  if [[ -n "$scorer" && "$scorer" != "checks" ]]; then
    printf '  checks runner: engagement scorer=%s (expected checks)\n' "$scorer"
    exit 1
  fi
  if [[ -z "$scorer" && -n "$cid" && "$cid" != "ofc-v1" ]]; then
    printf '  checks runner: contract %s has no scorer=checks\n' "$cid"
    exit 1
  fi
fi

# Shared palette — no local escape literals (cli-theme-single-source).
# shellcheck source=lib/theme.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/theme.sh"

TMPDIR_CHECKS=$(mktemp -d)
trap 'rm -rf "$TMPDIR_CHECKS"' EXIT
RESULTS_FILE="$TMPDIR_CHECKS/results.tsv"
: > "$RESULTS_FILE"

record() {
  local id="$1" status="$2" detail="$3"
  printf '%s\t%s\t%s\n' "$id" "$status" "$detail" >> "$RESULTS_FILE"
  if [[ "$status" == pass ]]; then
    printf '  %s✓%s %-40s %s%s%s\n' "$G" "$R" "$id" "$D" "${detail:0:55}" "$R"
  else
    printf '  %s✗%s %-40s %s%s%s\n' "$RD" "$R" "$id" "$D" "${detail:0:55}" "$R"
  fi
}

run_check() {
  local id="$1"
  shift
  local out rc
  set +e
  out=$(cd "$REPO" && bash -c "$*" 2>&1)
  rc=$?
  set -e
  if [[ $rc -eq 0 ]]; then
    record "$id" pass "$(echo "$out" | head -1)"
  else
    record "$id" fail "$(echo "$out" | head -1)"
  fi
}

status_of() {
  awk -F'\t' -v id="$1" '$1==id{print $2; exit}' "$RESULTS_FILE"
}

# ── documentation / files ───────────────────────────────────
run_check readme-exists 'test -f README.md && echo present'
run_check readme-required-sections '
  f=README.md; test -f "$f" || exit 1
  for s in "What this is" "Who it is for" "What it is not" "Clone and run" "Demo walkthrough" "Non-goals"; do
    grep -q "$s" "$f" || { echo "missing: $s"; exit 1; }
  done
  echo ok
'
run_check walkthrough-covers-maya '
  f=README.md; test -f "$f" || exit 1
  grep -qi "Maya Chen" "$f" && grep -qi availability "$f" && grep -qi slot "$f" && grep -qi confirm "$f" && echo ok
'
run_check docs-honest-prototype '
  f=README.md; test -f "$f" || exit 1
  grep -qiE "no backend|without a backend|No backend" "$f" && grep -qi localStorage "$f" && grep -qi fictional "$f" && echo ok
'
run_check cross-role-demo-script '
  if [[ -f docs/demo-walkthrough.md ]]; then f=docs/demo-walkthrough.md; else f=README.md; fi
  test -f "$f" || exit 1
  grep -qiE "People Ops|PeopleOps" "$f" && grep -qi Manager "$f" && grep -qi "New Hire" "$f" && grep -qi Copilot "$f" && echo ok
'
run_check architecture-notes '
  if [[ -f docs/architecture.md ]]; then f=docs/architecture.md; else f=README.md; fi
  test -f "$f" || exit 1
  grep -qi Architecture "$f" && echo ok
'
run_check readme-non-goals-explicit '
  f=README.md; test -f "$f" || exit 1
  grep -q "Non-goals" "$f" && grep -qiE "auth|authentication" "$f" && grep -qiE "AI|model" "$f" && echo ok
'
run_check dev-script-documented 'test -f README.md && grep -q "npm run dev" README.md && echo ok'
run_check node-version-noted '
  if [[ -f .nvmrc ]]; then echo .nvmrc; exit 0; fi
  if grep -q "\"engines\"" package.json 2>/dev/null; then echo engines; exit 0; fi
  test -f README.md && grep -qi Node README.md
'

# ── DX / package ────────────────────────────────────────────
run_check deps-pinned 'node -e "
  const p=require(\"./package.json\");
  const all={...p.dependencies,...p.devDependencies};
  const bad=Object.entries(all).filter(([,v])=>v===\"latest\");
  if(bad.length){console.error(JSON.stringify(bad)); process.exit(1);}
  console.log(\"ok\");
"'
run_check test-script-exists 'node -e "const p=require(\"./package.json\"); if(!p.scripts||!p.scripts.test) process.exit(1); console.log(p.scripts.test);"'
run_check deps-minimal 'node -e "
  const p=require(\"./package.json\");
  const allowed=new Set([\"react\",\"react-dom\",\"lucide-react\",\"@vitejs/plugin-react\",\"vite\",\"typescript\"]);
  const bad=Object.keys(p.dependencies||{}).filter(d=>!allowed.has(d));
  if(bad.length){console.error(bad.join(\",\")); process.exit(1);}
  console.log(\"ok\");
"'

# ── structural ──────────────────────────────────────────────
run_check domain-pure '! grep -qiE "from [\x27\"]react[\x27\"]|require\\([\x27\"]react" src/domain.ts && echo ok'
run_check app-not-monolith '
  lines=$(wc -l < src/App.tsx)
  extras=$(find src -type f \( -name "*.tsx" -o -name "*.ts" \) ! -name App.tsx ! -name main.tsx ! -name vite-env.d.ts ! -name "*.test.ts" ! -name "*.test.tsx" ! -path "*/__tests__/*" | wc -l)
  echo "App.tsx=$lines extras=$extras"
  test "$lines" -le 600 && test "$extras" -ge 3
'
run_check lean-src-tree '
  n=$(find src -type f \( -name "*.ts" -o -name "*.tsx" \) ! -name "*.test.ts" ! -name "*.test.tsx" ! -path "*/__tests__/*" | wc -l)
  echo "src_files=$n"
  test "$n" -le 25
'
run_check single-derive-support '
  n=$(grep -REn "export function deriveSupport|function deriveSupport" src/ --include="*.ts" --include="*.tsx" | wc -l)
  echo "count=$n"
  test "$n" -eq 1
'
run_check demo-constants-centralized '
  maya=$(grep -REn "const MAYA_ID|export const MAYA_ID" src/ --include="*.ts" --include="*.tsx" | wc -l)
  stor=$(grep -REn "const STORAGE_KEY|export const STORAGE_KEY" src/ --include="*.ts" --include="*.tsx" | wc -l)
  echo "MAYA_ID_defs=$maya STORAGE_KEY_defs=$stor"
  test "$maya" -eq 1 && test "$stor" -eq 1
'

# ── product clarity (source) ────────────────────────────────
run_check home-states-fictional 'grep -qiE "fictional|prototype" src/App.tsx && grep -qiE "no employee data|Local-only|fictional" src/App.tsx && echo ok'
run_check topbar-prototype-chip 'grep -q "Fictional prototype" src/App.tsx && echo ok'
run_check copilot-not-ai 'grep -qiE "not (a |an )?(real )?AI|deterministic|no (AI|model) call|demo (logic|messages)|prebuilt" src/App.tsx && echo ok'
run_check three-role-labels 'grep -q "People Ops" src/App.tsx && grep -q Manager src/App.tsx && grep -q "New Hire" src/App.tsx && echo ok'

# ── build / test ────────────────────────────────────────────
run_check build-green 'npm run build > /tmp/ofc-build.out 2>&1 && echo built'
run_check typescript-build 'tail -3 /tmp/ofc-build.out | tr "\n" " "; test -f /tmp/ofc-build.out'
run_check test-suite-green 'npm test > /tmp/ofc-test.out 2>&1 && echo tested'

# Named vitest probes (fail if suite missing or test fails)
for t in \
  maya-intro-flow \
  initial-handoffs-complete \
  domain-transitions-generic \
  derive-support-seed \
  status-signal-consistency \
  override-requires-reason \
  board-pills-require-reason \
  coordinator-signal-matches-domain \
  home-to-workspace \
  role-switcher-three-roles \
  reset-demo-restores-seed \
  a11y-smoke \
  no-duplicate-status-meta \
  no-dead-seed-fields
do
  run_check "$t" "npm test -- -t '$t' > /tmp/ofc-$t.out 2>&1 && echo pass"
done

# Composite checks depending on prior results
if [[ "$(status_of build-green)" == pass && "$(status_of test-suite-green)" == pass ]]; then
  record ci-local-parity pass 'build+test'
else
  record ci-local-parity fail 'build or test failed'
fi
if [[ "$(status_of readme-exists)" == pass && "$(status_of build-green)" == pass && "$(status_of test-suite-green)" == pass ]]; then
  record readme-clone-run-verified pass 'readme+build+test'
else
  record readme-clone-run-verified fail 'readme, build, or test missing'
fi

# JSON summary + score assist
python3 - "$RESULTS_FILE" "$OUT" "$CLIENT" <<'PY'
import json, sys, datetime
results_path, out_path, client = sys.argv[1:4]
checks = {}
with open(results_path) as f:
    for line in f:
        parts = line.rstrip("\n").split("\t", 2)
        if len(parts) < 2:
            continue
        cid, status = parts[0], parts[1]
        detail = parts[2] if len(parts) > 2 else ""
        checks[cid] = {"status": status, "detail": detail}

# ofc-v1 dimension → check ids
DIMS = {
  "onboarding-quality": [
    "test-suite-green", "maya-intro-flow", "initial-handoffs-complete",
    "domain-transitions-generic", "derive-support-seed",
  ],
  "workflow-clarity": [
    "status-signal-consistency", "override-requires-reason",
    "board-pills-require-reason", "coordinator-signal-matches-domain",
    "cross-role-demo-script",
  ],
  "usability": [
    "build-green", "home-to-workspace", "role-switcher-three-roles",
    "reset-demo-restores-seed", "a11y-smoke",
  ],
  "maintainability": [
    "typescript-build", "app-not-monolith", "domain-pure",
    "demo-constants-centralized", "architecture-notes",
  ],
  "documentation": [
    "readme-exists", "readme-required-sections", "readme-clone-run-verified",
    "walkthrough-covers-maya", "docs-honest-prototype",
  ],
  "developer-experience": [
    "deps-pinned", "test-script-exists", "ci-local-parity",
    "dev-script-documented", "node-version-noted",
  ],
  "product-clarity": [
    "home-states-fictional", "topbar-prototype-chip", "copilot-not-ai",
    "three-role-labels", "readme-non-goals-explicit",
  ],
  "simplicity": [
    "single-derive-support", "no-duplicate-status-meta", "lean-src-tree",
    "deps-minimal", "no-dead-seed-fields",
  ],
}

def band_score(dim, passed, total, checks_map, ids):
    # Conservative objective scoring from contract bands
    n = sum(1 for i in ids if checks_map.get(i, {}).get("status") == "pass")
    if dim == "onboarding-quality":
        maya = checks_map.get("maya-intro-flow", {}).get("status") == "pass"
        if n == total: return 9.5
        if n >= 3 and maya: return 7.0
        return 3.0 if not maya else 4.0
    if dim == "workflow-clarity":
        cons = checks_map.get("status-signal-consistency", {}).get("status") == "pass"
        ovr = checks_map.get("override-requires-reason", {}).get("status") == "pass"
        if n == total: return 9.5
        if n >= 3 and (cons or ovr): return 7.0
        if not cons and not ovr: return 3.0
        return 4.5
    if dim == "usability":
        build = checks_map.get("build-green", {}).get("status") == "pass"
        reset = checks_map.get("reset-demo-restores-seed", {}).get("status") == "pass"
        if n == total: return 9.5
        if not build: return 2.0
        if n >= 3 and reset: return 7.0
        return 4.5
    if dim == "maintainability":
        # special: App.tsx >900 → ≤5
        detail = checks_map.get("app-not-monolith", {}).get("detail", "")
        app_lines = None
        if "App.tsx=" in detail:
            try:
                app_lines = int(detail.split("App.tsx=")[1].split()[0])
            except Exception:
                pass
        tsc = checks_map.get("typescript-build", {}).get("status") == "pass"
        pure = checks_map.get("domain-pure", {}).get("status") == "pass"
        if app_lines is not None and app_lines > 900:
            return 4.0
        if n == total: return 9.5
        if n >= 3 and tsc and pure: return 7.0
        return 4.0
    if dim == "documentation":
        readme = checks_map.get("readme-exists", {}).get("status") == "pass"
        clone = checks_map.get("readme-clone-run-verified", {}).get("status") == "pass"
        if n == total: return 9.5
        if not readme or not clone and not readme: return 2.0 if not readme else 4.0
        if not readme: return 2.0
        if n >= 3: return 7.0
        return 4.0
    if dim == "developer-experience":
        pinned = checks_map.get("deps-pinned", {}).get("status") == "pass"
        parity = checks_map.get("ci-local-parity", {}).get("status") == "pass"
        if not pinned: return 4.0
        if n == total: return 9.5
        if n >= 3 and parity: return 7.0
        return 4.5
    if dim == "product-clarity":
        home = checks_map.get("home-states-fictional", {}).get("status") == "pass"
        if n == total: return 9.5
        if n >= 3 and home: return 7.5
        return 4.0 if not home else 5.0
    if dim == "simplicity":
        single = checks_map.get("single-derive-support", {}).get("status") == "pass"
        if n == total: return 9.5
        if n >= 3 and single: return 7.5
        return 4.0
    return round(10 * n / total, 1)

scores = {}
for dim, ids in DIMS.items():
    n_pass = sum(1 for i in ids if checks.get(i, {}).get("status") == "pass")
    sc = band_score(dim, n_pass, len(ids), checks, ids)
    failed = [i for i in ids if checks.get(i, {}).get("status") != "pass"]
    evidence = f"{n_pass}/{len(ids)} checks pass"
    if failed:
        evidence += "; fail: " + ", ".join(failed[:4])
    scores[dim] = {"score": sc, "evidence": evidence, "passed": n_pass, "total": len(ids), "failed": failed}

overall = round(sum(s["score"] for s in scores.values()) / len(scores), 1)
payload = {
    "ts": datetime.date.today().isoformat(),
    "client": client,
    "contract": "ofc-v1",
    "checks": checks,
    "scores": scores,
    "overall": overall,
}
with open(out_path, "w") as f:
    json.dump(payload, f, indent=2)
    f.write("\n")
print(f"\n  overall {overall}  → {out_path}")
PY

passed=$(awk -F'\t' '$2=="pass"{c++} END{print c+0}' "$RESULTS_FILE")
failed=$(awk -F'\t' '$2=="fail"{c++} END{print c+0}' "$RESULTS_FILE")
printf '\n  %s%d passed · %d failed%s\n\n' "$B" "$passed" "$failed" "$R"
exit 0
