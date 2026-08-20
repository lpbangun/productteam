# Iteration 2 — address reviewer FAIL on dims 3, 7, 8

## Fixes

1. **Supported argv (dim 3):** `test_all_verbs.py` now runs all 18 supported verbs through `ProductTeamApp._run_slash` with valid arguments and asserts real CLI text in the TUI transcript. `/splash` unsets `CONSULT_NO_SPLASH` for that argv only so the banner is real.
2. **Four sizes (dim 7):** `test_layout.py` asserts nonzero regions for header, transcript, chips, composer, and dock at 120×36, 80×24, 60×24, 40×20, plus vertical order and dock-above-composer.
3. **`/export`:** seed CLI output, streamed CLI stdout, and provider artifact bytes are recorded in `_turns`. Export markdown includes `Product Consulting Harness`.
4. **visual-cli 14/14:** `tests/visual-cli.sh` session-footer now strips ANSI before matching `mode: —`. This is a chat-PTY probe, not a TUI chrome change. Live-provider proof is still missing; freeze allows overall exit 1 for that pre-existing reason. Do not mock.

## Commands

| command | result |
|---|---|
| `lib/tui/.venv/bin/python -m pytest -q lib/tui/tests` | **28 passed** |
| `tests/cli-interface-parity.sh` | **PASS** |
| `tests/visual-cli.sh` | **14/14** visual ids; live-provider proof missing |

PTY notes from iter-1 still apply (`test_pty.py` still in the 28).
