# Product critique — proj-b

**Skill:** /critique · **Repo:** /home/logani/.herdr/worktrees/Product Consulting Harness/fix-new-user-tui/state/engagements/harness-cli/tmp-projects/proj-b · **When:** 20260807T084826Z

## Method
Structured audit from README + shallow tree. Findings cite paths.

## Product clarity
README present — skim first 80 lines for identity/audience.

## Target user
Infer from README "Who" / audience sections; flag if absent.

## UX / navigation / onboarding
Inspect entry docs and primary UI/docs paths in the tree below.

## Accessibility
Note whether a11y tests or guidance exist in tree.

## Product direction / friction / priorities / risks
Prioritize by impact-per-change. Prefer deletion. Do not rewrite vision.

## Tree (depth 2, truncated)
```
/home/logani/.herdr/worktrees/Product Consulting Harness/fix-new-user-tui/state/engagements/harness-cli/tmp-projects/proj-b/irrigation/valve_schedule.py
/home/logani/.herdr/worktrees/Product Consulting Harness/fix-new-user-tui/state/engagements/harness-cli/tmp-projects/proj-b/irrigation/__init__.py
/home/logani/.herdr/worktrees/Product Consulting Harness/fix-new-user-tui/state/engagements/harness-cli/tmp-projects/proj-b/irrigation/transpiration_model.py
/home/logani/.herdr/worktrees/Product Consulting Harness/fix-new-user-tui/state/engagements/harness-cli/tmp-projects/proj-b/README.md
/home/logani/.herdr/worktrees/Product Consulting Harness/fix-new-user-tui/state/engagements/harness-cli/tmp-projects/proj-b/pyproject.toml
/home/logani/.herdr/worktrees/Product Consulting Harness/fix-new-user-tui/state/engagements/harness-cli/tmp-projects/proj-b/GUIDANCE.md
```

## README excerpt
```
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
```

## Prioritized recommendations
1. (Fill from evidence above — highest leverage first)
2. …
3. …

## Evidence rule
Every recommendation must cite a path from this repo.
