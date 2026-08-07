# lib/splash.sh — the first-run / login banner.
#
# Draws a small knowledge graph: every node is a computer-headed person (▣, a
# screen where a head would be), every edge a piece of shared evidence. The
# picture is generated from the nodes and edges declared below, so the layout
# can change without touching the renderer.
#
# Bounded by construction: SPLASH_FRAME_COUNT frames, SPLASH_FRAME_DELAY apart,
# and it never reads stdin. Frames are animated only on a colour-capable TTY;
# in a pipe, in CI, or under NO_COLOR exactly one static frame is printed.
#
# Skip it entirely with CONSULT_NO_SPLASH=1 or `productteam splash --no-splash`.
# Dump every frame as plain text with CONSULT_SPLASH_DUMP=1,
# CONSULT_SPLASH_FRAMES=all, or `productteam splash --frames`.

SPLASH_FRAME_COUNT=3
SPLASH_FRAME_DELAY=0.12
SPLASH_ROWS=4
SPLASH_COLS=24

# Nodes: "row:col:glyph" — computer-headed people (▣ = screen for a head).
nodes=(
  "0:3:▣" "0:11:▣" "0:19:▣"
  "3:3:▣" "3:11:▣" "3:19:▣"
)

# Edges: "frame:row:col:glyph:repeat" — frame is when the edge first appears.
edges=(
  "2:0:4:─:7"  "2:0:12:─:7"
  "2:3:4:─:7"  "2:3:12:─:7"
  "3:1:3:│:1"  "3:2:3:│:1"
  "3:1:11:│:1" "3:2:11:│:1"
  "3:1:19:│:1" "3:2:19:│:1"
  "3:1:4:╲:1"  "3:2:5:╲:1"
  "3:1:18:╱:1" "3:2:17:╱:1"
)

splash_render() { # $1=highest frame to include
  local upto="${1:-$SPLASH_FRAME_COUNT}"
  local -a cell=()
  local spec f row col g n i r c line
  for (( i = 0; i < SPLASH_ROWS * SPLASH_COLS; i++ )); do cell[i]=' '; done
  for spec in "${edges[@]}"; do
    IFS=: read -r f row col g n <<<"$spec"
    if (( f <= upto )); then
      for (( i = 0; i < n; i++ )); do cell[row * SPLASH_COLS + col + i]="$g"; done
    fi
  done
  for spec in "${nodes[@]}"; do
    IFS=: read -r row col g <<<"$spec"
    cell[row * SPLASH_COLS + col]="$g"
  done
  for (( r = 0; r < SPLASH_ROWS; r++ )); do
    line=''
    for (( c = 0; c < SPLASH_COLS; c++ )); do line+="${cell[r * SPLASH_COLS + c]}"; done
    printf '    %s\n' "${line%"${line##*[![:space:]]}"}"
  done
}

splash_banner() { # $1=highest frame to include
  printf '\n  %sProduct Consulting Harness%s\n' "${B:-}" "${R:-}"
  printf '  %sProduct Judgment Layer · CLI-first · evidence over opinion%s\n\n' "${D:-}" "${R:-}"
  splash_render "$1"
  printf '\n  %s%s people · %s links · one shared evidence graph%s\n\n' \
    "${D:-}" "${#nodes[@]}" "${#edges[@]}" "${R:-}"
}

splash_show() { # $1… = flags
  local dump=0 a f
  for a in "$@"; do
    case "$a" in
      --frames)    dump=1 ;;
      --no-splash) return 0 ;;
      *)           return 2 ;;
    esac
  done
  if [[ -n "${CONSULT_NO_SPLASH:-}" ]]; then
    return 0
  fi
  if [[ "${CONSULT_SPLASH_DUMP:-}" == 1 || "${CONSULT_SPLASH_FRAMES:-}" == all ]]; then
    dump=1
  fi
  if (( dump )); then
    for (( f = 1; f <= SPLASH_FRAME_COUNT; f++ )); do
      printf -- '-- frame %s of %s --\n' "$f" "$SPLASH_FRAME_COUNT"
      splash_banner "$f"
    done
    return 0
  fi
  if [[ -t 1 && -n "${R:-}" ]]; then
    for (( f = 1; f <= SPLASH_FRAME_COUNT; f++ )); do
      printf '%s' "${CLR:-}"
      splash_banner "$f"
      if (( f < SPLASH_FRAME_COUNT )); then sleep "$SPLASH_FRAME_DELAY"; fi
    done
    return 0
  fi
  splash_banner "$SPLASH_FRAME_COUNT"
}
