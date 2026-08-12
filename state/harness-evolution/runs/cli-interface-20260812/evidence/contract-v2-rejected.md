# CLI-BENCHMARK-CONTRACT.md — ProductTeam CLI Interface (FROZEN, v2)

> **RECONSTRUCTION NOTE (2026-08-12):** this file is a best-effort
> reconstruction of the rejected v2 contract (id `cli-interface-20260812-v2`),
> archived after the v3 write replaced it. It is **not byte-exact**: its
> SHA-256 is `b9cf201310f8cc575412d8729ff9b2ce846889ed58c0b74e2c2228a87a305b51`,
> which differs from the recorded v2 freeze hash
> `036ae8e8c57bdbb3f88beafcba1c9ff3cb0e4c03298f9d03a390cdb463a7adca`
> (preserved in `evidence/freeze-sha-v2.txt` and in the v3 revision history).
> Treat the authoritative v2 record as: the freeze hash above, the rejected
> status, and `evidence/parity-test-baseline-v2.txt` (its failing baseline).

**Contract `cli-interface-20260812-v2` · frozen 2026-08-12 · run directory
`state/harness-evolution/runs/cli-interface-20260812/`.**

This contract freezes the observable command-line interface of the Product
Consulting Harness (`bin/productteam`) as it ships today, so a later
implementation iteration can be scored against a fixed benchmark. It does
**not** amend `BENCHMARKS.md` v1, `harness-apc-v1`, or engagement-local
contracts. Iteration 1 of at most 6.

## v2 revision (owner-approved re-freeze before any production edit)

v1 was rejected pre-build by the Critic (`evidence/critic-prebuild-rebuttal.md`,
`evidence/contract-v1-rejected.md`, `evidence/freeze-sha-v1.txt`). v2 applies
the Principal's accepted corrections (`principal-decision.md`,
`principal-priorities.md`). **No production implementation has begun; the
iter-1 baseline is still taken from the unmodified repository.** v2 changes:

1. **Registry.** A single thin descriptive command registry becomes the
   source for help text, `help --json`, dispatch validation/routing, slash
   palette, slash routing, and explicit unsupported reasons. Data table +
   existing handlers only; **no plugin host, no `eval`**.
2. **Frontend boundary.** New machine-readable output is limited to
   `help --json` (command metadata) and `status --json` (engagement list /
   current selection) — explicitly required by the mission. All existing
   JSON seams remain authoritative and unchanged.
3. **New frozen failing probes** for verified defects missed by v1: slash
   `/score <client> --iter <n>` and `/bench <client> run --iter <n>`
   forwarding, quoted multi-word slash argv, stale onboarding score syntax,
   and `bench`/`run` honest handling of summary-shaped scores.
4. **D5 removed.** The committed `state/style/` duplication is durable org
   memory, not a CLI dispatcher defect; it is **out of scope** for this
   contract and must not be "fixed" by editing `state/style/*`.
5. **D1 policy recorded.** Stale workspace metadata may be **recreated only
   when the recorded workspace path is absent**; recovery must never delete,
   relocate, reset, or overwrite an existing/dirty/foreign worktree.

| Field | Value |
|-------|-------|
| Subject | `bin/productteam` CLI surface + `tests/` parity probes |
| Contract id | `cli-interface-20260812-v2` |
| Frozen | 2026-08-12 (v2 re-freeze) |
| Run dir | `state/harness-evolution/runs/cli-interface-20260812/` |
| Freeze proof | `FREEZE-SHA.txt` (SHA-256 of this file) |
| Scores | **integers 0–10** per dimension, path/command-output evidence required |
| Scorer | Analyst only (independent). Principal never scores. |
| Baseline | iter-1 failing baseline: `evidence/parity-test-baseline-v2.txt` |
| Max iterations | 6 (this run + 5 repair iterations) |

## Freeze rule

`CLI-BENCHMARK-CONTRACT.md`, `FREEZE-SHA.txt`, and the parity probes
(`tests/cli-interface-parity.sh`) are frozen during the run. Any content
change to the contract file breaks its SHA-256 proof and fails probe 1 of the
parity test. A contract amendment requires owner approval, a version bump,
and a new freeze hash — it never applies mid-run retroactively.

---

## Scoring protocol

