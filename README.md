# Product Consulting Harness

An autonomous consulting organization that improves software — and itself.

This is not a dashboard, a workflow builder, or a coding agent. The CLI is
only the interface. The product is the organization: role-defined workers,
a frozen benchmark contract, durable memory, and an improvement loop that
critiques its own org chart after every iteration.

## Quickstart

```sh
bin/consult status             # org overview, engagements, convergence
bin/consult scores <client>    # benchmark history vs the frozen contract
bin/consult report <client>    # latest iteration report (evidence bundle)
bin/consult memory             # organizational memory
bin/consult org                # org self-evaluation log
bin/consult checks <client>    # deterministic checks (evidence, not vibes)
```

## How an engagement runs

1. A **brief** fixes the client, its vision, and constraints (`state/engagements/<client>/brief.md`).
2. A **Benchmark Contract** is frozen before any implementation (`BENCHMARKS.md`).
3. The loop runs until every dimension scores ≥9/10 with evidence, or 10 iterations:

   `Inspect → Benchmark → Prioritize → Debate → Implement → Test → Re-benchmark → Critique → Record memory → Improve the org`

4. Every iteration leaves an evidence bundle: scores, reasoning, changes,
   lessons, and an evaluation of the organization itself.

## Layout

| Path | Purpose |
|---|---|
| `CONSTITUTION.md` | Principles, autonomy policy, escalation rules |
| `AGENTS.md` | The organization: roles, spawn rules, critique protocol |
| `ARCHITECTURE.md` | Runtime, state layout, provider adapter, CLI surface |
| `BENCHMARKS.md` | The frozen benchmark contract — never move the goalposts |
| `MEMORY.md` | Durable organizational memory across runs |
| `bin/consult` | The CLI (bash, zero dependencies) |
| `state/` | Engagements, iterations, benchmark history |

## Principles

Delete before adding. Every abstraction, dependency, worker, command,
prompt, or layer must produce measurable benefit — or it goes.
Evidence over opinion. The client's vision is a constraint, not an
input to redesign. Full text in `CONSTITUTION.md`.
