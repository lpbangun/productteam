# Baseline notes — Build 4 role envelope: role invoke + status, sealed Builder input, request/result/manifest evidence, authorship close/score gates

Captured: 2026-08-10, working tree `upgrade-basic-funcionalities`, HEAD `1f6f17e`.
Scope: Build 4 baseline only (mission iteration 1 of 3, Build 4 =
role-envelope-inspection per `progress.json`). No product code touched. This file
complements the Build 1 baseline (`evidence/baseline-notes.md`), the Build 2 baseline
(`evidence/build-2-baseline.md`), and the Build 3 baseline
(`evidence/build-3-baseline.md`) and is cited by `mission-benchmark.md` §8.3.

## Frozen guard (unchanged from Builds 1–3)

`state/harness-evolution/HARNESS-BENCHMARK-CONTRACT.md`, `contract.json`, `LOCK.md`,
`FREEZE.md`, `FREEZE-SHA.txt`, `engagement.md`, `LOOP-SEQUENCE.md`, `authorize-merge`,
and `runs/iter-0/…iter-5/` remain untouched. Build 1–3 verdicts and evidence
(`mission-benchmark.md` §2–§7, `evidence/advisor-verdict.json`, `critic-verdict.md`,
`evidence/build-2-advisor-verdict.json`, `build-2-critic-verdict.md`,
`evidence/build-3-advisor-verdict.json`, `build-3-critic-verdict.md`) are not
re-scored or amended. `state/harness-evolution/judgment/` is Build 2's own durable
gate state and is not touched by Build 4. This baseline records only what Build 4
adds on top.

## Suite state at baseline (Builds 1–3 closed, Build 4 not started)

| Suite | Command | Exit | Artifact |
|-------|---------|------|----------|
| CLI smoke | `bin/consult smoke` | 0 | `evidence/acceptance-build-3-smoke.txt` (Build 3 run) |
| Harness checks | `bin/consult harness-checks state/harness-evolution/runs/iter-6` | 0 | `checks.json`: 42 passed · 0 failed (`evidence/acceptance-build-3-harness-checks.txt`) |

Neither suite exercises any Build 4 pointer: the 42 check ids cover workspace
isolation (Build 1), judgment-gate refuse/pass paths (Build 2), escalation
block/pause/resume + inspect-pack regeneration (Build 3), plus the frozen-contract
objective subset — none invoke a role, read a seal, or enforce an
Analyst-stamp/Critic-close authorship gate.

## Probe commands (baseline gap inventory, run 2026-08-10 from repo root)

All probes are re-runnable; findings feed `mission-benchmark.md` §8.3.

1. **Role invoke/status verbs in CLI** — `bin/consult help | grep -icE "role invoke|role-invoke|envelope|request|manifest"` → 0.
   `bin/consult role analyst invoke 'x'` → `error: unknown command 'role' — try: consult help`.
   No `role)`/`invoke)` dispatch branch: `grep -cE '^[[:space:]]+(invoke|role)\)' bin/consult` → 0.
   `bin/consult help` lists `org` ("Roles, loop, autonomy") — role *prose* only, no role execution verb.
2. **Request/result/manifest artifacts** — `find . -path ./.git -prune -o \( -name request.json -o -name result.json -o -name manifest.json \) -print` → 0 files;
   `find state/engagements -type d -name roles` → 0 dirs.
   No per-role envelope directory or artifact exists anywhere in `state/`.
3. **Seal concept (immutable per-iteration Builder input)** — `grep -rni "seal" bin/ lib/ tests/` → 0 matches.
   No seal write, no Builder-without-seal refusal, no hash-pinned Builder input exists.
4. **Analyst stamp (score authorship)** — `grep -rni "stamp" bin/ lib/ tests/` → 5 matches, all escalation/timestamp
   mechanics, none an analyst authorship stamp (`lib/engagement-state.sh:7,42,196` resume stamps,
   `lib/engagement-state.sh:214` comment, `lib/judgment-gate.sh:103` "timestamp" text).
   `scores.json` carries an optional `evaluator` string (`state/harness-evolution/runs/iter-5/scores.json`:
   `"evaluator":"independent-analyst"`; `state/engagements/agcode-learning/runs/iter-2/scores.json`:
   `"evaluator":null`) — a free-text field, not a stamp: nothing requires it, nothing invalidates scores when absent,
   and nothing checks that the scorer is not the implementer.