1. **Independent evaluator only.** Analyst scores; Principal never scores,
   never rewrites a score artifact.
2. **Evidence rule.** Every dimension score cites a concrete path, command
   output, or check artifact archived in the run directory. A score without
   evidence is **void**.
3. **Deterministic.** Scores are **integers 0–10**; band anchors are defined
   per dimension. Where a probe in `tests/cli-interface-parity.sh` covers the
   dimension, the probe outcome is primary evidence and a failing probe caps
   the dimension at 5 unless the Analyst documents an environment-only cause
   with proof.
4. **Overall.** Mean of the eleven dimensions, rounded to one decimal.
   Overall is informational; convergence is per-dimension.
5. **Baseline guard.** The iter-1 baseline is scored before any
   implementation change and is never re-scored retroactively.
6. **No mocks.** Any provider/agent execution in verification uses the
   authenticated real agent runtime. Fake providers, fixture-only “green”
   results, and fabricated outputs void the iteration.

---

## Command registry (single source, required by repair)

The repair iteration must introduce one thin data table (a shell array or a
flat data file under the CLI's own state — **not** a new state authority, not
a daemon) that drives, without duplication:

- the help text command table (`productteam help`),
- `productteam help --json` command metadata,
- top-level dispatch validation/routing (aliases `runtime`, `worktree`,
  `-h`, `--help` may stay hand-written),
- the chat slash palette (`/help` verb list and live hints),
- slash routing, and
- explicit `chat_supported` / `chat_reason` per command.

**Shape required by `help --json` (frozen):** a JSON object with

- `"commands"`: array of 32 entries, one per top-level command, each with
  string `name`, string `usage`, boolean `chat_supported`, and — when
  `chat_supported` is false — non-empty string `chat_reason`;
- `"chat_only"`: array of the 6 chat-only verbs
  (`provider workers clear export exit quit`).

The parity test derives the expected chat palette from this registry (falling
back to the frozen list below only while the registry is absent, i.e. the
failing baseline). The registry must agree with the frozen 32-command table
and the frozen classification table in this contract.

---

## Dimensions (11) and rubric

Band key (used everywhere):

| Band | Meaning |
|------|---------|
| **≤5** | Missing, broken, unreachable, or asserted only by mocks |
| **6–8** | Present and usable; gaps or partial coverage |
| **9–10** | Complete, evidenced, operable without out-of-band heroics |

### 1. reachability

**Success:** Every command in the help command table runs and exits
non-erroring on a cold checkout of this repo for the engagements the repo
ships with; stale workspace metadata recovers non-destructively.

| Band | Criteria |
|------|----------|
| ≤5 | A documented command cannot be reached on a cold checkout (exit ≠ 0 for a non-environmental reason) |
| 6–8 | Core read commands reachable; one documented command needs manual state surgery |
| 9–10 | All 32 help-listed commands reachable; stale-workspace recovery is automatic and never destroys existing worktrees |

**D1 policy (frozen):** when the recorded workspace path is **absent**,
`workspace_ensure` may recreate the metadata and proceed. It must **never**
delete, relocate, reset, or overwrite an existing, dirty, or foreign
worktree; any such case must refuse with a remedy, non-zero.

**Verification (repository-discovered):**

- `bin/productteam help` — exit 0; names all 32 top-level commands
- `bin/productteam checks onboarding-flight-control` — exit 0 on a cold checkout
- Non-destructive guard: a pre-existing directory at the would-be workspace
  path (with marker content) survives a `checks` attempt byte-identical
- Probe: `tests/cli-interface-parity.sh` sections 2–3

### 2. chat-reachability-classification

**Success:** `chat` is reachable on a TTY, refuses honestly off-TTY, and the
slash palette is complete, registry-driven, and honest: supported verbs
dispatch with exact argument forwarding; intentionally unsupported commands
are classified with explicit safety/usefulness reasons (never silently
misrouted, never duplicated lists).

| Band | Criteria |
|------|----------|
| ≤5 | chat unreachable on TTY, off-TTY refusal silent, unsupported command misrouted, or slash argument forwarding drops required flags |
| 6–8 | Palette complete but classification or forwarding has one gap |
| 9–10 | Registry-driven palette (25 verbs: 19 CLI + 6 chat-only); all 14 unsupported commands produce `unknown /X — /help` with a non-empty registry `chat_reason`; `/score <client> --iter <n>` and `/bench <client> run --iter <n>` forward every argument (a required-iter error must not appear; the honest downstream outcome, e.g. Analyst-stamp refusal, must) |

