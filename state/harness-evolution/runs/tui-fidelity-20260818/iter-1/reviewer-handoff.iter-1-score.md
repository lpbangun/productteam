# Reviewer handoff — iter-1 score

Independent score of `tui-fidelity-20260818` / `iter-1` against the immutable freeze.
No app/product, test, snapshot, freeze, or source-page edits.

## Freeze

- File: `state/harness-evolution/runs/tui-fidelity-20260818/frozen-benchmark.md`
- Live `sha256sum`: `da6335f2a7c100ee4a0f4a46c117986ddb1edf6adbe7a13e198c5dbd70794acd`
- Matches `FREEZE-SHA.txt` and `iter-1/freeze-sha-verified.txt`

## Files written by this review

- `state/harness-evolution/runs/tui-fidelity-20260818/iter-1/scores.json`
- `state/harness-evolution/runs/tui-fidelity-20260818/iter-1/reviewer-gate.md`
- this file

Product diff inspected (parent `iter-1/diff-stat.txt`): `lib/tui/app.py`, `lib/tui/theme.py`, `lib/tui/tests/test_layout.py`, `test_pty.py`, `test_slash.py`, two SVG snapshots. 7 files, +516/−236.

## Commands + exit codes (parent-run evidence; not invented)

| Gate | Exit | Record |
|---|---:|---|
| B1 collect | **0** | `77 tests collected in 0.34s` — 73 established nodeids still present; +4 appended |
| B2 suite | **1** | `4 failed, 73 passed in 382.58s` |
| B3 parity | **0** | `cli-interface parity v3: PASS` (33/18/15/6) |
| B4 visual-cli | **1** | `14/14 pass · 0 fail · 0 skipped · live provider proof missing` (allowed) |
| B6–B16 probe | **0** | `=== 0 FAIL(S) ===` — **does not fail today** |

B2 failures (verbatim from `iter-1/pytest.txt`):

- `test_all_verbs.py::test_all_18_supported_verbs_in_tui_transcript` — `AssertionError: home projection never seeded`
- `test_all_verbs.py::test_every_unsupported_verb_refuses_without_spawn` — same
- `test_slash.py::test_confirm_run_exact_argv_for_all_three_intercepts` — `AssertionError: ● Run` / `argv to bin/productteam...` ; `startswith('Run')` is false
- `test_slash.py::test_confirm_cancel_no_spawn` — same helper

## Score minimum + verdict

- Minimum: **D19 = 6.0**
- All other D01–D18, D20: **9.1–9.6**
- **Verdict: fail**

B6+ is green. That does not pass the iteration. Freeze acceptance needs every dimension ≥ 9.0 **and** B1–B5. B2 is red, so D19 cannot be ≥ 9.0.

Parent `notes.md` said the all-verbs boot miss was the L10 no-provider copy. Same-run `b6plus.txt` first paint is three L8 scored rows, not that copy. The proven miss is `test_all_verbs.py:10` still using the score-first regex `^\s*(\d+\.\d)\s+(\S+)`.

## Residual risks

- Confirm `dock_move` still allows highlight index 0 (title row); ask already skips it.
- Fail-path ✗ on chip+card is coded (`STATUS_GLYPHS` + `_provider_done`) but not live-probed this iter.
- `test_slash.py` still carries the old score-first `HOME_ROW_RE` (latent; confirm tests booted via empty `fake_env`).
- Worktree also has dirty `MEMORY.md` and `visualizer/locked/index.html`; those are outside the iter-1 `diff-stat.txt` and were not treated as this slice.

## Smallest next slice

Test-contract only. Do not change product TUI chrome.

1. Retarget `lib/tui/tests/test_all_verbs.py` boot onto the L8 home needle (and accept L10 copy as a valid boot).
2. Retarget `lib/tui/tests/test_slash.py` confirm helper onto `● Run` / `○ Cancel` plus descriptions.

Keep all 77 nodeids. Re-run B2 to exit 0.
