# adapter.py — the cockpit's only argv seam to the real `bin/productteam`.
#
# Every CLI function the TUI runs goes through an argv array to the real
# executable (never shell=True, never eval, never a concatenated command
# string). The slash palette is derived from live `productteam help --json`;
# the CLI registry stays the single source of truth — nothing here hardcodes
# a second verb list.
#
# Token-aware argv audit: `agents --json` is two allowed tokens; the whole
# tokens /bin/sh /bin/bash eval sqlite sqlite3 are refused. This is a
# whole-token check, never a substring ban.

from __future__ import annotations

import json
import os
import select
import subprocess
import time
from pathlib import Path
from typing import Callable, Iterable, Optional

FORBIDDEN_TOKENS = frozenset({"/bin/sh", "/bin/bash", "eval", "sqlite", "sqlite3"})
TIMEOUT = 60


class ForbiddenTokenError(ValueError):
    """A whole-token argv audit refusal."""


def _check_tokens(args: Iterable[str]) -> None:
    for tok in args:
        if tok in FORBIDDEN_TOKENS:
            raise ForbiddenTokenError(f"forbidden token in argv: {tok!r}")


def cli_path() -> str:
    """Resolve CONSULT_ROOT/bin/productteam, else walk up to the repo root."""
    env = os.environ.get("CONSULT_ROOT")
    if env:
        cand = Path(env) / "bin" / "productteam"
        if cand.is_file():
            return str(cand)
    here = Path(__file__).resolve()
    for parent in (here, *here.parents):
        cand = parent / "bin" / "productteam"
        if cand.is_file():
            return str(cand)
    raise FileNotFoundError(
        "bin/productteam not found — is CONSULT_ROOT set or is this a worktree copy?"
    )


def _merged_env(env: Optional[dict]) -> dict:
    merged = dict(os.environ)
    if env:
        merged.update(env)
    # Keep splash off unless the caller asked for it (tests/PTY).
    if not merged.get("CONSULT_NO_SPLASH"):
        merged.pop("CONSULT_NO_SPLASH", None)
    else:
        merged.setdefault("CONSULT_NO_SPLASH", "1")
    return merged


def run_argv(
    args: list[str], *, env: Optional[dict] = None, timeout: int = TIMEOUT
) -> subprocess.CompletedProcess:
    """argv-only subprocess to bin/productteam (captured)."""
    _check_tokens(args)
    cli = cli_path()
    return subprocess.run(
        [cli, *args],
        shell=False,
        env=_merged_env(env),
        timeout=timeout,
        capture_output=True,
        text=True,
    )


def run_argv_stream(
    args: list[str],
    *,
    on_line: Optional[Callable[[str], None]] = None,
    env: Optional[dict] = None,
    timeout: int = TIMEOUT,
) -> subprocess.CompletedProcess:
    """Streaming variant of run_argv: merged stdout+stderr lines are handed to
    on_line as they are produced. Still argv-only and token-audited."""
    _check_tokens(args)
    cli = cli_path()
    proc = subprocess.Popen(
        [cli, *args],
        shell=False,
        env=_merged_env(env),
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        bufsize=1,
    )
    chunks: list[str] = []
    assert proc.stdout is not None
    deadline = time.monotonic() + timeout
    timed_out = False
    fd = proc.stdout.fileno()
    while True:
        remaining = deadline - time.monotonic()
        if remaining <= 0:
            timed_out = True
            break
        ready, _, _ = select.select([fd], [], [], min(0.2, remaining))
        if not ready:
            if proc.poll() is not None:
                rest = proc.stdout.read() or ""
                if rest:
                    chunks.append(rest)
                    if on_line is not None:
                        for line in rest.splitlines(True):
                            on_line(line)
                break
            continue
        line = proc.stdout.readline()
        if not line:
            break
        chunks.append(line)
        if on_line is not None:
            on_line(line)
    if timed_out or proc.poll() is None:
        proc.kill()
        try:
            proc.wait(timeout=2)
        except Exception:
            pass
    else:
        proc.wait(timeout=2)
    rc = 124 if timed_out else (proc.returncode if proc.returncode is not None else 1)
    return subprocess.CompletedProcess(proc.args, rc, "".join(chunks), "")


class _Palette:
    """Lazily-loaded view of the live registry (help --json)."""

    def __init__(self) -> None:
        self._data: Optional[dict] = None

    def load(self) -> dict:
        cp = run_argv(["help", "--json"])
        if cp.returncode != 0:
            raise RuntimeError(
                f"productteam help --json failed (rc={cp.returncode})"
            )
        self._data = json.loads(cp.stdout)
        return self._data

    def reset(self) -> None:
        self._data = None

    @property
    def data(self) -> dict:
        if self._data is None:
            self.load()
        return self._data

    def commands(self) -> list[dict]:
        return self.data["commands"]

    def chat_only(self) -> list[str]:
        return list(self.data.get("chat_only", []))

    def by_name(self, verb: str) -> Optional[dict]:
        for c in self.commands():
            if c["name"] == verb:
                return c
        return None

    def classify(self, verb: str) -> str:
        """supported / unsupported / chat_only / unknown."""
        if verb in self.chat_only():
            return "chat_only"
        cmd = self.by_name(verb)
        if cmd is None:
            return "unknown"
        return "supported" if cmd["chat_supported"] else "unsupported"

    def usage_for(self, verb: str) -> str:
        cmd = self.by_name(verb)
        return cmd["usage"] if cmd else ""

    def reason_for(self, verb: str) -> str:
        cmd = self.by_name(verb)
        return cmd.get("chat_reason", "") if cmd else ""

    def palette_verbs(self) -> list[str]:
        """All command names plus the chat-only verbs (the dock lists both;
        unsupported commands stay selectable but refuse)."""
        return [c["name"] for c in self.commands()] + self.chat_only()


_PALETTE = _Palette()


def help_json() -> dict:
    return _PALETTE.load()


def reset_palette() -> None:
    _PALETTE.reset()


def classify(verb: str) -> str:
    return _PALETTE.classify(verb)


def usage_for(verb: str) -> str:
    return _PALETTE.usage_for(verb)


def reason_for(verb: str) -> str:
    return _PALETTE.reason_for(verb)


def palette_verbs() -> list[str]:
    return _PALETTE.palette_verbs()
