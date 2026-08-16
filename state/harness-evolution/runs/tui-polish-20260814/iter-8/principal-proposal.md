# Principal proposal — iteration 8 (TUI-owned splash only)

Hand the Critic this proposal. The Worker contract is **not** this file until debate binds it.

## Slice

Implement the freeze R7 / D16 TUI-owned boot splash and only the mechanics coupled to that boot state. Copy the starting bound from `iter-7/reviewer-gate.md` “Iter-8 bind (TUI-owned splash only)”. Do not implement proof-gap work (empty-home, pulse, prompt_export, live-PTY activity/empty-artifact/compact-cap, live-PTY `/report`).

Implied lift: D16 0.0 → ~9.0; D26 5.0 → ~9.0; D28 8.5 → ~8.7 (not 9.0). Hold every already-cleared ≥9.0 dimension.

## Files the Worker may touch

- `lib/tui/app.py` — boot splash on the existing compose tree; skip; glow; `CONSULT_NO_SPLASH` short-circuit; composer/footer stay visible
- `lib/tui/theme.py` — ASCII head helper(s) only; no new hex; no token table; no ROLE_STYLES edits
- `lib/tui/tests/test_layout.py` — native splash proofs
- `lib/tui/tests/test_nontty.py` — only if otherwise regressing the two existing rows

May not touch: `provider_turn.sh`, `adapter.py`, `session.py`, `test_pty.py` assertions, `test_all_verbs.py` NEEDLES, `test_slash.py`, Bash modules, freeze files, unrelated dirty worktree.

## Hazards the Critic must bind or cut

1. `#transcript` is append-only RichLog. Splash must not leave art in the transcript after skip/finish, or `_boot_home` / Q1 drown.
2. `Composer._on_key` currently routes Enter to `submit_composer` and Esc to `on_composer_escape`. Splash skip must intercept first: Enter/Esc/`/` skip without submit, without opening slash, without spawning.
3. Native `run_test` does not set `CONSULT_NO_SPLASH` on ProductTeamApp. Default-on splash would red the existing 52. Bind app-boot env short-circuit and how splash tests unset it.
4. Glow proof must be deterministic (stepper the test can fire), not wall-clock sleep. Exact order Principal → Analyst → Builder → Principal, one at a time. Idle all-neutral. Subtitle names the glowing head. Existing PRINCIPAL/ANALYST/BUILDER/OK only.
5. ASCII vocabulary must be named (three heads matching the glow roles). Not `lib/splash.sh` six-node graph. Not `ROBOTS_MARK`. Compact 40-col must keep composer+footer visible.
6. Once at boot when env unset; no replay on resize/slash/provider. Skip and natural finish both land idle home + `composer.focus()`. `_seed` may run under the overlay.
7. `/splash` after skip/finish remains the real CLI Command turn (`▣` needle in `_turns` / Command delta). It does not restart TUI boot splash.
8. Non-TTY `__main__.py` path unchanged.

Worker check: `lib/tui/.venv/bin/python -m pytest lib/tui/tests/test_layout.py -q`

Critic writes `iter-8/debate.md` only. No implementation, no scoring, no validation commands.
