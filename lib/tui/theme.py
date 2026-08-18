# theme.py — token colors, glyphs, and markdown-lite for the cockpit.
#
# Tokens mirror the locked cockpit token contract exactly: neutral canvas/
# field/rule/text/mute, the owner-locked You + four role identity hues, and
# the ok/err accents. Textual's secondary / accent / warning are pinned to
# MUTE so Textual can never introduce its cyan $primary into the cockpit.
# BUILDER and OK intentionally share the same exact hex (#22c55e).

from __future__ import annotations

import re
import time

from rich.text import Text
from textual.theme import Theme

CANVAS = "#0a0a0a"
FIELD = "#141414"
RULE = "#2a2a2a"
TEXT = "#e4e4e4"
MUTE = "#737373"
YOU = "#8a8a8a"
PRINCIPAL = "#c084fc"
ANALYST = "#60a5fa"
BUILDER = "#22c55e"
CRITIC = "#f59e0b"
OK = "#22c55e"
ERR = "#ef4444"

# The complete locked cockpit vocabulary (tests assert the cockpit sources
# use exactly this set — no cyan, no extras).
NEUTRAL = frozenset({CANVAS, FIELD, RULE, TEXT, MUTE})
ROLE_HUES = frozenset({YOU, PRINCIPAL, ANALYST, BUILDER, CRITIC})
ACCENTS = frozenset({OK, ERR})
COCKPIT_TOKENS = NEUTRAL | ROLE_HUES | ACCENTS

GLYPHS = {"Principal": "◆", "Analyst": "◇", "Builder": "▸", "Critic": "◉"}

# role → (exact glyph, exact identity hue). You has no glyph: gray rail and
# mute label only. These labels/rails/chips are the locked identity chrome.
ROLE_STYLES = {
    "You": ("", YOU),
    "Principal": ("◆", PRINCIPAL),
    "Analyst": ("◇", ANALYST),
    "Builder": ("▸", BUILDER),
    "Critic": ("◉", CRITIC),
}

STATUS_GLYPHS = {
    "done": "✓",
    "success": "✓",
    "pass": "✓",
    "failed": "✗",
    "fail": "✗",
    "error": "✗",
    "running": "…",
    "progress": "…",
    "pending": "○",
    "escalate": "▲",
}

PRODUCTTEAM_THEME = Theme(
    name="productteam",
    primary=OK,
    secondary=MUTE,
    warning=MUTE,
    error=ERR,
    success=OK,
    accent=MUTE,
    foreground=TEXT,
    background=CANVAS,
    surface=CANVAS,
    panel=CANVAS,
    dark=True,
    variables={},
)


def status_glyph(state: str) -> str:
    return STATUS_GLYPHS.get(state, "·")


def status_style(state: str) -> str:
    if state in ("done", "success", "pass"):
        return OK
    if state in ("failed", "fail", "error"):
        return ERR
    if state == "escalate":
        return "bold " + ERR
    return MUTE


def status_tag(state: str) -> Text:
    """`{glyph} {state}` — e.g. `✓ done`, `✗ failed`."""
    return Text(f"{status_glyph(state)} {state}", style=status_style(state))


def role_tag(role: str, active: bool = False) -> Text:
    """`{glyph} {role}` in the role's locked identity hue (You stays gray)."""
    glyph, hue = ROLE_STYLES.get(role, ("·", MUTE))
    style = "bold " + hue if active else hue
    return Text(f"{glyph} {role}".strip(), style=style)


def chip(role: str, state: str) -> Text:
    """`{status glyph} {role glyph} {role}` — e.g. `… ◇ Analyst`."""
    t = Text()
    t.append(status_glyph(state), style=status_style(state))
    active = state in ("running", "pending", "progress")
    t.append(" ")
    t.append_text(role_tag(role, active=active))
    return t


# ── markdown-lite (matches lib/render.sh) ────────────────────────────
# Headings ok+bold, fences mute, leading +/- diff lines ok/err, verdict
# (**…**) lines bold, evidence `path: text` lines with bold path + dim text,
# inline **bold** segments. Under NO_COLOR the markers degrade to plain text
# via Textual's monochrome filter — no content is ever dropped.

