# PTY note — iteration 1

## Commands

- `lib/tui/.venv/bin/python -m pytest lib/tui/tests/test_pty.py -q` → **2 passed** (`pty-test.txt`).
  - Real `productteam tui` PTY rendered the cockpit, `/status` reached real CLI output, and `/gate` refused with registry reason without spawning gate.
  - Provider interrupt probe retained the partial artifact, marked `workers.tsv` failed, and second Ctrl+C exited 130.
- `lib/tui/.venv/bin/python -m pytest lib/tui/tests/test_layout.py -q` was run by the Worker → **7 passed**. Static `120x36`, `80x24`, `60x24`, and `40x20` widget reachability and dock-above-composer assertions passed.

## Frozen PTY rows not yet satisfied

- Live ioctl/SIGWINCH `80→40→80`: **FAIL / no proof in iter-1**. Explicit compact mode was intentionally deferred by the accepted debate boundary. The current `on_resize` does not produce the locked compact/restored header proof.
- Role argv `@Builder` → `workers.tsv`: **FAIL / not implemented in iter-1**. Provider signature remains the shipped `ROOT PROMPT` seam.
- Activity-vs-speech empty-artifact proof: **FAIL / no activity region in iter-1**.
- Structured ask dock: **FAIL / absent**.
- Confirm cancel/no-spawn: **FAIL / absent**.
- Bordered evidence panel: **FAIL / absent**.
- TUI-owned splash: **FAIL / absent**.

The iter-1 PTY evidence is deliberately non-converged; it proves preservation of shipped slash/interrupt behavior while the later frozen slices remain open.
