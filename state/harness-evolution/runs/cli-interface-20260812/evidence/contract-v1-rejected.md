# CLI-BENCHMARK-CONTRACT.md — ProductTeam CLI Interface (FROZEN)

**Contract `cli-interface-20260812` · frozen 2026-08-12 · run directory
`state/harness-evolution/runs/cli-interface-20260812/`.**

This contract freezes the observable command-line interface of the Product
Consulting Harness (`bin/productteam`) as it ships today, so a later
implementation iteration can be scored against a fixed benchmark. It does
**not** amend `BENCHMARKS.md` v1, `harness-apc-v1`, or engagement-local
contracts. It is iteration 1 of at most 6.

| Field | Value |
|-------|-------|
| Subject | `bin/productteam` CLI surface + `tests/` parity probes |
| Contract id | `cli-interface-20260812` |
| Frozen | 2026-08-12 |
| Run dir | `state/harness-evolution/runs/cli-interface-20260812/` |
| Freeze proof | `FREEZE-SHA.txt` (SHA-256 of this file) |
| Scores | **integers 0–10** per dimension, path/command-output evidence required |
| Scorer | Analyst only (independent). Principal never scores. |
| Baseline | iter-1 failing baseline captured in `evidence/parity-test-baseline.txt` |
| Max iterations | 6 (this run + 5 repair iterations) |

## Freeze rule

`CLI-BENCHMARK-CONTRACT.md`, `FREEZE-SHA.txt`, and this contract's probes in
`tests/cli-interface-parity.sh` are frozen during the run. Any content change
to the contract file breaks its SHA-256 proof and fails probe 1 of the parity
test. A contract amendment requires owner approval, a version bump, and a new
freeze hash — it never applies mid-run retroactively.

---

## Scoring protocol

1. **Independent evaluator only.** Analyst scores; Principal never scores,
   never rewrites a score artifact.
2. **Evidence rule.** Every dimension score cites a concrete path,
   command output, or check artifact archived in the run directory. A score
   without evidence is **void**.
3. **Deterministic.** Scores are **integers 0–10**; band anchors are defined
   per dimension below. Where a probe in `tests/cli-interface-parity.sh`
   covers the dimension, the probe outcome is the primary evidence and the
   score must be consistent with it (a failing probe caps the dimension at 5
   unless the analyst documents an environment-only cause with proof).
4. **Overall.** Mean of the eleven dimensions, rounded to one decimal.
   Overall is informational; convergence is per-dimension.
5. **Baseline guard.** The iter-1 baseline (this run) is scored before any
   implementation change and is never re-scored retroactively.
6. **No mocks.** Any provider/agent execution in verification uses the
   authenticated real agent runtime. Fake providers, fixture-only “green”
   results, and fabricated outputs void the iteration.

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
non-erroring on a cold checkout of this repo (default state root), for the
engagements the repo ships with.

| Band | Criteria |
|------|----------|
| ≤5 | A documented command cannot be reached at all on a cold checkout (exit ≠ 0 for a non-environmental reason) |
| 6–8 | Core read commands reachable; at least one documented command needs manual state surgery to run |
| 9–10 | All 32 help-listed commands reachable; nothing needs manual state surgery |

**Verification (repository-discovered):**

- `bin/productteam help` — exit 0; names all 32 top-level commands
- `bin/productteam checks onboarding-flight-control` — exit 0 on a cold checkout
- `bin/productteam status`, `org`, `memory`, `agents`, `splash`, `smoke` — exit 0
- Probe: `tests/cli-interface-parity.sh` sections 2–3

### 2. chat-reachability-classification

**Success:** `chat` is reachable on a TTY, refuses honestly off-TTY, and the
slash-verb palette is complete and honest: supported verbs dispatch, and
intentionally unsupported CLI commands are classified (never silently
misrouted).

