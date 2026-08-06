# /critique — Structured product audit

## Purpose

Audit a product repository with evidence-backed, prioritized recommendations.

## Covers

- product clarity
- target user
- UX
- navigation
- onboarding
- accessibility
- product direction
- friction
- priorities
- risks

## Invoke

```sh
bin/consult skill critique <repo-or-client> [out-dir]
```

Writes `critique.md` (and optional JSON summary) under `out-dir`
(default: `state/harness-evolution/runs/skills/critique-<ts>/`).

## Rules

- Cite paths for every finding
- Prioritize by impact-per-change; prefer deletion
- Do not change product vision
- No secrets in output
