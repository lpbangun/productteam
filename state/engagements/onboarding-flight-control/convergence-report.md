# Convergence report — onboarding-flight-control

**Status:** CONVERGED · **Date:** 2026-08-06 · **Contract:** ofc-v1 · **Iterations:** 1
(improvement) after baseline iter-0 · **Mode:** Guided

## Why convergence is claimed

All frozen ofc-v1 convergence conditions hold on iter-1:

| Condition | Evidence |
|-----------|----------|
| Every dimension ≥ 9.0 | All eight at **9.5** in `runs/iter-1/scores.json` |
| Scores have evidence | Each cites `5/5 checks pass`; full snapshot in `checks.json` |
| Required tests pass | `npm test` 15/15; CLI `bin/consult smoke` pass |
| Independent Verifier confirms | ACCEPT / CONVERGED (re-ran tests, build, checks) |
| No unresolved critical/high | Persona lock-in, status divergence, reasonless pills resolved |
| No material regression | Overall 5.8 → 9.5; build still green |

Scores are **check-derived**, not Principal self-grades. Band rule: all five
objective checks pass → 9.5 per dimension (`lib/run-checks.sh`).

## Benchmark history

| Iter | Kind | Overall | ≥9 |
|------|------|---------|-----|
| 0 | baseline | 5.8 | 1 |
| 1 | iteration | 9.5 | 8 |

## Worktree / PR

Client changes live on branch `consult/engagement-2026-08-06` under
`clients/onboarding-flight-control` (uncommitted). Owner may review and
request commit/PR to https://github.com/lpbangun/onboarding-flight-control.

## Escalations

- ~~Multi-contract check router~~ → resolved 2026-08-06: `scorer` field + `consult score`
- ~~`clients/` layout~~ → resolved 2026-08-06: sibling repos only
  (`/home/logani/projects/onboarding-flight-control`)
