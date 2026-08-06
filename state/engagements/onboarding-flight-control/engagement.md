# Engagement: onboarding-flight-control

Opened: 2026-08-06 · Contract: ofc-v1 (frozen) · Client owner: lpbangun
Mode: **Guided** (Product Judgment Layer)

Repo: /home/logani/projects/onboarding-flight-control
Public: https://github.com/lpbangun/onboarding-flight-control
Live working copy (do not score): /home/logani/projects/Onboarding Flight Control
Branch: consult/engagement-2026-08-06
Scorer: checks
Vision: Fictional People Ops onboarding coordinator portfolio demo — local-only React/Vite prototype; no backend, auth, or real AI

## Mission

Improve **Onboarding Flight Control**—a fictional People Ops onboarding
portfolio demo (React/Vite, localStorage, no backend)—so it measurably
exceeds baseline on onboarding fidelity, cross-role workflow clarity,
first-run usability, maintainability, documentation, developer
experience, product identity, and structural simplicity. The engagement
preserves the product vision: a local-only prototype that makes cohort
onboarding, handoffs, and lightweight coordinator support legible across
People Ops, manager, and new-hire views without introducing real
integrations, authentication, employee data, or AI model calls. Success
means every dimension of contract `ofc-v1` reaches **9.0** within five
iterations, evidenced by passing automated checks and verified
documentation that lets an evaluator clone, run, and complete the Maya
Chen manager-introduction walkthrough without out-of-band guidance.

## Invariants (do not touch)

- Vision: supportive onboarding coordinator demo. No surveillance scoring.
- No backend, auth, real AI calls, calendars, or messaging integrations.
- Deterministic client-side data; persist with localStorage.
- Six fictional hires; role views: People Ops, Manager, New Hire.

## Product Judgment — Guided proposals (pre-implementation)

| Direction | Tradeoff | Expected lift |
|-----------|----------|---------------|
| A. Operator docs + pin deps + test harness | Low risk; no UX change | documentation, DX, product-clarity |
| B. Fix status/signal consistency + reason-required overrides | Touches board UX; restores audit trust | workflow-clarity, onboarding-quality |
| C. Multi-hire persona picker across Manager/New Hire/Copilot | Broader demo; more UI surface | product-clarity, usability, onboarding-quality |
| D. Split App.tsx into modules | Churny; enables maintainability 9 | maintainability, simplicity |

**Selected for iter-1+:** A → B → C → D as capacity allows. Challenge if any direction expands into real integrations (Override would be required).

## Intake findings (2026-08-06)

1. No README.md — identity and clone-to-value invisible.
2. No test suite / `npm test` script.
3. Manager + New Hire + Copilot hard-locked to Maya/Elena.
4. Board status pills override without reason dialog; `deriveSupport` can disagree with stored status after scheduling.
5. App.tsx ~1417 lines; deps pinned to `"latest"`.
6. Build passes (`npm run build` verified on fresh clone @ fc1ef89).
