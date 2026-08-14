# test_layout.py — frozen §6: four sizes, dock above composer, two accents.

import asyncio
import re
from pathlib import Path

from app import ProductTeamApp
from theme import NEUTRAL, ACCENTS

SIZES = [(80, 24), (120, 36), (60, 24), (40, 20)]
SNAPSHOT_DIR = Path(__file__).resolve().parent / "__snapshots__"

HEX_RE = re.compile(r"#[0-9a-fA-F]{6}")


async def _run_size(width, height):
    app = ProductTeamApp()
    async with app.run_test(size=(width, height)) as pilot:
        header = app.query_one("#header")
        for _ in range(300):
            if "ProductTeam" in str(header.render()):
                break
            await pilot.pause()
        assert "ProductTeam" in str(header.render()), "header seeded with ProductTeam"
        composer = app.query_one("#composer")
        transcript = app.query_one("#transcript")
        chips = app.query_one("#chips")
        dock = app.query_one("#dock")
        assert composer is not None
        for wgt, name in (
            (header, "header"),
            (transcript, "transcript"),
            (chips, "chips"),
            (composer, "composer"),
        ):
            assert wgt.region.width > 0 and wgt.region.height > 0, f"{name} reachable at {width}x{height}"
            assert wgt.region.x + wgt.region.width > 0
            assert wgt.region.y + wgt.region.height > 0
        assert not dock.has_class("visible"), "dock hidden until slash"
        await pilot.press("/")
        await pilot.pause()
        assert dock.has_class("visible"), "dock visible after typing /"
        assert dock.region.width > 0 and dock.region.height > 0, "dock reachable"
        # dock sits immediately above the composer and never covers it
        assert dock.region.y + dock.region.height <= composer.region.y
        assert header.region.y < transcript.region.y < chips.region.y < composer.region.y
        svg = app.export_screenshot()
        assert "#0178D4" not in svg, "no Textual default cyan in the screenshot"
        await pilot.press("escape")
        await pilot.pause()
        assert not dock.has_class("visible"), "esc closes the dock"


def test_four_sizes():
    for w, h in SIZES:
        asyncio.run(_run_size(w, h))


def test_two_accents_only_in_css_and_theme():
    app_src = (Path(__file__).resolve().parents[1] / "app.py").read_text()
    theme_src = (Path(__file__).resolve().parents[1] / "theme.py").read_text()
    allowed = NEUTRAL | ACCENTS
    for src in (app_src, theme_src):
        for color in HEX_RE.findall(src):
            assert color.lower() in allowed, (
                f"unauthorized color literal {color} in {'app.py' if src is app_src else 'theme.py'}"
            )
    assert ACCENTS <= {c.lower() for c in HEX_RE.findall(app_src + theme_src)}


async def _snapshot(name, type_keys):
    app = ProductTeamApp()
    async with app.run_test(size=(80, 24)) as pilot:
        for _ in range(300):
            if "ProductTeam" in str(app.query_one("#header").render()):
                break
            await pilot.pause()
        if type_keys:
            for key in type_keys:
                await pilot.press(key)
            await pilot.pause()
        svg = app.export_screenshot(title=name)
        assert "#0178D4" not in svg
        SNAPSHOT_DIR.mkdir(parents=True, exist_ok=True)
        (SNAPSHOT_DIR / f"{name}.svg").write_text(svg)


def test_snapshots_export():
    asyncio.run(_snapshot("cockpit-80x24", []))
    asyncio.run(_snapshot("palette-80x24", ["/", "s", "t"]))
    assert (SNAPSHOT_DIR / "cockpit-80x24.svg").is_file()
    assert (SNAPSHOT_DIR / "palette-80x24.svg").is_file()
