# app.py — ProductTeamApp: the optional Textual cockpit for bin/productteam.
#
# Layout follows state/harness-evolution/runs/tui-migration-20260812/visualizer
# (header → hairline → transcript → chips → slash dock → composer → footer).
# The dock sits immediately above the composer and never covers it; the
# composer is the filter — there is no second search input. Every CLI verb the
# cockpit runs goes through adapter.run_argv / run_argv_stream (argv only).
# Bare text runs a real provider turn through lib/tui/provider_turn.sh;
# Ctrl+C interrupts the provider process group (partial artifact preserved),
# a second Ctrl+C exits 130.

from __future__ import annotations

import json
import os
import signal
import subprocess
import threading
import time
from pathlib import Path

from rich.text import Text
from textual import events
from textual.app import App, ComposeResult
from textual.binding import Binding
from textual.widgets import OptionList, RichLog, Static, TextArea
from textual.widgets.option_list import Option

import adapter
import session
from theme import (
    CANVAS,
    FIELD,
    MUTE,
    OK,
    PRODUCTTEAM_THEME,
    RULE,
    TEXT,
    chip,
    md_line,
    role_tag,
    status_tag,
)

ROOT = Path(adapter.cli_path()).resolve().parent.parent
PROVIDER_TURN_SH = Path(__file__).resolve().parent / "provider_turn.sh"

CSS = f"""
Screen {{
    layout: vertical;
    background: {CANVAS};
    color: {TEXT};
}}
#header {{
    height: 1;
    color: {TEXT};
    text-style: bold;
    padding: 0 1;
    background: {CANVAS};
}}
#rule {{
    height: 1;
    background: {RULE};
}}
#transcript {{
    height: 1fr;
    background: {CANVAS};
    color: {TEXT};
    border: none !important;
    padding: 0 1;
    text-wrap: wrap;
}}
#chips {{
    height: 1;
    background: {CANVAS};
    color: {MUTE};
    padding: 0 1;
}}
#dock {{
    display: none;
    height: auto;
    max-height: 10;
    background: {FIELD};
    color: {TEXT};
    border: none !important;
    border-top: solid {RULE};
}}
#dock.visible {{
    display: block;
}}
#composer {{
    height: 3;
    background: {FIELD};
    color: {TEXT};
    border: none !important;
    padding: 0 1;
}}
#composer:focus {{
    border: none !important;
}}
#footer {{
    height: 1;
    color: {MUTE};
    padding: 0 1;
    background: {CANVAS};
}}
"""


class Composer(TextArea):
    """Unlabelled multiline composer.

    Enter sends; Shift+Enter inserts a newline. While the slash dock is
    visible, Tab completes the selected verb, ↑/↓ move the dock selection
    (the composer cursor is stopped), and Esc closes the dock."""

    async def _on_key(self, event: events.Key) -> None:
        key = event.key
        app: "ProductTeamApp" = self.app
        if key == "enter":
            event.prevent_default()
            event.stop()
            app.submit_composer()
            return
        if key == "shift+enter":
            event.prevent_default()
            event.stop()
            self.insert("\n")
            return
        if key == "escape":
            event.prevent_default()
            event.stop()
            app.on_composer_escape()
            return
        if app.dock_visible():
            if key == "tab":
                event.prevent_default()
                event.stop()
                app.complete_dock()
                return
            if key in ("up", "down"):
                event.prevent_default()
                event.stop()
                app.dock_move(-1 if key == "up" else 1)
                return
        await super()._on_key(event)


