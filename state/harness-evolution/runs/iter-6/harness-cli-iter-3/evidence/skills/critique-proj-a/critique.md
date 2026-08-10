# Product critique — proj-a

Runtime: agent
Timestamp: 20260810T051640Z
Repo: /home/logani/.herdr/worktrees/Product Consulting Harness/fix-new-user-tui/state/engagements/harness-cli/tmp-projects/proj-a
Skill: critique

# Product critique — proj-a

Runtime: agent  
Timestamp: 20260810T051640Z  
Repo: `/home/logani/.herdr/worktrees/Product Consulting Harness/fix-new-user-tui/state/engagements/harness-cli/tmp-projects/proj-a`  
Skill: critique

## Product clarity

Claims a **slack-water window** over the **harbour bar** from **harmonic constants**. `src/tideWindow.js` delivers height ≥ threshold only; current velocity is never used, and the comment equates slack with the high-water interval. Fixed **squat allowance** (`SQUAT_ALLOWANCE_M = 0.6`) is uncited and speed-blind. The **duty pilot brief** never names that risk. README.md says “Safety-checked”; nothing is checked. **Chart datum LAT** is assumed with no station field to verify it.

## Target user

Duty harbour pilot deciding transit for a deep-draught vessel. Needs decision-first text on a bridge wing: permit/deny, then window, then caveats (draught margin, height≠slack, LAT assumption). Current ordering inverts that.

## Friction

1. Window before permission in `src/harbourPilotBrief.js`.
2. “Slack-water” label on a height-only model in `src/tideWindow.js`.
3. Silent fixed squat allowance — looks like a real draught margin, isn’t.
4. Wrong/unknown datum fails open.
5. README overclaim erodes trust before the numbers.

## Prioritized recommendations

1. **Delete “Safety-checked” from `README.md`.** Say height-threshold / assumed-LAT. Cheapest confidence fix.
2. **Delete the “slack-water” claim where velocity is unused** (`src/tideWindow.js`, `README.md`). Call it a height-clearance window, or state slack ≠ high water.
3. **Reorder `src/harbourPilotBrief.js` decision-first:** permit/deny → window → required rise. Stop ending on “Transit permitted…”.
4. **Surface or delete the squat fiction:** name the fixed squat allowance and that it ignores speed in the brief, or remove `SQUAT_ALLOWANCE_M` from the formula until it is speed-aware and cited. Prefer naming/deletion over new physics.
5. **Fail closed on unknown chart datum** in `src/tideWindow.js` (stations have no datum field). Do not invent LAT.

Out of scope: chart plotter, AIS, route optimiser.

## Evidence

- `src/tideWindow.js`: `SQUAT_ALLOWANCE_M = 0.6`; height loop only; “current velocity is never consulted”; bar depth at assumed LAT.
- `src/harbourPilotBrief.js`: order is window → required rise → “Transit permitted…”.
- `README.md`: “Safety-checked slack-water windows”; “Chart datum is assumed to be LAT.”
- `GUIDANCE.md`: axes for draught safety margin, slack-water definition, brief legibility, missing datum, non-goals.
