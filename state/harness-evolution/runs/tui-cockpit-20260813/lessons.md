# Lessons — tui-cockpit-20260813

- Freeze first against the **executable** CLI. The 2026-08-12 spike died on a 0444 proxy and a substring `agent` ban. Token-aware traces that allow `agents --json` were the whole difference.
- `help --json` as the palette works. Adding `tui` is a 32→33 registry change; update only the live parity tables, never the historical CLI-BENCHMARK-CONTRACT hash.
- A TUI test that greps the **whole** transcript will false-pass. Isolate per-invocation CLI turns and wait for the worker thread.
- `CONSULT_NO_SPLASH=1` hides `/splash`. Unset it only for that argv.
- `productteam smoke` and `harness-checks` are multi-minute. Stream with a wall-clock deadline so the banner is real and the test ends.
- visual-cli `session-footer` failed because dim ANSI wrapped `mode: —`. Strip CSI in the chat probe; do not change TUI chrome to mask it.
- Reviewer is read-only. Parent must run argv dry-runs and tests; reviewer cites those artifacts.
- Worker timed out at 30m after writing the tree. Finish tests in the parent rather than relaunching a second writer on the same cwd.
