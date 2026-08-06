# FREEZE.md — Product Consulting Harness (APC)

**Status:** FROZEN for client repository validation  
**Frozen at:** 2026-08-06T06:45:00Z  
**Harness commit SHA:** `2cb1a9f478d613559dd38a7f4164f8e6e2c986bf` (main after PR #1)  
**Plus local iter-5 close artifacts** (to be committed as freeze tip)

## Benchmark

| Field | Value |
|-------|-------|
| Contract | `harness-apc-v1` |
| Target | every dimension ≥ 8.0 |
| Converging iter | iter-5 |
| Overall | 8.4 |
| Critic | CONVERGED (scores re-audit PASS) |

## Score progression

| Iter | Overall | Notes |
|------|---------|-------|
| 0 | 4.4 | baseline |
| 1 | 5.8 | runtime + checks + learning + judgment |
| 2 | 6.9 | gated GitHub + PR #1 |
| 3 | 7.8 | product skills |
| 4 | 8.2 | authorized merge + validate |
| 5 | 8.4 | memory + autonomy residuals — **CONVERGED** |

## Available agents / runtimes (preflight)

| Runtime | Status |
|---------|--------|
| Cursor `agent` | found (default) |
| Claude Code `claude` | found |
| Codex `codex` | found |
| OpenCode `opencode` | found |
| Gemini CLI | missing |
| Cursor IDE binary | found |

## GitHub permissions (verified)

- Account: `lpbangun`
- Scopes: `gist`, `read:org`, `repo`, `workflow`
- Repos admin/push/pull: product-consulting-harness, onboarding-flight-control, 48-hour-contributor-readiness-kit, skills-vector

## Freeze rule

Do **not** modify harness implementation during Phase 6 validation unless a
critical blocker makes execution impossible. Record any emergency fix in
`state/harness-evolution/freeze-exceptions.md`.