**Frozen classification (safety/usefulness reasons):**

| CLI command | chat_supported | chat_reason (safety/usefulness) |
|-------------|----------------|--------------------------------|
| help status agents runtime onboarding splash judge score checks bench report run memory org gh skill smoke harness-checks | true | read or delegated operations safe and useful inside a session |
| `chat` | false | safety: nested sessions re-enter the same REPL with no isolation; no usefulness |
| `open` | false | usefulness: one-shot cold-start needing `--repo` absolute-path args; safety: creates engagement state mid-session |
| `baseline` | false | usefulness: one-shot iter-0 bootstrap gated by `--allow-dirty`; owner-gated write |
| `workspace` | false | safety: worktree mutation; in-session invocation could touch dirty/foreign worktrees |
| `run-loop` | false | safety/usefulness: long-running overnight driver with its own signal handling; not a chat verb |
| `gate` | false | safety: owner-gated durable decisions must leave a durable record; session context bypasses it |
| `direction` | false | safety: proposal/clear ops mutate durable direction state; owner-gated |
| `escalation` | false | safety: block/resume carry authorization tokens; must not run mid-session |
| `inspect` | false | usefulness: regenerates the inspect pack (a write op) from files; read side is the file itself |
| `role` | false | safety: seal/invoke enforce authorship and stamp integrity; must not run mid-session |
| `card` | false | safety/usefulness: `seed-specialist` writes agent cards; read side available via `card list\|show` CLI |
| `style` | false | safety: org style is owner-edited durable memory; read side via `style show` CLI |
| `project-memory` | false | usefulness: append is a one-shot CLI op; read side via `project-memory show` |
| `pool` | false | usefulness: search/add are one-shot CLI ops; read side via `pool list\|show\|search` |

**Chat-only verbs (not CLI commands, palette-only):** `provider workers
clear export exit quit`.

**Verification:**

- `bin/productteam chat </dev/null` — non-zero exit, message names the TTY remedy
- PTY probes (parity test sections 6–8): `/help` lists the 25 verbs;
  each of the 14 unsupported commands yields `unknown /X — /help`; `/score
  onboarding-flight-control --iter 0` and `/bench harness-evolution run
  --iter 7` must reach the downstream Analyst-stamp refusal (`scores invalid:
  missing Analyst stamp …`) and must NOT print `scoring requires --iter` or a
  usage line; quoted `/provider "codex"` must select `codex` (quotes
  stripped) and a slash line containing `$(…)`/`;` must never execute
- Control (CLI, no chat): `bin/productteam score onboarding-flight-control
  --iter 0` and `bin/productteam bench harness-evolution run --iter 7` both
  exit 1 with `scores invalid: missing Analyst stamp …` — proves the
  downstream outcome is a stamp refusal, not a missing-iter error

### 3. argument-usage-parity

**Success:** Help usage lines match actual argument validation; what help
promises, the dispatcher enforces; misuse exits non-zero with a usage
message; slash handlers forward the exact same arguments as the CLI command.

| Band | Criteria |
|------|----------|
| ≤5 | A command accepts misuse silently, or slash forwarding drops required flags |
| 6–8 | Usage text differs cosmetically from enforcement |
| 9–10 | Every help usage line enforced; slash forwarding is argument-identical to the CLI path |

**Verification:**

- Misuse probes (all exit 1 with usage/unknown-option message matching help):
  `open`, `workspace <client>`, `score`, `run-loop`, `gh`, `skill`,
  `splash --bogus`, `onboarding --bogus`, `agents --bogus` —
  `evidence/usage-parity-probes.txt`
- Slash forwarding probes (D2): parity sections 6–8

### 4. help-readme-onboarding-parity

**Success:** `help` (canonical surface), `README.md`, and `onboarding` agree:
README documents every help-listed command, and onboarding's next-step text
uses current command syntax.

