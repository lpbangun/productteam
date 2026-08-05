# iter-1 — First improvement pass

Date: 2026-08-05 · Branch: consult/engagement-2026-08-05
Overall: 6.0 → **8.3** (+2.3) · Areas ≥9: 0 → **3**

## What shipped (4 commits)

1. **Carry forward owner's SKILL.md refinement** — the live working copy
   held an uncommitted, owner-authored SKILL.md polish (intent-first
   rule, condensed portability). Committed unchanged as the base so the
   published repo matches owner intent.
2. **Separate product surface from research corpus** — moved 15
   research/planning artifacts into `research/`; updated the 5
   `index.html` hrefs and re-anchored `01-research-findings.md` sibling
   links for the new depth. Root now holds only the product.
3. **Resolve staleness** — `research/PLAN.md` header changed from
   "v0 — edit me" to a shipped status; language decision recorded as
   resolved (TypeScript, per syllabus.md) with the owner's original note
   preserved. SKILL.md contract rule 4 gained the project-7 teach-back
   exception that syllabus.md declared but the skill omitted.
4. **README.md** — entry point: identity, Stage-0 status framing,
   quickstart, file map, "what this is not", link contract.

## Debate record (Critic)

Critic cut two proposed items — `scripts/verify.sh` (weak justification;
would have baked in the broken path) and an `index.html` identity edit
(frozen research artifact already framed as proposal) — and modified the
README item to carry the Stage-0 framing. Principal accepted all three.

## Score movement (baseline → iter-1)

| Area | 0 | 1 | Δ |
|---|---|---|---|
| correctness | 8.0 | 9.0 | +1.0 |
| simplicity | 6.3 | 8.5 | +2.2 |
| maintainability | 6.0 | 8.0 | +2.0 |
| usability | 4.5 | 8.5 | +4.0 |
| educational-quality | 8.5 | 9.0 | +0.5 |
| developer-experience | 4.5 | 7.5 | +3.0 |
| architecture | 5.5 | 8.0 | +2.5 |
| documentation | 5.0 | 7.5 | +2.5 |
| product-clarity | 6.0 | 9.0 | +3.0 |

## Residual defects (panel consensus)

- Repo data files are a dead copy until the user edits the skill's
  absolute data path — the trap is documented as setup but not flagged
  as a hazard.
- README overclaims "each project verified by its own check.ts" though
  project 7 is the documented exception.
- `research/PLAN.md` §3 still shows a `test_loop.py` (Python) example
  though TypeScript is the resolved language.
- Research corpus not itemized; `advisor-review-round-1.md` orphaned.
- No example of what a coaching moment actually looks like.

## Escalation carried

The absolute data path remains escalated to the owner (product-behavior
change; options 1–3 in MEMORY.md). It is the largest remaining cap on
developer-experience, simplicity, and architecture.

## Memory written

Debate value, move-files link-grep rule, and the escalation options were
recorded in MEMORY.md.
