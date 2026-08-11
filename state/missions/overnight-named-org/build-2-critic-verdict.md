# Build 2 Critic Verdict — User/project style memory
Status: **ACCEPT-WITH-NITS**
Date: 2026-08-11

## Done-when audit
- [x] **Append-mostly style file(s)** — `state/style/style.md` (+ `style.json` mirror) with `taste|risk|stack|never` sections; `productteam style append` is append-only; `style rewrite` refuses (with and without `--i-am-owner`).
- [x] **Per-engagement project memory** — `{engagement}/memory/project.md` (+ optional `project.json` pointer); scoped under engagement dir; no writes to `CONSTITUTION.md`, frozen contracts, or benchmark locks.
- [x] **Inspect loads style + lessons into next action + role context** — `inspect_derive_pack` emits `style`, `project_memory`, `lessons`; missing style surfaces in `next_suggested_action` and `missing[]`; `role_invoke` prefixes provider prompt via `style_memory_prompt_block` (style + project + lessons); `request.json` carries `style_pointer`, `style_missing`, `project_memory_pointer`.
- [x] **Style evolution gated** — only `style append`, owner manual edit, or `style accept-lesson` (provenance `source: critic-lesson` in `style.json`); no silent canon rewrite path.
- [x] **Inspect reacts to style/lessons changes; missing style explicit** — smoke: missing→present→append taste updates inspect pack; manual: lessons excerpt appears after `runs/iter-N/lessons.md` write; `style.missing == true` + NSA hint when absent.

## Verification run
| Check | Result |
|-------|--------|
| `bash tests/style-memory-smoke.sh` | **PASS** (8/8) |
| `bash tests/agent-cards-smoke.sh` | **PASS** (6/6) |
| `productteam memory` | **PASS** — prints `MEMORY.md` (org memory unchanged) |
| Guardrail: no DB/RAG | **PASS** — plain files only (`lib/style-memory.sh`) |
| Guardrail: CONSTITUTION untouched | **PASS** — zero references in style-memory layer |

## Findings (ordered by severity)
None blocking.

### Nits (non-blocking)
1. **Smoke gap: `style accept-lesson`** — works manually (appends to `never`, sets `source=critic-lesson`); not covered in `tests/style-memory-smoke.sh`.
2. **Smoke gap: envelope project pointer** — `project_memory_pointer` written to `request.json` but smoke only asserts `style_pointer` / `style_missing`.
3. **Lessons not on envelope JSON** — lessons load into role *prompt* and inspect `.lessons` pack, but not as a `lessons_pointer` field on `request.json` (acceptable if prompt context satisfies done-when; document or add field in Build 3 if machine audit needed).
4. **`style init` double-init refuse** — correct behavior (`style already initialized`) but untested in smoke.
5. **Committed `state/style/style.json`** — `updated: null` (mirror likely pre-sync artifact); harmless; next append/sync will stamp.
6. **`style_memory_request_fields` naming** — local variable `style_missing` shadows homonymous function; works today (smoke PASS) but brittle for future edits.
7. **`consult-smoke.sh` checks** — 1 pre-existing FAIL unrelated to Build 2 (no style-memory references in checks catalog).

## Org note
Clean separation: org `MEMORY.md` (escalation/resume pointers) vs org `state/style/` (taste/risk/stack/never) vs per-engagement `memory/project.md`. Inspect pack grows without breaking Build 1 agent-card overlays. Append-only posture matches CONSTITUTION evidence rule.

## Gate for Build 3
**OPEN** — no must-fix items. Optional before Build 3: add smoke lines for `accept-lesson` + `project_memory_pointer` on envelope (quality, not gate).
