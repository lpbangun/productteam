# test_layout.py — frozen §6: four sizes, dock above composer, locked tokens.

import asyncio
import json
import os
import re
import subprocess
import time
from pathlib import Path

import adapter
from app import ProductTeamApp
from textual.command import CommandPalette
from textual.widgets import Static
from theme import (
    ANALYST,
    BUILDER,
    COCKPIT_TOKENS,
    CRITIC,
    ERR,
    GLYPHS,
    MUTE,
    OK,
    PRINCIPAL,
    SPLASH_GAP_COMPACT,
    SPLASH_GAP_WIDE,
    SPLASH_HEADS,
    SPLASH_ROLES,
    TEXT,
    YOU,
)

# Every non-splash row in this file boots to the idle home: a non-empty
# CONSULT_NO_SPLASH short-circuits the boot splash exactly like
# lib/splash.sh. The splash tests below delenv it before app creation.
os.environ.setdefault("CONSULT_NO_SPLASH", "1")

SIZES = [(80, 24), (120, 36), (60, 24), (40, 20)]
SNAPSHOT_DIR = Path(__file__).resolve().parent / "__snapshots__"

HEX_RE = re.compile(r"#[0-9a-fA-F]{6}")
ANSI_ACCENT_RE = re.compile(r"\\e\[(?:3[0-7]|9[0-7])m")
BANNED_ENGAGEMENT = ("smoke", "run-loop", "gate-smoke", "overnight-rehears")
HOME_ROW_RE = re.compile(r"^\s*●\s+(\S+)\s+…+\s+(\d+\.\d)(.*)$", re.M)


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
        assert composer.region.width >= 20, (
            f"composer must be materially visible at {width}x{height} "
            f"(got {composer.region.width})"
        )
        assert not dock.has_class("visible"), "dock hidden until slash"
        await pilot.press("/")
        await pilot.pause()
        assert dock.has_class("visible"), "dock visible after typing /"
        assert dock.region.width > 0 and dock.region.height > 0, "dock reachable"
        assert composer.region.width >= 20, (
            f"composer stays visibly wide with the slash dock at {width}x{height} "
            f"(got {composer.region.width})"
        )
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


async def _boot_home(pilot, app):
    """Wait for the seeded header and the home projection (rows or empty copy)."""
    for _ in range(300):
        if "▣─▣─▣ ProductTeam" in str(app.query_one("#header").render()):
            break
        await pilot.pause()
    for _ in range(300):
        text = app.transcript_text()
        if HOME_ROW_RE.search(text) or "No scored sessions yet" in text:
            return text
        await pilot.pause()
    raise AssertionError("home projection never seeded")


def test_home_seed_filtered():
    """Q1: home carries at most three scored rows, never the banned
    engagements, and never a full status prose dump."""

    async def run():
        app = ProductTeamApp()
        async with app.run_test(size=(80, 24)) as pilot:
            text = await _boot_home(pilot, app)
            rows = HOME_ROW_RE.findall(text)
            assert 1 <= len(rows) <= 3, f"home must show at most three scored rows: {rows}"
            for name, _score, _rest in rows:
                low = name.lower()
                assert not any(b in low for b in BANNED_ENGAGEMENT), (
                    f"banned engagement seeded into home: {name}"
                )
            # the full prose status dump never enters the transcript
            assert "Product Consulting Harness" not in text
            assert "Product Judgment Layer" not in text
            assert "not scored" not in text

    asyncio.run(run())


def test_home_empty_copy_when_no_scored(monkeypatch):
    """D03: when no engagement is scored-eligible the home is the exact
    empty copy — zero home rows, no status prose, no banned rows — while
    the @Principal prefix, idle footer, and chips row stay mounted."""

    def fake(args, **kw):
        if list(args) == ["status", "--json"]:
            return subprocess.CompletedProcess(
                args, 0, json.dumps({"selected": None, "engagements": []}), ""
            )
        return subprocess.CompletedProcess(args, 0, "", "")

    monkeypatch.setattr(adapter, "run_argv", fake)

    async def run():
        app = ProductTeamApp()
        async with app.run_test(size=(80, 24)) as pilot:
            text = await _boot_home(pilot, app)
            assert text == "No scored sessions yet — bench <client> to score", text
            assert HOME_ROW_RE.findall(text) == [], "empty home must have zero rows"
            assert "Product Consulting Harness" not in text
            assert "Product Judgment Layer" not in text
            assert "not scored" not in text
            assert "@" not in str(app.query_one("#role-prefix", Static).render())
            assert str(app.query_one("#footer", Static).render()) == (
                "enter send · / commands · tab agents"
            )
            assert app.query_one("#chips") is not None
            for role in ("principal", "analyst", "builder", "critic"):
                assert app.query_one(f"#role-{role}", Static) is not None
            # banned-name scored rows and scored:false rows still seed the
            # exact empty copy — exclusion is part of the projection.
            app._seed_home([
                {"client": "smoke-client", "scored": True, "overall": 9.5,
                 "last_iter": "iter-1", "trend": None, "desc": ""},
                {"client": "gate-smoke", "scored": True, "overall": 9.0,
                 "last_iter": "iter-1", "trend": None, "desc": ""},
                {"client": "idle-client", "scored": False, "overall": None,
                 "last_iter": None, "trend": None, "desc": ""},
            ], None)
            await pilot.pause()
            assert HOME_ROW_RE.findall(app.transcript_text()) == [], (
                "banned/unscored rows must never seed home rows"
            )

    asyncio.run(run())


def _write_scores_tree(tmp_path, rows, cwd=None):
    """rows: [(client, iter, overall, mtime)] → scores.json under
    tmp_path/state/engagements/<client>/runs/iter-N/ with distinct mtimes;
    the mapped client (cwd given) also gets engagement.md Repo: = cwd."""
    for client, it, overall, mtime in rows:
        base = tmp_path / "state" / "engagements" / client / "runs" / f"iter-{it}"
        base.mkdir(parents=True, exist_ok=True)
        sf = base / "scores.json"
        sf.write_text(json.dumps({"overall": overall}), encoding="utf-8")
        os.utime(sf, (mtime, mtime))
    if cwd is not None:
        here = tmp_path / "state" / "engagements" / cwd[0]
        (here / "engagement.md").write_text(f"Repo: {cwd[1]}\n", encoding="utf-8")


def _status_fixture(engagements, real_run_argv):
    """adapter.run_argv stand-in: real CLI for everything except the
    home's ["status", "--json"] (which returns the fixture)."""
    def fake(args, **kw):
        if list(args) == ["status", "--json"]:
            return subprocess.CompletedProcess(
                args, 0, json.dumps({"selected": None, "engagements": engagements}), ""
            )
        return real_run_argv(args, **kw)
    return fake


def test_home_recency_mtime_order(tmp_path, monkeypatch):
    """D03: home rows sort by the latest valid scores.json st_mtime
    (numeric iter fallback, stable client tie-break), the mapped client is
    pinned into at most one slot while the rest stay recency-sorted, the
    cap stays three, and banned/unscored rows never appear."""
    monkeypatch.setattr("app.ROOT", tmp_path)
    cwd = str(Path.cwd().resolve())
    clients = [
        # (client, latest iter, overall, mtime) — mtime rank below
        ("new-client", 1, 9.0, 1700000400),   # newest mtime, iter-1
        ("mid-client", 9, 8.9, 1700000300),   # 2nd mtime
        ("lex-client", 10, 9.1, 1700000200),  # 3rd mtime (iter-10 vs iter-9)
        ("old-client", 2, 8.7, 1700000100),   # oldest of the four → dropped
        ("here-client", 3, 8.5, 1700000050),  # mapped, older than old → pin
        ("smoke-client", 4, 9.5, 1700000500),  # newest mtime but banned name
    ]
    _write_scores_tree(tmp_path, clients, cwd=("here-client", cwd))
    engagements = [
        {"client": client, "scored": True, "last_iter": f"iter-{it}",
         "overall": overall, "areas_ge_9": 1, "trend": "+0.0", "desc": ""}
        for client, it, overall, _mtime in clients
    ]
    engagements.append({
        "client": "idle-client", "scored": False, "last_iter": None,
        "overall": None, "areas_ge_9": None, "trend": None, "desc": "",
    })
    monkeypatch.setattr(
        adapter, "run_argv", _status_fixture(engagements, adapter.run_argv))

    async def run():
        app = ProductTeamApp()
        async with app.run_test(size=(80, 24)) as pilot:
            text = await _boot_home(pilot, app)
            rows = HOME_ROW_RE.findall(text)
            names = [name for name, _score, _rest in rows]
            assert names == ["here-client", "new-client", "mid-client"], names
            assert [score for _name, score, _rest in rows] == ["8.5", "9.0", "8.9"]
            assert app._overall == 8.5, "mapped engagement owns _overall"
            assert str(app.header.render()).endswith(" · 8.5")
            assert len(rows) == 3, "cap stays three"
            for absent in ("lex-client", "old-client", "smoke-client", "idle-client"):
                assert absent not in names, f"{absent} must not seed home"
            assert "Product Consulting Harness" not in text
            assert "Product Judgment Layer" not in text
            assert "not scored" not in text

    asyncio.run(run())


def test_home_recency_numeric_and_client_tiebreak(tmp_path, monkeypatch):
    """D03: equal mtimes fall back to the numeric iter (iter-10 beats
    iter-9 — never lexicographic) and equal iters to alphabetical client
    names — never the JSON array order (deliberately scrambled below)."""
    monkeypatch.setattr("app.ROOT", tmp_path)
    mt = 1700001000
    clients = [
        ("name-z", 7, 9.0, mt),
        ("tie-a", 9, 9.1, mt),
        ("name-a", 7, 8.9, mt),
        ("tie-b", 10, 9.2, mt),
    ]
    _write_scores_tree(tmp_path, clients)
    engagements = [
        {"client": client, "scored": True, "last_iter": f"iter-{it}",
         "overall": overall, "areas_ge_9": 1, "trend": None, "desc": ""}
        for client, it, overall, _mtime in clients
    ]
    monkeypatch.setattr(
        adapter, "run_argv", _status_fixture(engagements, adapter.run_argv))

    async def run():
        app = ProductTeamApp()
        async with app.run_test(size=(80, 24)) as pilot:
            text = await _boot_home(pilot, app)
            rows = HOME_ROW_RE.findall(text)
            names = [name for name, _score, _rest in rows]
            assert names == ["tie-b", "tie-a", "name-a"], names
            assert app._overall is None, "unmapped cwd must not acquire an engagement score"
            assert str(app.header.render()).endswith(" · 9.2"), (
                "unmapped header mirrors the most recent displayed home row")

    asyncio.run(run())


