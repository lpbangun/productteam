# Integration rehearsal — overnight named org

Date: 2026-08-11  
Client: `overnight-rehearsal`  
Status: **PASS**

## Scope exercised

| Slice | Result | Evidence |
|-------|--------|----------|
| 1 Named cards | PASS | `rehearsal/specialist.json` (Scout); Kai/Meridian/Forge/Vesper via `card list` |
| 2 Style + project memory | PASS | `rehearsal/inspect-pack.json` → `style.missing=false`, taste contains rehearsal line; `project_memory.missing=false` |
| 3 Experience pool | PASS | inspect pack retrieves prior seeds (`index_count≥1`) |
| 4 Guided path | PASS | propose → select `d1` → Vesper `ACCEPT-WITH-NITS` → Builder seal cites bound direction |
| 5 Overnight loop | PASS | SIGTERM mid-run → `--resume` → `completed` / `max-iters` (iter=3); no auto-created seal |

## Named artifacts

- Analyst envelope: Meridian + `style_missing=false` + `experience_pool_ids` — `rehearsal/analyst-request.json`
- Selection: Kai + `proposal_id=d1` — `rehearsal/selection.json`
- Critic rebuttal: Vesper — `rehearsal/critic-rebuttal.json`
- Loop: `rehearsal/loop-progress.json`, `rehearsal/run.log`

## Fixes landed during rehearsal

1. `direction list --json` now emits **machine-clean JSON only** (no human banner) — was breaking select-by-id scripting.
2. `gate select` refuses blank direction after write.

## Critic gates (builds 1–5)

All five: **ACCEPT-WITH-NITS** (must-fixes for Build 1 specialist show + Build 4 JSON list applied). See sibling `build-N-critic-verdict.md`.

## Out of scope (honest)

- No live provider multi-hour score/close transcript tonight (dry-run + refusal envelopes used).
- No cron/systemd live VPS wake — recipe only: `docs/overnight-loop.md`.
- Pre-existing `consult-smoke` OFC `workspace-metadata-mismatch` on `checks` remains unrelated.

## Stop

All five Done-when green + integration rehearsal archived. No sixth subsystem.
