# BENCHMARK-CONTRACT.md — Onboarding Flight Control (FROZEN)

**Contract `ofc-v1` · frozen 2026-08-06 · engagement-local.**

This contract scores `clients/onboarding-flight-control` only. It does
not replace or amend harness `BENCHMARKS.md` v1. Scores are 0–10 per
dimension, one decimal. A score without a cited path, command output, or
test name is **void**.

## Engagement metadata

| Field | Value |
|-------|-------|
| Client path | `clients/onboarding-flight-control` |
| Contract | `ofc-v1` |
| Frozen | 2026-08-06 |
| Target (per dimension) | **9.0** |
| Convergence | Every dimension ≥ 9.0 |
| Max iterations | **5** (iter-0 baseline + up to 4 change iterations; stop at 5 complete improvement iterations max per owner brief) |

## Invariants (do not change)

- Fictional People Ops onboarding portfolio demo (React/Vite, localStorage).
- No authentication, real employee data, or external integrations.
- Copilot remains deterministic demo logic, not a real AI model.
- Do not expand into production HRIS, messaging, or calendar systems.

## Scoring protocol

1. Analyst scores each dimension independently of the Principal.
2. Every score cites evidence: file path, command output, or test name.
3. Independent Verifier re-audits all scores before the run is accepted.
4. Subjective scores require two independent written justifications;
   resolve disagreements conservatively (lower score wins).
5. Overall = mean of eight dimensions, rounded to one decimal.
6. Convergence = every dimension ≥ 9.0 on the same scored iteration.

## Baseline guard

- iter-0 is scored **before any engagement product change**.
- Harness/test-scaffold added only to *measure* is allowed before
  baseline; product behavior must be unchanged for iter-0.
- iter-0 scores are never re-scored retroactively.

## Required verification commands

```bash
cd clients/onboarding-flight-control
npm ci
npm run build
npm test
```

## Dimensions (summary)

Objective check catalogs live in `checks/` scripts and the test suite.
Band rules:

| Dimension | 9–10 | 6–8 | ≤5 |
|-----------|------|-----|-----|
| **onboarding-quality** | All 5 checks pass | ≥3 + maya-intro-flow | maya-intro-flow fails or <3 |
| **workflow-clarity** | All 5 pass | ≥3 incl. consistency or override-reason | both consistency+override fail |
| **usability** | All 5 pass | ≥3 incl. build + reset | build fails |
| **maintainability** | All 5 pass | ≥3 incl. tsc + domain-pure | App.tsx >900 lines |
| **documentation** | All 5 pass | README + ≥3 | no README or clone-run fails |
| **developer-experience** | All 5 pass | ≥3 incl. ci-local-parity | `"latest"` still present |
| **product-clarity** | All 5 pass | ≥3 incl. home-states-fictional | implies real integrations |
| **simplicity** | All 5 pass | ≥3 incl. single-derive-support | status logic duplicated |

### Check IDs (frozen)

**onboarding-quality:** `test-suite-green`, `maya-intro-flow`, `initial-handoffs-complete`, `domain-transitions-generic`, `derive-support-seed`

**workflow-clarity:** `status-signal-consistency`, `override-requires-reason`, `board-pills-require-reason`, `coordinator-signal-matches-domain`, `cross-role-demo-script`

**usability:** `build-green`, `home-to-workspace`, `role-switcher-three-roles`, `reset-demo-restores-seed`, `a11y-smoke`

**maintainability:** `typescript-build`, `app-not-monolith`, `domain-pure`, `demo-constants-centralized`, `architecture-notes`

**documentation:** `readme-exists`, `readme-required-sections`, `readme-clone-run-verified`, `walkthrough-covers-maya`, `docs-honest-prototype`

**developer-experience:** `deps-pinned`, `test-script-exists`, `ci-local-parity`, `dev-script-documented`, `node-version-noted`

**product-clarity:** `home-states-fictional`, `topbar-prototype-chip`, `copilot-not-ai`, `three-role-labels`, `readme-non-goals-explicit`

**simplicity:** `single-derive-support`, `no-duplicate-status-meta`, `lean-src-tree`, `deps-minimal`, `no-dead-seed-fields`

## Convergence

The engagement converges when all eight dimensions ≥ 9.0 on the same
scored iteration, verified by the Independent Verifier, with no void
scores and no unresolved critical/high defects.