def test_header_cwd_projection():
    """D05: wide header is the locked shape with the process cwd basename,
    no engagement name, no Mode/Directive, and an honest score slot."""

    async def run():
        app = ProductTeamApp()
        async with app.run_test(size=(80, 24)) as pilot:
            text = ""
            for _ in range(300):
                text = str(app.query_one("#header").render())
                if "▣─▣─▣ ProductTeam" in text:
                    break
                await pilot.pause()
            assert text.startswith("▣─▣─▣ ProductTeam · "), text
            assert Path.cwd().name in text, f"header must carry the cwd basename: {text!r}"
            assert re.search(r"· (—|\d+\.\d)\s*$", text), (
                f"header must end with the cwd score or —: {text!r}"
            )
            assert "harness-cli" not in text, "header must never claim harness-cli"
            assert "Directive" not in text and "Mode" not in text, text

    asyncio.run(run())


def _header_spans(app):
    """[(covered_text, hex_or_empty, style_str)] across the #header
    widget's rendered visual — the same span walk the splash tests run."""
    text = app.header.render()
    out = []
    for span in text.spans:
        color = ""
        if span.style is not None and span.style.foreground is not None:
            color = (span.style.foreground.hex6 or "").lower()
        out.append((text.plain[span.start:span.end], color, str(span.style) if span.style else ""))
    return out


def _middle_head_span(app):
    """The span covering exactly the middle ▣ in `▣─▣─▣` (None when it is
    merged with the bold side heads)."""
    text = app.header.render()
    plain = text.plain
    first = plain.find("▣─")
    mid = plain.find("▣", first + 2)
    if mid < 0:
        return None
    for span in text.spans:
        if span.start == mid and span.end == mid + 1:
            return span
    return None


def _span_hex(span) -> str:
    """The span's foreground hex ("" when unstyled). Handles both textual
    Content spans (Style objects) and raw Rich spans (style strings)."""
    style = span.style
    if isinstance(style, str):
        return (style or "").lower()
    if style is not None and style.foreground is not None:
        return (style.foreground.hex6 or "").lower()
    return ""


def test_header_pulse_middle_head_ok_when_busy(tmp_path, monkeypatch):
    """D05: the wide header pulses only the middle ▣ (OK) while the
    provider is active or a live activity row exists; idle restores the
    plain bold head, side heads never pulse, and the compact header keeps
    its no-heads chrome (pulse never leaks there)."""
    monkeypatch.setenv("CONSULT_STATE_ROOT", str(tmp_path / "state"))

    async def run():
        app = ProductTeamApp()
        async with app.run_test(size=(80, 24)) as pilot:
            await _boot_home(pilot, app)
            # 1. idle: no provider, no live rows → middle head un-pulsed
            assert not app._provider_active
            assert app._live_activity_rows() == []
            assert _span_hex(_middle_head_span(app)) != OK, (
                "idle middle head must not be OK")
            assert "▣─▣─▣ ProductTeam" in str(app.header.render())
            for covered, color, _style in _header_spans(app):
                assert not ("▣" in covered and color == OK), (
                    f"idle header must carry no OK pulse: {covered!r}")
            # 2. busy via a live activity row (5 Hz poll paints the pulse)
            now = int(time.time())
            _write_activity_rows(app, [
                ("1", "Builder", "running", "verify the seam", "hold-provider.sh", now, "0", ""),
            ])
            await pilot.pause(0.35)
            assert _span_hex(_middle_head_span(app)) == OK, (
                "live activity must pulse the middle head with OK")
            spans = _header_spans(app)
            assert spans[0][0] == "▣─" and spans[0][1] != OK, "left head stays un-pulsed"
            assert ("─▣ ProductTeam", "") in [(c, col) for c, col, _s in spans], (
                "right head stays un-pulsed")
            # 3. busy via _provider_active after the activity clears to done
            _write_activity_rows(app, [
                ("1", "Builder", "done", "verify the seam", "hold-provider.sh", now, "0", ""),
            ])
            await pilot.pause(0.35)
            assert app._live_activity_rows() == []
            app._provider_active = True
            app._render_header()
            assert _span_hex(_middle_head_span(app)) == OK, (
                "_provider_active must pulse the middle head with OK")
            # compact while busy: no heads at all — pulse never leaks
            await pilot.resize_terminal(40, 20)
            await pilot.pause(0.25)
            compact = str(app.header.render())
            assert compact.startswith("ProductTeam "), compact
            assert "▣" not in compact, "compact header never carries heads"
            # restore wide, then idle restore drops the pulse
            await pilot.resize_terminal(80, 24)
            await pilot.pause(0.25)
            app._provider_active = False
            app._render_header()
            assert _span_hex(_middle_head_span(app)) != OK, (
                "idle restore must drop the pulse")
            assert "▣─▣─▣ ProductTeam" in str(app.header.render())

    asyncio.run(run())


def test_you_turn_chrome():
    """Bare-text Enter renders a locked You turn (gray rail, mute label, dim
    timestamp) instead of a plain unstyled echo. Provider role turns are out
    of this iteration, so the real provider spawn is stubbed for the test."""

    async def run():
        app = ProductTeamApp()
        app._start_provider_turn = lambda prompt: None  # presentation-only slice
        async with app.run_test(size=(80, 24)) as pilot:
            await _boot_home(pilot, app)
            before = app.transcript_text()
            app.composer.focus()
            await pilot.press("h", "i")
            await pilot.press("enter")
            await pilot.pause()
            delta = app.transcript_text()[len(before):]
            assert re.search(r"│ You · \d{2}:\d{2}", delta), (
                f"You turn chrome (rail + mute label + dim timestamp) missing: {delta!r}"
            )
            assert "hi" in delta, f"You body missing from turn: {delta!r}"
            assert delta.count("│") >= 2, "rail must edge the label line and the body line"
            assert before == app.transcript_text()[:len(before)], (
                "seed transcript must be untouched by the You turn"
            )

    asyncio.run(run())


def test_cockpit_token_contract():
    """Cockpit sources carry exactly the locked token set: neutral canvas/
    field/rule/text/mute, You + four role identity hues, ok/err accents.
    No Textual cyan and no additional hues are allowed."""
    app_src = (Path(__file__).resolve().parents[1] / "app.py").read_text()
    theme_src = (Path(__file__).resolve().parents[1] / "theme.py").read_text()
    for src, name in ((app_src, "app.py"), (theme_src, "theme.py")):
        for color in HEX_RE.findall(src):
            assert color.lower() in COCKPIT_TOKENS, (
                f"unauthorized color literal {color} in {name}"
            )
    used = {c.lower() for c in HEX_RE.findall(app_src + theme_src)}
    assert used == COCKPIT_TOKENS, (
        "locked cockpit tokens must all be present and no others: "
        f"missing={sorted(COCKPIT_TOKENS - used)} extra={sorted(used - COCKPIT_TOKENS)}"
    )


def test_bash_two_accent_budget():
    """The canonical Bash CLI keeps its red/green two-accent budget; the
    cockpit-only role identity allowance never weakens it."""
    root = Path(__file__).resolve().parents[3]
    src = (root / "bin" / "productteam").read_text(encoding="utf-8")
    src += (root / "lib" / "theme.sh").read_text(encoding="utf-8")
    codes = set(ANSI_ACCENT_RE.findall(src))
    assert codes <= {"\\e[31m", "\\e[32m"}, (
        f"Bash accent hues outside red/green: {sorted(codes)}"
    )


async def _snapshot(name, type_keys):
    # Textual reads NO_COLOR at App construction and installs a Monochrome
    # filter, so an inherited NO_COLOR would strip the locked role hues from
    # the evidence SVGs. Force color for the export only; the separate
    # NO_COLOR behavior tests (test_nontty) are untouched.
    had = os.environ.pop("NO_COLOR", None)
    try:
        app = ProductTeamApp()
        async with app.run_test(size=(80, 24)) as pilot:
            for _ in range(300):
                if "▣─▣─▣ ProductTeam" in str(app.query_one("#header").render()):
                    break
                await pilot.pause()
            for _ in range(300):
                if HOME_ROW_RE.search(app.transcript_text()) or "No scored sessions yet" in app.transcript_text():
                    break
                await pilot.pause()
            if type_keys:
                for key in type_keys:
                    await pilot.press(key)
                await pilot.pause()
            svg = app.export_screenshot(title=name)
            assert "#0178D4" not in svg, "no Textual default cyan in the screenshot"
            assert "Directive" not in svg, "snapshot must not claim a Mode/Directive"
            assert "run-loop" not in svg, "snapshot must not show run-loop rows"
            assert "smoke" not in svg, "snapshot must not show smoke rows"
            SNAPSHOT_DIR.mkdir(parents=True, exist_ok=True)
            (SNAPSHOT_DIR / f"{name}.svg").write_text(svg)
    finally:
        if had is not None:
            os.environ["NO_COLOR"] = had


def test_snapshots_export():
    asyncio.run(_snapshot("cockpit-80x24", []))
    asyncio.run(_snapshot("palette-80x24", ["/", "s", "t"]))
    assert (SNAPSHOT_DIR / "cockpit-80x24.svg").is_file()
    assert (SNAPSHOT_DIR / "palette-80x24.svg").is_file()


