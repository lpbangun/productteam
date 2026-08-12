# Design sprint — proj-a

Runtime: agent
Timestamp: 20260810T051613Z
Repo: /home/logani/.herdr/worktrees/Product Consulting Harness/fix-new-user-tui/state/engagements/harness-cli/tmp-projects/proj-a
Skill: design-sprint

# Design sprint — proj-a

Runtime: agent  
Timestamp: 20260810T051613Z  
Repo: `/home/logani/.herdr/worktrees/Product Consulting Harness/fix-new-user-tui/state/engagements/harness-cli/tmp-projects/proj-a`  
Skill: design-sprint

## Problem

The duty pilot brief in `src/harbourPilotBrief.js` is not decision-first: it prints the slack-water window before whether transit is permitted. The fixed squat allowance in `src/tideWindow.js` (`SQUAT_ALLOWANCE_M`) is never named where a duty harbour pilot will see it, and the brief does not admit that the window is height-only — not current velocity. A pilot deciding when a deep-draught vessel may cross the harbour bar therefore gets timing before go/no-go, with silent draught-margin and slack-water risk.

## Users

Primary: the duty harbour pilot on a bridge wing in daylight, choosing whether a given draught may transit the harbour bar inside the predicted window.

## Direction

Reorder and caveat the one-paragraph duty pilot brief so it leads with the transit decision, then the window, then explicit limits: fixed squat allowance and height-derived (not current-velocity) slack water. Smallest diff — no new forecasting physics, no vision rewrite.

## Scope in/out

**In**
- Decision-first copy in `src/harbourPilotBrief.js` (permit/deny first; window second).
- Surface `SQUAT_ALLOWANCE_M` from `src/tideWindow.js` in the brief so the draught safety margin is named where the pilot will see it.
- One short admission that the slack-water window is from predicted height only, not current velocity.
- Tone down README “safety-checked” overclaim to match what is actually computed.

**Out**
- Chart plotter, AIS consumer, route optimiser (GUIDANCE non-goals).
- Speed-dependent squat model, current-velocity slack detection, or chart-datum LAT validation beyond a brief caveat.
- New product surfaces or architecture.

## Milestones

1. Flip brief sentence order in `src/harbourPilotBrief.js`; keep one paragraph.
2. Include fixed squat allowance (m) and height-only slack-water caveat in that paragraph.
3. Align `README.md` claim language with “predicted window + brief,” not “safety-checked.”

## Risks

- Caveats may lengthen the brief for bridge-wing scan; keep to one short clause each.
- Naming squat without a citation can still mislead; do not invent authority — state it as a fixed allowance.
- Pilots may still treat height-open intervals as true slack water; the admit-language must be unambiguous.

## Validation

- Manual: `node src/harbourPilotBrief.js DOVER 9.4` — first clause is permit/deny; window follows; squat and height-only language present.
- Diff-level: only brief (+ optional README) change; `transitWindow` math in `src/tideWindow.js` unchanged.
- Reject any change that adds plotting, AIS, or routing.

## Expected impact

Faster, safer go/no-go reading for the duty pilot, with draught margin and slack-water limits visible in the brief — addressing GUIDANCE items on brief legibility, squat risk naming, and slack-water honesty without expanding product scope.
