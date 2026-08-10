#!/usr/bin/env bash
# Inspect the designed Product Consulting Harness CLI.
# Run from the harness root:
#   bash scripts/inspect-cli.sh
# Or:
#   ./scripts/inspect-cli.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
C="$ROOT/bin/productteam"
DEMO_STATE="$(mktemp -d "${TMPDIR:-/tmp}/productteam-inspect.XXXXXX")"

cleanup() { rm -rf "$DEMO_STATE"; }
trap cleanup EXIT

if [[ ! -x "$C" ]]; then
  printf 'missing executable: %s\n' "$C" >&2
  exit 1
fi

section() {
  printf '\n\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
  printf '  %s\n' "$1"
  printf '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n'
}

pause() {
  if [[ -t 0 && -z "${CONSULT_INSPECT_NONINTERACTIVE:-}" ]]; then
    printf '\n[Enter] continue · Ctrl-C quit  '
    read -r _ || true
    printf '\n'
  fi
}

export CONSULT_STATE_ROOT="$DEMO_STATE"
export CONSULT_NO_SPLASH="${CONSULT_NO_SPLASH:-}"

printf 'Product Consulting Harness — CLI inspect\n'
printf 'ROOT=%s\n' "$ROOT"
printf 'Isolated state: %s\n' "$DEMO_STATE"
printf 'Tip: CONSULT_INSPECT_NONINTERACTIVE=1 skips Enter pauses.\n'

section '1. Help (command table + non-goals)'
"$C" help
pause

section '2. Splash — knowledge-graph banner'
CONSULT_NO_SPLASH= "$C" splash
pause

section '3. Splash frames (all frames as text)'
"$C" splash --frames
pause

section '4. Onboarding (non-interactive write)'
"$C" onboarding --yes
pause

section '5. Agent detection'
"$C" agents
pause

section '6. Agent detection (JSON)'
"$C" agents --json | head -c 2000
printf '\n'
pause

section '7. Status overview'
"$C" status
pause

section '8. Chat session (V1 robots; TTY or non-TTY refuse)'
if [[ -t 0 && -t 1 ]]; then
  printf 'Entering chat for /help then /exit…\n'
  printf '/help\n/exit\n' | script -qefc "$C chat" /dev/null || true
else
  printf 'Non-TTY: expecting refuse…\n'
  if "$C" chat </dev/null; then
    printf 'UNEXPECTED: chat succeeded without TTY\n' >&2
  else
    printf 'Refused as expected.\n'
  fi
fi
pause

section '9. harness-cli engagement scores'
if [[ -f "$ROOT/state/engagements/harness-cli/runs/iter-1/scores.json" ]]; then
  jq '{overall, converged, scores: [.scores|to_entries[]|{dim:.key, score:.value.score}]}' \
    "$ROOT/state/engagements/harness-cli/runs/iter-1/scores.json"
else
  "$C" bench harness-cli || true
fi
pause

section '10. Optional live skill (proj-a critique) — real LLM call'
if [[ "${CONSULT_INSPECT_SKILL:-}" == 1 ]]; then
  OUT="$DEMO_STATE/skill-critique"
  "$C" skill critique "$ROOT/state/engagements/harness-cli/tmp-projects/proj-a" "$OUT"
  printf '\nArtifact:\n'
  head -40 "$OUT/critique.md" 2>/dev/null || true
else
  printf 'Skipped (set CONSULT_INSPECT_SKILL=1 to run a real provider call).\n'
  printf 'Example:\n  CONSULT_INSPECT_SKILL=1 bash scripts/inspect-cli.sh\n'
fi

section 'Done'
printf 'Re-run pieces yourself:\n'
printf '  %s help\n' "$C"
printf '  %s splash\n' "$C"
printf '  %s chat\n' "$C"
printf '  CONSULT_STATE_ROOT=%s %s onboarding --yes\n' "$DEMO_STATE" "$C"
printf '  %s agents --json\n' "$C"
printf '  %s status\n' "$C"
printf '\n'
