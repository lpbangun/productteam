# iter-1 report — onboarding-flight-control

**Date:** 2026-08-06 · **Kind:** iteration · **Mode:** Guided · **Contract:** ofc-v1

## Debate (pre-implementation)

**Principal proposed:** Docs + pin deps → domain status/signal + generic transitions
→ reason-required board overrides → App.tsx modularization → hire selector.

**Critic:** Accept all; each maps to frozen checks. Rejected: real AI/backend
(vision break). Rejected weakening tests. Overruled none.

## Implementation (diff summary)

Client branch `consult/engagement-2026-08-06` (uncommitted until owner asks):

| Change | Why |
|--------|-----|
| `README.md` | documentation, DX, product-clarity, demo walkthrough |
| Pin `package.json` deps + `engines.node` | developer-experience |
| `deriveSupport` awaiting-meeting path | workflow-clarity / onboarding-quality |
| Generic schedule/confirm transitions | onboarding-quality |
| Remove `overdueNote` | simplicity |
| `StatusReasonDialog` for board pills | workflow-clarity |
| Extract components; App.tsx 1417→572 | maintainability |
| Hire selector for 6 personas | product-clarity / usability |

`git diff --stat`: −999 / +232 on tracked files; new README, components/, tests.

## Verification (real commands)

```
npm test   → 15/15 passed (exit 0)
npm run build → exit 0
bin/consult checks onboarding-flight-control → 40/40 pass, overall 9.5
bin/consult smoke → all pass (after harness fixes)
```

## Scores (audited)

Overall **5.8 → 9.5**. All eight dimensions **9.5** (5/5 objective checks each).
Independent Verifier: **ACCEPT** / **CONVERGED**. No void scores.

## Independent Verifier

- Re-ran `npm test`, `npm run build`, `run-checks.sh` — exit 0.
- Spot-checked App.tsx lines, README sections, pinned deps, deriveSupport,
  reason dialog, hire selector.
- Remaining critical/high defects: **none**.
- Caveat: ensure `.checks-latest.json` refreshed with scored iteration (done).

## Harness Critic (org)

Auto-applied: contract-aware bench header, ofc-only checks guard, `.gitignore`
for clients node_modules/dist, smoke asserts ofc-v1 label, MEMORY entry,
iter-1 report. Escalated: multi-contract check router; whether `clients/`
lives in harness tree.

## Lessons

- Deterministic `consult checks` as primary scorer avoids LLM re-score drift.
- Measurement scaffold (vitest) must exclude `*.test.ts` from app `tsc` or
  baseline build-green falsely fails.
- Extracting UI while keeping contract grep targets in `App.tsx` requires
  deliberate copy placement (AI disclaimer, STATUS_META).

## Org self-review

Temporary specialists (Analyst, Benchmark Designer, Test Engineer, Product
Specialists, Implementation, Verifier, Harness Critic) delivered a one-iteration
lift without new permanent workers. Right-sized.
