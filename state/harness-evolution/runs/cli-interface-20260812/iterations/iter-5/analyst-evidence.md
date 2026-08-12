# Iteration 5 analyst evidence — cli-interface-20260812-v3 (no-change re-benchmark)

Evaluator: **Analyst** (independent; `AnalystIter5` worker; the Principal did not
score and did not author this artifact — contract "Scorer: Analyst only").
Scores are integers 0–10 per the frozen rubric in `CLI-BENCHMARK-CONTRACT.md`
(`cli-interface-20260812-v3`). Iteration 5 is one of the four bounded no-change
iterations (3–6) defined in `max-iteration-plan.md`: no safe work item has
positive benchmark lift, so **no work was accepted and no code delta exists**.
The scored subject is the unchanged iteration-2 deliverable on HEAD `1ebb52f`
(uncommitted repair worktree); current implementation and archived evidence
were re-verified read-only this iteration and match the iteration-2 citations.
**No commands, tests, formatters, or linters were run**; frozen iteration-2
final artifacts are reused as evidence (max-iteration-plan.md: "reuse current
immutable final verification artifacts because code does not change").

## Freeze integrity (re-verified)

- `FREEZE-SHA.txt` still reads
  `92f06ecd08e4e804e8c703af4a3af38519a7702ba2a72494fcdf9d596a6dc7f6  state/harness-evolution/runs/cli-interface-20260812/CLI-BENCHMARK-CONTRACT.md`.
- `evidence/parity-final.txt` probe 1 ("frozen contract hash matches
  FREEZE-SHA.txt") is PASS; the contract file and `FREEZE-SHA.txt` were not
  modified during the run. The iter-1 baseline (`baseline-scores.json`,
  `evidence/*-baseline-*`) is untouched — no silent baseline rewrite.
- This Analyst's writes are limited to `iterations/iter-5/` (scores + evidence);
  no run-root or production edits.

## No-change rationale

`max-iteration-plan.md` (iterations 3–6): iteration 2 repaired every product
defect and passed every frozen executable probe (parity 31/31). The only
sub-9 dimension is `dependencies-cold-start` (8), whose exact frozen 9–10
anchor — "No machine-pinned absolute paths in tracked state" — conflicts with
tracked immutable historical evidence containing machine-local paths and
engagement briefs identifying external client repositories. Rewriting those
records would corrupt evidence; deleting external-repo identity would break
plain-file authority. The permanent Critic explicitly accepted non-convergence
rather than score-gaming (`critic-final-verdict.md`: "Do not scrub
`state/engagements/*/workspace.json` (or sibling historical metadata) to chase
the 9–10 anchor"). Re-applying the unchanged v3 rubric therefore yields the
same evidence-bound integers as iteration 2: no inflation, no gaming.

## Re-verified evidence (all current, read-only)

- `evidence/parity-final.txt` — cli-interface parity v3: **31/31 PASS**, no FAIL.
- `evidence/smoke-final.txt` — `productteam smoke`: exit 0, "all smoke checks
  passed", no FAIL lines (archived file holds 55 PASS rows as of this audit;
  the iteration-2 narrative's "41/41" is superseded by the file's actual row
  count — the dimension-9 anchor is exit 0 + no FAIL, so no score impact).
- `evidence/visual-final.json` — visual-cli-v2: **14/14 PASS**, `converged: true`,
  `live_provider_proof: pass`.
- `evidence/live-chat-cycle.typescript` — real authenticated `agent` runtime
  through the retained chat path: `Reply with exactly LIVE-CYCLE-OK` → agent
  8 s → `✓ done ◇ Analyst` → `LIVE-CYCLE-OK` (exit 0). Real provider
  execution, not a fixture (contract "no mocks" rule).
- `evidence/harness-checks-final/checks.json` — harness-apc suite **57/57**
  pass, `"failed": 0`, `"validation": "real-commands"`.
- `evidence/usage-parity-probes.txt` — 9 misuse probes + unknown command
  (10 rows), all exit 1 naming the usage the help table promises.
- Source spot-checks (unchanged from iteration 2): `lib/commands.sh` 32
  `cmd_reg_add` rows + `CMD_CHAT_ONLY=(provider workers clear export exit quit)`
  + `cmd_help_json` (108–122); `lib/workspace.sh:76-80`
  `workspace-metadata-repoint`/`workspace-metadata-recreate`;
  `lib/repl.sh:225-232, 311-317` interrupt cleanup with `rc=130`, `:349-389`
  `repl_tokenize` (no eval), `:391-471` palette/routing/forwarding;
  `lib/onboarding.sh:51` prints `productteam score <client> --iter <n>`;
  `bin/productteam:287-331` `cmd_status_json`, `:1422-1425` `cmd_reg_index`
  dispatch; `README.md:65` 32-command table, `:116` Machine-readable
  boundaries; `.gitignore:3` `state/.cli/`.

## Dimension scores (rationale + evidence)

### 1. reachability — 9
Probe 2 PASS (help/-h/--help exit 0 and name all 32 commands); probe 3 PASS
(checks onboarding-flight-control exits 0 on a cold checkout; a pre-existing
marker directory at the would-be workspace path survives byte-identical). D1
fixed in `lib/workspace.sh` `workspace_ensure`: metadata recreated only when
the recorded path is absent; an existing recorded path is left byte-identical
and the canonical workspace is used — never deleted, relocated, reset, or
overwritten. Registry-driven dispatch routes all 32 names; unknown commands
die non-zero (probe 16). smoke green; harness-checks 57/57;
`usage-parity-probes.txt` 10 rows exit 1. **9 not 10**: `report`/`inspect`
happy paths not directly executed in archived final evidence; repoint branch
proceeds exit 0 (the frozen probe's expectation) rather than hard-refusing
non-zero on an existing foreign recorded path.

### 2. chat-reachability-classification — 10
Probe 5 (non-TTY refusal with TTY remedy), 6 (registry membership 32/18/14/6
set-for-set), 7 (PTY /help = full 24-verb registry-derived palette; all 14
unsupported commands yield `unknown /X — /help` with non-empty registry
`chat_reason`), 8 (/score and /bench forward `--iter` to the honest
Analyst-stamp refusal — never a missing-iter/usage error), 9 (quoted
`/provider "codex"` → codex, no eval). Real authenticated agent cycle
(`evidence/live-chat-cycle.typescript`). Registry + `repl_palette_build` +
`repl_run_slash` drive /help, hints, routing, classification.

### 3. argument-usage-parity — 10
Slash forwarding argument-identical to the CLI path (probe 8: same stamp
refusal as CLI controls); probe 16 (unknown command and usage errors exit
non-zero); `evidence/usage-parity-probes.txt` 10 rows exit 1 with
help-matching usage. Baseline cosmetic notes are outside the rubric anchors.

### 4. help-readme-onboarding-parity — 10
Probe 4 (README documents all 32 help-listed commands — README.md:65);
probe 12 (`onboarding --yes` uses `score <client> --iter <n>` —
lib/onboarding.sh:51; onboarding succeeds on an isolated state root).

### 5. argv-safety — 10
Probe 9 (quoted slash argv one value; embedded `;$(…)` inert); probe 14
(multi-word argv round-trips byte-identical; empty argv rejected non-zero);
`repl_tokenize` honors quotes/backslash, never evals, never re-parses.

### 6. frontend-machine-boundary — 10
Probe 6 (`help --json` frozen registry shape 32 + 6 chat_only, membership
matches §2); probe 11 (`status --json` lists onboarding-flight-control and
harness-evolution); probe 10 (all existing machine surfaces parse). README
Machine-readable boundaries table documents each surface.

### 7. non-tty-redirect-nocolor-exit — 10
Probe 13 (`bench`/`run` on summary-shaped scores honest rc=1, no `jq: error`,
never exit 5 — D7 fixed); probe 15 (redirected + NO_COLOR=1 zero ESC bytes;
color TTY emits ANSI); probe 16 (exit-code honesty).

### 8. ctrl-c-child-cleanup-partial-artifacts — 9
Code contract: scoped `trap INT` → `repl_interrupt_cleanup` (kill provider
group `-pid`, reap, `rc=130`, worker failed, partial artifact preserved with
"Ctrl+C leaves partial on disk"; REPL survives); run-loop traps TERM/INT →
`loop_pause_for_signal`. Runtime proof: visual-final 14/14
(`honest-partial-output`) with live provider proof; smoke run-loop PASS.
**9 not 10**: literal `130` exit recording code-verifiable but not shown in an
archived output transcript.

### 9. visual-smoke-contracts — 10
`productteam smoke` exit 0, no FAIL lines (baseline single FAIL `checks`
gone); probe 15 (splash/help ANSI-free in a pipe); visual-final 14/14 with
live provider proof.

### 10. dependencies-cold-start — 8
Cold-start repaired: probe 3 PASS (checks exits 0 on a cold checkout;
recovery automatic and non-destructive); runtime honesty holds (smoke:
`runtime --check` refuses a missing provider). **Band 6–8 applies, not 9–10**:
the rubric's 9–10 anchor requires "No machine-pinned absolute paths in
tracked state", and tracked engagement metadata still pins this machine's
paths — `state/engagements/onboarding-flight-control/workspace.json`
(committed, unmodified) records `source_repo:
/home/logani/projects/onboarding-flight-control` and
`path: /home/logani/.herdr/worktrees/Product Consulting Harness/test-rapid-basics/tmp/workspaces/onboarding-flight-control`
with `exists: true`; sibling tracked metadata carries `/home/logani` pins
(critic-final-verdict.md). Commands self-heal fully automatically and
non-destructively, so the dimension sits at the top of 6–8 — **not 9–10**.
This is the **exact blocker** (see below).

### 11. metadata-simplicity-deletion — 9
CLI state minimal: `state/.cli` gitignored (5-byte first-run + one config
line, atomic tmp+rename); only repair-introduced artifact is
`lib/commands.sh` — source, not state; no daemon/duplicate authority. v3
scope note honored: `state/style/*` untouched (org memory; critical failure
#6 avoided). Deletion paths exist (`workspace remove` clean-worktree-only,
`direction clear --i-am-owner`); run-loop smoke scaffolding cleans up after
itself. **9 not 10**: standalone `tests/run-loop-smoke.sh` not itself archived
as a standalone run in final evidence.

## Arithmetic

105/11 = 9.545 → **overall 9.5** (one decimal). Per-dimension:
9, 10, 10, 10, 10, 10, 10, 9, 10, 8, 9 (sum 105). Baseline (iter-1, never
rewritten): 5.5 (61/11); improvement **+4.0**.

## Convergence and the exact blocker

- **Converged: false** under this assignment's overlay rule (converged true
  only if **every** dimension ≥ 9), because dimension 10
  (`dependencies-cold-start`) = 8.
- The frozen contract's own checklist (every dimension ≥ 8.0 with the parity
  test green, baseline intact, freeze SHA unchanged, Analyst-authored scores,
  real verification, thin registry) is met on every verifiable item. Both
  thresholds are stated so the ≥9 overlay is not read as a silent contract
  amendment (critic-final-verdict.md nit).
- **Blocker wording vs immutable history.** The frozen 9–10 anchor requires
  "No machine-pinned absolute paths in tracked state." Reaching 9 would
  require deleting or rewriting tracked machine-local engagement path records
  that are valid historical evidence of prior machine-bound worktrees and of
  external client repo identity. Rewriting corrupts evidence; deleting breaks
  plain-file authority. The permanent Critic ruled this repair path must be
  rejected: "remain non-converged rather than corrupt immutable engagement
  metadata" (critic-final-verdict.md). The blocker is documented in
  `final-scores.json`, `critic-final-verdict.md`, and `max-iteration-plan.md`.

## Guards honored

- Principal never scored and did not author this artifact.
- No commands, tests, formatters, or linters run for this iteration; all
  evidence cited from recorded artifacts and current source (read-only
  verification).
- No run-root or production edits; this Analyst's writes are confined to
  `iterations/iter-5/analyst-scores.json` and `iterations/iter-5/analyst-evidence.md`.
- Scores are exact integers matching the frozen band anchors; no inflation.
