# BENCHMARK-CONTRACT — proj-b

Runtime: agent
Timestamp: 20260807T093047Z
Repo: /home/logani/.herdr/worktrees/Product Consulting Harness/fix-new-user-tui/state/engagements/harness-cli/tmp-projects/proj-b
Skill: benchmark

# BENCHMARK-CONTRACT — nursery-irrigation (proj-b)

**Contract `nursery-irrigation-v1` · FROZEN 20260807T093047Z · engagement-local.**

Subject: greenhouse irrigation scheduling for a commercial tomato nursery
(stdlib Python 3.11). Primary user: a nursery grower deciding how long each
valve zone runs tonight.

Implementers must not amend mid-run. Proposals → `proposed-benchmark-changes.md`
only. Scores are 0–10 per dimension, one decimal. A score without a cited path,
command output, or check result is **void**.

## What success means

The grower gets an overnight replenishment plan that closes each zone’s
transpiration deficit without waterlogging the rootzone, with honest uncertainty
on the vapour-pressure proxy, a stuck-sensor guard on humidity, and claims that
match the code. Non-goals stay out: not a fertigation controller, not a
climate-computer replacement, not a yield model.

## Dimensions (domain-specific)

### 1. deficit-model-honesty
`irrigation/transpiration_model.py` may keep the linear vapour-pressure proxy
(not Penman–Monteith), but any value presented as `mm_per_day` must carry a
stated error band or explicit “proxy, not ET₀” caveat the grower can see.
- 9–10: proxy labeled; uncertainty or band visible at the call site / CLI output
- 6–8: honesty in comments only, not on the emitted schedule
- ≤5: raw `mm_per_day` with no caveat (current baseline)

### 2. rootzone-saturation-safety
Overnight runtimes must be capped against field capacity so a large deficit
cannot waterlog the zone. `FIELD_CAPACITY_MM` in
`irrigation/transpiration_model.py` must be consulted by the scheduler in
`irrigation/valve_schedule.py` (or an equally clear single cap site).
- 9–10: every zone runtime ≤ capacity-derived max; cap location documented
- 6–8: cap exists but incomplete or hard to find
- ≤5: `FIELD_CAPACITY_MM` defined and unused; no saturation guard

### 3. stuck-sensor-guard
A humidity reading of 0 % (or other implausible RH) must not silently inflate
VPD / deficit. Plausibility check before
`vapour_pressure_deficit_kpa` / schedule emission.
- 9–10: guard rejects or flags stuck sensors; schedule does not waterlog from garbage RH
- 6–8: warning only, still schedules full inflated deficit
- ≤5: 0 % RH passes straight through (current baseline)

### 4. zone-fairness
Valve zones must not always finish in dictionary insertion order such that the
last zone alone finishes closest to sunrise without an explicit policy.
- 9–10: ordering policy stated and justified (or rotated / parallelized)
- 6–8: order documented as intentional with grower-visible rationale
- ≤5: silent dict-order bias in `irrigation/valve_schedule.py`

### 5. claim-code-alignment
README’s “waterlogging-safe” claim must match scheduler behavior. False
marketing is a critical failure of this dimension.
- 9–10: README and code agree on saturation safety
- 6–8: wording softened but residual overclaim
- ≤5: README claims waterlogging-safe; code does not cap (current baseline)

### 6. schedule-recoverability
Tonight’s plan must be recoverable after the process exits (persist, don’t only
print).
- 9–10: durable artifact for last night’s per-zone runtimes
- 6–8: optional persist path, default still print-only
- ≤5: print-only; last night’s plan unrecoverable

### 7. scope-discipline
No fertigation control, climate-computer integration, or yield prediction.
Recommendations that add those fail this dimension regardless of quality.
- 9–10: changes stay inside deficit → valve runtime overnight scheduling
- 6–8: mild scope creep without new product surface
- ≤5: fertigation / climate-computer / yield features introduced

### 8. overnight-replenishment-verification
Automated tests exercise deficit math, capacity cap, stuck-sensor guard, and
CLI schedule emission on real module imports (stdlib tests only).
- 9–10: tests cover GUIDANCE risks with path-cited assertions
- 6–8: partial coverage of model or scheduler only
- ≤5: no tests (current baseline)

## Scoring bands (all dimensions)

| Band | Meaning |
|------|---------|
| ≤5 | Broken / missing relative to the grower’s overnight decision |
| 6–8 | Usable with known gaps; evidence required |
| 9–10 | Excellent with file-level evidence |

## Acceptance threshold

**Every dimension ≥ 9.0** on the same scored iteration. Overall mean is
informational; convergence is per-dimension.

## Failure conditions (void the iteration)

- Secrets in artifacts
- Fake, stubbed, or mocked validation (fixtures posing as live runs)
- Vision rewrite into fertigation / climate-computer / yield prediction
- Silent “fixes” of deliberate weaknesses without scoring evidence
- No Critic verdict on diff, scores, and org

## Validation methods

- Run against the real tree: `python3 -m irrigation.valve_schedule`
- Inspect `irrigation/transpiration_model.py`, `irrigation/valve_schedule.py`,
  `README.md`, `GUIDANCE.md`
- Execute real stdlib tests / checks when present
- **No mocks.** Evidence must cite real paths and real command output from this
  repository.

## Convergence

All eight dimensions ≥ 9.0 on one scored iteration **and** Critic accept.

## Invariants

1. Stdlib-only Python; no climate-computer integration.
2. Product remains overnight valve-zone scheduling from transpiration deficit.
3. Contract frozen for the run; mid-run edits only via
   `proposed-benchmark-changes.md`.

## Machine-readable dimensions

```json
{"contract":"nursery-irrigation-v1","dimensions":["deficit-model-honesty","rootzone-saturation-safety","stuck-sensor-guard","zone-fairness","claim-code-alignment","schedule-recoverability","scope-discipline","overnight-replenishment-verification"],"target":9.0,"runtime":"agent","frozen":"20260807T093047Z","subject":"/home/logani/.herdr/worktrees/Product Consulting Harness/fix-new-user-tui/state/engagements/harness-cli/tmp-projects/proj-b","skill":"benchmark","source":"BENCHMARK-CONTRACT.md"}
```
