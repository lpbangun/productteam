# Product critique — proj-b

Runtime: agent
Timestamp: 20260810T081356Z
Repo: /home/logani/.herdr/worktrees/Product Consulting Harness/fix-new-user-tui/state/engagements/harness-cli/tmp-projects/proj-b
Skill: critique

## Product clarity

The product is overnight **overnight replenishment** for tomato nursery **valve zone**s: estimate **transpiration deficit**, print runtimes. That job is clear from `GUIDANCE.md` and `irrigation/valve_schedule.py`. Clarity breaks in `README.md`: it promises “Waterlogging-safe” scheduling while `FIELD_CAPACITY_MM` in `irrigation/transpiration_model.py` is never applied and `irrigation/valve_schedule.py` never caps against **field capacity**. The grower is sold **rootzone saturation** protection that does not exist.

## Target user

Nursery grower choosing how long each valve zone runs tonight. One command (`python3 -m irrigation.valve_schedule`), printed minutes, stdlib only. Correct scope. Non-goals (fertigation, climate computer, yield models) are correctly out of frame—do not expand into them.

## Friction

1. False safety claim in `README.md` vs uncapped runtimes in `irrigation/valve_schedule.py`—trust tax on every schedule.
2. Linear **vapour-pressure proxy** in `irrigation/transpiration_model.py` emits `mm_per_day` with no error band; a stuck 0% RH sensor inflates deficit with no **stuck-sensor guard**.
3. Zones water in dict order; the last zone always finishes closest to sunrise—no explicit fairness policy.
4. Schedule is print-only; last night’s plan is gone after the terminal clears.

## Prioritized recommendations

1. **Delete the “Waterlogging-safe” claim** from `README.md` until a field-capacity cap is real. Prefer honest copy over unused constants. Highest impact-per-change: one line removed restores claim/code alignment.
2. **Use or delete `FIELD_CAPACITY_MM`** in `irrigation/transpiration_model.py`. Dead constant that implies a cap. Either wire a hard runtime ceiling in `irrigation/valve_schedule.py` (`zone_runtime_minutes`) so overnight replenishment cannot exceed field capacity, or remove the constant so the model stops advertising unused safety.
3. **Reject implausible humidity before deficit** in `irrigation/transpiration_model.py` (`vapour_pressure_deficit_kpa`). A stuck-sensor guard (e.g. refuse/clamp RH ≈ 0%) stops silent over-watering without new product surface.
4. **State zone order policy** in `irrigation/valve_schedule.py` (`TONIGHT` / `overnight_schedule`) or rotate so the same bay is not always last-to-sunrise—only if sunrise proximity matters for the crop; otherwise document “dict order is fine” and stop pretending fairness is designed.
5. **Do not add** fertigation, climate-computer hooks, or yield prediction. Out of scope per `GUIDANCE.md`.

## Evidence

| Finding | Path |
|--------|------|
| “Waterlogging-safe” marketing | `README.md` L3 |
| Unused `FIELD_CAPACITY_MM = 42.0` | `irrigation/transpiration_model.py` L10–12 |
| Proxy → `mm_per_day`, no band; stuck RH note | `irrigation/transpiration_model.py` L33–40 |
| Uncapped runtime from deficit × canopy / flow | `irrigation/valve_schedule.py` L23–30 |
| Dict-order watering, last zone near sunrise | `irrigation/valve_schedule.py` L14–20, L29–30 |
| Print-only, no persistence | `irrigation/valve_schedule.py` L33–35 |
| Deliberate weaknesses called out | `GUIDANCE.md` L40–45 |
