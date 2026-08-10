# Iteration 6 lessons

## What worked

- One structural role glyph per worker plus a single active accent stayed readable under `NO_COLOR` and held the two-hue budget.
- File-backed activity provided useful presence without adding a daemon or second orchestration layer.
- Separating deterministic PTY checks from an archived real-provider transcript made the visual contract repeatable without mocks.
- Normalizing number and `{score,evidence}` entries fixed an existing real `bench harness-cli` failure while enabling honest deltas.

## What failed and was repaired

- A completion card alone hid the provider refusal body. Failure paths must render captured stderr before compact chrome.
- The first benchmark writer equated 8/8 deterministic criteria with convergence even though its own contract required live proof.
- Permanent PTY tests initially used `script`; Python stdlib `pty` avoided a new runtime dependency.
- Backticked wildcard state paths failed the frozen stale-path check; document the resolvable parent path instead.

## Durable rule

A loading UI is correct only if it preserves provider bytes and exit status on success and failure. A deterministic benchmark may report criterion passes, but must not report convergence until every required live artifact is present and validated.
