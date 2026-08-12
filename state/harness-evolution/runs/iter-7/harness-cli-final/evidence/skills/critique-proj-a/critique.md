# Product critique — proj-a

Runtime: agent
Timestamp: 20260810T081335Z
Repo: /home/logani/.herdr/worktrees/Product Consulting Harness/fix-new-user-tui/state/engagements/harness-cli/tmp-projects/proj-a
Skill: critique

## Product clarity

The product is a height-based **slack-water window** plus a one-paragraph **duty pilot brief**. That job is clear in `GUIDANCE.md` and `src/tideWindow.js`. Clarity breaks in `README.md`: “Safety-checked” overclaims — there is no safety check, only height ≥ draught + fixed squat. The code also equates slack water with an interval around high water (`src/tideWindow.js`), which is not the same as zero current.

## Target user

Primary user is a **duty harbour pilot** deciding whether a deep-draught vessel may cross the **harbour bar**. They need a bridge-wing answer: permitted or not, then when. Everything else (charts, AIS, routing) is out of scope.

## Friction

1. **Decision buried.** `src/harbourPilotBrief.js` prints the window and rise first; “Transit permitted…” last — wrong order for daylight glance reading.
2. **Hidden risk.** Fixed `SQUAT_ALLOWANCE_M` (0.6 m) in `src/tideWindow.js` never appears in the brief; squat grows with speed, so the **draught margin** is opaque and wrong for fast transits.
3. **Silent datum bet.** Chart depth assumes **chart datum LAT** with no station check; wrong datum → wrong window with no warning.
4. **Misnamed physics.** Window from height only; brief never says current velocity was ignored.

## Prioritized recommendations

1. **Delete “Safety-checked” from `README.md`.** Replace with plain “height-based window” language. Stops false trust; zero code risk.
2. **Reorder `src/harbourPilotBrief.js` to decision-first.** Lead with permitted/denied, then window, then rise. Prefer reorder over new UI.
3. **Name the squat and slack caveats in the brief (`src/harbourPilotBrief.js` + constant in `src/tideWindow.js`).** One clause: fixed squat allowance, not speed-aware; height-only, not current. Do not add a squat model or velocity engine.
4. **Fail closed on datum (`src/tideWindow.js`).** If LAT is not confirmed for the station, refuse the window rather than assume. Prefer refusal over a datum converter.

## Evidence

- `README.md`: “Safety-checked slack-water windows” — no check path exists.
- `src/tideWindow.js`: `SQUAT_ALLOWANCE_M = 0.6`; comment that slack is height-only; `BAR_DEPTH_AT_DATUM_M` with assumed LAT.
- `src/harbourPilotBrief.js`: window → rise → “Transit permitted…”; no squat/slack/datum disclosure.
- `GUIDANCE.md`: deliberate weaknesses match the above; non-goals exclude chart plotter / AIS / route optimiser.
