# Design sprint — proj-a

Runtime: agent
Timestamp: 20260807T093145Z
Repo: /home/logani/.herdr/worktrees/Product Consulting Harness/fix-new-user-tui/state/engagements/harness-cli/tmp-projects/proj-a
Skill: design-sprint

# Design sprint — proj-a

## Problem
A duty harbour pilot deciding when a deep-draught vessel may transit the harbour bar gets a brief that leads with the slack-water window and only then says whether transit is permitted (`src/harbourPilotBrief.js`). The underlying window also applies a fixed squat allowance to every vessel (`src/tideWindow.js`) without naming that risk where the pilot will see it. On a bridge wing in daylight, that ordering and silence make the “safety-checked” claim hard to act on.

## Users
**Primary:** duty harbour pilot — go/no-go for a given draught across the bar.  
**Not for:** chart plotters, AIS consumers, or route optimisers (GUIDANCE non-goals).

## Direction
Make the duty pilot brief decision-first and honest about the fixed squat allowance — permit/deny first, then window and required rise, with the constant squat allowance named in the brief — without changing how the window is computed beyond what the brief must disclose.

## Scope

**In**
- Reorder `src/harbourPilotBrief.js` so permitted/not permitted leads.
- Surface `SQUAT_ALLOWANCE_M` (or its value) in the brief so draught margin risk is visible.
- One-line README honesty: drop or qualify “safety-checked” to match what is actually checked.
- Minimal tests for brief order and squat disclosure.

**Out**
- Speed-dependent squat model rewrite.
- Current-velocity / true slack-water physics.
- Chart-datum LAT validation pipeline.
- Chart plotter, AIS, or route optimiser features.

## Milestones
1. Lock acceptance: brief leads with transit permitted/denied; squat allowance appears in the paragraph.
2. Edit `src/harbourPilotBrief.js` (+ light README wording); leave harmonic prediction logic untouched unless needed for the disclosed constant.
3. Add a tiny Node test that asserts decision-first order and squat mention.
4. Manual check: `node src/harbourPilotBrief.js DOVER 9.4` reads as a one-paragraph pilot brief.

## Risks
- Scope creep into “fix squat” or “real slack water” (GUIDANCE deliberate weaknesses — name them, don’t silently rewrite).
- Over-claiming safety after a copy/order change only.
- Brief becoming longer than one paragraph (legibility regress).

## Validation
- `node src/harbourPilotBrief.js DOVER 9.4` — first clause is permit/deny; squat allowance appears before or with the window detail.
- Diff limited to brief render (+ README wording / one test file); `src/tideWindow.js` prediction loop unchanged unless exposing the constant for the string.
- Confirm no new dependencies or chart/AIS/routing surfaces.

## Expected impact
Duty pilots get a decision-first duty pilot brief with an explicit draught-margin caveat, so brief legibility and named squat risk improve without a vision rewrite. Slack-water-vs-height and LAT-datum gaps stay known non-goals for later, smallest-diff iterations.
