# test_adapter.py — argv seam + live registry contract (33/18/15/6).

import json
import subprocess
from pathlib import Path

import pytest

import adapter

ROOT = Path(__file__).resolve().parents[3]
ADAPTER_SRC = Path(__file__).resolve().parents[1] / "adapter.py"


@pytest.fixture()
def state_root(tmp_path):
    return tmp_path / "cli-state"


@pytest.fixture()
def env(state_root):
    return {"CONSULT_STATE_ROOT": str(state_root), "CONSULT_NO_SPLASH": "1"}


def test_help_json_contract(env):
    data = adapter.help_json()
    assert data["contract"] == "cli-interface-20260812-v3"
    names = [c["name"] for c in data["commands"]]
    assert len(names) == 33
    supported = [c for c in data["commands"] if c["chat_supported"]]
    unsupported = [c for c in data["commands"] if not c["chat_supported"]]
    assert len(supported) == 18
    assert len(unsupported) == 15
    assert sorted(data["chat_only"]) == [
        "clear", "exit", "export", "provider", "quit", "workers",
    ]
    tui = next(c for c in data["commands"] if c["name"] == "tui")
    assert tui["usage"] == "productteam tui"
    assert tui["chat_supported"] is False
    assert tui["chat_reason"].strip()


def test_classify(env):
    assert adapter.classify("status") == "supported"
    assert adapter.classify("gate") == "unsupported"
    assert adapter.classify("chat") == "unsupported"
    assert adapter.classify("tui") == "unsupported"
    assert adapter.classify("provider") == "chat_only"
    assert adapter.classify("definitely-not-a-verb") == "unknown"


def test_usage_and_reason(env):
    assert adapter.usage_for("status") == "productteam status [--json]"
    assert adapter.usage_for("nope") == ""
    assert "TTY" in adapter.reason_for("tui")
    assert adapter.reason_for("nope") == ""


def test_palette_verbs(env):
    verbs = adapter.palette_verbs()
    assert len(verbs) == 39  # 33 commands + 6 chat-only
    for v in ("status", "tui", "provider", "gate"):
        assert v in verbs


def test_run_argv_status(env):
    cp = adapter.run_argv(["status"], env=env)
    assert cp.returncode == 0
    assert "Product Consulting" in cp.stdout


def test_run_argv_report_usage(env):
    cp = adapter.run_argv(["report"], env=env)
    assert cp.returncode == 1
    assert cp.stdout == ""
    assert "usage:" in cp.stderr


def test_run_argv_agents_json(env):
    cp = adapter.run_argv(["agents", "--json"], env=env)
    assert cp.returncode == 0
    data = json.loads(cp.stdout)
    assert isinstance(data, list)
    assert all("name" in row and "status" in row for row in data)


def test_agents_json_two_tokens(env):
    # `agents --json` must survive the token-aware audit as two tokens.
    cp = adapter.run_argv(["agents", "--json"], env=env)
    assert cp.returncode == 0


def test_forbidden_tokens_refused(env):
    for tok in ("/bin/sh", "/bin/bash", "eval", "sqlite", "sqlite3"):
        with pytest.raises(adapter.ForbiddenTokenError):
            adapter.run_argv(["status", tok], env=env)


def test_adapter_source_has_no_shell(env):
    src = ADAPTER_SRC.read_text()
    # Drop the module docstring and comment lines, then prove no real code
    # path uses shell=True, eval(, or any other shell string construction.
    body = src.split('"""', 2)[2] if src.count('"""') >= 2 else src
    code = "\n".join(
        line for line in body.splitlines() if not line.lstrip().startswith("#")
    )
    assert "shell=True" not in code
    assert "eval(" not in code
    assert "shell=" not in code.replace("shell=False", "")


def test_run_argv_stream_usage(env):
    lines = []
    cp = adapter.run_argv_stream(["report"], on_line=lines.append, env=env)
    assert cp.returncode == 1
    assert "".join(lines) == cp.stdout
    assert "usage:" in cp.stdout
