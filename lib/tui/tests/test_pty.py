# test_pty.py — real PTY probe of `productteam tui` (no mocks).
#
# If the environment cannot create a pty (no fork / no /dev/ptmx), the test
# is skipped rather than faked. On a real pty it launches the actual
# executable, types /status and expects real engagement text, then types
# /gate and requires the registry refuse reason — and proves the refusal did
# NOT spawn a real gate run (no "no directive" text from a gate status).

import os
import pty
import select
import struct
import termios
import time
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[3]
CLI = ROOT / "bin" / "productteam"

pytestmark = pytest.mark.skipif(
    not (hasattr(os, "fork") and os.path.exists("/dev/ptmx")),
    reason="no pty-capable environment (no fork or no /dev/ptmx)",
)


def _drain(fd, out, seconds):
    end = time.time() + seconds
    while time.time() < end:
        r, _, _ = select.select([fd], [], [], 0.2)
        if fd in r:
            try:
                d = os.read(fd, 65536)
                if not d:
                    return False
                out.append(d)
            except OSError:
                return False
    return True


def _wait_for(fd, out, needle, timeout):
    """Poll the pty output until needle appears (robust under load)."""
    if isinstance(needle, str):
        needle = needle.encode()
    deadline = time.time() + timeout
    while time.time() < deadline:
        _drain(fd, out, 0.25)
        if needle in b"".join(out):
            return True
    return False


def _send(fd, text):
    try:
        os.write(fd, text.encode())
    except OSError:
        pass


def _open_session(provider=None, extra_env=None):
    """Return (pid, fd, out-list) for a fresh pty cockpit session."""
    env = dict(os.environ)
    env["TERM"] = "xterm-256color"
    env["CONSULT_NO_SPLASH"] = "1"
    if extra_env:
        env.update(extra_env)
    if provider:
        env["CONSULT_PROVIDER"] = str(provider)
    pid, fd = pty.fork()
    if pid == 0:
        os.execvpe(str(CLI), [str(CLI), "tui"], env)
    import fcntl

    fcntl.ioctl(fd, termios.TIOCSWINSZ, struct.pack("HHHH", 24, 80, 0, 0))
    return pid, fd, []


def _close_session(pid, fd):
    try:
        os.close(fd)
    except OSError:
        pass
    for _ in range(50):
        done, status = os.waitpid(pid, os.WNOHANG)
        if done:
            return os.waitstatus_to_exitcode(status)
        time.sleep(0.1)
    return -1


def _run_status_gate_session():
    pid, fd, out = _open_session()
    try:
        assert _wait_for(fd, out, "ProductTeam", 25), "cockpit header rendered"
        _send(fd, "/status\r")
        assert _wait_for(fd, out, "Product Consulting Harness", 25), \
            "real status output reached the transcript"
        _send(fd, "/gate\r")
        assert _wait_for(fd, out, "use the CLI: productteam gate", 25), \
            "unsupported /gate refuses with the registry usage"
        _send(fd, "/exit\r")
        _drain(fd, out, 3)
    finally:
        status = _close_session(pid, fd)
    return b"".join(out), status


def test_pty_status_and_gate_refuse():
    out, status = _run_status_gate_session()
    txt = out.decode("utf-8", "replace")
    assert "Product Consulting Harness" in txt, "real status output seeded the transcript"
    assert "harness-cli" in txt, "real engagement text visible"
    assert "use the CLI: productteam gate" in txt, "unsupported /gate refuses with usage"
    assert "owner-gated" in txt, "refuse carries the registry reason"
    assert "no directive" not in txt, "refuse must not spawn a real gate run"
    assert "AttributeError" not in txt


def test_pty_provider_interrupt(tmp_path):
    """Real provider turn: first Ctrl+C keeps partial artifact + worker failed,
    second Ctrl+C exits 130."""
    slow = tmp_path / "slow-provider.sh"
    slow.write_text(
        "#!/usr/bin/env bash\n"
        "printf 'partial analysis begins\\n'\n"
        "sleep 30 &\n"
        "wait\n"
    )
    slow.chmod(0o755)
    state_root = tmp_path / "state"
    pid, fd, out = _open_session(slow, {"CONSULT_STATE_ROOT": str(state_root)})
    try:
        assert _wait_for(fd, out, "ProductTeam", 25), "cockpit header rendered"
        _send(fd, "analyze the layout\r")
        assert _wait_for(fd, out, "partial analysis begins", 25), \
            "provider artifact streamed into the transcript"
        _send(fd, "\x03")  # first Ctrl+C → interrupt, keep partial bytes
        assert _wait_for(fd, out, "interrupting provider", 15), \
            "interrupt toast shown"
        _send(fd, "\x03")  # second Ctrl+C → exit 130
        _drain(fd, out, 3)
    finally:
        status = _close_session(pid, fd)
    assert status == 130, "second Ctrl+C exits 130"
    txt = b"".join(out).decode("utf-8", "replace")
    assert "partial output left on disk" in txt, "partial artifact kept and named"
    arts = list(state_root.glob("runs/session-*/artifacts/*.txt"))
    assert arts, "artifact file exists"
    assert "partial analysis begins" in arts[0].read_text()
    tsvs = list(state_root.glob("runs/session-*/workers.tsv"))
    assert tsvs, "workers.tsv exists"
    assert "\tfailed\t" in tsvs[0].read_text(), "worker marked failed"
