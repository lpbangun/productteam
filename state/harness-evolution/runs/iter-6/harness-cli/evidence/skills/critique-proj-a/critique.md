# Product critique — proj-a

Runtime: agent
Timestamp: 20260810T050712Z
Repo: /home/logani/.herdr/worktrees/Product Consulting Harness/fix-new-user-tui/state/engagements/harness-cli/tmp-projects/proj-a
Skill: critique

# Product critique — proj-a

Runtime: agent  
Timestamp: 20260810T050712Z  
Repo: `/home/logani/.herdr/worktrees/Product Consulting Harness/fix-new-user-tui/state/engagements/harness-cli/tmp-projects/proj-a`  
Skill: critique

## Product clarity

Claims a **slack-water window** from station **harmonic constants** so a vessel can cross the **harbour bar**. What ships is height-above-threshold: `transitWindow` in `src/tideWindow.js` never uses current velocity and approximates slack as the interval around high water. README.md leads with “Safety-checked”; nothing is checked. Fixed **squat allowance** (`SQUAT_ALLOWANCE_M = 0.6`) never appears in the **duty pilot brief**, so **draught margin** looks authoritative when it is not.

## Target user

Duty harbour pilot deciding whether a deep-draught vessel may transit. Needs a decision-first brief on a bridge wing: permit/deny → window → caveats (squat ignores speed; height ≠ slack; **chart datum LAT** assumed). `src/harbourPilotBrief.js` prints the window first and permission last.

## Friction

1. Window before transit permission (`src/harbourPilotBrief.js`).
2. “Slack-water” naming for a height-only model (`src/tideWindow.js`).
3. Uncited squat constant; no speed caveat in pilot-facing text.
4. Silent LAT assumption — wrong datum → wrong clearance, no fail-closed path.
5. README overclaim forces distrust before the numbers.

## Prioritized recommendations

1. **Delete “Safety-checked” from `README.md`.** Replace with height-threshold / assumed-LAT wording.
2. **Delete the “slack-water” label where velocity is unused** (`src/tideWindow.js`, `README.md`). Call it a height-clearance window — or state that slack ≠ high water.
3. **Reorder `src/harbourPilotBrief.js` decision-first:** permit/deny → window → required rise. Stop ending on “Transit permitted…”.
4. **Surface or remove the silent squat fiction:** name the fixed squat allowance and that it ignores speed in the brief, or delete `SQUAT_ALLOWANCE_M` from the clearance formula until it is speed-aware and cited. Prefer naming/deletion over new physics.
5. **Fail closed on unknown chart datum** in `src/tideWindow.js` (stations have no datum field). Do not invent LAT.

Out of scope: chart plotter, AIS, route optimiser.

## Evidence

- `src/tideWindow.js`: `SQUAT_ALLOWANCE_M = 0.6`; height loop only; comment “current velocity is never consulted”; datum assumed LAT via `BAR_DEPTH_AT_DATUM_M`.
- `src/harbourPilotBrief.js`: order is window → required rise → “Transit permitted…”.
- `README.md`: “Safety-checked slack-water windows”; “Chart datum is assumed to be LAT.”
- `GUIDANCE.md`: axes for draught safety margin, slack-water definition, brief legibility, missing datum, non-goals.
