# lib/theme.sh — shared role chrome + semantic status badges.
# Batch runners and libs source this for the empty defaults; bin/productteam
# defines the real ANSI values before sourcing (cli-theme-single-source +
# cli-monochrome-chrome both require that shape). Every function here degrades
# to plain text when the color vars are empty (NO_COLOR, non-TTY, standalone).
: "${B:=}" "${D:=}" "${R:=}" "${G:=}" "${RD:=}" "${CLR:=}"

# role_chrome <role> [active] → distinct "glyph Role" turn tag without relying
# on hue. active=1 uses the success accent; inactive roles stay structural.
role_chrome() {
  local role="$1" active="${2:-0}" glyph style
  case "$role" in
    Principal) glyph='◆' ;;
    Analyst)   glyph='◇' ;;
    Builder)   glyph='▸' ;;
    Critic)    glyph='◉' ;;
    *)         glyph='·' ;;
  esac
  if [[ "$active" == 1 ]]; then
    style="${G}${B}"
  else
    style="${D}"
  fi
  printf '%s%s %s%s' "$style" "$glyph" "$role" "$R"
}

# status_badge <state> [label] → "GLYPH LABEL" for the semantic status
# vocabulary: pass|success|done → ✓ (G); fail|error|failed → ✗ (RD);
# running|progress → … (dim); pending → ○ (dim); escalate → ▲ (bold RD).
# Label defaults to the state word. Trailing reset included; plain text when
# uncolored.
status_badge() {
  local state="$1" label="${2:-$1}" glyph hue
  case "$state" in
    pass|success|done)  glyph='✓' hue="$G" ;;
    fail|error|failed)  glyph='✗' hue="$RD" ;;
    running|progress)   glyph='…' hue="$D" ;;
    pending)            glyph='○' hue="$D" ;;
    escalate)           glyph='▲' hue="$RD" ;;
    *)                  glyph='·' hue="$D" ;;
  esac
  if [[ -n "$hue" && -n "$R" ]]; then
    if [[ "$state" == escalate ]]; then
      printf '%s%s%s %s%s' "$hue" "$B" "$glyph" "$label" "$R"
    else
      printf '%s%s %s%s' "$hue" "$glyph" "$label" "$R"
    fi
  else
    printf '%s %s' "$glyph" "$label"
  fi
}
