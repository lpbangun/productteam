# Iteration 2 notes — targeting and role argv

## Accepted slice

Critic `iter-2/debate.md` bound two steps: repair stale native test synchronization, then add focusable/clickable Static role chips, separate `@Role` composer chrome, typed-role parsing, `ROOT PROMPT ROLE`, selected card prompt prepend, Builder workers proof, and interrupt re-proof. Activity/footer/compact/docks/splash stayed out.

## Observable result

- Four `RoleChip(Static)` controls are focusable and clickable in one height-1 row; no Textual Button/cyan/new hue.
- Session target defaults Principal. Separate composer chrome displays `@Role`; buffer remains raw user input. Typed leading `@Role` is stripped and selects that role without breaking slash/empty behavior in native test mode.
- Python passes role argv. Bash defaults missing role to Principal, runs `activity_start "$ROLE"`, sources only `agent-cards.sh`, prepends `.prompt_export` or card block, and keeps `ARTIFACT=` first.
- Completion labels the active role, not Analyst. `provider_turn.sh` no longer contains `activity_start Analyst`.
- Real PTY `@Builder` turn records Builder; process-group interrupt still passes.
- Snapshots are exported with deterministic role hues even when the parent environment has `NO_COLOR`; non-TTY NO_COLOR tests remain separate.

## Principal test table

| Check | Result |
|---|---|
| Native pytest + snapshots | **FAIL** — 35 passed, 1 failed (`pytest.txt`): actual PTY `/status` input did not reach the transcript after composer-region change. |
| Home / You turn / target controls | Targeted layout **PASS** (Worker 10 passed); full suite includes those passes. |
| Role argv | **PASS** — real `@Builder` → Builder `workers.tsv` (`pty-test.txt`). |
| Provider interrupt | **PASS** after signature/card change (`pty-test.txt`). |
| Activity vs speech | **FAIL / no activity region**. |
| Ask / confirm / evidence / splash | **FAIL / absent**. |
| PTY slash | **FAIL** before `/status` output; `/gate` was not reached. |
| PTY sizes + SIGWINCH | Static sizes pass; live resize **FAIL / absent**. |
| CLI interface parity | **PASS**, 33/18/15/6 (`cli-interface-parity.txt`). |
| Visual CLI | **14/14**; overall exit 1 only for allowed pre-existing missing live-provider proof (`visual-cli.txt`). |

## Next failing slice

First fix the actual PTY focus/input regression and keep full pytest green. Then implement the now-unblocked coupled live activity/speech/footer/compact slice. Mute Command rails can ride with slash repair only if it stays local; ask/confirm/evidence/splash remain separate.
