# Retarget audit — established-test retargeting

**Verdict: ACCEPT**

Independent post-tweak audit of established-test retargeting for
`tui-fidelity-20260818`. No rescore. No implementation iteration. No
product, test, snapshot, freeze, source-page, score, reviewer-gate, or
final-report edits.

The existing iter-2 **pass remains valid** under the owner-confirmed
narrow retarget exception.

## Authority applied

Owner tweak (as given to this audit):

- May narrowly retarget an established assertion **only** when its former
  expected presentation directly contradicts a mandatory Ask lock.
- Forbids deleting, renaming, skipping, broadly weakening, or changing
  non-conflicting functional assertions.
- Matching local/remote pinned source hashes remain authoritative even
  if the source differs from Git HEAD.

Cross-checked against:

- `frozen-benchmark.md` Ask locks L1–L17 and the freeze-allowed L8
  `HOME_ROW_RE` exception
- `FREEZE-SHA.txt` =
  `da6335f2a7c100ee4a0f4a46c117986ddb1edf6adbe7a13e198c5dbd70794acd`
  (matches `iter-2/freeze-sha-verified.txt`)
- `test-retargets.md`
- `established-nodeids.md`
- `iter-2/{pytest-collect.txt,pytest.txt,cli-interface-parity.txt,visual-cli.txt,b6plus.txt,notes.md,reviewer-gate.md,scores.json}`
- `final-report.md`

Pinned visual sources in the freeze (authoritative by matching
local/remote hashes; Git HEAD difference is irrelevant):

| source | sha256 |
|---|---|
| locked local + remote | `2a9627cb17ec3bf41e0f205ebc8b7d6842741c5aa2670ee3f40fb70746db8121` |
| decide local + remote | `db911fcbdb5075493f9b2fcc9e696f7c168fb32727b008a0d829458ef5fbfc63` |

## Tracked test/snapshot diff (Git HEAD → worktree)

`git status --short -- lib/tui/tests` and `git diff --stat HEAD -- lib/tui/tests`:

| path | status |
|---|---|
| `lib/tui/tests/test_all_verbs.py` | modified (8 ±) |
| `lib/tui/tests/test_layout.py` | modified (176 ±) |
| `lib/tui/tests/test_pty.py` | modified (10 ±) |
| `lib/tui/tests/test_slash.py` | modified (13 ±) |
| `lib/tui/tests/__snapshots__/cockpit-80x24.svg` | modified (regenerated paint) |
| `lib/tui/tests/__snapshots__/palette-80x24.svg` | modified (regenerated paint) |

Unchanged tracked test modules (0-byte diffs):

- `lib/tui/tests/conftest.py`
- `lib/tui/tests/test_adapter.py`
- `lib/tui/tests/test_nontty.py`

No untracked files under `lib/tui/tests`.

## Nodeid preservation

Python `ast` of top-level `test_*` functions:

| set | count |
|---|---|
| Git HEAD | **73** |
| current worktree | **77** |
| missing from current vs HEAD | **none** |
| renamed / reordered established defs | **none** |
| appended | **exactly 4** |

Appended (not rewrites):

- `lib/tui/tests/test_layout.py::test_home_row_lock_shape`
- `lib/tui/tests/test_layout.py::test_compact_chips_single_plus_count`
- `lib/tui/tests/test_layout.py::test_chip_done_status_on_chip_and_card`
- `lib/tui/tests/test_layout.py::test_no_provider_first_run_copy`

These four match `established-nodeids.md` and
`test-retargets.md` “Appended fidelity tests”.

Current 77-nodeid collection:

- recorded `iter-2/pytest-collect.txt`: `77 tests collected in 0.27s`,
  `EXIT_CODE=0`
- independent rerun this audit:
  `lib/tui/.venv/bin/python -m pytest lib/tui/tests --collect-only -q`
  → **exit 0**, `77 tests collected in 2.87s`

Set equality holds: HEAD 73 ⊂ collect 77 = current AST 77 =
`established-nodeids.md`. No established nodeid is absent from the
collection.

No new skip/xfail decorators. The only `pytestmark.skipif` is the
pre-existing PTY capability guard in `test_pty.py:24` (identical at
HEAD). Recorded B2 is `77 passed` with no skips.

## Ledger completeness

Every changed established **assertion** in the four modified Python
files is named in `test-retargets.md` with nodeid (or the shared helper
and every consuming nodeid), former conflicting expectation, governing
Ask lock, and coverage-preservation proof.

