# Critic prebuild rebuttal

## Initial verdict — REJECT-PENDING-AMENDMENTS

The first candidate benchmark could be passed by a static responder. `benchmark.py` accepted candidate-returned booleans for focus, event streaming, lifecycle reap, and terminal restoration; static frames required only marker words. The four `scenarios.json` workflows were documentation rather than executable inputs.

Freeze blockers identified by the Critic:

1. Add one external real-PTY driver for both candidates and all scenarios/sizes.
2. Independently own/read PID/PGID evidence, send both Ctrl+C inputs, test post-cancel editing, and compare terminal attributes.
3. Externally observe exact ProductTeam argv and state immutability; reject shell execution, databases, provider/destructive calls, and surviving daemons.
4. Make `scenarios.json` and `screen-state.json` executable sources rather than duplicated prose.
5. Generate malformed/wrong-version/order/session/timing event variants outside the candidate and require actual refusal.
6. Freeze score anchors, measurement methods, tie interval, material advantage, OpenTUI cost limits, and the deciding test.
7. Supply deterministic worker data and strengthen shared schema/cross-file/lifecycle tests.
8. Hash every normative file; benchmark must reject drift before execution.

The Critic also rebutted every required surface: header checks lacked real values; transcript was never scrolled; worker data was absent; composer was not edited; palette provenance/reasons were not proven; diff/evidence overlays lacked focus/background proof; interruption/failure was not visually observed.

## Advisor amendments before re-review

- Added `spikes/shared/pty_driver.py`: launches the actual candidate under isolated tmux PTYs at 120×36, 80×24, 60×24, and 40×20; injects Ctrl+E, Ctrl+P, Shift+Enter, bracketed paste, cursor editing, Ctrl+R, PageUp/End, Ctrl+G, and two Ctrl+C inputs; captures real terminal panes.
- Added a generated read-only ProductTeam proxy. It logs exact argv, blocks every non-allowlisted command, injects a per-run dynamic refusal sentinel, and serves real read-only CLI responses. Frozen copied state is hashed before/after.
- Lifecycle evidence is runner-owned: temporary spaced artifact/PID paths, external parent/child/PGID liveness checks, complete group disappearance, artifact bytes, post-cancel composer sentinel, second-Ctrl+C exit 130, and before/after termios comparison.
- Added `spikes/shared/workers.tsv` and correlated completed/interrupted/failed event payloads by `run_id`.
- Replaced candidate event booleans with benchmark-generated malformed, duplicate-sequence, wrong-version, mixed-session, negative-delay, and missing-payload files; exit/stderr is externally asserted.
- Added `spikes/shared/scoring-rubric.json` with 0/5/8/9/10 anchors for all 18 dimensions, missing-evidence score 0, measurement methods, 0.25 tie interval, 20% material threshold, OpenTUI cost limits, and a predeclared neutral-host deciding test.
- Added `spikes/shared/measure.py` for external startup, whole-tree RSS, local installed/package bytes, dependency inventory, LOC, and success/failure PTY restoration.
- Strengthened `test_shared.py` to seven tests: complete schemas/references, run correlation, worker projection, success/failure/hanging process fixture with real group termination, scoring completeness, scenario/driver key parity, and rejection of a static self-attesting stub.
- `benchmark.py` now validates the freeze manifest, generates negative events, checks non-TTY externally, invokes the real PTY suite, audits source for shell/eval/database APIs, constrains evidence output, and no longer accepts mandatory interaction booleans.

Verification after amendments:

```text
python3 -m py_compile spikes/shared/*.py
python3 -m unittest -v spikes/shared/test_shared.py
python3 spikes/shared/pty_driver.py --adversarial-self-test
```

Outcome: 7 tests passed in 6.723s; `{"static_stub_rejected": true}`.

## Freeze status

Pending Critic re-review. Builders remain unauthorized until the Critic accepts these amendments and `FREEZE-SHA.txt` is written.


## Second verdict — REJECT-PENDING-AMENDMENTS

The Critic accepted the external PTY foundation (F1) but rejected freeze because PID files could be forged, the proxy was cooperative, scenario semantics remained marker-based, run schemas were incomplete, measurements/decision rules were not executable, and output/freeze scope was loose.

Second amendment pass:

