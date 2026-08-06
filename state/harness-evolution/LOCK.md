# LOCK.md — harness-apc-v1 freeze

**Frozen at:** `2026-08-06T06:00:04Z`  
**Contract id:** `harness-apc-v1`  
**Date:** 2026-08-06

## Freeze rule

Implementers **MUST NOT** modify these locked files during an active
harness-evolution run:

- `state/harness-evolution/HARNESS-BENCHMARK-CONTRACT.md`
- `state/harness-evolution/contract.json`
- `state/harness-evolution/LOCK.md`

## Proposed changes

Rubric or threshold proposals go **only** to:

`state/harness-evolution/proposed-benchmark-changes.md`

They do **not** apply mid-run. Owner approval + new version id required
before any successor contract is frozen for a later run.

## Baseline

Score iter-0 against this lock **before** APC-lifting implementation.
Do not re-score iter-0 retroactively.
