# Product critique — proj-b

Runtime: agent
Timestamp: 20260810T050731Z
Repo: /home/logani/.herdr/worktrees/Product Consulting Harness/fix-new-user-tui/state/engagements/harness-cli/tmp-projects/proj-b
Skill: critique

## Product clarity

The README promises “waterlogging-safe” overnight replenishment. The code does not. `irrigation/transpiration_model.py` defines `FIELD_CAPACITY_MM` and never consults it; `irrigation/valve_schedule.py` converts transpiration deficit straight into minutes with no rootzone saturation cap. A grower reading the README trusts a safety property the schedule never enforces. The vapour-pressure proxy also labels output as `mm_per_day` with no error band, so a crude linear proxy reads like measured crop water use.

## Target user

A nursery grower deciding how long each valve zone runs tonight. They need a short, trustworthy plan they can act on before lights-out—not fertigation, climate-computer replacement, or yield prediction. Tonight’s job is: honest deficit → capped runtime → recoverable plan.

## Friction

1. False safety: “waterlogging-safe” in `README.md` contradicts unused `FIELD_CAPACITY_MM`.
2. Stuck humidity at 0% inflates VPD with no stuck-sensor guard (`vapour_pressure_deficit_kpa`).
3. Zones run in dict order; last zone always finishes nearest sunrise—silent fairness cost.
4. Schedule is printed only; last night’s plan is gone after the terminal scrolls.

## Prioritized recommendations

1. **Delete the waterlogging claim** in `README.md` until a field-capacity cap exists—or delete `FIELD_CAPACITY_MM` from `irrigation/transpiration_model.py` if the product will not use it. Dead capacity constants plus safety copy is worse than an honest “uncapped” label.
2. **Cap in `zone_runtime_minutes`** (`irrigation/valve_schedule.py`): minutes may not exceed what `FIELD_CAPACITY_MM` × canopy area can accept. That is where rootzone saturation belongs; do not add a second subsystem.
3. **Reject impossible RH** in `vapour_pressure_deficit_kpa` (`irrigation/transpiration_model.py`)—a stuck-sensor guard that fails closed (skip/warn), not a new sensor stack.
4. **Drop or document zone order** in `overnight_schedule` (`irrigation/valve_schedule.py`): if dict order is arbitrary, say so; do not invent rotation machinery until fairness is shown to matter for this nursery.

## Evidence

- `README.md` L3: “Waterlogging-safe…” vs `FIELD_CAPACITY_MM = 42.0` unused in `irrigation/transpiration_model.py` L12 and uncapped `zone_runtime_minutes` in `irrigation/valve_schedule.py` L23–26.
- `irrigation/transpiration_model.py` L33–36: RH 0% passes through; L39–40: proxy returned as `mm_per_day` with no band.
- `irrigation/valve_schedule.py` L14–20, L29–30: insertion-order watering; L33–35: print-only, no persistence.
