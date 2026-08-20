# Iteration 9 notes — convergence proof cluster

## Product change

`lib/tui/app.py` now orders eligible home rows by the mtime of each client's latest valid numeric `iter-N/scores.json`, then numeric iteration and stable client name. It does not add fields to `status --json`. A cwd-mapped client can occupy one pinned slot only when outside the true top three; the remaining rows stay recency ordered. Existing bans and the three-row cap remain.

## New native proof

`lib/tui/tests/test_layout.py` adds five rows:

- exact empty-home projection and retained idle cockpit;
- mtime order, cap, exclusions, and mapped-slot behavior;
- numeric `iter-10` vs `iter-9` and alphabetical tie-break;
- idle/live/compact middle-head span styling;
- Principal/Analyst/Builder/Critic speaking rails with exact role hue and neutral body.

`lib/tui/tests/test_pty.py` adds one real executable row covering the exact-session live activity strip, silent empty-artifact window, prompt export, live 80→40→80 behavior, 1+N cap, and first owned speech. The compact composer needle is `@Builder`, not `@Principal`: the typed role intentionally changes the session-local target under Q15.

## Acceptance

- Native TUI suite: **73 passed** (`pytest.txt`).
- Real PTY suite: **6 passed** (`pty-test.txt`).
- CLI interface parity: **PASS 33/18/15/6** (`cli-interface-parity.txt`).
- Canonical visual CLI: **14/14**, exit 1 only for the freeze-allowed pre-existing missing live-provider proof (`visual-cli.txt`).
- No edits to `provider_turn.sh`, adapter/session/theme, Bash authority, registry, frozen files, or snapshots.

The first full-suite run found an interrupt-card paint race in the PTY assertion. The test now waits for the first Ctrl+C's failed card before issuing the second Ctrl+C; this strengthens rather than weakens the frozen interrupt sequence. The repeated full suite is green.

Expected lift: D03/D04/D05/D06/D07/D09/D24/D28 to at least 9.0. Independent Reviewer decides convergence.
