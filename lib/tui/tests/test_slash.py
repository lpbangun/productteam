# test_slash.py — dock filtering, unsupported refuse (no spawn), usage on
# missing args, and the session-local verbs.

import asyncio
import json
import os
import re
import subprocess
from pathlib import Path

import pytest

import adapter
from app import ProductTeamApp

HOME_ROW_RE = re.compile(r"^\s*(\d+\.\d)\s+(\S+)(.*)$", re.M)

FAKE_HELP = {
    "contract": "cli-interface-20260812-v3",
    "commands": [
        {"name": "help", "usage": "productteam help [--json]", "chat_supported": True},
        {"name": "status", "usage": "productteam status [--json]", "chat_supported": True},
        {"name": "report", "usage": "productteam report <client>", "chat_supported": True},
        {"name": "bench", "usage": "productteam bench <client>", "chat_supported": True},
        {"name": "gate", "usage": "productteam gate <client> status|direct|…",
         "chat_supported": False,
         "chat_reason": "owner-gated durable decisions must leave a durable record"},
        {"name": "chat", "usage": "productteam chat", "chat_supported": False,
         "chat_reason": "nested sessions re-enter the same REPL"},
        {"name": "tui", "usage": "productteam tui", "chat_supported": False,
         "chat_reason": "optional presentation client"},
        {"name": "gh", "usage": "productteam gh preflight", "chat_supported": True},
        {"name": "checks", "usage": "productteam checks", "chat_supported": True},
        {"name": "onboarding", "usage": "productteam onboarding", "chat_supported": True},
    ],
    "chat_only": ["provider", "workers", "clear", "export", "exit", "quit"],
}


def _fake_run_argv(args, env=None, timeout=60):
    if args[:2] == ["help", "--json"]:
        return subprocess.CompletedProcess(args, 0, json.dumps(FAKE_HELP), "")
    if args[:2] == ["status", "--json"]:
        return subprocess.CompletedProcess(
            args, 0,
            json.dumps({"selected": None, "engagements": [
                {"client": "harness-cli", "scored": True, "last_iter": "iter-1",
                 "overall": 9.5},
            ]}),
            "",
        )
    if args == ["status"]:
        return subprocess.CompletedProcess(
            args, 0, "Product Consulting Harness\n  harness-cli · Directive · 9.5\n", "")
    if args[:2] == ["agents", "--json"]:
        return subprocess.CompletedProcess(
            args, 0,
            json.dumps([
                {"name": "agent", "status": "found"},
                {"name": "claude", "status": "found"},
                {"name": "codex", "status": "missing"},
            ]),
            "",
        )
    raise AssertionError(f"unexpected run_argv argv: {args}")


def _fake_stream_usage(args, on_line=None, env=None, timeout=60):
    out = "error: usage: productteam report <client>\n"
    if on_line:
        on_line(out)
    return subprocess.CompletedProcess(args, 1, out, "")


# Real-shaped /report stdout under non-TTY (render_markdown_lite: 2-space
# indent, markers kept). The heading/prose stay Command; the two evidence
# payloads split to the panel.
REPORT_STREAM = (
    "  # harness-cli iter-1 — report\n"
    "  KEEP lib/tui/. Reviewer scored every mandatory dim ≥ 9.0.\n"
    "  lib/tui/app.py: rail stays 2px\n"
    "  runs/iter-1/pytest.txt\n"
)

# Real-shaped /bench stdout under non-TTY: banner, contract, history table,
# then LATEST area rows whose evidence paths sit after the score (rightmost
# mixed) and an overall row ending in scores.json (trailing path token).
BENCH_STREAM = (
    "  Benchmark — harness-cli\n"
    "  Contract harness-cli-v1 · frozen 2026-08-07 · target ≥ 9.0 in every dimension\n"
    "  HISTORY\n"
    "   iter  date        kind        overall\n"
    "  LATEST — iter-1\n"
    "   visual-cli-clarity   9.5  +5.5  lib/theme.py: headings stay ok\n"
    "   overall  9.5   state/engagements/harness-cli/runs/iter-1/scores.json\n"
)


