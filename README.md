# Product Consulting Harness

A Product Judgment Layer that turns messy product intent into a clear
improvement mission, executes it, measures the result, and retains what
it learns. The CLI is the interface; judgment lives in modes, evidence,
and a frozen benchmark contract.

## Quickstart

```sh
bin/consult                  # org overview
bin/consult judge <client>   # mode + mission
bin/consult checks <client>  # deterministic contract checks
bin/consult bench <client>   # scores + history
bin/consult report <client>  # latest iteration reasoning
bin/consult memory           # durable lessons
bin/consult org              # roles + autonomy
bin/consult smoke            # CLI smoke tests
```

Provider: authenticated Cursor `agent` CLI by default (`CONSULT_PROVIDER` to swap).
No API keys. No mocks.

## Product Judgment modes

| Mode | Behavior |
|------|----------|
| **Guided** | Propose high-leverage directions with tradeoffs |
| **Directive** | Follow a user direction; validate risks |
| **Challenge** | Push back with evidence when harm is likely |
| **Override** | Follow an explicit decision; document concerns |

Full text: `JUDGMENT.md`.

## How an engagement runs

1. Brief + mode in `state/engagements/<client>/engagement.md`
2. Freeze `contract.json` + engagement `BENCHMARK-CONTRACT.md` before changes
3. Build measurement tests; record iter-0 baseline
4. Loop (max 5 iterations unless converged earlier):

   Inspect → Measure → Prioritize → Implement → Real tests →
   Re-benchmark → Independently verify → Critique → Memory →
   Safe harness improvements

5. Convergence: every dimension ≥ 9.0 with evidence, verifier OK,
   no unresolved critical/high defects, no material regression.

## Layout

| Path | Purpose |
|------|---------|
| `CONSTITUTION.md` | Principles, autonomy, escalation |
| `AGENTS.md` | Permanent roles |
| `JUDGMENT.md` | Product Judgment modes + temporary specialists |
| `BENCHMARKS.md` | Harness-wide contract v1 (prior engagements) |
| `MEMORY.md` | Durable organizational memory |
| `bin/consult` | CLI |
| `lib/provider.sh` | Cursor `agent` provider seam |
| `lib/run-checks.sh` | Deterministic checks (`scorer=checks`) |
| `tests/consult-smoke.sh` | CLI smoke |
| `state/` | Engagements, scores, history |

Client products live as **sibling repos**; each brief has `Repo: /absolute/path`
and `contract.json` declares `scorer: checks|provider`. Use `consult score`.

## Principles

Delete before adding. Evidence over opinion. Never move the goalposts.
Client vision is a constraint. Full text in `CONSTITUTION.md`.
