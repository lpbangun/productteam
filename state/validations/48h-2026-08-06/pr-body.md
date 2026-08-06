## Summary
- Align quality-lead Decision guardrail copy with `AGENTS.md` non-negotiables by naming **pay** and **promotion** alongside hiring/firing.
- Strengthen `tests/rendered-html.test.mjs` (and browser-flow check) so the fuller safeguard cannot regress silently.
- Mirror the same honesty in README safeguards list.

## Why
Frozen validation (`state/validations/48h-2026-08-06`) flagged safety-honesty drift: agent rules forbade pay/promotion decisions, but the visible UI omitted them.

## Test plan
- [x] `npm test` (build + rendered-html tests) — 4/4 pass
- [ ] CI checks on this PR
- [ ] Merge only if gates pass (no `--admin` / force)

Validation evidence: Product Consulting Harness `state/validations/48h-2026-08-06/`