def _fake_stream_report(args, on_line=None, env=None, timeout=60):
    out = REPORT_STREAM
    if on_line:
        for line in out.splitlines(True):
            on_line(line)
    return subprocess.CompletedProcess(args, 0, out, "")


def _fake_stream_bench(args, on_line=None, env=None, timeout=60):
    out = BENCH_STREAM
    if on_line:
        for line in out.splitlines(True):
            on_line(line)
    return subprocess.CompletedProcess(args, 0, out, "")


@pytest.fixture()
def fake_env(monkeypatch, tmp_path):
    adapter.reset_palette()
    monkeypatch.setattr(adapter, "run_argv", _fake_run_argv)
    monkeypatch.setattr(adapter, "run_argv_stream", _fake_stream_usage)
    monkeypatch.delenv("CONSULT_PROVIDER", raising=False)
    monkeypatch.setenv("CONSULT_STATE_ROOT", str(tmp_path / "cli-state"))
    monkeypatch.setenv("CONSULT_NO_SPLASH", "1")
    return tmp_path


async def _wait_for(pilot, predicate, timeout=10.0):
    deadline = asyncio.get_event_loop().time() + timeout
    while asyncio.get_event_loop().time() < deadline:
        if predicate():
            return True
        await pilot.pause()
        await asyncio.sleep(0.02)
    return False


async def _boot(pilot):
    """Wait for the locked home projection: seeded header, then home rows or
    the honest empty copy (the removed prose-status seed is never a needle)."""
    app = pilot.app
    for _ in range(300):
        if "▣─▣─▣ ProductTeam" in str(app.query_one("#header").render()):
            break
        await pilot.pause()
    for _ in range(300):
        text = app.transcript_text()
        if HOME_ROW_RE.search(text) or "No scored sessions yet" in text:
            break
        await pilot.pause()
    app.query_one("#composer").focus()
    await pilot.pause()
    return app


def test_sta_filters_to_status(fake_env):
    async def run():
        async with ProductTeamApp().run_test(size=(80, 24)) as pilot:
            app = await _boot(pilot)
            await pilot.press("/", "s", "t", "a")
            await pilot.pause()
            assert app.dock_visible()
            assert app._dock_verbs == ["status"]
    asyncio.run(run())


def test_gate_refused_without_spawn(fake_env):
    spawns = []

    def stream(args, on_line=None, env=None, timeout=60):
        spawns.append(args)
        return subprocess.CompletedProcess(args, 0, "", "")

    adapter.run_argv_stream = stream

    async def run():
        async with ProductTeamApp().run_test(size=(80, 24)) as pilot:
            app = await _boot(pilot)
            await pilot.press("/", "g", "a", "t", "e")
            await pilot.press("enter")
            ok = await _wait_for(
                pilot, lambda: "use the CLI: productteam gate" in app.transcript_text())
            assert ok, "refuse reason printed"
            assert "owner-gated durable decisions" in app.transcript_text()
            assert "Directive: no directive" not in app.transcript_text()
    asyncio.run(run())
    assert spawns == [], "refuse must not spawn the CLI command"


def test_report_missing_args_prints_usage(fake_env):
    async def run():
        async with ProductTeamApp().run_test(size=(80, 24)) as pilot:
            app = await _boot(pilot)
            await pilot.press("/", "r", "e", "p", "o", "r", "t")
            await pilot.press("enter")
            ok = await _wait_for(
                pilot, lambda: "usage: productteam report <client>" in app.transcript_text())
            assert ok, "usage printed without inventing a client"
            ok = await _wait_for(pilot, lambda: not app._cli_busy)
            assert ok, "usage stream finished"
            await pilot.pause(0.1)
            assert app._dock_kind == "slash", "usage-only report opens no evidence panel"
            assert not app.dock_visible(), "empty evidence buffer paints no labelled chrome"
    asyncio.run(run())


