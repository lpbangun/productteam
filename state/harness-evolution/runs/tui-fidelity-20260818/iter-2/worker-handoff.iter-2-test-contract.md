# Iteration 2 worker handoff — test-contract integration fix (D19)

## Task

Apply only the reviewer-approved smallest test-contract fix for D19: retarget
stale score-first home-row detection and stale confirm assertions in two test
files to the frozen L8 / L10 / L17 chrome. No product code was touched.

## Changed files (scope-limited to the two test files)

- `lib/tui/tests/test_all_verbs.py`
- `lib/tui/tests/test_slash.py`

## Diff summary

1. `test_all_verbs.py`:
   - `HOME_ROW_RE` retargeted from stale score-first
     `^\s*(\d+\.\d)\s+(\S+)(.*)$` to the frozen L8 shape
     `^\s*●\s+(\S+)\s+…+\s+(\d+\.\d)(.*)$` (identical to `test_layout.py`).
   - `_boot_home` now also accepts the mandatory L10 `no installed agent`
     first-run copy as a valid seeded boot state.
2. `test_slash.py`:
   - `HOME_ROW_RE` retargeted to the same L8 shape (used only via `.search`).
   - `_confirm_open` now asserts the locked OMP confirm rows:
     row 0 `Confirm write · 1 of 2`, row 1 `● Run` +
     `argv to bin/productteam. Output streams as a Command turn.`, row 2
     `○ Cancel` + `Nothing is spawned.`
   - `test_confirm_run_exact_argv_for_all_three_intercepts` asserts
     `● Run` at row 1 (was `Run` at row 0).

No nodeid was deleted, renamed, skipped, or weakened. No product chrome,
freeze, source page, snapshot, or non-TUI file was modified.

## Commands run (exact)

- `cd lib/tui && .venv/bin/python -m pytest tests/test_all_verbs.py::test_all_18_supported_verbs_in_tui_transcript tests/test_all_verbs.py::test_every_unsupported_verb_refuses_without_spawn tests/test_slash.py::test_confirm_run_exact_argv_for_all_three_intercepts tests/test_slash.py::test_confirm_cancel_no_spawn -q`
  → exit 0, `4 passed in 65.85s`
- `cd lib/tui && .venv/bin/python -m pytest tests --collect-only -q`
  → exit 0, `77 tests collected in 0.33s` (all 73 established nodeids still
  present; +4 appended fidelity tests)

## Freeze hash confirmation

`state/harness-evolution/runs/tui-fidelity-20260818/frozen-benchmark.md` =
`da6335f2a7c100ee4a0f4a46c117986ddb1edf6adbe7a13e198c5dbd70794acd` (unchanged).

## Residual risks

- The full official B2 suite and B6+ probe were not run here; the parent runs
  every frozen command. The four formerly-red nodeids pass and collection is
  intact, which addresses the only D19 blocker the reviewer identified.
- `test_slash.py` `_confirm_open` now checks exact locked descriptions; if a
  future product change alters those strings, the test will flag it (intended).