_HEADING_RE = re.compile(r"^#{1,6}\s+(.*)$")
_DIFF_RE = re.compile(r"^([+-])[^\s-]")
_EVIDENCE_RE = re.compile(r"^([^\s:]*[./_\-][^\s:]*):\s(.*)$")


def _inline_bold(line: str) -> Text:
    """Inline **bold** segments, mirroring render.sh's while loop."""
    t = Text()
    rest = line
    while "**" in rest:
        pre, _, rest = rest.partition("**")
        if "**" not in rest:
            t.append(pre + "**" + rest)
            rest = ""
            break
        bold, _, rest = rest.partition("**")
        t.append(pre)
        t.append(bold, style="bold")
    if rest:
        t.append(rest)
    return t


def md_line(line: str, in_fence: bool = False) -> tuple[Text, bool]:
    """One markdown-lite line → (styled Text, next fence state)."""
    t = Text()
    if line.startswith("```"):
        t.append("  ```", style=MUTE)
        return t, not in_fence
    if in_fence:
        t.append("  " + line)
        return t, in_fence
    m = _HEADING_RE.match(line)
    if m:
        t.append("  " + m.group(1), style="bold " + OK)
        return t, in_fence
    m = _DIFF_RE.match(line)
    if m:
        sign = m.group(1)
        t.append("  " + sign, style=OK if sign == "+" else ERR)
        t.append(line[1:])
        return t, in_fence
    if line.startswith("**"):
        t.append("  " + line.replace("**", ""), style="bold")
        return t, in_fence
    probe = line[1:] if line.startswith("`") else line
    m = _EVIDENCE_RE.match(probe)
    if m:
        t.append("  " + m.group(1), style="bold")
        t.append(": " + m.group(2), style=MUTE)
        return t, in_fence
    t.append("  ")
    t.append_text(_inline_bold(line))
    return t, in_fence


def markdown_lite(text: str) -> Text:
    """Full-text markdown-lite (multi-line)."""
    out = Text()
    in_fence = False
    lines = text.splitlines() or [""]
    for i, line in enumerate(lines):
        seg, in_fence = md_line(line, in_fence)
        out.append_text(seg)
        if i < len(lines) - 1:
            out.append("\n")
    return out


# ── locked turn chrome ───────────────────────────────────────────────
# Every turn uses a narrow rail and a role label. You gets a gray rail and
# mute label; the four permanent roles use their identity hue for rail and
# label. The timestamp is dim. Body copy stays markdown-lite neutral. This
# is presentation only — no focus/click targeting rides on it in iter-1.

RAIL = "│"


def turn(role: str, text: str, ts: str | None = None) -> Text:
    """One locked role turn: `│ {label} · {HH:MM}` then the markdown-lite body."""
    glyph, hue = ROLE_STYLES.get(role, ("", MUTE))
    label = f"{glyph} {role}".strip()
    if ts is None:
        ts = time.strftime("%H:%M")
    t = Text()
    t.append(RAIL, style=hue)
    t.append(" ", style=MUTE)
    t.append(label, style=hue)
    t.append(f" · {ts}", style=MUTE)
    for i, line in enumerate(text.splitlines() or [""]):
        t.append("\n")
        t.append(RAIL, style=hue)
        seg, _ = md_line(line)
        t.append_text(seg)
    return t


# ── Command rail (D11/D21) ──────────────────────────────────────────
# The one mute Command chrome writer: a MUTE rail + MUTE `Command` label +
# dim timestamp, then markdown-lite body lines on the MUTE rail. Never a
# role hue, never a toast. The app owns exactly three call sites: slash
# request echo, supported streamed summaries, unsupported refuse + usage.
# The body arrives already styled (md_line) so the app keeps fence state.

def command_open(first_body: Text) -> Text:
    """Open a Command turn: `│ Command · {HH:MM}` then a MUTE rail + body."""
    t = Text()
    t.append(RAIL, style=MUTE)
    t.append(" Command", style=MUTE)
    t.append(f" · {time.strftime('%H:%M')}", style=MUTE)
    t.append("\n")
    t.append(RAIL, style=MUTE)
    t.append_text(first_body)
    return t


