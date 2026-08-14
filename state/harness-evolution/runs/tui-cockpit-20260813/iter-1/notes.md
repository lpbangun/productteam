# Iteration 1 — implementation + gate package

Worker timed out after writing the cockpit; parent finished tests and evidence.

## What shipped

- `lib/tui/` Textual 8.2.8 + Rich 15.0.0 cockpit
- Registry `productteam tui` (`chat_supported=0`)
- argv-only adapter to real `bin/productteam`
- Session verbs match `lib/repl.sh`
- Nested `/chat` and `/tui` refuse
- `tests/cli-interface-parity.sh` 32→33 / 18 / 15 / 6
- README documents optional TUI; chat remains fallback

## Commands run (this gate)

| command | result |
|---|---|
| `lib/tui/.venv/bin/python -m pytest -q lib/tui/tests` | **28 passed** (35s) |
| `tests/cli-interface-parity.sh` | **PASS** (33/18/15/6) |
| `tests/visual-cli.sh` | 13/14 visual ids; `session-footer` FAIL; live-provider proof missing (exit 1 allowed for missing live proof) |
| `productteam tui` non-TTY | exit 2, empty stdout, stderr `requires an interactive TTY` |
| `NO_COLOR=1 productteam tui` non-TTY | no ESC |
| historical `CLI-BENCHMARK-CONTRACT.md` sha | unchanged / matches FREEZE-SHA |
| cockpit `frozen-benchmark.md` sha | `cc827fff…` unchanged |

## visual-cli session-footer

Reproduced independently of the TUI: the initial chat footer is
`engagement: — · mode: <dim>—</dim> · provider: …` so a literal grep for
`mode: —` misses because of ANSI around the em dash. After `/bench harness-cli`
the harness footer and `◆ Principal ›` are present. `tests/visual-cli.sh` was
not edited. Treat as pre-existing flake, not a TUI regression.

## PTY

`lib/tui/tests/test_pty.py`:
- `/status` → real `Product Consulting Harness` + `harness-cli`
- `/gate` → refuse reason + usage; no `no directive` (did not spawn gate)
- provider interrupt: first Ctrl+C keeps partial artifact + worker `failed`; second → 130

## Untouched

- `spikes/shared/`
- `lib/repl.sh` / `lib/theme.sh` / `lib/render.sh` / `lib/activity.sh` / `lib/provider.sh`
- `frozen-benchmark.md` / `FREEZE-SHA.txt`
- historical `cli-interface-20260812` contract
