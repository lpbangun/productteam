# /benchmark — Lock a measurable product benchmark

## Purpose

Define what “better” means **before** implementation and freeze it for the run.

## Defines

- what success means
- scoring criteria (0–10 bands)
- required evidence
- acceptance thresholds
- failure conditions
- validation methods
- convergence conditions

## Invoke

```sh
bin/consult skill benchmark <repo-or-client> [out-dir]
```

Writes `BENCHMARK-CONTRACT.md` + `contract.json` under `out-dir`.
Marks them frozen for the engagement; implementers must not edit mid-run.

## Rules

- Independent of the implementer when used in an engagement
- Proposed mid-run changes go to `proposed-benchmark-changes.md` only
- Cite concrete checks where possible
