# Product critique — 48-hour-contributor-readiness-kit

**Skill:** /critique · **Repo:** /home/logani/projects/48-hour-contributor-readiness-kit · **When:** 20260806T064600Z

## Method
Structured audit from README, DESIGN, AGENTS, package.json, tests, and primary UI source. Findings cite paths.

## Product clarity
Strong. README states fictional simulation and the three-route task (`README.md`). DESIGN defines audiences and experience architecture (`DESIGN.md`). Live demo link present.

## Target user
- Contributor and quality lead (`DESIGN.md` Audiences).
- Deliberately not a real HR/employment system (`README.md` disclaimer; `AGENTS.md` non-negotiables).

## UX / navigation / onboarding
Single workspace with contributor stages + quality-lead view (`app/ReadinessKit.tsx`). Session-local progress; no auth required (`DESIGN.md`).

## Accessibility
Keyboard tabs, `aria-live`, focusable controls asserted in source tests (`tests/rendered-html.test.mjs`). Browser flow includes 320 px overflow check (`tests/browser-flow.mjs`).

## Friction / priorities / risks
Highest leverage gap: **safety-honesty drift** between agent non-negotiables and visible quality-lead guardrail copy.
- `AGENTS.md` forbids automatic punitive, disciplinary, hiring, firing, **pay**, **promotion**, or personnel decisions.
- Quality-lead UI omits pay/promotion (`app/ReadinessKit.tsx` Decision guardrail).
- Source test only matches a partial phrase (`tests/rendered-html.test.mjs`), so the gap can regress silently.

Secondary (deferred): README could add an explicit “Who this is / is not for” block mirroring OFC-style clarity — lower urgency than locking the visible guardrail.

## Prioritized recommendations
1. Align quality-lead Decision guardrail (and test assertion) with `AGENTS.md` pay/promotion language — expected lift: **safety-honesty**, **documentation** coherence. Evidence: `AGENTS.md`, `app/ReadinessKit.tsx`, `tests/rendered-html.test.mjs`.
2. (Defer) Expand README audience / non-audience section — lift: **product-clarity**. Evidence: `README.md`, `DESIGN.md`.
3. (Defer) Keep browser acceptance optional/documented; do not expand scope into new tooling. Evidence: `package.json`, `tests/browser-flow.mjs`.

## Evidence rule
Every recommendation cites a path from this repo.