| Band | Criteria |
|------|----------|
| ≤5 | README omits ≥ 3 help-listed commands, or onboarding prints a stale command signature |
| 6–8 | README omits 1–2 commands, or onboarding friction |
| 9–10 | README documents all 32 help-listed commands; `onboarding --yes` next-step text uses current syntax (`score <client> --iter <n>`); onboarding succeeds on an isolated state root |

**Verification:**

- Parity test section 4: every frozen command appears in `README.md`
- Parity test section 11: `onboarding --yes` output contains
  `score <client> --iter` (lib/onboarding.sh step 4 currently prints the
  stale `productteam score <client>` — D4)

### 5. argv-safety

**Success:** Multi-word arguments round-trip byte-identical at the CLI **and**
inside chat slash lines; empty arguments are rejected or preserved
deterministically; slash parsing never uses `eval` or executes embedded
command text.

| Band | Criteria |
|------|----------|
| ≤5 | An argument is split/lost/truncated, quotes mangled, or a slash line executes embedded text |
| 6–8 | One boundary-drift case (e.g. quoted slash value) |
| 9–10 | Multi-word CLI values round-trip byte-identical; quoted slash values parse as one argument; embedded `$(…)`/`;` text is inert; empty input rejected non-zero |

**Verification:**

- CLI: isolated style state `style init` + `style append taste "alpha beta
  gamma"` → `style show --json` contains exactly `alpha beta gamma`;
  `style append never ""` exits non-zero (parity section 13)
- Chat (PTY): `/provider "codex"` selects codex (D5); `/provider x;touch
  /tmp/…` creates nothing and keeps the session alive (parity section 8)

### 6. frontend-machine-boundary

**Success:** Every machine-readable surface (`--json` and JSON-by-default
commands) emits valid, parseable JSON with a stable shape; the two required
frontend surfaces exist: `help --json` (command registry metadata) and
`status --json` (engagement list / current selection).

| Band | Criteria |
|------|----------|
| ≤5 | A documented JSON surface emits non-JSON; or `help --json` / `status --json` absent |
| 6–8 | All surfaces parse; one shape undocumented |
| 9–10 | `help --json` (32 commands + chat classification + 6 chat-only) and `status --json` (engagements array incl. onboarding-flight-control and harness-evolution) parse and are documented; all existing surfaces parse |

**Verification:**

- `jq -e .` over existing surfaces: `agents --json`, `card list --json`,
  `style show --json`, `pool list --json`,
  `project-memory show <client> --json`, `escalation <client> status`,
  `gate/workspace/role status`, `direction <client> list --json`, inspect
  pack (parity section 9)
- `help --json` registry shape (parity section 6) and `status --json`
  engagement list (parity section 10) — both fail on the baseline (D6)

### 7. non-tty-redirect-nocolor-exit

**Success:** Output is ANSI-free outside a color TTY and under `NO_COLOR=1`;
on a color TTY, ANSI is present; exit codes are honest — including on bad
input, where a raw interpreter traceback (e.g. `jq: error` with jq's exit
code 5) must never leak to the user.

| Band | Criteria |
|------|----------|
| ≤5 | ANSI leaks in redirected output, `NO_COLOR=1` ignored, or a raw `jq: error` traceback with exit 5 reaches the user |
| 6–8 | One ANSI leak or one non-honest exit path |
| 9–10 | Redirected output zero ESC bytes; TTY+`NO_COLOR=1` zero ESC bytes; TTY without `NO_COLOR` emits ANSI; unknown command and usage errors exit non-zero; `bench`/`run` on summary-shaped scores exit with an honest message and never a raw jq traceback |

**Verification:**

- `bin/productteam help | grep -c $'\e'` → 0; `bin/productteam splash` (pipe) → 0
- PTY probes (parity section 12): ESC count > 0 on color TTY; ESC count 0 with
  `NO_COLOR=1`
- `bin/productteam bench harness-evolution` and
  `bin/productteam run harness-evolution 7` — must not contain `jq: error`
  and must not exit 5 (D7; baseline exits 5 with a raw jq traceback on
  `runs/iter-7/scores.json` `"scores": null` — `evidence/bench-harness-evolution.txt`,
  `evidence/run-harness-evolution-7.txt`)

### 8. ctrl-c-child-cleanup-partial-artifacts

