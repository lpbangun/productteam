# Accepted bounded work list

Principal decision: accept one evidence-spike work item per candidate after the amended benchmark receives Critic approval and is hashed. No implementation may start earlier.

## OpenTUI Builder — `spikes/opentui/` only

Implement the eight shared surfaces, argv-only read adapters, strict shared event parser/replay, process-group lifecycle, non-TTY/terminal behavior, framework-native interaction/snapshot/unit tests, exact local dependencies/lock, and local package/measurement commands using OpenTUI core/Solid/keymap 0.5.2, Solid 1.9.12, and Bun 1.3+.

Expected benchmark lift: dimensions 1–12 and 18 from absent to directly testable; dimensions 13–17 become measurable. Explicit cuts: no ProductTeam state writes, domain/autonomy logic, provider execution, daemon/database, settings/onboarding/theme/session search/plugins, `productteam tui`, compatibility shim, or shared-file edit.

## Textual Builder — `spikes/textual/` only

Implement the same eight surfaces, adapters, parser/replay, lifecycle, non-TTY/terminal behavior, framework-native tests, exact local dependencies/lock, and package/measurement commands using Python 3.12, Textual 8.2.8, Rich 15.0.0, pytest, pytest-asyncio, and pytest-textual-snapshot.

Expected benchmark lift and cuts are identical to OpenTUI. Framework-native mechanics may differ; information architecture, actions, semantic states, fixture bytes, and frozen evidence bar may not.

## Shared contracts

Exact common-suite entrypoints are frozen:

- OpenTUI command: absolute Bun executable, `run`, absolute `spikes/opentui/src/main.tsx`.
- Textual command: absolute `spikes/textual/.venv/bin/python`, absolute `spikes/textual/src/productteam_tui/app.py`.

Both entrypoints must support:

- interactive bare launch under the shared environment;
- `--probe contract` redirect-safe exact-version JSON;
- `--validate-events <path>` against `event-schema.json`: valid exit 0; malformed/envelope/payload/transition/timing contract exit 2, no stdout, plain stderr containing `event`;
- `--terminal-case success|failure`: real renderer start then exit 0 or 17 with cleanup;
- `PRODUCTTEAM_TUI_REPLAY_REPEAT` for the frozen repeated 10-second measurement stream;
- common keys Ctrl+E evidence, Ctrl+P palette, Ctrl+R replay, Ctrl+G lifecycle, Escape close, Shift+Enter newline, Enter submit, Ctrl+C cancel/exit.

Each Builder must skip project-wide validation while building. The Principal runs the frozen common suite, measurements, real terminal smoke, canonical CLI regression checks, and evidence capture once both finish.

No visual churn after implementation. Repairs, if needed, are limited to unchanged-benchmark failures capable of changing retention.