def test_role_chips_focusable_and_selectable():
    """D18: four focusable/clickable role chips; default target Principal;
    click and keyboard both select Builder; selection restores composer
    focus; @Role chrome follows the target."""

    async def run():
        app = ProductTeamApp()
        app._start_provider_turn = lambda prompt: None  # presentation-only slice
        async with app.run_test(size=(80, 24)) as pilot:
            await _boot_home(pilot, app)
            assert app._target_role == "Principal", "team briefs still route through Principal"
            assert app._pinned is False, "idle home is team mode — no pinned role"
            prefix = app.query_one("#role-prefix")
            assert "@" not in str(prefix.render()), "team mode shows no @Role chrome"
            for role in ("principal", "analyst", "builder", "critic"):
                chip = app.query_one(f"#role-{role}", Static)
                assert chip.can_focus, f"{role} chip must be focusable"
            # keyboard: tab to the chips row, cycle right twice, Enter selects Builder
            await pilot.press("tab")
            await pilot.press("tab")
            await pilot.press("right")
            await pilot.press("right")
            await pilot.press("enter")
            await pilot.pause()
            assert app._target_role == "Builder", "Enter on the focused chip selects Builder"
            assert "@Builder" in str(prefix.render()), "prefix chrome follows the target"
            assert app.focused is app.composer, "selection restores composer focus"
            # Arrow navigation changes focus only: the pin, prefix, and send
            # route remain Builder even while Analyst is focused.
            app.query_one("#role-builder", Static).focus()
            await pilot.press("left")
            await pilot.pause()
            assert app.focused is app.query_one("#role-analyst", Static)
            assert app._target_role == "Builder" and app._pinned is True
            assert app._route_role == "Builder"
            assert "@Builder" in str(prefix.render())
            app.composer.text = "keep the pinned route"
            app.submit_composer()
            assert app._active_turn_role == "Builder"
            # click selects and restores focus the same way
            await pilot.click("#role-critic")
            await pilot.pause()
            assert app._target_role == "Critic", "click selects the clicked role"
            assert "@Critic" in str(prefix.render())
            assert app.focused is app.composer, "click selection restores composer focus"
            # L6: a second activation on the already-pinned chip unpins back
            # to team — prefix collapses (width 0), no @Role chrome.
            await pilot.click("#role-critic")
            await pilot.pause()
            assert app._pinned is False, "second click on the pinned chip unpins"
            assert "@" not in str(prefix.render()), "unpinned prefix carries no @Role"
            assert str(prefix.styles.width) in ("0", "0w", "0h"), (
                f"unpinned prefix must collapse to width 0: {prefix.styles.width!r}")
            assert app.focused is app.composer

    asyncio.run(run())


def test_typed_role_prefix_strips():
    """D18: a typed leading @Role overrides the session target, is stripped
    from the prompt, never enters the You body, and a bare @Role alone
    spawns nothing."""

    async def run():
        app = ProductTeamApp()
        app._start_provider_turn = lambda prompt: None  # presentation-only slice
        async with app.run_test(size=(80, 24)) as pilot:
            await _boot_home(pilot, app)
            before = app.transcript_text()
            app.composer.focus()
            await pilot.press(*list("@Builder build the seam"))
            await pilot.press("enter")
            await pilot.pause()
            delta = app.transcript_text()[len(before):]
            assert "@Builder" not in delta, "typed @Role must be stripped from the turn"
            assert "build the seam" in delta, "stripped prompt is the You body"
            assert app._target_role == "Builder", "typed @Role overrides the session target"
            assert app._active_turn_role == "Builder", "active turn role records Builder"
            assert "@Builder" in str(app.query_one("#role-prefix").render())
            # empty after strip → target still updates, no turn spawns
            before2 = app.transcript_text()
            app.composer.focus()
            await pilot.press(*list("@Critic"))
            await pilot.press("enter")
            await pilot.pause()
            assert app._target_role == "Critic", "bare @Role still updates the target"
            assert app.transcript_text() == before2, "bare @Role alone spawns nothing"

    asyncio.run(run())


def test_snapshot_role_hues_and_no_cyan():
    """D02: refreshed snapshots carry the four role identity hexes (chips and
    @Role chrome) and never any Textual cyan."""
    for name in ("cockpit-80x24.svg", "palette-80x24.svg"):
        svg = (SNAPSHOT_DIR / name).read_text()
        for hue in (PRINCIPAL, ANALYST, BUILDER, CRITIC):
            assert hue in svg, f"{name} must show role hue {hue}"
        assert "#0178D4" not in svg, f"{name} must not show Textual cyan"


def _write_activity_rows(app, rows):
    directory = app._activity_session_dir
    directory.mkdir(parents=True, exist_ok=True)
    header = "id\trole\tstate\tmission\tprovider\tstart\telapsed\tartifact\n"
    directory.joinpath("workers.tsv").write_text(
        header + "\n".join("\t".join(map(str, row)) for row in rows) + "\n"
    )


def test_activity_file_backed_caps_footer_and_resize(tmp_path, monkeypatch):
    """Live chrome reads only the app-owned workers.tsv and keeps resize
    header/activity/footer changes independent from focus."""
    monkeypatch.setenv("CONSULT_STATE_ROOT", str(tmp_path / "state"))

    async def run():
        app = ProductTeamApp()
        async with app.run_test(size=(80, 24)) as pilot:
            await _boot_home(pilot, app)
            assert not app.activity.has_class("visible")
            now = int(time.time()) - 4
            rows = [
                ("1", "Principal", "running", "planning", "claude", now, "4", ""),
                ("2", "Analyst", "pending", "evidence", "gpt", now, "4", ""),
                ("3", "Critic", "progress", "checking", "local", now, "4", ""),
            ]
            _write_activity_rows(app, rows)
            await pilot.pause(0.35)
            text = str(app.activity.render())
            assert text.count("\n") == 2
            assert "planning" in text and "claude" in text
            assert re.match(
                r"ctrl\+c interrupt · \d+:\d{2} · claude$",
                str(app.query_one("#footer").render()),
            )
            assert app.focused is app.composer

            await pilot.resize_terminal(60, 24)
            await pilot.pause(0.25)
            assert str(app.header.render()).startswith("▣─▣─▣ ProductTeam")
            assert str(app.activity.render()).count("\n") == 1
            assert app.focused is app.composer

            await pilot.resize_terminal(40, 20)
            await pilot.pause(0.25)
            header_score = (f"{app._header_score:.1f}"
                            if app._header_score is not None else "—")
            assert str(app.header.render()) == f"ProductTeam {header_score}"
            compact = str(app.activity.render())
            assert compact.count("\n") == 1 and "+2" in compact
            assert re.match(
                r"ctrl\+c · \d+:\d{2}$",
                str(app.query_one("#footer").render()),
            )
            await pilot.resize_terminal(80, 24)
            await pilot.pause(0.25)
            assert "▣─▣─▣ ProductTeam" in str(app.header.render())
            assert str(app.activity.render()).count("\n") == 2
            assert app.focused is app.composer

            rows = [(*row[:2], "done", *row[3:]) for row in rows]
            _write_activity_rows(app, rows)
            await pilot.pause(0.35)
            assert not app.activity.has_class("visible")
            assert str(app.query_one("#footer").render()) == (
                "enter send · / commands · tab agents"
            )
            await pilot.press("/")
            await pilot.pause()
            assert str(app.query_one("#footer").render()) == (
                "enter run · tab complete · ↑↓ choose · esc close"
            )
            await pilot.press("escape")
            await pilot.pause()
            assert str(app.query_one("#footer").render()) == (
                "enter send · / commands · tab agents"
            )

    asyncio.run(run())


def test_empty_artifact_stays_activity_and_speech_is_owned(tmp_path, monkeypatch):
    """Empty artifact work is silent in the transcript; emitted bytes open
    exactly one role-owned turn and later chunks do not duplicate its body."""
    monkeypatch.setenv("CONSULT_STATE_ROOT", str(tmp_path / "state"))

    async def run():
        app = ProductTeamApp()
        async with app.run_test(size=(80, 24)) as pilot:
            await _boot_home(pilot, app)
            now = int(time.time())
            _write_activity_rows(
                app, [("1", "Analyst", "running", "research", "claude", now, "0", "")]
            )
            await pilot.pause(0.3)
            before = app.transcript_text()
            assert "Thinking…" not in before
            assert "◇ Analyst" not in before
            app._active_turn_role = "Analyst"
            app._append_provider_chunk("answer one\nanswer two\n")
            await pilot.pause()
            delta = app.transcript_text()[len(before):]
            assert "◇ Analyst" in delta
            assert delta.count("answer one") == 1
            assert delta.count("answer two") == 1
            assert delta.count("◇ Analyst") == 1
            assert delta.count("│") >= 3
            app._add_turn("provider", "answer one\nanswer two")
            assert app._turns[-1] == ("provider", "answer one\nanswer two")

    asyncio.run(run())


def test_four_role_speaking_rails_neutral_body(tmp_path, monkeypatch):
    """D04: Principal/Analyst/Builder/Critic each open exactly one speaking
    rail whose rail and label carry the exact ROLE_STYLES identity hue; the
    distinctive body stays neutral (no style span covers it, never a role/
    You/OK/ERR hue) and Thinking never appears. No provider mock: the test
    drives _append_provider_chunk only, resetting per-role speech state."""
    monkeypatch.setenv("CONSULT_STATE_ROOT", str(tmp_path / "state"))

    async def run():
        app = ProductTeamApp()
        async with app.run_test(size=(80, 24)) as pilot:
            await _boot_home(pilot, app)
            writes = []
            orig_write = app.transcript.write

            def recording(renderable, *a, **k):
                writes.append(renderable)
                return orig_write(renderable, *a, **k)

            app.transcript.write = recording
            for role, glyph, hue, body in (
                ("Principal", "◆", PRINCIPAL, "principal body"),
                ("Analyst", "◇", ANALYST, "analyst body"),
                ("Builder", "▸", BUILDER, "builder body"),
                ("Critic", "◉", CRITIC, "critic body"),
            ):
                writes.clear()
                before = app.transcript_text()
                app._provider_speech_opened = False
                app._md_buffer = ""
                app._md_fence = False
                app._active_turn_role = role
                app._append_provider_chunk(f"{body}\n")
                await pilot.pause()
                delta = app.transcript_text()[len(before):]
                assert delta.count(f"│ {glyph} {role}") == 1, (
                    f"{role} must open exactly one speaking rail: {delta!r}")
                assert _turn_has_hue(app, f"{glyph} {role}", hue), (
                    f"{role} label must carry {hue}")
                assert "Thinking…" not in delta
                # the opener write's first span is the rail glyph in the hue
                opener = writes[0]
                assert opener.plain.startswith("│")
                rail_span = opener.spans[0]
                assert opener.plain[rail_span.start:rail_span.end] == "│"
                assert _span_hex(rail_span) == hue, f"{role} rail must be {hue}"
                # neutral body: no style span covers the distinctive body —
                # so it can never carry a role/You/OK/ERR hue
                for w in writes:
                    for sp in w.spans:
                        covered = w.plain[sp.start:sp.end]
                        assert body not in covered, (
                            f"{role} body must carry no style span")
                    assert body in w.plain, f"{role} body must be written"

    asyncio.run(run())


