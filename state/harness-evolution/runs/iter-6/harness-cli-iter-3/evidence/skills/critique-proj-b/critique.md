# Product critique — proj-b

Runtime: agent
Timestamp: 20260810T051701Z
Repo: /home/logani/.herdr/worktrees/Product Consulting Harness/fix-new-user-tui/state/engagements/harness-cli/tmp-projects/proj-b
Skill: critique

## Product clarity

README promises “waterlogging-safe” overnight schedules. `irrigation/valve_schedule.py` converts **transpiration deficit** to runtime with no cap against **field capacity**, so **rootzone saturation** is unbounded. `FIELD_CAPACITY_MM` in `irrigation/transpiration_model.py` is dead weight. The product story and the product disagree: either drop the safety claim or wire the cap—do not keep both.

## Target user

Primary user is a nursery grower choosing tonight’s **valve zone** runtimes. They need: honest deficit numbers, a schedule that will not waterlog, and a recoverable plan. They do not need fertigation, a climate computer, or yield prediction—those are out of scope.

## Friction

1. **False safety.** Grower trusts “waterlogging-safe”; large deficit → long runtimes, no **field capacity** check.
2. **False precision.** Linear **vapour-pressure proxy** is labeled `mm_per_day` with no error band—looks decision-grade, is not.
3. **Stuck humidity.** 0 % RH inflates deficit with no **stuck-sensor guard**.
4. **Zone order.** Dictionary order leaves the last zone finishing nearest sunrise; grower cannot see or change that bias.
5. **Ephemeral output.** Print-only schedule; last night’s plan is gone after the terminal clears.

## Prioritized recommendations

1. **Delete the waterlogging claim** in `README.md` until `FIELD_CAPACITY_MM` actually bounds `zone_runtime_minutes` in `irrigation/valve_schedule.py`. Prefer stripping the adjective over adding a subsystem.
2. **Cap overnight replenishment at field capacity** in `irrigation/valve_schedule.py` (cap belongs on runtime/litres, not deeper in the proxy). If you will not use `FIELD_CAPACITY_MM`, delete it from `irrigation/transpiration_model.py`—unused constants imply a safety feature that does not exist.
3. **Label the proxy** in `irrigation/transpiration_model.py`: rename or document that output is a **vapour-pressure proxy**, not Penman–Monteith `mm_per_day`, so growers do not over-trust it.
4. **Reject impossible RH** before deficit math in `irrigation/transpiration_model.py` (minimal **stuck-sensor guard**)—fail closed, do not invent climate logic.
5. Do **not** add fertigation, climate-computer integration, or yield models.

## Evidence

- `README.md`: “Waterlogging-safe overnight irrigation schedules”
- `irrigation/transpiration_model.py`: `FIELD_CAPACITY_MM = 42.0` unused; `transpiration_deficit_mm_per_day` = slope × VPD; stuck 0 % RH passes through
- `irrigation/valve_schedule.py`: `zone_runtime_minutes` uncapped; `TONIGHT` dict order; `print` only, no persistence
- `GUIDANCE.md`: deliberate weaknesses match the above
