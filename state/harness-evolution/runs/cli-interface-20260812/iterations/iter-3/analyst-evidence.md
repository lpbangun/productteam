# Analyst evidence — cli-interface-20260812-v3 (iteration 3, no-change re-benchmark)

Evaluator: **Analyst (AnalystIter3, independent)** — the Principal did not score and did
not author this artifact (contract "Scorer: Analyst only"). Iteration 3 of the
user-specified six-iteration cap (`max-iteration-plan.md`).

## Audit method

Read-only evidence audit only. **No commands, tests, formatters, or linters were
run** (assignment acceptance: "No commands"). The frozen v3 rubric
(`CLI-BENCHMARK-CONTRACT.md`, SHA-256 `92f06ecd…` per `FREEZE-SHA.txt`) was
applied independently to the **unchanged iteration-2 deliverable**: no file was
modified, added, or removed by this iteration, so the immutable iteration-2
verification artifacts are the current evidence and are reused as cited. Every
claim below cites a recorded artifact or current source path.

## No-change record

- **Accepted work:** none. No safe work item has positive benchmark lift
  (`max-iteration-plan.md`): rewriting the machine-pinned engagement records
  would corrupt immutable historical evidence, and deleting external-repo
  identity would break plain-file authority.
- **Code delta since iteration 2:** zero. Subject remains the uncommitted repair
  worktree on HEAD `1ebb52f` (`bin/productteam`, `lib/commands.sh`,
  `lib/repl.sh`, `lib/workspace.sh`, `lib/onboarding.sh`, `README.md`,
  `tests/cli-interface-parity.sh`); contract file and `FREEZE-SHA.txt` untouched.
- **Score integrity:** no score inflation. Dimension 10 is held at 8 rather than
  forcing the 9-10 anchor by scrubbing tracked state.

## Freeze integrity

- `FREEZE-SHA.txt` = `92f06ecd08e4e804e8c703af4a3af38519a7702ba2a72494fcdf9d596a6dc7f6`
  (SHA-256 of `CLI-BENCHMARK-CONTRACT.md`); parity probe 1 PASS.
- Iter-1 baseline (`baseline-scores.json`, `evidence/*-baseline-*`) untouched —
  no silent baseline rewrite. This iteration appended only `iterations/iter-3/`.

## Verification artifacts (current evidence, reused)

| Artifact | Recorded result |
|----------|-----------------|
| `evidence/parity-final.txt` | cli-interface parity v3: **31/31 PASS**, no FAIL (probes 1-16 incl. registry membership 32/18/14/6, PTY 24-verb palette, slash forwarding, ANSI, exit honesty) |
| `evidence/smoke-final.txt` | `productteam smoke`: all checks PASS, no FAIL lines, `all smoke checks passed` (exit 0) |
| `evidence/visual-final.json` | visual-cli-v2: **14/14 PASS**, `converged: true`, `live_provider_proof: pass` (incl. `honest-partial-output`) |
| `evidence/live-chat-cycle.typescript` | real authenticated `agent` runtime: `Reply with exactly LIVE-CYCLE-OK` → `LIVE-CYCLE-OK`, exit 0 — no mocks (contract rule 6) |
| `evidence/harness-checks-final/checks.json` | harness-apc: **57/57**, `validation: real-commands` |
| `evidence/usage-parity-probes.txt` | 9 misuse probes + unknown command exit 1 with usage matching help |
| `evidence/bench-harness-evolution.txt`, `evidence/run-harness-evolution-7.txt` | baseline D7 raw `jq: error` exit 5; final handles summary-shaped scores honestly (rc=1) |
| `evidence/style-dup-baseline.txt` | v3 out-of-scope org-memory record, retained untouched |

## Dimension scores (frozen v3 rubric, integers 0-10)

