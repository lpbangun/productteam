# Design sprint — proj-a

Runtime: agent
Timestamp: 20260810T055127Z
Repo: /home/logani/.herdr/worktrees/Product Consulting Harness/fix-new-user-tui/state/engagements/harness-cli/tmp-projects/proj-a
Skill: design-sprint

## Problem

The **duty pilot brief** from `src/harbourPilotBrief.js` leads with the **slack-water window** and only then says transit is permitted. A duty harbour pilot on a bridge wing needs the go/no-go first. The **draught margin** also applies a fixed **squat allowance** in `src/tideWindow.js` (`SQUAT_ALLOWANCE_M`) with no speed dependence and no mention in the brief, so the pilot never sees that risk.

## Users

Primary: a **duty harbour pilot** deciding when a deep-draught vessel may cross the **harbour bar**.

## Direction

Ship a **decision-first duty pilot brief**: permit/deny first, then window and required rise, plus one explicit line that the **draught margin** uses a fixed **squat allowance** (not speed-aware). No new forecasting model, no chart/AIS/routing.

## Scope in / out

**In**
- Reorder copy in `src/harbourPilotBrief.js` so the transit decision leads.
- Name the fixed **squat allowance** from `src/tideWindow.js` in that brief (smallest honest caveat).
- Optionally tone down README “safety-checked” so claims match what is actually checked.

**Out**
- Chart plotter, AIS consumer, route optimiser (GUIDANCE non-goals).
- Current-velocity **slack-water** model, speed-dependent squat formula, or **chart datum LAT** validation beyond naming the assumption.
- Vision rewrite of the product.

## Milestones

1. Reorder brief: decision → window → required rise above **chart datum**.
2. Append one squat-allowance caveat tied to the constant in `src/tideWindow.js`.
3. Align README wording with “height-based window + fixed allowance,” not “safety-checked.”

## Risks

- A one-line squat caveat can be misread as a full squat model; keep it clearly “fixed allowance, not speed-adjusted.”
- Still height-only: **slack water** ≠ high water; do not imply current was used.

## Validation

- Run `node src/harbourPilotBrief.js DOVER 9.4` and confirm the first sentence is permit/deny.
- Confirm the brief mentions fixed **squat allowance** / **draught margin**.
- Spot-check a no-window draught still fails closed with a clear deny line.

## Expected impact

Smallest diff that makes the brief usable on a bridge wing and surfaces the named squat risk GUIDANCE asks about—without expanding scope past harmonic height → **slack-water window** → **duty pilot brief**.
