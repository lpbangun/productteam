# Product critique — proj-b

Runtime: agent
Timestamp: 20260810T055234Z
Repo: /home/logani/.herdr/worktrees/Product Consulting Harness/fix-new-user-tui/state/engagements/harness-cli/tmp-projects/proj-b
Skill: critique

## Product clarity

README promises “waterlogging-safe” overnight schedules. `irrigation/valve_schedule.py` converts **transpiration deficit** straight into runtime with no cap against **field capacity**, so **rootzone saturation** is unconstrained. `FIELD_CAPACITY_MM` in `irrigation/transpiration_model.py` is dead weight. The **vapour-pressure proxy** is exported as `mm_per_day` with no error band — the grower gets a false-precision number.

## Target user

Nursery grower choosing how long each **valve zone** runs for **overnight replenishment**. Scope stops at tonight’s runtimes. Fertigation, climate-computer, and yield models are out of scope.

## Friction

- Claim vs code: “waterlogging-safe” is marketing; the scheduler never consults capacity.
- Stuck humidity at 0 % inflates deficit with no **stuck-sensor guard**.
- Zones follow dict order; last zone always finishes nearest sunrise — fairness never stated.
- Schedule is print-only; last night’s plan is gone after the terminal scrolls.

## Prioritized recommendations

1. **Delete the “waterlogging-safe” claim** from `README.md` until a real cap exists — or wire `FIELD_CAPACITY_MM` into `zone_runtime_minutes` in `irrigation/valve_schedule.py` and drop the unused constant elsewhere. Prefer deleting the claim over adding a climate stack.
2. **Delete or gate unbounded deficit** in `irrigation/transpiration_model.py`: reject RH outside a plausibility band (stuck-sensor guard) before `vapour_pressure_deficit_kpa` scales runtime. Do not add sensors or Penman–Monteith.
3. **Delete silent dictionary ordering** as the fairness policy in `irrigation/valve_schedule.py` — either document “insertion order, last zone nearest sunrise” or sort by a stated rule. No new scheduler surface.
4. **Delete print-as-persistence** as a product promise: either stop implying recoverable plans, or write one overnight file. Prefer the former until a grower needs history.

## Evidence

- `irrigation/transpiration_model.py`: `FIELD_CAPACITY_MM = 42.0` unused; `transpiration_deficit_mm_per_day` = slope × VPD; comment admits 0 % RH passes through.
- `irrigation/valve_schedule.py`: `zone_runtime_minutes` = deficit × canopy / flow; no capacity clamp; `main` only `print`s.
- `README.md`: lead line “Waterlogging-safe…” contradicts the scheduler.
- `GUIDANCE.md`: flags deficit honesty, rootzone saturation, zone fairness, sensor trust; non-goals exclude fertigation / climate-computer / yield.
