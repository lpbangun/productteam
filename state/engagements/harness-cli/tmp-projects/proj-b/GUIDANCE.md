# GUIDANCE.md — proj-b

Language: Python (3.11, stdlib only)
Domain: greenhouse irrigation scheduling for a commercial tomato nursery
Primary user: a nursery grower deciding how long each valve zone runs tonight

This is a deliberately small dummy project. It exists so the harness CLI's
skills can be verified against a real, specific repository rather than a
template. Nothing here is production code. It shares no source filename with
`proj-a` and no part of its domain.

## What this project claims to do

Estimate each zone's **transpiration deficit** from a crude
temperature/humidity model, then emit a valve schedule that closes the deficit
overnight without waterlogging the rootzone.

## What a skill should evaluate here

1. **Deficit model honesty.** `irrigation/transpiration_model.py` uses a linear
   vapour-pressure proxy instead of Penman–Monteith. That is fine for a dummy,
   but the code presents the number as `mm_per_day` with no stated error band.
2. **Rootzone saturation.** `irrigation/valve_schedule.py` never caps total
   runtime against field capacity, so a large deficit can produce a schedule
   that waterlogs the zone. Where should the cap live?
3. **Zone fairness.** Zones are watered in dictionary order. The last zone in
   the ordering always finishes closest to sunrise. Does that matter?
4. **Sensor trust.** A stuck humidity sensor reading 0 % inflates the deficit
   without any plausibility guard.
5. **Non-goals.** This project is deliberately *not* a fertigation controller,
   not a climate-computer replacement, and not a yield-prediction model. A
   recommendation that adds any of those is out of scope.

## Terms specific to this project

`transpiration deficit` · `valve zone` · `rootzone saturation` ·
`field capacity` · `vapour-pressure proxy` · `overnight replenishment` ·
`stuck-sensor guard`

## Deliberate weaknesses (do not "fix" silently — they are the test subject)

- No tests at all.
- `FIELD_CAPACITY_MM` is defined but never used.
- Schedules are printed, never persisted, so last night's plan is unrecoverable.
- README claims "waterlogging-safe" scheduling that the code does not perform.