**Success:** Interrupting a long-running CLI operation (chat provider call,
run-loop) terminates its child process tree and leaves partial artifacts
visible and named — never a silently abandoned child or a torn state file.

| Band | Criteria |
|------|----------|
| ≤5 | Ctrl+C leaves an orphaned child or corrupts state silently |
| 6–8 | Cleanup works but partial artifacts unnamed/undocumented |
| 9–10 | Scoped SIGINT kills the provider tree, keeps the session alive, records exit 130, leaves the partial artifact on disk with a documented path |

**Verification:**

- Code contract: `lib/repl.sh` `repl_ask` scoped `trap INT` →
  `repl_interrupt_cleanup`; `lib/run-loop.sh`
  `trap 'loop_pause_for_signal' TERM INT`
- Archived runtime proof (pre-implementation): `state/harness-evolution/runs/iter-7/visual-checks-final.json`
  — `honest-partial-output` probe, 14/14 pass
- Documented honesty: chat prints “Ctrl+C leaves partial on disk” before work

### 9. visual-smoke-contracts

**Success:** The built-in smoke suite (`productteam smoke` /
`tests/consult-smoke.sh`) passes and the visual CLI surface (splash, theme)
renders without ANSI leaks outside a color TTY.

| Band | Criteria |
|------|----------|
| ≤5 | Smoke exits non-zero for a non-environmental reason |
| 6–8 | Smoke green only with `CONSULT_SMOKE_SKIP_CLIENT=1`; or one FAIL from state drift |
| 9–10 | `productteam smoke` exits 0 with no FAIL lines; splash renders statically in a pipe |

**Verification:**

- `bin/productteam smoke` — exit code + FAIL lines:
  `evidence/smoke-baseline.txt` (iter-1: exit 1, single FAIL `checks`, D1
  root cause)
- Parity sections 2 and 12 (help/splash ANSI-free in pipe)

### 10. dependencies-cold-start

**Success:** A fresh clone runs the CLI with common POSIX tools; provider
agents are detected, optional, absence reported honestly; tracked engagement
state does not pin machine-specific absolute paths that break cold-start
commands — and when a recorded path is stale/absent, recovery is automatic
and non-destructive (D1 policy).

| Band | Criteria |
|------|----------|
| ≤5 | A tracked command fails on a fresh checkout because state pins this machine's absolute paths, with no recovery |
| 6–8 | State pins absolute paths but commands self-heal or fail with a clear remedy |
| 9–10 | No machine-pinned absolute paths in tracked state; cold-start commands run; recovery non-destructive |

**Verification:**

- `bin/productteam agents --json` detection (`lib/provider.sh` catalog)
- `grep -R '/home/logani' state/engagements/` — machine-pinned paths and
  their command impact: `evidence/checks-baseline.txt` (D1)
- `bin/productteam runtime --check` with `CONSULT_PROVIDER=/nonexistent` —
  non-zero + honest message

### 11. metadata-simplicity-deletion

**Success:** CLI state files are minimal, deduplicated, and deletable
without breaking cold-start reachability. **Scope note (v2):** the committed
duplicate entry in `state/style/` is durable org memory, out of scope for
this contract (Principal decision; D5 removed). This dimension scores the
CLI's own metadata, not org memory content.

| Band | Criteria |
|------|----------|
| ≤5 | CLI metadata duplicated or stale in a way that forces manual deletion to reach a command |
| 6–8 | One vestigial file or duplication, no reachability impact |
| 9–10 | CLI state minimal; every file load-bearing or documented deletable; smoke scaffolding cleans up after itself |

**Verification:**

- `state/.cli/` gitignored: 5-byte `first-run` marker + one `config` line
- `tests/run-loop-smoke.sh` standalone exits 0 and removes its
  `state/engagements/run-loop-*` scaffolding (trap cleanup)
- No new durable state introduced by repairs beyond the thin registry

---

## Verified iter-1 baseline defects (frozen evidence, v2)

Scored before any implementation change. Each is reproduced with real
commands; the parity test fails on all of them.

