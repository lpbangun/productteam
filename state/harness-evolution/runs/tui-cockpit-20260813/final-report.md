# Final report — ProductTeam Textual cockpit

**KEEP `lib/tui/`.** Reviewer `ceaab23a` scored every mandatory freeze dimension ≥ 9.0 on iteration 3.

## What shipped

`productteam tui` is an optional TTY presentation client of `bin/productteam`.

- Textual 8.2.8 + Rich 15.0.0, venv gitignored
- Visualizer layout: header `ProductTeam · {engagement} · {mode} · {score}`, transcript, chips, slash dock above unlabelled composer, one footer
- Two accents only (`#22c55e` / `#ef4444`); no Textual cyan
- Palette from live `help --json` (33/18/15/6 after adding `tui`)
- Chat-supported verbs run as argv arrays against the real CLI
- Unsupported verbs refuse with `chat_reason` and do not spawn
- `/provider /workers /clear /export /exit` match REPL semantics
- Bare text → `provider_turn.sh` process group; first Ctrl+C keeps partial artifact; second exits 130
- Nested `/chat` and `/tui` refused
- Non-TTY: exit 2, empty stdout, `requires an interactive TTY`, no ESC under `NO_COLOR`
- `productteam chat` is unchanged and does not launch the TUI

## Loop

1. Inspect — live registry still 32/18/14/6; no `lib/tui/`
2. Freeze — argv dry-run vs executable `bin/productteam` mode 0775 including `agents --json`; reviewer `8348c50a` ACCEPT-FOR-FREEZE; hash `cc827fff…`
3. Build — worker timed out after writing the tree; parent finished
4. Iter-1 FAIL — dims 3, 7, 8
5. Iter-2 FAIL — dim 3 (accumulated transcript)
6. Iter-3 PASS — keep

## Verification (iter-3)

- pytest 28 passed (`iter-3/pytest.txt`)
- `tests/cli-interface-parity.sh` PASS
- `tests/visual-cli.sh` 14/14 visual ids; live-provider proof still missing (allowed overall exit 1)
- PTY: `/status` real output; `/gate` refuse; provider interrupt 130 (`iter-3/pty-note.md`)

## Scores

See `scores.json` and `iter-3/reviewer-gate.md`. Lowest mandatory: visual layout / provider interrupt 9.4.

## Residual risks

- Live authenticated provider proof for visual-cli is still absent (pre-existing; not mocked).
- `/smoke` and `/harness-checks` are long; the stream deadline shows their real banners then stops the wait. Users typing those verbs in the TUI will see live output until the command finishes.
- Textual `run_test` + `pty.fork` can warn about multi-threaded fork; PTY tests still pass.

OpenTUI stays closed. Bash remains domain/state/process authority.
