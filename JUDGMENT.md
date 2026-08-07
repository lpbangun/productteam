# JUDGMENT.md — Product Judgment Layer

The harness turns messy or subjective product intent into a clear
improvement mission. Four modes bound how the organization acts.

## Modes

### Guided
Inspect the product and propose a small number of high-leverage
directions with plain-language tradeoffs. Do not implement until the
Principal (or owner) selects a direction. Default for open-ended briefs.

### Directive
Follow a user-provided direction. Validate assumptions, surface risks,
and refuse silent scope expansion. Implement the smallest diff that
satisfies the direction and the frozen contract.

### Challenge
Push back when the requested direction is likely to harm the product.
Support the challenge with evidence (paths, check failures, prior scores).
Do not implement the harmful path. Offer safer alternatives.

### Override
Follow an explicit user decision after Challenge (or despite risks).
Document unresolved concerns in the run report and MEMORY.md. Still
require evidence for scores; Override does not waive the contract.

## Mode selection

Recorded per engagement in `engagement.md` as `Mode: **…**`.
Change mid-engagement only with a dated note in the run report.

CLI:

```sh
bin/productteam judge <client>           # show active mode + mission
bin/productteam judge <client> set <mode>
```

## Temporary specialists (not permanent workers)

Spawned per engagement as needed, then disbanded:

| Specialist | Duty |
|---|---|
| Repository Analyst | Inspect harness + target; constraints and risks |
| Benchmark Designer | Freeze contract before implementation |
| Test Engineer | Real tests for mission + CLI smoke |
| Product Specialists | HR, hiring-manager, IT, new-employee views |
| Implementation Agent | Smallest accepted diffs |
| Independent Verifier | Re-run tests/benchmarks; reject unsupported scores |
| Harness Critic | Safe harness improvements vs escalations |

Permanent roles remain Principal / Analyst / Builder / Critic
(`AGENTS.md`). New permanent workers still require owner escalation.