| Id | Defect | Evidence | Failing probe |
|----|--------|----------|---------------|
| **D1** | `productteam checks onboarding-flight-control` exits 2: `workspace-metadata-mismatch`. Tracked `workspace.json` pins a workspace path from a different worktree; `workspace_ensure` hard-fails with no remedy and no non-destructive recovery (v2 policy: recover only when recorded path absent; never touch existing/dirty/foreign worktrees) | `evidence/checks-baseline.txt`; `state/engagements/onboarding-flight-control/workspace.json` | parity 3 |
| **D2** | Slash forwarding drops required flags: `/score <client> --iter <n>` and `/bench <client> run --iter <n>` reach `cmd_score`/`cmd_bench_run` without `--iter` → session dies with `scoring requires --iter <n> to bind the Analyst stamp`. CLI controls prove the honest downstream is a stamp refusal (`scores invalid: missing Analyst stamp …`), not a missing-iter error | `lib/repl.sh` score/bench cases vs `bin/productteam` CLI dispatch; CLI control outputs (parity 7) | parity 7 |
| **D3** | README omits 5 help-listed commands: `direction`, `pool`, `project-memory`, `run-loop`, `style` (help 32 vs README 27) | `evidence/readme-parity-diff.txt` | parity 4 |
| **D4** | `onboarding --yes` step 4 prints stale `productteam score <client>` (help/CLI require `--iter <n>`) | `lib/onboarding.sh:51`; `evidence/onboarding-stale-syntax.txt` | parity 11 |
| **D5** | Slash quoted argv mangled: `/provider "codex"` treats the quotes literally → `provider "codex" is not a usable installed agent`; a safe parser must strip quotes and select codex without `eval` (embedded `$(…)`/`;` text is already inert) | PTY capture (parity 8) | parity 8 |
| **D6** | Frontend boundary: `help --json` and `status --json` do not exist (emit prose, exit 0) — no command-registry metadata, no engagement-list JSON | PTY/pipe captures (parity 6, 10) | parity 6, 10 |
| **D7** | `bench harness-evolution` and `run harness-evolution 7` exit 5 with a raw `jq: error` traceback on summary-shaped `runs/iter-7/scores.json` (`"scores": null`) — no honest message, no fallback | `evidence/bench-harness-evolution.txt`, `evidence/run-harness-evolution-7.txt` | parity 12 |

**Removed from scope (v2):** the `state/style/` duplicate entry (v1 D5) —
durable org memory, not a CLI dispatcher defect; evidence retained as
`evidence/style-dup-baseline.txt` for the record, and `state/style/*` must
not be edited to satisfy any probe.

**Additional baseline facts (passing, guarded by the parity test):** help
exits 0 and names all 32 commands; chat refuses non-TTY with TTY remedy;
`/help` lists all 25 verbs and all 14 unsupported commands classify honestly;
all existing `--json` surfaces parse; redirected output and `NO_COLOR=1` are
ANSI-free while a color TTY emits ANSI; CLI multi-word argv round-trips
byte-identical and empty argv is rejected; unknown command and usage errors
exit non-zero; slash lines never execute embedded text; `productteam smoke`
exits 1 with a single FAIL (`checks`, D1 root cause).

---

## Minimum thresholds and stop conditions

- **Threshold:** every dimension ≥ 8.0 on the same scored iteration.
- **Convergence checklist (all must hold):** iter-1 baseline never rewritten;
  freeze SHA unchanged during the scored iteration; all 11 dimensions ≥ 8
  with non-void evidence; Analyst authored scores; Critic re-audit recorded;
  parity test exits 0; real (non-mock) verification only; registry is a data
  table with no `eval`/plugin host.
- **Stop:** converged, or 6 iterations exhausted → write
  `convergence-report.md` in the run directory.

## Critical failures (void the iteration)

1. **Contract moved mid-run** — any edit to this file or `FREEZE-SHA.txt`
   during an active iteration (detectable: probe 1 hash mismatch).
2. **Fake/mocked validation** — fabricated command output, stub providers,
   or “green” results not produced by the claimed command against the real repo.
3. **Self-scoring** — Principal authored or overwrote the iteration scores.
4. **Silent baseline rewrite** — iter-1 evidence files altered retroactively.
5. **Destructive workspace handling** — recovery that deletes, relocates,
   resets, or overwrites an existing/dirty/foreign worktree (D1 policy).
6. **Durable-state churn for probes** — editing `state/style/*` (or other
   org memory) to satisfy a parity probe.
