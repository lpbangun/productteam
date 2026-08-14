# Reviewer gate — iter-1

Reviewer run: `0a432e41`
Verdict: **FAIL**

Mandatory dimensions below 9.0: **3 (1.0), 7 (8.5), 8 (8.0)**.

## Scores

| # | dimension | score | citation |
|---|---|---:|---|
| 1 | Visual layout | 9.2 | `lib/tui/app.py` CSS; `test_layout.py`; pytest 28 pass |
| 2 | Registry palette | 10.0 | `adapter.py` live help --json |
| 3 | Supported argv | 1.0 | Only `/status` proven in TUI transcript; other verbs adapter-direct or skipped |
| 4 | Unsupported refuse | 9.7 | All 15 refuse without spawn |
| 5 | Provider interrupt | 9.4 | PTY partial + failed + 130 |
| 6 | Non-TTY / NO_COLOR | 10.0 | `test_nontty.py` |
| 7 | Four sizes | 8.5 | Dock/composer checked; transcript/chips regions not asserted |
| 8 | Canonical CLI | 8.0 | parity PASS; visual-cli 13/14 session-footer; live proof missing |
| 9 | Argv / trace honesty | 9.8 | argv arrays, agents --json allowed |
| 10 | Authority | 9.2 | Bash owns CLI/provider; `/export` content incomplete |

## Required next commands

1. Prove all 18 supported verbs, with valid arguments, through the real TUI transcript.
2. Assert header/transcript/chips/composer/dock reachable at four sizes.
3. `/export` must include actual CLI and provider output.
4. `tests/visual-cli.sh` 14/14. Do not change TUI to mask the chat-footer ANSI flake.
5. Live-provider proof remains the pre-existing allowed overall-exit-1 reason; do not mock.

Full review: `.pi/subagents/artifacts/0a432e41_reviewer_0_output.md`
