# Iteration 4 notes — activity, speech, footer, compact

## Implemented slice

- Conditional non-focusable `#activity`, exact-session `workers.tsv` polling, braille/live elapsed, and 3/2/1+N caps.
- Role-owned speech rail on first artifact bytes; no full-body transcript replay at completion.
- Exact idle, busy, and slash footer strings.
- Explicit <=40 header and focus-safe `on_resize`.
- Native layout/activity/resize tests and a new real-PTY SIGWINCH test; snapshots refreshed.

## Verification

| Check | Result |
|---|---|
| Worker targeted layout | PASS — 12 passed |
| Native pytest + snapshots | **FAIL — 4 failed, 35 passed** (`pytest.txt`) |
| Canonical parity | PASS — 33/18/15/6 (`cli-interface-parity.txt`) |
| Visual CLI | 14/14; allowed overall exit 1 only for missing live-provider proof (`visual-cli.txt`) |
| Provider stream/interrupt | FAIL — artifact is drained once before blocking on provider exit |
| Role argv | workers seam remains, but real PTY speech needle times out |
| SIGWINCH | Product implementation covered natively; PTY needle is not ANSI-normalized and times out |

## Decision

Iteration 4 is FAIL. Preserve the implemented UI slice, but iteration 5 must first repair live artifact streaming and make the SIGWINCH proof observe the terminal honestly. No remaining feature work may be called complete unless the full native suite returns green.
