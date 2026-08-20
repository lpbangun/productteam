# ProductTeam

**A CLI-first product judgment and improvement loop for coding agents.**

ProductTeam turns an existing software repository and an open-ended
product brief into a bounded, measurable engagement. It coordinates distinct
Analyst, Builder, and Critic roles; freezes the benchmark before implementation;
runs work in an isolated Git worktree; and records decisions, scores, evidence,
and lessons as plain files.

The project now includes a role-aware chat experience, an optional Textual
cockpit, guided direction selection, durable judgment gates, named agent cards,
organizational and project memory, cross-engagement experience reuse, and a
bounded overnight loop.

> **Project status:** active development. The CLI contract and state artifacts
> are designed to be inspectable, but interfaces may continue to evolve.

## Why this exists

Coding agents are good at producing changes, but a useful product-improvement
process also needs to decide **what should change**, preserve the product's
vision, measure whether the change helped, and retain what was learned.

ProductTeam supplies that missing judgment layer:

- **Evidence before claims** — benchmark scores cite artifacts and paths.
- **Frozen goals** — the benchmark contract is fixed before implementation.
- **Separated roles** — the Principal orchestrates; the Analyst scores; the
  Builder implements; the Critic challenges priorities and reviews outcomes.
- **Durable decisions** — modes, gates, escalations, role receipts, and history
  survive between sessions as Markdown and JSON.
- **Safe client isolation** — checks and agent runs use detached Git worktrees,
  not the client's active working tree.
- **Bounded autonomy** — owner decisions, risk gates, iteration limits, and
  stop conditions constrain unattended work.

## What it is not

This is not an IDE, a general-purpose agent framework, or a client-product
redesign tool. There is no daemon, application server, or database. The CLI is
the interface and plain files under `state/` are the source of truth.

## Requirements

Core CLI:

- Bash 4+
- Git
- `jq`
- Standard Unix tools (`awk`, `sed`, `grep`, `sha256sum`, `timeout`)
- An authenticated coding-agent CLI for provider-backed work

The harness detects supported coding-agent CLIs from `PATH` and from optional
paths in `CONSULT_AGENT_DIRS`. Run `bin/productteam agents` to see what is
available. No API key is stored by the harness.

Optional TUI:

- Python 3.10+
- `venv`
- Dependencies pinned in `lib/tui/requirements.txt`

## Installation

Clone the repository and run the CLI directly:

```sh
git clone https://github.com/lpbangun/productteam.git
cd productteam
bin/productteam help
bin/productteam runtime --check
```

`bin/consult` remains available as a compatibility alias for
`bin/productteam`.

### Optional Textual cockpit

The standard `chat` interface has no Python dependency. To enable the optional
full-screen TUI:

```sh
python3 -m venv lib/tui/.venv
lib/tui/.venv/bin/pip install -r lib/tui/requirements.txt
bin/productteam tui
```

Both `chat` and `tui` require an interactive terminal. The TUI is a presentation
client over the same command registry; `bin/productteam` remains the only domain
and durable-state writer.

## Quick start

### 1. Run onboarding

```sh
bin/productteam onboarding --yes
bin/productteam agents
```

### 2. Open an engagement

Client repositories live beside the harness, not inside it. Use an absolute
path:

```sh
bin/productteam open my-product \
  --repo /absolute/path/to/my-product \
  --mode Guided \
  --scorer checks \
  --mission "Improve onboarding without changing the product vision."
```

This creates the engagement, freezes its initial benchmark contract, and
prepares an isolated worktree under `tmp/workspaces/my-product`.

Use `--scorer checks` when the engagement has deterministic checks configured,
or `--scorer provider` for provider-based evaluation.

### 3. Establish the baseline

```sh
bin/productteam baseline my-product
bin/productteam bench my-product
```

A provider-scored baseline requires an Analyst role invocation first; the CLI
will refuse and print the required command rather than inventing a score.

### 4. Select a direction and run the loop

