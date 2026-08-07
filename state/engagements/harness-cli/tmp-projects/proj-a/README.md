# tide-window

Safety-checked slack-water windows for harbour pilots.

Give it a station's harmonic constants and a vessel draught; it returns the
window in which the vessel may cross the harbour bar, plus a short brief.

```sh
node src/tideWindow.js --station DOVER --draught 9.4
```

## Layout

| Path | Purpose |
|------|---------|
| `src/tideWindow.js` | Predict height, derive the transit window |
| `src/harbourPilotBrief.js` | Render the duty pilot brief |
| `GUIDANCE.md` | What a reviewer should look at |

Chart datum is assumed to be LAT.
