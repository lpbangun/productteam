# test_pty.py — real PTY probe of `productteam tui` (no mocks).
#
# If the environment cannot create a pty (no fork / no /dev/ptmx), the test
# is skipped rather than faked. On a real pty it launches the actual
# executable, types /status and expects real engagement text, then types
# /gate and requires the registry refuse reason — and proves the refusal did
# NOT spawn a real gate run (no "no directive" text from a gate status).

import json
import os
import pty
import re
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


def _strip_ansi(data: bytes) -> bytes:
    """Return captured PTY bytes with ANSI CSI/OSC escape sequences and C1
    control bytes removed, keeping the UTF-8 glyph payload. Assertion-only
    normalization: the real terminal keeps its control sequences (styled
    header glyphs are painted with CSI between them)."""
    out = bytearray()
    i = 0
    n = len(data)
    utf8 = 0  # remaining UTF-8 continuation bytes expected after a lead byte
    while i < n:
        b = data[i]
        if utf8:
            out.append(b)
            utf8 -= 1
            i += 1
            continue
        if b == 0x1B:  # ESC
            if i + 1 >= n:
                break
            nxt = data[i + 1]
            if nxt == 0x5B:  # CSI: ESC [ params intermediates final
                i += 2
                while i < n and not (0x40 <= data[i] <= 0x7E):
                    i += 1
                i += 1
                continue
            if nxt == 0x5D:  # OSC: ESC ] ... BEL or ST
                i += 2
                while i < n:
                    c = data[i]
                    if c == 0x07:
                        i += 1
                        break
                    if c == 0x1B and i + 1 < n and data[i + 1] == 0x5C:
                        i += 2
                        break
                    i += 1
                continue
            if nxt in (0x50, 0x58, 0x5E, 0x5F):  # DCS/SOS/PM/APC ... ST
                i += 2
                while i < n:
                    if data[i] == 0x1B and i + 1 < n and data[i + 1] == 0x5C:
                        i += 2
                        break
                    i += 1
                continue
            i += 1  # lone ESC
            continue
        if 0xC2 <= b <= 0xF4:  # UTF-8 lead byte: keep whole codepoint
            out.append(b)
            utf8 = 1 if b <= 0xDF else (2 if b <= 0xEF else 3)
            i += 1
            continue
        if 0x80 <= b <= 0x9F:  # C1 control (never a lead byte here)
            i += 1
            continue
        out.append(b)
        i += 1
    return bytes(out)


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
        # The cockpit runs one turn at a time: the busy guard refuses a
        # second submit while /status is still streaming, so wait for the
        # streamed command turn to finish (its final line) before /gate.
        # The needle must survive Textual's width crop of the rendered line.
        assert _wait_for(fd, out, "bench <client> for scores", 25), \
            "status command turn completed before /gate"
        _send(fd, "/gate\r")
        # The busy guard can still win the final instant of the /status
        # stream; when it refuses, /gate stays in the composer, so a second
        # Enter re-submits it. An Enter on the already-refused empty composer
        # is a no-op, which keeps this loop idempotent.
        for _ in range(3):
            if _wait_for(fd, out, "use the CLI: productteam gate", 10):
                break
            _send(fd, "\r")
        else:
            assert False, "unsupported /gate refuses with the registry usage"
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
        assert _wait_for(fd, out, "partial output left on disk", 15), \
            "first Ctrl+C finishes the failed card before forced exit"
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