- The fixture now traps SIGTERM/SIGINT and deterministically terminates/reaps its child.
- Before Ctrl+C, the runner proves live `/proc` parent/child identities, exact spaced fixture argv, child PPid, shared new PGID distinct from the candidate, and pre-cancel artifact hash. Fake PID/artifact records are an explicit failing test.
- Candidate cwd is the proxy root; PATH contains only proxy bin plus system bins. Every PTY descendant is traced with `strace -ff` for process/network calls; real ProductTeam/provider/destructive/network execs fail; traced PIDs must be gone. Canonical code/state trees are hashed before/after. Adversarial tests cover real-CLI bypass, network, curl/provider class, SQLite/eval source, and a live survivor.
- `screen-state.json`, `workers.tsv`, event payloads, and machine action/observation IDs now drive exact assertions. The driver requires header values, roles/states, transcript text, composer/evidence/diff bytes, focus edits after overlay close, scroll restoration, one edited submission, dynamic refusal, replay progression, unread clearing, and exact run IDs. Scenario coverage mutation fails.
- Added `event-schema.json`; the stream now contains valid complete/interrupted/failed correlated lifecycles (19 envelopes). Shared tests validate payload requirements and transitions. Benchmark negatives now include sequence gap, unknown type, invalid payload type, illegal transition, and timestamp/delay mismatch in addition to the first six cases. Real event-to-visible timing windows are measured.
- Every dimension now has dimension-specific 0/5/8/9/10 anchors. `measure.py` uses complete first-frame startup, 10-second streaming RSS, external 100-character p95 latency at 60×24 and 40×20, external dependency inventory, size, LOC, and normal/failure termios. `score.py` validates citations, mandatory gates, tie/material/OpenTUI-cost rules, and produces the decision. Native suite commands are fixed by framework in `benchmark.py`.
- Framework names bind to exact candidate directories/entrypoint forms before any invocation. Evidence output is restricted below `runs/tui-migration-20260812/evidence/<framework>`. Freeze membership is exact, with duplicates/extra/omission/traversal/symlink rejection, and is rechecked after every candidate phase.

Focused proof now passes 11 shared tests, including lifecycle, boundary adversaries, scenario mutation, fake lifecycle, score rules, and static-stub rejection.

Builders remain unauthorized pending the next Critic review and freeze manifest.


## Third verdict — REJECT-PENDING-AMENDMENTS

The Critic closed F1/F2 but found five decision-changing false-pass paths: one-width/no-range score logic and zero-byte absent packages; fake runtime/framework substitution and source symlink escapes; shell `-c` plus non-engagement authority writes; non-orthogonal/incomplete event negatives; and bulk scenario credit without true newline/scroll/event progression proof.

Third amendment pass:

- Added frozen `runtime-manifest.json` with actual Bun/Python paths, executable SHA-256, and versions. Framework scope now requires the exact runtime identity, exact candidate directory/entrypoint/manifest/lock/package script, no candidate-owned symlink escapes, exact installed framework versions queried independently, and fixed native typecheck/test/package commands. Adversaries reject fake Bun and escaped entrypoints.
- Authority hashing now covers the entire worktree except candidate-owned trees, temp, Git internals, caches, and the declared evidence output. Python AST catches spaced `shell = True`; JS patterns supplement; external traces reject sh/bash/dash `-c`, real ProductTeam, provider/destructive executables, network sockets, and survivors. Tests detect a write under `state/harness-evolution/` outside engagements.
- Event negatives now preserve timestamps for a transition-only failure and systematically remove/invalid-type every required field for all 14 payload types, plus sequence/version/session/type/timing cases. Canonical events are checked against every declared type/enum/boundary. Orthogonality and negative count are tested.
- Scenario IDs are recorded one action at the actual key/send and one observation at its dedicated assertion—bulk credit is removed. New top/bottom transcript anchors prove PageUp changes state and overlay close restores it. Submitted lines use `LINE1END`/`LINE2START` on distinct captured rows, proving Shift+Enter rather than visual wrapping. Replay requires exact `EVENT 8/19` then `EVENT 19/19` while the top anchor remains stable, dynamic unread appearance, exact run IDs/payloads, and unread clearing at End.
- Packaging is a fixed native command and absent/empty `dist` fails. Latency uses three 100-character/10-second runs per narrow size with p95 ranges. The scorer requires material latency at both sizes above noise, treats LOC/payload as separate OR branches, implements the exact retain-both neutral-host evidence branch, and has boundary tests for one-width-only, absent package, tie, and retain-both.

Focused proof: 14/14 shared/adversarial tests pass twice; static stub rejected. Builders remain blocked for final Critic acceptance.


## Final authorization — ACCEPT-FOR-FREEZE

The sole remaining summary-only latency bypass is closed. `score.py` requires exactly three 100-sample runs at both 60×24 and 40×20, rejects nonfinite/negative/missing data, and recomputes median/min/max/range before applying the two-width material rule. Focused reproduction now raises `ScoreError`; 14/14 tests pass twice.

Critic authorization: freeze the exact 18-file set enforced by `benchmark.freeze_paths()` and start both Builders in parallel. Any later shared-file edit invalidates the manifest and requires recorded rationale plus new Critic review before implementation may continue.