| Band | Criteria |
|------|----------|
| ≤5 | chat unreachable on TTY, or off-TTY refusal is silent/zero-exit |
| 6–8 | Palette complete but an unsupported command is misrouted or classified opaquely |
| 9–10 | All 25 verbs listed by `/help`; all 14 unsupported commands produce `unknown /X — /help` and the session stays alive |

**Intentionally unsupported chat commands (classification, frozen):**

| CLI command | Class | Reason it is not a slash verb |
|-------------|-------|-------------------------------|
| `chat` | chat | self-reference; no nested sessions |
| `open`, `baseline`, `workspace`, `run-loop` | bootstrap/lifecycle | one-shot cold-start and overnight ops, not in-session verbs |
| `gate`, `direction`, `escalation` | gate/decision | durable owner-gated decisions surfaced via `/judge` |
| `inspect`, `role`, `card`, `style`, `project-memory`, `pool` | stateful file ops | file-derived state managed via dedicated CLI commands |

**Verification:**

- `bin/productteam chat </dev/null` — non-zero exit, message names the TTY remedy
- PTY probe (parity test section 6): `/help` lists the 25 verbs; each of the 14
  unsupported commands yields `unknown /X — /help`; `/exit` terminates

### 3. argument-usage-parity

**Success:** Help usage lines match the actual argument validation of each
command: what help promises, the dispatcher enforces; misuse exits non-zero
with a usage message.

| Band | Criteria |
|------|----------|
| ≤5 | A command accepts misuse silently or help documents an option the command rejects |
| 6–8 | Usage text differs in detail from enforcement (cosmetic) |
| 9–10 | Every help usage line is enforced; misuse exits non-zero with the documented usage |

**Verification:**

- Misuse probes: `open`, `workspace <client>`, `score`, `run-loop`, `gh`,
  `skill`, `splash --bogus`, `onboarding --bogus`, `agents --bogus` — all exit
  1 with a usage/unknown-option message matching help (captured in evidence)
- `bin/productteam help` usage lines vs. probe outputs in
  `evidence/usage-parity-probes.txt`

### 4. help-readme-onboarding-parity

**Success:** `help` (canonical surface), `README.md`, and `onboarding` agree:
README documents every help-listed command, and onboarding is a documented,
working first-run path.

| Band | Criteria |
|------|----------|
| ≤5 | Help omits commands, or README omits ≥ 3 help-listed commands |
| 6–8 | README omits 1–2 help-listed commands, or onboarding has friction |
| 9–10 | README documents all 32 help-listed commands; onboarding `--yes` succeeds on an isolated state root |

**Verification:**

- Parity test section 4: every one of the 32 frozen commands appears in
  `README.md` (`productteam <cmd>` mention)
- `CONSULT_STATE_ROOT=$(mktemp -d) bin/productteam onboarding --yes` — exit 0

### 5. argv-safety

**Success:** Multi-word arguments round-trip byte-identical; empty arguments
are rejected or preserved deterministically — never silently truncated,
split, or glued.

| Band | Criteria |
|------|----------|
| ≤5 | An argument is split/lost/truncated, or a multi-word value cannot be stored |
| 6–8 | One command shows boundary drift (e.g. whitespace trimming) |
| 9–10 | Multi-word values round-trip byte-identical; empty input rejected with non-zero |

**Verification:**

- Isolated style state: `style init`, then
  `style append taste "alpha beta gamma"` → `style show --json` contains
  exactly `alpha beta gamma`; `style append never ""` exits non-zero
  (parity test section 9)

### 6. frontend-machine-boundary

**Success:** Every machine-readable surface (`--json` and JSON-by-default
commands) emits valid, parseable JSON with a stable shape, both on success and
on empty state.

| Band | Criteria |
|------|----------|
| ≤5 | A documented JSON surface emits non-JSON or fails to parse |
| 6–8 | All surfaces parse; one shape is unstable or undocumented |
| 9–10 | All surfaces parse and their shapes are documented in the run report |

