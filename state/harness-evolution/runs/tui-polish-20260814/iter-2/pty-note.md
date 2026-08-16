# PTY note — iteration 2

## Passing real-provider seam probes

`lib/tui/.venv/bin/python -m pytest lib/tui/tests/test_pty.py::test_pty_provider_interrupt lib/tui/tests/test_pty.py::test_pty_typed_role_records_builder -q` → **2 passed** (`pty-test.txt`).

- After `provider_turn.sh ROOT PROMPT ROLE` and card-prepend changes, first Ctrl+C still reaps the provider group, preserves partial artifact bytes, and records `failed`; second Ctrl+C exits 130.
- A real executable provider fixture with typed `@Builder` records `Builder` in `workers.tsv`, proving role argv and removal of the Analyst hardcode.

## Failing real slash PTY probe

The full native run reached **35 passed, 1 failed**. `test_pty_status_and_gate_refuse` rendered the header but `/status` did not produce `Product Consulting Harness` within 25s (`pytest.txt`). This is a real TTY focus/input regression after the composer-region/RoleChip change; the run did not reach the subsequent `/gate` assertion. It must be fixed, not papered over.

## Still-open frozen PTY rows

- Live ioctl/SIGWINCH `80→40→80`: **FAIL / absent**.
- Dedicated activity strip with empty artifact and no fake speech: **FAIL / absent**.
- Ask dock, confirm cancel/no-spawn, evidence panel, and TUI splash: **FAIL / absent**.

Static four-size reachability and deterministic color snapshots pass through `test_layout.py` (Worker: 10 passed), but they are not a substitute for the missing live resize proof.
