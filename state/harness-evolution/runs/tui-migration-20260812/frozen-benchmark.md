# ProductTeam TUI evidence-spike benchmark

Status: **candidate amended after Critic rejection; pending re-review and freeze hash**. Date: 2026-08-13.

## Decision

Compare OpenTUI 0.5.2 + Solid 1.9.12 against Textual 8.2.8 + Rich 15.0.0 as optional presentation clients. Bash remains the canonical CLI and sole domain/process/state authority. No `productteam tui`, daemon, database, provider ownership, second state writer, or migration default is authorized.

## Normative inputs and runners

`spikes/shared/scenarios.json` is the executable scenario source and names every normative shared file. Core inputs: `screen-state.json`, `session-events.ndjson`, `event-schema.json`, `workers.tsv`, `runtime-manifest.json`, and `process_fixture.py`. Enforcement: `benchmark.py`, `pty_driver.py`, `measure.py`, `test_shared.py`, and `scoring-rubric.json`.

`FREEZE-SHA.txt` records SHA-256 for every normative shared file plus this contract, the Advisor baseline, Critic rebuttal, accepted work list, and fixture description. `benchmark.py` rejects any mismatch before candidate execution. Evidence output may not target shared inputs, engagement state, or candidate source directories.

## Required product surface

1. Engagement/status header.
2. Scrollable chat transcript.
3. Worker/activity strip.
4. Permanently docked bordered multiline composer.
5. Registry-derived command palette.
6. Permission dialog with the shared unified diff.
7. Evidence viewer overlay.
8. Failure/interruption notification.

Overlays never replace/clear the composer. Close restores prior composer focus and transcript scroll. Streaming continues beneath overlays. Off-bottom streaming shows unread state and does not force a jump.

## External interaction contract

The same `pty_driver.py` launches each actual candidate in isolated tmux terminals at 120×36, 80×24, 60×24, and 40×20. `capture-pane` supplies externally observed cell text. The driver executes all four scenarios at every size:

- **Inspect:** capture real/copy header/transcript/workers/composer; type focus sentinel; Ctrl+E evidence; Escape; prove overlay/background coexistence and focus restoration.
- **Compose/palette:** type first line; Shift+Enter; bracketed paste Unicode/spaced path; cursor edit; Enter; Ctrl+P; filter `gate`; observe exact usage and per-run dynamic unsupported sentinel; Escape.
- **Replay:** Ctrl+R at real 1.0 timing; type during replay; PageUp; capture permission/diff and streaming under overlay; observe unread; Escape/End; observe completion, interruption, and failure.
- **Lifecycle:** Ctrl+G starts the shared parent/child fixture in a new process group; runner reads PID/PGID, sends first Ctrl+C, proves parent/child/group gone and artifact intact, types post-cancel sentinel, sends second Ctrl+C, requires exit 130 and equal before/after termios.

Content matrix: ASCII, emoji, CJK, combining mark, long token/path, multiline Markdown, fenced code, and unified diff.

## Boundary enforcement

A generated read-only ProductTeam proxy logs exact argv and blocks everything except:

- `help --json`
- `status --json`
- `agents --json`
- `gate harness-cli status`
- `workspace harness-cli status`
- `role harness-cli status 1`

The proxy returns current real read-only CLI data and injects a dynamic gate-refusal sentinel. A copied projection root contains inspect pack, history, scores, and workers. Pre/post hashes must match. Frozen runtime hashes plus installed framework metadata reject runtime/framework substitution and symlink escapes. AST/source audit and descendant traces reject shell execution, `eval`, SQLite/database APIs, and shell-string process APIs. New candidate/sandbox-tagged processes must not survive. Provider, destructive, owner-gated, long-running ProductTeam, and mutating commands fail at the proxy.

## Event validation

The version-1 fixture has 19 strictly sequenced envelopes covering all 14 required event types with timestamp, session ID, type, nonnegative delay, payload, and correlated `run_id`. It covers all requested types; completed/interrupted/failed terminal observations use distinct run IDs. The benchmark creates malformed JSON, duplicate sequence, wrong version, mixed session, negative delay, and missing-payload variants; each must exit 2 with a plain stderr event remedy and no stdout. Real replay remains an external PTY scenario.

## Non-interactive and terminal behavior

Bare non-TTY launch: exit 2, empty stdout, stderr contains `requires an interactive TTY`, no ESC under `NO_COLOR`. Redirected diagnostic probes remain JSON/plain UTF-8. Real PTY cases externally require normal exit 0, injected failure 17, signal/second-Ctrl+C 130, and termios restoration after all three.

## Scoring and measurements

`scoring-rubric.json` freezes evidence anchors for all 18 user dimensions. Missing direct evidence scores 0. Mandatory dimensions 1–12 and 18 each require ≥9.0 before retention. Independent Analyst scores; Critic audits every citation.

`measure.py` freezes: spawn-to-complete-first-frame cold/warm startup; 20Hz `/proc` whole-tree RSS including a 10-second stream and three-run p95 ranges at each narrow size; allocated source/dependency/package bytes; lock-derived runtime/dev dependency counts; nonblank noncomment source/test LOC; ten warm repetitions; success/failure PTY restoration. Framework-specific install/package commands may differ, but output method and exclusions do not.

`score.py` validates all 18 evidence-cited scores, missing-evidence behavior, mandatory retention gates, aggregates, and the final rule.

Approximate tie: mandatory/all-dimension mean delta ≤0.25 with no material advantage. Material advantage: ≥20% p95 replay-input latency at both narrow sizes, production LOC, or distributable payload, exceeding run range and without a mandatory regression. OpenTUI costs are acceptable only if installed size, warm startup, and streaming RSS are each ≤1.5× Textual and lifecycle/distribution remain ≥9. Textual wins an approximate tie. The only retain-both deciding test is the frozen 20-run neutral-host 10-second/20Hz replay described in `scoring-rubric.json`.

## Decision outcomes

Retain Textual; retain OpenTUI; retain both only under the exact inconclusive rule; or delete both and write non-convergence. Static screenshot sophistication cannot decide the result. No production migration is part of this spike.