| Changed assertion | Ledger row | Lock | Conflict is presentation? | Functional remainder |
|---|---|---|---|---|
| `test_all_verbs.py` `HOME_ROW_RE` + `_boot_home` L10 accept | both all-verb nodeids | L8, L10 | yes — score-first wait / missing L10 first-run | 18 verbs, needles, unsupported refuse, no-spawn still asserted |
| `test_layout.py` `HOME_ROW_RE` + tuple unpack in seed/recency | `test_home_seed_filtered`, both recency tests | L8 | yes — score-first capture order | cap 3, exclusions, recency names, scores, tie-break unchanged |
| `test_home_empty_copy_when_no_scored` `@Principal` → no `@` | same nodeid | L15, L4 | yes — idle `@Role` | exact empty copy, zero rows, prose exclusions, footer, chips remain |
| `test_role_chips_focusable_and_selectable` unpinned / no `@` + added unpin | same nodeid | L15, L6, L4 | yes — idle pin/@ chrome | Principal routing, focusability, keyboard/click pin, `@Builder`/`@Critic` when pinned, composer focus remain; unpin/width-0 **added** |
| `test_ask_dock_single_exact_question_and_answer` title/`recommended`/indices | same nodeid | L16 | yes — `★`, 0-based options, no title | question turn, descriptions, bold default, footer k of n, Space/Enter, structured answer, close, one-shot remain |
| `test_splash_idle_neutral_and_exact_art` no `@` + `#`/`o`/`>` line 5 | same nodeid | L15, L3 | yes — idle `@Role` and old `/ \` `◇` `▸` marks | 10-line art, dimensions, neutral spans, composer/footer, banned needles, transcript isolation remain |
| `test_splash_stepper_glow_order_one_ok_head` glow needles | same nodeid | L3 | yes — former distinct marks | Principal→Analyst→Builder→Principal, one-OK-head/span checks remain |
| `test_splash_natural_finish_home_and_focus` no auto-finish | same nodeid | L1 | yes — fifth-tick finish | persist past tick 5, wrap, Enter dismiss, home/footer/focus, no splash art, post-finish idempotence **stronger** |
| `test_pty_confirm_cancel_keeps_composer` OMP confirm + no `@` | same nodeid | L17, L15 | yes — `Run /gh merge` compact rows + idle `@Role` | Esc cancel, idle footer restore, `/gh merge` echo, `/exit` rc 0 remain |
| `test_pty_sigwinch_compact` no `@` + `enter send` | same nodeid | L15 | yes — idle `@Role` | 80→40 compact header/cwd and 40→80 `▣─▣─▣` restore remain; composer/footer **added** |
| `test_slash.py` `HOME_ROW_RE` used by `_boot` | helper row; slash functional asserts unchanged | L8 | yes — score-first wait | slash/evidence/provider/session/confirm behavior unchanged except L17 rows |
| `_confirm_open` + Run row in both confirm tests | both confirm nodeids | L17 | yes — compact `Run {slash}` / bare `Cancel` | exact argv for three intercepts, default Run, arrow Cancel, Esc Cancel, no spawn, dock close remain |

No changed established assertion is missing from the ledger.

Non-conflicting tests that still exercise ask/confirm/home behavior
without a presentation rewrite were left alone, including
`test_ask_dock_multi_toggle_and_esc_cancel` (toggle / k of n / Esc
cancel JSON; no `★` / compact-row needles) and
`test_confirm_non_matching_gh_unchanged`.

Snapshots are not nodeids. Regenerated SVGs follow L8 home rows
(`● name …… score`), keep `#c084fc` role hue, and contain neither
`@Principal` nor Textual cyan `#0178D4`. Snapshot export / no-cyan
tests are unchanged functions.

## No forbidden mutation

- **Deleted established tests:** none
- **Renamed established tests:** none
- **Skipped established tests:** none (no new skip/xfail; B2 recorded
  77 passed / 0 skipped)
- **Broad weakening:** none. Replacements are lock-shaped needles or
  added lock checks. Split PTY `Run` + `/gh merge` still requires both
  facts; slash dropped `== f"Run {slash}"` only because L17 labels are
  `Run` / `Cancel`, while exact argv remains the spawn assertion.
