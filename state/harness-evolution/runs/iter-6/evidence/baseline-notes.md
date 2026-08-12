# Baseline notes — Build 1 workspace isolation (advisor-owned)

Captured: 2026-08-10, working tree `upgrade-basic-funcionalities`, HEAD `1f6f17e`.
Scope: Build 1 baseline only (mission iteration 1 of 3). No product code touched.

## Suite runs (exact commands + exit status)

| Suite | Command (run from repo root) | Exit | Artifact |
|-------|------------------------------|------|----------|
| CLI smoke | `bin/consult smoke > state/harness-evolution/runs/iter-6/evidence/smoke.txt 2>&1` | 0 | `evidence/smoke.txt` |
| Harness checks | `bin/consult harness-checks state/harness-evolution/runs/iter-6 > state/harness-evolution/runs/iter-6/evidence/harness-checks.txt 2>&1` | 0 | `evidence/harness-checks.txt`, `checks.json` |

`bin/consult smoke`: 28/28 PASS, "all smoke checks passed".
`bin/consult harness-checks state/harness-evolution/runs/iter-6`: 22 passed · 0 failed;
`phases-artifact` detail `loop-sequence-only` (no `phases.json` in iter-6 — acceptable;
harness-checks falls back to `LOOP-SEQUENCE.md`). Suite wrote `checks.json` into iter-6.

## Suite side effects (honesty note)

Running the suites regenerated pre-existing working artifacts outside iter-6:
`state/engagements/onboarding-flight-control/runs/.checks-latest.json` (ts bumped to
2026-08-10) and iter-3 evidence skill scaffolds (rerun content drift). These were
restored to committed state with `git checkout -- <paths>` after capture; `git status --short`
then showed only `?? state/harness-evolution/runs/iter-6/`. The frozen
harness-apc-v1 files (HARNESS-BENCHMARK-CONTRACT.md, contract.json, LOCK.md, FREEZE*,
engagement.md, LOOP-SEQUENCE.md, authorize-merge, iter-0..5 runs) were never edited.

## Probe commands (baseline gap inventory)

All probes run 2026-08-10 from repo root; findings cited in `mission-benchmark.md` §3.

1. Workspace verb in CLI — `bin/consult help | grep -ic "workspace"` → 0.
   `bin/consult help | grep -iE "ws|workspace|isolat"` → 0 matches.
2. Dirty handling — `grep -rn -i "dirty" lib/ bin/consult` → 0 matches.
3. Isolation coverage in harness-checks — `grep -c "workspace\|isolat\|dirty" lib/harness-checks.sh` → 0.
4. Docs — `grep -rn -i "workspace\|isolat" README.md AGENTS.md ARCHITECTURE.md docs/` → 0 matches.
5. Evidence location — `ls state/engagements/onboarding-flight-control/runs/iter-0/` →
   `checks.txt npm-test.txt report.md scores.json`; per-run evidence lives in the shared
   live engagement dir (`runs/.checks-latest.json` at the engagement root). No workspace isolation.

## Verdict

Current behavior is honestly: smoke and harness-checks green (exit 0) but zero
coverage of the five workspace-isolation pointers; all five pointers FAIL or are
PARTIAL at pointer level per `mission-benchmark.md` §3 table. This is the
pre-implementation baseline for Build 1.
