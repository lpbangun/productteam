# session.py — session-local verbs for the cockpit, matching lib/repl.sh.
#
# /clear /export /provider /workers /exit /quit keep the same semantics as
# the REPL: /export writes markdown under ${CONSULT_STATE_ROOT or
# ROOT/state/.cli}/sessions/, /provider mutates only this process's
# CONSULT_PROVIDER, /workers renders the file-backed strip. Nothing here
# writes durable state except /export (and what an invoked CLI already
# writes).

from __future__ import annotations

import json
import os
from datetime import datetime
from pathlib import Path

import adapter


def state_root(root: str | Path) -> Path:
    return Path(os.environ.get("CONSULT_STATE_ROOT") or (Path(root) / "state" / ".cli"))


def tokenize(line: str) -> list[str]:
    """Safe shell-like tokenizer (port of repl_tokenize): single/double
    quotes and backslashes are honored; $(), ; and metacharacters stay inert.
    The result is passed as argv — never re-parsed, never eval'd."""
    args: list[str] = []
    w = ""
    quote = ""
    i = 0
    n = len(line)
    while i < n:
        c = line[i]
        if quote:
            if c == quote:
                quote = ""
            elif c == "\\" and quote == '"' and i + 1 < n:
                nxt = line[i + 1]
                if nxt in "$`\"\\":
                    w += nxt
                    i += 1
                else:
                    w += "\\"
            else:
                w += c
        else:
            if c in ("'", '"'):
                quote = c
            elif c == "\\":
                if i + 1 < n:
                    i += 1
                    w += line[i]
                else:
                    w += "\\"
            elif c in (" ", "\t"):
                if w:
                    args.append(w)
                    w = ""
            else:
                w += c
        i += 1
    if w:
        args.append(w)
    return args


def split_slash(line: str) -> tuple[str, str]:
    """`/verb args…` on the first line → (verb, raw-args-string)."""
    first = line.split("\n", 1)[0].strip()
    if not first.startswith("/"):
        return "", ""
    rest = first[1:].strip()
    if not rest:
        return "", ""
    tokens = rest.split()
    return tokens[0].lower(), rest[len(tokens[0]):].strip()


def export_session(turns: list[tuple[str, str]], root: str | Path) -> str:
    """Write ${STATE_ROOT}/sessions/tui-<ts>.md and return the path."""
    sroot = state_root(root)
    ts = datetime.now().strftime("%Y%m%d-%H%M%S")
    out = sroot / "sessions" / f"tui-{ts}.md"
    out.parent.mkdir(parents=True, exist_ok=True)
    lines = [
        "# TUI session — " + datetime.now().strftime("%Y-%m-%d %H:%M:%S") + "\n",
    ]
    if not turns:
        lines.append("\n_No turns recorded yet._\n")
    for kind, text in turns:
        heading = {"user": "User", "cli": "Command", "provider": "Assistant",
                   "system": "System"}.get(kind, "Turn")
        lines.append(f"\n## {heading}\n\n{text}\n")
    out.write_text("".join(lines))
    return str(out)


def _found_agents() -> list[str]:
    cp = adapter.run_argv(["agents", "--json"])
    if cp.returncode != 0:
        raise RuntimeError(cp.stderr.strip() or f"agents --json exited {cp.returncode}")
    data = json.loads(cp.stdout)
    return [a["name"] for a in data if a.get("status") == "found"]


def set_provider(name: str | None) -> tuple[bool, str]:
    """Session-only CONSULT_PROVIDER (runtime_have / runtime_cycle semantics)."""
    try:
        found = _found_agents()
    except Exception as exc:  # noqa: BLE001 — surface honestly
        return False, f"provider: {exc}"
    if not found:
        return False, "no installed agent to cycle to — run `productteam agents`"
    current = os.environ.get("CONSULT_PROVIDER", "")
    base = os.path.basename(current) if current else ""
    if name:
        if name in found:
            os.environ["CONSULT_PROVIDER"] = name
            return True, f"provider → {name}"
        return False, f"provider {name} is not a usable installed agent"
    if base in found:
        idx = found.index(base)
        nxt = found[(idx + 1) % len(found)]
    else:
        nxt = found[0]
    os.environ["CONSULT_PROVIDER"] = nxt
    return True, f"provider → {nxt}"


def workers_rows(state_root: str | Path) -> list[dict]:
    """Latest session workers.tsv → row dicts (id role state mission provider
    start elapsed artifact). Empty list when nothing has been recorded yet."""
    runs = Path(state_root) / "runs"
    if not runs.is_dir():
        return []
    dirs = [
        d for d in runs.glob("session-*")
        if d.is_dir() and (d / "workers.tsv").is_file()
    ]
    dirs.sort(key=lambda d: (d / "workers.tsv").stat().st_mtime, reverse=True)
    for d in dirs:
        rows: list[dict] = []
        with open(d / "workers.tsv", encoding="utf-8", errors="replace") as fh:
            for raw in fh.readlines()[1:]:
                parts = raw.rstrip("\n").split("\t")
                if len(parts) >= 8:
                    rows.append({
                        "id": parts[0],
                        "role": parts[1],
                        "state": parts[2],
                        "mission": parts[3],
                        "provider": parts[4],
                        "start": parts[5],
                        "elapsed": parts[6],
                        "artifact": parts[7],
                    })
        if rows:
            return rows
    return []
