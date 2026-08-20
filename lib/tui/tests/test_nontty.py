# test_nontty.py — frozen §5: non-TTY refusal and NO_COLOR.

import os
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
CLI = ROOT / "bin" / "productteam"


def _run(env_extra=None):
    env = dict(os.environ)
    if env_extra:
        env.update(env_extra)
    return subprocess.run(
        [str(CLI), "tui"],
        stdin=subprocess.DEVNULL,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        env=env,
        timeout=60,
    )


def test_nontty_refusal():
    cp = _run()
    assert cp.returncode == 2
    assert cp.stdout == b""
    assert b"requires an interactive TTY" in cp.stderr


def test_nontty_no_color_no_escapes():
    cp = _run({"NO_COLOR": "1"})
    assert cp.returncode == 2
    assert cp.stdout == b""
    assert b"\x1b" not in cp.stdout + cp.stderr
    assert b"requires an interactive TTY" in cp.stderr
