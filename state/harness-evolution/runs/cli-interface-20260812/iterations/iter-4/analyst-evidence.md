# Iteration 4 Analyst scores — cli-interface-20260812-v3 (no-change re-benchmark)

Evaluator: **Analyst** (independent; the Principal did not score and did not
author this artifact — contract "Scorer: Analyst only"). Scores are integers
0–10 per the frozen rubric in `CLI-BENCHMARK-CONTRACT.md`. This is iteration 4
of the six-iteration cap: a no-change re-benchmark of the **unchanged
iteration-2 deliverable**, executed per `max-iteration-plan.md`. All evidence
is reused from the immutable final verification artifacts because no code
changed; **no commands, tests, formatters, or linters were run for this
audit.**

## No-change confirmation (iteration 4 vs iteration 2)

- Git status is identical to the iteration-2 audit: `README.md`,
  `bin/productteam`, `lib/onboarding.sh`, `lib/repl.sh`, `lib/workspace.sh`
  modified; `lib/commands.sh` and `tests/cli-interface-parity.sh` untracked;
  HEAD `1ebb52f` (`fix(harness): pool cite leak, specialist sed corruption,
  iter validation`).
- Contract file and `FREEZE-SHA.txt` untouched: independent `sha256sum` of
  `CLI-BENCHMARK-CONTRACT.md` = `92f06ecd08e4e804e8c703af4a3af38519a7702ba2a72494fcdf9d596a6dc7f6`
  matches `FREEZE-SHA.txt` exactly (parity probe 1 PASS).
- No accepted work, no code delta. `max-iteration-plan.md` documents that no
  safe work item has positive benchmark lift for iterations 3–6; the
  iteration-2 repair (`final-scores.json` / `final-evidence.md`,
  `critic-final-verdict.md` ACCEPT) is the scored deliverable.

## Evidence re-verified as present and unchanged

- `evidence/parity-final.txt` — cli-interface parity v3: **31/31 PASS**, no FAIL.
- `evidence/smoke-final.txt` — `productteam smoke`: **41/41 PASS**,
  "all smoke checks passed" (exit 0).
- `evidence/visual-final.json` — visual-cli-v2: **14/14 PASS**,
  `converged: true`, `live_provider_proof: pass`.
- `evidence/live-chat-cycle.typescript` — real authenticated `agent` runtime
  through the retained chat path: `LIVE-CYCLE-OK`, exit 0 (no mocks).
- `evidence/harness-checks-final/checks.json` — 57/57, `validation: real-commands`.
- `evidence/usage-parity-probes.txt` — 10 misuse/unknown rows, each exit 1
  with usage matching help.
- `evidence/bench-harness-evolution.txt`, `evidence/run-harness-evolution-7.txt` —
  baseline D7 raw-jq exit 5 record (now fixed, probes 13 PASS).
- `state/engagements/onboarding-flight-control/workspace.json` — tracked,
  machine-pinned `/home/logani/...` paths, `git diff HEAD` empty (unchanged
  since iteration 2; the dimension-10 blocker).
- `state/.cli/` — gitignored (`.gitignore:3`), 5-byte `first-run` marker;
  session scratch under `state/.cli/runs/` is transient, untracked REPL
  chat-cycle output.

## Dimension scores (rationale + evidence)

