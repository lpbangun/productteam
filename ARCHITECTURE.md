# ARCHITECTURE.md

## Shape

Three layers, each replaceable at its seam:

```
┌──────────────────────────────────────────────┐
│ CLI (bin/consult)          — inspect, run    │
├──────────────────────────────────────────────┤
│ Org loop (AGENTS.md roles) — judge, decide   │
├──────────────────────────────────────────────┤
│ State (state/, *.md)       — memory, history │
└──────────────────────────────────────────────┘
```

The CLI is a viewer and launcher. Judgment lives in the workers.
All durable state is plain text so any future runtime can continue.

## State layout

```
state/
  engagements/<client>/
    engagement.md      # brief: vision, constraints, repo path
    contract.json      # frozen benchmark contract (copy of BENCHMARKS.md v1)
    history.jsonl      # one line per scored run (the benchmark history)
    runs/iter-N/
      scores.json      # {area: {score, evidence}}
      report.md        # reasoning, debate, diff, lessons, org review
```

`history.jsonl` line format:

```json
{"ts":"…","iter":0,"kind":"baseline","scores":{"correctness":6.2,"…":0},"overall":6.2,"run":"runs/iter-0"}
```

## Provider seam

One function, swappable:

```sh
# lib/provider.sh
provider_ask() {  # $1=prompt  → stdout: model reply
  "${CONSULT_PROVIDER:-claude}" -p "$1" --output-format text
}
```

Default provider is the authenticated `claude` CLI — no API keys, no
mocks. Set `CONSULT_PROVIDER` to any binary that answers a prompt on
stdout to swap providers. Nothing else in the system knows which
provider runs.

## The loop, mechanically

```
Inspect      Analyst reads client repo, lists findings with paths
Benchmark    Analyst scores contract.json → runs/iter-N/scores.json
Prioritize   Principal ranks findings by expected benchmark lift
Debate       Critic rebuts; items need an expected lift to survive
Implement    Builder makes smallest diff per surviving item
Test         verification attached per item (check/test/proof)
Re-bench     Analyst re-scores; history.jsonl appended
Critique     Critic reviews diff + scores + org
Memory       MEMORY.md updated; run report written
Org-improve  low-risk org fixes applied; rest escalated
```

Convergence: every contract area ≥ 9.0, or a non-convergence report
after 10 iterations.

## What does NOT exist (and why)

- No database — jsonl + markdown are inspectable and diffable.
- No daemon/server — the org runs when invoked, memory is files.
- No plugin system — the provider seam is the only extension point.
- No config file — one env var (`CONSULT_PROVIDER`), documented here.

Each absence is deliberate; adding any of these requires evidence per
the Constitution.
