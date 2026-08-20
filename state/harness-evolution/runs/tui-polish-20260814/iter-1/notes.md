# Iteration 1 notes — identity and honest state

## Accepted slice

Critic `iter-1/debate.md` revised the Principal's broader proposal to the smallest coherent presentation slice: filtered home, cwd/latest-score header, exact cockpit role tokens, static identity chips, You turn rail/label/timestamp, and cockpit-vs-Bash color assertions. Targeted lift: D02, D03, D04, D05, D19, D23.

Worker changed only:

- `lib/tui/app.py`
- `lib/tui/theme.py`
- `lib/tui/tests/test_layout.py`
- `lib/tui/tests/__snapshots__/cockpit-80x24.svg`
- `lib/tui/tests/__snapshots__/palette-80x24.svg`

## Observable slice result

- Home calls structured `status --json` only; no prose `status` seed or full dump enters transcript/turn history.
- Home is capped at three scored rows and filters smoke/run-loop/gate-smoke/overnight-rehears names.
- Header shape is `▣─▣─▣ ProductTeam · exp-tui-migration · —` in this worktree. The em dash is honest: no engagement `Repo:` resolves exactly to this worktree. No fallback to unrelated `harness-cli`; no Mode/Directive.
- Exact owner-locked You/Principal/Analyst/Builder/Critic hues are cockpit-only. Canonical Bash red/green accent assertion remains separate.
- Bare text writes a gray-railed `You · HH:MM` turn with markdown-lite body rather than a plain echo.
- Snapshots show three filtered scored rows, exact role-colored chips, and no excluded smoke/run-loop copy or `Directive`. A legitimate global scored `harness-cli` row may appear in home; the header never uses it.

## Principal test table

| Check | Result |
|---|---|
| Native pytest + snapshots | **FAIL** — 23 passed, 9 failed (`pytest.txt`). All failures are stale boot needles waiting for the removed prose-status seed; `test_slash._wait_for` also calls nonexistent `app.pause()` only after that stale wait misses. |
| Home seed | **PASS for iter-1 slice** — targeted test and snapshots assert cap/exclusions/no prose seed. |
| Turn chrome | **PASS for You** — targeted per-turn delta test; provider role speech remains deferred. |
| Role argv | **FAIL / absent**. |
| Activity vs speech | **FAIL / absent**. |
| Ask dock | **FAIL / absent**. |
| Confirm | **FAIL / absent**. |
| Evidence | **FAIL / absent**. |
| PTY slash | **PASS preservation** — real `/status`, `/gate` no-spawn (`pty-test.txt`, `pty-note.md`). |
| PTY sizes + SIGWINCH | Static sizes pass; live `80→40→80` **FAIL / absent**. |
| Provider interrupt | **PASS preservation** — partial artifact, failed worker, second Ctrl+C 130. |
| CLI interface parity | **PASS** (`cli-interface-parity.txt`), 33/18/15/6. |
| Visual CLI | **14/14**; overall exit 1 only for allowed pre-existing missing live-provider proof (`visual-cli.txt`). |

## Next failing slice

Fix stale native-test boot synchronization, then implement the coupled live-work/control seam from the Critic: selected role → provider role/card prompt → honest activity/speech → dynamic footer → compact/SIGWINCH. Docks and splash remain later unless scope stays coherent.
