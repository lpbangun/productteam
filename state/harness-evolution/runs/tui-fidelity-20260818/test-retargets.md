# Established-test retarget ledger

Authority: the confirmed goal tweak explicitly permits narrowly retargeting an established assertion when its former expected presentation directly contradicts a mandatory Ask lock. It does not permit deleting, renaming, skipping, or weakening nodeids or unrelated functional assertions.

## Nodeid preservation

AST comparison of the six tracked test modules at Git `HEAD` versus the current worktree found:

- established at `HEAD`: **73**
- current: **77**
- missing established test functions: **none**
- appended tests: exactly four (listed below)

The parent-run iteration-2 collection recorded 77 nodeids and the full run recorded 77 passed. Thus all original 73 remain present and passing.

## Retargeted established expectations

| Established nodeid(s) | Former conflicting expectation | Ask lock requiring the retarget | Replacement and coverage-preservation proof |
|---|---|---|---|
| `test_all_verbs.py::test_all_18_supported_verbs_in_tui_transcript`; `test_all_verbs.py::test_every_unsupported_verb_refuses_without_spawn` (shared `_boot_home`) | Score-first home regex; only scored/no-scored boot states accepted | **L8** home is `● name …… score`; **L10** adds a no-provider first-run state | Helper now recognizes L8 rows and L10 copy. The tests still exercise every 18 supported verb and every unsupported refusal, including real-output and no-spawn assertions. No verb assertion changed. |
| `test_layout.py::test_home_seed_filtered` | Parsed `(score, name, rest)` from score-first rows | **L8** | Parses `(name, score, rest)` from `● name …… score`; cap-three and all exclusion assertions remain unchanged. |
| `test_layout.py::test_home_empty_copy_when_no_scored` | Idle composer displayed `@Principal` | **L15** team default has no idle `@Role`; **L4** unpinned prefix collapses | Replaced only the conflicting prefix assertion with absence of `@`. Empty-state copy exclusions and idle-footer assertions remain. |
| `test_layout.py::test_home_recency_mtime_order`; `test_layout.py::test_home_recency_numeric_and_client_tiebreak` | Tuple unpacking assumed score-first row order | **L8** | Tuple order follows L8. Exact recency ordering, score values, cap, exclusions, numeric iteration handling, and tie-break checks remain unchanged. |
| `test_layout.py::test_role_chips_focusable_and_selectable` | Startup treated Principal as visibly pinned with `@Principal`; no second-click unpin assertion | **L15**, **L6**, **L4** | Startup remains Principal-routed under the hood but asserts unpinned/no `@Role`; added same-chip unpin, zero-width prefix, and focus restoration. Existing focusability, keyboard selection, click selection, role targeting, and composer-focus checks remain. Coverage is stronger. |
| `test_layout.py::test_ask_dock_single_exact_question_and_answer` | Compact rows used `★`, had no title/count row, and option indices began at 0 | **L16** OMP ask title, in-dock count, literal `recommended`, descriptions | Assertions now require title/count, literal word, no star, descriptions, selection markers, bold recommendation, keyboard navigation, exact structured answer persistence, and close behavior. Behavioral coverage remains and chrome coverage is stronger. |
| `test_layout.py::test_splash_idle_neutral_and_exact_art` | Idle prefix contained `@Principal`; old splash mark line used distinct `/ \\`/`◇`/`▸` marks | **L15**; **L3** identical pure-ASCII bodies with `#`/`o`/`>` marks | Only conflicting needles changed. Exact 10-line art, dimensions, neutral spans, composer/footer visibility, banned needles, and transcript isolation remain checked. |
| `test_layout.py::test_splash_stepper_glow_order_one_ok_head` | Glow needles referenced the former distinct marks | **L3** | Needles now use `#`/`o`/`>` while preserving exact Principal→Analyst→Builder→Principal order and one-OK-head/span checks. |
| `test_layout.py::test_splash_natural_finish_home_and_focus` | Fifth timer tick auto-finished splash | **L1** splash persists until Enter/any key | Same nodeid now proves persistence past the old fifth tick, glow wrapping, Enter dismissal, restored home/footer/focus, no splash art in transcript, and post-finish idempotence. This replaces a directly contradictory assertion and strengthens the required behavior check. |
| `test_pty.py::test_pty_confirm_cancel_keeps_composer` | Compact confirm rows (`Run /gh merge`, `Cancel`) and idle `@Principal` | **L17** OMP confirm; **L15** no idle `@Role` | Requires `Confirm write`, Run/Cancel, retained `/gh merge` command echo, and no idle role tag. Existing real PTY Escape cancel, no-write behavior, composer retention, and footer restoration remain. |
| `test_pty.py::test_pty_sigwinch_compact` | Compact frame contained `@Principal` | **L15** | Requires no idle tag and explicitly retains composer/footer. All existing 80→40→80 header/cwd/score/resize assertions remain. Coverage is stronger. |
| `test_slash.py` shared `HOME_ROW_RE` used by boot helper | Score-first home regex | **L8** | Retarget only; slash execution, evidence, provider, session, and confirm behavior assertions are unchanged except the L17 rows below. |
| `test_slash.py::test_confirm_run_exact_argv_for_all_three_intercepts`; `test_confirm_cancel_no_spawn` (shared `_confirm_open`) | Two compact rows, `Run` at index 0, exact bare `Cancel`, and `Run /verb` row echo | **L17** | Helper now requires title/count, radio-prefixed Run/Cancel, and both locked descriptions. Exact original argv for all three intercepts, default Run, arrow Cancel, Escape Cancel, no spawn, and dock close remain. Command echo remains independently covered by the PTY test. |

## Appended fidelity tests (not rewrites)

- `test_layout.py::test_home_row_lock_shape` — direct L8 row shape.
- `test_layout.py::test_compact_chips_single_plus_count` — L12 compact and wide restoration.
- `test_layout.py::test_chip_done_status_on_chip_and_card` — L14 chip + card status.
- `test_layout.py::test_no_provider_first_run_copy` — L10 copy/footer precedence.

## Generated snapshots

`cockpit-80x24.svg` and `palette-80x24.svg` are regenerated visual evidence, not established test nodeids. Their changed paint follows the same L3/L4/L8/L15/L16/L17 expectations; snapshot export and no-cyan/token tests pass.

## Non-retargeted functional contract

No adapter, non-TTY, provider interrupt, argv forwarding, refusal, evidence classification, session mutation, exact command execution, cancellation/no-spawn, four-size layout, or SIGWINCH functional assertion was removed. Iteration-2 evidence:

- `pytest-collect.txt`: 77 collected, exit 0
- `pytest.txt`: 77 passed, exit 0
- `cli-interface-parity.txt`: 33/18/15/6 PASS
- `visual-cli.txt`: 14/14 (only freeze-allowed live-provider proof absent)
- `b6plus.txt`: 0 FAIL(S)
