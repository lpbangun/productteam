# Final scores — cli-interface-20260812-v3 (iteration 2)

Evaluator: **FinalAnalyst** (independent; the Principal did not score and did not
author this artifact — contract "Scorer: Analyst only"). Scores are integers
0–10 per the frozen rubric in `CLI-BENCHMARK-CONTRACT.md`. All 31 parity probes
PASS (`evidence/parity-final.txt`), so no probe caps apply (scoring protocol
rule 3). Nothing was re-run for this audit; every claim cites recorded
artifacts and current source.

## Freeze integrity

- `FREEZE-SHA.txt` = `92f06ecd08e4e804e8c703af4a3af38519a7702ba2a72494fcdf9d596a6dc7f6`.
- Independent `sha256sum` of `CLI-BENCHMARK-CONTRACT.md` matches that hash
  exactly; parity probe 1 (`frozen contract hash matches FREEZE-SHA.txt`) PASS.
- The contract file and `FREEZE-SHA.txt` were not modified during the run
  (probe 1 + hash). The iter-1 baseline (`baseline-scores.json`,
  `evidence/*-baseline-*`) is untouched — no silent baseline rewrite.
- Repairs are uncommitted worktree changes on HEAD `1ebb52f`
  (`README.md`, `bin/productteam`, `lib/onboarding.sh`, `lib/repl.sh`,
  `lib/workspace.sh` modified; `lib/commands.sh` added); no contract files
  changed.

## Framework decision vs canonical CLI (scope clarification)

The Ink 7.1.1 and OpenTUI 0.5.1 prototypes were owner-required **bounded
disposable spikes** (`principal-decision.md`). Both were built, tested
(`evidence/ink-tests.txt` 35/35; `evidence/opentui-tests.txt` 31/31),
measured against the live CLI boundary (`framework-comparison.md`), and then
**deleted** because neither passed the retention gate: no recurring defect to
fix, no multiline editing or provider streaming implemented, no screen-reader
evidence, Node >=22 (Ink) / Bun-or-Node-26.4-FFI (OpenTUI) runtime floors,
22,860 KiB / 81,468 KiB installed trees, ~3 s live-data snapshots, and 0%
net deletion of replaceable Bash lines (`architecture-decision.md`,
`dependency-packaging-report.md`). The canonical Bash CLI/REPL is retained and
is the scored subject. **Framework disposal is an evidence decision, not a
failure of any frozen dimension; no dimension is docked for it.**

## Parity, smoke, visual, and live evidence (all green)

- `evidence/parity-final.txt` — cli-interface parity v3: **31/31 PASS**, no FAIL.
- `evidence/smoke-final.txt` — `productteam smoke`: **41/41 PASS**, "all smoke checks passed" (exit 0).
- `evidence/visual-final.json` — visual-cli-v2: **14/14 PASS**, `converged: true`, `live_provider_proof: pass`.
- `evidence/live-chat-cycle.typescript` — real authenticated `agent` runtime
  through the retained chat path: `Reply with exactly LIVE-CYCLE-OK` → agent
  8 s → `✓ done ◇ Analyst · 8s · 1.txt` → `LIVE-CYCLE-OK`, exit 0. Real
  provider execution, not a fixture (contract "no mocks" rule).
- `evidence/harness-checks-final/checks.json` — harness-apc suite **57/57**, `validation: real-commands`.
- `evidence/ink-tests.txt` 35/35 and `evidence/opentui-tests.txt` 31/31 —
  spike suites only; neither framework retained (see above).

## Dimension scores (rationale + evidence)

### 1. reachability — 9
Probe 2 PASS (`help`/`-h`/`--help` exit 0 and name all 32 commands); probe 3
PASS (`checks onboarding-flight-control` exits 0 on a cold checkout; a
pre-existing marker directory at the would-be workspace path survives
byte-identical). D1 fixed in `lib/workspace.sh` `workspace_ensure`: metadata is
recreated only when the recorded path is absent; a recorded path that still
exists is left byte-identical and the canonical workspace is used
(`workspace-metadata-recreate` / `workspace-metadata-repoint` messages) —
never deleted, relocated, reset, or overwritten. Registry-driven dispatch
(`bin/productteam:1422-1425`) routes all 32 names; unknown commands die
non-zero (probe 16). `smoke-final.txt` green; `harness-checks-final` 57/57;
`usage-parity-probes.txt` shows 9 misuse probes exit 1 with help-matching
usage. **9 not 10**: `report` and `inspect` are named/routed but their happy
path is not directly executed in the archived final evidence, and the repoint
branch proceeds exit 0 (the frozen probe's expectation) rather than
hard-refusing non-zero on an existing foreign recorded path.

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
and usage errors exit non-zero). `evidence/usage-parity-probes.txt`: 9 misuse
probes + unknown command all exit 1 naming the usage the help table promises.
Baseline cosmetic notes (pool `list --bogus` error prefix; `bin/consult`
forms in README body) are outside the rubric anchors (usage-line enforcement
and slash-forwarding identity) and appear in no failing probe.

### 4. help-readme-onboarding-parity — 10
Probe 4 PASS — README documents every help-listed command (32/32; quickstart
plus the 32-row CLI-surface table). Probe 12 PASS — `onboarding --yes`
next-step text uses current `score <client> --iter <n>` syntax;
`lib/onboarding.sh:51` now prints the `--iter` form (baseline D4 stale
`productteam score <client>` fixed), and onboarding succeeds on an isolated
state root.

