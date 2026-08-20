# Every chat-supported verb must produce its own real CLI output in the TUI.

import asyncio
import os
import re

import adapter
from app import ProductTeamApp

HOME_ROW_RE = re.compile(r"^\s*●\s+(\S+)\s+…+\s+(\d+\.\d)(.*)$", re.M)

VALID_ARGS = {
    "bench": "harness-cli",
    "checks": "nosuchclient",
    "gh": "preflight",
    "judge": "harness-cli",
    "report": "harness-cli",
    "run": "harness-cli 1",
    "score": "onboarding-flight-control --iter 0",
    "skill": "critique /nonexistent-skill-target",
}

# Needles that must appear in THIS turn's delta (not the accumulated log).
NEEDLES = {
    "help": ("Commands",),
    "status": ("Product Consulting Harness",),
    "agents": ("Coding agents",),
    "runtime": ("Coding agents",),
    "org": ("The organization",),
    "memory": ("Organizational Memory",),
    "report": ("iter-1",),
    "bench": ("Benchmark",),
    "score": ("missing Analyst stamp",),
    "run": ("visual-cli-clarity",),
    "judge": ("Product Judgment",),
    "checks": ("no engagement 'nosuchclient'",),
    "harness-checks": ("Harness checks",),
    "skill": ("cannot resolve target",),
    "gh": ("Logged in to github.com", "auth: not logged in", "gh_user="),
    "onboarding": ("Detect the coding agents here",),
    "splash": ("▣",),
    "smoke": ("productteam smoke",),
}


async def _wait(app, pred, timeout=90.0):
    deadline = asyncio.get_event_loop().time() + timeout
    while asyncio.get_event_loop().time() < deadline:
        if pred():
            return True
        await asyncio.sleep(0.05)
    return False


async def _boot_home(pilot, app):
    """Wait for the locked home projection (header + home rows or the honest
    empty copy) — the removed prose-status seed is never a boot needle."""
    for _ in range(600):
        if "▣─▣─▣ ProductTeam" in str(app.query_one("#header").render()):
            break
        await pilot.pause()
    for _ in range(600):
        text = app.transcript_text()
        if (
            HOME_ROW_RE.search(text)
            or "No scored sessions yet" in text
            or "no installed agent" in text  # L10 no-provider first-run
        ):
            return
        await pilot.pause()
    raise AssertionError("home projection never seeded")


def test_all_18_supported_verbs_in_tui_transcript():
    data = adapter.help_json()
    supported = [c["name"] for c in data["commands"] if c["chat_supported"]]
    assert len(supported) == 18
    os.environ.setdefault("CONSULT_NO_SPLASH", "1")
    os.environ.setdefault("CONSULT_SMOKE_SKIP_CLIENT", "1")
    real_stream = adapter.run_argv_stream

    def stream(args, on_line=None, env=None, timeout=60):
        # smoke / harness-checks print their banner immediately, then run long.
        # Cap so the TUI still receives real stdout and the turn ends.
        if args and args[0] in ("smoke", "harness-checks"):
            timeout = 12
        return real_stream(args, on_line=on_line, env=env, timeout=timeout)

    adapter.run_argv_stream = stream
    try:
        asyncio.run(_run_supported(supported))
    finally:
        adapter.run_argv_stream = real_stream


async def _run_supported(supported):
    async with ProductTeamApp().run_test(size=(80, 24)) as pilot:
        app = pilot.app
        await _boot_home(pilot, app)
        missing = []
        for verb in supported:
            args = VALID_ARGS.get(verb, "")
            n_turns = len(app._turns)
            app._run_slash(verb, args)
            timeout = 30.0 if verb in ("smoke", "harness-checks") else 45.0
            finished = await _wait(
                app,
                lambda n=n_turns: (not getattr(app, "_cli_busy", False))
                and any(k == "cli" for k, _ in app._turns[n:]),
                timeout=timeout,
            )
            delta = "\n".join(text for kind, text in app._turns[n_turns:] if kind == "cli")
            needles = NEEDLES[verb]
            if not finished or not any(n in delta for n in needles):
                missing.append((verb, delta[-240:]))
        assert not missing, "per-turn CLI output missing: " + repr(missing)


def test_every_unsupported_verb_refuses_without_spawn():
    data = adapter.help_json()
    unsupported = [c["name"] for c in data["commands"] if not c["chat_supported"]]
    assert "tui" in unsupported and "chat" in unsupported and "gate" in unsupported
    spawns: list[list[str]] = []
    real_stream = adapter.run_argv_stream

    def wrapped(args, on_line=None, env=None, timeout=60):
        spawns.append(list(args))
        return real_stream(args, on_line=on_line, env=env, timeout=timeout)

    adapter.run_argv_stream = wrapped
    try:

        async def run():
            async with ProductTeamApp().run_test(size=(80, 24)) as pilot:
                app = pilot.app
                await _boot_home(pilot, app)
                for verb in unsupported:
                    before = app.transcript_text()
                    app._run_slash(verb, "")
                    hit = await _wait(
                        app,
                        lambda v=verb, b=before: (
                            f"/{v} — " in app.transcript_text()[len(b):]
                            and "use the CLI:" in app.transcript_text()[len(b):]
                        ),
                    )
                    assert hit, f"/{verb} must refuse with reason + usage"
                    snippet = adapter.reason_for(verb).split(";", 1)[0][:24]
                    assert snippet in app.transcript_text()[len(before):]

        asyncio.run(run())
    finally:
        adapter.run_argv_stream = real_stream
    assert spawns == [], f"unsupported verbs must not spawn: {spawns}"
