# Product critique — proj-b

Runtime: agent
Timestamp: 20260810T051216Z
Repo: /home/logani/.herdr/worktrees/Product Consulting Harness/fix-new-user-tui/state/engagements/harness-cli/tmp-projects/proj-b
Skill: critique

## Product clarity

README promises “waterlogging-safe” overnight schedules. The code does not. `FIELD_CAPACITY_MM` sits unused in `irrigation/transpiration_model.py`; `irrigation/valve_schedule.py` converts transpiration deficit straight into runtime with no rootzone saturation cap. The grower is sold overnight replenishment safety the product does not deliver. Delete the claim until the cap exists—or wire the unused constant and drop the marketing.

## Target user

A nursery grower choosing how long each valve zone runs tonight. They need a short, trustworthy table: zone → minutes → “will this flood?”. They do not need fertigation control, a climate computer, or yield prediction. Scope is already right; honesty of the number is not.

## Friction

1. False safety: “waterlogging-safe” vs uncapped schedule.
2. Blind trust in sensors: RH 0 % inflates the vapour-pressure proxy with no stuck-sensor guard.
3. Opaque precision: deficit labeled `mm_per_day` with no error band.
4. Zone order bias: dict insertion order leaves the last bay finishing nearest sunrise.
5. Ephemeral plan: print-only; last night’s schedule is gone after the terminal scrolls.

## Prioritized recommendations

1. **Delete the waterlogging-safe claim** in `README.md` until runtime is capped by field capacity. Prefer stripping the promise over adding features.
2. **Use or delete `FIELD_CAPACITY_MM`** in `irrigation/transpiration_model.py`. Cap in `irrigation/valve_schedule.py` at `min(deficit, FIELD_CAPACITY_MM)` (or equivalent litres). Dead constant + unsafe schedule is worse than an honest uncapped tool.
3. **Reject or flag impossible humidity** in `irrigation/transpiration_model.py` (`vapour_pressure_deficit_kpa`) before overnight replenishment math runs—stuck-sensor guard, not a new sensing stack.
4. **Stop implying instrument-grade mm/day** in `transpiration_deficit_mm_per_day`: rename or annotate as vapour-pressure proxy estimate; do not add Penman–Monteith.
5. **Decide zone order explicitly** in `irrigation/valve_schedule.py` (or document that dictionary order is arbitrary). Do not add a fairness optimizer unless sunrise finish time actually matters for this nursery.

## Evidence

- `README.md`: “Waterlogging-safe overnight irrigation schedules…”
- `irrigation/transpiration_model.py`: `FIELD_CAPACITY_MM = 42.0` defined, unused; linear vapour-pressure proxy; comment that RH 0 % inflates VPD.
- `irrigation/valve_schedule.py`: `zone_runtime_minutes` / `overnight_schedule` uncapped; zones iterated in dict order; stdout only.
- `GUIDANCE.md`: deliberate gaps—no tests, unused field capacity, print-only plans, README/code mismatch on rootzone saturation.
