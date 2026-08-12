#!/usr/bin/env bash
# lib/activity.sh — file-backed worker activity for provider invocations.
# Telemetry only: a session TSV under $STATE_ROOT/runs/session-<pid>/workers.tsv
# records each provider worker with state pending|running|done|failed. This is
# not a process supervisor — nothing here spawns, signals, or reaps anything
# but the one provider pid handed to activity_spinner, and the spinner is
# terminal chrome, never a daemon.
#
# Columns: id  role  state  mission  provider  start  elapsed  artifact
# Every file update is temp+rename (atomic). All functions degrade to plain
# text when theme vars are empty (NO_COLOR / non-TTY / standalone source).

# Session dir for the current shell; set by activity_init.
ACTIVITY_SESSION_DIR=''

_act_session_dir() { # → session dir (ACTIVITY_SESSION_DIR, else deterministic per-pid)
  if [[ -n "$ACTIVITY_SESSION_DIR" ]]; then
    printf '%s' "$ACTIVITY_SESSION_DIR"
    return 0
  fi
  local root="${STATE_ROOT:-}"
  if [[ -z "$root" ]]; then
    root="$PWD/state/.cli"
  fi
  printf '%s' "$root/runs/session-$$"
}

_act_trunc() { # $1=text $2=max → one line, truncated with ellipsis
  local t="$1" m="${2:-60}"
  t=${t//$'\t'/ }
  t=${t//$'\n'/ }
  if (( ${#t} > m )); then
    printf '%s…' "${t:0:$((m-1))}"
  else
    printf '%s' "$t"
  fi
}

_act_append() { # $1=file $2=line — atomic temp+rename
  local f="$1" line="$2" tmp
  tmp=$(mktemp "${f}.XXXXXX") || return 1
  if [[ -f "$f" ]]; then
    cat "$f" >> "$tmp"
  fi
  printf '%s\n' "$line" >> "$tmp"
  mv "$tmp" "$f"
}

activity_init() { # → session dir path (creates $STATE_ROOT/runs/session-<pid>/workers.tsv)
  local dir
  dir=$(_act_session_dir)
  mkdir -p "$dir"
  if [[ ! -f "$dir/workers.tsv" ]]; then
    printf 'id\trole\tstate\tmission\tprovider\tstart\telapsed\tartifact\n' > "$dir/workers.tsv"
  fi
  ACTIVITY_SESSION_DIR="$dir"
  printf '%s' "$dir"
}

activity_start() { # $1=role $2=mission $3=provider $4=artifact → worker id
  local role="$1" mission="$2" provider="$3" artifact="$4"
  local dir
  dir=$(_act_session_dir)
  if [[ ! -d "$dir" ]]; then
    activity_init >/dev/null
  fi
  local f="$dir/workers.tsv" id=0 now
  if [[ -f "$f" ]]; then
    id=$(awk -F'\t' 'END{print NR}' "$f")
  fi
  id=$(( id + 0 ))
  now=$(date +%s)
  mission=$(_act_trunc "$mission" 80)
  artifact=${artifact//$'\t'/ }
  artifact=${artifact//$'\n'/ }
  _act_append "$f" "$(printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s' \
    "$id" "$role" pending "$mission" "$provider" "$now" 0 "$artifact")"
  printf '%s' "$id"
}

activity_update() { # $1=id $2=state $3=artifact(optional) — rewrites that row
  local id="$1" state="$2" artifact="${3:-}"
  local dir f
  dir=$(_act_session_dir)
  f="$dir/workers.tsv"
  if [[ ! -f "$f" ]]; then
    return 1
  fi
  local tmp
  tmp=$(mktemp "${f}.XXXXXX") || return 1
  local rid role st mission provider start elapsed art now
  while IFS=$'\t' read -r rid role st mission provider start elapsed art; do
    if [[ "$rid" == "$id" ]]; then
      now=$(date +%s)
      elapsed=$(( now - start ))
      st="$state"
      if [[ -n "$artifact" ]]; then
        art=${artifact//$'\t'/ }
        art=${art//$'\n'/ }
      fi
    fi
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
      "$rid" "$role" "$st" "$mission" "$provider" "$start" "$elapsed" "$art" >> "$tmp"
  done < "$f"
  mv "$tmp" "$f"
}

activity_strip() { # → one line per recorded worker
  local dir f
  dir=$(_act_session_dir)
  f="$dir/workers.tsv"
  if [[ ! -f "$f" ]]; then
    return 0
  fi
  local rid role st mission provider start elapsed art badge role_tag art_name
  while IFS=$'\t' read -r rid role st mission provider start elapsed art; do
    if [[ "$rid" == id ]]; then
      continue
    fi
    badge="$st"
    if command -v status_badge >/dev/null 2>&1; then
      badge=$(status_badge "$st")
    fi
    role_tag="$role"
    if command -v role_chrome >/dev/null 2>&1; then
      role_tag=$(role_chrome "$role")
    fi
    art_name=''
    [[ -n "$art" ]] && art_name=" · $(basename "$art")"
    printf '  %s %-3s %s · %s\n' "$badge" "$rid" "$role_tag" "$(_act_trunc "$mission" 56)"
    printf '  %s%s · %ss%s%s\n' "${D:-}" "$provider" "$elapsed" "$art_name" "${R:-}"
  done < "$f"
}

activity_spinner() { # $1=pid $2=role $3=mission $4=provider $5=start → provider exit status
  local pid="$1" role="$2" mission="$3" provider="$4" start="${5:-$(date +%s)}"
  local rc=0
  if [[ "${CONSULT_NO_SPINNER:-}" == 1 || ! -t 1 ]]; then
    if wait "$pid" 2>/dev/null; then
      rc=0
    else
      rc=$?
    fi
    if (( rc == 127 )); then
      rc=1
    fi
    return $rc
  fi
  local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
  local i=0 now el line len=0
  while ps -p "$pid" >/dev/null 2>&1; do
    now=$(date +%s)
    el=$(( now - start ))
    line=$(printf '  %s %s · %s · %ss' "${frames[i]}" "$(_act_trunc "$mission" 48)" "$provider" "$el")
    printf '\r%s' "$line"
    len=${#line}
    i=$(( (i + 1) % ${#frames[@]} ))
    sleep 0.1
  done
  # clear the spinner line (spaces only — no ANSI escapes here)
  if (( len > 0 )); then
    printf '\r%*s\r' "$len" ''
  fi
  if wait "$pid" 2>/dev/null; then
    rc=0
  else
    rc=$?
  fi
  if (( rc == 127 )); then
    rc=1
  fi
  return $rc
}

activity_card() { # $1=state $2=role $3=elapsed $4=artifact → compact completion card
  local state="$1" role="$2" elapsed="$3" artifact="$4"
  local art badge role_tag
  art=$(basename "${artifact:-}")
  badge="$state"
  if command -v status_badge >/dev/null 2>&1; then
    badge=$(status_badge "$state")
  fi
  role_tag="$role"
  if command -v role_chrome >/dev/null 2>&1; then
    role_tag=$(role_chrome "$role")
  fi
  if [[ -n "$art" ]]; then
    printf '  %s %s · %ss · %s\n' "$badge" "$role_tag" "$elapsed" "$art"
  else
    printf '  %s %s · %ss\n' "$badge" "$role_tag" "$elapsed"
  fi
}
