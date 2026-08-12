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
    workspace.json     # isolated worktree source/path/SHA metadata
    judgment/          # durable judgment gates (per current mode)
      selection.json   #   Guided: direction + selected_by + decision + ts
      directive.json   #   Directive: direction + risks + decision + ts
      challenge.json   #   Challenge: harmful + safer_alternative + evidence + decision + ts
      override.json    #   Override: direction + risks + critic_record + evidence_record + non_waivers + decision + ts
    escalations.json   # blocked/resolved entries, options, resume tokens
    pause.json         # active/resumed progress state
    authorize-resume.json # manual owner auth, consumed on resume
    continuation.json  # last authorized continuation pointer
    inspect-pack.json  # regenerable projection; never authoritative state
    roles/iter-N/
      Builder/seal.json # write-once input path + SHA-256
      <Role>/attempt-N/{request,result,manifest}.json
      Analyst/stamp.json # successful result hash + evaluator identity
      close.json        # Analyst/Critic/authorship close receipt
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


Operational client worktrees are detached checkouts under
`tmp/workspaces/<client>` (or `CONSULT_WORKSPACE_ROOT`). They are disposable;
their engagement-local `workspace.json` is the durable pointer a later session
uses to inspect or recreate them.
`history.jsonl` line format:

```json
{"ts":"…","iter":0,"kind":"baseline","scores":{"correctness":6.2,"…":0},"overall":6.2,"run":"runs/iter-0"}
```

## Scoring seam

Each engagement declares how it is scored in `contract.json`:

| `scorer` | Command | Mechanism |
|----------|---------|-----------|
| `checks` | `productteam score … --iter N` → `productteam checks` | Deterministic `lib/run-checks.sh`; target Analyst gate |
| `provider` | `productteam score … --iter N` → `productteam bench run --iter N` | LLM via `lib/provider.sh`; target Analyst gate |

Wrong path refuses honestly. No plugin router — add a third scorer
only with evidence of need (Constitution).

All scoring paths first cross `lib/workspace.sh`. `consult workspace <client>
ensure|status|remove` owns one detached worktree per engagement. `score`,
`checks`, and provider `bench … run` auto-ensure it and never fall back to the
owner's live `Repo:` tree. A dirty worktree refuses by name unless the invocation
supplies `--allow-dirty <reason>`; that reason is preserved with the evidence.

`ensure` reuses the existing pinned detached checkout and does not reset
to newer source HEAD; a caller that needs a fresh tree runs `remove`
then `ensure`. If the checkout directory is removed out-of-band while
source still registers the worktree, recovery is `git worktree prune` in
the source repo, then `ensure`.

Each provider run archives path/SHA/dirty in `runs/iter-N/workspace.json`.
Deterministic checks archive the same provenance in a unique
`runs/check-*/workspace.json`. This is a plain-file seam, not an orchestrator or
workspace registry.

## Judgment gate seam

`lib/judgment-gate.sh` decides and records whether implementation may proceed
per the engagement's current `Mode:` (the sole authority; a missing/unknown mode
refuses). Per-mode payloads live as plain JSON in the engagement's
`judgment/` directory, written atomically (tmp + rename, mirroring the
workspace seam). `consult gate <client> status` re-derives the decision from
those files alone and emits valid JSON — no chat, no other state. The current
mode's file is the only one read; stale files from other modes are ignored, not
deleted. `implement` is a read-only predicate: it never mutates the engagement.

| Mode | Gate file | Implement decision |
|------|-----------|--------------------|
| Guided | `judgment/selection.json` | allowed iff non-empty `direction` + `selected_by` (selection precedes implementation) |
| Directive | `judgment/directive.json` | allowed iff durable `direction` + `decision` (`risks` array may be empty) |
| Challenge | `judgment/challenge.json` + `judgment/selection.json` | challenged `harmful` path always refused; only `safer_alternative` (matching selection) is implementable |
| Override | `judgment/override.json` | allowed iff exact `direction`, non-empty `risks`, `critic_record`, `evidence_record`, and `non_waivers.{critic,evidence,frozen_contract}=true` — Override never waives the contract |

`bound_direction` in status is the implementable direction for the current
mode; `implement [<direction>]` accepts an explicit direction only if it equals
the bound one. Status is machine-readable (`client`, `mode`, `allowed`,
`decision`, `reason`, `bound_direction`, `artifact`, `artifact_ts`, plus
`required`/`present` data) and exits 0 even for a refusal or a legacy
engagement with no `judgment/` payload. Build 4's Builder invocation consumes
this same predicate; Build 3's progress-block seam composes before it.

## Escalation, pause, and inspect seam

`lib/engagement-state.sh` owns a small file state machine. `escalation block`
writes one blocked `escalations.json` entry (options + resume token) and an
active `pause.json`. One `progress_blocked_reason` predicate guards deterministic
checks, provider scoring, and `gate … implement`; read/control commands remain
available.

Resume needs a separate, manually created `authorize-resume.json` with exact
id/token plus non-empty `authorized_by` and `decision`. The token correlates the
decision but never authorizes alone. A successful resume stamps escalation
resolved, pause resumed, authorization consumed, writes `continuation.json`,
and appends a pointer to `${CONSULT_MEMORY_FILE:-MEMORY.md}`. State stays
inspectable; no file deletion is treated as authorization.

`consult inspect <client>` atomically regenerates `inspect-pack.json` from
`engagement.md`, judgment state, score files and `history.jsonl`, escalation and
pause state, continuation, and the latest lessons file. Every required source
has a value or explicit `missing:true` marker; `next_suggested_action` follows
pause → judgment → measurement precedence. The pack is a projection, never a
second state authority.

## Role envelope seam

`lib/role-envelope.sh` adds no scheduler. One `consult role … invoke` resolves
the existing isolated workspace and makes exactly one `provider_ask` call.
Analyst, Builder, and Critic attempts persist atomic request/result/manifest
triples, including refusals. The manifest hashes the exact request and result
bytes. `role … status` validates those hashes and derives stable `asked`,
`ran`, `produced`, and `missing` arrays only from final JSON files.

Builder has one write-once `seal.json` per role iteration. It records the exact
input path and SHA-256; invocation re-hashes and reads those bytes after the
engagement pause check and before the existing judgment predicate. There is no
free Builder task argument and no reseal path. The seal is provenance, not
authorization.

A successful Analyst attempt writes a stamp bound to its result hash and role
identity. Score publication is explicitly bound to that same integer
iteration; missing/malformed stamps refuse before workspace/provider work.
Builder and Analyst may use the same provider, but their recorded identities
must differ. Close applies the same authorship predicate, requires a complete
successful Critic envelope, and writes `close.json`. These are structural
plain-file receipts, not cryptographic user authentication.

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
- No general config file — provider and workspace-root overrides are explicit
  environment seams (`CONSULT_PROVIDER`, `CONSULT_WORKSPACE_ROOT`).
- No second runtime module — detection lives in `lib/provider.sh`.

Each absence is deliberate; adding any of these requires evidence per
the Constitution.