# ── structured ask dock (frozen §6, file-backed seam) ────────────────

ASK_SINGLE = {
    "event": "ask",
    "id": "ask-single-1",
    "role": "Builder",
    "question": "Where should each role's color appear?",
    "mode": "single",
    "options": [
        {"id": "label-rail", "label": "Label + rail",
         "description": "Color the role label, chip, and 2px turn rail.",
         "recommended": True},
        {"id": "label-only", "label": "Label only",
         "description": "Keep the rail neutral.", "recommended": False},
    ],
    "default": ["label-rail"],
}

ASK_MULTI = {
    "event": "ask",
    "id": "ask-multi-1",
    "role": "Analyst",
    "question": "Which evidence sources should the panel show?",
    "mode": "multi",
    "options": [
        {"id": "report", "label": "Report", "description": "Bench files.",
         "recommended": True},
        {"id": "scores", "label": "Scores", "description": "Iteration scores.",
         "recommended": False},
        {"id": "notes", "label": "Notes", "description": "Session notes.",
         "recommended": False},
    ],
    "default": ["report"],
}


def _write_ask(app, event):
    art = Path(app._active_artifact)
    art.parent.mkdir(parents=True, exist_ok=True)
    (art.parent / "ask.json").write_text(json.dumps(event), encoding="utf-8")


async def _ask_wait(pilot, predicate, timeout=8.0):
    deadline = asyncio.get_event_loop().time() + timeout
    while asyncio.get_event_loop().time() < deadline:
        if predicate():
            return True
        await pilot.pause()
        await asyncio.sleep(0.02)
    return False


def _turn_has_hue(app, label, hue):
    """True when a transcript strip segment carries the label in the exact
    role hue (the real colored turn chrome, not a plain echo)."""
    for strip in app.transcript.lines:
        for seg in strip:
            if label in seg.text:
                style = seg.style
                if str(style) == hue or str(getattr(style, "color", "")) == hue:
                    return True
    return False


def _ask_dock_row(app, index):
    return app.dock.get_option_at_index(index).prompt


async def _open_ask(pilot, app, tmp_path, event, role):
    app._provider_active = True
    app._active_artifact = str(tmp_path / "session" / "artifacts" / "a.txt")
    _write_ask(app, event)
    ok = await _ask_wait(pilot, lambda: app._dock_kind == "ask")
    assert ok, "ask.json opens the ask dock"
    assert app.dock_visible()
    assert app._target_role == "Principal"  # the ask role never rewrites the session target
    return Path(app._active_artifact).parent


def test_ask_dock_single_exact_question_and_answer(tmp_path, monkeypatch):
    """D08: the file-backed ask seam opens the single #dock above the
    composer, renders the exact question as one colored Builder turn with
    labels/descriptions/recommended, live k of n, arrows/Space/Enter, an
    atomic structured answer, and one-time consumption."""
    monkeypatch.setenv("CONSULT_STATE_ROOT", str(tmp_path / "state"))

    async def run():
        app = ProductTeamApp()
        async with app.run_test(size=(80, 24)) as pilot:
            await _boot_home(pilot, app)
            before = app.transcript_text()
            art_dir = await _open_ask(pilot, app, tmp_path, ASK_SINGLE, "Builder")
            # composer stays mounted, focused, and the dock sits above it
            assert app.focused is app.composer
            dock = app.query_one("#dock")
            composer = app.query_one("#composer")
            assert dock.region.y + dock.region.height <= composer.region.y
            assert composer.region.height > 0
            # exact question: one real colored role turn, never a rewrite
            delta = app.transcript_text()[len(before):]
            assert delta.count("Where should each role's color appear?") == 1
            assert delta.count("▸ Builder") == 1
            assert _turn_has_hue(app, "▸ Builder", BUILDER), (
                "question turn must carry the Builder identity hue"
            )
            # labels + mute descriptions + literal recommended + defaults
            title = _ask_dock_row(app, 0)
            assert "Ask" in title.plain and "1 of 2" in title.plain, title.plain
            row0 = _ask_dock_row(app, 1)
            assert "Label + rail" in row0.plain and "recommended" in row0.plain
            assert "★" not in row0.plain, "L16: the literal word replaces ★"
            assert "Color the role label, chip, and 2px turn rail." in row0.plain
            assert "bold" in [s.style for s in row0.spans], "recommended label is bold"
            assert row0.plain.startswith("●"), "default option shows the selected marker"
            row1 = _ask_dock_row(app, 2)
            assert "Label only" in row1.plain and "Keep the rail neutral." in row1.plain
            assert "recommended" not in row1.plain
            assert "bold" not in [s.style for s in row1.spans]
            # live k of n + arrows + Space (single selects the highlighted id)
            assert str(app.query_one("#footer").render()) == (
                "1 of 2 · ↑↓ choose · space select · enter confirm · esc cancel"
            )
            await pilot.press("down")
            await pilot.pause()
            assert str(app.query_one("#footer").render()) == (
                "2 of 2 · ↑↓ choose · space select · enter confirm · esc cancel"
            )
            await pilot.press("space")
            await pilot.pause()
            assert app._ask_selection == ["label-only"]
            assert app.dock.highlighted == 2
            # Enter atomically persists the structured answer and closes
            await pilot.press("enter")
            await pilot.pause()
            assert not app.dock_visible() and app._dock_kind == "slash"
            assert app.focused is app.composer
            answer = json.loads((art_dir / "ask.answer.json").read_text())
            assert answer == {
                "event": "ask-answer",
                "ask_id": "ask-single-1",
                "answers": ["label-only"],
                "cancelled": False,
            }
            assert not (art_dir / "ask.answer.json.tmp").exists(), "atomic replace, no temp"
            assert (art_dir / "ask.json.done").is_file(), "ask retired after answering"
            assert not (art_dir / "ask.json").exists()
            # one-time consumption: the same id never re-opens the dock
            answered_text = app.transcript_text()
            _write_ask(app, ASK_SINGLE)
            ok = await _ask_wait(pilot, lambda: not (art_dir / "ask.json").exists())
            assert ok, "re-emitted same-id file retired without reopening"
            assert not app.dock_visible(), "a retired id must never re-open the dock"
            assert app.transcript_text() == answered_text, "question rendered exactly once"
            # a fresh id still opens the seam (new ask in the same directory)
            fresh = dict(ASK_SINGLE, id="ask-single-2")
            _write_ask(app, fresh)
            ok = await _ask_wait(pilot, lambda: app._dock_kind == "ask")
            assert ok, "a fresh ask id opens the dock again"
            await pilot.press("escape")
            await pilot.pause()
            assert not app.dock_visible()

    asyncio.run(run())


def test_ask_dock_multi_toggle_and_esc_cancel(tmp_path, monkeypatch):
    """D08: multi mode toggles membership with Space, k of n counts the
    selection, and Esc cancels with cancelled=true and an empty selection —
    closing the dock and restoring composer focus, no spawn."""
    monkeypatch.setenv("CONSULT_STATE_ROOT", str(tmp_path / "state"))

    async def run():
        app = ProductTeamApp()
        async with app.run_test(size=(80, 24)) as pilot:
            await _boot_home(pilot, app)
            art_dir = await _open_ask(pilot, app, tmp_path, ASK_MULTI, "Analyst")
            assert "◇ Analyst" in app.transcript_text()
            assert app.focused is app.composer
            assert str(app.query_one("#footer").render()) == (
                "1 of 3 · ↑↓ choose · space toggle · enter confirm · esc cancel"
            )
            # Space toggles the highlighted option off, then on
            await pilot.press("space")
            await pilot.pause()
            assert app._ask_selection == []
            assert str(app.query_one("#footer").render()) == (
                "0 of 3 · ↑↓ choose · space toggle · enter confirm · esc cancel"
            )
            await pilot.press("down")
            await pilot.press("down")
            await pilot.press("space")
            await pilot.pause()
            assert app._ask_selection == ["notes"]
            assert str(app.query_one("#footer").render()) == (
                "1 of 3 · ↑↓ choose · space toggle · enter confirm · esc cancel"
            )
            await pilot.press("space")
            await pilot.pause()
            assert app._ask_selection == []
            assert str(app.query_one("#footer").render()) == (
                "0 of 3 · ↑↓ choose · space toggle · enter confirm · esc cancel"
            )
            # Esc cancels: structured answer with cancelled=true, empty list
            await pilot.press("escape")
            await pilot.pause()
            assert not app.dock_visible() and app._dock_kind == "slash"
            assert app.focused is app.composer
            answer = json.loads((art_dir / "ask.answer.json").read_text())
            assert answer == {
                "event": "ask-answer",
                "ask_id": "ask-multi-1",
                "answers": [],
                "cancelled": True,
            }
            assert (art_dir / "ask.json.done").is_file()

    asyncio.run(run())


