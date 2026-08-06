# Iter-1 report — Foundation (Critic-accepted scope)

**Mode:** Directive (state/harness-evolution/engagement.md)  
**Builder:** Principal session implementing Critic-narrowed list  
**Contract:** harness-apc-v1 (lock unmodified)

## Debate outcome

Critic CUT `consult evolve` and `consult learn`; NARROWED runtime into
`lib/provider.sh`; REORDERED secrets into Iter 1; REORDERED judgment
examples into Iter 1. Accepted four deliverables — all shipped.

## Diff summary

| Change | Why |
|--------|-----|
| `lib/provider.sh` | runtime_detect / runtime_default / honest provider refusal |
| `bin/consult` | `runtime`, `harness-checks`; status shows provider |
| `lib/harness-checks.sh` | objective harness-apc checks + secrets scan |
| `docs/learning-schema.md` | learning artifact schema |
| `state/harness-evolution/engagement.md` | Mode + mission |
| `examples/challenge-refusal.md` + `override-risks.md` | judgment artifacts |
| `tests/consult-smoke.sh` | runtime + schema coverage; remove hanging provider invoke |
| README + ARCHITECTURE | document shipped surface only |

## Verification

- `CONSULT_SMOKE_SKIP_CLIENT=1 bin/consult smoke` → all PASS
- `bin/consult harness-checks …/iter-1` → 11 passed · 0 failed
- Lock hashes unchanged (see evidence/lock-hashes-pre.txt vs post)

## Expected lifts

runtime-routing, memory-learning, testing-evidence, product-judgment,
safety-discipline, cli-onboarding (minor). github-integration and
product-skills deferred to later iters per Critic.

## Org self-review
Roles stayed at four permanents. No new verbs beyond Critic-accepted seams.
Evidence: this run directory + harness-checks.
