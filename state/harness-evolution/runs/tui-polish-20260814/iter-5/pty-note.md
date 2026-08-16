# PTY note — iteration 5

`lib/tui/.venv/bin/python -m pytest lib/tui/tests/test_pty.py -q` → **4 passed** (`pty-test.txt`). Full native run also reports **39 passed** (`pytest.txt`).

- Real `/status` streams through the `harness-cli` engagement; `/gate` refuses and does not spawn.
- Slow-provider artifact bytes stream live into one owned role turn. First Ctrl+C keeps partial output and marks the worker failed; second exits 130.
- Typed `@Builder verify the seam` renders Builder speech and records Builder/done/mission in `workers.tsv`.
- Real ioctl SIGWINCH 80→40→80 proves normalized wide heads, compact `ProductTeam {score}` without heads/cwd, composer `@Principal` retained, and wide heads restored.

Repairs: provider artifacts are drained repeatedly while the process is alive and once after exit; periodic activity paint pauses while a CLI argv stream is active; exit/quit waits boundedly for that already-running stream so queued output is not discarded; PTY resize assertions normalize terminal control sequences rather than weakening text needles.