def test_ask_invalid_retires_once_and_refuses(tmp_path, monkeypatch):
    """§6: a malformed, missing, or prose-only event never opens a fake
    question — one mute refusal, the file retired once, no turn, no spawn."""
    monkeypatch.setenv("CONSULT_STATE_ROOT", str(tmp_path / "state"))

    bad_cases = [
        (dict(ASK_SINGLE, event="question"), "event is not 'ask'"),
        (dict(ASK_SINGLE, role="Boss"), "invalid role 'Boss'"),
        (dict(ASK_SINGLE, mode="any"), "invalid mode 'any'"),
        (dict(ASK_SINGLE, options=[
            {"id": "a", "label": "l", "description": "d", "recommended": False},
            {"id": "a", "label": "l2", "description": "d2", "recommended": False},
        ], default=[]), "duplicate option id 'a'"),
        (dict(ASK_SINGLE, options=[
            {"id": "a", "label": "l", "description": "d", "recommended": True},
            {"id": "b", "label": "l2", "description": "d2", "recommended": True},
        ], default=[]), "more than one recommended option for single mode"),
        (dict(ASK_SINGLE, options=[
            {"id": "a", "label": "l", "description": "d", "recommended": "yes"},
        ], default=[]), "option 'a' recommended is not boolean"),
        (dict(ASK_SINGLE, default=["nope"]), "default ids not in options"),
        ("this is prose, not json", "not an object"),
    ]

    async def run():
        app = ProductTeamApp()
        async with app.run_test(size=(80, 24)) as pilot:
            await _boot_home(pilot, app)
            for i, (event, reason) in enumerate(bad_cases):
                before = app.transcript_text()
                app._provider_active = True
                app._active_artifact = str(
                    tmp_path / f"case-{i}" / "artifacts" / "a.txt")
                _write_ask(app, event)
                ok = await _ask_wait(
                    pilot,
                    lambda: (Path(app._active_artifact).parent / "ask.json.invalid").is_file(),
                )
                assert ok, f"invalid ask must be retired: {reason}"
                assert not app.dock_visible(), f"no dock for invalid ask: {reason}"
                assert app._dock_kind == "slash"
                delta = app.transcript_text()[len(before):]
                assert f"ask ignored: {reason}" in delta, (
                    f"one honest refusal for: {reason!r} — got {delta!r}"
                )
                assert "Where should each role's color appear?" not in delta, (
                    f"no fake question for: {reason}"
                )
                assert "▸ Builder" not in delta
                assert (Path(app._active_artifact).parent / "ask.json").exists() is False

            # raw prose that is not valid JSON at all: still one refusal, no dock
            before = app.transcript_text()
            app._provider_active = True
            app._active_artifact = str(tmp_path / "case-prose" / "artifacts" / "a.txt")
            art_dir = Path(app._active_artifact).parent
            art_dir.mkdir(parents=True, exist_ok=True)
            (art_dir / "ask.json").write_text(
                "where should colors go? this is prose, not json", encoding="utf-8"
            )
            ok = await _ask_wait(pilot, lambda: (art_dir / "ask.json.invalid").is_file())
            assert ok, "raw prose ask retired as invalid"
            assert not app.dock_visible()
            delta = app.transcript_text()[len(before):]
            assert "ask ignored:" in delta, f"one honest refusal for prose: {delta!r}"
            assert "where should colors go?" not in delta, "prose never becomes a question"

    asyncio.run(run())


def test_composer_width_visible_in_dock_states(tmp_path, monkeypatch):
    """D01: the role prefix is bounded so the composer keeps a materially
    visible width in every dock state (slash, ask, confirm) at 80 and 40 —
    it must never collapse to the off-screen 2-column sliver."""
    monkeypatch.setenv("CONSULT_STATE_ROOT", str(tmp_path / "state"))

    async def run():
        app = ProductTeamApp()
        async with app.run_test(size=(80, 24)) as pilot:
            await _boot_home(pilot, app)
            composer = app.query_one("#composer")
            assert composer.region.width >= 20, f"idle composer too narrow: {composer.region.width}"
            # slash state
            await pilot.press("/")
            await pilot.pause()
            assert app.dock_visible() and app._dock_kind == "slash"
            assert composer.region.width >= 20, "composer too narrow with slash dock"
            await pilot.press("escape")
            await pilot.pause()
            assert not app.dock_visible(), "Esc closes the slash dock"
            # Esc keeps the typed "/" in the composer; clear it like a user
            # would before the next command.
            await pilot.press("backspace")
            await pilot.pause()
            assert app.composer.text == "", "composer cleared for the next command"
            # ask state (file-backed seam)
            app._provider_active = True
            app._active_artifact = str(tmp_path / "ask" / "artifacts" / "a.txt")
            _write_ask(app, ASK_SINGLE)
            ok = await _ask_wait(pilot, lambda: app._dock_kind == "ask")
            assert ok, "ask dock opened"
            assert composer.region.width >= 20, "composer too narrow with ask dock"
            await pilot.press("escape")
            await pilot.pause()
            # confirm state (real registry: gh is a supported verb)
            await pilot.press(*list("/gh merge"))
            await pilot.press("enter")
            await pilot.pause()
            assert app._dock_kind == "confirm" and app.dock_visible()
            assert composer.region.width >= 20, "composer too narrow with confirm dock"
            await pilot.press("escape")
            await pilot.pause()
            assert not app.dock_visible(), "Esc closes the confirm dock"
            # 40 columns keeps the same guarantee
            await pilot.resize_terminal(40, 20)
            await pilot.pause(0.25)
            assert composer.region.width >= 20, (
                f"composer too narrow at 40 columns: {composer.region.width}"
            )
            await pilot.press(*list("/gh merge"))
            await pilot.press("enter")
            await pilot.pause()
            assert app._dock_kind == "confirm" and app.dock_visible()
            assert composer.region.width >= 20, (
                f"composer too narrow at 40 columns with confirm dock: {composer.region.width}"
            )
            await pilot.press("escape")
            await pilot.pause()

    asyncio.run(run())


# ── iter-7: evidence dock, Command rail, attached completion card ────

def _all_spans(app):
    """[(span_text, style_str)] across the whole transcript (styled runs
    only — unstyled body text has no span, mirroring _turn_has_hue)."""
    out = []
    for strip in app.transcript.lines:
        for seg in strip:
            out.append((seg.text, str(seg.style) if seg.style else ""))
    return out


def test_provider_speech_markdown_and_attached_done_card(tmp_path, monkeypatch):
    """D10/D14: native owned-speaking markdown-lite snapshot (heading,
    +/-, evidence path, plain body, fence) on the Builder rail with exactly
    one body copy, then one attached done card that never replays it."""
    monkeypatch.setenv("CONSULT_STATE_ROOT", str(tmp_path / "state"))

    async def run():
        app = ProductTeamApp()
        async with app.run_test(size=(80, 24)) as pilot:
            await _boot_home(pilot, app)
            now = int(time.time())
            _write_activity_rows(
                app, [("1", "Analyst", "running", "research", "claude", now, "0", "")]
            )
            await pilot.pause(0.3)
            before = app.transcript_text()
            assert "Thinking…" not in before
            assert "◇ Analyst" not in before, "activity strip never enters the transcript"
            # Capture the exact styled Texts handed to the RichLog: the
            # segment renderer merges adjacent same-style runs (BUILDER and
            # OK share the same locked hex) and inherits the rail's default
            # style over unstyled runs, so neutral-body proof reads the
            # write boundary while +/-, heading, evidence, fence, and the
            # card stay observable on the painted segments too.
            writes = []
            orig_write = app.transcript.write

            def recording(renderable, *a, **k):
                writes.append(renderable)
                return orig_write(renderable, *a, **k)

            app.transcript.write = recording
            app._active_turn_role = "Builder"
            app._append_provider_chunk(
                "# Done when\n"
                "+keep composer\n"
                "-dump status\n"
                "lib/tui/app.py: rail stays 2px\n"
                "plain body\n"
            )
            app._append_provider_chunk("```fence\ninside\n```\n")
            await pilot.pause()
            delta = app.transcript_text()[len(before):]
            assert delta.count("plain body") == 1, "one body copy"
            assert delta.count("▸ Builder") == 1, "speech opens one Builder rail"
            assert "Done when" in delta and "keep composer" in delta
            assert "dump status" in delta and "rail stays 2px" in delta
            assert "inside" in delta and "```" in delta
            assert _turn_has_hue(app, "▸ Builder", BUILDER), (
                "speaking rail carries the Builder identity hue")
            spans = _all_spans(app)
            # heading: bold + OK
            assert ("  Done when", "bold " + OK) in spans, (
                "heading payload is bold + OK")
            # leading +/- diff markers: OK / ERR (locked _DIFF_RE shapes)
            assert ("  +", OK) in spans, "plus diff marker is OK"
            assert ("  -", ERR) in spans, "minus diff marker is ERR"
            # evidence line: bold path + mute `: text` (the bold path carries
            # the rail's default hue on the painted segment)
            assert ("  lib/tui/app.py", "bold " + BUILDER) in spans, (
                "evidence path is bold on the rail")
            assert (": rail stays 2px", MUTE) in spans, "evidence text is mute"
            # fence markers mute
            assert ("  ```", MUTE) in spans, "fence marker is mute"
            # plain and fenced body are written unstyled — markdown-lite
            # never paints them OK/ERR/role-hued
            for w in writes:
                for sp in w.spans:
                    covered = w.plain[sp.start:sp.end]
                    assert "plain body" not in covered, (
                        "plain body must carry no style span")
                    assert "inside" not in covered, (
                        "fenced body must carry no style span")
            fence_markers = [
                covered for w in writes
                for sp in w.spans
                if (covered := w.plain[sp.start:sp.end]) == "  ```"
            ]
            assert len(fence_markers) == 2, "both fence markers are styled mute"
            # done: one attached card, no body replay, no toast
            app._provider_done(0, str(tmp_path / "w12.txt"))
            await pilot.pause()
            delta = app.transcript_text()[len(before):]
            assert delta.count("plain body") == 1, "done card never replays the body"
            assert "✓ done" in delta, "card carries the done status"
            assert ("✓ done", OK) in _all_spans(app), "done status is OK-hued"
            assert ("▸ Builder", "bold " + BUILDER) in _all_spans(app), (
                "card rides the Builder rail (active bold)")
            assert "w12.txt" in delta, "card names the artifact"
            assert app._toasts == [], "a clean done writes no toast"

    asyncio.run(run())