def command_continue(line: Text) -> Text:
    """One more markdown-lite body line on the open Command rail."""
    t = Text(RAIL, style=MUTE)
    t.append_text(line)
    return t


def completion_card(
    role: str,
    state: str,
    elapsed_s: int,
    artifact_name: str | None,
    *,
    detail: str | None = None,
) -> Text:
    """One attached rail-continuation card appended once at provider done:
    `│ {status}  {role} · {elapsed}s · {artifact}` (+ optional mute detail).
    Uses the speaking turn's role hue rail; never replays spoken body."""
    _, hue = ROLE_STYLES.get(role, ("", MUTE))
    t = Text()
    t.append(RAIL, style=hue)
    t.append(" ", style=MUTE)
    t.append_text(status_tag(state))
    t.append("  ", style=MUTE)
    t.append_text(role_tag(role, active=state in ("done", "success", "pass")))
    t.append(f" · {elapsed_s}s", style=MUTE)
    if artifact_name:
        t.append(f" · {artifact_name}", style=MUTE)
    if detail:
        t.append(f" · {detail}", style=MUTE)
    return t


# ── evidence path classification (D12/D25) ───────────────────────────
# split_evidence_line is the product classifier for /report and /bench
# streaming. The app calls it from _append_cli_line at stream time (never
# post-hoc on the RichLog); it returns (command_fragment, evidence_fragment)
# where either side may be None. Full-line and rightmost-mixed path payloads
# split to the evidence dock; usage/error/die, headings, banners, tables,
# and prose stay Command summaries. area/score/iter-1/Benchmark prefixes
# are preserved on the Command side.

_PATH_PREFIXES = ("state/", "runs/", "lib/", "bin/", "tests/", "docs/")
_ESC_RE = re.compile(r"\x1b\[[0-9;?]*[A-Za-z]|\x1b\][^\x07\x1b]*(?:\x07|\x1b\\)")
_ERR_MARKERS = ("usage:", "error:", "no report yet", "no scored runs yet")
_DIE_RE = re.compile(r"\bdie\b")


def _strip_escapes(line: str) -> str:
    """Drop CSI/OSC sequences before classification (defensive; the TUI
    Popen is not a TTY, but the classifier must not see escapes)."""
    return _ESC_RE.sub("", line)


def _is_path_token(token: str) -> bool:
    """A path-only token: contains `/`, is not a URL, is one whitespace-free
    token, and looks like a file path (dot extension or a known tree root)."""
    if not token or "://" in token or "/" not in token:
        return False
    if any(c.isspace() for c in token):
        return False
    return "." in token or token.startswith(_PATH_PREFIXES)


def _signed_delta(text: str) -> bool:
    """True when the token is a signed delta like `+5.5` / `-0.3` (never a
    bare score like `9.5`)."""
    return bool(re.match(r"^[+-][0-9.]+$", text))


def split_evidence_line(line: str) -> tuple[str | None, str | None]:
    """One streamed report/bench line → (command_fragment, evidence_fragment).

    Either side may be None. Rules, in order, against the stripped copy:
    1. empty / usage / error / die / no-report / no-scored-runs → summary;
    2. full-line evidence (`path: rest` or a path-only token) → panel only;
    3. rightmost mixed row (`… area score … path[: text]`) → prefix stays
       Command, the path payload (plus any signed delta immediately before
       it) goes to the panel;
    4. everything else (headings, banners, tables, prose) → summary.
    """
    raw = _strip_escapes(line).rstrip("\n")
    stripped = raw.strip()
    if not stripped:
        return raw, None
    low = stripped.lower()
    if any(m in low for m in _ERR_MARKERS) or _DIE_RE.search(low):
        return raw, None
    if _EVIDENCE_RE.match(stripped):
        return None, stripped
    if _is_path_token(stripped):
        return None, stripped
    # rightmost mixed: the longest suffix that is an evidence substring —
    # anchored at a token boundary so a partial path (`…theme.py: …`) can
    # never masquerade as a full `path: text` payload…
    start = -1
    for i in range(len(stripped)):
        if (i == 0 or stripped[i - 1].isspace()) and _EVIDENCE_RE.match(stripped[i:]):
            start = i
    if start > 0:
        payload = stripped[start:]
        prefix_words = stripped[:start].split()
        if prefix_words and _signed_delta(prefix_words[-1]):
            delta = prefix_words[-1]
            delta_idx = stripped.rfind(delta, 0, start)
            payload = stripped[delta_idx:]  # delta + original gap + path
            prefix_words = prefix_words[:-1]
        return " ".join(prefix_words), payload
    # …else a trailing path token (bench overall rows end in scores.json).
    words = stripped.split()
    if len(words) > 1 and _is_path_token(words[-1]):
        path_start = len(stripped) - len(words[-1])
        payload = stripped[path_start:]
        prefix_words = words[:-1]
        if prefix_words and _signed_delta(prefix_words[-1]):
            delta = prefix_words[-1]
            delta_idx = stripped.rfind(delta, 0, path_start)
            payload = stripped[delta_idx:]  # delta + original gap + path
            prefix_words = prefix_words[:-1]
        return " ".join(prefix_words), payload
    return raw, None


