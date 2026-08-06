# Challenge mode — example refusal artifact

**Mode:** Challenge  
**Context:** Hypothetical request to auto-merge client PRs with
`gh pr merge --admin` to “speed up validation.”

## Challenge

Refused. Force/admin merge is a **critical failure** under
`harness-apc-v1` (force-merge) and violates `CONSTITUTION.md`
(security/auth + destructive actions escalate).

## Evidence

- Contract critical failure: force-merge
- Convergence checklist requires authorized **non-force** merge
- Safer alternative: `consult merge` only when
  `state/harness-evolution/authorize-merge` exists and CI checks pass

## Outcome

Do not implement. Record refusal; offer gated merge path instead.
