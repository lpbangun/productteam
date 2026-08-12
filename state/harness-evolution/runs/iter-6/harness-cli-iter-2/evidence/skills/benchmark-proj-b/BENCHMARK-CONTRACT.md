# BENCHMARK-CONTRACT — proj-b

Runtime: agent
Timestamp: 20260810T051032Z
Repo: /home/logani/.herdr/worktrees/Product Consulting Harness/fix-new-user-tui/state/engagements/harness-cli/tmp-projects/proj-b
Skill: benchmark

# BENCHMARK CONTRACT — nursery-irrigation-v1 (FROZEN)

**Subject:** `nursery-irrigation` — overnight valve scheduling for a commercial tomato nursery  
**Primary user:** grower deciding how long each valve zone runs tonight  
**Acceptance threshold:** ≥ **9.0** / 10 (mean across dimensions; no dimension may be waived)  
**Validation:** live stdlib Python only — **no mocks**, no stubbed sensors, no faked field-capacity tables, no simulated climate-computer feeds. Score against the real tree and `python3 -m irrigation.valve_schedule` as shipped.

## Scope (frozen)

In scope: transpiration-deficit estimation via the vapour-pressure proxy, overnight replenishment runtimes per valve zone, rootzone saturation vs field capacity, stuck-sensor plausibility, zone ordering fairness, and honesty of README claims vs code.

Out of scope (score 0 on any recommendation that expands into these): fertigation control, climate-computer replacement, yield prediction.

## Dimensions

### 1. `deficit-model-honesty`
Does `irrigation/transpiration_model.py` treat `transpiration_deficit_mm_per_day` as an exact millimetre quantity, or does it disclose that the linear vapour-pressure proxy is not Penman–Monteith and carries no error band? Evidence must cite the function that emits `mm_per_day` and any (missing) uncertainty statement.

### 2. `rootzone-saturation-cap`
Does overnight replenishment ever consult `FIELD_CAPACITY_MM` so total applied depth cannot waterlog the rootzone? Evidence must show whether the cap lives in the model constant’s consumer path or is absent from `irrigation/valve_schedule.py`’s `zone_runtime_minutes` / `overnight_schedule`.

### 3. `stuck-sensor-guard`
Can a humidity sensor stuck at 0 % inflate vapour-pressure deficit without a plausibility reject/clamp before runtime is emitted? Score the presence of a stuck-sensor guard on real `ZoneReading` inputs, not mocked sensor streams.

### 4. `zone-fairness-vs-sunrise`
Zones are scheduled in dictionary insertion order in `irrigation/valve_schedule.py` (`TONIGHT`). Does the last zone systematically finish closest to sunrise, and is that ordering risk acknowledged or mitigated for the grower?

### 5. `claim-code-fidelity`
README advertises “waterlogging-safe” overnight schedules. Does the executable path actually enforce waterlogging safety, or is the claim false against the live scheduler? Cite README vs `irrigation/valve_schedule.py`.

### 6. `schedule-recoverability`
Is tonight’s plan only printed, or persisted so last night’s valve runtimes are recoverable? Unrecoverable print-only plans cannot score above partial credit.

### 7. `scope-discipline`
Recommendations and diffs stay inside deficit → valve runtime for tomato nursery zones. Any drift into fertigation, climate-computer integration, or yield models fails this dimension.

## Scoring rules (frozen)

- Each dimension: 0–10 with **file-path evidence** (path + reasoning).  
- Aggregate target: **≥ 9.0**.  
- **No mocks:** validators run the real modules under `irrigation/`; inventing sensors, capacities, or schedules to “pass” a check voids the score for that dimension.  
- Deliberate weaknesses named in `GUIDANCE.md` are the test subject — silent “fixes” without evidence do not raise the frozen contract; they are scored only when verified against the cited paths.

## Mandatory evidence paths (minimum)

- `irrigation/transpiration_model.py` — proxy slope, `FIELD_CAPACITY_MM`, deficit as `mm_per_day`, humidity → VPD path  
- `irrigation/valve_schedule.py` — uncapped `zone_runtime_minutes`, ordered `TONIGHT`, print-only `main`  
- `README.md` / `GUIDANCE.md` — claim surface and non-goals

## Machine-readable dimensions

```json
{"contract":"nursery-irrigation-v1","dimensions":["deficit-model-honesty","rootzone-saturation-cap","stuck-sensor-guard","zone-fairness-vs-sunrise","claim-code-fidelity","schedule-recoverability","scope-discipline"],"target":9.0,"runtime":"agent","frozen":"20260810T051032Z","subject":"/home/logani/.herdr/worktrees/Product Consulting Harness/fix-new-user-tui/state/engagements/harness-cli/tmp-projects/proj-b","skill":"benchmark","source":"BENCHMARK-CONTRACT.md"}
```
