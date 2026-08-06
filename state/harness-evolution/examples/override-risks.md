# Override mode — example unresolved risks

**Mode:** Override  
**Context:** Owner explicitly directs merging a PR with one flaky
non-blocking lint warning after Challenge.

## Decision

Follow owner Override. Merge remains non-force (`gh pr merge` without
`--admin`). Flaky lint is documented, not silenced by bypass.

## Unresolved risks (recorded, not waived)

1. Flaky lint may hide a real regression on a later commit.
2. Override does not waive the frozen benchmark or secrets gate.
3. Post-merge validation must still re-run tests and archive evidence.

## Evidence rule

Scores still require real command output. Override never moves
`harness-apc-v1` goalposts.