### 1. reachability — 9
Probe 2 PASS (`help`/`-h`/`--help` exit 0 and name all 32 commands); probe 3
PASS (`checks onboarding-flight-control` exits 0 on a cold checkout; a
pre-existing marker directory at the would-be workspace path survives
byte-identical). D1 policy enforced in `lib/workspace.sh` `workspace_ensure`:
metadata recreated only when the recorded path is absent
(`workspace-metadata-recreate`); an existing recorded path is left
byte-identical and the canonical workspace is used
(`workspace-metadata-repoint`) — never deleted, relocated, reset, or
overwritten. Registry-driven dispatch (`bin/productteam:1422-1425`) routes all
32 names; unknown commands die non-zero (probe 16; `usage-parity-probes.txt`
`not-a-command`). `smoke-final.txt` 41/41; `harness-checks-final` 57/57.
**9 not 10**: `report` and `inspect` are named/routed but their happy path is
not directly executed in the archived final evidence, and the repoint branch
proceeds exit 0 (the frozen probe's expectation) rather than hard-refusing
non-zero on an existing foreign recorded path.

### 2. chat-reachability-classification — 10
Probe 5 (non-TTY refusal with TTY remedy), probe 6 (registry membership
32/18/14/6 cross-checked set-for-set), probe 7 (PTY `/help` = full 24-verb
registry-derived palette; all 14 unsupported commands yield
`unknown /X — /help` with non-empty registry `chat_reason`), probe 8
(`/score <client> --iter 0` and `/bench <client> run --iter 7` forward `--iter`
and reach the honest Analyst-stamp refusal `scores invalid: missing Analyst
stamp …` — never a missing-iter/usage error), probe 9 (quoted `/provider
"codex"` → codex, no eval). Real authenticated agent cycle through chat
(`evidence/live-chat-cycle.typescript`). Source: `lib/commands.sh` registry
(18 supported / 14 unsupported with safety-usefulness reasons / 6 chat-only);
`lib/repl.sh` `repl_palette_build` + `repl_run_slash` drive `/help`, hints,
routing, and classification from the registry.

### 3. argument-usage-parity — 10
Slash forwarding is argument-identical to the CLI path (probe 8 PASS: same
stamp-refusal downstream as the CLI controls). Probe 16 PASS (unknown command
and usage errors exit non-zero). `evidence/usage-parity-probes.txt`: 10 rows
(`open`, `workspace <client>`, `score`, `run-loop`, `gh`, `skill`,
`splash --bogus`, `onboarding --bogus`, `agents --bogus`, `not-a-command`) all
exit 1 naming the usage the help table promises. Baseline cosmetic notes (pool
`list --bogus` error prefix; `bin/consult` forms in README body) are outside
the rubric anchors (usage-line enforcement and slash-forwarding identity) and
appear in no failing probe.

### 4. help-readme-onboarding-parity — 10
Probe 4 PASS — README documents every help-listed command (32/32). Probe 12
PASS — `onboarding --yes` next-step text uses current
`productteam score <client> --iter <n>` syntax; `lib/onboarding.sh:51` now
prints the `--iter` form (baseline D4 stale `productteam score <client>`
fixed), and onboarding succeeds on an isolated state root.

### 5. argv-safety — 10
Probe 9 PASS (quoted slash argv parses as one value; embedded `;$(…)` inert —
nothing executed). Probe 14 PASS (multi-word argv round-trips byte-identical;
empty argv rejected non-zero). `lib/repl.sh` `repl_tokenize` honors
single/double quotes and backslash, never evals, never re-parses. All four
9–10 criteria evidenced.

### 6. frontend-machine-boundary — 10
Probe 6 PASS — `help --json` emits the frozen registry shape (32 commands with
`usage`/`chat_supported`/`chat_reason`; 6 `chat_only`) with membership matching
§2. Probe 11 PASS — `status --json` lists engagements including
onboarding-flight-control and harness-evolution. Probe 10 PASS — every existing
machine surface parses (agents/card list/style show/pool list/project-memory
show/escalation status). `cmd_help_json` (`lib/commands.sh:96-112`),
`cmd_status_json` (`bin/productteam:287-331`); README `Machine-readable
boundaries` table documents each surface.

### 7. non-tty-redirect-nocolor-exit — 10
Probe 13 PASS — `bench harness-evolution` and `run harness-evolution 7`
handle the summary-shaped `runs/iter-7/scores.json` (`"scores": null`)
honestly with rc=1, no `jq: error`, never exit 5 (baseline D7 fixed:
`cmd_bench` filters non-contract-shaped history rows; `cmd_run_detail`
shape-checks and dies with the shape plus a re-score remedy). Probe 15 PASS —
redirected output and TTY+`NO_COLOR=1` zero ESC bytes; color TTY emits ANSI.
Probe 16 PASS — exit-code honesty on unknown command and usage errors.

### 8. ctrl-c-child-cleanup-partial-artifacts — 9
Code contract: `repl_ask` scoped `trap INT` → `repl_interrupt_cleanup`
(kill of the provider process group `-pid` with pid fallback, reap, `rc=130`,
worker marked failed, partial artifact preserved with `Ctrl+C leaves partial
on disk`); REPL survives; run-loop traps TERM/INT → `loop_pause_for_signal`
(paused + `--resume`). Runtime proof: `evidence/visual-final.json` 14/14
including `honest-partial-output` (SIGINT keeps REPL alive; artifact
bytes/path preserved; worker marked failed; clean exit) with live provider
proof; smoke-final run-loop PASS. **9 not 10**: the literal `130` exit
recording is code-verifiable (`rc=130`) but not shown in an archived output
transcript.

### 9. visual-smoke-contracts — 10
`productteam smoke` 41/41 PASS with no FAIL lines (baseline single FAIL
`checks` gone). Probe 15 PASS — splash renders statically in a pipe,
ANSI-free. `evidence/visual-final.json` 14/14 with live provider proof.

### 10. dependencies-cold-start — 8
Cold-start defect repaired and stable: probe 3 PASS — `checks
onboarding-flight-control` exits 0 on a cold checkout; recovery automatic and
non-destructive; runtime honesty holds (smoke: `runtime --check` refuses a
missing provider). **However**, the rubric's 9–10 anchor requires **"No
machine-pinned absolute paths in tracked state"**, and tracked engagement
metadata still pins this machine's paths:
`state/engagements/onboarding-flight-control/workspace.json` (tracked; `git
diff HEAD` empty — unchanged since iteration 2) records
`/home/logani/.herdr/worktrees/Product Consulting Harness/test-rapid-basics/tmp/workspaces/onboarding-flight-control`
with `exists: true` and a `/home/logani` `source_repo`; overnight-rehearsal
and harness-cli tracked metadata likewise pin `/home/logani` paths. The repair
removed the command impact (commands now self-heal fully automatically and
non-destructively), so the dimension sits at the top of band 6–8 ("state pins
absolute paths but commands self-heal"), not 9–10. **This is the exact
documented blocker**: the frozen 9–10 wording conflicts with immutable
historical evidence; rewriting those records would corrupt evidence and
deleting external-repo identity would break plain-file authority. The
permanent Critic explicitly accepted non-convergence over score-gaming
(`critic-final-verdict.md`, `max-iteration-plan.md`).

### 11. metadata-simplicity-deletion — 9
CLI state minimal: `state/.cli` gitignored (`.gitignore:3`) holding the 5-byte
`first-run` marker plus one config line, atomic tmp+rename; session scratch
under `state/.cli/runs/` is transient, untracked REPL chat-cycle output. The
only repair-introduced artifact is `lib/commands.sh` — source, not state; no
daemon, no duplicate authority. v3 scope note honored: `state/style/*`
untouched (out of scope org memory; critical failure #6 avoided). Deletion
paths exist (`workspace remove` clean-worktree-only, `direction clear
--i-am-owner`); run-loop smoke scaffolding cleans up after itself
(`tests/run-loop-smoke.sh` trap cleanup; smoke-final overnight run-loop PASS;
parity harnesses remove their fresh state roots and tmp workspaces on exit).
**9 not 10**: the standalone `tests/run-loop-smoke.sh` is trap-cleanup
code-verified and its loop covered by smoke-final, but it is not itself
archived as a standalone run in the final evidence.

## Overall and convergence

- **Mean: 9.5** — 105/11 = 9.545 → one decimal 9.5.
- Baseline (iter-1, never rewritten): 61/11 = 5.5 (independently recomputed
  from `baseline-scores.json`); improvement **+4.0**.
- Per-dimension: 9, 10, 10, 10, 10, 10, 10, 9, 10, 8, 9.
- **Converged: false** under this run's rule (converged true only if every
  dimension ≥ 9) because dimension 10 (dependencies-cold-start) = 8: tracked
  state still pins machine-specific absolute paths, and the frozen 9–10
  anchor conflicts with immutable historical records. The frozen contract's
  own convergence checklist threshold (every dimension ≥ 8.0 with the parity
  test green, baseline intact, freeze SHA unchanged, Analyst-authored scores,
  Critic re-audit, real verification, thin registry) is met on every item the
  recorded evidence can verify; the ≥9 overlay is the documented reason the
  run consumes its six-iteration cap without convergence.

## Blocker (exact, unchanged since iteration 2)

| | |
|---|---|
| Dimension | `dependencies-cold-start` (10) |
| Score | 8 |
| Frozen 9–10 anchor | "No machine-pinned absolute paths in tracked state" |
| Conflict | Tracked historical engagement metadata immutably pins `/home/logani` paths (`state/engagements/onboarding-flight-control/workspace.json`, `exists: true`; overnight-rehearsal and harness-cli tracked files) |
| Decision | Scrubbing would corrupt immutable evidence and break plain-file authority; permanent Critic accepted non-convergence (`critic-final-verdict.md`), planned across iterations 3–6 (`max-iteration-plan.md`). No repair is safe; iteration 4 records **no accepted work, no code delta**. |

## Guards honored

- Principal never scored and did not author this artifact (contract "Scorer:
  Analyst only").
- Baseline (`baseline-scores.json`, `evidence/*-baseline-*`) and freeze files
  untouched; no retroactive rewrite.
- No commands, tests, formatters, or linters run for this audit; all evidence
  cited from recorded artifacts verified present in the run directory and
  from current source.
- Iteration 4 writes only `iterations/iter-4/analyst-scores.json` and
  `iterations/iter-4/analyst-evidence.md`; no production/run-root edits.
