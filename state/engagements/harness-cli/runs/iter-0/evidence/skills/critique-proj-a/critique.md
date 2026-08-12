# Product critique — proj-a

**Skill:** /critique · **Repo:** /home/logani/.herdr/worktrees/Product Consulting Harness/fix-new-user-tui/state/engagements/harness-cli/tmp-projects/proj-a · **When:** 20260807T084826Z

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
/home/logani/.herdr/worktrees/Product Consulting Harness/fix-new-user-tui/state/engagements/harness-cli/tmp-projects/proj-a/src/harbourPilotBrief.js
/home/logani/.herdr/worktrees/Product Consulting Harness/fix-new-user-tui/state/engagements/harness-cli/tmp-projects/proj-a/src/tideWindow.js
/home/logani/.herdr/worktrees/Product Consulting Harness/fix-new-user-tui/state/engagements/harness-cli/tmp-projects/proj-a/README.md
/home/logani/.herdr/worktrees/Product Consulting Harness/fix-new-user-tui/state/engagements/harness-cli/tmp-projects/proj-a/GUIDANCE.md
/home/logani/.herdr/worktrees/Product Consulting Harness/fix-new-user-tui/state/engagements/harness-cli/tmp-projects/proj-a/package.json
```

## README excerpt
```
# tide-window

Safety-checked slack-water windows for harbour pilots.

Give it a station's harmonic constants and a vessel draught; it returns the
window in which the vessel may cross the harbour bar, plus a short brief.

```sh
node src/tideWindow.js --station DOVER --draught 9.4
```

## Layout

| Path | Purpose |
|------|---------|
| `src/tideWindow.js` | Predict height, derive the transit window |
| `src/harbourPilotBrief.js` | Render the duty pilot brief |
| `GUIDANCE.md` | What a reviewer should look at |

Chart datum is assumed to be LAT.
```

## Prioritized recommendations
1. (Fill from evidence above — highest leverage first)
2. …
3. …

## Evidence rule
Every recommendation must cite a path from this repo.
