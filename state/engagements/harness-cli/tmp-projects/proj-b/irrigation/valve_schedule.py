"""Turn per-zone transpiration deficits into tonight's valve runtimes.

Dummy project for harness-cli skill verification. Not production code.
Runtime is never capped against field capacity, so a large deficit can
produce a schedule that waterlogs the rootzone.
"""

from irrigation.transpiration_model import (
    ZONE_FLOW_L_PER_MIN,
    ZoneReading,
    transpiration_deficit_mm_per_day,
)

# Zones are watered in insertion order; the last one always finishes closest
# to sunrise.
TONIGHT: dict[str, ZoneReading] = {
    "bay-1-truss": ZoneReading("bay-1-truss", 24.5, 62.0, 310.0),
    "bay-2-cherry": ZoneReading("bay-2-cherry", 26.1, 48.0, 275.0),
    "bay-3-propagation": ZoneReading("bay-3-propagation", 22.0, 78.0, 90.0),
}


def zone_runtime_minutes(reading: ZoneReading) -> float:
    deficit_mm = transpiration_deficit_mm_per_day(reading)
    litres_needed = deficit_mm * reading.canopy_area_m2
    return litres_needed / ZONE_FLOW_L_PER_MIN


def overnight_schedule() -> list[tuple[str, float]]:
    return [(zone, zone_runtime_minutes(r)) for zone, r in TONIGHT.items()]


def main() -> None:
    for zone, minutes in overnight_schedule():
        print(f"{zone}\t{minutes:.1f} min")


if __name__ == "__main__":
    main()
