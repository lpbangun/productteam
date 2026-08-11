# Workspace checks must restore dirt after measurement

## What worked

Isolated worktrees for `productteam checks` with archived `runs/check-*/workspace.json` evidence. Restore check-induced dirt (e.g. tsconfig.tsbuildinfo) so subsequent role invokes are not blocked by measurement side-effects.

## What failed

Running checks in the engagement repo without workspace isolation left dirty trees that blocked Builder invoke.

## Context

- kind: worked
- domain: implement
- client: harness-cli
- iter: —
- sealed: 2026-08-11T00:00:00Z

## Cite

- MEMORY.md Lessons 2026-08-11 · three-mission loop · workspace restore after checks
