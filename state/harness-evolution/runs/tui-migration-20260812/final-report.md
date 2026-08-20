# ProductTeam TUI evidence spike — final report

## Decision

**No winner. Both prototypes were deleted; retain neither.** Neither OpenTUI nor Textual is recommended as an optional frontend or migration direction from this spike. The canonical Bash CLI and plain-file state remain unchanged.

This decision is caused by the frozen benchmark, not measured framework inferiority. Its generated ProductTeam proxy is made non-executable before required seams run, and its trace policy independently rejects the required `agents --json` token. Post-build benchmark edits were prohibited and none were made.

## Scenarios exercised

Native framework tests exercised the shared header, transcript, worker strip, multiline composer, registry palette model, evidence and permission overlays, failure/interruption notifications, strict 19-event replay, scrolling/unread state, focus restoration, Unicode/wrapping, four terminal sizes, and real fixture process-group cancellation. Direct PTY smoke exercised normal and injected-failure renderer cleanup at 80x24. Separate real tmux captures exercised base rendering at 120x36, 80x24, 60x24, and 40x20.

The frozen external Inspect, Compose/palette, Autonomous replay, and Process lifecycle scenario sequence did **not** complete. Therefore none is claimed as a benchmark pass.

## Verification outcomes

- Shared frozen self-tests: 14/14 pass; static-stub adversary rejected.
- OpenTUI before deletion: `bun run typecheck`; raw `bun test` 61/61 (916 assertions); `bun run package` — pass.
- Textual before deletion: `python -m compileall -q src`; `python -m pytest -q` 52/52 with eight snapshots, repeated; `python scripts/package.py` — pass.
- Both: contract probe, exhaustive generated malformed-event rejection, non-TTY exit 2/empty stdout/plain remedy/NO_COLOR — pass.
- Direct PTY terminal cases: both success 0 and failure 17; terminal attributes restored.
- Lifecycle unit checks: OpenTUI 3/3 and Textual 3/3; process groups reaped and partial bytes preserved.
- Canonical CLI interface parity: pass. Canonical visual CLI: 14/14 checks pass, command exits 1 only because its pre-existing live-provider proof is intentionally absent.
- Frozen full benchmark: fail/void before comparable interaction evidence. No cold/warm startup, RSS, or p95 comparison is valid.

## Changed files retained

- `spikes/shared/`: frozen framework-neutral fixtures, schemas, driver, measurement/scoring tools, and tests.
- `state/harness-evolution/runs/tui-migration-20260812/`: freeze, evidence, scores, verdict, comparison, terminal/frame captures, and reports.
- `.gitignore`: prototype dependency/build exclusions.

The evaluated `spikes/opentui/` and `spikes/textual/` trees were deleted as required by the non-convergence outcome.

## Remaining risks

OpenTUI demonstrated pre-1.0 API, Solid preload, Bun/native, dependency-size, and custom focus/dialog glue risk. Textual demonstrated Python environment/distribution and framework namespace/internal coupling risk. Neither obtained valid common-suite latency/RSS or complete external Ctrl+C/trace proof.

## Later migration

Neither deleted prototype should directly inform a migration decision. A later authorized spike may reuse only framework-neutral contracts and recorded learnings after creating and freezing a runnable external benchmark. Static evidence suggests Textual deserves the first rerun because it used 812 source LOC versus 1,371, 19 installed distributions versus 111 packages, and 38.9 MB versus 124.4 MB allocated dependency trees; those are prioritization facts, not a winner.

Must remain framework-neutral: semantic screen projection, event envelope/schema, command-registry derivation, argv-only CLI boundary, plain-file projections, process-group cancellation semantics, terminal/exit contract, scenario vocabulary, and scoring evidence.

## Owner escalation

A new benchmark freeze is constitution-level/change-control work and requires owner authorization. Required amendments: preserve executable mode on the generated proxy and replace substring trace rejection with token-aware policy that permits the mandated `agents --json` seam. Until then: no `productteam tui`, no default frontend, no migration, and no retained prototype.
