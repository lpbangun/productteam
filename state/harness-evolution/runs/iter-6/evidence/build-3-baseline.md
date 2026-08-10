# Baseline notes — Build 3 durable escalations, pause/authorized resume, file-derived inspect (advisor-owned)

Captured: 2026-08-10, working tree `upgrade-basic-funcionalities`, HEAD `1f6f17e`.
Scope: Build 3 baseline only (mission iteration 1 of 3, Build 3 =
inspect-pack-escalations per `progress.json`). No product code touched. This file
complements the Build 1 baseline (`evidence/baseline-notes.md`) and the Build 2
baseline (`evidence/build-2-baseline.md`) and is cited by `mission-benchmark.md` §7.2.

## Frozen guard (unchanged from Builds 1–2)

`state/harness-evolution/HARNESS-BENCHMARK-CONTRACT.md`, `contract.json`, `LOCK.md`,
`FREEZE.md`, `FREEZE-SHA.txt`, `engagement.md`, `LOOP-SEQUENCE.md`, `authorize-merge`,
and `runs/iter-0/…iter-5/` remain untouched. Build 1 and Build 2 verdicts and evidence
(`mission-benchmark.md` §2–§6, `evidence/advisor-verdict.json`, `critic-verdict.md`,
`evidence/build-2-advisor-verdict.json`, `build-2-critic-verdict.md`) are not re-scored
or amended. `state/harness-evolution/judgment/` is Build 2's own durable gate state and
is not touched by Build 3. This baseline records only what Build 3 adds on top.

## Suite state at baseline (Builds 1–2 closed, Build 3 not started)

| Suite | Command | Exit | Artifact |
|-------|---------|------|----------|
| CLI smoke | `bin/consult smoke` | 0 | `evidence/smoke.txt` (Build 2 run) |
| Harness checks | `bin/consult harness-checks state/harness-evolution/runs/iter-6` | 0 | `evidence/harness-checks.txt` (Build 2 run: 35 passed · 0 failed; re-confirmed 2026-08-10 at capture time) |

Neither suite exercises any Build 3 pointer: the `run_check` ids in
`lib/harness-checks.sh` plus the workspace and judgment-gate probes cover runtime,
lock, learning, judgment examples, engagement mode line, github seam, skills, phases,
org self-review, secrets, provider seam, workspace isolation (Build 1), and the eight
gate refuse/pass checks (Build 2) — none read `escalations.json`, `pause.json`,
`authorize-resume.json`, or an `inspect-pack.json`.

## Probe commands (baseline gap inventory, run 2026-08-10 from repo root)

All probes are re-runnable; findings feed `mission-benchmark.md` §7.2.

1. **Build 3 verbs in CLI** — `bin/consult help | grep -iE "escalat|pause|resume|inspect"` → 0 matches. `bin/consult help` lists `judge`/`gate`/`score`/`bench`/`checks`/`workspace`/`harness-checks`/`runtime`/`gh`/`skill`/`run`/`report`/`memory`/`org`/`smoke`/`help` — no escalation, pause, resume, or inspect command.
2. **Durable escalation artifacts** — `find . -path ./.git -prune -o -name "escalations.json" -print` → 0; `find state/engagements -name "*escalat*"` → 0. Escalations exist only as prose in `MEMORY.md` §Escalations ("awaiting owner", e.g. the agcode-learning data-path escalation with three listed options) and in `state/engagements/agcode-learning/runs/iter-1/panel.json`/`report.md` text. No per-engagement machine-readable escalation state anywhere.
3. **Escalation block/options/token mechanics** — `grep -rniE "escalat" bin/ lib/ tests/` → only role prose (`bin/consult:259` "Principal … escalates", `bin/consult:279` "Escalate: permanent workers · architecture · security/auth ·"). No command blocks score/check/implement on an open escalation; no resolve records options or a token.
4. **Pause/resume artifacts** — `find . -path ./.git -prune -o \( -name "pause.json" -o -name "authorize-resume.json" \) -print` → 0 files. No pause or resume concept in `bin/consult` (`grep -n "pause\|resume" bin/consult` → 0 functional hits). `state/harness-evolution/runs/iter-6/progress.json` exists (builds 1–2 `done`, 3 `next`, 4 `pending`, `next_action` text) but nothing pauses or resumes it.
5. **Pause predicate shared with the implement gate** — `grep -rn "pause" lib/judgment-gate.sh bin/consult tests/*.sh` → 0. Build 2's `gate implement` (`bin/consult:328`, `lib/judgment-gate.sh`) has no pause-aware predicate to reuse.
6. **File-derived inspect** — `bin/consult help | grep -c inspect` → 0; `find . -name "inspect-pack*"` → 0. Closest file-derived precedents: `consult gate <client> status` emits JSON derived from `judgment/` files (`bin/consult:328`, `lib/judgment-gate.sh` — verified live: `{"client":…,"mode":"Guided","decision":"refused",…}` for onboarding-flight-control), and `consult bench <client>` derives history from `runs/iter-*/scores.json` (`bin/consult:490`, `cmd_bench`). Neither combines mode+gates+scores+escalations+lessons+next-action, and neither emits explicit missing markers.
7. **MEMORY override seam** — `grep -rn "CONSULT_MEMORY_FILE" bin/ lib/ tests/` → 0 matches. Memory is read from `$ROOT/MEMORY.md` only (`cmd_memory`, `bin/consult:485-488`); no env override exists for isolated real tests, so a Build 3 resume test writing the MEMORY pointer would touch the org memory unless the seam is added.

## Honest baseline verdict (pre-implementation)

| Pointer | Baseline status | Evidence |
|---------|----------------|----------|
| 1 Durable escalations | **FAIL** | escalations are free prose in `MEMORY.md` §Escalations (awaiting owner) and run report/panel text (probe 2); no `escalations.json`, no block-until-resolved, no recorded options+token (probe 1, 3) |
| 2 Pause / authorized resume | **FAIL** | no `pause.json` or `authorize-resume.json`; no resume that removes the pause, updates machine state (`progress.json`), or writes the MEMORY pointer; no pause-aware predicate for the implement gate (probe 4, 5, 7) |
| 3 File-derived `consult inspect` | **FAIL** | no `consult inspect` verb and no `inspect-pack.json` (probe 1, 6); the file-derived JSON precedent (`gate status`) and history derivation (`bench`) cover only judgment and scores, not the full mode+gates+scores+escalations+lessons+next-action pack, and nothing emits explicit missing markers |

## Verdict

Current state is honestly: escalations are tracked as owner-facing prose in
`MEMORY.md`; `progress.json` records build status and a text `next_action`; `consult
gate <client> status` proves the repo can derive machine JSON from plain files, and
`consult bench` proves history derivation from `scores.json`. But there is no
escalation lifecycle, no pause/resume with authorization, and no file-derived inspect
pack. All three Build 3 pointers therefore FAIL at baseline. This is the
pre-implementation state Build 3 must close; Build 4 (role-envelope inspection) is
not specified and is untouched.
