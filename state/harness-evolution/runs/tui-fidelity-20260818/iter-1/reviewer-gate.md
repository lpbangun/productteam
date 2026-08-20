# Reviewer gate — iter-1

Reviewer: independent, read-only. No app, test, snapshot, registry, or freeze edits.
Run: `tui-fidelity-20260818` / `iter-1`
Freeze: `state/harness-evolution/runs/tui-fidelity-20260818/frozen-benchmark.md`
SHA-256: `da6335f2a7c100ee4a0f4a46c117986ddb1edf6adbe7a13e198c5dbd70794acd`
Verified this review against `FREEZE-SHA.txt`, `iter-1/freeze-sha-verified.txt`, and a live `sha256sum` of the freeze. Hash holds.

**Verdict: fail**

Not every mandatory dimension is ≥ 9.0. B2 is red. Iter-1 is not converged.

| | |
|---|---|
| `all_ge_9` | `false` |
| Lowest | **6.0** (`D19`) |
| Below 9.0 | D19 only |
| ≥ 9.0 | D01–D18, D20 (19/20) |
| B6+ | green (`iter-1/b6plus.txt` exit **0**, `0 FAIL(S)`) |
| B2 | red (`iter-1/pytest.txt` exit **1**, `4 failed, 73 passed`) |

## Frozen commands (recorded, not invented)

| Gate | Command | Exit | Record |
|---|---|---:|---|
| B1 | `lib/tui/.venv/bin/python -m pytest lib/tui/tests --collect-only -q` | **0** | `77 tests collected in 0.34s` — all 73 established nodeids still present; +4 appended fidelity tests |
| B2 | `lib/tui/.venv/bin/python -m pytest lib/tui/tests -q` | **1** | `4 failed, 73 passed in 382.58s (0:06:22)` |
| B3 | `tests/cli-interface-parity.sh` | **0** | `cli-interface parity v3: PASS` (33/18/15/6) |
| B4 | `tests/visual-cli.sh` | **1** | `14/14 pass · 0 fail · 0 skipped · live provider proof missing` (allowed) |
| B5 | B2 nodeids `test_four_sizes`, `test_pty_sigwinch_compact`, `test_activity_file_backed_caps_footer_and_resize` | **0** | present in collect; absent from the B2 failure list |
| B6–B16 | freeze §7 probe | **0** | `=== 0 FAIL(S) ===` |

## B2 failures (disposition)

These four established nodeids are still collected. They are not green.

1. `test_all_verbs.py::test_all_18_supported_verbs_in_tui_transcript`
2. `test_all_verbs.py::test_every_unsupported_verb_refuses_without_spawn`

Both die in `_boot_home` with `AssertionError: home projection never seeded`. The helper still uses the pre-L8 regex `^\s*(\d+\.\d)\s+(\S+)(.*)$` (`lib/tui/tests/test_all_verbs.py:10`). Same-environment B6+ first paint is L8 (`● osint-loop-research …… 9.5`, …). That paint cannot match the old score-first needle. Parent `notes.md` blamed the L10 no-provider copy; the recorded B6+ paint shows scored L8 rows, so the stale regex is the proven cause.

3. `test_slash.py::test_confirm_run_exact_argv_for_all_three_intercepts`
4. `test_slash.py::test_confirm_cancel_no_spawn`

Both fail in `_confirm_open` at `assert texts[1].startswith("Run")` against the locked row `● Run\n   argv to bin/productteam. Output streams as a Command turn.` The helper was retargeted far enough to expect three options and a `Confirm write` title, then left a column-0 `Run` / exact `Cancel` needle that L17 no longer paints.

B6+ being green does not rescue D19. Freeze §3 B2 is “every collected test passes.”

## Scores

| ID | dimension | score | citation |
|---|---|---:|---|
| D01 | L1 splash persist | 9.6 | `app.py` stepper wraps and never auto-finishes; `b6plus.txt` exit 0; Enter/any-key skip tests still green |
| D02 | L2 splash-only plane | 9.4 | `#header/#rule/#activity/#chips.splashed { display: none }`; B7 green |
| D03 | L3 identical ASCII splash | 9.5 | `theme.py` 11×7 `#` / `o` / `>` heads; exact-art test green |
| D04 | L4 prefix width 0 | 9.5 | CSS width 0 / `.pinned` 12; B8 green; `PREFIX=''` |
| D05 | L5 header `▣─▣─▣` | 9.6 | B6+ 80×24 header exact; compact `ProductTeam {score}` still proven |
| D06 | L6 second-click unpin | 9.5 | `select_role` toggle; B9 green |
| D07 | L7 role-hued chips | 9.4 | identity hexes in `theme.py` + snapshot; no idle mute-gray |
| D08 | L8 home `● name …… score` | 9.6 | B6+ first paint three L8 rows; B10/B16 green |
| D09 | L9 empty busy composer | 9.3 | composer cleared on submit; busy facts stay in footer; activity footer test green |
| D10 | L10 no-provider first-run | 9.4 | dedicated copy + footer; B11 and appended test green |
| D11 | L11 evidence dock | 9.3 | labelled `#dock` above composer; evidence test green; no file-open |
| D12 | L12 40-col chips | 9.5 | `{glyph} {role} +N`; B12 and SIGWINCH-40 green |
| D13 | L13 live chrome pack | 9.4 | `│ Command · HH:MM`, corner toast, `#2a2a2a` rule, no blink, `│` rail |
| D14 | L14 chip + card status | 9.2 | B13 ✓ chip+card green; fail uses `STATUS_GLYPHS` ✗ (no live ✗ probe) |
| D15 | L15 team default | 9.5 | unpinned, no `@Role`; `_route_role` is Principal |
| D16 | L16 OMP ask | 9.4 | title, in-dock `k of n`, literal `recommended`, descriptions; B14 green |
| D17 | L17 OMP confirm | 9.1 | B15 green; PTY cancel green; native confirm tests red on stale `Run` needle |
| D18 | Four sizes + SIGWINCH | 9.5 | B16 + `test_four_sizes` + PTY SIGWINCH green |
| D19 | B1–B5 preservation | **6.0** | B1/B3/B4/B5 hold; **B2 exit 1, 4 established tests failed** |
| D20 | Authority / non-rebuild | 9.3 | `diff-stat.txt` is `lib/tui` only; chat stays Bash; pins and parity hold |

## Smallest next slice

Test-contract only. Do not touch product chrome.

1. Retarget `lib/tui/tests/test_all_verbs.py` `HOME_ROW_RE` / `_boot_home` onto the L8 needle already used in `test_layout.py`, and treat the L10 `no installed agent` copy as a valid boot state.
2. Retarget `lib/tui/tests/test_slash.py` `_confirm_open` (and the two confirm tests) onto the locked radio+description rows: `● Run` / `argv to bin/productteam...` and `○ Cancel` / `Nothing is spawned.` Retarget that file's stale score-first `HOME_ROW_RE` the same way.

Do not delete tests. Do not weaken B1–B5. Do not amend the freeze. Re-run B2; it must go exit 0 with the current 77 nodeids still present.

## Stop rule

KEEP `lib/tui/`. Do not write `final-report.md`. Iter-1 verdict is **fail**.
