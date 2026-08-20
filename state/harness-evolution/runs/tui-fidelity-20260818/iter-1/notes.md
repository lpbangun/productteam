# Iteration 1 parent verification notes

## Frozen hash

`frozen-benchmark.md` remains `da6335f2a7c100ee4a0f4a46c117986ddb1edf6adbe7a13e198c5dbd70794acd`.

## Commands

| Gate | Result |
|---|---|
| B1 collect | exit 0; 77 collected: all established 73 nodeids plus four appended fidelity tests |
| B2 full TUI suite | exit 1; 73 passed, 4 failed in 382.58s |
| B3 CLI parity | exit 0; frozen 33/18/15/6 contract PASS |
| B4 visual CLI | exit 1; 14/14 pass, only allowed missing live-provider proof |
| B6–B16 exact probe | exit 0; 0 FAIL(S) |

## Concrete B2 failures

1. `test_all_18_supported_verbs_in_tui_transcript`: its `_boot_home` helper accepts scored rows/no-scored copy but not the newly mandatory no-provider first-run copy.
2. `test_every_unsupported_verb_refuses_without_spawn`: same helper mismatch.
3. `test_confirm_run_exact_argv_for_all_three_intercepts`: test expects `Run` at column 0, while locked OMP chrome correctly paints `● Run`.
4. `test_confirm_cancel_no_spawn`: same stale helper expectation.

These are test-contract integration gaps, not B6+ visual misses. Because B2 is mandatory, iteration 1 cannot converge and must receive a reviewer fail verdict before a smallest-diff iteration 2 test fix.
