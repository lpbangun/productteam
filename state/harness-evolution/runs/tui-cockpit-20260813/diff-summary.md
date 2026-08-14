# Diff summary — tui-cockpit-20260813

## Added

- `lib/tui/` — Textual 8.2.8 + Rich 15.0.0 optional cockpit (~2k LOC including tests)
  - `adapter.py` argv-only subprocess to `bin/productteam`
  - `app.py` visualizer layout + slash dock + provider interrupt
  - `session.py` chat-only verbs matching `lib/repl.sh`
  - `theme.py` two-accent tokens
  - `provider_turn.sh` Bash process-group provider turn
  - `tests/` pytest + snapshots + PTY
- `productteam tui` registry row (`chat_supported=0`)
- `state/harness-evolution/runs/tui-cockpit-20260813/` evidence

## Changed

- `.gitignore` — `lib/tui/.venv/` and caches (spike ignores preserved)
- `README.md` — 33 commands / 15 unsupported; tui documented as optional; chat remains fallback
- `bin/productteam` — `cmd_tui` TTY guard + exec venv
- `lib/commands.sh` — `tui` row
- `tests/cli-interface-parity.sh` — live tables 33/18/15/6
- `tests/visual-cli.sh` — ANSI-strip session-footer match (chat PTY, not TUI chrome)

## Untouched

- `lib/repl.sh`, `lib/theme.sh`, `lib/render.sh`, `lib/activity.sh`, `lib/provider.sh`
- `spikes/shared/`
- `state/harness-evolution/runs/cli-interface-20260812/CLI-BENCHMARK-CONTRACT.md` + FREEZE-SHA
- `frozen-benchmark.md` hash `cc827fff…`
