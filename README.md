# Product Consulting Harness

A Product Judgment Layer that turns messy product intent into a clear
improvement mission, executes it, measures the result, and retains what
it learns. The **CLI** is the interface; judgment lives in modes, evidence,
and a frozen benchmark contract.

## Non-goals

Not an IDE. Not a client-product redesign. Not a chat UI. There is no
daemon, no server, and no database — state is plain files under `state/`.

## First run

```sh
bin/consult onboarding --yes   # agents → provider → engagement → score
bin/consult splash             # knowledge-graph banner (CONSULT_NO_SPLASH=1 skips)
bin/consult agents             # detect coding agents (agents|runtime)
bin/consult runtime --check    # alias of agents; fails if none usable
bin/consult                    # status overview (splash once on first run)
```

## Quickstart

```sh
bin/consult                  # org overview (status)
bin/consult status           # same overview, named explicitly
bin/consult help             # command table
bin/consult onboarding [--yes]
bin/consult splash [--frames]
bin/consult agents [--json] [--check]
bin/consult runtime          # alias of agents
bin/consult judge <client>   # mode + mission (also: harness-evolution)
bin/consult score <client>   # score via engagement scorer
bin/consult checks <client>  # deterministic contract checks
bin/consult bench <client>   # scores + history
bin/consult bench <client> run  # provider scoring (scorer=provider only)
bin/consult run <client> <n> # scores for iteration n
bin/consult report <client>  # latest iteration reasoning
bin/consult harness-checks   # harness-apc objective checks + secrets scan
bin/consult gh preflight     # GitHub auth + permissions (redacted)
bin/consult gh pr-create|status|checks|merge|validate
bin/consult memory           # durable lessons
bin/consult org              # roles + autonomy
bin/consult smoke            # CLI smoke tests
bin/consult skill critique|benchmark|design-sprint <target>
```

Provider: authenticated Cursor `agent` CLI by default (`CONSULT_PROVIDER` to swap).
Detected agents: `bin/consult agents`. No API keys. No mocks — skills call the
real provider seam (`lib/provider.sh`).

GitHub: `bin/consult gh …` wraps `gh` with gates — **never** `--admin` /
force-merge. Merge requires `state/harness-evolution/authorize-merge` (or
`CONSULT_AUTHORIZE_MERGE`).

Learning artifacts: `docs/learning-schema.md` · harness evolution under
`state/harness-evolution/` (locked contract `harness-apc-v1`).

## Environment variables

| Variable | Purpose |
|----------|---------|
| `CONSULT_PROVIDER` | Override the active coding-agent binary |
| `CONSULT_STATE_ROOT` | Relocate CLI first-run / onboarding state (default `state/.cli`) |
| `CONSULT_NONINTERACTIVE` | `1` makes `consult onboarding` write (same as `--yes`) |
| `CONSULT_NO_SPLASH` | `1` skips the splash banner entirely |
| `CONSULT_SPLASH_DUMP` / `CONSULT_SPLASH_FRAMES=all` | Dump every splash frame as text |
| `CONSULT_AGENT_DIRS` | Extra `:`-separated dirs scanned after `PATH` for agents |
| `CONSULT_AUTHORIZE_MERGE` | Path to authorize-merge file for `gh merge` |
| `CONSULT_PR_TITLE` / `CONSULT_PR_BODY` / `CONSULT_PR_BRANCH` | PR create overrides |
| `CONSULT_ROOT` | Set by the CLI to the harness root (exported for child scripts) |
| `CONSULT_SMOKE_SKIP_CLIENT` | Skip sibling-client checks inside smoke |
| `NO_COLOR` | Disable ANSI accents |

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
| `docs/learning-schema.md` | Harness-evolution learning artifact schema |
| `docs/skills.md` | First-party skills (live provider calls) |
| `bin/consult` | CLI |
| `lib/theme.sh` | Empty defaults for batch runners (ANSI lives in `bin/consult`) |
| `lib/provider.sh` | Provider + agent detection seam |
| `lib/splash.sh` | Knowledge-graph splash |
| `lib/onboarding.sh` | First-run onboarding |
| `lib/github.sh` | Gated PR/merge/validate helpers (no `--admin`) |
| `lib/run-checks.sh` | Deterministic checks (`scorer=checks`) |
| `lib/harness-checks.sh` | Harness-apc objective checks + secrets scan |
| `lib/harness-cli-checks.sh` | harness-cli-v1 check suite |
| `lib/run-skill.sh` | Skills via real `provider_ask` |
| `tests/consult-smoke.sh` | CLI smoke |
| `state/` | Engagements, scores, history |
| `state/harness-evolution/` | APC self-improvement (locked `harness-apc-v1`) |

Client products live as **sibling repos**; each brief has `Repo: /absolute/path`
and `contract.json` declares `scorer: checks|provider`. Use `consult score`.

## Principles

Delete before adding. Evidence over opinion. Never move the goalposts.
Client vision is a constraint. Full text in `CONSTITUTION.md`.
