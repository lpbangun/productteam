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
bin/productteam onboarding --yes   # agents → provider → engagement → score
bin/productteam splash             # knowledge-graph banner (CONSULT_NO_SPLASH=1 skips)
bin/productteam agents             # detect coding agents (agents|runtime)
bin/productteam runtime --check    # alias of agents; fails if none usable
bin/productteam open <client> --repo /abs/sibling   # engagement stub + freeze + workspace
bin/productteam baseline <client>  # iter-0 via isolated workspace (checks or honest deferred)
bin/productteam                    # status overview (splash once on first run)
```

## Quickstart

```sh
bin/productteam                  # org overview (status)
bin/productteam status           # same overview, named explicitly
bin/productteam help             # command table
bin/productteam chat             # role-aware interactive session
bin/productteam tui              # optional Textual cockpit (TTY presentation client)
bin/productteam onboarding [--yes]
bin/productteam splash [--frames]
bin/productteam agents [--json] [--check]
bin/productteam runtime          # alias of agents
bin/productteam judge <client>   # mode + mission (also: harness-evolution)
bin/productteam gate <client> status|implement|select|direct|challenge|override|rebut
bin/productteam direction <client> propose|list|clear|rebut   # Guided directions (state/engagements/<client>/direction/)
bin/productteam workspace <client> ensure|status|remove
bin/productteam escalation <client> block|status|resume
bin/productteam inspect <client>
bin/productteam role <client> seal|invoke|status|close
bin/productteam card list|show|seed-specialist   # named agent cards (state/agents/)
bin/productteam style show|init|append|accept-lesson|rewrite   # org style memory (state/style/)
bin/productteam project-memory show|append <client>   # per-engagement notes
bin/productteam pool list|show|search|add   # experience excerpts (state/experience-pool/)
bin/productteam score <client> --iter <n>   # Analyst-stamped score
bin/productteam checks <client>  # deterministic contract checks
bin/productteam bench <client>   # scores + history
bin/productteam bench <client> run --iter <n>
bin/productteam run <client> <n> # scores for iteration n
bin/productteam run-loop <client> --max-hours <n> --max-iters <m>   # overnight loop driver
bin/productteam report <client>  # latest iteration reasoning
bin/productteam harness-checks   # harness-apc objective checks + secrets scan
bin/productteam gh preflight     # GitHub auth + permissions (redacted)
bin/productteam gh pr-create|status|checks|merge|validate
bin/productteam memory           # durable lessons
bin/productteam org              # roles + autonomy
bin/productteam smoke            # CLI smoke tests
bin/productteam skill critique|benchmark|design-sprint <target>

