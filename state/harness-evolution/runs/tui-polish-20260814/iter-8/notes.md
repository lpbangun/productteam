# Iteration 8 notes — TUI-owned boot splash

## Function implemented

- Exact TUI-owned three-head angular ASCII frame in the transcript slot; composer/footer remain mounted and visible.
- Neutral idle frame; live OK glow order Principal→Analyst→Builder→Principal; natural finish once.
- Any-key skip consumes input before composer/chips/global Ctrl+C/Ctrl+Q/command-palette actions. After skip normal key behavior resumes.
- Non-empty `CONSULT_NO_SPLASH` bypasses boot; existing test and PTY workflows remain immediate-idle.
- Splash art never enters transcript state; seeded home remains underneath and appears after finish.
- `/splash` remains a real CLI Command turn and does not replay TUI boot.

## Verification

| Check | Result |
|---|---|
| Native pytest | PASS — 67 passed (`pytest.txt`) |
| Real PTY regressions | PASS — 5 passed (`pty-test.txt`) |
| CLI parity | PASS — 33/18/15/6 (`cli-interface-parity.txt`) |
| Visual CLI | 14/14; allowed exit 1 only for existing live-provider proof (`visual-cli.txt`) |
| Splash behavior | PASS — exact art, spans, glow, skip, finish, compact, once, env and CLI separation |
| Non-TTY | PASS inside native suite; app is never constructed |

## Remaining convergence work

There are no known zero-score functions. Iter-9 should close Reviewer-named proof gaps on already-implemented home/header/activity/speech/compact/provider/evidence/splash behavior, preferably with real PTY rows. Iter-10 remains available for final independent-review fallout only.
