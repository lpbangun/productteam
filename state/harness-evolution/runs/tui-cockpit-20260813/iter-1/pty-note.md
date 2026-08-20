# PTY note — tui-cockpit-20260813 iter-1

Two PTY probes were run against the **real** `bin/productteam tui` (no mocks,
no proxy binaries) using a stdlib `pty.fork()` with a 24x80 window.

## 1. Slash + refuse (automated: `lib/tui/tests/test_pty.py::test_pty_status_and_gate_refuse`)

- Launched `bin/productteam tui` in a pty (`TERM=xterm-256color`,
  `CONSULT_NO_SPLASH=1`).
- Typed `/status` + Enter: real `productteam status` output reached the
  transcript (`Product Consulting Harness`, engagement text `harness-cli`).
- Typed `/gate` + Enter: refuse reason rendered
  (`use the CLI: productteam gate … owner-gated durable decisions …`).
- No `Directive: no directive` text appeared → **the refuse path did NOT
  spawn a real gate run**.
- `/exit` exited cleanly (status 0).

## 2. Provider interrupt (automated: `lib/tui/tests/test_pty.py::test_pty_provider_interrupt`)

- Launched the cockpit with `CONSULT_PROVIDER=/tmp/.../slow-provider.sh`
  (a real executable that prints a prefix then sleeps) and a throwaway
  `CONSULT_STATE_ROOT`.
- Typed bare text + Enter: artifact streamed into the transcript
  (`partial analysis begins`).
- First Ctrl+C (`\x03`): interrupt toast shown, partial artifact bytes kept,
  `workers.tsv` row flipped to `failed`.
- Second Ctrl+C: app exited with status **130**; termios restored by Textual
  (alternate-screen teardown visible in the capture).

Manual pre-check (before automating) confirmed the bash-side process group
semantics: `provider_turn.sh` (started with `start_new_session=True`, i.e. its
own session + process group) receives SIGINT, its `INT` trap runs
`kill -TERM -- -$!` against the provider job group, preserves the partial
artifact, marks the worker failed via `activity_update`, and exits 130.

## Result

All PTY checks pass on this machine (pty-capable). If an environment lacks
`/dev/ptmx` or `fork`, `test_pty.py` skips rather than fakes the run.
