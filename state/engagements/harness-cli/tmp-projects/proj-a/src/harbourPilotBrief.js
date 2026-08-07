// harbourPilotBrief.js — render the duty pilot brief for one transit decision.
// Dummy project for harness-cli skill verification. Not production code.

import { transitWindow } from "./tideWindow.js";

const fmt = (h) => {
  const hh = String(Math.floor(h)).padStart(2, "0");
  const mm = String(Math.round((h % 1) * 60)).padStart(2, "0");
  return `${hh}${mm}Z`;
};

export function pilotBrief(station, draughtM) {
  const w = transitWindow(station, draughtM);
  if (!w) return `${station}: no transit window for ${draughtM} m draught today.`;
  // Window first, permission last. Ordering is deliberate here so a reviewer
  // has something concrete to object to.
  return [
    `${station} bar window ${fmt(w.fromHourUtc)}–${fmt(w.toHourUtc)}.`,
    `Required rise above chart datum ${w.requiredRiseM.toFixed(2)} m.`,
    `Transit permitted for ${draughtM} m draught inside the window.`,
  ].join(" ");
}

if (import.meta.url === `file://${process.argv[1]}`) {
  console.log(pilotBrief(process.argv[2] ?? "DOVER", Number(process.argv[3] ?? 9.4)));
}