def test_pty_typed_role_records_builder(tmp_path):
    """D18 Role-argv row: a typed leading @Builder turn runs the real provider
    fixture path (no _start_provider_turn stub) and workers.tsv records the
    Builder role — activity_start is never hardcoded Analyst."""
    fast = tmp_path / "builder-provider.sh"
    fast.write_text(
        "#!/usr/bin/env bash\n"
        "printf 'builder analysis complete\\n'\n"
    )
    fast.chmod(0o755)
    state_root = tmp_path / "state"
    pid, fd, out = _open_session(fast, {"CONSULT_STATE_ROOT": str(state_root)})
    try:
        assert _wait_for(fd, out, "ProductTeam", 25), "cockpit header rendered"
        _send(fd, "@Builder verify the seam\r")
        assert _wait_for(fd, out, "builder analysis complete", 25), \
            "provider artifact streamed into the transcript"
        # The worker row flips to done as the turn script exits; poll the file.
        deadline = time.time() + 15
        row = None
        while time.time() < deadline:
            tsvs = list(state_root.glob("runs/session-*/workers.tsv"))
            if tsvs:
                lines = tsvs[0].read_text().splitlines()
                for raw in lines[1:]:
                    parts = raw.split("\t")
                    if len(parts) >= 3 and parts[1] == "Builder":
                        row = parts
                        break
            if row and row[2] == "done":
                break
            time.sleep(0.25)
        _send(fd, "/exit\r")
        _drain(fd, out, 3)
    finally:
        status = _close_session(pid, fd)
    assert status == 0, f"clean /exit leaves rc 0, got {status}"
    assert row, "workers.tsv must record a Builder row"
    assert row[1] == "Builder", f"worker role is Builder, got {row[1]!r}"
    assert row[2] == "done", f"worker finished done, got {row[2]!r}"
    assert "verify the seam" in row[3], "mission is the stripped user prompt"
    txt = b"".join(out).decode("utf-8", "replace")
    assert "Builder" in txt, "completion card labels the turn's role"

def test_pty_confirm_cancel_keeps_composer():
    """D13 live row: `/gh merge` opens the real confirm dock (Run/Cancel
    options + the confirm footer); Esc cancels the write, the dock closes
    back to the idle footer, and the composer/@Principal chrome remains;
    `/exit` then leaves rc 0. The no-spawn proof itself stays with the
    native recorder test; this proves the live dock/routing on the real
    executable. Assertions run on the ANSI-normalized accumulated stream
    like the SIGWINCH row."""
    def wait_delta(fd, out, mark, needle, timeout=25):
        if isinstance(needle, str):
            needle = needle.encode()
        deadline = time.time() + timeout
        while time.time() < deadline:
            _drain(fd, out, 0.25)
            if needle in _strip_ansi(b"".join(out))[mark:]:
                return True
        return False

    pid, fd, out = _open_session()
    try:
        assert _wait_for(fd, out, "ProductTeam", 25), "cockpit header rendered"
        _send(fd, "/gh merge\r")
        assert wait_delta(fd, out, 0, "↑↓ choose · enter run · esc cancel"), \
            "confirm footer shown for the intercepted write"
        txt = _strip_ansi(b"".join(out)).decode("utf-8", "replace")
        assert "Confirm write" in txt, "confirm dock shows the Confirm write title"
        assert "Run" in txt and "Cancel" in txt, "confirm dock shows Run / Cancel options"
        assert "/gh merge" in txt, "the intercepted verb echo stays in the transcript"
        assert "@Principal" not in txt, "team mode shows no default @Role tag"
        _drain(fd, out, 0.5)
        mark = len(_strip_ansi(b"".join(out)))
        _send(fd, "\x1b")  # Esc cancels the write: executes nothing
        assert wait_delta(fd, out, mark, "enter send · / commands · tab agents"), \
            "Esc closes the confirm dock back to the idle footer"
        _send(fd, "/exit\r")
        _drain(fd, out, 3)
    finally:
        status = _close_session(pid, fd)
    assert status == 0, f"clean /exit leaves rc 0, got {status}"


