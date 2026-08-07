# nursery-irrigation

Waterlogging-safe overnight irrigation schedules for a tomato nursery.

Reads today's zone climate readings, estimates the transpiration deficit, and
prints how long each valve zone should run tonight.

```sh
python3 -m irrigation.valve_schedule
```

## Layout

| Path | Purpose |
|------|---------|
| `irrigation/transpiration_model.py` | Deficit estimate from temp + humidity |
| `irrigation/valve_schedule.py` | Turn deficits into per-zone runtimes |
| `GUIDANCE.md` | What a reviewer should look at |

Stdlib only. No climate-computer integration.