def test_evidence_dock_caps_composer_focus_and_keys(tmp_path, monkeypatch):
    """D01/D12: the evidence dock stays above the composer at 80 and 40,
    caps 6 wide / 3 compact with a mute +N row, keeps the composer >= 20,
    and Space/Tab/Enter/Esc never run or spawn anything."""
    monkeypatch.setenv("CONSULT_STATE_ROOT", str(tmp_path / "state"))
    paths80 = [f"runs/iter-1/file{i}.txt" for i in range(7)]

    def stream(args, on_line=None, env=None, timeout=60):
        out = "".join(f"  {p}\n" for p in paths80)
        for line in out.splitlines(True):
            if on_line:
                on_line(line)
        return subprocess.CompletedProcess(args, 0, out, "")

    monkeypatch.setattr(adapter, "run_argv_stream", stream)

    async def run():
        app = ProductTeamApp()
        async with app.run_test(size=(80, 24)) as pilot:
            await _boot_home(pilot, app)
            composer = app.query_one("#composer")
            await pilot.press(*list("/report harness-cli"))
            await pilot.press("enter")
            ok = await _ask_wait(pilot, lambda: app._dock_kind == "evidence")
            assert ok, "evidence dock opened"
            dock = app.query_one("#dock")
            assert dock.has_class("evidence"), "evidence border class applied"
            assert dock.region.y + dock.region.height <= composer.region.y, (
                "evidence dock sits above the composer")
            assert composer.region.width >= 20, (
                f"composer too narrow with evidence dock: {composer.region.width}")
            assert app.focused is app.composer, "composer keeps focus"
            assert str(app.query_one("#footer").render()) == "↑↓ · esc close"
            # wide cap: label + 6 paths + mute +1
            assert dock.option_count == 8
            label = dock.get_option_at_index(0).prompt
            assert label.plain == "evidence · 7 files"
            assert all(str(s.style) == MUTE for s in label.spans), (
                "label row is mute chrome")
            assert dock.get_option_at_index(7).prompt.plain == "+1"
            row1 = dock.get_option_at_index(1).prompt
            assert row1.plain == "runs/iter-1/file0.txt"
            assert any(
                "runs/iter-1/file0.txt" in row1.plain[s.start:s.end]
                and s.style == "bold"
                for s in row1.spans
            ), "evidence path row is bold"
            # Space/Tab are no-ops while the evidence dock is open
            await pilot.press("space")
            await pilot.pause()
            assert composer.text == "", "Space must not type into the composer"
            await pilot.press("tab")
            await pilot.pause()
            assert composer.text == "", "Tab must not complete or move focus"
            # arrows highlight only
            await pilot.press("down")
            await pilot.pause()
            assert dock.highlighted == 1
            await pilot.press("down")
            await pilot.pause()
            assert dock.highlighted == 2
            # Esc closes and restores focus
            await pilot.press("escape")
            await pilot.pause()
            assert not dock.has_class("visible") and app._dock_kind == "slash"
            assert not dock.has_class("evidence"), "evidence class removed on close"
            assert app.focused is app.composer
            # compact: 40 columns caps at 3 paths + +4 and keeps composer >= 20
            await pilot.resize_terminal(40, 20)
            await pilot.pause(0.25)
            await pilot.press(*list("/report harness-cli"))
            await pilot.press("enter")
            ok = await _ask_wait(pilot, lambda: app._dock_kind == "evidence")
            assert ok, "evidence dock reopened at 40 columns"
            assert composer.region.width >= 20, (
                f"composer too narrow at 40 columns with evidence dock: "
                f"{composer.region.width}")
            assert dock.option_count == 5, "compact cap: label + 3 paths + +4"
            assert dock.get_option_at_index(0).prompt.plain == "evidence · 7 files"
            assert dock.get_option_at_index(4).prompt.plain == "+4"
            assert dock.region.y + dock.region.height <= composer.region.y
            # Enter closes (never spawns, never submits)
            await pilot.press("enter")
            await pilot.pause()
            assert not dock.has_class("visible") and app._dock_kind == "slash"
            assert app.focused is app.composer

    asyncio.run(run())


def test_command_rail_mute_no_role_hues(tmp_path, monkeypatch):
    """D11/D21: a supported /status streams as exactly one mute Command turn
    — rail, label, and timestamp carry no role hue — and the unsupported
    refuse stays mute too."""
    monkeypatch.setenv("CONSULT_STATE_ROOT", str(tmp_path / "state"))

    def stream(args, on_line=None, env=None, timeout=60):
        out = "Product Consulting Harness\n  harness-cli · Directive · 9.5\n"
        for line in out.splitlines(True):
            if on_line:
                on_line(line)
        return subprocess.CompletedProcess(args, 0, out, "")

    monkeypatch.setattr(adapter, "run_argv_stream", stream)

    async def run():
        app = ProductTeamApp()
        async with app.run_test(size=(80, 24)) as pilot:
            await _boot_home(pilot, app)
            before = app.transcript_text()
            await pilot.press(*list("/status"))
            await pilot.press("enter")
            ok = await _ask_wait(
                pilot, lambda: "│ Command" in app.transcript_text()[len(before):])
            assert ok, "slash echo opens the Command rail"
            ok = await _ask_wait(pilot, lambda: not app._cli_busy)
            assert ok, "stream finished"
            delta = app.transcript_text()[len(before):]
            assert delta.count("│ Command") == 1, "one Command open per turn"
            assert "Product Consulting Harness" in delta, "streamed summary is Command"
            for hue in (PRINCIPAL, ANALYST, BUILDER, CRITIC, YOU):
                assert not _turn_has_hue(app, "Command", hue), (
                    f"Command label must stay mute, got {hue}")
            assert _turn_has_hue(app, "Command", MUTE), (
                "Command label strip is mute chrome")
            rails = [s for t, s in _all_spans(app) if t == "│"]
            assert rails and all(s == MUTE for s in rails), (
                "every Command rail strip is mute")
            # unsupported refuse continues the mute rail (no role hue)
            before2 = app.transcript_text()
            await pilot.press(*list("/gate"))
            await pilot.press("enter")
            ok = await _ask_wait(
                pilot,
                lambda: "use the CLI: productteam gate"
                in app.transcript_text()[len(before2):],
            )
            assert ok, "refuse prints the registry usage"
            assert "owner-gated durable decisions" in app.transcript_text()[len(before2):]
            assert "Directive: no directive" not in app.transcript_text()[len(before2):]
            for hue in (PRINCIPAL, ANALYST, BUILDER, CRITIC, YOU):
                assert not _turn_has_hue(app, "use the CLI", hue), (
                    f"refuse must stay mute, got {hue}")

    asyncio.run(run())


# ── iter-8: TUI-owned boot splash (D16/D26) ─────────────────────────
# The splash tests delete CONSULT_NO_SPLASH before app creation so the
# boot overlay shows (the module-level setdefault keeps every other row
# on the idle home). All stepper timing is driven by direct
# _splash_advance() calls — never wall-clock waits — and the production
# 0.4s interval is stopped first so a tick can never race an assertion.

BANNED_SPLASH_NEEDLES = (
    "▣───────",
    "6 people",
    "14 links",
    "shared evidence graph",
    "Product Consulting Harness",
    "Product Judgment Layer",
    "▄██▄",
    "█ ██ █",
    "█▄▄▄▄█",
    "▐▌▐▌",
    "◉",
    "Critic",
)


def _splash_spans(app):
    """[(span_text, hex_or_empty)] across the #splash widget's displayed
    visual — the same span walk the provider/done-card tests run on the
    transcript, but against the widget's own rendered content."""
    text = app.splash.render()
    out = []
    for span in text.spans:
        color = ""
        if span.style is not None and span.style.foreground is not None:
            color = (span.style.foreground.hex6 or "").lower()
        out.append((text.plain[span.start:span.end], color))
    return out


def _splash_deterministic(app):
    """Neutralize the production 0.4s glow interval before the app mounts
    (its ticks capture this no-op), so no wall-clock tick can race the
    assertions on this machine. The stepper is then driven step-by-step
    with the real ProductTeamApp._splash_advance(app) and the interval is
    stopped once the app is inside run_test."""
    app._splash_advance = lambda: None  # no-op captured by set_interval


def test_splash_idle_neutral_and_exact_art(monkeypatch):
    """D16: boot shows the idle splash — the exact 11x7 three-head art
    with the 39-column wide join at 80, every head/subtitle span MUTE and
    the brand TEXT (no identity hue, no OK/ERR, no banned graph/ROBOTS/
    Critic needle anywhere), composer + footer visible, `enter continue ·
    any key skip` footer, @Principal prefix, and the art never enters the
    transcript."""
    monkeypatch.delenv("CONSULT_NO_SPLASH", raising=False)

    async def run():
        app = ProductTeamApp()
        _splash_deterministic(app)
        async with app.run_test(size=(80, 24)) as pilot:
            if app._splash_timer is not None:
                app._splash_timer.stop()
            assert app._splash_active and app._splash_step == 0, "idle is step 0"
            splash = app.splash
            assert splash.has_class("visible"), "splash visible at boot"
            assert not splash.can_focus, "splash is not focusable"
            assert splash.region.width > 0 and splash.region.height > 0
            assert app.transcript.has_class("splashed"), "transcript hidden under splash"
            # chrome stays mounted and visible below the splash
            composer = app.composer
            footer = app.query_one("#footer", Static)
            assert composer.region.width >= 20, (
                f"composer too narrow under the splash: {composer.region.width}")
            assert composer.region.height > 0
            assert footer.region.height == 1 and footer.region.width > 0
            assert "@" not in str(app.query_one("#role-prefix", Static).render())
            assert str(footer.render()) == "enter continue · any key skip"
            # exact art: 39-column wide join of the three 11-column heads
            text = splash.render()
            lines = text.plain.splitlines()
            assert len(lines) == 10, f"splash must be 10 lines: {lines!r}"
            joined = [
                (" " * SPLASH_GAP_WIDE).join(SPLASH_HEADS[r][row] for r in SPLASH_ROLES)
                for row in range(7)
            ]
            assert all(len(row) == 39 for row in joined), "wide join is 39 columns"
            assert lines[0] == "     |             |             |     "
            assert lines[0] == joined[0]
            assert lines[1] == "    /^\\           /^\\           /^\\    "
            assert lines[5] == "     #             o             >     "
            assert lines[6] == " Principal      Analyst       Builder  "
            assert lines[7] == ""
            assert lines[8] == "ProductTeam"
            assert lines[9] == "principal · analyst · builder"
            # idle spans: heads + subtitle MUTE, brand TEXT, nothing else
            spans = _splash_spans(app)
            assert ("ProductTeam", TEXT) in spans
            assert ("principal · analyst · builder", MUTE) in spans
            for covered, color in spans:
                assert color in (MUTE, TEXT), (
                    f"idle must be neutral, got {color} on {covered!r}")
            for hue in (PRINCIPAL, ANALYST, BUILDER, CRITIC, YOU, OK, ERR):
                assert hue not in [c for _cov, c in spans], (
                    f"idle must not use {hue}")
            # the unique splash needle is on the widget, never in the transcript
            assert "/^\\" in text.plain, "angular head needle present in the splash"
            assert "/^\\" not in app.transcript_text(), (
                "splash art must never enter the transcript")
            for needle in BANNED_SPLASH_NEEDLES:
                assert needle not in text.plain, f"banned needle in splash: {needle!r}"
                assert needle not in app.transcript_text(), (
                    f"banned needle in transcript: {needle!r}")

    asyncio.run(run())


