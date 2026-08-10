# BENCHMARK-CONTRACT — proj-b

Runtime: agent
Timestamp: 20260810T055043Z
Repo: /home/logani/.herdr/worktrees/Product Consulting Harness/fix-new-user-tui/state/engagements/harness-cli/tmp-projects/proj-b
Skill: benchmark

# BENCHMARK-CONTRACT — nursery-irrigation-v1 (FROZEN)

**Runtime:** agent  
**Frozen at:** 20260810T055043Z  
**Subject:** `/home/logani/.herdr/worktrees/Product Consulting Harness/Fix-new-user-tui/state/engagements/harness-cli/tmp-projects/proj-b`  
**Product:** overnight valve-zone irrigation for a commercial tomato nursery (stdlib Python ≥3.11)  
**Primary user:** nursery grower deciding how long each valve zone runs tonight  

**Acceptance threshold:** every dimension **≥ 9.0** / 10 on the same scored iteration (mean is informational).  
**Validation:** live tree only — **no mocks**, no stubbed humidity sensors, no faked `FIELD_CAPACITY_MM` tables, no simulated climate-computer feeds. Evidence must cite real paths and real output from `python3 -m irrigation.valve_schedule`.

Implementers must not edit this contract mid-run. Proposed changes → `proposed-benchmark-changes.md` only. A score without path-cited evidence is void.

## What success means

The grower gets an overnight replenishment schedule that closes each zone’s **transpiration deficit** without **rootzone saturation** past **field capacity**, with honest labelling of the **vapour-pressure proxy**, a **stuck-sensor guard** on humidity, an explicit zone-ordering policy (not silent dict bias toward sunrise), README claims that match the scheduler, and a recoverable last-night plan. Non-goals stay out: not fertigation, not a climate-computer, not yield prediction.

## Dimensions

### 1. `deficit-model-honesty`
`irrigation/transpiration_model.py` may keep the linear vapour-pressure proxy (not Penman–Monteith), but any value surfaced as `mm_per_day` / `transpiration_deficit_mm_per_day` must disclose uncertainty (error band or explicit “proxy, not ET₀” caveat visible to the grower at schedule emission). Comment-only honesty does not clear ≥9.0.

### 2. `rootzone-saturation-cap`
Overnight runtimes must consult `FIELD_CAPACITY_MM` so a large deficit cannot waterlog the zone. Cap must live on a real consumer path from `irrigation/valve_schedule.py` (`zone_runtime_minutes` / `overnight_schedule`) — defining the constant unused fails this dimension.

### 3. `stuck-sensor-guard`
A humidity sensor stuck at 0 % must not silently inflate VPD → deficit → runtime. Plausibility reject/flag before `vapour_pressure_deficit_kpa` drives schedule emission. Score against real `ZoneReading` inputs in the tree, not mocked sensor streams.

### 4. `zone-fairness-vs-sunrise`
`TONIGHT` in `irrigation/valve_schedule.py` waters zones in dictionary insertion order so the last zone finishes closest to sunrise. Ordering must be an explicit, grower-visible policy (or rotated/parallelized)—silent dict-order bias fails.

### 5. `claim-code-fidelity`
README advertises “waterlogging-safe” scheduling. That claim must match executable behavior in `irrigation/valve_schedule.py`. False marketing is a critical failure of this dimension.

### 6. `schedule-recoverability`
Tonight’s per-zone runtimes must be recoverable after process exit (persist an artifact). Print-only `main` leaves last night’s plan unrecoverable and cannot clear ≥9.0.

### 7. `overnight-replenishment-verification`
Automated stdlib tests exercise deficit math, capacity cap, stuck-sensor guard, and CLI schedule emission via real module imports. No tests (current baseline) scores ≤5.

### 8. `scope-discipline`
Changes stay inside deficit → valve-zone overnight scheduling for tomato nursery zones. Recommendations that add fertigation control, climate-computer integration, or yield prediction fail this dimension regardless of quality.

## Scoring bands

| Band | Meaning |
|------|---------|
| ≤5 | Broken / missing relative to the grower’s overnight decision (current deliberate weaknesses) |
| 6–8 | Partial: usable with known gaps; file evidence required |
| 9–10 | Excellent with path-cited proof on the live tree |

## Failure conditions (void the iteration)

- Mocked, stubbed, or faked validation posing as live runs  
- Secrets in artifacts  
- Vision rewrite into fertigation / climate-computer / yield prediction  
- Silent “fixes” of GUIDANCE deliberate weaknesses without scored evidence  
- Scores without cited paths

## Validation methods

- Run: `python3 -m irrigation.valve_schedule` on the real tree  
- Inspect: `irrigation/transpiration_model.py`, `irrigation/valve_schedule.py`, `README.md`, `GUIDANCE.md`  
- **No mocks.** Evidence = real paths + real command / test output from this repository

## Convergence

All eight dimensions ≥ 9.0 on one scored iteration, with Critic accept on diff, scores, and org.

## Mandatory evidence paths (minimum)

- `irrigation/transpiration_model.py` — proxy slope, `FIELD_CAPACITY_MM`, `mm_per_day` surface, humidity → VPD  
- `irrigation/valve_schedule.py` — uncapped runtime, ordered `TONIGHT`, print-only `main`  
- `README.md` / `GUIDANCE.md` — claim surface and non-goals

## Machine-readable dimensions

```json
{"contract":"nursery-irrigation-v1","dimensions":["deficit-model-honesty","rootzone-saturation-cap","stuck-sensor-guard","zone-fairness-vs-sunrise","claim-code-fidelity","schedule-recoverability","overnight-replenishment-verification","scope-discipline"],"target":9.0,"runtime":"agent","frozen":"20260810T055043Z","subject":"/home/logani/.herdr/worktrees/Product Consulting Harness/fix-new-user-tui/state/engagements/harness-cli/tmp-projects/proj-b","skill":"benchmark","source":"BENCHMARK-CONTRACT.md"}
```