def test_report_stream_evidence_panel(fake_env):
    """D12/D25: a real-shaped /report stream keeps its Command summary
    (iter-1 heading + prose) and splits the two evidence paths into the
    labelled #dock — withheld from the transcript, above the composer,
    arrows highlight only, Enter/Esc close and restore focus."""
    adapter.run_argv_stream = _fake_stream_report

    async def run():
        async with ProductTeamApp().run_test(size=(80, 24)) as pilot:
            app = await _boot(pilot)
            before = app.transcript_text()
            await pilot.press(*list("/report harness-cli"))
            await pilot.press("enter")
            ok = await _wait_for(
                pilot, lambda: app._dock_kind == "evidence" and app.dock_visible())
            assert ok, "report stream opens the evidence dock"
            delta = app.transcript_text()[len(before):]
            assert "iter-1" in delta, "Command summary keeps the report heading"
            assert "KEEP lib/tui/." in delta, "prose summary stays a Command line"
            assert "runs/iter-1/pytest.txt" not in delta, "path withheld from chat"
            assert "lib/tui/app.py" not in delta, "evidence path withheld from chat"
            assert app.dock.get_option_at_index(0).prompt.plain == "evidence · 2 files"
            assert app.dock.get_option_at_index(1).prompt.plain == (
                "lib/tui/app.py: rail stays 2px")
            assert app.dock.get_option_at_index(2).prompt.plain == "runs/iter-1/pytest.txt"
            dock = app.query_one("#dock")
            composer = app.query_one("#composer")
            assert dock.region.y + dock.region.height <= composer.region.y, (
                "evidence dock sits above the composer")
            assert app.focused is app.composer, "composer keeps focus"
            assert str(app.query_one("#footer").render()) == "↑↓ · esc close"
            # arrows highlight only; Enter closes without running anything
            await pilot.press("down")
            await pilot.pause()
            assert app.dock.highlighted == 1
            await pilot.press("down")
            await pilot.pause()
            assert app.dock.highlighted == 2
            await pilot.press("enter")
            await pilot.pause()
            assert not app.dock_visible() and app._dock_kind == "slash"
            assert app.focused is app.composer
            assert "lib/tui/app.py" not in app.transcript_text()[len(before):], (
                "paths never re-enter the transcript after close")

    asyncio.run(run())


def test_bench_stream_evidence_panel(fake_env):
    """D12/D25: a real-shaped /bench stream keeps Benchmark/area/score/overall
    on the Command rail (rightmost-mixed split) and panels the evidence paths
    — never in the transcript, Esc closes and restores focus."""
    adapter.run_argv_stream = _fake_stream_bench

    async def run():
        async with ProductTeamApp().run_test(size=(80, 24)) as pilot:
            app = await _boot(pilot)
            before = app.transcript_text()
            await pilot.press(*list("/bench harness-cli"))
            await pilot.press("enter")
            ok = await _wait_for(
                pilot, lambda: app._dock_kind == "evidence" and app.dock_visible())
            assert ok, "bench stream opens the evidence dock"
            delta = app.transcript_text()[len(before):]
            assert "Benchmark — harness-cli" in delta, "banner stays Command"
            assert "visual-cli-clarity" in delta, "area name stays Command"
            assert "9.5" in delta, "score stays Command"
            assert "overall" in delta, "overall summary stays Command"
            assert "HISTORY" in delta and "LATEST — iter-1" in delta
            assert "lib/theme.py" not in delta, "evidence path withheld from chat"
            assert "scores.json" not in delta, "evidence path withheld from chat"
            assert app.dock.get_option_at_index(0).prompt.plain == "evidence · 2 files"
            assert app.dock.get_option_at_index(1).prompt.plain == (
                "+5.5  lib/theme.py: headings stay ok")
            assert app.dock.get_option_at_index(2).prompt.plain == (
                "state/engagements/harness-cli/runs/iter-1/scores.json")
            dock = app.query_one("#dock")
            composer = app.query_one("#composer")
            assert dock.region.y + dock.region.height <= composer.region.y
            await pilot.press("escape")
            await pilot.pause()
            assert not app.dock_visible() and app._dock_kind == "slash"
            assert app.focused is app.composer

    asyncio.run(run())