**Verification:**

- `jq -e .` over: `agents --json`, `card list --json`, `style show --json`,
  `pool list --json`, `project-memory show <client> --json`,
  `escalation <client> status` (JSON by default) — all parse (parity test
  section 7)

### 7. non-tty-redirect-nocolor-exit

**Success:** Output is ANSI-free when stdout is not a color TTY (pipe,
redirect, CI) and under `NO_COLOR=1`; on a color TTY, ANSI is present; exit
codes are honest (0 success, non-zero refusal/error).

| Band | Criteria |
|------|----------|
| ≤5 | ANSI escapes leak into redirected output, or `NO_COLOR=1` is ignored on a TTY |
| 6–8 | One command emits ANSI in a non-color context |
| 9–10 | Redirected output has zero ESC bytes; TTY+`NO_COLOR=1` has zero ESC bytes; TTY without `NO_COLOR` emits ANSI; unknown command and usage errors exit non-zero |

**Verification:**

- `bin/productteam help | grep -c $'\e'` → 0; `bin/productteam splash` (pipe) → 0
- PTY probes (parity test section 8): ESC count > 0 on color TTY; ESC count 0
  with `NO_COLOR=1`
- `bin/productteam not-a-command` → non-zero; `bin/productteam open` → non-zero

### 8. ctrl-c-child-cleanup-partial-artifacts

**Success:** Interrupting a long-running CLI operation (chat provider call,
run-loop) terminates its child process tree and leaves partial artifacts
visible and named — never a silently abandoned child or a torn state file.

| Band | Criteria |
|------|----------|
| ≤5 | Ctrl+C leaves an orphaned child process or corrupts state silently |
| 6–8 | Cleanup works but partial artifacts are unnamed or undocumented |
| 9–10 | Scoped SIGINT kills the provider tree, keeps the session alive, records exit 130, and leaves the partial artifact on disk with a documented path |

**Verification:**

- Code-level contract: `lib/repl.sh` `repl_ask` scoped `trap INT` →
  `repl_interrupt_cleanup`; `lib/run-loop.sh` `trap 'loop_pause_for_signal' TERM INT`
- Behavior probe (requires real provider): interrupt a chat provider call,
  confirm `ps` shows no surviving child and the partial artifact exists under
  the session dir; transcript in `evidence/`
- Documented honesty: chat prints “Ctrl+C leaves partial on disk” before work

### 9. visual-smoke-contracts

**Success:** The built-in smoke suite (`productteam smoke` / `tests/consult-smoke.sh`)
passes and the visual CLI surface (splash, theme) renders without ANSI leaks
in non-TTY contexts.

| Band | Criteria |
|------|----------|
| ≤5 | Smoke suite exits non-zero for a non-environmental reason |
| 6–8 | Smoke green only with `CONSULT_SMOKE_SKIP_CLIENT=1`; or one FAIL from state drift |
| 9–10 | `productteam smoke` exits 0 with no FAIL lines; splash renders statically in a pipe |

**Verification:**

- `bin/productteam smoke` — exit code + FAIL lines archived in
  `evidence/smoke-baseline.txt`
- Parity test sections 2 and 8 (help/splash ANSI-free in pipe)

### 10. dependencies-cold-start

**Success:** A fresh clone runs the CLI with only common POSIX tools
(`bash`, `jq`, `git`, coreutils); provider agents are detected, optional, and
their absence is reported honestly; tracked engagement state does not pin
machine-specific absolute paths that break cold-start commands.

| Band | Criteria |
|------|----------|
| ≤5 | A tracked command fails on a fresh checkout because state pins this machine's absolute paths |
| 6–8 | State pins absolute paths but commands self-heal or fail with a clear remedy |
| 9–10 | No machine-pinned absolute paths in tracked state; all cold-start commands run |

**Verification:**

