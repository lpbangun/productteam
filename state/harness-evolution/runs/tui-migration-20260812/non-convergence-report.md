# Non-convergence report

## Required outcome

Both prototypes were deleted. Neither OpenTUI nor Textual is retained as an optional frontend or migration direction.

## Cause

The immutable frozen benchmark contains two contradictions:

1. The generated `bin/productteam` proxy is set executable (0555) and then reset to non-executable mode (0444) by the recursive hardening loop. Required CLI seams fail before comparable scenario evidence can be collected.
2. The trace audit rejects the substring `agent`, while the required seam set mandates `agents --json` and verifies it in the argv log.

Changing the benchmark after implementation started was prohibited. Candidate-local interpreter fallbacks or skipped seams would weaken the exact argv/boundary contract and were rejected.

## What was established before deletion

OpenTUI: typecheck and 61 native tests passed; package succeeded; redirect-safe contract/event/non-TTY checks passed; direct PTY success/failure returned 0/17 and restored terminal state; lifecycle unit proof passed.

Textual: compileall and 52 native tests including eight snapshots passed repeatedly; package succeeded; redirect-safe contract/event/non-TTY checks passed; direct PTY success/failure returned 0/17 and restored terminal state; lifecycle unit proof passed.

Real base frames at all four sizes exist for both. These partial checks do not prove the frozen four scenarios, dynamic registry parity, external focus/scroll behavior, complete boundary trace, 130 signal path, or comparative latency/RSS.

## Decision rule

Mandatory dimensions 1–12 and 18 each require at least 9. Independent scoring kept every candidate below that gate because common external evidence was missing. Neither passed; `delete-both` was the only valid outcome. This is benchmark non-convergence, not a framework loss.

## Exact deciding rerun

A future iteration requires owner authorization for a new freeze: correct proxy permissions and make trace policy token-aware so the required `agents --json` seam is allowed; then build fresh candidates and rerun the unchanged semantic scenarios, measurements, independent scoring, and tie rules. No current prototype remains to promote.
