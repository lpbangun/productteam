#!/usr/bin/env bash
# provider_turn.sh — one bare-text provider turn for the TUI cockpit.
#
# This script owns the provider process group and the file-backed activity
# record, exactly as lib/repl.sh repl_ask does. The Python app launches it
# with start_new_session=True (its own process group), tails the artifact
# file into the transcript, and forwards the first Ctrl+C as SIGINT to this
# group. The INT trap below TERMs the provider job group (kill -TERM -- -$!),
# preserves partial artifact bytes, marks the worker failed, and exits 130;
# a second Ctrl+C exits the app with 130.
#
# No Python supervisor: signals, reaping, and activity updates stay in bash.
set -u
ROOT="${1:-}"
PROMPT="${2:-}"
[[ -n "$ROOT" && -n "$PROMPT" ]] || exit 2
export CONSULT_ROOT="$ROOT"
export STATE_ROOT="${CONSULT_STATE_ROOT:-$ROOT/state/.cli}"

source "$ROOT/lib/provider.sh"
source "$ROOT/lib/theme.sh"
source "$ROOT/lib/activity.sh"
: "${B:=}" "${D:=}" "${R:=}" "${G:=}" "${RD:=}"

activity_init >/dev/null 2>&1 || true
id=$(activity_start Analyst "$PROMPT" "${CONSULT_PROVIDER:-}" '' 2>/dev/null || true)
[[ -n "$id" ]] || id="w$$"
dir="$(_act_session_dir)"
art="$dir/artifacts/$id.txt"
mkdir -p "$dir/artifacts"
activity_update "$id" running "$art" 2>/dev/null || true

# Tell the app where the artifact lives (stderr stays unbuffered through the
# merged pipe, so the app can start tailing before the turn finishes).
printf 'ARTIFACT=%s\n' "$art" >&2

rc=0
set -m
provider_ask "$PROMPT" "$ROOT" >"$art" 2>&1 &
pid=$!
trap 'kill -TERM -- "-$pid" 2>/dev/null || kill -TERM "$pid" 2>/dev/null || true
      wait "$pid" 2>/dev/null || true
      activity_update "$id" failed "$art" 2>/dev/null || true
      exit 130' INT
wait "$pid"
rc=$?
trap - INT
if (( rc == 0 )); then
  activity_update "$id" done "$art" 2>/dev/null || true
else
  activity_update "$id" failed "$art" 2>/dev/null || true
fi
printf 'EXIT=%s\n' "$rc" >&2
exit "$rc"
