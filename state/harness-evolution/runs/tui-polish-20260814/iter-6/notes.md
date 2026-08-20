# Iteration 6 notes — structured ask and write confirmation

## Functions implemented

- One existing `#dock` now has explicit slash/ask/confirm state; no modal or second supervisor.
- Active-provider `ask.json` is read only beside the active artifact, validated against freeze §6, consumed once, and retired.
- Exact colored question turn, option labels/descriptions/recommended state, single/multi selection, live `k of n`, arrows/Space/Enter/Esc, and atomic `ask.answer.json` are behaviorally tested.
- Exact `/gh merge`, `/checks --allow-dirty`, and `/onboarding --yes` argv are intercepted. Run executes the stored original argv; Cancel/Esc calls nothing.
- Ask and confirm footer states are exact. Composer remains mounted, focused, and materially visible.

## Verification

| Check | Result |
|---|---|
| Native pytest + snapshots | PASS — 47 passed (`pytest.txt`) |
| Real PTY | PASS — 5 passed (`pty-test.txt`, `pty-note.md`) |
| CLI interface parity | PASS — 33/18/15/6 (`cli-interface-parity.txt`) |
| Visual CLI | 14/14; allowed exit 1 only for pre-existing live-provider proof (`visual-cli.txt`) |
| Ask schema/control | PASS — file-backed single/multi, valid/invalid, response, one-time consumption |
| Confirm | PASS — all three intercepts, exact Run argv, empty Cancel argv log, live PTY cancel |
| Composer visibility | PASS — >=20 columns at four sizes and all dock states; live echo visible |

## Remaining blocker order

No convergence claim. Evidence panel and TUI splash remain zero-score functions. Iter-7 should implement evidence + Command/toast/card semantics; iter-8 should implement splash. Later iterations close PTY activity/prompt/header/home proof gaps named by Reviewers.
