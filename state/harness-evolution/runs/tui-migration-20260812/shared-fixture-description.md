# Shared fixture description

All shared files are framework-neutral and read-only to both builders.

- `screen-state.json`: deterministic semantic cockpit input containing all eight components, Unicode classes, Markdown/code, long token/path, diff, evidence, and notifications. Real CLI seams are separately served through the external proxy.
- `session-events.ndjson`: 19 version-1 envelopes covering all 14 required event types with strict sequence, ISO timestamp, stable session ID, nonnegative timing, required type, payload, and `run_id`. `run-complete`, `run-interrupted`, and `run-failed` disambiguate terminal observations. It is frontend protocol data, not an autonomy engine.
- `workers.tsv`: copied deterministic canonical worker projection with the existing eight-column schema and running/pending/done states.
- `scenarios.json`: executable source for four scenarios, four sizes, common keymap, content matrix, proxy allowlist, negative-event cases, noninteractive contract, prohibitions, and normative-file list.
- `runtime-manifest.json`: frozen host Bun/Python paths, executable hashes, and versions used to prevent runtime/framework substitution.
- `process_fixture.py`: safe Python parent writes a partial artifact, starts a child, records parent/child/PGID, streams, and supports hang/success/failure. It imports no ProductTeam code and never reads/writes repository state.
- `event-schema.json`: per-type payload contracts plus complete/interrupted/failed run transition rules.
- `pty_driver.py`: external tmux PTY/cell driver. It performs the shared keystrokes, records frames, owns sandbox/PID evidence, compares termios, validates exact argv/state immutability, audits forbidden process APIs, and rejects survivors.
- `benchmark.py`: verifies the freeze manifest, exact symmetric framework versions, valid/invalid event exits, non-TTY behavior, and the full PTY suite. Candidate booleans do not satisfy mandatory interactions.
- `measure.py`: common startup, whole-tree RSS, size, dependencies, LOC, and normal/failure terminal method.
- `score.py`: external citation/threshold/tie/material/cost decision evaluator.
- `scoring-rubric.json`: dimension-specific 0/5/8/9/10 evidence anchors, missing-evidence behavior, measurement rules, tie/material/cost thresholds, and predeclared inconclusive test.
- `test_shared.py`: fourteen integrity/adversarial tests covering complete schema/reference parity, event correlation, worker projection, fixture success/failure/hang group cleanup, scoring completeness, scenario-driver keys, and rejection of a static self-attesting stub.

Current shared verification:

```text
python3 -m py_compile spikes/shared/*.py
python3 -m unittest -v spikes/shared/test_shared.py
python3 spikes/shared/pty_driver.py --adversarial-self-test
```

Result: 14/14 tests pass twice; static stub, fake lifecycle, scenario mutation, real-CLI bypass, network/provider class, database/eval, and survivor adversaries are rejected. The candidate-specific implementations do not exist yet, so no candidate behavior is claimed by this fixture proof.
