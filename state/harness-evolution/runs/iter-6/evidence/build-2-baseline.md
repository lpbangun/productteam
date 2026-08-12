# Baseline notes — Build 2 judgment gates (advisor-owned)

Captured: 2026-08-10, working tree `upgrade-basic-funcionalities`, HEAD `1f6f17e`.
Scope: Build 2 baseline only (mission iteration 1 of 3, Build 2 = judgment-gates per
`progress.json`). No product code touched. This file complements the Build 1 baseline
(`evidence/baseline-notes.md`) and is cited by `mission-benchmark.md` §6.3.

## Frozen guard (unchanged from Build 1)

`state/harness-evolution/HARNESS-BENCHMARK-CONTRACT.md`, `contract.json`, `LOCK.md`,
`FREEZE.md`, `FREEZE-SHA.txt`, `engagement.md`, `LOOP-SEQUENCE.md`, `authorize-merge`,
and `runs/iter-0/…iter-5/` remain untouched. Build 1 verdicts and evidence
(`mission-benchmark.md` §2–§5, `evidence/advisor-verdict.json`, `critic-verdict.md`)
are not re-scored or amended. This baseline records only what Build 2 adds on top.

## Suite state at baseline (Build 1 closed, Build 2 not started)

| Suite | Command | Exit | Artifact |
|-------|---------|------|----------|
| CLI smoke | `bin/consult smoke` | 0 | `evidence/smoke.txt` (Build 1 run: all 28 PASS) |
| Harness checks | `bin/consult harness-checks state/harness-evolution/runs/iter-6` | 0 | `evidence/harness-checks.txt` (Build 1 run: 27 passed · 0 failed) |

Neither suite exercises any Build 2 pointer: the 22 `run_check` ids in
`lib/harness-checks.sh` plus 5 workspace probes (`tests/workspace-smoke.sh`) cover
runtime, lock, learning, judgment *examples*, engagement mode line, github seam,
skills, phases, org self-review, secrets, provider seam, and workspace isolation —
none call an implement gate or read `judgment/` artifacts.

## Probe commands (baseline gap inventory, run 2026-08-10 from repo root)

All probes are re-runnable; findings feed `mission-benchmark.md` §6.3.

1. **Implement gate verb** — `bin/consult help | grep -ic gate` → 0;
   `grep -n "gate)" bin/consult` → no dispatch branch; `grep -c "cmd_gate\|judgment/" bin/consult lib/*.sh` → 0.
   No `consult gate` command exists. `consult status` (`cmd_status`, `bin/consult:208`)
   is the org-level engagements overview, not a per-client gate/machine status.
2. **Durable gate artifacts** — `find . -type d -name judgment` → 0 matches;
   `find state -name "*.json" | grep -i "gate\|judgment"` → 0 matches.
   No per-engagement `judgment/` files exist anywhere.
3. **Judge show/set (pre-existing seam)** — `bin/consult help` lists
   `consult judge <client>` and `consult judge <client> set <mode>`
   (`bin/consult:127-128`; dispatch `bin/consult:559-565`; `cmd_judge` `:283`,
   `cmd_judge_set` `:301`). `cmd_judge_set` writes the mode line into
   `state/engagements/<client>/engagement.md` via `sed`. Tests cover show/set:
   `tests/consult-smoke.sh:17` (judge show), `:30` (judge harness-evolution),
   `:56` (help lists judge).
4. **Override risks / non-waivers** — only the *example* artifacts exist:
   `state/harness-evolution/examples/override-risks.md` and
   `examples/challenge-refusal.md`; harness-checks verifies only their presence
   (`run_check judgment-examples`, `lib/harness-checks.sh:93`) and the engagement
   mode line (`run_check harness-engagement-mode`, `:94`). No gate records risks or
   non-waivers into durable files at run time.
5. **Machine status** — `consult judge <client>` prints mode + mission as text
   (no JSON, no gate state); no command emits machine-readable implement-gate status.
6. **Mode→Implement binding** — JUDGMENT.md is authoritative (Guided = no implement
   until Principal/owner selects; Directive = implement smallest diff satisfying
   direction + frozen contract; Challenge = refuse harmful path, offer safer
   alternatives; Override = follow explicit decision after Challenge, document
   unresolved concerns, never waive contract). Nothing enforces or records those
   bindings at the CLI: `grep -c "implement"` gate wiring in `tests/consult-smoke.sh`
   `tests/workspace-smoke.sh` `lib/harness-checks.sh` → 0 each.

## Honest baseline verdict (pre-implementation)

| Pointer | Baseline status | Evidence |
|---------|----------------|----------|
| 1 All four modes bind Implement per JUDGMENT | **FAIL** | modes are documented (JUDGMENT.md) and selectable (`consult judge … set`, tests/consult-smoke.sh:17,30,56) but no gate consults or records them; implementability is not decided or archived (probe 1, 6) |
| 2 Required gates are durable files | **FAIL** | zero `judgment/` dirs and zero gate/judgment JSON in `state/` (probe 2); mode lives only in `engagement.md` text |
| 3 Override risks + non-waivers | **FAIL** | only static example artifact `examples/override-risks.md`; no run-time requirement of non-empty risks or critic/evidence/frozen-contract non-waiver records (probe 4) |
| 4 Machine status | **FAIL** | no `consult gate <client> status`; `cmd_status` is org overview (`bin/consult:208`); `judge show` is human text only (probe 3, 5) |
| 5 Each mode has ≥1 refuse and pass path | **FAIL** | no gate refuse/pass checks in `lib/harness-checks.sh` or either smoke test (probe 6); Build 1 workspace dirty refuse/pass (`workspace-dirty-refusal`, `workspace-dirty-escape-evidence`) are isolation paths, not judgment-gate paths |

## Verdict

Current state is honestly: `consult judge` show/set exists and is smoke-tested; the
four modes are fully specified in JUDGMENT.md; Challenge/Override have documented
example artifacts. There is no implement gate, no durable `judgment/` gate state,
no machine-readable gate status, and no gate refusal/pass tests. All five Build 2
pointers therefore FAIL at baseline. This is the pre-implementation state Build 2
must close; Build 4's Builder invocation will later call the same implement gate,
so its surface is specified now.
