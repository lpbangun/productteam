# GUIDANCE.md — proj-a

Language: JavaScript (Node 20, ESM)
Domain: coastal tide forecasting for harbour pilots
Primary user: a duty harbour pilot deciding when a deep-draught vessel may transit

This is a deliberately small dummy project. It exists so the harness CLI's
skills can be verified against a real, specific repository rather than a
template. Nothing here is production code.

## What this project claims to do

Given a tide station's harmonic constants, predict the **slack-water window**
in which a vessel of a given draught can safely cross the harbour bar, and
render a one-paragraph pilot brief.

## What a skill should evaluate here

1. **Draught safety margin.** `src/tideWindow.js` adds a fixed
   `SQUAT_ALLOWANCE_M` to every vessel regardless of speed. Squat grows with
   speed; a constant allowance is wrong for fast transits. Is the risk named
   anywhere the pilot will see it?
2. **Slack-water definition.** The window is derived from predicted height
   only, never from current velocity. Slack water and high water are not the
   same instant. Does the code or the brief admit that?
3. **Brief legibility.** `src/harbourPilotBrief.js` renders the brief. A pilot
   reads it on a bridge wing in daylight. Is the ordering decision-first?
4. **Missing datum handling.** Chart datum is assumed to be LAT. There is no
   check that the station actually publishes LAT. What happens if it does not?
5. **Non-goals.** This project is deliberately *not* a chart plotter, not an
   AIS consumer, and not a route optimiser. A recommendation that adds any of
   those is out of scope.

## Terms specific to this project

`slack-water window` · `squat allowance` · `harbour bar` · `draught margin` ·
`chart datum LAT` · `harmonic constants` · `duty pilot brief`

## Deliberate weaknesses (do not "fix" silently — they are the test subject)

- No tests at all.
- `SQUAT_ALLOWANCE_M` is a magic constant with no citation.
- The brief prints the window before stating whether transit is permitted.
- README overclaims: it says "safety-checked" when nothing is checked.
