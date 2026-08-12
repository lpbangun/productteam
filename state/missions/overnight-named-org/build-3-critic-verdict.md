# Build 3 Critic Verdict — Experience pool (GEA-lite)
Status: **ACCEPT-WITH-NITS**
Date: 2026-08-11

## Done-when audit
- [x] **Cross-engagement pool of sealed what-worked / what-failed excerpts (not source patches)** — `state/experience-pool/` with `INDEX.jsonl` + `entries/<id>.md`; entry template is `## What worked | ## What failed | ## Context | ## Cite`; committed seeds (`20260811-workspace-checks-restore-1`, `20260811-osint-stop-resume-1`) are narrative excerpts with cite lines, no client source patches.
- [x] **Tag by domain (ideation, implement, scoring, client)** — `pool_valid_domain` enforces the four required domains (+ optional `org`); index rows carry `domain`; `pool list --domain` filters.
- [x] **Retrieve via path/grep/simple rank — no vector DB** — `pool show` (path), `pool search` (grep over index + entry bodies, rank by match count then `ts`), `pool retrieve` (sort by `ts`, domain filter); header comment and implementation confirm no embeddings/vector store.
- [x] **Write at iter close or explicit command** — explicit: `productteam pool add`, `productteam pool add-from-iter`; at close: `productteam role <client> close <iter> --seal-experience --kind … --domain … --title …` (requires all flags).
- [x] **Later engagement inspect/role request can cite an earlier pool entry** — smoke: `pool-smoke-b` inspect pack retrieves `WORKED_ID` sealed from `pool-smoke-a`; live: `onboarding-flight-control/inspect-pack.json` retrieves both seed entries from `harness-cli` and `osint-loop-research` with `cite_line` + `entries/` paths; role invoke writes `experience_pool_ids` on `request.json`.

## Verification run
| Check | Result |
|-------|--------|
| `bash tests/experience-pool-smoke.sh` | **PASS** (11/11) |
| `bash tests/agent-cards-smoke.sh` (Build 1) | **PASS** (6/6) |
| `bash tests/style-memory-smoke.sh` (Build 2) | **PASS** (8/8) |
| `bash tests/consult-smoke.sh` (aggregate) | **1 FAIL** — pre-existing `checks` item; all Build 1–3 feature smokes PASS |
| Guardrail: no vector DB / embeddings | **PASS** — plain files + grep only |
| Guardrail: no client source patches in pool | **PASS** — spot-checked seeds + smoke entries |
| Guardrail: default close does NOT auto-write pool | **PASS** — `role close` without `--seal-experience` calls `pool_seal_hint` only; `pool_add_from_iter` gated behind explicit flag |
| Inspect wiring (`pool_derive_pack`) | **PASS** — `lib/engagement-state.sh` emits `experience_pool` on inspect pack |
| Role wiring (`experience_pool_ids` + prompt block) | **PASS** — `lib/role-envelope.sh` merges ids into `request.json` and prefixes provider prompt |

## Findings (ordered by severity)
None blocking.

### Nits (non-blocking)
1. **Smoke gap: default close no auto-seal** — behavior verified in code + manual probe (close failure leaves pool at 0 files); not asserted in `tests/experience-pool-smoke.sh`.
2. **Smoke gap: `--seal-experience` close path** — implemented and documented in `cmd_role close` usage string; untested end-to-end.
3. **Smoke gap: `pool retrieve` CLI** — function exists; smoke exercises retrieve only via inspect/role, not direct `productteam pool retrieve`.
4. **Retrieve cap = 3** — `pool_retrieve_for_inspect` round-robins domains and stops at three entries total; acceptable for GEA-lite but may drop relevant older entries in a large pool.
5. **Extra domain `org`** — beyond done-when four domains; harmless extension, document if Build 4 tightens taxonomy.
6. **Prompt truncation** — `experience_pool_prompt_block` caps title/cite at 60/80 chars; ids remain on envelope JSON for audit.
7. **Drive-by: `onboarding-flight-control/inspect-pack.json` refreshed** — expected side effect of inspect with shared pool; not a Build 3 defect.

## Org note
Clean additive layer: org-wide pool sits beside org `state/style/` and per-engagement `memory/project.md`. Inspect pack grows without breaking Build 1–2 overlays. Explicit-write posture matches CONSTITUTION evidence rule — close prints seal hint instead of silently archiving lessons. `consult-smoke.sh` now wires the pool smoke alongside style/card smokes.

## Gate for Build 4
**OPEN** — no must-fix items. Optional before Build 4: add smoke lines for (a) default close leaves pool unchanged + prints seal hint on successful close, (b) `--seal-experience` close path, (c) direct `pool retrieve`. Consider whether Build 4 should add `lessons_pointer` / pool cite fields to envelope JSON for machine audit (deferred from Build 2 nit #3).