- **Non-conflicting functional asserts changed:** none found. Adapter,
  non-TTY, provider interrupt, argv forwarding, refusal, evidence
  classification, session mutation, four-size layout, and SIGWINCH
  restore asserts are untouched.

AST assert counts on established functions either stay equal with a
lock-shaped substitution or **increase** (chips +5, ask +2, splash
finish +4, PTY confirm +1, PTY SIGWINCH +1, slash confirm-run +1).

## Ledger accuracy

`test-retargets.md` statements match the actual diffs and the recorded
iter-2 commands. The “77 collected / 77 passed / parity PASS / visual
14/14 / B6+ 0 FAIL(S)” citations match the files below. No invented
output.

Minor non-blocking notes (not incompleteness, not a correction
requirement):

- Ledger nodeids are module-short (`test_layout.py::…`) rather than the
  collected `lib/tui/tests/test_layout.py::…`. Unambiguous.
- A few **docstrings** still mention `@Principal`
  (`test_home_empty_copy_when_no_scored:138`,
  `test_role_chips_focusable_and_selectable:512`,
  `test_splash_idle_neutral_and_exact_art:1421`,
  `test_pty_confirm_cancel_keeps_composer:269`). Comments only; asserts
  were retargeted and ledgered.
- `test_pty_sigwinch_compact` ledger text says “header/cwd/score/resize
  assertions remain.” That test never asserted a numeric score at HEAD;
  header/cwd/resize did remain.

## Iter-2 pass remains valid under the owner tweak

Iter-1 failed solely on D19/B2: four established nodeids were red on
stale score-first boot and compact confirm needles that contradicted
L8/L10/L17. Iter-2 retargeted those contracts only. Cumulative
presentation retargets in layout/PTY/snapshots are the same allowed
class (L1/L3/L4/L6/L8/L10/L15/L16/L17).

Because:

1. every altered established assertion is a former presentation that
   directly contradicted a mandatory Ask lock (or the freeze-allowed L8
   home-row regex),
2. every established nodeid still exists and was green in the recorded
   B2 run,
3. underlying functional coverage is preserved or strengthened,
4. `test-retargets.md` is complete and accurate,

the owner tweak **authorizes** the retargets that made B2 green. It
does **not** reopen D19 or invalidate `iter-2/reviewer-gate.md` =
**pass**, `iter-2/scores.json` `all_ge_9=true` (lowest D14=9.2), or
`final-report.md` CONVERGED.

Do not start another implementation iteration from this audit.

## Frozen commands (recorded; not re-executed except B1)

This audit did not rescore and did not re-run B2/B3/B4/B6+.

| Gate | Command | Exit | Record |
|---|---|---:|---|
| B1 recorded | `lib/tui/.venv/bin/python -m pytest lib/tui/tests --collect-only -q` | **0** | `iter-2/pytest-collect.txt`: `77 tests collected in 0.27s` |
| B1 this audit | same | **0** | `77 tests collected in 2.87s` |
| B2 | `lib/tui/.venv/bin/python -m pytest lib/tui/tests -q` | **0** | `iter-2/pytest.txt`: `77 passed in 282.11s (0:04:42)` |
| B3 | `tests/cli-interface-parity.sh` | **0** | `iter-2/cli-interface-parity.txt`: `cli-interface parity v3: PASS`; `33/18/15/6` |
| B4 | `tests/visual-cli.sh` | **1** | `iter-2/visual-cli.txt`: `14/14 pass · 0 fail · 0 skipped · live provider proof missing` (freeze-allowed) |
| B6–B16 | freeze §7 probe | **0** | `iter-2/b6plus.txt`: `=== 0 FAIL(S) ===` — does **not** fail on the recorded post-implementation paint |

B6+ first paint in that record is already L8 (`● osint-loop-research …… 9.5`, …),
not the freeze-day score-first rows. Expected after implementation.

## Residual risks

- D14 remains 9.2 on a shared fail-glyph path rather than a live `✗`
  probe. Already scored ≥ 9.0; out of scope for this retarget audit.
- B4 still exits 1 only for the pre-existing missing live-provider
  proof. Freeze-allowed.
- Stale `@Principal` docstrings could confuse a later reader; they are
  not assertions and do not require a documentation correction to
  accept this ledger.

## Files changed by this audit

Only this artifact:

`state/harness-evolution/runs/tui-fidelity-20260818/retarget-review-handoff.retarget-audit.md`
