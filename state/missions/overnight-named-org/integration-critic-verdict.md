# Integration Critic Verdict — overnight-named-org
Status: **ACCEPT-WITH-NITS**
Date: 2026-08-11

## Spot-check summary

| Check | Result | Evidence |
|-------|--------|----------|
| Builds 1–5 critic gates | PASS | All five `build-N-critic-verdict.md` are **ACCEPT-WITH-NITS** (Build 1 must-fix landed) |
| Key libs + doc exist | PASS | `lib/agent-cards.sh`, `style-memory.sh`, `experience-pool.sh`, `direction-gate.sh`, `run-loop.sh`, `docs/overnight-loop.md` |
| Named cards in rehearsal | PASS | Kai (`selection.json`, `proposals.json`), Meridian (`analyst-request.json`, proposals team), Vesper (`critic-rebuttal.json`); Scout in `specialist.json` |
| Style + project memory loaded | PASS | `inspect-pack.json` → `style.missing=false`, taste includes rehearsal line; `project_memory.missing=false` |
| Experience pool ids | PASS | `analyst-request.json` → `experience_pool_ids`; inspect pack `index_count=2`, retrieved entries cited |
| Guided selection path | PASS | `selection.json` → `proposal_id=d1`, `display_name=Kai`; `critic-rebuttal.json` → Vesper `ACCEPT-WITH-NITS`; gate `bound_direction` set |
| Loop completed + resume | PASS | `loop-progress.json` → `status=completed`, `stop_reason=max-iters`, `iter=3`; `run.log` → SIGTERM pause → `--resume` → three iters |
| No always-on daemon | PASS | `run-loop.sh` bounded CLI; `docs/overnight-loop.md` cron/systemd **oneshot** wake only |
| No DB | PASS | jq + plain files across all five libs; pool grep/path retrieve only |
| No GEA code evolution | PASS | `experience-pool.sh` header: narrative excerpts only, no agent-code evolution |
| No sixth subsystem | PASS | Four permanent cards + optional ephemeral Scout specialist; no fifth invokable worker |

## Findings (ordered by severity)

None blocking.

### Nits (non-blocking)
1. **Integration loop was dry-run/no-provider** — rehearsal proves inspect → gate → pause → resume → max-iters, but not a headed iter with live provider score/close under loop orchestration (deferred honestly in `INTEGRATION-REHEARSAL.md`).
2. **Guided score/close transcript still composite** — Build 4 nit persists: direction-path smoke + rehearsal stop before Analyst stamp → bench → Critic envelope → `role close` in one overnight client transcript.
3. **Root README cross-link** — overnight recipe lives in `docs/overnight-loop.md` only; operators may miss it (Build 5 nit #2).
4. **Card slice git hygiene** — Build 1 card assets may remain untracked until owner commits (non-gate).
5. **Smoke coverage debt** — accept-lesson, seal-experience close, Vesper display_name assertion, default-close pool unchanged: quality gaps, not integration blockers.

## Org self-review

The overnight-named-org mission stayed within the four permanent workers plus ephemeral specialist pattern: each build added a thin, file-backed layer that composes existing seams (cards → style/memory → pool → direction gate → run-loop) instead of spawning a second orchestrator or resident daemon. Principal orchestration friction is low — critic verdicts per build were consistent, must-fixes (specialist show, machine-clean `direction list --json`) landed before integration, and the rehearsal archive gives inspectable cross-slice evidence. Remaining holes are operational polish (README link, untracked card seeds, smoke gaps for accept-lesson/seal-experience/Vesper assertion) and one honest deferral: live provider score/close under loop wake was not exercised tonight. No benchmark self-grading bias observed in build gates; integration spot-check confirms artifact-level naming and guardrails without a sixth subsystem.

## Gate for mission close

**OPEN** — mission may close as **Done**. Recommended follow-ups (owner discretion): one headed Guided iter with provider + manual Builder seal under `run-loop`; root README link to `docs/overnight-loop.md`; commit card slice when ready.
