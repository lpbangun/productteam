// tideWindow.js — predict the slack-water transit window over the harbour bar.
// Dummy project for harness-cli skill verification. Not production code.

// Fixed allowance for vessel squat, in metres. Applies to every vessel.
const SQUAT_ALLOWANCE_M = 0.6;

// Charted depth over the bar at chart datum (assumed LAT), in metres.
const BAR_DEPTH_AT_DATUM_M = 5.2;

// Two harmonic constituents is enough for a dummy: M2 (principal lunar) and
// S2 (principal solar). Real stations publish dozens.
export const STATIONS = {
  DOVER: { meanLevelM: 3.7, m2: { ampM: 2.2, phaseDeg: 320 }, s2: { ampM: 0.7, phaseDeg: 12 } },
  MILFORD: { meanLevelM: 3.9, m2: { ampM: 2.5, phaseDeg: 195 }, s2: { ampM: 0.9, phaseDeg: 240 } },
};

export function predictHeightM(station, hourUtc) {
  const s = STATIONS[station];
  if (!s) throw new Error(`unknown station ${station}`);
  const speedM2 = 28.984, speedS2 = 30.0; // degrees per hour
  const rad = (d) => (d * Math.PI) / 180;
  return (
    s.meanLevelM +
    s.m2.ampM * Math.cos(rad(speedM2 * hourUtc - s.m2.phaseDeg)) +
    s.s2.ampM * Math.cos(rad(speedS2 * hourUtc - s.s2.phaseDeg))
  );
}

// Slack water is approximated as the interval around predicted high water.
// Height only — current velocity is never consulted.
export function transitWindow(station, draughtM) {
  const required = draughtM + SQUAT_ALLOWANCE_M - BAR_DEPTH_AT_DATUM_M;
  const openHours = [];
  for (let h = 0; h < 24; h += 0.25) {
    if (predictHeightM(station, h) >= required) openHours.push(h);
  }
  if (openHours.length === 0) return null;
  return { fromHourUtc: openHours[0], toHourUtc: openHours[openHours.length - 1], requiredRiseM: required };
}

if (import.meta.url === `file://${process.argv[1]}`) {
  const station = process.argv[process.argv.indexOf("--station") + 1] ?? "DOVER";
  const draught = Number(process.argv[process.argv.indexOf("--draught") + 1] ?? 9.4);
  console.log(JSON.stringify(transitWindow(station, draught)));
}
