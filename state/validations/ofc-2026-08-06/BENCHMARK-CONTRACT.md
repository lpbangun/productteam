# BENCHMARK-CONTRACT — Onboarding Flight Control validation (FROZEN)

**Contract `ofc-val-2026-08-06` · frozen 2026-08-06 · validation-local.**

Independent of engagement `ofc-v1`. Scores this client only for the
validation run under `state/validations/ofc-2026-08-06/`. Do not amend
mid-run; proposals → `proposed-benchmark-changes.md`.

| Field | Value |
|-------|-------|
| Subject | `/home/logani/projects/onboarding-flight-control` |
| Public | https://github.com/lpbangun/onboarding-flight-control |
| Contract | `ofc-val-2026-08-06` |
| Frozen | 2026-08-06T06:46:08Z (tailored lock) |
| Target | every dimension ≥ **8.0** |
| Max change | **ONE** high-leverage product improvement within vision |

## Vision invariants (do not change)

- Fictional People Ops onboarding portfolio demo (React/Vite, localStorage).
- No authentication, real employee data, backend, or external integrations.
- Copilot remains deterministic demo logic — not a real AI model.
- Supportive coordinator framing — no surveillance scoring.

## What success means

After one scoped change, the demo is measurably safer for portfolio
reviewers: clone → test → build remains green, and the change closes a
concrete correctness/DX gap that could ship broken static Pages without
tests.

## Dimensions

Scores 0–10, one decimal. Score without path / command / test evidence is **void**.

| Dimension | 9–10 | 6–8 | ≤5 |
|-----------|------|-----|-----|
| **correctness** | `npm test` + `npm run build` green; CI runs both before merge/deploy paths | tests or build fragile; CI partial | tests/build fail or deploy without any gate |
| **usability** | Demo walkthrough in README still completable cold; UI entry intact | minor friction | broken first-run or missing walkthrough |
| **documentation** | README identity + clone/run + non-goals honest; CI/docs match reality | small drift | false claims or missing clone path |
| **developer-experience** | PR/push path runs `npm test` + build with Node 22; local scripts documented | scripts ok, CI gap | `"latest"` deps or no test script |
| **product-clarity** | Fictional/prototype framing visible in UI + README | mostly clear | implies real HRIS/AI/auth |
| **simplicity** | Smallest diff for the chosen lift; no new deps unless required | some churn | drive-by refactors / scope creep |

## Acceptance threshold

Every dimension ≥ 8.0 on the post-change scored snapshot, with Critic
self-review notes recorded in this validation directory.

## Failure conditions

- Secrets in artifacts or commits
- Fake/mocked PR URLs or validation
- Vision rewrite (backend, auth, real AI)
- Mid-run contract move
- Merge via `--admin` / force
- No self-review / learning artifact

## Validation methods (real systems only)

```bash
cd /home/logani/projects/onboarding-flight-control
npm ci
npm test
npm run build
```

Plus: GitHub PR via `consult gh pr-create`, gated merge via
`authorize-merge` + `consult gh merge`, post-merge `consult gh validate`.

## Convergence (this validation)

One accepted PR merged to `main` that lifts the chosen gap, gates pass,
post-merge validate artifact written, `learning.md` present.
