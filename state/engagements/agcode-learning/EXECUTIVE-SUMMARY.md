# Executive summary — first engagement

**Client:** AgCode Learning (lpbangun/agcode-learning)
**Engagement:** 2026-08-05, one session · **Contract:** v1 (frozen, never amended)

## Headline

A local-first learning product with excellent pedagogy but no entry
point, a cluttered root, and stale decision records was brought from
**6.0 to 8.3 overall** across three improvement iterations, with three
areas (correctness 9.3, educational-quality 9.0, product-clarity 9.0)
at or above the ≥9 target. The owner's vision and pedagogy were never
touched. The remaining gap is owned by **two owner decisions**, named
explicitly below — the org did not paper over them.

## What the org did

- Carried the owner's uncommitted SKILL.md refinement forward as the
  branch's first commit (GitHub was behind owner intent).
- Separated product surface from a 15-file research corpus (`research/`).
- Wrote the missing README: identity, quickstart, file map, research
  inventory, non-goals, link contract, coaching-moment example.
- Closed staleness and contradictions (PLAN status, TypeScript
  decision, check.ts example, capstone exception, link counts,
  machine-bound `file://` hrefs).
- Changed **no** product behavior, pedagogy, or frozen research content
  (href-only maintenance where links were touched).

## How it was measured

Frozen 9-area contract; independent 3-judge panels per run (strict /
fresh-eyes / skeptic) with file-path evidence required; medians;
tiebreak re-scoring when spread >2; Critic audit for self-grading bias
before acceptance. Baseline never re-scored. Full bundles under
`runs/iter-0…3/`.

## The org improved itself (every iteration)

- Debate cut 2 weak items and added 2 missing ones (round-1 link,
  seed-copy sentence).
- A late Critic audit in iter-1 became audit-before-acceptance from
  iter-2; iter-2's scores were corrected −0.2 for optimism.
- Two CLI bugs found in live use were fixed the same iteration.
- The provider seam was proven end-to-end (`consult bench <client> run`),
  so a future session can re-score without this one.
- No permanent workers were added; Builder stayed dormant (right-sized).

## Owner decisions required (the only path to full green)

1. **Skill data path** — keep documented status quo, make clones
   self-contained, or add a per-harness override (recommendation in
   MEMORY.md). Unblocks DX, usability, maintainability, architecture.
2. **License** — MIT recommended; your rights decision.

## Deliverables

- Client branch + PR: `consult/engagement-2026-08-05` on
  lpbangun/agcode-learning.
- This engagement record: brief, contract.json, backlog,
  history.jsonl, runs/iter-0…3 (scores, panels, reports),
  convergence-report.md.
- Harness: README/CONSTITUTION/AGENTS/ARCHITECTURE/MEMORY/BENCHMARKS
  + `bin/consult` CLI, committed in the harness repo.
