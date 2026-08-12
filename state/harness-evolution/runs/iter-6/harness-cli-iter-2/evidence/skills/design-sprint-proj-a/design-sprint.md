# Design sprint — proj-a

Runtime: agent
Timestamp: 20260810T051117Z
Repo: /home/logani/.herdr/worktrees/Product Consulting Harness/fix-new-user-tui/state/engagements/harness-cli/tmp-projects/proj-a
Skill: design-sprint

## Problem

The duty pilot brief in `src/harbourPilotBrief.js` puts the slack-water window before the transit decision, and never names the fixed squat allowance or that the window in `src/tideWindow.js` is height-only (not current velocity). A duty harbour pilot on a bridge wing gets window times first and an implied “safety-checked” story the README overclaims.

## Users

Primary: a duty harbour pilot deciding when a deep-draught vessel may cross the harbour bar.

## Direction

Make the duty pilot brief **decision-first and risk-honest**: lead with permit/deny for the given draught, then the slack-water window, then one short clause naming the fixed squat allowance and that the window is derived from predicted height only (not slack by current). Smallest diff; no new product surface.

## Scope in / out

**In**
- Reorder `src/harbourPilotBrief.js` so transit permitted / not permitted comes first.
- Surface `SQUAT_ALLOWANCE_M` (from `src/tideWindow.js`) in the brief text the pilot will see.
- Admit height-only slack-water approximation in the brief (one clause).
- Tone down README “safety-checked” so it matches what is actually checked.

**Out**
- Speed-dependent squat model, current-velocity slack, chart/AIS/route features (non-goals).
- Chart-datum LAT validation beyond a brief/README honesty note.
- Vision rewrite, new modules, or a test suite (unless needed to lock brief order).

## Milestones

1. Export or pass squat allowance + a “height-only window” flag from `transitWindow` into the brief renderer.
2. Rewrite the one-paragraph brief: decision → window → named limits (squat allowance, height-only).
3. Align README claim language with GUIDANCE (no silent “fix” of the deliberate weaknesses beyond honesty).

## Risks

- Pilots may treat named caveats as full mitigation; keep wording as limits, not clearance.
- Over-explaining squat/slack could hurt bridge-wing legibility — one clause each, not a tutorial.
- Do not silently replace the constant squat model; name the risk, don’t pretend it’s fixed.

## Validation

- Run `node src/harbourPilotBrief.js DOVER 9.4` (and a no-window draught): first sentence is permit/deny; brief mentions squat allowance and height-only window.
- Confirm `src/tideWindow.js` window math unchanged except any export needed for the brief.
- Spot-check README no longer claims “safety-checked” without qualification.

## Expected impact

Faster, safer read for the duty pilot: decision first, draught margin risk visible, slack-water definition honesty without expanding scope beyond the existing harbour-bar brief.