def test_splash_stepper_glow_order_one_ok_head(monkeypatch):
    """D16: the stepper glows exactly one head at a time in the locked
    order Principal → Analyst → Builder → Principal (cycle wrap), each
    with the exact live subtitle in OK while the other two heads stay
    MUTE — observed on the widget's displayed spans."""
    monkeypatch.delenv("CONSULT_NO_SPLASH", raising=False)
    distinct = {
        "Principal": ("     #     ", " Principal "),
        "Analyst": ("     o     ", "  Analyst  "),
        "Builder": ("     >     ", "  Builder  "),
    }

    async def run():
        app = ProductTeamApp()
        _splash_deterministic(app)
        async with app.run_test(size=(80, 24)) as pilot:
            if app._splash_timer is not None:
                app._splash_timer.stop()
            for step, role in enumerate(
                ("Principal", "Analyst", "Builder", "Principal"), start=1
            ):
                ProductTeamApp._splash_advance(app)
                assert app._splash_step == step and app._splash_active
                spans = _splash_spans(app)
                ok = [(cov, color) for cov, color in spans if color == OK]
                # exactly one head (7 rows) + the live subtitle are OK
                assert len(ok) == 8, (
                    f"step {step}: expected one head + subtitle OK, got {ok!r}")
                assert (f"{GLYPHS[role]} {role}", OK) in ok, (
                    f"step {step}: live subtitle identifies {role}")
                foot, label = distinct[role]
                assert (foot, OK) in ok and (label, OK) in ok
                for other in SPLASH_ROLES:
                    if other != role:
                        ofoot, olabel = distinct[other]
                        assert (ofoot, MUTE) in spans and (olabel, MUTE) in spans, (
                            f"step {step}: {other} must stay MUTE")
                assert ("principal · analyst · builder", MUTE) not in spans
                assert app.splash.has_class("visible"), "still glowing at step"

    asyncio.run(run())


def test_splash_natural_finish_home_and_focus(monkeypatch):
    """L1/D01: the splash never auto-finishes — the glow stepper wraps
    Principal → Analyst → Builder → Principal forever; Enter (continue)
    finishes it, the seeded home shows (never splash art), the idle footer
    returns, composer focus restores; a further advance after the finish
    is a no-op."""
    monkeypatch.delenv("CONSULT_NO_SPLASH", raising=False)

    async def run():
        app = ProductTeamApp()
        _splash_deterministic(app)
        async with app.run_test(size=(80, 24)) as pilot:
            if app._splash_timer is not None:
                app._splash_timer.stop()
            for _ in range(6):
                ProductTeamApp._splash_advance(app)
            await pilot.pause()
            assert app._splash_active, (
                "the splash must persist past the old fifth tick")
            assert app._splash_step == 2, (
                f"glow wraps 1..4, got step {app._splash_step}")
            assert app.splash.has_class("visible")
            assert app.transcript.has_class("splashed")
            await pilot.press("enter")
            await pilot.pause()
            assert not app._splash_active
            assert not app.splash.has_class("visible")
            assert not app.transcript.has_class("splashed")
            assert str(app.query_one("#footer", Static).render()) == (
                "enter send · / commands · tab agents"
            )
            assert app.focused is app.composer, "finish restores composer focus"
            home = await _boot_home(pilot, app)
            assert HOME_ROW_RE.search(home) or "No scored sessions yet" in home
            assert "/^\\" not in app.transcript_text(), (
                "finish leaves no splash art in the transcript")
            # the finished splash is idempotent: further advances do nothing
            ProductTeamApp._splash_advance(app)
            assert not app._splash_active
            assert not app.splash.has_class("visible")
            assert "/^\\" not in app.transcript_text()

    asyncio.run(run())


def test_splash_enter_skips_no_submit(monkeypatch):
    """D16/D18: Enter during the splash skips it — no You turn, no
    provider spawn, composer empty, idle footer restored."""
    monkeypatch.delenv("CONSULT_NO_SPLASH", raising=False)

    async def run():
        app = ProductTeamApp()
        async with app.run_test(size=(80, 24)) as pilot:
            assert app._splash_active
            await pilot.press("enter")
            await pilot.pause()
            assert not app._splash_active
            assert not app.splash.has_class("visible")
            assert not app.transcript.has_class("splashed")
            assert app.composer.text == "", "enter is consumed, never submitted"
            assert app._turns == [], "no You turn and no provider spawn"
            assert app.focused is app.composer
            assert str(app.query_one("#footer", Static).render()) == (
                "enter send · / commands · tab agents"
            )

    asyncio.run(run())


def test_splash_slash_skips_second_slash_opens_dock(monkeypatch):
    """D11/D16: `/` during the splash skips it without opening the slash
    dock or typing the slash; a second `/` after the skip opens the dock
    exactly as today."""
    monkeypatch.delenv("CONSULT_NO_SPLASH", raising=False)

    async def run():
        app = ProductTeamApp()
        async with app.run_test(size=(80, 24)) as pilot:
            assert app._splash_active
            await pilot.press("/")
            await pilot.pause()
            assert not app._splash_active
            assert not app.splash.has_class("visible")
            assert not app.dock.has_class("visible"), "the skip key never opens a dock"
            assert app.composer.text == "", "the skip key is consumed, never typed"
            await pilot.press("/")
            await pilot.pause()
            assert app.dock.has_class("visible"), "a real / opens the slash dock"
            assert app._dock_kind == "slash"
            assert app.composer.text == "/"
            await pilot.press("escape")
            await pilot.pause()
            assert not app.dock.has_class("visible")

    asyncio.run(run())


def test_splash_escape_skips(monkeypatch):
    """D16: Esc during the splash skips it — no dock, idle footer (never
    an ask/confirm/evidence footer)."""
    monkeypatch.delenv("CONSULT_NO_SPLASH", raising=False)

    async def run():
        app = ProductTeamApp()
        async with app.run_test(size=(80, 24)) as pilot:
            assert app._splash_active
            await pilot.press("escape")
            await pilot.pause()
            assert not app._splash_active
            assert not app.splash.has_class("visible")
            assert not app.dock.has_class("visible"), "esc never opens a dock"
            assert app._dock_kind == "slash"
            footer = str(app.query_one("#footer", Static).render())
            assert footer == "enter send · / commands · tab agents", footer

    asyncio.run(run())


def test_splash_any_key_skips_consumed(monkeypatch):
    """R7: any key skips the splash — a printable letter is consumed, not
    typed into the composer, and spawns nothing."""
    monkeypatch.delenv("CONSULT_NO_SPLASH", raising=False)

    async def run():
        app = ProductTeamApp()
        async with app.run_test(size=(80, 24)) as pilot:
            assert app._splash_active
            await pilot.press("x")
            await pilot.pause()
            assert not app._splash_active
            assert not app.splash.has_class("visible")
            assert app.composer.text == "", "printable skip key is consumed, never typed"
            assert app._turns == [], "skip spawns no turn and no provider"
            assert str(app.query_one("#footer", Static).render()) == (
                "enter send · / commands · tab agents"
            )

    asyncio.run(run())


def test_splash_env_short_circuit(monkeypatch):
    """D26: a non-empty CONSULT_NO_SPLASH boots straight to the idle
    cockpit — #splash never shows, home seeds, the footer is idle, and
    `/` opens the dock immediately."""
    monkeypatch.setenv("CONSULT_NO_SPLASH", "1")

    async def run():
        app = ProductTeamApp()
        async with app.run_test(size=(80, 24)) as pilot:
            await pilot.pause()
            assert not app._splash_active, "env bypass never starts the splash"
            assert not app.splash.has_class("visible")
            assert app._splash_timer is None
            assert app._splash_step == 0
            assert str(app.query_one("#footer", Static).render()) == (
                "enter send · / commands · tab agents"
            )
            assert app.focused is app.composer
            await _boot_home(pilot, app)
            await pilot.press("/")
            await pilot.pause()
            assert app.dock.has_class("visible"), "/ opens the dock without a splash"

    asyncio.run(run())


def test_splash_compact_40x20_does_not_cover(monkeypatch):
    """D07/D01: at 40x20 the splash shows the 35-column compact join and
    never covers the composer (splash bottom <= composer top); the
    composer stays >= 20 wide, the footer stays visible, and skip still
    works."""
    monkeypatch.delenv("CONSULT_NO_SPLASH", raising=False)

    async def run():
        app = ProductTeamApp()
        _splash_deterministic(app)
        async with app.run_test(size=(40, 20)) as pilot:
            if app._splash_timer is not None:
                app._splash_timer.stop()
            assert app._splash_active
            splash = app.splash
            composer = app.composer
            footer = app.query_one("#footer", Static)
            assert splash.has_class("visible")
            assert composer.region.width >= 20, (
                f"composer too narrow at 40 cols: {composer.region.width}")
            assert composer.region.height > 0
            assert footer.region.height == 1 and footer.region.width > 0
            assert str(footer.render()) == "enter continue · any key skip"
            assert splash.region.y + splash.region.height <= composer.region.y, (
                "the splash must never cover the composer")
            # the widget shows the compact 35-column join, not the wide 39
            text = splash.render()
            lines = text.plain.splitlines()
            compact = (" " * SPLASH_GAP_COMPACT).join(
                SPLASH_HEADS[r][0] for r in SPLASH_ROLES)
            assert len(compact) == 35, "compact join is 35 columns"
            assert lines[0] == compact, lines[0]
            assert lines[0] == "     |           |           |     "
            # skip still works at compact
            await pilot.press("enter")
            await pilot.pause()
            assert not app._splash_active
            assert not splash.has_class("visible")

    asyncio.run(run())


