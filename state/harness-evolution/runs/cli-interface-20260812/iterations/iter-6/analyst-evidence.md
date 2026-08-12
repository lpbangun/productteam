# Analyst evidence — cli-interface-20260812-v3 (iteration 6, no-change re-benchmark)

Evaluator: **Analyst** (independent; Principal never scores and did not author
this artifact — contract "Scorer: Analyst only"). Run:
`state/harness-evolution/runs/cli-interface-20260812/`. Iteration 6 of at most
6 — the terminal no-change organization re-benchmark of the unchanged
iteration-2 deliverable.

**Method:** Read-only re-audit. No commands, tests, formatters, or linters
were run for this audit (assignment constraint). Every dimension score cites a
concrete path, command output, or check artifact archived in the run directory
(scoring protocol rule 2 — a score without evidence is void). Evidence
artifacts are reused, not regenerated, because code does not change and
re-running side-effecting suites is prohibited without a delta.

## 0. No-change confirmation

- **No accepted work, no code delta since iteration 2.** `max-iteration-plan.md`
  fixes iterations 3–6 as bounded re-audits with no product delta ("Inspect:
  re-audit current frozen artifacts; no product delta"). `critic-final-verdict.md`
  records the iteration-2 repair state at HEAD `1ebb52f` (uncommitted repair
  worktree: `README.md`, `bin/productteam`, `lib/onboarding.sh`, `lib/repl.sh`,
  `lib/workspace.sh` modified; `lib/commands.sh` added). Nothing changed since.
- **This iteration writes only** `iterations/iter-6/analyst-scores.json` and
  `iterations/iter-6/analyst-evidence.md`. No production/run-root edits.
- **Evidence re-audited this iteration (all present and matching the
  iteration-2 claims):**

| Artifact | Claim verified |
|----------|----------------|
| `evidence/parity-final.txt` | 31/31 PASS; probe 1 (frozen contract hash matches `FREEZE-SHA.txt`) PASS; probes 2–16 rows all PASS |
| `evidence/smoke-final.txt` | `productteam smoke`: 41 checks PASS, "all smoke checks passed" |
| `evidence/visual-final.json` | visual-cli-v2 14/14 PASS, `converged: true`, `live_provider_proof: pass` |
| `evidence/live-chat-cycle.typescript` | real authenticated `agent` cycle → `LIVE-CYCLE-OK`, artifact `1.txt`, exit 0 |
| `evidence/harness-checks-final/checks.json` | harness-apc 57/57, `validation: real-commands` |
| `evidence/usage-parity-probes.txt` | 10 misuse rows, all exit 1 with usage matching help |
| `evidence/bench-harness-evolution.txt`, `evidence/run-harness-evolution-7.txt` | baseline D7 raw `jq: error` exit 5 record (fixed in iter-2; fix re-cited) |
| `state/engagements/onboarding-flight-control/workspace.json` | tracked, committed; pins `source_repo /home/logani/projects/onboarding-flight-control` and `path /home/logani/.herdr/worktrees/Product Consulting Harness/test-rapid-basics/tmp/workspaces/onboarding-flight-control`, `exists: true` |

## 1. Freeze integrity (unchanged)

- `FREEZE-SHA.txt` records `92f06ecd08e4e804e8c703af4a3af38519a7702ba2a72494fcdf9d596a6dc7f6`.
- Parity probe 1 ("frozen contract hash matches FREEZE-SHA.txt") PASS in
  `evidence/parity-final.txt`; `baseline-scores.json` revision history records
  the v3 hash `92f06ecd…` as owner-approved re-freeze.
- Contract file and `FREEZE-SHA.txt` untouched during the run; iter-1 baseline
  (`baseline-scores.json`, `evidence/*-baseline-*`) never rewritten (recorded
  in `final-scores.json` baseline_guard; `critic-final-verdict.md` §1.3).

## 2. Independent dimension scores (unchanged deliverable → unchanged scores)

Scores are integers 0–10 per the frozen v3 rubric. Because the deliverable and
its evidence are unchanged, each dimension re-verifies the iteration-2 result.
The conservative 9s (dimensions 1, 8, 11) are retained for the same
documented reasons; no score is inflated and none is docked anew.

| # | Dimension | Score | Primary evidence |
|---|-----------|------:|------------------|
| 1 | reachability | 9 | probes 2, 3 PASS; `lib/workspace.sh:66-101` recreate/repoint (never deletes); registry dispatch `bin/productteam:1422-1425`; smoke 41/41; harness-checks 57/57; usage-parity 10 rows exit 1. 9 not 10: `report`/`inspect` happy paths not directly executed in archived evidence; repoint branch exits 0 rather than hard-refusing non-zero on an existing foreign recorded path |
| 2 | chat-reachability-classification | 10 | probes 5, 6, 7, 8, 9 PASS; 32/18/14/6 set-for-set; 24-verb registry-derived palette; all 14 unsupported → `unknown /X — /help` with non-empty `chat_reason`; `--iter` forwarded to Analyst-stamp refusal; `/provider "codex"` → codex; real live chat cycle `LIVE-CYCLE-OK` |
| 3 | argument-usage-parity | 10 | probe 8 (slash forwarding argument-identical to CLI), probe 16 (exit-code honesty); `evidence/usage-parity-probes.txt` 10 rows exit 1 with help-matching usage |
| 4 | help-readme-onboarding-parity | 10 | probe 4 (README 32/32), probe 12 (`onboarding --yes` prints `score <client> --iter <n>`; `lib/onboarding.sh:51`) |
| 5 | argv-safety | 10 | probe 9 (quoted slash argv one value; `;$(…)` inert), probe 14 (byte-identical round-trip; empty rejected); `lib/repl.sh:349-389` `repl_tokenize` no-eval |
| 6 | frontend-machine-boundary | 10 | probe 6 (`help --json` frozen shape 32+6), probe 11 (`status --json` engagements), probe 10 (all existing surfaces parse); `lib/commands.sh:96-112`, `bin/productteam:287-331`; README boundaries table |
| 7 | non-tty-redirect-nocolor-exit | 10 | probe 13 (`bench`/`run` on summary-shaped scores: rc=1, no `jq: error`, never exit 5), probe 15 (ANSI-free redirect/NO_COLOR, ANSI on color TTY), probe 16 (non-zero exit codes) |
| 8 | ctrl-c-child-cleanup-partial-artifacts | 9 | code contract `lib/repl.sh:224-232, 311-317` (scoped trap INT → `repl_interrupt_cleanup`, killpg `-pid`, `rc=130`, partial preserved); `lib/run-loop.sh` TERM/INT → pause; `evidence/visual-final.json` 14/14 incl. `honest-partial-output` + live provider proof; smoke run-loop PASS. 9 not 10: literal `130` exit not shown in an archived transcript (code-verifiable only) |
| 9 | visual-smoke-contracts | 10 | `evidence/smoke-final.txt` 41/41 no FAIL; probe 15 splash/help ANSI-free in pipe; `evidence/visual-final.json` 14/14 + live provider proof |
| 10 | dependencies-cold-start | **8 — EXACT BLOCKER** | probe 3 PASS (cold-checkout `checks` rc=0; recovery automatic, non-destructive); `lib/workspace.sh:66-101`; smoke `runtime --check` honesty. 9–10 anchor ("No machine-pinned absolute paths in tracked state") unmet: `state/engagements/onboarding-flight-control/workspace.json` (independently re-read this iteration) pins `/home/logani/…` paths, `exists: true`; `/home/logani` paths remain in overnight-rehearsal and harness-cli tracked metadata. Top of band 6–8 ("state pins absolute paths but commands self-heal") |
| 11 | metadata-simplicity-deletion | 9 | `state/.cli` gitignored (5-byte `first-run` + one config line, atomic tmp+rename); registry is source not state; `state/style/*` out of scope, untouched; deletion paths (`workspace remove`, `direction clear --i-am-owner`); `tests/run-loop-smoke.sh` trap cleanup. 9 not 10: standalone run-loop-smoke not archived as its own final run |

## 3. Arithmetic

- Sum of the 11 integer scores: 9+10+10+10+10+10+10+9+10+8+9 = **105**.
- Overall: 105/11 = 9.545 → one decimal **9.5** (contract: overall is the
  mean to one decimal; informational).
- Baseline (iter-1, never rewritten): 5.5 (61/11). Improvement vs baseline:
  **+4.0**, unchanged from iteration 2.

## 4. Converged status and the exact blocker

- **Converged: false** under this assignment's rule (true only if every
  dimension ≥ 9), because dimension 10 (dependencies-cold-start) = 8.
