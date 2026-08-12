# OSINT stop/resume: one engine, exit 2 at max

## What failed

Split stop/resume logic across scripts caused ambiguous termination; callers could not distinguish "at max iterations" from other failures.

## What worked

Single engine with exit code 2 when max not raised; continue when `--max-iterations` raised. `output/termination.json` aligned to `termination_engine`.

## Context

- kind: failed
- domain: client
- client: osint-loop-research
- iter: 1
- sealed: 2026-08-11T00:00:00Z

## Cite

- state/missions/osint-lift/report.md · Mission 2 closed iter-1