def test_splash_no_replay_on_resize(monkeypatch):
    """D16: once skipped, the splash never replays — resizing 80→40→80
    keeps #splash hidden and the stepper dead."""
    monkeypatch.delenv("CONSULT_NO_SPLASH", raising=False)

    async def run():
        app = ProductTeamApp()
        async with app.run_test(size=(80, 24)) as pilot:
            await pilot.press("enter")
            await pilot.pause()
            assert not app._splash_active
            for w, h in ((40, 20), (80, 24)):
                await pilot.resize_terminal(w, h)
                await pilot.pause(0.25)
                assert not app.splash.has_class("visible"), (
                    f"resize to {w}x{h} must not replay the splash")
                assert not app._splash_active
                assert not app.transcript.has_class("splashed")
                assert app.focused is app.composer

    asyncio.run(run())


def test_splash_cli_separation(monkeypatch):
    """D26: /splash stays a real CLI Command turn (▣ graph) after boot —
    it never reopens the #splash widget and never re-runs the boot
    stepper."""
    monkeypatch.setenv("CONSULT_NO_SPLASH", "1")

    def stream(args, on_line=None, env=None, timeout=60):
        out = "▣─────── 6 people 14 links\nshared evidence graph\n"
        for line in out.splitlines(True):
            if on_line:
                on_line(line)
        return subprocess.CompletedProcess(args, 0, out, "")

    monkeypatch.setattr(adapter, "run_argv_stream", stream)

    async def run():
        app = ProductTeamApp()
        async with app.run_test(size=(80, 24)) as pilot:
            await _boot_home(pilot, app)
            assert not app._splash_active
            assert not app.splash.has_class("visible")
            before = len(app._turns)
            await pilot.press(*list("/splash"))
            await pilot.press("enter")
            ok = await _ask_wait(
                pilot, lambda: len(app._turns) > before and not app._cli_busy)
            assert ok, "/splash must stream its CLI graph as a Command turn"
            delta = app._turns[before:]
            assert any(kind == "cli" and "▣" in text for kind, text in delta), delta
            assert not app.splash.has_class("visible"), "/splash never reopens #splash"
            assert not app._splash_active, "no second boot splash"
            assert app._splash_timer is None
            await pilot.pause(0.25)
            assert not app.splash.has_class("visible")

    asyncio.run(run())


def test_splash_ctrl_c_skips_no_exit_130(monkeypatch):
    """D16/D29: Ctrl+C during the boot splash skips it instead of exiting
    with 130 — the app stays running on the idle cockpit."""
    monkeypatch.delenv("CONSULT_NO_SPLASH", raising=False)

    async def run():
        app = ProductTeamApp()
        async with app.run_test(size=(80, 24)) as pilot:
            assert app._splash_active
            await pilot.press("ctrl+c")
            await pilot.pause()
            assert app.is_running, "ctrl+c during splash must not exit the app"
            assert not app._splash_active
            assert not app.splash.has_class("visible")
            assert not app.transcript.has_class("splashed")
            assert app.composer.text == ""
            assert str(app.query_one("#footer", Static).render()) == (
                "enter send · / commands · tab agents"
            )

    asyncio.run(run())


def test_splash_ctrl_q_skips_no_exit(monkeypatch):
    """R7/D29: ctrl+q is Textual's priority quit binding, so it would
    bypass the composer's consume — during the boot splash it must skip
    like any key and never exit the app."""
    monkeypatch.delenv("CONSULT_NO_SPLASH", raising=False)

    async def run():
        app = ProductTeamApp()
        async with app.run_test(size=(80, 24)) as pilot:
            assert app._splash_active
            await pilot.press("ctrl+q")
            await pilot.pause()
            assert app.is_running, "ctrl+q during splash must not exit the app"
            assert not app._splash_active
            assert not app.splash.has_class("visible")
            assert not app.transcript.has_class("splashed")
            assert app.composer.text == ""
            assert str(app.query_one("#footer", Static).render()) == (
                "enter send · / commands · tab agents"
            )

    asyncio.run(run())


def test_splash_ctrl_q_after_skip_exits_normally(monkeypatch):
    """D29: once the splash is gone, ctrl+q keeps Textual's normal quit
    behavior (return code 0) — the boot guard never weakens quit."""
    monkeypatch.delenv("CONSULT_NO_SPLASH", raising=False)

    async def run():
        app = ProductTeamApp()
        async with app.run_test(size=(80, 24)) as pilot:
            await pilot.press("enter")
            await pilot.pause()
            assert not app._splash_active
            await pilot.press("ctrl+q")
            await pilot.pause()
            assert app._exit, "ctrl+q after skip must quit the app"
            assert app._return_code == 0, (
                f"normal quit must return 0, got {app._return_code}")

    asyncio.run(run())


def test_splash_ctrl_p_palette_guard(monkeypatch):
    """R7: Textual installs ctrl+p as a priority command-palette binding,
    so it would bypass the composer's splash consume — during the boot
    splash it must skip like any key instead of opening the palette."""
    monkeypatch.delenv("CONSULT_NO_SPLASH", raising=False)

    async def run():
        app = ProductTeamApp()
        async with app.run_test(size=(80, 24)) as pilot:
            assert app._splash_active
            await pilot.press("ctrl+p")
            await pilot.pause()
            assert app.is_running
            assert not app._splash_active
            assert not app.splash.has_class("visible")
            assert not CommandPalette.is_open(app), (
                "ctrl+p must not open the command palette during splash")
            assert app.composer.text == ""
            assert str(app.query_one("#footer", Static).render()) == (
                "enter send · / commands · tab agents"
            )

    asyncio.run(run())


# ── iter-1 fidelity locks (L8/L10/L12/L14) ──────────────────────────

def test_home_row_lock_shape():
    """L8: each scored home row is exactly `● {client} …… {score:.1f}` —
    bullet, name, leader dots, score last; no iter/trend metadata."""
    app = ProductTeamApp()
    assert app._home_row({"client": "harness-cli", "overall": 9.5}).plain == (
        "● harness-cli …… 9.5")
    assert app._home_row({"client": "agcode-learning", "overall": 8.3}).plain == (
        "● agcode-learning …… 8.3")


def test_compact_chips_single_plus_count(tmp_path, monkeypatch):
    """L12: at 40 columns exactly one identity chip renders with the
    hidden count (`◆ Principal +3`); 80 columns restores all four."""
    monkeypatch.setenv("CONSULT_STATE_ROOT", str(tmp_path / "state"))

    async def run():
        app = ProductTeamApp()
        async with app.run_test(size=(40, 20)) as pilot:
            for _ in range(300):
                if app.transcript_text():
                    break
                await pilot.pause()
            visible = [
                r for r in ("principal", "analyst", "builder", "critic")
                if str(app.query_one(f"#role-{r}", Static).styles.display) != "none"
            ]
            assert visible == ["principal"], visible
            assert str(app.query_one("#role-principal", Static).render()).strip() == (
                "◆ Principal +3")
            await pilot.resize_terminal(80, 24)
            await pilot.pause(0.25)
            visible = [
                r for r in ("principal", "analyst", "builder", "critic")
                if str(app.query_one(f"#role-{r}", Static).styles.display) != "none"
            ]
            assert visible == ["principal", "analyst", "builder", "critic"], visible
            assert "+3" not in str(app.query_one("#role-principal", Static).render())

    asyncio.run(run())


def test_chip_done_status_on_chip_and_card(tmp_path, monkeypatch):
    """L14: after a role completes, its chip carries `✓` and the attached
    completion card keeps its `✓` status."""
    monkeypatch.setenv("CONSULT_STATE_ROOT", str(tmp_path / "state"))

    async def run():
        app = ProductTeamApp()
        async with app.run_test(size=(80, 24)) as pilot:
            await _boot_home(pilot, app)
            app._active_turn_role = "Builder"
            app._append_provider_chunk("done body\n")
            await pilot.pause()
            app._provider_done(0, str(tmp_path / "w12.txt"))
            await pilot.pause()
            chip = str(app.query_one("#role-builder", Static).render())
            assert "✓" in chip, f"done chip must carry ✓: {chip!r}"
            assert "✓ done" in app.transcript_text(), "card keeps its ✓ status"

    asyncio.run(run())


def test_chip_failed_status_on_chip_and_card(tmp_path, monkeypatch):
    """L14: failure and interrupt both carry the existing `✗ failed`
    language on the role chip and attached completion card."""
    monkeypatch.setenv("CONSULT_STATE_ROOT", str(tmp_path / "state"))

    async def run():
        app = ProductTeamApp()
        async with app.run_test(size=(80, 24)) as pilot:
            await _boot_home(pilot, app)
            for role, rc in (("Builder", 1), ("Analyst", 130)):
                app._active_turn_role = role
                app._provider_done(rc, str(tmp_path / f"{role}.txt"))
                await pilot.pause()
                chip = str(app.query_one(f"#role-{role.lower()}", Static).render())
                assert "✗" in chip, f"failed chip must carry ✗: {chip!r}"
            assert app.transcript_text().count("✗ failed") >= 2, (
                "failure and interrupt cards keep their ✗ status")

    asyncio.run(run())


def test_no_provider_first_run_copy(monkeypatch):
    """L10: an empty `agents --json` paints the locked no-provider
    first-run copy and footer — not the status dump, not the scored-home
    empty copy — even when scored sessions exist."""

    def fake(args, **kw):
        if list(args) == ["agents", "--json"]:
            return subprocess.CompletedProcess(
                args, 0, json.dumps({"agents": [], "installed": []}), "")
        if list(args) == ["status", "--json"]:
            return subprocess.CompletedProcess(args, 0, json.dumps({
                "selected": None,
                "engagements": [
                    {"client": "harness-cli", "scored": True, "overall": 9.5,
                     "last_iter": "iter-1", "trend": "+0.0", "desc": ""},
                ],
            }), "")
        return subprocess.CompletedProcess(args, 0, "", "")

    monkeypatch.setattr(adapter, "run_argv", fake)

    async def run():
        app = ProductTeamApp()
        async with app.run_test(size=(80, 24)) as pilot:
            for _ in range(300):
                if app.transcript_text():
                    break
                await pilot.pause()
            text = app.transcript_text()
            assert "no installed agent" in text, text
            assert "run /agents  or  productteam onboarding" in text, text
            assert "harness-cli" not in text, (
                "scored rows must not seed under the no-provider first-run")
            assert str(app.query_one("#footer", Static).render()) == (
                "/agents · /onboarding · /help")

    asyncio.run(run())
