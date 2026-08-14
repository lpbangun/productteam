# theme.py — token colors, glyphs, and markdown-lite for the cockpit.
#
# Tokens mirror the visualizer `:root` block exactly. Two accents only:
# ok (#22c55e) and err (#ef4444); everything else is neutral. Textual's
# secondary / accent / warning are pinned to MUTE so Textual can never
# introduce its cyan $primary into the cockpit.

from __future__ import annotations

import re

from rich.text import Text
from textual.theme import Theme

CANVAS = "#0a0a0a"
FIELD = "#141414"
RULE = "#2a2a2a"
TEXT = "#e4e4e4"
MUTE = "#737373"
OK = "#22c55e"
ERR = "#ef4444"

# The complete color vocabulary (tests assert the CSS uses only these).
NEUTRAL = frozenset({CANVAS, FIELD, RULE, TEXT, MUTE})
ACCENTS = frozenset({OK, ERR})

GLYPHS = {"Principal": "◆", "Analyst": "◇", "Builder": "▸", "Critic": "◉"}
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
    glyph = GLYPHS.get(role, "·")
    style = "bold " + OK if active else MUTE
    return Text(f"{glyph} {role}", style=style)


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
