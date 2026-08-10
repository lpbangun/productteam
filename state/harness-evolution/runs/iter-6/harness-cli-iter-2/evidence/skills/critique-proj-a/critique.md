# Product critique — proj-a

Runtime: agent
Timestamp: 20260810T051156Z
Repo: /home/logani/.herdr/worktrees/Product Consulting Harness/fix-new-user-tui/state/engagements/harness-cli/tmp-projects/proj-a
Skill: critique

## Product clarity

Claims a **slack-water window** for safe **harbour bar** transit. What ships: height-only clearance with a fixed **squat allowance**, then a one-line **duty pilot brief**. README.md calls this “Safety-checked”; nothing is checked. `src/tideWindow.js` treats high water as slack water. Product name and copy overpromise; delete the safety claim before adding features.

## Target user

Duty harbour pilot deciding whether a deep-draught vessel may cross the bar. Needs a decision-first brief on a bridge wing: permitted / not, then window, then caveats (draught margin, datum, squat). Current brief does the reverse.

## Friction

- Decision buried: window and rise print before “Transit permitted” (`src/harbourPilotBrief.js`).
- Silent risk: `SQUAT_ALLOWANCE_M = 0.6` applies to every vessel; squat never appears in the brief.
- Misnamed window: height ≥ required rise, not current velocity — pilot may treat it as true slack water.
- Assumed **chart datum LAT** with no station check; wrong datum → wrong draught margin, no warning.
- No tests; false confidence compounds the above.

## Prioritized recommendations

1. **Delete “Safety-checked” from README.md.** One word change; stops the overclaim GUIDANCE flags. Prefer this over any new safety UI.
2. **Reorder `src/harbourPilotBrief.js` decision-first.** Lead with permitted/denied, then window times. Delete the window-first sentence order; do not add chart/AIS/route surfaces.
3. **Name the squat lie in the brief, or drop the constant’s implied precision.** Either surface that squat allowance is fixed (not speed-aware) in `src/harbourPilotBrief.js`, or stop implying a calibrated margin from the magic `SQUAT_ALLOWANCE_M` in `src/tideWindow.js`. Prefer naming/removing over a squat model.
4. **Stop calling it slack water unless velocity is used.** In `src/tideWindow.js` / brief copy, say “height-clearance window” (or admit high water ≠ slack). Deletion of the misleading term beats adding a current model in this scope.
5. **Fail closed on datum.** If station does not publish LAT, refuse the window rather than assume chart datum LAT. Smallest fix: explicit refusal string; no plotter.

## Evidence

- `src/tideWindow.js`: `SQUAT_ALLOWANCE_M = 0.6`; comment “Height only — current velocity is never consulted”; `transitWindow` opens on predicted height alone.
- `src/harbourPilotBrief.js`: window → required rise → “Transit permitted…” (permission last).
- `README.md`: “Safety-checked slack-water windows”; “Chart datum is assumed to be LAT.”
- `GUIDANCE.md`: deliberate weaknesses match the above; non-goals exclude chart plotter / AIS / route optimiser.