class ProductTeamApp(App):
    """The cockpit. Read-only presenter; `bin/productteam` stays the sole
    domain, judgment, workspace, provider, and durable-state writer."""

    TITLE = "ProductTeam"
    CSS = CSS
    BINDINGS = [
        Binding("ctrl+c", "interrupt_provider", "Interrupt", priority=True, show=False),
    ]

    def __init__(self) -> None:
        super().__init__()
        self.register_theme(PRODUCTTEAM_THEME)
        self._engagement = ""
        self._mode = "—"
        self._overall: float | None = None
        self._turns: list[tuple[str, str]] = []
        self._chips_text: list[dict] = []
        self._md_fence = False
        self._md_buffer = ""
        self._dock_verbs: list[str] = []
        self._provider_proc: subprocess.Popen | None = None
        self._provider_active = False
        self._provider_interrupted = False
        self._provider_started_at = 0.0
        self._alive = True
        self._cli_busy = False

    # ── compose / mount ──────────────────────────────────────────────
    def compose(self) -> ComposeResult:
        yield Static(id="header")
        yield Static(id="rule")
        yield RichLog(id="transcript", wrap=True, highlight=False, markup=False)
        yield Static(id="chips")
        yield OptionList(id="dock")
        yield Composer(id="composer")
        yield Static(id="footer", markup=False)

    def on_mount(self) -> None:
        self.theme = "productteam"
        self.query_one("#footer", Static).update("enter send · tab complete · ↑↓ choose · esc close")
        self.composer.focus()
        threading.Thread(target=self._seed, daemon=True).start()
        self.set_interval(2.0, self._refresh_chips)
        self._refresh_chips()

    def on_unmount(self) -> None:
        self._alive = False
        proc = self._provider_proc
        if proc is not None and proc.poll() is None:
            try:
                os.killpg(proc.pid, signal.SIGKILL)
            except (ProcessLookupError, PermissionError):
                pass

    def _call(self, fn, *args) -> None:
        """call_from_thread wrapper that tolerates a stopping app.

        A callback may already be queued when the app unmounts (widgets
        pruned before the future runs); a worker-thread UI update must never
        take the app down with it."""
        if not self._alive:
            return
        try:
            self.call_from_thread(fn, *args)
        except Exception:
            pass

    # ── widget accessors ─────────────────────────────────────────────
    @property
    def header(self) -> Static:
        return self.query_one("#header", Static)

    @property
    def transcript(self) -> RichLog:
        return self.query_one("#transcript", RichLog)

    @property
    def chips(self) -> Static:
        return self.query_one("#chips", Static)

    @property
    def dock(self) -> OptionList:
        return self.query_one("#dock", OptionList)

    @property
    def composer(self) -> Composer:
        return self.query_one("#composer", Composer)

    def transcript_text(self) -> str:
        return "\n".join(line.text for line in self.transcript.lines)

    def dock_visible(self) -> bool:
        return self.dock.has_class("visible")

    # ── seed: real status, header projections, chips ─────────────────
    def _seed(self) -> None:
        try:
            cp = adapter.run_argv(["status", "--json"])
            data = json.loads(cp.stdout) if cp.returncode == 0 else None
        except Exception:
            data = None
        engagements = (data or {}).get("engagements", [])
        self._call(self._seed_header, engagements)
        try:
            cp2 = adapter.run_argv(["status"])
        except Exception as exc:
            self._call(self._write_line, Text(f"status unavailable: {exc}", style=MUTE))
            return
        if cp2.returncode == 0:
            if cp2.stdout.strip():
                self._call(self._add_turn, "cli", cp2.stdout)
            for line in cp2.stdout.splitlines():
                self._call(self._append_cli_line, line)
        else:
            self._call(self._write_line, Text(cp2.stderr.strip(), style=MUTE))

    def _seed_header(self, engagements: list[dict]) -> None:
        eng = self._pick_engagement(engagements)
        if eng:
            self._engagement = eng
            self._mode = self._read_mode(eng) or "—"
            self._overall = self._read_overall(eng)
        self._render_header()

    def _pick_engagement(self, engagements: list[dict]) -> str:
        names = [e.get("client", "") for e in engagements if e.get("client")]
        if "harness-cli" in names:
            return "harness-cli"
        for e in engagements:
            if e.get("scored"):
                return e.get("client", "")
        return names[0] if names else ""

    def _read_mode(self, eng: str) -> str:
        f = ROOT / "state" / "engagements" / eng / "engagement.md"
        try:
            for raw in f.read_text(encoding="utf-8", errors="replace").splitlines():
                if raw.startswith("Mode:"):
                    fields = raw.split()
                    if len(fields) >= 2:
                        return fields[1].replace("*", "").strip() or "—"
        except OSError:
            pass
        return ""

    def _read_overall(self, eng: str) -> float | None:
        runs = ROOT / "state" / "engagements" / eng / "runs"
        if not runs.is_dir():
            return None
        best: tuple[int, float] | None = None
        for d in runs.glob("iter-*"):
            if not d.is_dir():
                continue
            try:
                num = int(d.name.split("-", 1)[1])
            except (IndexError, ValueError):
                continue
            sf = d / "scores.json"
            if not sf.is_file():
                continue
            try:
                ov = json.loads(sf.read_text(encoding="utf-8")).get("overall")
                if isinstance(ov, (int, float)):
                    if best is None or num > best[0]:
                        best = (num, float(ov))
            except (OSError, ValueError):
                continue
        return best[1] if best else None

    def _render_header(self) -> None:
        t = Text()
        t.append("ProductTeam", style="bold")
        t.append(f" · {self._engagement or '—'}", style=MUTE)
        t.append(f" · {self._mode}")
        t.append(" · ")
        score = f"{self._overall:.1f}" if self._overall is not None else "—"
        t.append(score, style="bold " + OK if (self._overall or 0) >= 9 else MUTE)
        self.header.update(t)

    # ── chips (file-backed worker strip) ─────────────────────────────
    def _refresh_chips(self) -> None:
        try:
            self._chips_text = session.workers_rows(session.state_root(ROOT))
        except OSError:
            self._chips_text = []
        self._render_chips()

    def _render_chips(self) -> None:
        rows = self._chips_text
        t = Text()
        if self.size.width <= 40:
            running = [r for r in rows if r["state"] in ("running", "pending", "progress")]
            if running:
                r = running[0]
                t.append_text(chip(r["role"], r["state"]))
                n = len(rows) - 1
                if n > 0:
                    t.append(f"  +{n}", style=MUTE)
        else:
            for i, r in enumerate(rows):
                if i:
                    t.append("   ")
                t.append_text(chip(r["role"], r["state"]))
        self.chips.update(t)

    def on_resize(self) -> None:
        self._render_chips()

    # ── transcript writers ───────────────────────────────────────────
    def _write_line(self, renderable) -> None:
        self.transcript.write(renderable)

    def _append_cli_line(self, line: str) -> None:
        line = line.rstrip("\n")
        seg, self._md_fence = md_line(line, self._md_fence)
        self.transcript.write(seg)

    def _append_provider_chunk(self, data: str) -> None:
        self._md_buffer += data
        while "\n" in self._md_buffer:
            line, self._md_buffer = self._md_buffer.split("\n", 1)
            seg, self._md_fence = md_line(line, self._md_fence)
            self.transcript.write(seg)

    def _flush_provider_buffer(self) -> None:
        if self._md_buffer:
            seg, self._md_fence = md_line(self._md_buffer, self._md_fence)
            self.transcript.write(seg)
            self._md_buffer = ""

    def _echo(self, text: str) -> None:
        self.transcript.write(Text(text))
        self._add_turn("system", text)

    def _echo_muted(self, text: str) -> None:
        self.transcript.write(Text(text, style=MUTE))
        self._add_turn("system", text)

    def _add_turn(self, kind: str, text: str) -> None:
        if text:
            self._turns.append((kind, text))

    # ── slash dock ───────────────────────────────────────────────────
    def on_text_area_changed(self, event) -> None:
        self._refresh_dock()

    def _dock_prefix(self) -> str | None:
        """None when the composer's first line is not a slash command."""
        text = self.composer.text
        first = text.split("\n", 1)[0].strip()
        if not first.startswith("/"):
            return None
        rest = first[1:].strip()
        if not rest:
            return ""
        return rest.split()[0].lower()

    def _refresh_dock(self) -> None:
        prefix = self._dock_prefix()
        if prefix is None:
            self._close_dock()
            return
        try:
            verbs = adapter.palette_verbs()
            matches = [v for v in verbs if v.startswith(prefix)]
        except Exception as exc:
            self._close_dock()
            self._echo_muted(f"palette unavailable: {exc}")
            return
        matches.sort(key=lambda v: (0 if adapter.classify(v) in ("supported", "chat_only") else 1, v))
        self._dock_verbs = matches
        self.dock.add_class("visible")
        self.dock.set_options([Option(self._dock_prompt(v), v) for v in matches])
        if matches:
            self.dock.highlighted = 0

    def _dock_prompt(self, verb: str) -> Text:
        try:
            kind = adapter.classify(verb)
        except Exception:
            kind = "unknown"
        t = Text()
        if kind == "unsupported":
            t.append(f"/{verb}", style=MUTE)
            t.append("  unsupported", style=MUTE)
        elif kind == "chat_only":
            t.append(f"/{verb}", style="bold " + OK)
            t.append("  session verb", style=MUTE)
        else:
            t.append(f"/{verb}", style=TEXT)
            try:
                t.append("  " + adapter.usage_for(verb), style=MUTE)
            except Exception:
                pass
        return t

    def _close_dock(self) -> None:
        self.dock.remove_class("visible")

    def dock_move(self, delta: int) -> None:
        n = len(self._dock_verbs)
        if not n:
            return
        cur = self.dock.highlighted
        cur = 0 if cur is None else cur
        self.dock.highlighted = max(0, min(n - 1, cur + delta))

    def complete_dock(self) -> None:
        if not self._dock_verbs:
            return
        idx = self.dock.highlighted
        if idx is None or idx >= len(self._dock_verbs):
            return
        verb = self._dock_verbs[idx]
        self.composer.clear()
        self.composer.insert(f"/{verb} ")
        self.composer.focus()

    def on_composer_escape(self) -> None:
        if self.dock_visible():
            self._close_dock()
        elif self.composer.text.startswith("/"):
            self.composer.clear()

    # ── send ─────────────────────────────────────────────────────────
    def submit_composer(self) -> None:
        text = self.composer.text.rstrip()
        if not text:
            return
        dock_visible = self.dock_visible()
        first = text.split("\n", 1)[0].strip()
        typed_verb, typed_args = session.split_slash(first)
        if dock_visible:
            idx = self.dock.highlighted
            if idx is not None and idx < len(self._dock_verbs):
                selected = self._dock_verbs[idx]
                args = typed_args if (typed_verb and selected == typed_verb) else ""
                self.composer.clear()
                self._close_dock()
                self._run_slash(selected, args)
                return
        self.composer.clear()
        self._close_dock()
        if first.startswith("/"):
            self._run_slash(typed_verb, typed_args)
        else:
            self._add_turn("user", text)
            self._echo(text)
            self._start_provider_turn(text)

    # ── slash routing (session-local + registry-driven) ──────────────
    def _run_slash(self, verb: str, args: str) -> None:
        self._add_turn("user", f"/{verb}" + (f" {args}" if args else ""))
        self.transcript.write(Text(f"/{verb}" + (f" {args}" if args else "")))
        verb = verb.lower()
        tokens = session.tokenize(args)
        if verb in ("exit", "quit"):
            self.exit(0)
            return
        if verb == "clear":
            self.transcript.clear()
            self._turns = []
            return
        if verb == "export":
            try:
                path = session.export_session(self._turns, ROOT)
                self._echo_muted(f"wrote {path}")
            except OSError as exc:
                self._echo_muted(f"export failed: {exc}")
            return
        if verb == "provider":
            ok, msg = session.set_provider(tokens[0] if tokens else None)
            self._echo(msg)
            return
        if verb == "workers":
            rows = session.workers_rows(session.state_root(ROOT))
            if rows:
                t = Text()
                for i, r in enumerate(rows):
                    if i:
                        t.append("   ")
                    t.append_text(chip(r["role"], r["state"]))
                self.transcript.write(t)
            else:
                self._echo_muted("no worker activity yet")
            return
        try:
            kind = adapter.classify(verb)
        except Exception as exc:
            self._echo_muted(f"registry unavailable: {exc}")
            return
        if kind == "unknown":
            self._echo_muted(f"unknown /{verb} — /help")
        elif kind == "unsupported":
            reason = adapter.reason_for(verb)
            usage = adapter.usage_for(verb)
            self._echo_muted(f"/{verb} — {reason}")
            self._echo_muted(f"use the CLI: {usage}")
        elif kind == "supported":
            self._exec_cli([verb, *tokens])
        else:  # chat_only handled above
            self._echo_muted(f"unknown /{verb} — /help")

    # ── supported CLI verbs: argv + streamed markdown-lite ───────────
    def _exec_cli(self, argv: list[str]) -> None:
        self._cli_busy = True

        def on_line(line: str) -> None:
            self._call(self._append_cli_line, line)

        def run() -> None:
            try:
                extra = {"CONSULT_NO_SPLASH": ""} if argv[:1] == ["splash"] else None
                cp = adapter.run_argv_stream(argv, on_line=on_line, env=extra)
                out = (cp.stdout or "") + (cp.stderr or "")
                if out.strip():
                    self._call(self._add_turn, "cli", out)
                if cp.returncode != 0 and "usage:" in out:
                    try:
                        usage = adapter.usage_for(argv[0])
                    except Exception:
                        usage = ""
                    if usage and usage not in out:
                        self._call(self._echo, f"usage: {usage}")
            except adapter.ForbiddenTokenError as exc:
                self._call(self._echo_muted, str(exc))
            except subprocess.TimeoutExpired:
                self._call(self._echo_muted, f"… /{argv[0]} timed out after {adapter.TIMEOUT}s")
            except Exception as exc:
                self._call(self._echo_muted, f"/{argv[0]} failed: {exc}")
            finally:
                self._cli_busy = False

        threading.Thread(target=run, daemon=True).start()

    # ── bare text → real provider turn (process-group safe) ──────────
    def _start_provider_turn(self, prompt: str) -> None:
        self._provider_active = True
        self._provider_interrupted = False
        self._provider_started_at = time.monotonic()
        threading.Thread(target=self._provider_thread, args=(prompt,), daemon=True).start()

    def _provider_thread(self, prompt: str) -> None:
        env = dict(os.environ)
        env["CONSULT_STATE_ROOT"] = str(session.state_root(ROOT))
        try:
            proc = subprocess.Popen(
                ["bash", str(PROVIDER_TURN_SH), str(ROOT), prompt],
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                start_new_session=True,
                env=env,
            )
        except Exception as exc:
            self._provider_active = False
            self._call(self._provider_done, None, f"provider launch failed: {exc}")
            return
        self._provider_proc = proc
        art: str | None = None
        if proc.stdout is not None:
            try:
                line = proc.stdout.readline()
            except OSError:
                line = b""
            if line:
                text = line.decode(errors="replace").strip()
                if text.startswith("ARTIFACT="):
                    art = text[len("ARTIFACT="):]
        size = 0
        while proc.poll() is None:
            if art:
                size = self._drain_artifact(art, size)
            time.sleep(0.05)
        if art:
            size = self._drain_artifact(art, size)
            self._call(self._flush_provider_buffer)
            try:
                body = Path(art).read_text(encoding="utf-8", errors="replace")
            except OSError:
                body = ""
            if body.strip():
                self._call(self._add_turn, "provider", body)
        rc = proc.wait()
        self._provider_proc = None
        self._provider_active = False
        self._call(self._provider_done, rc, art)

    def _drain_artifact(self, art: str, size: int) -> int:
        try:
            with open(art, "r", encoding="utf-8", errors="replace") as fh:
                fh.seek(size)
                data = fh.read()
                if data:
                    size = fh.tell()
                    self._call(self._append_provider_chunk, data)
        except OSError:
            pass
        return size

    def _provider_done(self, rc: int | None, art: str | None) -> None:
        elapsed = int(time.monotonic() - self._provider_started_at)
        self._refresh_chips()
        if rc is None:
            self._echo_muted(str(art) if art else "provider turn failed")
            return
        if rc == 130:
            self.notify("Ctrl+C — interrupt", severity="warning")
            if art:
                self._echo_muted(f"Ctrl+C — partial output left on disk ({Path(art).name})")
            return
        state = "done" if rc == 0 else "failed"
        t = Text()
        t.append_text(status_tag(state))
        t.append("  ")
        t.append_text(role_tag("Analyst", active=rc == 0))
        t.append(f" · {elapsed}s")
        if art:
            t.append(f" · {Path(art).name}")
        self.transcript.write(t)
        if rc != 0:
            self.notify("provider failed", severity="error")
            self._echo_muted("provider refused — /agents · raw artifact kept on disk")

    # ── interrupt: first Ctrl+C kills the provider group, second exits ─
    def action_interrupt_provider(self) -> None:
        proc = self._provider_proc
        if proc is not None and proc.poll() is None and self._provider_active:
            if not self._provider_interrupted:
                self._provider_interrupted = True
                self.notify("Ctrl+C — interrupting provider, partial output kept", severity="warning")
                try:
                    os.killpg(proc.pid, signal.SIGINT)
                except (ProcessLookupError, PermissionError):
                    pass
                threading.Thread(target=self._ensure_stopped, args=(proc,), daemon=True).start()
            else:
                self.exit(130)
        else:
            self.exit(130)

    def _ensure_stopped(self, proc: subprocess.Popen) -> None:
        deadline = time.monotonic() + 2.0
        while time.monotonic() < deadline and proc.poll() is None:
            time.sleep(0.05)
        if proc.poll() is not None:
            return
        try:
            os.killpg(proc.pid, signal.SIGTERM)
        except (ProcessLookupError, PermissionError):
            pass
        deadline = time.monotonic() + 1.0
        while time.monotonic() < deadline and proc.poll() is None:
            time.sleep(0.05)
        if proc.poll() is None:
            try:
                os.killpg(proc.pid, signal.SIGKILL)
            except (ProcessLookupError, PermissionError):
                pass
