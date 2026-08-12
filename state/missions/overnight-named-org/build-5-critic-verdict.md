# Build 5 Critic Verdict — Long-running overnight runner
Status: **ACCEPT-WITH-NITS**
Date: 2026-08-11

## Done-when audit
- [x] **Entrypoint `productteam run-loop <client> --max-hours N --max-iters M` using existing seams** — `bin/productteam` `cmd_run_loop` requires both bounds; delegates to `lib/run-loop.sh` `run_loop`; reuses `inspect_write_pack`, `progress_blocked_reason`, `judgment_mode` / `judgment_implement_refusal`, `loop_critic_reject`, `engagement_scorer` + `cmd_checks` / `cmd_bench_run`, `role_close`, `pool_seal_hint` (`lib/run-loop.sh`; smoke: `run-loop-refuse-missing-flags`).
- [x] **Durable progress/heartbeat; resume after kill** — `state/engagements/<client>/loop/progress.json` (phase, iter, pid, stop_reason, no_lift_streak), `heartbeat` timestamp file, append-only `run.log`; SIGTERM/INT trap → `loop_pause_for_signal` writes `status=paused`, `stop_reason=killed-resume-pending`, exit 0; `--resume` reopens from progress (smoke: `run-loop-dry-run-progress`, `run-loop-kill-resume`; archived: `build-5-resume-proof.md` / `build5-proof-614455`).
- [x] **Hard stops: max hours, max iters, open escalation, gate block, no-lift streak, Critic REJECT** — `loop_stop` reasons: `max-hours` (`CONSULT_LOOP_TEST_SECONDS` override for CI), `max-iters` (status `completed`), `escalation` (`progress_blocked_reason`), `gate-block` (`judgment_implement_refusal`), `no-lift` (`loop_update_no_lift` + `CONSULT_NO_LIFT_STREAK`), `critic-reject` (`loop_critic_reject` pre/post role); smoke covers all six (+ missing-flag refuse).
- [x] **File logs only; README recipe for cron/systemd** — no DB; artifacts under `loop/`; `docs/overnight-loop.md` documents cron + systemd oneshot/timer recipes and test override (nit: root `README.md` does not cross-link — see #2).
- [x] **Sustained cycle + resume proof archived** — `state/missions/overnight-named-org/build-5-resume-proof.md` + `build-5-progress-sample.json`: 4-iter dry-run, SIGTERM mid-run, `--resume` → `max-iters` completion.

## Guardrail audit
- [x] **Invoked/cron-woken only — no always-on daemon** — driver is a bounded CLI loop that exits on stop; docs describe cron/systemd **oneshot** wake, not a resident service.
- [x] **Never auto-Implement past judgment gates** — `loop_run_one_iter` calls `judgment_implement_refusal` before role phase; dry-run/no-provider simulates role without `role_invoke`; live path logs *"no auto-Builder (seal+rebuttal required manually)"* and never stamps Builder (smoke: `run-loop-no-auto-builder-seal`, `run-loop-gate-block`).
- [x] **No DB** — jq + plain files only.

## Verification run
| Check | Result |
|-------|--------|
| `bash tests/run-loop-smoke.sh` | **PASS** (11/11) — includes `run-loop-critic-reject` |
| Dry-run never creates Builder seal | **PASS** — `find …/roles -name seal.json` empty after dry-run |
| SIGTERM → pause → `--resume` → complete | **PASS** — `status=paused` / `killed-resume-pending`, log line `resume from iter`, final `max-iters` |
| `tests/consult-smoke.sh` wiring | **PASS** — help lists `run-loop`; aggregate invokes run-loop smoke |
| Archived sustained proof | **PASS** — `build5-proof-614455` transcript + sample progress |
| Docs: `docs/overnight-loop.md` | **PASS** — command, artifacts, hard stops, cron, systemd, CI override |

## Findings (ordered by severity)
None blocking.

### Nits (non-blocking)
1. **Archived proof smoke list stale** — `build-5-resume-proof.md` lists 10 PASS lines; current smoke has 11 (adds `run-loop-critic-reject`). Proof body is still valid; refresh the header table when convenient.
2. **Root README omits overnight link** — cron/systemd recipe lives in `docs/overnight-loop.md` only; done-when “README recipe” is satisfied by that doc but operators starting from root `README.md` may miss it.
3. **No provider overnight integration path** — smoke exercises `--dry-run --no-provider` and gate/refusal seams; a single headed run with `CONSULT_PROVIDER` + manual Builder seal → score → close is deferred to Integration rehearsal (expected).
4. **Resume CLI still requires `--max-hours` / `--max-iters`** — values are read from `progress.json` on `--resume`; flags are redundant on resume (harmless, slightly confusing UX).
5. **Interrupted iter re-run implicit** — kill mid-`loop_run_one_iter` leaves `iter` unchanged; resume re-executes that iteration number. Correct for idempotent inspect/gate phases; worth one line in `docs/overnight-loop.md` if operators expect skip-ahead.
6. **Duplicate-run guard is pid-only** — stale `status=running` with dead pid allows a fresh non-resume start that overwrites progress; acceptable if cron always passes `--resume` after first wake.
7. **Score path without Builder** — non-dry-run may run checks/provider score when role stamps exist from manual work; loop never creates those stamps — consistent with “orchestrator not Builder,” but Integration should confirm operator workflow.

## Org note
Thin file driver — ~325 lines in `lib/run-loop.sh`, no second org brain, no fifth worker. Correctly composes Builds 1–4 seams (gates, envelopes, pool hint, inspect) instead of reimplementing them. Trap-based pause preserves cron resume semantics without a supervisor daemon. Critic REJECT wired as a first-class hard stop closes the adversarial loop for overnight runs.

## Gate for Integration rehearsal
**OPEN** — no must-fix items. Recommended before first live overnight on a real client: (a) refresh `build-5-resume-proof.md` smoke table to 11/11, (b) add one-line link from root `README.md` → `docs/overnight-loop.md`, (c) one Integration transcript: Guided client, manual propose → select → rebut → seal → `run-loop` (no `--dry-run`) for a single iter with provider configured, proving score/close under loop orchestration without auto-Builder, (d) optional doc note on interrupted-iter resume semantics.
