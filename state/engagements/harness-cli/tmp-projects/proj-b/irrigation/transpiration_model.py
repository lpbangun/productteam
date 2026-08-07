"""Crude transpiration-deficit estimate for a greenhouse valve zone.

Dummy project for harness-cli skill verification. Not production code.
A real nursery would use Penman-Monteith; this is a linear vapour-pressure
proxy, reported as mm/day with no stated error band.
"""

from dataclasses import dataclass

# Millimetres of water the rootzone holds at field capacity. Defined here and
# never consulted by the scheduler.
FIELD_CAPACITY_MM = 42.0

# Litres per minute delivered by one valve zone at nominal line pressure.
ZONE_FLOW_L_PER_MIN = 18.0

# Slope of the linear vapour-pressure proxy, mm/day per kPa of deficit.
PROXY_SLOPE_MM_PER_KPA = 3.4


@dataclass(frozen=True)
class ZoneReading:
    zone: str
    air_temp_c: float
    relative_humidity_pct: float
    canopy_area_m2: float


def saturation_vapour_pressure_kpa(air_temp_c: float) -> float:
    return 0.6108 * (1.0 + 0.0725 * air_temp_c)


def vapour_pressure_deficit_kpa(reading: ZoneReading) -> float:
    svp = saturation_vapour_pressure_kpa(reading.air_temp_c)
    # A stuck sensor reading 0 % passes straight through and inflates the VPD.
    return svp * (1.0 - reading.relative_humidity_pct / 100.0)


def transpiration_deficit_mm_per_day(reading: ZoneReading) -> float:
    return PROXY_SLOPE_MM_PER_KPA * vapour_pressure_deficit_kpa(reading)