- **Blocker wording (frozen rubric):** dimension 10's 9–10 anchor —
  "No machine-pinned absolute paths in tracked state."
- **Immutable reality:** tracked engagement metadata legitimately and
  permanently pins machine-specific absolute paths (`workspace.json` for
  onboarding-flight-control and overnight-rehearsal, plus harness-cli tracked
  metadata). These are valid historical evidence of prior machine-bound
  worktrees; rewriting or deleting them would corrupt evidence and break
  plain-file authority.
- **No safe work item has positive benchmark lift** (`max-iteration-plan.md`):
  the only way to lift dimension 10 to 9 is to corrupt immutable records —
  rejected. The permanent Critic explicitly accepted non-convergence over
  score-gaming (`critic-final-verdict.md`); the frozen contract's own ≥8.0
  checklist is met on every verifiable item.
- Terminal outcome at the six-iteration cap is therefore the honest,
  evidence-backed **non-convergence** record: dimensions 9,10,10,10,10,10,10,9,
  10,8,9; overall 9.5; converged false; one blocker with no acceptable repair.

## 5. Guards honored (iteration 6)

- Principal never scored and did not author this artifact.
- No commands, tests, formatters, or linters run; all evidence cited from
  recorded artifacts and current source; no production/run-root edits.
- Baseline and freeze files untouched; no silent rewrite; no score inflation;
  no fabrication (contract critical failures 1–6 not triggered).
