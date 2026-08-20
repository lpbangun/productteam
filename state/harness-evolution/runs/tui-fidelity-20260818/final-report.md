# Final report — ProductTeam TUI fidelity

**Outcome:** CONVERGED in iteration 2  
**Reviewer verdict:** pass  
**Mandatory dimensions:** D01–D20 all ≥ 9.0  
**Lowest score:** D14 = 9.2  
**Stop:** first all-pass; no iteration 3

## Frozen contract

- Benchmark: `state/harness-evolution/runs/tui-fidelity-20260818/frozen-benchmark.md`
- Reviewer acceptance: `ACCEPT-FOR-FREEZE`
- Frozen SHA-256: `da6335f2a7c100ee4a0f4a46c117986ddb1edf6adbe7a13e198c5dbd70794acd`
- Final live SHA-256: `da6335f2a7c100ee4a0f4a46c117986ddb1edf6adbe7a13e198c5dbd70794acd`
- Locked/remote cockpit source SHA-256: `2a9627cb17ec3bf41e0f205ebc8b7d6842741c5aa2670ee3f40fb70746db8121`
- Locked/remote Ask source SHA-256: `db911fcbdb5075493f9b2fcc9e696f7c168fb32727b008a0d829458ef5fbfc63`

The freeze was not amended after hashing.

## Confirmed goal-tweak authority

After the first completion audit identified a contradiction between mandatory Ask locks and the freeze's blanket test-rewrite prohibition, the owner confirmed an explicit narrow exception: established presentation assertions may be retargeted only when their former expectation directly conflicts with an Ask lock. Nodeids and underlying functional intent must remain.

`test-retargets.md` records every altered established assertion by nodeid, former expectation, governing Ask lock, replacement, and coverage-preservation proof. `established-nodeids.md` proves all 73 established test functions remain present and collected, with exactly four appended fidelity tests; the parent-run suite passed all 77. Independent reviewer artifact `retarget-review.md` records **ACCEPT**, finding no deletion, rename, skip, broad weakening, or non-conflicting functional assertion change, and confirms the iteration-2 pass remains valid under the owner tweak.

The locked sources are authoritative by matching local/remote pinned hashes. A difference from Git HEAD alone does not invalidate those frozen sources.

## Delivered fidelity

The existing `lib/tui/` was retained and updated rather than rebuilt. The converged cockpit now includes:

- persistent key-dismissed, splash-only boot plane with identical ASCII heads;
- zero-width unpinned role prefix and same-chip unpin behavior;
- always role-hued chips and compact `{glyph} {role} +N` rendering;
- `● name …… score` home rows and dedicated no-provider first run;
- empty busy composer with runtime facts in the footer;
- status ✓/✗ on both role chips and completion cards;
- OMP ask/confirm title, count, descriptions, and literal `recommended` chrome;
- preserved `▣─▣─▣`, evidence dock, Command timestamp, corner toast, filled rule, no-blink behavior, and `│` rail;
- preserved team-chat default with no idle `@Role`.

No second frontend, domain rewrite, daemon, or alternate state authority was introduced. `productteam chat` remains the Bash REPL.

## Iteration record

### Iteration 1

- B6–B16 exact probe reached `0 FAIL(S)`.
- Existing suite: 73 passed, four stale integration expectations failed.
- Reviewer verdict: fail; D19 = 6.0, all other dimensions ≥ 9.0.
- Evidence: `iter-1/`.

### Iteration 2

One worker made the reviewer-approved test-contract-only follow-up in `test_all_verbs.py` and `test_slash.py`. No product chrome changed in this iteration.

Parent-run frozen commands:

| Gate | Result |
|---|---|
| B1 collect | exit 0 — 77 collected; all established 73 nodeids retained plus four appended fidelity tests |
| B2 TUI suite | exit 0 — 77 passed in 282.11s |
| B3 CLI parity | exit 0 — `cli-interface parity v3: PASS` (33/18/15/6) |
| B4 visual CLI | exit 1 — 14/14 pass; only the freeze-allowed pre-existing live-provider proof is missing |
| B5 sizes / PTY / SIGWINCH | pass within B2 |
| B6–B16 exact probe | exit 0 — `0 FAIL(S)` |

Reviewer result: `iter-2/reviewer-gate.md` = pass; `iter-2/scores.json` records every D01–D20 score and citation. `test-retargets.md` documents the narrow Ask-lock test exceptions required by the confirmed goal tweak.

## Changed TUI surface

Cumulative tracked TUI delta versus HEAD:

- `lib/tui/app.py`
- `lib/tui/theme.py`
- `lib/tui/tests/test_layout.py`
- `lib/tui/tests/test_pty.py`
- `lib/tui/tests/test_slash.py`
- `lib/tui/tests/test_all_verbs.py`
- `lib/tui/tests/__snapshots__/cockpit-80x24.svg`
- `lib/tui/tests/__snapshots__/palette-80x24.svg`

The worktree contained pre-existing modifications at inspection start; they were preserved rather than reset.

## Residual evidence note

`tests/visual-cli.sh` still reports the pre-existing missing live-provider proof. The frozen contract explicitly permits its exit 1 only with the observed `14/14 pass · 0 fail · 0 skipped` result. Reviewer D14 is 9.2 because failure-chip behavior is proven through the shared status path rather than a dedicated live ✗ probe. Neither residual is below the frozen 9.0 convergence threshold.

## Stop decision

All mandatory dimensions reached at least 9.0 in iteration 2. Keep `lib/tui/`; do not write `not-converged.md`; stop the loop.
