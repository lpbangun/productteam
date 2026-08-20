# Iteration 3 notes — real-PTY slash repair

## Slice

Critic `iter-3/debate.md` rejected unrelated scope and bound one `app.py` repair: keep Composer focused while the slash dock is visible/closing. No tests, provider seam, visual chrome, snapshots, or deferred feature work changed.

## Result

- Native pytest + snapshots: **36 passed** (`pytest.txt`).
- Real PTY: `/status`, `/gate` refuse/no-spawn, interrupt, and Builder role argv all pass (`pty-test.txt`, `pty-note.md`).
- CLI interface parity: **PASS**, 33/18/15/6 (`cli-interface-parity.txt`).
- Visual CLI: **14/14**, overall exit 1 only for allowed pre-existing missing live-provider proof (`visual-cli.txt`).

## Frozen table status

| Check | Result |
|---|---|
| Native pytest + snapshots | PASS |
| Home / You / targeting / role argv | PASS for implemented paths |
| PTY slash | PASS |
| Provider interrupt | PASS |
| Activity vs speech | FAIL / absent |
| Ask | FAIL / absent |
| Confirm | FAIL / absent |
| Evidence | FAIL / absent |
| PTY sizes + SIGWINCH | Static sizes pass; live resize FAIL / absent |
| TUI splash | FAIL / absent |
| Canonical Bash gates | PASS / 14-of-14 allowed exception |

## Next slice

With the full suite green and role argv honest, the next coherent dependency chain is activity strip → speaking-turn ownership → state-dependent footer → explicit 40-column mode and live resize proof. Ask/confirm/evidence/splash remain for the final permitted iteration unless the Reviewer narrows differently.