def test_provider_sets_session_env(fake_env):
    async def run():
        async with ProductTeamApp().run_test(size=(80, 24)) as pilot:
            app = await _boot(pilot)
            await pilot.press("/", "p", "r", "o", "v", "i", "d", "e", "r")
            await pilot.press("enter")
            ok = await _wait_for(
                pilot,
                lambda: any(m == "provider → agent" and s == "information"
                            for m, s in app._toasts),
            )
            assert ok, "provider toast observed on the session log"
            assert "provider → agent" not in app.transcript_text(), (
                "provider response is a toast, not a transcript line")
            assert os.environ.get("CONSULT_PROVIDER") == "agent"
    asyncio.run(run())


def test_provider_named(fake_env):
    async def run():
        async with ProductTeamApp().run_test(size=(80, 24)) as pilot:
            app = await _boot(pilot)
            keys = list('/provider "claude"')
            await pilot.press(*keys)
            await pilot.press("enter")
            ok = await _wait_for(
                pilot,
                lambda: any(m == "provider → claude" and s == "information"
                            for m, s in app._toasts),
            )
            assert ok, "named provider toast observed on the session log"
            assert "provider → claude" not in app.transcript_text(), (
                "provider response stays out of the transcript")
    asyncio.run(run())


def test_clear_clears_transcript(fake_env):
    async def run():
        async with ProductTeamApp().run_test(size=(80, 24)) as pilot:
            app = await _boot(pilot)
            assert "harness-cli" in app.transcript_text(), "home row seeded from status --json"
            await pilot.press(*list("/status"))
            await pilot.press("enter")
            ok = await _wait_for(
                pilot, lambda: "usage: productteam report" in app.transcript_text())
            assert ok, "status streamed its (fake) output"
            await pilot.press(*list("/clear"))
            await pilot.press("enter")
            await pilot.pause()
            assert app.transcript_text().strip() == ""
    asyncio.run(run())


def test_export_writes_markdown(fake_env):
    async def run():
        async with ProductTeamApp().run_test(size=(80, 24)) as pilot:
            app = await _boot(pilot)
            # A real CLI turn (fake streamed usage output) recorded as a Command.
            await pilot.press(*list("/status"))
            await pilot.press("enter")
            ok = await _wait_for(
                pilot,
                lambda: any(k == "cli" for k, _ in app._turns)
                and "usage: productteam report" in app.transcript_text(),
            )
            assert ok, "a real CLI turn streamed before export"
            await pilot.press(*list("/export"))
            await pilot.press("enter")
            ok = await _wait_for(
                pilot,
                lambda: any(m.startswith("wrote ") and s == "information"
                            for m, s in app._toasts),
            )
            assert ok, "export success toast observed on the session log"
            assert "wrote " not in app.transcript_text(), (
                "export response is a toast, not a transcript line")
    asyncio.run(run())
    exported = list(Path(os.environ["CONSULT_STATE_ROOT"]).glob("sessions/tui-*.md"))
    assert len(exported) == 1
    text = exported[0].read_text()
    assert "# TUI session" in text
    assert "/export" in text
    assert "usage: productteam report" in text, "export must include the streamed CLI turn"


def test_exit_leaves(fake_env):
    async def run():
        async with ProductTeamApp().run_test(size=(80, 24)) as pilot:
            app = await _boot(pilot)
            await pilot.press(*list("/exit"))
            await pilot.press("enter")
            ok = await _wait_for(pilot, lambda: getattr(app, "_exit", False), timeout=5.0)
            assert ok, "app exited via /exit"
            assert app.return_code == 0
    asyncio.run(run())


def _confirm_recorder():
    spawns = []

    def stream(args, on_line=None, env=None, timeout=60):
        spawns.append(args)
        return subprocess.CompletedProcess(args, 0, "", "")

    adapter.run_argv_stream = stream
    return spawns


async def _type_slash(pilot, text):
    await pilot.press(*list(text))


