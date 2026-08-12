# Product critique — proj-b

Runtime: agent
Timestamp: 20260807T093304Z
Repo: /home/logani/.herdr/worktrees/Product Consulting Harness/fix-new-user-tui/state/engagements/harness-cli/tmp-projects/proj-b
Skill: critique

# Product critique — proj-b

**Skill:** /critique · **Repo:** `.../tmp-projects/proj-b` · **When:** 20260807T093304Z

## Product clarity

README promises “waterlogging-safe” overnight replenishment. `irrigation/valve_schedule.py` never consults `FIELD_CAPACITY_MM` and does not cap runtime, so rootzone saturation is unconstrained. That claim should be deleted until the cap exists. `irrigation/transpiration_model.py` exposes a linear vapour-pressure proxy as `mm_per_day` with no error band — the unit overstates precision.

## Target user

Nursery grower deciding how long each valve zone runs tonight. Job is: climate readings → tonight’s minutes per zone. Out of scope: fertigation, climate-computer replacement, yield prediction. Product surface is a printed schedule; last night’s plan is unrecoverable after the process exits.

## Friction

1. False safety: grower trusts README, code can waterlog.
2. Stuck humidity at 0% inflates transpiration deficit with no stuck-sensor guard.
3. Zones run in dict insertion order; last zone always finishes closest to sunrise — fairness unstated.
4. No tests; regressions on deficit math or caps are invisible.

## Prioritized recommendations

1. **Delete the waterlogging-safe claim** in `README.md` (or wire `FIELD_CAPACITY_MM` into `irrigation/valve_schedule.py` and cap overnight replenishment). Prefer the delete until the cap is real.
2. **Delete unused dead weight or use it once:** `FIELD_CAPACITY_MM` in `irrigation/transpiration_model.py` is defined and ignored — either remove it or make it the sole rootzone saturation cap in the scheduler.
3. **Reject absurd sensors before scheduling:** in `irrigation/transpiration_model.py` / `vapour_pressure_deficit_kpa`, add a stuck-sensor guard (e.g. RH near 0% / out of band) so a bad reading cannot dominate tonight’s runtimes.
4. **Stop over-precision:** rename or annotate `transpiration_deficit_mm_per_day` so the vapour-pressure proxy is not presented as calibrated mm/day without an error band.
5. **Do not add** fertigation, climate-computer I/O, or yield models — they fight the primary user job.

## Evidence

| Finding | Path |
|--------|------|
| `FIELD_CAPACITY_MM = 42.0` unused; comment admits never consulted | `irrigation/transpiration_model.py` |
| No field-capacity cap on runtime; dict-order schedule | `irrigation/valve_schedule.py` |
| “Waterlogging-safe” claim | `README.md` |
| Evaluation criteria + non-goals | `GUIDANCE.md` |
| Stuck RH=0 inflates VPD (commented, unguarded) | `irrigation/transpiration_model.py` (`vapour_pressure_deficit_kpa`) |
