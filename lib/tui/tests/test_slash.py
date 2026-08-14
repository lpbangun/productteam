# test_slash.py — dock filtering, unsupported refuse (no spawn), usage on
# missing args, and the session-local verbs.

import asyncio
import json
import os
import subprocess
from pathlib import Path

import pytest

import adapter
from app import ProductTeamApp

FAKE_HELP = {
    "contract": "cli-interface-20260812-v3",
    "commands": [
        {"name": "help", "usage": "productteam help [--json]", "chat_supported": True},
        {"name": "status", "usage": "productteam status [--json]", "chat_supported": True},
        {"name": "report", "usage": "productteam report <client>", "chat_supported": True},
        {"name": "gate", "usage": "productteam gate <client> status|direct|…",
         "chat_supported": False,
         "chat_reason": "owner-gated durable decisions must leave a durable record"},
        {"name": "chat", "usage": "productteam chat", "chat_supported": False,
         "chat_reason": "nested sessions re-enter the same REPL"},
        {"name": "tui", "usage": "productteam tui", "chat_supported": False,
         "chat_reason": "optional presentation client"},
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


@pytest.fixture()
def fake_env(monkeypatch, tmp_path):
    adapter.reset_palette()
    monkeypatch.setattr(adapter, "run_argv", _fake_run_argv)
    monkeypatch.setattr(adapter, "run_argv_stream", _fake_stream_usage)
    monkeypatch.delenv("CONSULT_PROVIDER", raising=False)
    monkeypatch.setenv("CONSULT_STATE_ROOT", str(tmp_path / "cli-state"))
    monkeypatch.setenv("CONSULT_NO_SPLASH", "1")
    return tmp_path


async def _wait_for(app, predicate, timeout=10.0):
    deadline = asyncio.get_event_loop().time() + timeout
    while asyncio.get_event_loop().time() < deadline:
        if predicate():
            return True
        await app.pause()
        await asyncio.sleep(0.02)
    return False


async def _boot(pilot):
    app = pilot.app
    composer = app.query_one("#composer")
    composer.focus()
    await pilot.pause()
    await _wait_for(app, lambda: "Product Consulting Harness" in app.transcript_text())
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
                app, lambda: "use the CLI: productteam gate" in app.transcript_text())
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
                app, lambda: "usage: productteam report <client>" in app.transcript_text())
            assert ok, "usage printed without inventing a client"
    asyncio.run(run())


def test_provider_sets_session_env(fake_env):
    async def run():
        async with ProductTeamApp().run_test(size=(80, 24)) as pilot:
            app = await _boot(pilot)
            await pilot.press("/", "p", "r", "o", "v", "i", "d", "e", "r")
            await pilot.press("enter")
            ok = await _wait_for(app, lambda: "provider → agent" in app.transcript_text())
            assert ok
            assert os.environ.get("CONSULT_PROVIDER") == "agent"
    asyncio.run(run())


def test_provider_named(fake_env):
    async def run():
        async with ProductTeamApp().run_test(size=(80, 24)) as pilot:
            app = await _boot(pilot)
            keys = list('/provider "claude"')
            await pilot.press(*keys)
            await pilot.press("enter")
            ok = await _wait_for(app, lambda: "provider → claude" in app.transcript_text())
            assert ok
    asyncio.run(run())


def test_clear_clears_transcript(fake_env):
    async def run():
        async with ProductTeamApp().run_test(size=(80, 24)) as pilot:
            app = await _boot(pilot)
            assert "Product Consulting Harness" in app.transcript_text()
            await pilot.press(*list("/status"))
            await pilot.press("enter")
            ok = await _wait_for(
                app, lambda: "usage: productteam report" in app.transcript_text())
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
            await pilot.press("/", "e", "x", "p", "o", "r", "t")
            await pilot.press("enter")
            ok = await _wait_for(app, lambda: "wrote " in app.transcript_text())
            assert ok
    asyncio.run(run())
    exported = list(Path(os.environ["CONSULT_STATE_ROOT"]).glob("sessions/tui-*.md"))
    assert len(exported) == 1
    text = exported[0].read_text()
    assert "# TUI session" in text
    assert "/export" in text
    assert "Product Consulting Harness" in text, "export must include CLI output"


def test_exit_leaves(fake_env):
    async def run():
        async with ProductTeamApp().run_test(size=(80, 24)) as pilot:
            app = await _boot(pilot)
            await pilot.press(*list("/exit"))
            await pilot.press("enter")
            ok = await _wait_for(app, lambda: getattr(app, "_exit", False), timeout=5.0)
            assert ok, "app exited via /exit"
            assert app.return_code == 0
    asyncio.run(run())