def test_pty_sigwinch_compact():
    """A real terminal resize redraws compact chrome without spawning work,
    retains the composer, and restores the wide heads after SIGWINCH.
    Presence/absence checks run on the ANSI-normalized byte stream (Textual
    paints styled header glyphs with CSI between them), with the same glyph
    needles and timeouts as the raw-PTY assertions."""
    import fcntl

    def wait_delta(fd, out, mark, needle, timeout=25):
        deadline = time.time() + timeout
        if isinstance(needle, str):
            needle = needle.encode()
        while time.time() < deadline:
            _drain(fd, out, 0.25)
            if needle in _strip_ansi(b"".join(out))[mark:]:
                return True
        return False

    def wait_compact(fd, out, mark, timeout=25):
        """Wait for the app to settle at 40 columns, then return the stripped
        delta from after the last stale wide-header frame. Frames painted at
        the still-cached 80-column width while the SIGWINCH is being processed
        are excluded; the resize reflow (compact header, retained composer
        with @Principal) lands after them. None on timeout."""
        deadline = time.time() + timeout
        heads = "▣─▣─▣".encode()
        while time.time() < deadline:
            _drain(fd, out, 0.25)
            stripped = _strip_ansi(b"".join(out))[mark:]
            if b"ProductTeam" not in stripped:
                continue
            _drain(fd, out, 1.0)  # let the resize reflow finish painting
            stripped = _strip_ansi(b"".join(out))[mark:]
            last = stripped.rfind(heads)
            if last >= 0:
                eol = stripped.find(b"\r\n", last)
                if eol >= 0:
                    return stripped[eol + 2:]
                eol = stripped.find(b"\n", last)
                if eol >= 0:
                    return stripped[eol + 1:]
            return stripped
        return None

    pid, fd, out = _open_session()
    cwd = Path.cwd().name.encode()
    try:
        assert wait_delta(fd, out, 0, "▣─▣─▣ ProductTeam", 25), "wide header rendered"
        _drain(fd, out, 0.5)
        mark = len(_strip_ansi(b"".join(out)))
        fcntl.ioctl(fd, termios.TIOCSWINSZ, struct.pack("HHHH", 20, 40, 0, 0))
        compact = wait_compact(fd, out, mark)
        assert compact is not None, "compact header rendered"
        assert b"ProductTeam" in compact
        assert "▣─▣─▣".encode() not in compact
        assert cwd not in compact
        assert b"@Principal" not in compact, "team mode shows no default @Role tag"
        assert b"enter send" in compact, "composer + idle footer retained at compact"

        mark = len(_strip_ansi(b"".join(out)))
        fcntl.ioctl(fd, termios.TIOCSWINSZ, struct.pack("HHHH", 24, 80, 0, 0))
        assert wait_delta(fd, out, mark, "▣─▣─▣ ProductTeam"), "wide header restored"
        restored = _strip_ansi(b"".join(out))[mark:]
        assert "▣─▣─▣ ProductTeam".encode() in restored
    finally:
        _send(fd, "/exit\r")
        _drain(fd, out, 3)
        status = _close_session(pid, fd)
    assert status == 0, f"clean /exit leaves rc 0, got {status}"


# ── iter-9: freeze §7 empty-artifact PTY row (D06/D07/D09/D24) ────────
# One hold-then-speak provider fixture: parse `-p` (provider_ask invokes
# non-agent bins as `"$bin" -p "$prompt" --output-format text`), atomically
# write the captured prompt before any stdout byte, hold 8s of silence,
# then speak owned bytes and stay alive 25s for the inject + SIGWINCH +
# restore window. The capture file is argv-adjacent D24 evidence — never
# the artifact and never speech.

HOLD_PROVIDER = (
    "#!/usr/bin/env bash\n"
    'prompt=""\n'
    "while (($#)); do\n"
    '  if [[ "$1" == "-p" && $# -ge 2 ]]; then prompt="$2"; shift 2; continue; fi\n'
    "  shift\n"
    "done\n"
    'mkdir -p "${CONSULT_STATE_ROOT:-/tmp}"\n'
    'printf \'%s\\n\' "$prompt" > "${CONSULT_STATE_ROOT}/prompt-capture.txt.tmp"\n'
    'mv "${CONSULT_STATE_ROOT}/prompt-capture.txt.tmp" "${CONSULT_STATE_ROOT}/prompt-capture.txt"\n'
    "sleep 8\n"
    "printf 'owned speech begins\\n'\n"
    "sleep 25\n"
    "printf 'owned speech continues\\n'\n"
)


def _wait_delta(fd, out, mark, needle, timeout=25):
    """Wait for needle in the ANSI-stripped stream after `mark` (same
    normalization as the confirm/SIGWINCH rows)."""
    if isinstance(needle, str):
        needle = needle.encode()
    deadline = time.time() + timeout
    while time.time() < deadline:
        _drain(fd, out, 0.25)
        if needle in _strip_ansi(b"".join(out))[mark:]:
            return True
    return False


