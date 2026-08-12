# Product critique — proj-a

Runtime: agent
Timestamp: 20260810T055204Z
Repo: /home/logani/.herdr/worktrees/Product Consulting Harness/fix-new-user-tui/state/engagements/harness-cli/tmp-projects/proj-a
Skill: critique

## Product clarity

The product claims a **slack-water window** for crossing the harbour bar from harmonic constants plus draught. That promise is false in two places: `README.md` leads with “Safety-checked” while nothing is checked, and `src/tideWindow.js` equates slack water with a height-above-threshold band around high water—current velocity is never used. A duty pilot brief that says “transit permitted” without naming those limits is clarity debt, not a feature gap.

## Target user

Primary user: a duty harbour pilot deciding whether a deep-draught vessel may cross the bar. They need a yes/no first, then the window, then caveats (squat allowance, chart datum LAT). Bridge-wing daylight reading makes ordering and honesty the product; charts, AIS, and routing are out of scope.

## Friction

1. `src/harbourPilotBrief.js` prints the window before permission—decision-last under glare.
2. Fixed `SQUAT_ALLOWANCE_M` (0.6 m) in `src/tideWindow.js` is invisible in the brief and wrong for fast transits; draught margin risk is unnamed where the pilot looks.
3. Chart datum LAT is assumed with no station check; wrong datum silently shrinks or invents the window.
4. README overclaim (“safety-checked”) trains false trust before the first run.

## Prioritized recommendations

1. **Delete the safety claim** in `README.md` (“Safety-checked…”). Say height-derived window only—no safety certification language.
2. **Reorder the duty pilot brief** in `src/harbourPilotBrief.js`: permit/deny first, then window times, then required rise. Delete window-first ordering.
3. **Surface or drop the squat fiction** in `src/tideWindow.js`: either name the fixed squat allowance in the brief as a non-speed-aware constant, or remove `SQUAT_ALLOWANCE_M` until speed is an input. Prefer remove over inventing a model.
4. **Admit the slack definition** in `src/tideWindow.js` / brief output: height band ≠ slack water; do not call the result a slack-water window unless velocity enters the calc—rename or footnote; prefer rename/delete of the claim.
5. **Fail closed on datum** where stations are defined in `src/tideWindow.js`: no LAT → no window, not a silent LAT assumption.

## Evidence

- `src/tideWindow.js`: `SQUAT_ALLOWANCE_M = 0.6`; comment “Height only — current velocity is never consulted”; LAT assumed via `BAR_DEPTH_AT_DATUM_M`.
- `src/harbourPilotBrief.js`: lines build window → rise → “Transit permitted…” (decision last).
- `README.md`: “Safety-checked slack-water windows”; “Chart datum is assumed to be LAT.”
- `GUIDANCE.md`: deliberate weaknesses match the above; non-goals exclude chart plotter / AIS / route optimiser.
