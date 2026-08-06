# BENCHMARK-CONTRACT.md — Skills Vector (FROZEN)

**Contract `skills-vector-v1` · frozen 2026-08-06T06:47:00Z · validation-local.**

This contract scores `/home/logani/projects/skills-vector` only. Scores are
0–10 per dimension, one decimal. A score without a cited path, command
output, or test name is **void**.

## Subject metadata

| Field | Value |
|-------|-------|
| Subject path | `/home/logani/projects/skills-vector` |
| Contract | `skills-vector-v1` |
| Frozen | 2026-08-06T06:47:00Z |
| Target (per dimension) | **8.0** |
| Convergence | Every dimension ≥ 8.0 on one scored iteration |
| Mode | Constrained minimal-context validation (PR-only; do not merge) |

## Product inference (locked for this run)

- **Product:** Private-first occupational intelligence MVP that produces one
  evidence-led, human-gated U.S. role brief for three fixed People Ops &
  Talent roles (HR Coordinator, Recruiter, L&D Specialist).
- **Users:** People Ops / Talent practitioners reviewing private draft briefs;
  engineers extending the LangGraph boundary without provider setup.
- **Constraints:** Offline unittest; no model providers, credentials,
  schedulers, persistence, deployment, or public UI; no individual career
  predictions; briefs private unless human-approved; agents must not change
  prompt/policy/memory/model routing autonomously.

## Invariants (do not change)

- Approved roles remain exactly the three pilot roles.
- Geography remains U.S.-only; domain remains People Operations & Talent.
- Evidence categories stay limited to the approved labor/research/policy set.
- LangGraph handlers remain injected; no default provider wiring.
- No paid API calls, mocks of product behavior, or vision rewrite.

## Scoring protocol

1. Score each dimension with file-level or command evidence.
2. Overall = mean of six dimensions, rounded to one decimal.
3. Convergence = every dimension ≥ 8.0 on the same iteration.
4. Fake/mocked validation, secrets in artifacts, or mid-run contract edits → void.

## Required verification commands

```bash
cd /home/logani/projects/skills-vector
uv venv .venv
uv pip install --python .venv/bin/python -e .
.venv/bin/python -m unittest discover -s tests -v
.venv/bin/python -m compileall -q src tests
```

## Dimensions

| Dimension | 9–10 | 6–8 | ≤5 |
|-----------|------|-----|-----|
| **correctness** | Offline suite green; brief validation rejects incomplete/unsafe drafts | Suite green with known gaps | Failing tests or publishable brief without approval |
| **usability** | Clear failure messages for scope/evidence/review violations | Errors exist but uneven | Silent acceptance of invalid briefs |
| **documentation** | README + goal-loop match behavior and verification | README runnable; minor drift | Missing/contradictory docs |
| **developer-experience** | README commands succeed; contracts testable without providers | Install + tests work | Broken install or network-required tests |
| **product-clarity** | Scope, three roles, private/human-gate, non-goals explicit in code+docs | Mostly clear; one gap | Ambiguous audience or overclaims |
| **simplicity** | Small domain+workflow surface; no dead policy constants | Lean tree; minor unused surface | Providers/UI/scheduler creep |

### Frozen check IDs (evidence anchors)

**correctness:** `unittest-green`, `compileall-clean`, `brief-requires-claim-kinds`, `high-impact-corroboration`, `non-private-needs-approval`, `brief-requires-both-horizons`, `claim-ids-unique`

**usability:** `scope-errors-named`, `missing-evidence-named`, `human-approval-error-named`

**documentation:** `readme-exists`, `readme-verify-commands`, `goal-loop-guardrails`, `readme-non-goals`

**developer-experience:** `uv-editable-install`, `unittest-offline`, `no-provider-config-required`, `handlers-injected`

**product-clarity:** `three-roles-only`, `us-geography-only`, `private-default`, `human-review-interrupt`, `human-gated-changes-named`

**simplicity:** `src-two-modules`, `deps-langgraph-only`, `no-scheduler-persistence-ui`, `workflow-edges-declarative`

## Failure conditions

- Secrets or credentials in validation artifacts or PR
- Mocked/fake tests substituting for real unittest
- Mid-run edit of this contract or `contract.json`
- Merge of the validation PR (PR-only run)
- Scope expansion into providers, UI, scheduler, or job board

## Convergence

All six dimensions ≥ 8.0 on one scored iteration with Critic-acceptable
evidence, PR opened and **not** merged.