async def _confirm_open(pilot, app):
    assert app._dock_kind == "confirm", "write intercept opens the confirm dock"
    assert app.dock_visible()
    assert str(app.query_one("#footer").render()) == "↑↓ choose · enter run · esc cancel"
    texts = [app.dock.get_option_at_index(i).prompt.plain for i in range(2)]
    assert texts[1] == "Cancel"


def test_confirm_run_exact_argv_for_all_three_intercepts(fake_env):
    """D13: `/gh merge`, `/checks --allow-dirty`, `/onboarding --yes` are
    intercepted exactly; Run reuses the stored original argv list."""
    spawns = _confirm_recorder()

    async def run():
        async with ProductTeamApp().run_test(size=(80, 24)) as pilot:
            app = await _boot(pilot)
            for slash, expected in (
                ("/gh merge", ["gh", "merge"]),
                ("/checks --allow-dirty", ["checks", "--allow-dirty"]),
                ("/onboarding --yes", ["onboarding", "--yes"]),
            ):
                await _type_slash(pilot, slash)
                await pilot.press("enter")
                await pilot.pause()
                await _confirm_open(pilot, app)
                assert app.dock.get_option_at_index(0).prompt.plain == f"Run {slash}"
                await pilot.press("enter")  # Run is default-highlighted
                ok = await _wait_for(pilot, lambda: spawns[-1:] == [expected], timeout=5)
                assert ok, f"Run must execute the exact original argv: {spawns}"
                assert not app.dock_visible(), "confirm dock closes after Run"
                assert app._dock_kind == "slash"

    asyncio.run(run())
    assert spawns == [
        ["gh", "merge"],
        ["checks", "--allow-dirty"],
        ["onboarding", "--yes"],
    ], "argv log must show exactly the three runs, in order"


def test_confirm_cancel_no_spawn(fake_env):
    """D13: choosing Cancel (or Esc) for an intercepted write executes
    nothing — the argv log stays empty for that attempt."""
    spawns = _confirm_recorder()

    async def run():
        async with ProductTeamApp().run_test(size=(80, 24)) as pilot:
            app = await _boot(pilot)
            # /gh merge → Cancel via arrows
            await _type_slash(pilot, "/gh merge")
            await pilot.press("enter")
            await pilot.pause()
            await _confirm_open(pilot, app)
            await pilot.press("down")
            await pilot.press("enter")
            await pilot.pause(0.1)
            assert spawns == [], "Cancel must not spawn the CLI command"
            assert not app.dock_visible(), "confirm dock closes after Cancel"
            # /checks --allow-dirty → Esc
            await _type_slash(pilot, "/checks --allow-dirty")
            await pilot.press("enter")
            await pilot.pause()
            await _confirm_open(pilot, app)
            await pilot.press("escape")
            await pilot.pause(0.1)
            assert spawns == [], "Esc must not spawn the CLI command"
            assert not app.dock_visible()
            # /onboarding --yes → Cancel via arrows
            await _type_slash(pilot, "/onboarding --yes")
            await pilot.press("enter")
            await pilot.pause()
            await _confirm_open(pilot, app)
            await pilot.press("down")
            await pilot.press("enter")
            await pilot.pause(0.1)
            assert spawns == [], "argv log must stay empty for every cancelled attempt"

    asyncio.run(run())


def test_confirm_non_matching_gh_unchanged(fake_env):
    """Only the three exact argvs are intercepted; `/gh preflight` (a
    supported verb with a different argv) runs immediately, unchanged."""
    spawns = _confirm_recorder()

    async def run():
        async with ProductTeamApp().run_test(size=(80, 24)) as pilot:
            app = await _boot(pilot)
            await _type_slash(pilot, "/gh preflight")
            await pilot.press("enter")
            ok = await _wait_for(pilot, lambda: spawns == [["gh", "preflight"]], timeout=5)
            assert ok, f"non-intercepted supported argv must run immediately: {spawns}"
            assert app._dock_kind == "slash", "no confirm dock for a non-matching argv"
            assert not app.dock_visible()

    asyncio.run(run())