def _wait_compact(fd, out, mark, timeout=25):
    """Wait for the app to settle at 40 columns, then return the stripped
    delta from after the last stale wide-header frame. None on timeout."""
    deadline = time.time() + timeout
    heads = "▣─▣─▣".encode()
    while time.time() < deadline:
        _drain(fd, out, 0.25)
        stripped = _strip_ansi(b"".join(out))[mark:]
        if b"ProductTeam" not in stripped:
            continue
        _drain(fd, out, 1.0)  # let the resize reflow finish painting
        stripped = _strip_ansi(b"".join(out))[mark:]
        last = stripped.rfind(heads)
        if last >= 0:
            eol = stripped.find(b"\r\n", last)
            if eol >= 0:
                return stripped[eol + 2:]
            eol = stripped.find(b"\n", last)
            if eol >= 0:
                return stripped[eol + 1:]
        return stripped
    return None


def test_pty_activity_empty_artifact_compact_and_prompt_export(tmp_path):
    """Freeze §7 + D06/D07/D09/D24: a real hold-then-speak provider turn
    proves the empty-artifact silence window (no Thinking, no fake agent
    rail) beside the live activity strip (braille / mission / provider
    basename / m:ss / busy footer); an atomic same-session workers.tsv
    inject caps the compact activity at 1 live row + 2 while the header
    shows the compact score slot (no heads/cwd, @Builder prefix kept); the wide
    heads restore while the work is still live; first owned bytes open
    exactly one Builder rail with no Thinking; and the exact Builder
    prompt_export + `verify the seam` land in prompt-capture.txt from the
    fixture argv before any stdout byte. /exit stays the clean exit — the
    interrupt coverage belongs to test_pty_provider_interrupt."""
    import fcntl
    import shutil

    # The fixture must sit at a short path: at 40 columns the compact
    # activity row wraps inside its max-height-4 strip, and a long pytest
    # tmp_path (>=64 chars) plus the mandated hold-provider.sh basename
    # wraps to 4 rows — clipping the `+2` overflow line off the TTY. A
    # /tmp/<pid>/ dir keeps the basename needle (footer + strip) while the
    # row fits in 3 wrapped rows, so the capped strip shows 1 + +2.
    provider_dir = Path("/tmp") / f"pt-{os.getpid()}"
    shutil.rmtree(provider_dir, ignore_errors=True)
    provider_dir.mkdir(parents=True, exist_ok=True)
    hold = provider_dir / "hold-provider.sh"
    hold.write_text(HOLD_PROVIDER)
    hold.chmod(0o755)
    state_root = tmp_path / "state"
    prompt_export = json.loads(
        (ROOT / "state" / "agents" / "builder.json").read_text(encoding="utf-8")
    )["prompt_export"]
    assert prompt_export, "live Builder card must carry a non-empty prompt_export"
    expected_capture = f"{prompt_export}\n\nverify the seam\n"
    cwd = Path.cwd().name.encode()

    pid, fd, out = _open_session(hold, {"CONSULT_STATE_ROOT": str(state_root)})
    try:
        # T0: idle wide header
        assert _wait_for(fd, out, "ProductTeam", 25), "idle header rendered"
        _drain(fd, out, 0.5)
        # T1: mark the stripped stream, send the Builder turn
        mark = len(_strip_ansi(b"".join(out)))
        _send(fd, "@Builder verify the seam\r")
        # T2: the exact-session workers.tsv with a live Builder row whose
        # artifact is missing/empty/size 0 (the hold window)
        tsv = None
        deadline = time.time() + 15
        while time.time() < deadline:
            for cand in state_root.glob("runs/session-*/workers.tsv"):
                try:
                    lines = cand.read_text().splitlines()
                except OSError:
                    continue
                for raw in lines[1:]:
                    parts = raw.split("\t")
                    if len(parts) < 8 or parts[1] != "Builder":
                        continue
                    if parts[2] not in ("pending", "running", "progress"):
                        continue
                    try:
                        empty = (not parts[7]) or not Path(parts[7]).exists() \
                            or Path(parts[7]).stat().st_size == 0
                    except OSError:
                        empty = True
                    if empty:
                        tsv = cand
                        break
                if tsv:
                    break
            if tsv:
                break
            time.sleep(0.25)
        assert tsv is not None, (
            "live session workers.tsv with an empty-artifact Builder row never appeared")
        # D24: the capture file lands before any stdout byte — read it now,
        # before the speech window
        cap = state_root / "prompt-capture.txt"
        deadline = time.time() + 15
        while time.time() < deadline:
            if cap.is_file() and cap.stat().st_size > 0:
                break
            time.sleep(0.25)
        assert cap.is_file() and cap.stat().st_size > 0, (
            "prompt-capture.txt never written by the hold-provider")
        capture = cap.read_text(encoding="utf-8")
        assert capture == expected_capture, (
            "captured prompt must be exactly prompt_export + blank line + user prompt")
        assert "Thinking…" not in capture and "│ ▸" not in capture
        assert "owned speech begins" not in capture
        # T3: absence + activity window on the stripped delta (chip-safe:
        # chips may paint role glyphs without a leading rail)
        _drain(fd, out, 0.5)
        delta = _strip_ansi(b"".join(out))[mark:]
        assert "Thinking…".encode() not in delta, "Thinking must stay absent while holding"
        for opener in ("│ ◆", "│ ◇", "│ ▸", "│ ◉"):
            assert opener.encode() not in delta, (
                f"fake agent speaking opener {opener!r} during the hold")
        assert any(ch.encode() in delta for ch in "⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"), (
            "braille spinner missing from the live activity strip")
        assert "verify the seam".encode() in delta, "activity mission missing"
        assert "hold-provider.sh".encode() in delta, "provider basename missing"
        assert re.search(rb"\d+:\d{2}", delta), "elapsed m:ss missing"
        assert "ctrl+c interrupt".encode() in delta, "busy footer missing"
        # T4: atomic same-session inject — header and the live Builder row
        # preserved, two extra live rows appended
        header_lines = tsv.read_text().splitlines()
        assert header_lines[0] == "id\trole\tstate\tmission\tprovider\tstart\telapsed\tartifact"
        assert any(
            p[1] == "Builder" and p[2] in ("pending", "running", "progress")
            for p in (l.split("\t") for l in header_lines[1:])
        ), "live Builder row must survive the inject"
        now = int(time.time())
        extra = [
            f"2\tAnalyst\trunning\tevidence\tgpt\t{now - 4}\t4\t",
            f"3\tCritic\tprogress\tchecking\tlocal\t{now - 4}\t4\t",
        ]
        tmp_tsv = tsv.with_name("workers.tsv.inject")
        tmp_tsv.write_text("\n".join(header_lines + extra) + "\n")
        os.replace(tmp_tsv, tsv)
        _drain(fd, out, 0.5)
        # T5: compact while live — score slot, no heads/cwd, @Builder, +2
        mark_compact = len(_strip_ansi(b"".join(out)))
        fcntl.ioctl(fd, termios.TIOCSWINSZ, struct.pack("HHHH", 20, 40, 0, 0))
        compact = _wait_compact(fd, out, mark_compact)
        assert compact is not None, "compact frame never rendered"
        assert re.search(r"ProductTeam (—|\d+\.\d)".encode(), compact), (
            "compact header must carry the score slot")
        assert "▣─▣─▣".encode() not in compact, "compact must drop the heads"
        assert cwd not in compact, "compact must drop the cwd basename"
        # Composer visibly retained at compact. Contract correction vs the
        # original @Principal needle: the typed `@Builder` turn legitimately
        # changed the session-local target (Q15), so the prefix chrome shows
        # @Builder — demanding Principal would contradict the product lock.
        assert b"@Builder" in compact, "composer prefix retained at compact"
        assert b"+2" in compact, "compact activity must cap 1 live row + 2"
        # T6: restore wide heads while the work is still live
        mark_wide = len(_strip_ansi(b"".join(out)))
        fcntl.ioctl(fd, termios.TIOCSWINSZ, struct.pack("HHHH", 24, 80, 0, 0))
        assert _wait_delta(fd, out, mark_wide, "▣─▣─▣ ProductTeam"), (
            "wide heads restored while the provider is still live")
        # T7: first owned speech opens exactly one Builder rail, no Thinking
        assert _wait_for(fd, out, "owned speech begins", 25), (
            "provider speech never arrived")
        after = _strip_ansi(b"".join(out))[mark:]
        assert after.count("│ ▸".encode()) == 1, "exactly one Builder speaking opener"
        assert "Thinking…".encode() not in after
        # T8: clean /exit — never Ctrl+C (interrupt coverage stays with the
        # existing provider-interrupt row)
        _send(fd, "/exit\r")
        _drain(fd, out, 3)
    finally:
        status = _close_session(pid, fd)
        shutil.rmtree(provider_dir, ignore_errors=True)
    assert status == 0, f"clean /exit leaves rc 0, got {status}"
