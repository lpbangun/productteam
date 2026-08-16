#!/usr/bin/env bash
# provider_turn.sh — one bare-text provider turn for the TUI cockpit.
#
# Signature: provider_turn.sh ROOT PROMPT [ROLE]. ROLE is optional and
# defaults to Principal, never Analyst. The selected role's state/agents
# card is sourced through lib/agent-cards.sh only (never role-envelope.sh /
# role_invoke — chat is not a sealed engagement turn): the card's
# `prompt_export` is prepended when non-empty, else the derived
# `agent_card_prompt_block`. All card I/O is captured in variables so
# ARTIFACT= stays the first merged protocol line on stderr.
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
ROLE="${3:-Principal}"
[[ -n "$ROOT" && -n "$PROMPT" ]] || exit 2
export CONSULT_ROOT="$ROOT"
export STATE_ROOT="${CONSULT_STATE_ROOT:-$ROOT/state/.cli}"

source "$ROOT/lib/provider.sh"
source "$ROOT/lib/theme.sh"
source "$ROOT/lib/activity.sh"
source "$ROOT/lib/agent-cards.sh"
: "${B:=}" "${D:=}" "${R:=}" "${G:=}" "${RD:=}"

activity_init >/dev/null 2>&1 || true
id=$(activity_start "$ROLE" "$PROMPT" "${CONSULT_PROVIDER:-}" '' 2>/dev/null || true)
[[ -n "$id" ]] || id="w$$"
dir="$(_act_session_dir)"
art="$dir/artifacts/$id.txt"
mkdir -p "$dir/artifacts"
activity_update "$id" running "$art" 2>/dev/null || true

# Selected-role card prefix: capture every card read so nothing but the
# protocol lines ever reaches stdout/stderr (Python merges stderr and reads
# the first line as ARTIFACT=). Missing card, missing jq, or a role without
# a card degrades to the user PROMPT only — the turn still runs.
prompt="$PROMPT"
card=$(agent_card_for_role "$ROLE" 2>/dev/null || true)
if [[ -n "$card" ]]; then
  exported=$(printf '%s' "$card" | jq -r '.prompt_export // empty' 2>/dev/null || true)
  if [[ -n "$exported" ]]; then
    prompt=$(printf '%s\n\n%s' "$exported" "$PROMPT")
  else
    block=$(agent_card_prompt_block "$card" "$ROLE" '-' 0 2>/dev/null || true)
    if [[ -n "$block" ]]; then
      prompt=$(printf '%s\n%s' "$block" "$PROMPT")
    fi
  fi
fi

# Tell the app where the artifact lives (stderr stays unbuffered through the
# merged pipe, so the app can start tailing before the turn finishes).
printf 'ARTIFACT=%s\n' "$art" >&2

rc=0
set -m
provider_ask "$prompt" "$ROOT" >"$art" 2>&1 &
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
