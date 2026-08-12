# Final report — ProductTeam CLI interface

## Outcome

Canonical Bash CLI repaired and future frontend boundary established. Ink and OpenTUI were implemented as bounded live-data spikes, tested, measured, and deleted. No optional TUI retained.

Independent Analyst: overall 9.5; dimension vector `9,10,10,10,10,10,10,9,10,8,9`. Permanent Critic: ACCEPT diff, scores, architecture, organization, and terminal report. User overlay remains non-converged at iteration 6 because `dependencies-cold-start=8`; see `non-convergence-report.md`.

## Changed product files

- `lib/commands.sh`: canonical 32-command metadata, aliases, usage, handler, chat support/reason, JSON metadata.
- `bin/productteam`: generated help and routing, `help --json`, `status --json`, null-safe/honest benchmark history.
- `lib/repl.sh`: registry-driven hints/help/routing; quoted argv parser without `eval`; correct score/bench forwarding.
- `lib/workspace.sh`: non-destructive recovery from stale absent/mismatched workspace metadata.
- `lib/onboarding.sh`: current `score <client> --iter <n>` syntax.
- `README.md`: all command documentation and authoritative frontend JSON/file seams.
- `tests/cli-interface-parity.sh`: frozen v3 parity/PT​​Y/argv/output benchmark.
- `MEMORY.md`: durable lessons.

## Verification

- `bash -n bin/productteam lib/*.sh tests/*.sh` — pass (`evidence/syntax-final.txt`).
- `tests/cli-interface-parity.sh` — all probes pass (`evidence/parity-final.txt`).
- `tests/consult-smoke.sh` — all checks pass (`evidence/smoke-final.txt`).
- `tests/visual-cli.sh ...` — 14/14, zero skipped, live provider proof pass (`evidence/visual-final.json`).
- Real terminal transcript: authenticated `agent` runtime returned `LIVE-CYCLE-OK`; provider selected; completion card recorded (`evidence/live-chat-cycle.typescript`).
- `bin/productteam harness-checks ...` — 57/57 (`evidence/harness-checks-final/checks.json`).
- Ink prototype — 35/35 before deletion (`evidence/ink-tests.txt`).
- OpenTUI prototype — 31/31 before deletion (`evidence/opentui-tests.txt`).
- Paths with spaces, quoted slash argv, metacharacter inertness, required `--iter`, NO_COLOR, redirected output, non-TTY refusal, exit codes, Ctrl+C process-tree cleanup, partial artifacts, and stale workspace recovery are covered by frozen parity/visual/smoke outputs.

## Framework decision

`architecture-decision.md`: not yet. Ink required Node >=22, 39 package paths, ~22.3 MiB installed, >1,400 source lines, and ~3.35 s measured live snapshot. OpenTUI required Bun or Node >=26.4 experimental FFI, native platform packages, ~79.6 MiB installed, >1,100 source lines, and ~2.92 s snapshot. Neither implemented provider streaming, proved screen-reader behavior, or deleted any Bash UI code. Both missed the 25–30% net-deletion gate.

## Evidence inventory

- Freeze: `CLI-BENCHMARK-CONTRACT.md`, `FREEZE-SHA.txt`, rejected v1/v2 copies under `evidence/`.
- Baseline: `baseline-scores.json`, `baseline-evidence.md`, parity baseline outputs.
- Debate: `principal-priorities.md`, `critic-prebuild-rebuttal.md`, `principal-decision.md`.
- Implementation: `diff-summary.md`, test outputs under `evidence/`.
- Re-benchmark: `final-scores.json`, `final-evidence.md`, iteration 3–6 Analyst/Critic artifacts.
- Frameworks: `framework-comparison.md`, `dependency-packaging-report.md`, snapshots/test outputs.
- Decision/review: `architecture-decision.md`, `critic-final-verdict.md`, `lessons-and-org-review.md`, `non-convergence-report.md`.

## Remaining risk and owner escalation

No unresolved security, authentication, destructive-action, or autonomy-policy issue. No framework adoption requested. One future owner decision: approve a benchmark v4 that distinguishes active machine pins from immutable provenance; v3 cannot be amended retroactively. Until then, the product behavior is green but the literal all-dimensions-9 overlay remains unmet.
