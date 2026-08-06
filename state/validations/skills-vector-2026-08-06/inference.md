# Inference — Skills Vector (minimal context)

## Product
Private-first occupational intelligence MVP for U.S. People Operations & Talent.
Produces one updatable, evidence-led **role brief** for three fixed roles:
HR Coordinator, Recruiter, Learning & Development Specialist.

## Users
- People Ops / Talent practitioners reviewing private draft briefs (human gate before any non-private state).
- Engineers extending the LangGraph workflow via injected handlers without configuring model providers.

## Constraints (from README + docs/goal-loop.md + code)
- Offline unittest; no network/model calls in contract tests.
- No providers, credentials, schedulers, persistence, deployment, or public UI in this phase.
- U.S. geography only; approved evidence categories only; no individual career predictions.
- Briefs default private; publication requires explicit human approval.
- Agents must not autonomously change prompt/policy/memory/model routing.

## Highest-leverage gap chosen
`validate_brief` accepted drafts with only one scenario horizon and duplicate claim ids—
undermining the product promise of time-bound, inspectable role uncertainty.
Fix stays inside domain validation (no scope expansion).
