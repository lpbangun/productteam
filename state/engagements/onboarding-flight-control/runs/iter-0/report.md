# iter-0 baseline report — onboarding-flight-control

**Date:** 2026-08-06 · **Kind:** baseline · **Mode:** Guided · **Contract:** ofc-v1

## Mission (selected)

Improve OFC on eight ofc-v1 dimensions without changing product vision
(fictional local-only People Ops demo).

## Subagents

| Role | Conclusion |
|------|------------|
| Repository Analyst | No README/tests; Maya lock-in; App monolith; build passes pre-scaffold |
| Product Specialists | Critical: persona lock-in; High: status/signal divergence, reasonless board pills |
| Benchmark Designer | Froze ofc-v1 (8 dims, target 9.0, max 5 iters) |
| Test Engineer | Vitest suite: 11 pass / 4 fail at baseline |

## Baseline scores (overall **5.8**)

| Dimension | Score | Evidence |
|-----------|-------|----------|
| onboarding-quality | 7.0 | maya flow + handoffs + derive seed pass; generic transitions fail |
| workflow-clarity | 4.5 | override path OK; consistency + board pills + demo script fail |
| usability | 2.0→* | build broken by test scaffold until tsconfig exclude |
| maintainability | 4.0 | App.tsx 1417 lines; no architecture notes |
| documentation | 2.0 | no README |
| developer-experience | 4.0 | `"latest"` deps; no README scripts |
| product-clarity | 7.5 | UI honest; README non-goals missing |
| simplicity | 7.5 | overdueNote dead field |

\* Scaffold completion: exclude `*.test.ts` from `tsconfig.json` so
`npm run build` measures product code only. Product behavior unchanged.

## Known failing objective checks

domain-transitions-generic, status-signal-consistency,
board-pills-require-reason, no-dead-seed-fields, all README checks,
deps-pinned, app-not-monolith, architecture-notes.

## No product implementation yet

Baseline frozen. Implementation begins iter-1.
