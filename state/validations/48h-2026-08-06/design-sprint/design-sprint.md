# Design sprint — 48-hour-contributor-readiness-kit

**Skill:** /design-sprint · **Repo:** /home/logani/projects/48-hour-contributor-readiness-kit · **When:** 20260806T064600Z

## Problem framing
Portfolio reviewers and agents must trust that the kit’s *visible* safeguards match its written non-negotiables. A partial guardrail (“hiring, firing…”) that omits pay/promotion understates the safety boundary stated in `AGENTS.md`.

## Target users
- Portfolio reviewers evaluating humane, evidence-led contributor ops.
- Contributors practicing classification; quality leads viewing fictional cohort patterns.
- Not for: real employment decisions, real personnel data, automatic punitive tooling.

## Product direction
Keep the field-guide learning simulation; make safety copy and test evidence honest and complete.

## Implementation scope
**In:** One guardrail copy fix in `app/ReadinessKit.tsx` + matching assertions in `tests/rendered-html.test.mjs` (and browser flow string if present).
**Out:** New features, vision changes, persistence, analytics, redesign, guide content rewrite.

## Milestones
1. Inspect + lock tailored benchmark (done under `state/validations/48h-2026-08-06/`)
2. Implement bounded safety-honesty fix
3. Real `npm test` + review
4. PR (+ merge only if gates pass)

## Risks
Copy drift vs AGENTS · over-scoping into UX redesign · flaky browser chrome path

## Validation plan
`npm test` in subject repo; archive command tails under validation dir; harness PR/merge gates only.

## Expected impact
- **safety-honesty** ↑ — UI matches AGENTS non-negotiables
- **correctness** held — existing tests still pass with stronger assertion
- **documentation** ↑ — AGENTS ↔ UI ↔ test triangle consistent
- **simplicity** held — smallest diff

## Evidence base
`README.md`, `DESIGN.md`, `AGENTS.md`, `package.json`, `app/ReadinessKit.tsx`, `tests/rendered-html.test.mjs`, `tests/browser-flow.mjs`