# `bin/consult` remains a compatibility shim to `bin/productteam`.
```

## CLI surface (frozen contract `cli-interface-20260812-v3`)

Every top-level command below is named by `productteam help`; `help` is the
canonical command surface. The frozen command table has **33** commands:
**18** chat-supported, **15** intentionally unsupported in chat (each with a
non-empty safety/usefulness reason), plus **6** chat-only verbs (`provider
workers clear export exit quit`). The historical `cli-interface-20260812-v3`
table had **32** commands; `productteam tui` is the additive, optional TTY
frontend added on top of that freeze (it is `chat_supported=0`, so the frozen
32-command contract in `state/harness-evolution/runs/cli-interface-20260812/`
stays untouched).

| Command | Purpose |
|---------|---------|
| `productteam` | Org status overview (same as `status`) |
| `productteam help [--json]` | Command table; `--json` emits the command registry |
| `productteam status [--json]` | Org overview; `--json` emits the engagement list |
| `productteam chat` | Role-aware interactive session (TTY only) |
| `productteam tui` | Optional Textual cockpit (TTY presentation client; `productteam chat` remains the fallback, and `chat` never launches the TUI) |
| `productteam onboarding [--yes]` | First-run: agents → provider → engagement → score |
| `productteam splash [--frames]` | Knowledge-graph banner (`CONSULT_NO_SPLASH=1` skips) |
| `productteam agents [--json] [--check]` | Coding agents on this device; provider availability |
| `productteam runtime [--check]` | Alias of `agents`; `--check` fails if none usable |
| `productteam judge <client> [set <mode>]` | Judgment mode + mission |
| `productteam open <client> --repo <abs-path>` | Cold engagement stub + freeze stamp + workspace |
| `productteam baseline <client>` | iter-0 bootstrap via workspace + checks/score |
| `productteam gate <client> status\|implement\|select\|direct\|challenge\|override\|rebut` | Durable judgment decisions + machine status |
| `productteam direction <client> propose\|list\|clear\|rebut` | Guided direction proposals + Critic rebuttal |
| `productteam workspace <client> ensure\|status\|remove` | Isolated client worktree lifecycle |
| `productteam escalation <client> block\|status\|resume` | Durable owner block and authorized continuation |
| `productteam inspect <client> [out]` | Regenerate the file-derived inspect pack |
| `productteam role <client> seal\|invoke\|status\|close` | Single-turn roles, sealed input, authorship gates |
| `productteam card list\|show\|seed-specialist` | Named agent cards (`state/agents/`) |
| `productteam style show\|init\|append\|accept-lesson\|rewrite` | Org style memory (`state/style/`) |
| `productteam project-memory show\|append <client>` | Per-engagement notes |
| `productteam pool list\|show\|search\|add` | Cross-engagement experience excerpts |
| `productteam score <client> --iter <n>` | Score via the declared scorer + Analyst stamp |
| `productteam checks <client>` | Deterministic checks in the isolated workspace |
| `productteam bench <client> [run --iter <n>]` | Benchmark contract + history + latest scores |
| `productteam run <client> <n>` | Show scores for iteration n |
| `productteam run-loop <client> --max-hours <n> --max-iters <m>` | Overnight loop driver |
| `productteam report <client>` | Latest iteration report |
| `productteam harness-checks [iter-dir]` | Objective harness-apc checks + secrets scan |
| `productteam gh preflight\|pr-create\|status\|checks\|merge\|validate` | Gated GitHub (no `--admin`) |
| `productteam skill <name> <target>` | Run a skill (`/critique|/benchmark|/design-sprint`) |
| `productteam memory` | Organizational memory |
| `productteam org` | Roles, loop, autonomy |
| `productteam smoke` | CLI smoke tests |

`score <client> --iter <n>` and `bench <client> run --iter <n>` are the only
score entrypoints; a missing `--iter` is a usage error. `bench`/`run` render
only **contract-shaped** score records (a `.scores` object plus a numeric
`.overall`); a null or summary-shaped `runs/iter-N/scores.json` is skipped
with a note when a newer contract-shaped run exists, and otherwise fails
honestly (never a raw jq traceback, never a silently substituted iteration).

### Machine-readable boundaries

All machine surfaces below are **derived, read-mostly views over plain files
under `state/` — the files remain authoritative**; every surface emits valid
JSON unless noted, parseable with `jq -e .`.

| Surface | Command / path | Shape and authority |
|---------|----------------|---------------------|
| Command registry | `productteam help --json` | `{commands:[{name,usage,chat_supported,chat_reason?}], chat_only:[…]}` — 33 commands, 6 chat-only verbs; drives help text, dispatch validation, slash palette, unsupported reasons |
| Engagement list | `productteam status --json` | `{engagements:[{client,…}], …}` — engagement list / current selection, derived from `state/engagements/` |
| Agent detection | `productteam agents --json` | array of `{name,status,path,version,note}` from `lib/provider.sh` catalog (PATH then `CONSULT_AGENT_DIRS`) |
| Provider availability | `productteam agents` / `productteam runtime --check` | honest absence: `runtime --check` exits non-zero with a remedy when no agent is usable |
| Inspect pack | `productteam inspect <client>` | regenerates `state/engagements/<client>/inspect-pack.json` from engagement files: mode/gate, scores + `history.jsonl`, escalation/pause, lessons, continuation, `next_suggested_action`; missing sources are explicit `missing:true` |
| Worker activity | `state/.cli/runs/session-<pid>/workers.tsv` | TSV `id role state mission provider start elapsed artifact`; file-backed telemetry (`lib/activity.sh`), atomic temp+rename, never a supervisor |
| Judgment gate | `productteam gate <client> status` | JSON `{client,mode,allowed,decision,reason,bound_direction,artifact,artifact_ts,…}` derived from `judgment/` files; always exits 0 |
| Workspace | `productteam workspace <client> status` | JSON `{client,source_repo,path,sha,exists,dirty,allow_dirty_reason}` derived from engagement `workspace.json` + live worktree |
| Role envelope | `productteam role <client> status [iter]` | JSON `{client,iter,root,asked,ran,produced,missing}` derived from `roles/iter-N/<Role>/attempt-N/` files; byte-stable |

Provider: authenticated Cursor `agent` CLI by default (`CONSULT_PROVIDER` to swap).
Detected agents: `bin/productteam agents`. No API keys. No mocks — skills call the
real provider seam (`lib/provider.sh`).
In chat, `/agents` shows installed/missing/selected providers, `/provider`
cycles the installed catalog, and `/workers` shows the file-backed activity
log under `state/.cli/runs/`. Prompt chrome keeps the Product Judgment mode
and engagement score trend visible; slash prefixes show matching commands.
Provider turns state that execution is blocking and Ctrl+C preserves any
partial artifact. `/export` writes the timestamped markdown transcript under
the state/.cli/sessions/ directory.

`productteam tui` is the optional Textual presentation client: it derives its
slash palette from the live registry, runs every chat-supported verb as argv
against `bin/productteam`, refuses unsupported verbs with the registry reason,
and keeps the same session verbs (`/provider`, `/workers`, `/clear`, `/export`,
`/exit`). It requires a TTY and stays read-only — `bin/productteam` remains the
sole domain, judgment, workspace, provider, and durable-state writer.
`productteam chat` remains the fallback interactive session, and `chat` never
launches the TUI.

GitHub: `bin/productteam gh …` wraps `gh` with gates — **never** `--admin` /
force-merge. Merge requires `state/harness-evolution/authorize-merge` (or
`CONSULT_AUTHORIZE_MERGE`).

Learning artifacts: `docs/learning-schema.md` · harness evolution under
`state/harness-evolution/` (locked contract `harness-apc-v1`).

## Environment variables

| Variable | Purpose |
|----------|---------|
| `CONSULT_PROVIDER` | Override the active coding-agent binary |
| `CONSULT_STATE_ROOT` | Relocate CLI first-run / onboarding state (default `state/.cli`) |
| `CONSULT_NONINTERACTIVE` | `1` makes `productteam onboarding` write (same as `--yes`) |
| `CONSULT_NO_SPLASH` | `1` skips the splash banner entirely |
| `CONSULT_NO_SPINNER` | `1` disables chat spinner frames; provider execution and completion cards remain |
| `CONSULT_SPLASH_DUMP` / `CONSULT_SPLASH_FRAMES=all` | Dump every splash frame as text |
| `CONSULT_AGENT_DIRS` | Extra `:`-separated dirs scanned after `PATH` for agents |
| `CONSULT_AUTHORIZE_MERGE` | Path to authorize-merge file for `gh merge` |
| `CONSULT_PR_TITLE` / `CONSULT_PR_BODY` / `CONSULT_PR_BRANCH` | PR create overrides |
| `CONSULT_ROOT` | Set by the CLI to the harness root (exported for child scripts) |
| `CONSULT_SMOKE_SKIP_CLIENT` | Skip sibling-client checks inside smoke |
| `NO_COLOR` | Disable ANSI accents |
## Isolated client workspaces

`score`, `checks`, and provider benchmark runs never use the `Repo:` working
tree directly. They ensure a detached worktree under
`tmp/workspaces/<client>` and persist its source/path/SHA in the engagement's
`workspace.json`. `workspace status` emits live machine-readable JSON;
`workspace remove` removes only a clean worktree.

A dirty isolated worktree refuses scoring/checks with
`workspace-dirty: <client>`. The only reuse escape is explicit and recorded:
`--allow-dirty '<reason>'`. Each provider score stores `workspace.json` beside
its scores; each deterministic check stores the same path/SHA/dirty evidence
in a unique `runs/check-*/workspace.json`. The live owner tree is never the
fallback. `CONSULT_WORKSPACE_ROOT` may relocate worktrees without changing the
plain-file metadata seam.

`ensure` reuses the existing detached checkout; it does not reset it to a newer
source `HEAD`. To refresh, remove the clean workspace and ensure it again.
Recovery is automatic and non-destructive: if the recorded `workspace.json`
path no longer exists, `ensure` recreates it at the canonical current
workspace (pruning only stale git registrations whose working tree is gone);
a recorded path that still exists — e.g. a foreign worktree from another
harness instance — is left byte-identical and the metadata is repointed to
the canonical workspace. Existing, dirty, or foreign worktrees are never
deleted, relocated, reset, or overwritten.

## Product Judgment modes

| Mode | Behavior |
|------|----------|
| **Guided** | Propose high-leverage directions with tradeoffs |
| **Directive** | Follow a user direction; validate risks |
| **Challenge** | Push back with evidence when harm is likely |
| **Override** | Follow an explicit decision; document concerns |

Full text: `JUDGMENT.md`.

## Judgment gates

The four modes bind implementation through **durable files** under the
engagement: `state/engagements/<client>/judgment/` (selection, directive,
challenge, override). `productteam gate <client> …` is the read-mostly gate:

```sh
productteam gate <client> status                                   # machine JSON
productteam gate <client> implement [<direction>]                  # allow/refuse
productteam gate <client> select <direction> [selected-by]         # Guided or Challenge safer alternative
productteam gate <client> direct <direction> [risk...]             # Directive only
productteam gate <client> challenge <harmful> <safer> <evidence>   # Challenge only
productteam gate <client> override <direction> <risk> <critic-record> <evidence-record>
```

The current `Mode:` line in `engagement.md` is the sole authority: each verb
works only in its mode, stale files from other modes are ignored, and a
missing/unknown mode refuses. `implement` without an argument uses the mode's
bound direction (Guided/Directive/Override `.direction`; Challenge
`.safer_alternative`); an explicit direction must equal the bound one.

| Mode | Implement requires | Refuses |
|------|--------------------|---------|
| Guided | `judgment/selection.json` with non-empty `direction` + `selected_by` | no selection yet; wrong direction |
| Directive | `judgment/directive.json` with `direction` + `decision` (`risks` may be empty) | no durable directive |
| Challenge | `judgment/challenge.json` (`harmful`, `safer_alternative`, `evidence`) **and** `selection.json` matching the safer alternative | the challenged harmful path always; incomplete challenge |
| Override | `judgment/override.json`: exact direction, non-empty `risks`, `critic_record`, `evidence_record`, and `non_waivers.{critic,evidence,frozen_contract}=true` | empty risks; missing/false non-waivers |

Writers persist `mode`, `ts`, and the decision atomically (tmp + rename).
`status` emits valid JSON (`client`, `mode`, `allowed`, `decision`, `reason`,
`bound_direction`, `artifact`, `artifact_ts`, plus required/present data) and
always exits 0 — a later session re-derives the same decision from the files
alone. Override **never waives the contract**: the non-waiver booleans are
required and there is no waiver channel. Builder role invocation consumes this
same read-only `implement` predicate after pause and seal checks.

## Escalations and file-state continuation

```sh
productteam escalation <client> block <id> <summary> <option> [option...]
productteam escalation <client> status
productteam escalation <client> resume <id> <resume-token>
productteam inspect <client>
```

`block` writes one entry in engagement `escalations.json` and an active
`pause.json`. The same predicate then refuses `checks`, provider scoring, and
`gate … implement`, naming the blocking files. Options and the resume token are
durable; the token correlates state but is not authorization.

The owner must manually create `authorize-resume.json`; the CLI never creates
it:

```json
{"id":"owner-1","token":"<resume-token>","authorized_by":"owner","decision":"selected option"}
```

`resume` requires exact id/token matching and non-empty owner/decision fields.
It marks the escalation resolved, stamps pause resumed and authorization
consumed, writes `continuation.json`, and appends a pointer to `MEMORY.md`.
Tests relocate only the MEMORY target with `CONSULT_MEMORY_FILE`.

`inspect` regenerates `inspect-pack.json` from engagement files: mode/gate,
scores and `history.jsonl`, escalation/pause state, latest lessons pointer,
continuation, and `next_suggested_action`. Missing sources are explicit
`missing:true` objects plus entries in `missing`; the pack never fills gaps from
chat.

## Role envelopes and authorship gates

```sh
productteam role <client> seal <iter> <builder-input-file>
productteam role <client> invoke Analyst <iter> '<single-turn task>'
productteam role <client> invoke Builder <iter>
productteam role <client> invoke Critic <iter> '<single-turn task>'
productteam role <client> status [iter]
productteam role <client> close <iter>
productteam score <client> --iter <n>
```

Each invoke is one `provider_ask` call in the isolated client worktree. It
writes an atomic `request.json`, `result.json`, and hash-indexed `manifest.json`
under `roles/iter-N/<Role>/attempt-N/`, including honest failure envelopes.
`status` reads only those files and returns byte-stable `asked`, `ran`,
`produced`, and `missing` arrays; it never reads chat or live process state.

Builder input is write-once per iteration. `seal` records the input file path
and SHA-256; Builder re-hashes and reads those exact bytes, refusing missing or
changed input before the provider call. It also composes the active pause and
judgment gates. The seal proves input integrity, not identity or authorization.

A successful Analyst envelope writes `Analyst/stamp.json`, bound to its result
hash and `CONSULT_ROLE_IDENTITY` (default `analyst`). Provider score publication
requires `--iter N` and that exact iteration's valid stamp. Score and close
refuse when the successful Builder identity equals the Analyst identity. Close
also requires a successful Critic envelope, then writes `roles/iter-N/close.json`.
The same authenticated provider may execute each role; role identity, not the
provider binary name, enforces separation.

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
| `bin/productteam` | CLI |
| `lib/theme.sh` | Role chrome + semantic badges (ANSI literals stay in `bin/productteam`) |
| `lib/render.sh` | Markdown-lite replies and evidence/delta highlighting |
| `lib/activity.sh` | File-backed worker activity + bounded loading spinner |
| `lib/repl.sh` | Interactive chat, judgment/score chrome, slash hints, interrupt-safe artifacts, transcript export |
| `lib/provider.sh` | Provider detection, session cycling, and ask seam |
| `lib/onboarding.sh` | First-run onboarding |
| `lib/github.sh` | Gated PR/merge/validate helpers (no `--admin`) |
| `lib/workspace.sh` | Isolated worktree lifecycle, dirty gate, provenance |
| `lib/judgment-gate.sh` | Durable per-mode judgment gates + machine status |
| `lib/engagement-state.sh` | Escalation pause/resume + file-derived inspect |
| `lib/role-envelope.sh` | Sealed single-turn roles + authorship gates |
| `lib/agent-cards.sh` | Named agent cards (markdown + json under state/agents/) |
| `state/agents/` | Permanent role cards + specialist template |
| `lib/run-checks.sh` | Deterministic checks (`scorer=checks`) |
| `lib/harness-checks.sh` | Harness-apc objective checks + secrets scan |
| `lib/harness-cli-checks.sh` | harness-cli-v1 check suite |
| `lib/run-skill.sh` | Skills via real `provider_ask` |
| `tests/consult-smoke.sh` | CLI smoke |
| `tests/workspace-smoke.sh` | Real-worktree isolation refusal/pass probe |
| `tests/judgment-gate-smoke.sh` | Real-CLI judgment gate refuse/pass probe |
| `tests/escalation-smoke.sh` | Real block/authorize/resume/inspect probe |
| `tests/role-envelope-smoke.sh` | Real-provider seal/envelope/authorship probe |
| `tests/agent-cards-smoke.sh` | Agent card list/show/seed + envelope display_name |
| `state/` | Engagements, scores, history, and plain-file CLI sessions |
| `state/harness-evolution/` | APC self-improvement (locked `harness-apc-v1`) |

Client products live as **sibling repos**; each brief has `Repo: /absolute/path`
and `contract.json` declares `scorer: checks|provider`. Use `productteam score`.

## Principles

Delete before adding. Evidence over opinion. Never move the goalposts.
Client vision is a constraint. Full text in `CONSTITUTION.md`.
