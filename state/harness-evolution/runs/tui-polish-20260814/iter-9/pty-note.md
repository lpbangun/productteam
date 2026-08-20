# PTY note — iteration 9

## Live proof

`lib/tui/.venv/bin/python -m pytest lib/tui/tests/test_pty.py -q`: **6 passed** (`pty-test.txt`).

The sixth row launches the real `bin/productteam tui` and existing `provider_turn.sh` against a hold-then-speak executable. One turn proves, in order:

- `@Builder verify the seam` creates the exact session `workers.tsv` row while its artifact is absent/empty.
- Before provider bytes: the normalized invocation delta has no `Thinking…` and no agent speaking rail; the live strip contains a braille frame, mission, provider basename, `m:ss`, and busy interrupt footer.
- Two live rows are atomically appended to that exact TSV without dropping Builder.
- Live ioctl `80→40` renders `ProductTeam {score}`, omits heads/cwd, retains the actual session-local `@Builder` composer target, and renders `+2`; `40→80` restores `▣─▣─▣ ProductTeam` while work remains live.
- The provider's captured `-p` argv equals the live Builder `prompt_export`, blank line, and user prompt before stdout.
- First provider bytes open exactly one Builder speaking rail; `Thinking…` remains absent.
- `/exit` returns 0. Existing SIGINT row remains separate and green.

## Chronology hardening

The first full native run exposed an existing PTY race: the interrupt row waited for the immediate toast, then sent the force-exit Ctrl+C before Textual painted the failed card. Product behavior and artifact/worker state were correct, but the accumulated output could miss `partial output left on disk`.

The row now waits for the first Ctrl+C's failed card before sending the second Ctrl+C. This strengthens the asserted chronology: first interrupt reaps/preserves/marks failed and paints the card; second exits 130. Targeted PTY and the repeated full native suite are green.
