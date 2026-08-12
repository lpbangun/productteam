# Product critique — proj-a

Runtime: agent
Timestamp: 20260807T093217Z
Repo: /home/logani/.herdr/worktrees/Product Consulting Harness/fix-new-user-tui/state/engagements/harness-cli/tmp-projects/proj-a
Skill: critique

## Product clarity

Claims a **slack-water window** for safe harbour-bar transit from harmonic constants. Delivery is height-above-threshold only: `transitWindow` in `src/tideWindow.js` never uses current velocity, and the comment admits slack is approximated as the interval around high water. README.md leads with “Safety-checked”; nothing is checked. Fixed **squat allowance** (`SQUAT_ALLOWANCE_M = 0.6`) is unlabeled in the **duty pilot brief**, so draught margin looks authoritative when it is not.

## Target user

Duty harbour pilot deciding whether a deep-draught vessel may cross the bar. Needs a decision-first brief readable on a bridge wing: permitted/not, then window, then caveats (squat vs speed, height≠slack, **chart datum LAT** assumption). Current brief inverts that.

## Friction

1. Window times before transit permission (`src/harbourPilotBrief.js`).
2. “Slack-water” naming when the model is height-only (`src/tideWindow.js`).
3. Uncited constant squat allowance with no speed caveat in pilot-facing text.
4. Silent LAT assumption — wrong datum → wrong clearance, no fail-closed path.
5. README overclaim forces the pilot to distrust the tool before reading the numbers.

## Prioritized recommendations

1. **Delete “Safety-checked” from README.md.** Replace with height-threshold / assumed-LAT wording. Stops the worst false confidence cheaply.
2. **Delete the “slack-water” label where velocity is unused** (`src/tideWindow.js`, README.md). Call it a height-clearance window until current is modeled — or say explicitly that slack ≠ high water.
3. **Reorder `src/harbourPilotBrief.js` decision-first:** permit/deny → window → required rise. Drop the trailing “Transit permitted…” as the punchline.
4. **Surface or remove the silent squat fiction:** either name the fixed squat allowance and that it ignores speed in the brief, or delete `SQUAT_ALLOWANCE_M` from the clearance formula until it is speed-aware and cited. Prefer naming/deletion over new physics.
5. **Fail closed on unknown chart datum** in `src/tideWindow.js` (stations lack a datum field today). Do not invent LAT.

Out of scope: chart plotter, AIS, route optimiser.

## Evidence

- `src/tideWindow.js`: `SQUAT_ALLOWANCE_M = 0.6`; height loop only; comment “current velocity is never consulted”; datum assumed LAT via `BAR_DEPTH_AT_DATUM_M`.
- `src/harbourPilotBrief.js`: lines order window → required rise → “Transit permitted…”.
- `README.md`: “Safety-checked slack-water windows”; “Chart datum is assumed to be LAT.”
- `GUIDANCE.md`: evaluation axes for draught safety margin, slack-water definition, brief legibility, missing datum, non-goals.