### 5. argv-safety — 10
Probe 9 PASS (quoted slash argv parses as one value; embedded `;$(…)` inert —
nothing executed). Probe 14 PASS (multi-word argv round-trips byte-identical;
empty argv rejected non-zero). `lib/repl.sh` `repl_tokenize` honors
single/double quotes and backslash, never evals, never re-parses.

### 6. frontend-machine-boundary — 10
Probe 6 PASS — `help --json` emits the frozen registry shape (32 commands with
`usage`/`chat_supported`/`chat_reason`; 6 `chat_only`) with membership matching
§2. Probe 11 PASS — `status --json` lists engagements including
onboarding-flight-control and harness-evolution. Probe 10 PASS — every existing
machine surface parses (agents/card list/style show/pool list/project-memory
show/escalation status/gate/workspace/role). `cmd_help_json`
(`lib/commands.sh:96-112`), `cmd_status_json` (`bin/productteam:287-331`);
README `Machine-readable boundaries` table documents each surface.

### 7. non-tty-redirect-nocolor-exit — 10
Probe 13 PASS — `bench harness-evolution` and `run harness-evolution 7`
handle the summary-shaped `runs/iter-7/scores.json` (`"scores": null`)
honestly with rc=1, no `jq: error`, never exit 5 (baseline D7 raw-jq
traceback fixed: `cmd_bench` filters non-contract-shaped history rows;
`cmd_run_detail` shape-checks and dies with the shape plus a re-score remedy).
Probe 15 PASS — redirected output and TTY+`NO_COLOR=1` zero ESC bytes; color
TTY emits ANSI. Probe 16 PASS — exit-code honesty on unknown command and
usage errors.

### 8. ctrl-c-child-cleanup-partial-artifacts — 9
Code contract: `repl_ask` scoped `trap INT` → `repl_interrupt_cleanup`
(kill of the provider process group `-pid` with pid fallback, reap, `rc=130`,
worker marked failed, partial artifact preserved with `Ctrl+C leaves partial
on disk`); REPL survives; run-loop traps TERM/INT → `loop_pause_for_signal`
(paused + `--resume`). Runtime proof: `evidence/visual-final.json` 14/14
including `honest-partial-output` (SIGINT keeps REPL alive; artifact
bytes/path preserved; worker marked failed; clean exit) with live provider
proof; smoke-final run-loop PASS. **9 not 10**: artifact/worker/REPL-alive
are evidenced in the recorded transcript; the literal `130` exit recording is
code-verifiable (`rc=130`) but not shown in an archived output transcript.

### 9. visual-smoke-contracts — 10
`productteam smoke` 41/41 PASS with no FAIL lines (baseline single FAIL
`checks` gone). Probe 15 PASS — splash renders statically in a pipe, ANSI-free.
`evidence/visual-final.json` 14/14 with live provider proof.

### 10. dependencies-cold-start — 8
Cold-start defect repaired: probe 3 PASS — `checks onboarding-flight-control`
exits 0 on a cold checkout; recovery automatic and non-destructive; runtime
honesty holds (smoke: `runtime --check` refuses a missing provider). However,
the rubric's 9-10 anchor requires **"No machine-pinned absolute paths in
tracked state"**, and tracked engagement metadata still pins this machine's
paths: `state/engagements/onboarding-flight-control/workspace.json`
(committed; `git diff HEAD` empty) records
`/home/logani/.herdr/worktrees/Product Consulting Harness/test-rapid-basics/tmp/workspaces/onboarding-flight-control`
with `exists: true`, and `/home/logani` paths remain in overnight-rehearsal
and harness-cli tracked metadata. The repair removed the command impact
(commands now self-heal fully automatically and non-destructively), so the
dimension sits at the top of band 6-8 ("state pins absolute paths but
commands self-heal"), not 9-10.

### 11. metadata-simplicity-deletion — 9
CLI state minimal: `state/.cli` gitignored (5-byte `first-run` + one config
line, atomic tmp+rename); the only repair-introduced artifact is
`lib/commands.sh` — source, not state; no daemon, no duplicate authority.
v3 scope note honored: `state/style/*` untouched (out of scope org memory;
critical failure #6 avoided). Deletion paths exist (`workspace remove`
clean-worktree-only, `direction clear --i-am-owner`); run-loop smoke
scaffolding cleans up after itself (`tests/run-loop-smoke.sh` trap cleanup;
smoke-final overnight run-loop PASS; parity harnesses remove their fresh
state roots and tmp workspaces on exit). **9 not 10**: the standalone
`tests/run-loop-smoke.sh` is trap-cleanup code-verified and its loop covered
by smoke-final, but it is not itself archived as a standalone run in the
final evidence.

## Overall and convergence

- **Mean: 9.5** — 105/11 = 9.545 → one decimal 9.5.
- Baseline (iter-1, never rewritten): 5.5 (61/11); improvement **+4.0**.
- Per-dimension: 9, 10, 10, 10, 10, 10, 10, 9, 10, 8, 9.
- **Converged: false** under this assignment's rule (converged true only if
  every dimension >= 9) because dimension 10 (dependencies-cold-start) = 8:
  tracked state still pins machine-specific absolute paths. The frozen
  contract's own convergence checklist threshold (every dimension >= 8.0 with
  the parity test green, baseline intact, freeze SHA unchanged, Analyst-
  authored scores, real verification, thin registry) is met on every item the
  recorded evidence can verify.

## Guards honored

- Principal never scored and did not author this artifact.
- Baseline and freeze files untouched; no commands, tests, formatters, or
  linters run for this audit; all evidence cited from recorded artifacts and
  current source.