5. **Close gate (Critic-required, implementer ≠ evaluator)** — `bin/consult help | grep -ci close` → 0;
   `grep -rniE "close.*gate|closeout" bin/consult lib/*.sh` → 0.
   Critic verdicts exist only as free files (`critic-verdict.md`, `build-2-critic-verdict.md`,
   `build-3-critic-verdict.md`) with no CLI gate refusing a close until a Critic verdict artifact is present,
   and no authorship comparison between implementer and evaluator.
6. **Provider seam (exists, authenticated, reused by Build 4)** — `lib/provider.sh` provides the single model
   entry point: `provider_ask` (definition `lib/provider.sh:47`; sole callsite `bin/consult:664` in
   `cmd_bench_run`), plus `runtime_detect`/`runtime_default` and the `CONSULT_PROVIDER` swap.
   Real authenticated runtime is present: `bin/consult runtime` shows `agent`
   (`/home/logani/.local/bin/agent`, active) plus `claude`, `codex`, `opencode`, `cursor` found; `gemini` missing.
   The seam itself is green (`run_check provider-seam`, `lib/harness-checks.sh:221`) — what is absent is any
   role-envelope invocation over it. No mock provider exists or is permitted.
7. **Chat-log evidence / daemon-bus machinery** — `find state -iname "*chat*" -o -iname "*transcript*"` → 0;
   `grep -rniE "daemon|message bus|swarm|auto-orchestrat" bin/ lib/ tests/` → 0.
   No database, plugin router, or RAG exists (Build 1 constraint, unchanged).
8. **File-derived status precedent** — `state/harness-evolution/inspect-pack.json` (Build 3) keys:
   `client, continuation, escalations, gate, history, lessons, missing, mode, next_suggested_action, pause, scores` —
   a regenerable pack derived entirely from files, with explicit `missing` markers and no chat logs. This is the
   closest precedent for Build 4 pointer 5 (file-derived role status), but it covers no role
   ask/run/produce envelope.
9. **Build 4 seam note (existing)** — `mission-benchmark.md` §6.1 records that "Build 4's Builder invocation calls
   the same implement gate" (`consult gate <client> implement`, Build 2 surface); `progress.json` names Build 4
   `role-envelope-inspection` with `next_action` "Inspect Build 4 role envelope and authorship gates from files."

## Honest baseline verdict (pre-implementation)

| Pointer | Baseline status | Evidence |
|---------|----------------|----------|
| 1 Role invoke + status over the existing provider seam | **FAIL** | provider seam exists and is authenticated (probe 6) but no `consult role … invoke`/`status` verb and no dispatch branch (probe 1); the only model call is the hard-coded Analyst bench prompt (`bin/consult:664`) |
| 2 Per-iteration sealed Builder input | **FAIL** | zero "seal" references in bin/lib/tests (probe 3); no write-once seal, no Builder-without-seal refusal |
| 3 Request/result/manifest evidence | **FAIL** | 0 `request.json`/`result.json`/`manifest.json` files and 0 role dirs anywhere (probe 2); worker output exists only as `raw-provider-output.txt` on provider failure and `scores.json` on success — no envelope with role/provider/ts/exit/hashes |
| 4 Close/score authorship gates | **FAIL** | no Analyst stamp (probe 4); `evaluator` is optional free text; no close verb, no Critic-required close gate, no implementer≠evaluator rejection (probe 5) |
| 5 File-derived status without chat logs | **FAIL** | inspect-pack proves the file-derived pattern (probe 8) but answers no role asked/ran/produced; there is no role status at all (probe 1), and no harness checks cover the envelope lifecycle (suite state) |

## Verdict

Current state is honestly: `lib/provider.sh` is a real, authenticated single model
seam with exactly one callsite; `inspect-pack.json` proves the repo can derive
machine JSON from plain files with explicit missing markers and zero chat logs;
`judgment/` and `escalations.json`/`pause.json` prove durable gate/state files
with atomic writers. But there is no role invocation verb, no sealed Builder
input, no request/result/manifest envelope, no Analyst stamp gating scores, no
Critic-required close gate, and no role status. All five Build 4 pointers
therefore FAIL at baseline. This is the pre-implementation state Build 4 must
close; Builds 1–3 evidence and the frozen `harness-apc-v1` contract are
untouched.