| # | Dimension | Score | Primary evidence |
|---|-----------|------:|------------------|
| 1 | reachability | **9** | Parity probes 2, 3 PASS (32-command help surface; `checks onboarding-flight-control` rc=0; non-destructive guard). D1 recovery in `lib/workspace.sh:66-101` recreates metadata only when the recorded path is absent, repoints otherwise, never deletes a worktree. Registry dispatch `bin/productteam:1422-1425`. 9 not 10: `report`/`inspect` happy paths not directly executed in archived final evidence; repoint branch exits 0 (frozen probe expectation) rather than hard-refusing on a foreign recorded path |
| 2 | chat-reachability-classification | **10** | Probes 5-9 PASS: non-TTY refusal, registry membership 32/18/14/6, PTY 24-verb palette with per-unsupported `unknown /X — /help` + non-empty `chat_reason`, `--iter` forwarding to stamp refusal, quoted `/provider "codex"`. Real provider: `live-chat-cycle.typescript` |
| 3 | argument-usage-parity | **10** | Probes 8, 16 PASS; slash forwarding argument-identical to CLI path (same stamp-refusal downstream); `usage-parity-probes.txt` misuse rows exit 1 with help-matching usage |
| 4 | help-readme-onboarding-parity | **10** | Probes 4, 12 PASS: README documents all 32 commands; `lib/onboarding.sh:51` prints current `score <client> --iter <n>` syntax (D4 fixed); onboarding succeeds on isolated state root |
| 5 | argv-safety | **10** | Probes 9, 14 PASS: quoted slash argv parses as one value, embedded `;$(…)` inert; CLI multi-word argv round-trips byte-identical, empty argv rejected. `repl_tokenize` (`lib/repl.sh:349-389`) — no eval, no re-parse |
| 6 | frontend-machine-boundary | **10** | Probes 6, 10, 11 PASS: `help --json` frozen registry shape; `status --json` engagement list; all existing JSON surfaces parse; README Machine-readable boundaries table |
| 7 | non-tty-redirect-nocolor-exit | **10** | Probes 13, 15, 16 PASS: summary-shaped scores handled honestly (rc=1, no `jq: error`, never exit 5); zero ESC bytes redirected and under `NO_COLOR=1`, ANSI on color TTY; exit-code honesty |
| 8 | ctrl-c-child-cleanup-partial-artifacts | **9** | Code contract: scoped `trap INT` → `repl_interrupt_cleanup` (killpg, reap, rc=130, worker failed, partial bytes preserved, REPL survives); run-loop traps to `loop_pause_for_signal`. Runtime: `visual-final.json` 14/14 incl. `honest-partial-output` + live provider proof; smoke run-loop PASS. 9 not 10: literal 130 recording code-verified (`lib/repl.sh:312`) but not in an archived interrupt transcript |
| 9 | visual-smoke-contracts | **10** | `smoke-final.txt` all checks PASS, no FAIL lines, exit 0; probe 15 splash/help ANSI-free in pipe; `visual-final.json` 14/14 with live provider proof |
| 10 | dependencies-cold-start | **8** | Probe 3 PASS (cold-checkout rc=0, automatic non-destructive recovery); runtime honesty holds. **Not 9-10**: the frozen 9-10 anchor requires *no machine-pinned absolute paths in tracked state*, and tracked `state/engagements/onboarding-flight-control/workspace.json` (source_repo `/home/logani/projects/onboarding-flight-control`; path `/home/logani/.herdr/worktrees/Product Consulting Harness/test-rapid-basics/tmp/workspaces/onboarding-flight-control`, `exists: true`) and `state/engagements/overnight-rehearsal/workspace.json` (`/home/logani/.herdr/worktrees/Product Consulting Harness/feature-agent-socials/tmp/workspaces/overnight-rehearsal`; source_repo `/tmp/tmp.AlFUDSL4oL/client`) still pin machine paths. Commands self-heal fully, so the dimension sits at the top of band 6-8. **Exact blocker** — see below |
| 11 | metadata-simplicity-deletion | **9** | `state/.cli` gitignored (5-byte `first-run` + one config line, atomic tmp+rename); registry is source (`lib/commands.sh`), not state; no daemon/duplicate authority; v3 scope note honored (`state/style/*` untouched, critical failure #6 avoided); deletion paths exist; run-loop smoke scaffolding self-cleans. 9 not 10: standalone `tests/run-loop-smoke.sh` not itself archived as a standalone final run |

## Arithmetic

Sum of the 11 integer scores: 9+10+10+10+10+10+10+9+10+8+9 = **105**.
Mean: 105/11 = 9.545 → **overall 9.5** (one decimal, contract scoring protocol
rule 4). Baseline iter-1 mean 5.5 (61/11); improvement **+4.0**. Per-dimension
profile: 9, 10, 10, 10, 10, 10, 10, 9, 10, 8, 9 — identical to iteration 2, as
required for a no-change re-benchmark.

## Convergence

- **Converged: false** — per this assignment's rule, converged is true only if
  every dimension ≥ 9; dimension 10 (dependencies-cold-start) = 8.
- The frozen contract's own convergence checklist (every dimension ≥ 8.0, parity
  test green, iter-1 baseline never rewritten, freeze SHA unchanged,
  Analyst-authored scores, Critic re-audit, real verification, thin registry) is
  met on every item the recorded evidence can verify. Both thresholds are stated
  explicitly (critic-final-verdict.md nit 4) so the ≥ 9 overlay is not read as a
  silent contract amendment.

## Exact blocker (dimension 10)

The frozen 9-10 anchor for `dependencies-cold-start` — *"No machine-pinned
absolute paths in tracked state"* — conflicts with immutable historical
evidence. Tracked engagement metadata pins this machine's absolute paths
(`/home/logani/…` in `state/engagements/onboarding-flight-control/workspace.json`
and `state/engagements/overnight-rehearsal/workspace.json`, both committed and
unmodified vs HEAD). Those records are valid historical evidence of prior
machine-bound worktrees and engagement briefs identifying external client
repositories: rewriting them would corrupt evidence, and deleting external-repo
identity would break plain-file authority. The permanent Critic explicitly
accepted non-convergence over score-gaming
(`critic-final-verdict.md` §2, §6: "Do not scrub `state/engagements/*/workspace.json`
… to chase the 9–10 anchor"), and `max-iteration-plan.md` records that no safe
work item has positive benchmark lift. This iteration therefore accepts no work
and holds dimension 10 at 8, consuming iteration 3 of the six-iteration cap
honestly.

## Guards honored

- Principal never scored and did not author this artifact (evaluator: Analyst).
- No commands, tests, formatters, or linters run for this audit; all evidence
  cited from recorded artifacts and current source.
- Baseline and freeze files untouched; only `iterations/iter-3/` appended.
- No score inflation: the blocker is recorded, not papered over.
