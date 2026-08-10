# ARCHITECTURE.md

## Shape

Three layers, each replaceable at its seam:

```
┌──────────────────────────────────────────────┐
│ CLI (bin/productteam)          — inspect, run    │
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
    engagement.md      # brief: vision, constraints, Repo: sibling path
    contract.json      # frozen contract + scorer (checks|provider)
    history.jsonl      # one line per scored run
    runs/iter-N/
      scores.json      # {dimension: {score, evidence}}
      report.md        # reasoning, debate, diff, lessons, org review
  .cli/
    runs/session-*/    # worker TSV, transcript source, provider artifacts
    sessions/*.md      # user-exported chat transcripts
```

Client product repos are **siblings**, not nested under the harness.
`engagement.md` points at them with an absolute `Repo:` path.

`history.jsonl` line format:

```json
{"ts":"…","iter":0,"kind":"baseline","scores":{"correctness":6.2,"…":0},"overall":6.2,"run":"runs/iter-0"}
```

## Scoring seam

Each engagement declares how it is scored in `contract.json`:

| `scorer` | Command | Mechanism |
|----------|---------|-----------|
| `checks` | `productteam score` → `productteam checks` | Deterministic `lib/run-checks.sh` |
| `provider` | `productteam score` → `productteam bench run` | LLM via `lib/provider.sh` |

Wrong path refuses honestly. No plugin router — add a third scorer
only with evidence of need (Constitution).

## Provider seam

One module, swappable (`lib/provider.sh`):

- `AGENT_CATALOG` — single list of known coding agents (≥10)
- `runtime_detect` / `productteam agents [--json]` — PATH then `CONSULT_AGENT_DIRS`
- `runtime_default` / `provider_ask` — real LLM calls; honest refusal if missing
- `runtime_cycle` — advances through installed catalog entries for one chat session

Default provider is the authenticated Cursor `agent` CLI — no API keys, no
mocks. Set `CONSULT_PROVIDER` to swap. `productteam agents --check` (alias:
`productteam runtime --check`) exits non-zero when the active provider is missing.

## CLI chrome + first run

- `lib/theme.sh` — structural role tags + semantic badges; ANSI literals remain
  centralized in `bin/productteam` with bold/dim and two accent hues
- `lib/render.sh` — markdown-lite replies plus signed evidence-path rendering
- `lib/activity.sh` — telemetry-only TSV below `state/.cli/runs/` in a
  `session-*/workers.tsv` path; no daemon or worker supervisor
- `lib/repl.sh` — persistent Judgment/score chrome, live slash-prefix hints,
  interrupt-safe provider artifacts, turn separators, and markdown `/export`
- `lib/onboarding.sh` — `productteam onboarding --yes`; state under `CONSULT_STATE_ROOT`

`CONSULT_NO_SPINNER=1` suppresses spinner frames without changing the real
provider call, activity transitions, completion card, or reply.

## Harness self-checks

`bin/productteam harness-checks` runs `lib/harness-checks.sh` — an objective
subset for `harness-apc-v1` (smoke, runtime-detect, lock presence/hashes,
secrets scan, judgment examples, github seam). Client OFC checks stay in
`lib/run-checks.sh` and are never mixed in. Engagement-local runners are
named by `contract.json` `.checks_runner` (e.g. `lib/harness-cli-checks.sh`).

## GitHub seam

`lib/github.sh` + `bin/productteam gh …`:

| Subcommand | Behavior |
|------------|----------|
| `preflight` | Auth + permissions; tokens redacted |
| `pr-create` | Push + `gh pr create` |
| `status` / `checks` | PR view / checks JSON |
| `merge` | **Refuses** without authorize-merge file; never `--admin` |
| `validate` | Post-merge/PR validation artifact |

Authorize file default: `state/harness-evolution/authorize-merge`.

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

Convergence: every contract dimension ≥ 9.0, or a non-convergence report
after `max_iterations` from that engagement's `contract.json`.

## What does NOT exist (and why)

- No database — jsonl + markdown are inspectable and diffable.
- No daemon/server — the org runs when invoked, memory is files.
- No plugin system — provider + scorer fields are the extension points.
- No nested `clients/` tree — product repos stay siblings.
- No config file — one env var (`CONSULT_PROVIDER`), documented here.
- No second runtime module — detection lives in `lib/provider.sh`.

Each absence is deliberate; adding any of these requires evidence per
the Constitution.