# ── boot splash (D16/D26) ───────────────────────────────────────────
# The TUI-owned boot splash lives here so the art never leaks into app.py
# or the RichLog. Freeze R7: three angular heads (Principal, Analyst,
# Builder — no Critic), futuristic line-art, ASCII inside Textual, live
# glow = OK. Each head is exactly 11 columns x 7 rows (six art rows plus
# the label row); the heads join side by side with a 3-column gap at
# width >= 41 and a 1-column gap at width <= 40, giving the 39/35-column
# joins that fit inside 80/40 with the #splash `0 1` padding.

SPLASH_ROLES = ("Principal", "Analyst", "Builder")

# Pure-ASCII heads only: `· ─ ◇ ▸ ▐▌ ═` have ambiguous or wide cell
# advances and slant under real mono fonts. `| / \ ^ - _ o # >` are
# exactly one cell in every terminal, so the three heads stay aligned.
SPLASH_HEADS = {
    "Principal": (
        "     |     ",
        "    /^\\    ",
        "   /---\\   ",
        "  | o o |  ",
        "  |  -  |  ",
        "     #     ",
        " Principal ",
    ),
    "Analyst": (
        "     |     ",
        "    /^\\    ",
        "   /---\\   ",
        "  | o o |  ",
        "  |  -  |  ",
        "     o     ",
        "  Analyst  ",
    ),
    "Builder": (
        "     |     ",
        "    /^\\    ",
        "   /---\\   ",
        "  | o o |  ",
        "  |  -  |  ",
        "     >     ",
        "  Builder  ",
    ),
}

SPLASH_GAP_WIDE = 3      # join gap when width >= 41
SPLASH_GAP_COMPACT = 1   # join gap when width <= 40


def splash_render(width: int, glow: str | None = None) -> Text:
    """The boot splash as one Text: three 11x7 heads joined side by side,
    a blank line, the ProductTeam brand, then the idle or live subtitle.

    glow is None → the idle frame: every head row and the idle subtitle
    are MUTE, the brand is TEXT. glow in SPLASH_ROLES → exactly that one
    head (six art rows + label) and the live subtitle `{glyph} {role}`
    are OK; the other two heads stay MUTE. app.py never restyles it."""
    gap = " " * (SPLASH_GAP_WIDE if width >= 41 else SPLASH_GAP_COMPACT)
    heads = [SPLASH_HEADS[role] for role in SPLASH_ROLES]
    live = glow in SPLASH_ROLES
    t = Text()
    for row in range(7):
        for i, role in enumerate(SPLASH_ROLES):
            if i:
                t.append(gap, style=MUTE)
            style = OK if (live and role == glow) else MUTE
            t.append(heads[i][row], style=style)
        t.append("\n", style=MUTE)
    t.append("\n", style=MUTE)
    t.append("ProductTeam", style=TEXT)
    t.append("\n", style=MUTE)
    if live:
        t.append(f"{GLYPHS[glow]} {glow}", style=OK)
    else:
        t.append("principal · analyst · builder", style=MUTE)
    return t