In the default **Guided** mode, implementation cannot begin until a direction
is proposed, selected, and reviewed by the Critic:

```sh
bin/productteam direction my-product propose \
  --title "Reduce onboarding friction" \
  --tradeoffs "Narrow scope; preserve the existing information architecture" \
  --lift "Expected usability and product-clarity improvement" \
  --evidence docs/onboarding-review.md

bin/productteam direction my-product list
bin/productteam gate my-product select d1 owner
bin/productteam gate my-product status
```

Then use individual role and scoring commands, the interactive chat, or the
bounded loop driver:

```sh
bin/productteam chat
# or
bin/productteam run-loop my-product --max-hours 6 --max-iters 5 --resume
```

See [docs/overnight-loop.md](docs/overnight-loop.md) before scheduling an
unattended run.

## How an engagement works

```text
Inspect → Benchmark → Prioritize → Debate → Implement → Test
        → Re-benchmark → Critique → Memory → Org improvement
```

1. **Inspect** — the Analyst examines the client repository with file-level
   evidence.
2. **Benchmark** — the frozen contract records the baseline and target.
3. **Prioritize and debate** — the Principal ranks work by expected lift; the
   Critic rebuts each proposed item.
4. **Implement** — the Builder receives sealed input and makes the smallest
   accepted change.
5. **Verify** — real checks run in the engagement's isolated worktree.
6. **Re-benchmark** — the Analyst publishes iteration-bound scores.
7. **Critique and remember** — the Critic reviews the diff, scores, and
   organization; reports and lessons remain on disk.

Convergence means every contract dimension reaches its target with evidence,
or the engagement records an honest non-convergence report.

## Product Judgment modes

| Mode | Behavior |
|---|---|
| **Guided** | Propose a small set of high-leverage directions; wait for selection and Critic rebuttal before implementation. |
| **Directive** | Follow the owner's direction, document risks, and prevent silent scope expansion. |
| **Challenge** | Refuse a harmful path with evidence and offer a safer alternative. |
| **Override** | Follow an explicit owner decision while preserving Critic, evidence, and frozen-contract requirements. |

The active mode is recorded in each engagement's `engagement.md`. See
[JUDGMENT.md](JUDGMENT.md) for the complete policy and gate requirements.

## Interfaces

### Human interfaces

```sh
bin/productteam              # engagement overview
bin/productteam chat         # role-aware interactive session
bin/productteam tui          # optional Textual cockpit
bin/productteam report NAME  # latest iteration reasoning
bin/productteam bench NAME   # benchmark history and latest scores
```

The chat and TUI derive their commands from the same registry. Commands that
mutate owner-gated state remain intentionally unavailable inside a chat
session and explain why they must be run directly.

### Core engagement commands

| Command | Purpose |
|---|---|
| `open <client> --repo <absolute-path>` | Create an engagement, freeze its contract, and prepare a workspace. |
| `baseline <client>` | Record iteration zero using the declared scorer. |
| `inspect <client>` | Regenerate a file-derived inspection pack. |
| `judge <client> [set <mode>]` | Show or select the Product Judgment mode. |
| `direction <client> propose\|list\|clear\|rebut` | Manage Guided direction proposals and Critic review. |
| `gate <client> …` | Record and evaluate durable implementation decisions. |
| `workspace <client> ensure\|status\|remove` | Manage the isolated client worktree. |
| `role <client> seal\|invoke\|status\|close` | Run role envelopes and verify authorship receipts. |
| `checks <client>` | Run deterministic checks in the isolated workspace. |
| `score <client> --iter <n>` | Publish an Analyst-stamped score for one iteration. |
| `run-loop <client> --max-hours <n> --max-iters <n>` | Run a bounded, resumable improvement loop. |
| `escalation <client> block\|status\|resume` | Pause work and require explicit owner continuation. |

### Organization and memory

