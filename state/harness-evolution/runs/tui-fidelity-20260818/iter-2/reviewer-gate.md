# Reviewer gate — iter-2

Reviewer: independent, read-only. No app, test, snapshot, registry, or freeze edits.
Run: `tui-fidelity-20260818` / `iter-2`
Freeze: `state/harness-evolution/runs/tui-fidelity-20260818/frozen-benchmark.md`
SHA-256: `da6335f2a7c100ee4a0f4a46c117986ddb1edf6adbe7a13e198c5dbd70794acd`
Verified this review against `FREEZE-SHA.txt`, `iter-2/freeze-sha-verified.txt`, and a live `sha256sum` of the freeze. Hash holds.

**Verdict: pass**

Every mandatory dimension is ≥ 9.0. Frozen command pass rules hold, including preservation of the established 73 nodeids. Visual-cli exit 1 is the freeze-allowed 14/14 + missing live-provider proof. B6+ is green.

**Authorize `final-report.md` and stop.** Do not start iter-3.

| | |
|---|---|
| `all_ge_9` | `true` |
| Lowest | **9.2** (`D14`) |
| Below 9.0 | none |
| ≥ 9.0 | D01–D20 (20/20) |
| B6+ | green (`iter-2/b6plus.txt` exit **0**, `0 FAIL(S)`) |
| B2 | green (`iter-2/pytest.txt` exit **0**, `77 passed`) |

## Frozen commands (recorded, not invented)

| Gate | Command | Exit | Record |
|---|---|---:|---|
| B1 | `lib/tui/.venv/bin/python -m pytest lib/tui/tests --collect-only -q` | **0** | parent `iter-2/pytest-collect.txt`: `77 tests collected in 0.27s`. Independent rerun this review: `77 tests collected in 0.34s`. All 73 established nodeids still present; +4 appended fidelity tests |
| B2 | `lib/tui/.venv/bin/python -m pytest lib/tui/tests -q` | **0** | `77 passed in 282.11s (0:04:42)` |
| B3 | `tests/cli-interface-parity.sh` | **0** | `cli-interface parity v3: PASS` (33/18/15/6) |
| B4 | `tests/visual-cli.sh` | **1** | `14/14 pass · 0 fail · 0 skipped · live provider proof missing` (allowed) |
| B5 | B2 nodeids `test_four_sizes`, `test_pty_sigwinch_compact`, `test_activity_file_backed_caps_footer_and_resize` | **0** | present in collect; included in the B2 77-passed run |
| B6–B16 | freeze §7 probe | **0** | `=== 0 FAIL(S) ===` — does **not** fail today |

## Iter-2 slice (inspected)

Exactly the reviewer-approved test-contract follow-up. Product chrome was not edited this iteration.

- `lib/tui/tests/test_all_verbs.py`: `HOME_ROW_RE` retargeted to L8; `_boot_home` also accepts the L10 `no installed agent` copy.
- `lib/tui/tests/test_slash.py`: same L8 `HOME_ROW_RE`; `_confirm_open` and the Run assertion retargeted onto locked L17 `● Run` / `○ Cancel` + descriptions.

No nodeid deleted, renamed, or skipped. The four iter-1 B2 failures are now inside the 77-passed set.

## Scores

| ID | dimension | score | citation |
|---|---|---:|---|
| D01 | L1 splash persist | 9.6 | `app.py` stepper wraps and never auto-finishes; `b6plus.txt` exit 0; Enter/any-key skip tests green |
| D02 | L2 splash-only plane | 9.4 | `#header/#rule/#activity/#chips.splashed { display: none }`; B7 green |
| D03 | L3 identical ASCII splash | 9.5 | `theme.py` 11×7 `#` / `o` / `>` heads; exact-art test green |
| D04 | L4 prefix width 0 | 9.5 | CSS width 0 / `.pinned` 12; B8 green; `PREFIX=''` |
| D05 | L5 header `▣─▣─▣` | 9.6 | B6+ 80×24 header exact; compact `ProductTeam {score}` still proven |
| D06 | L6 second-click unpin | 9.5 | `select_role` toggle; B9 green |
| D07 | L7 role-hued chips | 9.4 | identity hexes in `theme.py`; no idle mute-gray |
| D08 | L8 home `● name …… score` | 9.6 | B6+ first paint three L8 rows; B10/B16 green |
| D09 | L9 empty busy composer | 9.3 | composer cleared on submit; busy facts stay in footer |
| D10 | L10 no-provider first-run | 9.4 | dedicated copy + footer; B11 and appended test green |
| D11 | L11 evidence dock | 9.3 | labelled `#dock` above composer; no file-open |
| D12 | L12 40-col chips | 9.5 | `{glyph} {role} +N`; B12 and SIGWINCH-40 green |
| D13 | L13 live chrome pack | 9.4 | `│ Command · HH:MM`, corner toast, `#2a2a2a` rule, no blink, `│` rail |
| D14 | L14 chip + card status | **9.2** | B13 ✓ chip+card green; fail uses `STATUS_GLYPHS` ✗ (no live ✗ probe) |
| D15 | L15 team default | 9.5 | unpinned, no `@Role`; `_route_role` is Principal |
| D16 | L16 OMP ask | 9.4 | title, in-dock `k of n`, literal `recommended`, descriptions; B14 green |
| D17 | L17 OMP confirm | 9.4 | B15 green; native confirm tests now green after L17 retarget; PTY cancel green |
| D18 | Four sizes + SIGWINCH | 9.5 | B16 + `test_four_sizes` + PTY SIGWINCH green |
| D19 | B1–B5 preservation | 9.4 | 73 established nodeids present and green; parity 33/18/15/6; visual-cli 14/14 allowed; B2 exit 0 |
| D20 | Authority / non-rebuild | 9.3 | iter-2 is test-contract only; chat stays Bash; pins and parity hold |

## Stop rule

KEEP `lib/tui/`. This is the first all-pass. **Write `final-report.md` and stop.** Do not write `not-converged.md`. Do not start iter-3.