- `lib/provider.sh` agent catalog detection (`bin/productteam agents --json`)
- `grep -R '/home/logani' state/engagements/` — machine-pinned paths in
  tracked state; command impact of `checks onboarding-flight-control`
  (exit 2, `workspace-metadata-mismatch`) captured in
  `evidence/checks-baseline.txt`
- `bin/productteam runtime --check` with `CONSULT_PROVIDER=/nonexistent` —
  non-zero + honest message

### 11. metadata-simplicity-deletion

**Success:** CLI state files (`state/style/*`, `state/.cli/*`, engagement
workspace metadata) are minimal, deduplicated, and deletable without breaking
cold-start reachability.

| Band | Criteria |
|------|----------|
| ≤5 | Duplicated metadata entries or stale files that force manual deletion to reach a command |
| 6–8 | One duplication or one vestigial file, no reachability impact |
| 9–10 | No duplicate entries; every state file is load-bearing or documented as deletable |

**Verification:**

- `bin/productteam style show --json` — no duplicated entries across
  taste/risk/stack/never (parity test section 10)
- `state/style/style.md` content diff (committed duplicate entry)
- Run-loop smoke scaffolding dirs: `tests/run-loop-smoke.sh` standalone exits
  0 and removes its `state/engagements/run-loop-*` scaffolding (trap cleanup)

---

## Verified iter-1 baseline defects (frozen evidence)

Scored before any implementation change. All three are reproduced with real
commands in this run directory; the parity test fails on them.

| Id | Defect | Evidence (repository-discovered) | Failing probe |
|----|--------|----------------------------------|---------------|
| **D1** | `productteam checks onboarding-flight-control` exits 2: `workspace-metadata-mismatch`. `state/engagements/onboarding-flight-control/workspace.json` pins `path` from a different worktree checkout; `workspace_ensure` hard-fails instead of self-healing on a cold checkout | `evidence/checks-baseline.txt`; `state/engagements/onboarding-flight-control/workspace.json` | parity 3 |
| **D3** | README omits 5 help-listed commands: `direction`, `pool`, `project-memory`, `run-loop`, `style` (help lists 32, README documents 27) | `evidence/readme-parity-diff.txt`; `bin/productteam help` vs `README.md` | parity 4 |
| **D5** | `style show --json` emits a duplicated entry (`rehearsal prefers file evidence` twice in `taste`) from committed `state/style/style.md` | `evidence/style-dup-baseline.txt`; `state/style/style.json` | parity 10 |

Additional baseline facts (passing, guarded by the parity test): chat refuses
non-TTY with TTY remedy; `/help` lists all 25 slash verbs and all 14
unsupported commands classify honestly; all five `--json` surfaces parse;
redirected output and `NO_COLOR=1` are ANSI-free while a color TTY emits ANSI;
multi-word argv round-trips byte-identical; unknown command and usage errors
exit non-zero; `productteam smoke` exits 1 with a single FAIL (`checks`,
same root cause as D1) — full transcript in `evidence/smoke-baseline.txt`.

## Minimum thresholds and stop conditions

- **Threshold:** every dimension ≥ 8.0 on the same scored iteration.
- **Convergence checklist (all must hold):** iter-1 baseline never rewritten;
  freeze SHA unchanged during the scored iteration; all 11 dimensions ≥ 8 with
  non-void evidence; Analyst authored scores; Critic re-audit recorded; parity
  test exits 0; real (non-mock) verification only.
- **Stop:** converged, or 6 iterations exhausted → write
  `convergence-report.md` in the run directory.

## Critical failures (void the iteration)

1. **Contract moved mid-run** — any edit to this file or `FREEZE-SHA.txt`
   during an active iteration (detectable: probe 1 hash mismatch).
2. **Fake/mocked validation** — fabricated command output, stub providers,
   or “green” results not produced by the claimed command against the real repo.
3. **Self-scoring** — Principal authored or overwrote the iteration scores.
4. **Silent baseline rewrite** — iter-1 evidence files altered retroactively.