| Command | Purpose |
|---|---|
| `card list\|show\|seed-specialist` | Inspect permanent agent cards or seed a temporary specialist. |
| `style show\|init\|append\|accept-lesson` | Maintain durable organizational taste, risks, stack preferences, and prohibitions. |
| `project-memory show\|append <client>` | Maintain engagement-specific notes. |
| `pool list\|show\|search\|add` | Reuse evidence-backed excerpts across engagements. |
| `skill critique\|benchmark\|design-sprint <target>` | Run a first-party provider-backed product skill. |
| `memory` | Read durable organization-wide lessons. |
| `org` | Show roles, autonomy boundaries, and the operating loop. |

### Complete command surface

```sh
bin/productteam agents                              # coding agents on this device
bin/productteam baseline <client>                   # iter-0 via isolated workspace + checks
bin/productteam bench <client>                      # benchmark history and latest scores
bin/productteam card list|show|seed-specialist      # named agent cards (state/agents/)
bin/productteam chat                                # role-aware interactive session (TTY)
bin/productteam checks <client>                     # deterministic checks in the isolated workspace
bin/productteam direction <client> propose|list|clear|rebut
bin/productteam escalation <client> block|status|resume
bin/productteam gate <client> status|implement|select|direct|challenge|override|rebut
bin/productteam gh preflight|pr-create|status|checks|merge|validate
bin/productteam harness-checks                      # objective harness checks + secrets scan
bin/productteam help [--json]                       # command table; --json emits the registry
bin/productteam inspect <client>                    # regenerate the file-derived inspect pack
bin/productteam judge <client> [set <mode>]
bin/productteam memory                              # durable organization-wide lessons
bin/productteam onboarding [--yes]
bin/productteam open <client> --repo <abs-path> [--mode …] [--scorer …]
bin/productteam org                                 # roles, loop, autonomy
bin/productteam pool list|show|search|add           # experience excerpts (state/experience-pool/)
bin/productteam project-memory show|append <client>
bin/productteam report <client>                     # latest iteration reasoning
bin/productteam role <client> seal|invoke|status|close
bin/productteam run <client> <iter>                 # scores for one iteration
bin/productteam run-loop <client> --max-hours <n> --max-iters <m>
bin/productteam runtime [--check]                   # alias of agents
bin/productteam score <client> --iter <n>           # Analyst-stamped score
bin/productteam skill critique|benchmark|design-sprint <target>
bin/productteam smoke                               # CLI smoke tests
bin/productteam splash [--frames]                   # knowledge-graph banner (CONSULT_NO_SPLASH=1 skips)
bin/productteam status [--json]                     # engagement overview
bin/productteam style show|init|append|accept-lesson|rewrite
bin/productteam tui                                 # optional Textual cockpit
bin/productteam workspace <client> ensure|status|remove
```

Run `bin/productteam help` for the complete command surface or
`bin/productteam help --json` for the machine-readable registry.

## Safety and evidence model

### Isolated workspaces

Checks, scoring, and provider role invocations operate in a detached worktree.
A dirty workspace is refused unless the caller supplies an explicit
`--allow-dirty "reason"`; that reason is stored with the evidence. The client's
live working tree is never used as a silent fallback.

### Durable judgment gates

Implementation permission is derived from mode-specific files under:

```text
state/engagements/<client>/judgment/
```

`gate <client> status` emits the current decision as JSON. In Challenge mode,
the harmful path always remains blocked. In Override mode, the Critic,
evidence, and frozen contract cannot be waived.

### Role and score integrity

Role invocations write request, result, and hash-bound manifest files. Builder
input is sealed by path and SHA-256. Analyst score publication is bound to a
specific iteration, and the same recorded identity cannot be both Builder and
Analyst for that iteration.

### Escalation and recovery

Open escalations pause implementation, checks, and scoring. Resuming requires a
separate owner-authored `authorize-resume.json` with matching identifiers and a
recorded decision; a token alone is not authorization.

## Plain-file state

The important state layout is intentionally inspectable:

