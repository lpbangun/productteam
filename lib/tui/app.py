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
import re
import signal
import subprocess
import threading
import time
from pathlib import Path

from rich.text import Text
from textual import events
from textual.app import App, ComposeResult
from textual.binding import Binding
from textual.containers import Horizontal
from textual.widgets import OptionList, RichLog, Static, TextArea
from textual.widgets.option_list import Option

import adapter
import session

from theme import (
    _EVIDENCE_RE,
    CANVAS,
    ERR,
    FIELD,
    MUTE,
    OK,
    PRODUCTTEAM_THEME,
    ROLE_STYLES,
    RULE,
    SPLASH_ROLES,
    TEXT,
    chip,
    command_continue,
    command_open,
    completion_card,
    md_line,
    role_tag,
    splash_render,
    split_evidence_line,
    status_glyph,
    status_style,
    turn,
)

# A leading signed delta on an evidence payload (`+5.5  path: text`).
_DELTA_RE = re.compile(r"^[+-][0-9.]+")

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
#splash {{
    display: none;
    height: 1fr;
    background: {CANVAS};
    color: {TEXT};
    padding: 0 1;
    text-wrap: wrap;
    overflow-x: hidden;
    overflow-y: hidden;
}}
#splash.visible {{
    display: block;
}}
#activity {{
    display: none;
    height: auto;
    min-height: 1;
    max-height: 4;
    background: {CANVAS};
    color: {TEXT};
    padding: 0 1;
    text-wrap: nowrap;
    overflow-x: hidden;
    overflow-y: hidden;
}}
#activity.visible {{
    display: block;
}}
#transcript {{
    height: 1fr;
    background: {CANVAS};
    color: {TEXT};
    border: none !important;
    padding: 0 1;
    text-wrap: wrap;
}}
#transcript.splashed {{
    display: none;
}}
#chips {{
    height: 1;
    background: {CANVAS};
    padding: 0 1;
    overflow-x: hidden;
    overflow-y: hidden;
}}
RoleChip {{
    height: 1;
    width: auto;
    background: {CANVAS};
}}
RoleChip:focus {{
    outline: none;
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
#dock.evidence {{
    border: solid {RULE} !important;
}}
#composer-region {{
    height: 3;
    background: {FIELD};
}}
#role-prefix {{
    height: 3;
    width: 0;
    padding: 0;
    background: {FIELD};
    overflow: hidden;
}}
#role-prefix.pinned {{
    width: 12;
    padding: 0 0 0 1;
}}
#composer {{
    height: 3;
    width: 1fr;
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
#header.splashed,
#rule.splashed,
#activity.splashed,
#chips.splashed {{
    display: none;
}}
"""


class Composer(TextArea):
    """Unlabelled multiline composer.

    Enter sends; Shift+Enter inserts a newline. While a dock is visible,
    ↑/↓ move the dock selection (the composer cursor is stopped); Tab
    completes the slash verb only; Space toggles/selects ask options only;
    Esc closes per dock kind (slash close, ask cancel, confirm cancel)."""

    async def _on_key(self, event: events.Key) -> None:
        key = event.key
        app: "ProductTeamApp" = self.app
        if app._splash_consume_key(event):
            return
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
                # Tab completes the slash dock only; ask/confirm ignore it.
                event.prevent_default()
                event.stop()
                if app._dock_kind == "slash":
                    app.complete_dock()
                return
            if key in ("up", "down"):
                event.prevent_default()
                event.stop()
                app.dock_move(-1 if key == "up" else 1)
                return
            if key == "space":
                # Space controls the ask dock only (slash inserts a literal
                # space; confirm and evidence ignore it).
                if app._dock_kind == "ask":
                    event.prevent_default()
                    event.stop()
                    app.ask_toggle()
                    return
                if app._dock_kind in ("confirm", "evidence"):
                    event.prevent_default()
                    event.stop()
                    return
        await super()._on_key(event)


class RoleChip(Static):
    """One focusable/clickable role chip in the single-row #chips region.

    Focus/selection renders bold in the role's locked identity hue (no
    border, no outline, no extra hue). Enter/Space select the role and
    restore composer focus; Left/Right cycle the selection while the chips
    row keeps focus."""

    can_focus = True

    def __init__(self, role: str, lead: bool = False, **kwargs) -> None:
        super().__init__(**kwargs)
        self._role = role
        self._lead = lead
        self._focused = False

    def _refresh(self) -> None:
        app: "ProductTeamApp" = self.app
        active = self._focused or (app._pinned and app._target_role == self._role)
        tag = role_tag(self._role, active=active)
        status = app._role_status.get(self._role)
        t = Text()
        if status:
            # L14: a completed/failed role carries ✓/✗ on its chip too.
            t.append(status_glyph(status), style=status_style(status))
            t.append(" ")
            t.append_text(tag)
        else:
            if self._lead:
                t.append(" ")
            t.append_text(tag)
        # L12: at <=40 columns exactly one identity renders with the hidden
        # count (`{glyph} {role} +N`); the other chips are display:none.
        if app.size.width <= 40 and self.styles.display != "none":
            t.append(f" +{len(app._ROLE_CHIP_ORDER) - 1}", style=MUTE)
        self.update(t)

    def on_mount(self) -> None:
        self._refresh()

    def on_focus(self) -> None:
        self._focused = True
        self._refresh()

    def on_blur(self) -> None:
        self._focused = False
        self._refresh()

    def on_click(self, event: events.Click) -> None:
        event.stop()
        self.app.select_role(self._role)

    def on_key(self, event: events.Key) -> None:
        if self.app._splash_consume_key(event):
            return
        if event.key in ("enter", "space"):
            event.stop()
            self.app.select_role(self._role)
        elif event.key in ("left", "right"):
            event.stop()
            self.app.cycle_role(-1 if event.key == "left" else 1)


class ProductTeamApp(App):
    """The cockpit. Read-only presenter; `bin/productteam` stays the sole
    domain, judgment, workspace, provider, and durable-state writer."""

    TITLE = "ProductTeam"
    CSS = CSS
    BINDINGS = [
        Binding("ctrl+c", "interrupt_provider", "Interrupt", priority=True, show=False),
        # Replaces Textual's priority ctrl+q quit so the boot splash can
        # consume it like any other key; the normal quit path is preserved
        # once the splash has finished.
        Binding("ctrl+q", "quit_splash_or_exit", "Quit", priority=True, show=False),
    ]

    def __init__(self) -> None:
        super().__init__()
        self.register_theme(PRODUCTTEAM_THEME)
        self._cwd_label = Path.cwd().name or str(Path.cwd())
        self._overall: float | None = None
        self._header_score: float | None = None
        self._turns: list[tuple[str, str]] = []
        self._md_fence = False
        self._md_buffer = ""
        self._dock_verbs: list[str] = []
        # Command rail state: the slash echo opens one mute Command turn and
        # every streamed summary line continues it. Session verbs never set
        # it — their responses are toasts/chips/clear/exit, not Command.
        self._command_open = False
        # D12/D25 evidence: the active CLI argv (report/bench only) plus the
        # buffered evidence payloads split at stream time; the dock opens on
        # completion only when the buffer is non-empty.
        self._cli_argv: list[str] | None = None
        self._evidence_paths: list[str] = []
        # Append-only session toast log (message, severity) fed by notify;
        # tests observe toasts here instead of scraping widget internals.
        self._toasts: list[tuple[str, str]] = []
        self._provider_proc: subprocess.Popen | None = None
        self._provider_active = False
        self._provider_interrupted = False
        self._provider_started_at = 0.0
        self._alive = True
        self._cli_busy = False
        self._target_role = "Principal"
        self._pinned = False  # team mode by default; a chip or typed @Role pins
        self._active_turn_role = "Principal"
        self._provider_speech_opened = False
        self._activity_session_dir = (
            session.state_root(ROOT) / "runs" / f"session-{os.getpid()}"
        )
        self._activity_rows: list[dict] = []
        self._activity_spinner = 0
        self._activity_timer = None
        # One dock, one state machine: "slash" (existing), "ask" (structured
        # §6 event beside the live provider artifact), "confirm" (pre-run
        # write intercept). Opening ask/confirm closes the slash dock; the
        # slash refresh early-returns while the kind is not "slash".
        self._dock_kind = "slash"
        self._active_artifact: str | None = None
        self._ask_seen_id: str | None = None
        self._ask_event: dict | None = None
        self._ask_options: list[dict] = []
        self._ask_mode = "single"
        self._ask_role = "Principal"
        self._ask_selection: list[str] = []
        self._confirm_argv: list[str] | None = None
        self._confirm_label = ""
        # Boot splash state: active only between _splash_show and
        # _splash_finish. Step 0 is the idle frame; 1-4 glow the heads
        # Principal → Analyst → Builder → Principal; step 5 finishes.
        self._splash_active = False
        self._splash_step = 0
        self._splash_timer = None
        # L14: per-role completion status for the chip row (done/failed).
        self._role_status: dict[str, str] = {}
        # L10: first-run no-provider flag, set by the seed thread.
        self._no_provider = False

    # ── compose / mount ──────────────────────────────────────────────
    def compose(self) -> ComposeResult:
        yield Static(id="header")
        yield Static(id="rule")
        yield Static(id="splash", markup=False)
        yield RichLog(id="transcript", wrap=True, highlight=False, markup=False)
        yield Static(id="activity", markup=False)
        with Horizontal(id="chips"):
            for i, role in enumerate(self._ROLE_CHIP_ORDER):
                yield RoleChip(role, lead=bool(i), id=f"role-{role.lower()}")
        yield OptionList(id="dock")
        with Horizontal(id="composer-region"):
            yield Static(id="role-prefix", markup=False)
            yield Composer(id="composer")
        yield Static(id="footer", markup=False)

    def on_mount(self) -> None:
        self.theme = "productteam"
        self._render_activity()
        self._render_footer()
        self.composer.focus()
        self._render_chips()
        self._render_role_prefix()
        self._activity_timer = self.set_interval(0.2, self._poll_activity)
        threading.Thread(target=self._seed, daemon=True).start()
        # CONSULT_NO_SPLASH (non-empty, same semantics as lib/splash.sh)
        # boots straight to the idle cockpit; unset/empty shows the boot
        # splash over the seeded home. Boot-only: skip/finish/resize/slash
        # never replay it.
        if not os.environ.get("CONSULT_NO_SPLASH"):
            self._splash_show()


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

    def notify(
        self,
        message: str,
        *,
        severity: str = "information",
        timeout: float | None = None,
    ) -> None:
        """Record every session toast append-only on `_toasts` (message,
        severity) before the Textual toast chrome paints it."""
        self._toasts.append((message, severity))
        super().notify(message, severity=severity, timeout=timeout)

    # ── widget accessors ─────────────────────────────────────────────
    @property
    def header(self) -> Static:
        return self.query_one("#header", Static)

    @property
    def transcript(self) -> RichLog:
        return self.query_one("#transcript", RichLog)

    @property
    def splash(self) -> Static:
        return self.query_one("#splash", Static)

    @property
    def chips(self) -> Horizontal:
        return self.query_one("#chips", Horizontal)

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
    @property
    def activity(self) -> Static:
        return self.query_one("#activity", Static)

    @staticmethod
    def _elapsed(start: object, fallback: int = 0) -> str:
        try:
            seconds = max(0, int(time.time() - float(str(start))))
        except (TypeError, ValueError):
            seconds = max(0, int(fallback))
        return f"{seconds // 60}:{seconds % 60:02d}"

    def _read_activity_rows(self) -> list[dict]:
        path = self._activity_session_dir / "workers.tsv"
        try:
            with path.open(encoding="utf-8", errors="replace") as fh:
                lines = fh.readlines()
        except OSError:
            return []
        rows: list[dict] = []
        for raw in lines[1:]:
            parts = raw.rstrip("\n").split("\t")
            if len(parts) < 8:
                continue
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
        return rows

    def _live_activity_rows(self) -> list[dict]:
        return [
            row for row in self._activity_rows
            if row.get("state") in ("pending", "running", "progress")
        ]

    def _activity_width_cap(self) -> int:
        width = self.size.width
        if width >= 80:
            return 3
        if width >= 41:
            return 2
        return 1

    def _render_activity(self) -> None:
        live = self._live_activity_rows()
        if not live:
            self.activity.remove_class("visible")
            self.activity.update("")
            return
        self.activity.add_class("visible")
        shown = live[: self._activity_width_cap()]
        hidden = len(live) - len(shown)
        frames = "⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
        frame = frames[self._activity_spinner % len(frames)]
        rendered = Text()
        for i, row in enumerate(shown):
            if i:
                rendered.append("\n")
            role = row.get("role", "") or "Principal"
            _, hue = ROLE_STYLES.get(role, ("", MUTE))
            rendered.append(frame, style=hue)
            rendered.append(" ")
            rendered.append_text(role_tag(role, active=True))
            mission = row.get("mission", "")
            provider = row.get("provider", "")
            facts = [x for x in (mission, provider) if x]
            if facts:
                rendered.append(" · ", style=MUTE)
                rendered.append(" · ".join(facts), style=TEXT)
            rendered.append(" · " + self._elapsed(row.get("start"), row.get("elapsed", 0)), style=MUTE)
        if hidden and self.size.width <= 40:
            rendered.append(f"\n+{hidden}", style=MUTE)
        self.activity.update(rendered)

    def _busy_context(self) -> tuple[str, str]:
        live = self._live_activity_rows()
        if live:
            row = min(live, key=lambda r: float(r.get("start") or 0))
            provider = row.get("provider", "")
            elapsed = self._elapsed(row.get("start"), row.get("elapsed", 0))
            if provider:
                return elapsed, os.path.basename(provider)
        if self._provider_active:
            seconds = max(0, int(time.monotonic() - self._provider_started_at))
            elapsed = f"{seconds // 60}:{seconds % 60:02d}"
        else:
            elapsed = "0:00"
        provider = os.path.basename(os.environ.get("CONSULT_PROVIDER", "")) or "—"
        return elapsed, provider

    def _render_footer(self) -> None:
        footer = self.query_one("#footer", Static)
        if self._splash_active:
            footer.update("enter continue · any key skip")
            return
        if self.dock_visible():
            if self._dock_kind == "ask":
                n = len(self._ask_options)
                if self._ask_mode == "single":
                    idx = self.dock.highlighted
                    k = 0 if idx is None else min(max(idx, 1), n)
                    verb = "select"
                else:
                    k = len(self._ask_selection)
                    verb = "toggle"
                footer.update(
                    f"{k} of {n} · ↑↓ choose · space {verb} · enter confirm · esc cancel"
                )
                return
            if self._dock_kind == "confirm":
                footer.update("↑↓ choose · enter run · esc cancel")
                return
            if self._dock_kind == "evidence":
                footer.update("↑↓ · esc close")
                return
            footer.update("enter run · tab complete · ↑↓ choose · esc close")
            return
        busy = self._provider_active or bool(self._live_activity_rows())
        if not busy:
            if self._no_provider:
                footer.update("/agents · /onboarding · /help")
            else:
                footer.update("enter send · / commands · tab agents")
            return
        elapsed, provider = self._busy_context()
        if self.size.width <= 40:
            footer.update(f"ctrl+c · {elapsed}")
        else:
            footer.update(f"ctrl+c interrupt · {elapsed} · {provider}")

    def _poll_activity(self) -> None:
        try:
            self.query_one("#activity", Static)
        except Exception:
            return
        # While a CLI verb streams (run_argv_stream → _append_cli_line), skip
        # chrome repaints: 5 Hz header/footer/activity paints on the UI thread
        # must not delay or erase the streamed status tail. This does not mark
        # the provider busy or change slash routing; the timer resumes its
        # normal cadence once the CLI finishes (_cli_busy False).
        if self._cli_busy:
            return
        self._poll_ask()
        rows = self._read_activity_rows()
        self._activity_rows = rows
        self._activity_spinner = (self._activity_spinner + 1) % 10
        self._render_activity()
        self._render_footer()
        self._render_chips()
        self._render_header()
    def on_resize(self, event: events.Resize) -> None:
        # Resize is chrome-only: preserve the current focus target. It
        # never restarts or replays the boot splash (post-skip resize
        # keeps #splash hidden; the stepper repaints on its own ticks).
        self._render_header()
        self._render_activity()
        self._render_chips()
        self._render_footer()


    # ── boot splash (D16/D26): TUI-owned overlay on the transcript slot ──
    # The splash is a non-focusable #splash Static occupying the
    # transcript's 1fr slot while visible; the RichLog takes class
    # `splashed` (display: none) so the two never split the field. _seed
    # still fills home underneath and skip/finish never clear or replay
    # the transcript. Step 0 paints the idle frame immediately; production
    # glows advance on a 0.4s interval Principal → Analyst → Builder →
    # Principal and the fifth advance finishes naturally. Tests drive
    # _splash_advance directly.

    def _splash_show(self) -> None:
        """Paint the idle splash now and start the 0.4s glow stepper. L2
        splash-only plane: header, rule, activity, and chips are hidden
        while the splash lives; the composer and footer stay visible."""
        self._splash_active = True
        self._splash_step = 0
        self.splash.update(splash_render(self.size.width, None))
        self.splash.add_class("visible")
        self.transcript.add_class("splashed")
        for wid in ("header", "rule", "activity", "chips"):
            try:
                self.query_one(f"#{wid}").add_class("splashed")
            except Exception:
                pass
        self._render_footer()
        self._splash_timer = self.set_interval(0.4, self._splash_advance)

    def _splash_advance(self) -> None:
        """One stepper tick: the glow cycles Principal → Analyst → Builder
        → Principal (steps 1..4 wrap forever). L1: never auto-finishes —
        the splash persists until Enter (continue) or any other key
        (skip)."""
        if not self._splash_active:
            return
        self._splash_step = (self._splash_step % 4) + 1
        glow = SPLASH_ROLES[(self._splash_step - 1) % len(SPLASH_ROLES)]
        self.splash.update(splash_render(self.size.width, glow))

    def _splash_finish(self) -> None:
        """Hide the splash and restore the idle cockpit. Idempotent; shared
        by any-key skip, Enter continue, Ctrl+C, and other skip bindings.
        Never clears or writes the transcript — the seeded home simply
        becomes visible."""
        if not self._splash_active:
            return
        if self._splash_timer is not None:
            self._splash_timer.stop()
            self._splash_timer = None
        self._splash_active = False
        self.splash.remove_class("visible")
        self.transcript.remove_class("splashed")
        for wid in ("header", "rule", "activity", "chips"):
            try:
                self.query_one(f"#{wid}").remove_class("splashed")
            except Exception:
                pass
        self.composer.focus()
        self._render_footer()

    def _splash_consume_key(self, event: events.Key) -> bool:
        """First in every key path while the splash is live: any key skips
        it. The key is consumed (never forwarded), so nothing is typed,
        submitted, or dock-opened. Returns True when the splash consumed
        the event."""
        if not self._splash_active:
            return False
        event.prevent_default()
        event.stop()
        self._splash_finish()
        return True


    # ── structured ask: file-backed §6 seam beside the live artifact ──
    # The only accepted ask control is a structured event read from
    # `Path(self._active_artifact).parent / "ask.json"` — the sibling of the
    # live provider artifact, never a glob, never a fixed path, never
    # scraped from transcript prose. Polled from the 0.2s activity timer
    # while a provider turn is live and the dock is in the plain slash
    # state; a consumed or invalid file is retired once (os.replace) and an
    # id-keyed guard prevents any re-open.
    def _poll_ask(self) -> None:
        if not self._provider_active or self._dock_kind != "slash":
            return
        art = self._active_artifact
        if not art:
            return
        path = Path(art).parent / "ask.json"
        if not path.is_file():
            return
        try:
            event = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, ValueError) as exc:
            self._retire_ask(path, "invalid")
            self._echo_muted(f"ask ignored: {exc}")
            return
        if not isinstance(event, dict):
            self._retire_ask(path, "invalid")
            self._echo_muted("ask ignored: not an object")
            return
        if event.get("id") == self._ask_seen_id:
            # Already consumed once: a re-emitted file with the same id must
            # never re-open the dock; retire it so the poll does not loop.
            self._retire_ask(path, "done")
            return
        err = self._validate_ask(event)
        if err:
            self._retire_ask(path, "invalid")
            self._echo_muted(f"ask ignored: {err}")
            return
        self._open_ask_dock(event)

    def _retire_ask(self, path: Path, kind: str) -> None:
        """os.replace the consumed/invalid ask file so the poll never
        replays it (answered/cancelled → ask.json.done, malformed →
        ask.json.invalid)."""
        try:
            os.replace(path, path.with_name(f"ask.json.{kind}"))
        except OSError:
            pass

    def _validate_ask(self, event: dict) -> str | None:
        """Canonical §6 validation. Returns a specific reason string when
        the event is not a valid ask, else None. No fake question, no
        spawn, no retry-loop on violation."""
        if event.get("event") != "ask":
            return "event is not 'ask'"
        ask_id = event.get("id")
        if not isinstance(ask_id, str) or not ask_id.strip():
            return "missing stable id"
        role = event.get("role")
        if role not in ("Principal", "Analyst", "Builder", "Critic"):
            return f"invalid role {role!r}"
        question = event.get("question")
        if not isinstance(question, str) or not question.strip():
            return "missing question"
        mode = event.get("mode")
        if mode not in ("single", "multi"):
            return f"invalid mode {mode!r}"
        options = event.get("options")
        if not isinstance(options, list) or not options:
            return "missing options"
        seen: set[str] = set()
        for i, opt in enumerate(options):
            if not isinstance(opt, dict):
                return f"option {i} is not an object"
            oid = opt.get("id")
            if not isinstance(oid, str) or not oid.strip():
                return f"option {i} missing id"
            if oid in seen:
                return f"duplicate option id {oid!r}"
            seen.add(oid)
            if not isinstance(opt.get("label"), str) or not opt["label"].strip():
                return f"option {oid!r} missing label"
            if not isinstance(opt.get("description"), str) or not opt["description"].strip():
                return f"option {oid!r} missing description"
            if not isinstance(opt.get("recommended"), bool):
                return f"option {oid!r} recommended is not boolean"
        if mode == "single":
            recs = [o for o in options if o.get("recommended")]
            if len(recs) > 1:
                return "more than one recommended option for single mode"
        default = event.get("default")
        if default is None:
            default = []
        if not isinstance(default, list) or not all(
            isinstance(d, str) for d in default
        ):
            return "default is not an array of ids"
        unknown = [d for d in default if d not in seen]
        if unknown:
            return f"default ids not in options: {unknown}"
        if mode == "single" and len(default) > 1:
            return "single default has more than one id"
        return None

    def _open_ask_dock(self, event: dict) -> None:
        """Valid ask: consume once, render the exact question as one real
        colored role turn, then the option rows (label bold when
        recommended or in default, mute description line, recommended
        mark). The composer stays mounted below and focused."""
        self._dock_kind = "ask"
        self._ask_event = event
        self._ask_role = event["role"]
        self._ask_mode = event["mode"]
        self._ask_options = list(event["options"])
        self._ask_selection = [d for d in (event.get("default") or [])]
        self._ask_seen_id = event.get("id")
        self._write_turn(self._ask_role, event["question"])
        self._render_ask_dock()

    def _render_ask_dock(self, highlight: int | None = None) -> None:
        """OMP ask chrome (L16): row 0 is the title `Ask · k of n`, rows
        1..n are the options. The dock stays above the composer, which
        keeps focus."""
        options = [self._ask_title_row()]
        options += [self._ask_option_row(i) for i in range(len(self._ask_options))]
        self.dock.set_options(options)
        self.dock.add_class("visible")
        idx = self.dock.highlighted if highlight is None else highlight
        if idx is None:
            idx = 1
        self.dock.highlighted = max(1, min(len(self._ask_options), idx))
        self.composer.focus()
        self._render_footer()

    def _ask_title_row(self) -> Option:
        """Mute title row: `Ask · {k} of {n}` — the in-dock live count."""
        n = len(self._ask_options)
        if self._ask_mode == "multi":
            k = len(self._ask_selection)
        else:
            k = 1 if self._ask_selection else 0
        t = Text()
        t.append("Ask", style="bold")
        t.append(f" · {k} of {n}", style=MUTE)
        return Option(t, "_ask_title")

    def _ask_option_row(self, index: int) -> Option:
        """One ask row: selection marker, label (bold when recommended or in
        default), the literal `recommended` mark (never ★), then a mute
        description line."""
        opt = self._ask_options[index]
        oid = opt["id"]
        selected = oid in self._ask_selection
        recommended = bool(opt.get("recommended"))
        in_default = oid in (self._ask_event or {}).get("default", [])
        t = Text()
        t.append("● " if selected else "○ ", style=OK if selected else MUTE)
        t.append(opt["label"], style="bold" if (recommended or in_default) else None)
        if recommended:
            t.append("  recommended", style=OK)
        t.append("\n")
        t.append("   ", style=MUTE)
        t.append(opt["description"], style=MUTE)
        return Option(t, oid)

    def ask_toggle(self) -> None:
        """Space on the ask dock: single selects the highlighted id, multi
        toggles its membership; the dock and live k of n re-render."""
        if self._dock_kind != "ask" or not self._ask_options:
            return
        idx = self.dock.highlighted
        if idx is None or idx < 1 or idx > len(self._ask_options):
            return
        oid = self._ask_options[idx - 1]["id"]
        if self._ask_mode == "single":
            self._ask_selection = [oid]
        elif oid in self._ask_selection:
            self._ask_selection = [s for s in self._ask_selection if s != oid]
        else:
            self._ask_selection.append(oid)
        self._render_ask_dock(highlight=idx)

    def _confirm_ask(self) -> None:
        """Enter on the ask dock: persist the structured answer atomically,
        consume once, close/refocus."""
        self._ask_answer(False)

    def _cancel_ask(self) -> None:
        """Esc on the ask dock: persist cancelled=true with an empty
        selection, consume once, close/refocus."""
        self._ask_answer(True)

    def _ask_answer(self, cancelled: bool) -> None:
        event = self._ask_event
        if event is None:
            self._close_dock()
            return
        ask_id = event.get("id")
        art = self._active_artifact
        if art:
            answer_path = Path(art).parent / "ask.answer.json"
            payload = {
                "event": "ask-answer",
                "ask_id": ask_id,
                "answers": [] if cancelled else list(self._ask_selection),
                "cancelled": cancelled,
            }
            tmp = answer_path.with_name("ask.answer.json.tmp")
            try:
                tmp.write_text(json.dumps(payload), encoding="utf-8")
                os.replace(tmp, answer_path)
            except OSError:
                pass
            self._retire_ask(Path(art).parent / "ask.json", "done")
        self._ask_seen_id = ask_id
        self._close_dock()

    # ── confirm: pre-run write intercept (D13) ───────────────────────
    # Only these write-carrying tokenized argvs are intercepted before the
    # supported branch of _run_slash; every other argv (including `/gh
    # preflight`) takes the unchanged path. Run reuses the stored original
    # argv list; Cancel/Esc executes nothing. `checks ... --allow-dirty` is
    # matched by flag anywhere after the verb because checks requires a
    # <client> first arg — the legacy two-token tuple matched an argv the
    # real command can never run (`checks` dies on a client named
    # `--allow-dirty`).
    _CONFIRM_ARGVS = (
        ("gh", "merge"),
        ("onboarding", "--yes"),
    )

    def _needs_confirm(self, argv: list[str]) -> bool:
        if tuple(argv) in self._CONFIRM_ARGVS:
            return True
        return argv[:1] == ["checks"] and "--allow-dirty" in argv[1:]

    def _open_confirm(self, verb: str, args: str, argv: list[str]) -> None:
        """Open the single #dock in confirm state (L17): title row
        `Confirm write · 1 of 2`, then `Run` (default highlighted) and
        `Cancel` with the locked descriptions. Does not call _exec_cli
        yet."""
        self._dock_kind = "confirm"
        self._confirm_argv = argv
        self._confirm_label = f"/{verb}" + (f" {args}" if args else "")
        title = Text()
        title.append("Confirm write", style="bold")
        title.append(" · 1 of 2", style=MUTE)
        run_t = Text()
        run_t.append("● ", style=OK)
        run_t.append("Run", style="bold")
        run_t.append("\n   ", style=MUTE)
        run_t.append("argv to bin/productteam. Output streams as a Command turn.", style=MUTE)
        cancel_t = Text()
        cancel_t.append("○ ", style=MUTE)
        cancel_t.append("Cancel", style=TEXT)
        cancel_t.append("\n   ", style=MUTE)
        cancel_t.append("Nothing is spawned.", style=MUTE)
        self.dock.set_options([
            Option(title, "_confirm_title"),
            Option(run_t, "run"),
            Option(cancel_t, "cancel"),
        ])
        self.dock.add_class("visible")
        self.dock.highlighted = 1
        self.composer.focus()
        self._render_footer()

    def _confirm_choice(self) -> None:
        """Enter on the confirm dock: Run (highlighted != 2) executes the
        stored original argv — never re-tokenized, never rewritten; Cancel
        (highlighted == 2) executes nothing."""
        argv = self._confirm_argv
        run = self.dock.highlighted != 2
        self._close_dock()
        if run and argv is not None:
            self._exec_cli(argv)

    # ── evidence dock: D12/D25 labelled path panel ───────────────────
    # The existing single #dock OptionList, opened only when a /report or
    # /bench stream buffered a non-empty path list. Display-only: arrows
    # highlight, Space/Tab no-op, Enter/Esc close and restore composer
    # focus — no file spawn, no second widget, no new region.
    def _maybe_open_evidence(self) -> None:
        """Called from the _exec_cli stream finally (UI thread via _call):
        an empty buffer paints no panel and no labelled chrome."""
        if not self._evidence_paths:
            return
        self._open_evidence_dock()

    def _open_evidence_dock(self) -> None:
        self._dock_kind = "evidence"
        cap = 3 if self.size.width <= 40 else 6
        shown = self._evidence_paths[:cap]
        hidden = len(self._evidence_paths) - len(shown)
        options = [self._evidence_label_row()]
        options += [self._evidence_path_row(p, i) for i, p in enumerate(shown)]
        if hidden:
            options.append(Option(Text(f"+{hidden}", style=MUTE), "_more"))
        self.dock.set_options(options)
        self.dock.add_class("visible")
        self.dock.add_class("evidence")
        self.dock.highlighted = 0
        self.composer.focus()
        self._render_footer()

    def _evidence_label_row(self) -> Option:
        """Mute prompt row: `evidence · {n} files` — never a path id."""
        n = len(self._evidence_paths)
        return Option(Text(f"evidence · {n} files", style=MUTE), "_label")

    def _evidence_path_row(self, payload: str, index: int) -> Option:
        """One evidence payload: optional signed delta ok/err, bold path,
        mute `: text` remainder. The id is display-only (never run)."""
        t = Text()
        rest = payload
        m = _DELTA_RE.match(rest)
        if m:
            t.append(m.group(0), style=OK if rest[0] == "+" else ERR)
            rest = rest[m.end():]
            t.append(rest[: len(rest) - len(rest.lstrip())], style=MUTE)
            rest = rest.lstrip()
        m = _EVIDENCE_RE.match(rest)
        if m:
            t.append(m.group(1), style="bold")
            t.append(": " + m.group(2), style=MUTE)
        else:
            t.append(rest, style="bold")
        return Option(t, f"ev-{index}")


    # ── seed: filtered status --json home + honest cwd header ────────
    # Home rows are a display-only projection of scored sessions; the full
    # `status` prose never enters the transcript or `_turns`.
    def _check_no_provider(self) -> bool:
        """L10: `agents --json` reports no installed runtime/provider → the
        locked first-run copy owns the first paint (even when scored
        sessions exist). Any CLI failure or unparseable output counts as
        provider-present, so a broken probe can never fake the empty state."""
        try:
            cp = adapter.run_argv(["agents", "--json"])
            if cp.returncode != 0:
                return False
            data = json.loads(cp.stdout or "{}")
        except Exception:
            return False
        if isinstance(data, list):
            return not any(
                isinstance(a, dict) and a.get("status") == "found" for a in data
            )
        if isinstance(data, dict):
            found_keys = [k for k in ("agents", "installed")
                          if isinstance(data.get(k), list)]
            if not found_keys:
                return False  # unknown shape → provider-present
            return not any(data.get(k) for k in found_keys)
        return False

    def _seed_no_provider(self) -> None:
        """The locked no-provider first-run copy — display only, never the
        status dump, never the scored-home empty copy. Chips + empty
        composer remain (L10)."""
        t = Text()
        t.append("no installed agent", style=MUTE)
        t.append("\n", style=MUTE)
        t.append("run /agents  or  productteam onboarding", style=MUTE)
        self.transcript.write(t)

    def _seed(self) -> None:
        try:
            cp = adapter.run_argv(["status", "--json"])
            data = json.loads(cp.stdout) if cp.returncode == 0 else None
        except Exception:
            data = None
        engagements = (data or {}).get("engagements", [])
        # Honest cwd projection: _overall exists only when an engagement's
        # Repo: metadata resolves to this process's cwd. An unmapped header
        # may later mirror the newest displayed home row; it never reads a
        # Mode/Directive or picks a special engagement name.
        cwd = Path.cwd().resolve()
        mapped: str | None = None
        for e in engagements:
            client = e.get("client", "")
            if client and self._repo_path(client) == cwd:
                mapped = client
                break
        self._cwd_label = cwd.name or str(cwd)
        self._overall = self._read_overall(mapped) if mapped else None
        self._header_score = self._overall
        if self._check_no_provider():
            self._no_provider = True
            self._call(self._render_header)
            self._call(self._render_footer)
            self._call(self._seed_no_provider)
            return
        self._no_provider = False
        self._call(self._render_header)
        self._call(self._seed_home, engagements, mapped)

    def _repo_path(self, client: str) -> Path | None:
        """engagement.md `Repo:` path, resolved (None when absent/unreadable)."""
        f = ROOT / "state" / "engagements" / client / "engagement.md"
        try:
            for raw in f.read_text(encoding="utf-8", errors="replace").splitlines():
                if raw.startswith("Repo:"):
                    p = raw.split(":", 1)[1].strip()
                    if p:
                        return Path(p).resolve()
        except OSError:
            pass
        return None

    def _latest_valid_scores(self, eng: str) -> tuple[int, float, float] | None:
        """Latest valid scores.json for an engagement: (numeric iter,
        overall, file st_mtime), or None. The latest valid iter is the
        largest numeric N (iter-10 beats iter-9 — never lexicographic);
        that file's mtime is the honest recency key the home sort uses
        (the status JSON carries no mtime field)."""
        runs = ROOT / "state" / "engagements" / eng / "runs"
        if not runs.is_dir():
            return None
        best: tuple[int, float, float] | None = None
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
                if not isinstance(ov, (int, float)):
                    continue
                mtime = sf.stat().st_mtime
            except (OSError, ValueError):
                continue
            if best is None or num > best[0]:
                best = (num, float(ov), mtime)
        return best

    def _read_overall(self, eng: str) -> float | None:
        found = self._latest_valid_scores(eng)
        return found[1] if found else None

    def _render_header(self) -> None:
        score = f"{self._header_score:.1f}" if self._header_score is not None else "—"
        if self.size.width <= 40:
            t = Text()
            t.append("ProductTeam ", style="bold")
            t.append(score, style="bold " + OK if (self._header_score or 0) >= 9 else MUTE)
            self.header.update(t)
            return
        t = Text()
        t.append("▣─", style="bold")
        t.append("▣", style="bold " + OK if (self._provider_active or self._live_activity_rows()) else "bold")
        t.append("─▣ ProductTeam", style="bold")
        t.append(f" · {self._cwd_label or '—'}", style=MUTE)
        t.append(" · ")
        t.append(score, style="bold " + OK if (self._header_score or 0) >= 9 else MUTE)
        self.header.update(t)

    # ── home: at most three scored rows, exclusions enforced ─────────
    _BANNED_ENGAGEMENT = ("smoke", "run-loop", "gate-smoke", "overnight-rehears")

    def _seed_home(self, engagements: list[dict], mapped: str | None) -> None:
        rows = []
        for e in engagements:
            if not e.get("scored"):
                continue
            name = e.get("client", "")
            low = name.lower()
            if any(pat in low for pat in self._BANNED_ENGAGEMENT):
                continue
            if not isinstance(e.get("overall"), (int, float)):
                continue
            rows.append(e)

        def recency_key(e: dict) -> tuple[float, int, str]:
            """(mtime desc, numeric iter desc, client asc): newest latest
            scores.json first; equal mtimes fall back to the numeric iter
            (never the lexicographic string); equal both → stable client
            name tie-break. Missing/unreadable scores sort oldest."""
            client = e.get("client", "") or ""
            found = self._latest_valid_scores(client)
            if found is not None:
                return (-found[2], -found[0], client)
            m = re.match(r"^iter-(\d+)$", e.get("last_iter") or "")
            num = int(m.group(1)) if m else -1
            return (0.0, -num, client)

        rows.sort(key=recency_key)
        # Optional mapped pin: at most one slot, and the remaining rows stay
        # recency-sorted (never a mapped-first sort over the whole list).
        if mapped is not None:
            for i, e in enumerate(rows):
                if e.get("client") == mapped and i >= 3:
                    row = rows.pop(i)
                    rows.insert(0, row)
                    break
        rows = rows[:3]
        if mapped is None:
            self._header_score = float(rows[0]["overall"]) if rows else None
            self._render_header()
        if not rows:
            self.transcript.write(
                Text("No scored sessions yet — bench <client> to score", style=MUTE)
            )
            return
        for e in rows:
            self.transcript.write(self._home_row(e))

    def _home_row(self, e: dict) -> Text:
        """One compact display-only home row (L8): `● {client} ……
        {overall:.1f}` — bullet, name, leader dots, score last. No
        iter/trend metadata, no score-first layout."""
        name = e.get("client", "")
        overall = float(e["overall"])
        t = Text()
        t.append("● ", style=MUTE)
        t.append(name, style=TEXT)
        t.append(" …… ", style=MUTE)
        t.append(f"{overall:.1f}", style="bold " + OK if overall >= 9 else MUTE)
        return t

    # ── chips: one focusable/clickable role row + session-local target ──
    _ROLE_CHIP_ORDER = ("Principal", "Analyst", "Builder", "Critic")

    def _render_chips(self) -> None:
        """One role chip per permanent role. L12: at <=40 columns the row
        collapses to exactly the live/pinned identity plus the hidden
        count (`{glyph} {role} +N`); 80+ restores all four."""
        compact = self.size.width <= 40
        show_role = self._target_role if self._pinned else "Principal"
        for role in self._ROLE_CHIP_ORDER:
            chip = self.query_one(f"#role-{role.lower()}", RoleChip)
            chip.styles.display = "none" if (compact and role != show_role) else "block"
            chip._refresh()

    def _render_role_prefix(self) -> None:
        """Team mode (unpinned) collapses the prefix to width 0 so the
        caret sits flush left (L4); a pinned or typed role expands it to
        `@Role` in the role hue."""
        prefix = self.query_one("#role-prefix", Static)
        if not self._pinned:
            prefix.remove_class("pinned")
            prefix.update("")
            return
        prefix.add_class("pinned")
        _, hue = ROLE_STYLES.get(self._target_role, ("", MUTE))
        prefix.update(Text(f"@{self._target_role}", style=hue))

    def select_role(self, role: str) -> None:
        """Click/Enter/Space: the first activation pins the role; a second
        activation on the already-pinned chip unpins back to team (L6);
        any other chip pins that role. Restores composer focus. A fresh
        boot is team mode (no @Role pin)."""
        if role not in self._ROLE_CHIP_ORDER:
            return
        if self._pinned and self._target_role == role:
            self._pinned = False
        else:
            self._target_role = role
            self._pinned = True
        self._render_chips()
        self._render_role_prefix()
        self.composer.focus()

    def cycle_role(self, delta: int) -> None:
        """Left/Right on the chips row move focus only. Target, pin,
        prefix, and routing change only when a role is activated."""
        if len(self._ROLE_CHIP_ORDER) < 2:
            return
        focused = self.focused
        role = focused._role if isinstance(focused, RoleChip) else self._target_role
        idx = self._ROLE_CHIP_ORDER.index(role)
        role = self._ROLE_CHIP_ORDER[(idx + delta) % len(self._ROLE_CHIP_ORDER)]
        self.query_one(f"#role-{role.lower()}", RoleChip).focus()

    @property
    def _route_role(self) -> str:
        """The role bare text targets: the pinned role, else Principal
        (team chat — Principal coordinates under the hood, L15)."""
        return self._target_role if self._pinned else "Principal"

    @staticmethod
    def _strip_role_token(text: str) -> tuple[str, str]:
        """Parse an optional leading exact @Role token (case-sensitive locked
        names, word boundary). Returns (role, remainder); no match → ("", text)."""
        for role in ("Principal", "Analyst", "Builder", "Critic"):
            token = "@" + role
            if text.startswith(token):
                after = text[len(token):]
                if after == "" or after[0] in (" ", "\t", "\n"):
                    return role, after.lstrip(" \t\n")
        return "", text

    # ── transcript writers ───────────────────────────────────────────
    def _write_line(self, renderable) -> None:
        self.transcript.write(renderable)

    def _evidence_classify(self) -> bool:
        """D12/D25: classify at stream time only for the current /report or
        /bench argv; every other supported verb streams its full summary to
        the Command rail."""
        return self._cli_argv is not None and self._cli_argv[:1] in (
            ["report"],
            ["bench"],
        )

    def _append_cli_line(self, line: str) -> None:
        line = line.rstrip("\n")
        body = line
        if self._evidence_classify() and not self._md_fence:
            cmd_frag, ev_frag = split_evidence_line(line)
            if ev_frag is not None:
                self._evidence_paths.append(ev_frag)
                if cmd_frag is None:
                    return  # withheld from chat; the panel owns the payload
                body = cmd_frag
        seg, self._md_fence = md_line(body, self._md_fence)
        if self._command_open:
            self.transcript.write(command_continue(seg))
        else:
            self.transcript.write(command_open(seg))
            self._command_open = True

    def _command_body(self, body_line: str) -> None:
        """One markdown-lite line on the open Command rail (opens the turn
        defensively if no echo opened it — the echo normally does)."""
        seg, _ = md_line(body_line)
        if self._command_open:
            self.transcript.write(command_continue(seg))
        else:
            self.transcript.write(command_open(seg))
            self._command_open = True

    def _append_provider_line(self, line: str) -> None:
        if not line.strip():
            return
        seg, self._md_fence = md_line(line, self._md_fence)
        role = self._active_turn_role
        _, hue = ROLE_STYLES.get(role, ("", MUTE))
        if not self._provider_speech_opened:
            rendered = Text()
            rendered.append("│", style=hue)
            rendered.append(" ", style=MUTE)
            rendered.append_text(role_tag(role))
            rendered.append(f" · {time.strftime('%H:%M')}", style=MUTE)
            rendered.append("\n")
            rendered.append("│", style=hue)
            rendered.append_text(seg)
            self.transcript.write(rendered)
            self._provider_speech_opened = True
            return
        rendered = Text("│", style=hue)
        rendered.append_text(seg)
        self.transcript.write(rendered)

    def _append_provider_chunk(self, data: str) -> None:
        if not data.strip():
            return
        self._md_buffer += data
        if not self._provider_speech_opened and "\n" not in self._md_buffer:
            line, self._md_buffer = self._md_buffer, ""
            self._append_provider_line(line)
        while "\n" in self._md_buffer:
            line, self._md_buffer = self._md_buffer.split("\n", 1)
            self._append_provider_line(line)

    def _flush_provider_buffer(self) -> None:
        if self._md_buffer:
            line, self._md_buffer = self._md_buffer, ""
            self._append_provider_line(line)

    def _write_turn(self, role: str, text: str) -> None:
        """One locked role turn: rail + role label + dim timestamp + body."""
        self.transcript.write(turn(role, text))

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
        # The slash refresh never clobbers an ask/confirm/evidence dock, and
        # a typed `/` during a live CLI stream cannot steal the slot before
        # the evidence panel opens on completion.
        if self._dock_kind != "slash" or self._cli_busy:
            return
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
        self.composer.focus()
        self._render_footer()
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
        self._dock_kind = "slash"
        self.dock.remove_class("visible")
        self.dock.remove_class("evidence")
        self.composer.focus()
        self._render_footer()

    def dock_move(self, delta: int) -> None:
        if self._dock_kind == "ask":
            n = len(self._ask_options)
            if not n:
                return
            cur = self.dock.highlighted
            cur = 1 if cur is None else cur
            self.dock.highlighted = max(1, min(n, cur + delta))
            self._render_footer()
            return
        if self._dock_kind == "confirm":
            cur = self.dock.highlighted
            cur = 0 if cur is None else cur
            self.dock.highlighted = max(0, min(2, cur + delta))
            return
        if self._dock_kind == "evidence":
            # Display-only: arrows scroll/highlight the panel rows; they
            # never run, never open a file.
            n = self.dock.option_count
            if not n:
                return
            cur = self.dock.highlighted
            cur = 0 if cur is None else cur
            self.dock.highlighted = max(0, min(n - 1, cur + delta))
            return
        n = len(self._dock_verbs)
        if not n:
            return
        cur = self.dock.highlighted
        cur = 0 if cur is None else cur
        self.dock.highlighted = max(0, min(n - 1, cur + delta))

    def complete_dock(self) -> None:
        if self._dock_kind != "slash" or not self._dock_verbs:
            return
        idx = self.dock.highlighted
        if idx is None or idx >= len(self._dock_verbs):
            return
        verb = self._dock_verbs[idx]
        self.composer.clear()
        self.composer.insert(f"/{verb} ")
        self.composer.focus()

    def on_composer_escape(self) -> None:
        if self._dock_kind == "ask":
            self._cancel_ask()
        elif self._dock_kind == "confirm":
            self._close_dock()  # Cancel/Esc executes nothing
        elif self._dock_kind == "evidence":
            self._close_dock()  # closes only; no file spawn
        elif self.dock_visible():
            self._close_dock()
        elif self.composer.text.startswith("/"):
            self.composer.clear()

    # ── send ─────────────────────────────────────────────────────────
    def submit_composer(self) -> None:
        # Early-route before any slash/provider logic: Enter in an ask dock
        # confirms the structured selection, Enter in a confirm dock runs or
        # cancels the intercepted write, Enter in an evidence dock closes it
        # (display-only — never runs, never opens a file).
        if self._dock_kind == "ask":
            self._confirm_ask()
            return
        if self._dock_kind == "confirm":
            self._confirm_choice()
            return
        if self._dock_kind == "evidence":
            self._close_dock()
            return
        raw = self.composer.text
        text = raw.rstrip()
        if not text:
            return
        typed_role, rest = self._strip_role_token(text)
        if typed_role:
            self._target_role = typed_role
            self._pinned = True
            self._render_chips()
            self._render_role_prefix()
        text = rest
        first = text.split("\n", 1)[0].strip()
        typed_verb, typed_args = session.split_slash(first)
        if (self._provider_active or self._cli_busy) and typed_verb not in (
            "exit", "quit", "clear", "export", "provider", "workers"
        ):
            # One in-flight turn owns the shared turn state (artifact path,
            # md buffer, proc pointer, command rail); a second submit would
            # interleave chunks on the wrong rails and orphan the Ctrl+C
            # interrupt path for the newer provider group. Session verbs
            # stay available — they are local, cheap, and never spawn a
            # provider or CLI turn; /exit already defers for _cli_busy.
            self.notify("still busy — wait for the current turn", severity="warning")
            return
        dock_visible = self.dock_visible()
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
        if not text:
            return
        if first.startswith("/"):
            self._run_slash(typed_verb, typed_args)
        else:
            self._active_turn_role = self._route_role
            self._add_turn("user", text)
            self._write_turn("You", text)
            self._start_provider_turn(text)

    # ── slash routing (session-local + registry-driven) ──────────────
    def _run_slash(self, verb: str, args: str) -> None:
        raw_verb = verb
        verb = verb.lower()
        echo = f"/{raw_verb}" + (f" {args}" if args else "")
        self._add_turn("user", echo)
        if verb in ("exit", "quit", "clear", "export", "provider", "workers"):
            # Session verbs are not Command turns: their response is a toast
            # (or a chip row / clear / exit), never Command chrome.
            self.transcript.write(Text(echo))
        else:
            # The slash request echo opens the one mute Command turn; every
            # streamed summary line continues it.
            self._command_open = False
            self._md_fence = False
            seg, _ = md_line(echo)
            self.transcript.write(command_open(seg))
            self._command_open = True
        tokens = session.tokenize(args)
        if verb in ("exit", "quit"):
            if self._cli_busy:
                # A CLI verb is still streaming (run_argv_stream → queued
                # _append_cli_line work). Let its tail reach the transcript
                # before teardown instead of dropping it; bounded so a hung
                # verb cannot trap the user. Ctrl+C and provider semantics
                # are untouched.
                threading.Thread(target=self._exit_after_cli, daemon=True).start()
                return
            self.exit(0)
            return
        if verb == "clear":
            self.transcript.clear()
            self._turns = []
            return
        if verb == "export":
            try:
                path = session.export_session(self._turns, ROOT)
                self.notify(f"wrote {path}")
            except OSError as exc:
                self.notify(f"export failed: {exc}", severity="error")
            return
        if verb == "provider":
            _, msg = session.set_provider(tokens[0] if tokens else None)
            self.notify(msg)
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
            self._command_body(f"/{verb} — {reason}")
            self._command_body(f"use the CLI: {usage}")
        elif kind == "supported":
            argv = [verb, *tokens]
            if self._needs_confirm(argv):
                self._open_confirm(verb, args, argv)
                return
            self._exec_cli(argv)
        else:  # chat_only handled above
            self._echo_muted(f"unknown /{verb} — /help")

    # ── supported CLI verbs: argv + streamed markdown-lite ───────────
    def _exec_cli(self, argv: list[str]) -> None:
        # A new CLI turn supersedes a stale evidence panel (direct
        # _run_slash callers); the composer path already closed it.
        if self._dock_kind == "evidence":
            self._close_dock()
        self._cli_busy = True
        self._cli_argv = argv
        self._evidence_paths = []
        self._md_fence = False

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
                self._call(self._maybe_open_evidence)
                self._cli_argv = None

        threading.Thread(target=run, daemon=True).start()

    def _exit_after_cli(self, rc: int = 0, max_wait: float = 5.0) -> None:
        """Defer app exit while a streamed CLI verb finishes (_cli_busy), so
        its tail is painted to the terminal before teardown. Bounded."""
        deadline = time.monotonic() + max_wait
        while time.monotonic() < deadline and self._cli_busy:
            time.sleep(0.05)
        self._call(self.exit, rc)

    # ── bare text → real provider turn (process-group safe) ──────────
    def _start_provider_turn(self, prompt: str) -> None:
        self._active_turn_role = self._route_role
        self._provider_active = True
        self._provider_interrupted = False
        self._provider_speech_opened = False
        self._md_buffer = ""
        self._md_fence = False
        self._role_status = {}  # a new turn clears stale chip ✓/✗
        self._provider_started_at = time.monotonic()
        # A stale artifact from a previous turn must never serve its old
        # ask.json before the new ARTIFACT= line arrives.
        self._active_artifact = None
        self._render_header()
        self._render_chips()
        self._render_footer()
        threading.Thread(target=self._provider_thread, args=(prompt,), daemon=True).start()

    def _provider_thread(self, prompt: str) -> None:
        env = dict(os.environ)
        env["CONSULT_STATE_ROOT"] = str(session.state_root(ROOT))
        env["ACTIVITY_SESSION_DIR"] = str(self._activity_session_dir)
        try:
            proc = subprocess.Popen(
                ["bash", str(PROVIDER_TURN_SH), str(ROOT), prompt, self._active_turn_role],
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                start_new_session=True,
                env=env,
            )
        except Exception as exc:
            self._provider_active = False
            self._call(self._render_footer)
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
                    self._activity_session_dir = Path(art).parent.parent
                    self._active_artifact = art
        # Live artifact drain: keep tailing the artifact (byte offset held in
        # `size`) while the provider process is alive, flushing each new chunk
        # so a final unterminated line still appears live. The loop must NOT
        # break on _provider_interrupted — it exits only when the process is
        # actually dead, so interrupt-reaped partial bytes land exactly once.
        size = 0
        while proc.poll() is None:
            if art:
                prev = size
                size = self._drain_artifact(art, size)
                if size > prev:
                    self._call(self._flush_provider_buffer)
            time.sleep(0.05)
        if art:
            size = self._drain_artifact(art, size)
        self._call(self._flush_provider_buffer)
        if art:
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
        self._render_header()
        self._render_activity()
        self._render_footer()
        elapsed = int(time.monotonic() - self._provider_started_at)
        if rc is None:
            self._echo_muted(str(art) if art else "provider turn failed")
            return
        if rc == 130:
            # Interrupt: exactly one attached failed card names the partial
            # artifact. The interrupt toast was already shown once at the
            # first Ctrl+C — no second notify, no extra mute echo.
            self._role_status[self._active_turn_role] = "failed"
            self._render_chips()
            self.transcript.write(completion_card(
                self._active_turn_role,
                "failed",
                elapsed,
                Path(art).name if art else None,
                detail="partial output left on disk",
            ))
            return
        state = "done" if rc == 0 else "failed"
        # L14: ✓/✗ on the chip row and on the attached card.
        self._role_status[self._active_turn_role] = state
        self._render_chips()
        # One rail-continuation card on the speaking turn's rail; never
        # replays the spoken body, never clears the transcript.
        self.transcript.write(completion_card(
            self._active_turn_role,
            state,
            elapsed,
            Path(art).name if art else None,
        ))
        if rc != 0:
            self.notify("provider failed", severity="error")

    # ── interrupt: first Ctrl+C kills the provider group, second exits ─
    def action_interrupt_provider(self) -> None:
        if self._splash_active:
            # Ctrl+C during boot skips the splash; it must not exit 130.
            self._splash_finish()
            return
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

    def action_quit_splash_or_exit(self) -> None:
        """ctrl+q: during boot it skips the splash like any key (the key
        must never exit the app); once the splash is gone it keeps
        Textual's normal quit behavior (exit, return code 0)."""
        if self._splash_active:
            self._splash_finish()
            return
        self.exit()

    def action_command_palette(self) -> None:
        """Textual installs ctrl+p as a priority binding, so it would
        bypass the composer's splash consume. While the splash is live the
        palette key skips it instead; afterwards the palette opens as
        usual (it is a no-op when the palette is already open)."""
        if self._splash_active:
            self._splash_finish()
            return
        super().action_command_palette()

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