```text
state/
  engagements/<client>/
    engagement.md             # brief, mode, and source repository
    contract.json             # frozen benchmark contract and scorer
    workspace.json            # isolated worktree provenance
    judgment/                 # durable mode-specific decisions
    roles/iter-N/             # sealed inputs and role receipts
    runs/iter-N/              # scores, evidence, and reports
    history.jsonl             # append-only score history
    escalations.json          # blocked and resolved owner decisions
    inspect-pack.json         # regenerable projection of current state
  agents/                     # permanent and specialist agent cards
  style/                      # organization preferences and lessons
  experience-pool/            # reusable cross-engagement excerpts
  .cli/                       # local sessions, worker activity, exports
```

For the full data flow and invariants, see
[ARCHITECTURE.md](ARCHITECTURE.md).

## Machine-readable output

The following surfaces emit JSON suitable for automation:

```sh
bin/productteam help --json
bin/productteam status --json
bin/productteam agents --json
bin/productteam gate my-product status
bin/productteam workspace my-product status
bin/productteam role my-product status
bin/productteam direction my-product list --json
```

Plain files remain authoritative; JSON commands are derived views unless their
command explicitly records a decision.

## Configuration

| Variable | Purpose |
|---|---|
| `CONSULT_PROVIDER` | Override the active coding-agent executable. |
| `CONSULT_AGENT_DIRS` | Add `:`-separated directories to provider discovery. |
| `CONSULT_STATE_ROOT` | Relocate CLI-local onboarding and session state. |
| `CONSULT_WORKSPACE_ROOT` | Relocate isolated client worktrees. |
| `CONSULT_NONINTERACTIVE=1` | Apply onboarding without prompts. |
| `CONSULT_NO_SPLASH=1` | Disable the startup splash. |
| `CONSULT_NO_SPINNER=1` | Disable chat spinner frames. |
| `CONSULT_AUTHORIZE_MERGE` | Point to the file authorizing a gated GitHub merge. |
| `NO_COLOR=1` | Disable ANSI color. |

## Testing

Run the core CLI smoke suite:

```sh
bin/productteam smoke
```

Run the broader shell test suite:

```sh
for test in tests/*.sh; do
  printf '\n==> %s\n' "$test"
  bash "$test"
done
```

Some tests exercise real Git worktrees, TTY behavior, or an installed coding
provider. Read the test output rather than treating a skipped external
capability as a pass.

For the optional TUI tests:

```sh
lib/tui/.venv/bin/pip install pytest
lib/tui/.venv/bin/pytest -q lib/tui/tests
```

## Project documentation

- [ARCHITECTURE.md](ARCHITECTURE.md) — layers, state model, and enforcement seams
- [CONSTITUTION.md](CONSTITUTION.md) — principles, autonomy, and definition of done
- [AGENTS.md](AGENTS.md) — permanent roles and collaboration protocol
- [JUDGMENT.md](JUDGMENT.md) — judgment modes and temporary specialists
- [BENCHMARKS.md](BENCHMARKS.md) — benchmark contracts
- [docs/overnight-loop.md](docs/overnight-loop.md) — cron/systemd operation and stop conditions
- [docs/skills.md](docs/skills.md) — first-party provider-backed skills
- [docs/learning-schema.md](docs/learning-schema.md) — learning artifact schema

## Contributing

Issues and focused pull requests are welcome. Before submitting a change:

1. Keep the scope small and explain the product or benchmark lift.
2. Preserve the frozen command and state contracts unless the change explicitly
   updates them.
3. Add or update a deterministic check for behavior changes.
4. Run the relevant smoke tests and include the exact commands and results.
5. Do not commit provider credentials, session exports, local state, virtual
   environments, or generated worktrees.

Architecture, authentication, autonomy-policy, destructive, and client-vision
changes require owner review under [CONSTITUTION.md](CONSTITUTION.md).

## License

A license file has not yet been added to this repository. Until one is
published, copyright law applies by default; do not assume permission to copy,
modify, or redistribute the project.
