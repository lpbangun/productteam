# lib/repl.sh — interactive session (V1 robots mark locked).
# Enter via: productteam chat
# Bare text → provider_ask. /cmd → argv handlers. No daemon.
# Chat chrome: role_chrome prompt (active Principal), file-backed activity
# strip (Analyst worker), live spinner, completion card, markdown-lite reply,
# and an honest footer (engagement · mode · provider · last-iter · overall)
# redrawn immediately above each prompt.

ROBOTS_MARK=(
  ' ▄██▄═════▄██▄═════▄██▄ '
  '█ ██ █   █ ██ █   █ ██ █'
  '█▄▄▄▄█═══█▄▄▄▄█═══█▄▄▄▄█'
  ' ▐▌▐▌     ▐▌▐▌     ▐▌▐▌ '
)

# ── session + footer state ──────────────────────────────────────────
SESSION_DIR='' SESSION_ART='' SESSION_TS=''
FOOT_ENGAGEMENT=''

repl_header() {
  local tip tip_w=22 i
  local -a tips=(
    'Getting started'
    'linked agents · one team'
    '──────────────'
    '/agents  /score  /skill'
    '/status  /help   /exit'
  )
  printf '\n  %sProductTeam%s\n\n' "${B:-}" "${R:-}"
  for i in "${!ROBOTS_MARK[@]}"; do
    tip="${tips[i]:-}"
    printf '  %s' "${ROBOTS_MARK[i]}"
    [[ -n "$tip" ]] && printf '   %s%s%s' "${D:-}" "$tip" "${R:-}"
    printf '\n'
  done
  printf '\n  %sprovider:%s · /help · ctrl+d exit%s\n\n' \
    "${D:-}" "$(runtime_default 2>/dev/null || echo none)" "${R:-}"
}

repl_session_init() {
  [[ -n "$SESSION_DIR" ]] && return 0
  local d=''
  if declare -F activity_init >/dev/null 2>&1; then
    d=$(activity_init 2>/dev/null || true)
  fi
  if [[ -z "$d" ]]; then
    d="${STATE_ROOT:-$ROOT/state/.cli}/runs/session-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$d" 2>/dev/null || true
  fi
  SESSION_DIR="$d"
  SESSION_ART="$d/artifacts"
  mkdir -p "$SESSION_ART" 2>/dev/null || true
  SESSION_TS=$(date +%s)
}

repl_foot_select() { # $1=client — remember the engagement for the footer
  FOOT_ENGAGEMENT="$1"
}

repl_footer() { # honest status line, redrawn immediately above each prompt
  local prov mode last ov d
  prov="${CONSULT_PROVIDER:-$(runtime_default 2>/dev/null || echo none)}"
  mode='—'; last='—'; ov='—'
  if [[ -n "$FOOT_ENGAGEMENT" ]]; then
    d="${STATE:-$ROOT/state/engagements}/$FOOT_ENGAGEMENT"
    if [[ -f "$d/engagement.md" ]]; then
      mode=$(awk '/^Mode:/{gsub(/\*/,""); print $2; exit}' "$d/engagement.md" 2>/dev/null || true)
      mode="${mode:-—}"
    fi
    if declare -F latest_run >/dev/null 2>&1; then
      last=$(latest_run "$d" 2>/dev/null || true)
      last="${last:-—}"
    fi
    if [[ "$last" != '—' && -f "$d/runs/$last/scores.json" ]]; then
      ov=$(jq -r '.overall' "$d/runs/$last/scores.json" 2>/dev/null || true)
      ov="${ov:-—}"
    fi
  fi
  printf '  %sengagement: %s · mode: %s · provider: %s · last-iter: %s · overall: %s%s\n' \
    "${D:-}" "${FOOT_ENGAGEMENT:-—}" "$mode" "$prov" "$last" "$ov" "${R:-}"
}

repl_prompt() { # active Principal chrome + prompt arrow
  printf '  '
  if declare -F role_chrome >/dev/null 2>&1; then
    role_chrome Principal 1
  else
    printf '%sPrincipal%s' "${B:-}" "${R:-}"
  fi
  printf ' %s›%s ' "${B:-}" "${R:-}"
}

repl_render_reply() { # $1=artifact path
  if declare -F render_markdown_lite >/dev/null 2>&1; then
    render_markdown_lite "$1"
  else
    cat "$1"
  fi
}

repl_ask() { # $1=prompt — real background provider invocation + activity + card
  local line="$1" provider rc=0 id='' art='' start elapsed pid
  provider="$(runtime_default 2>/dev/null || true)"
  repl_session_init
  start=$(date +%s)
  if declare -F activity_start >/dev/null 2>&1; then
    id=$(activity_start Analyst "$line" "$provider" '' 2>/dev/null || true)
  fi
  [[ -n "$id" ]] || id="w$(date +%s)"
  art="$SESSION_ART/$id.txt"
  if declare -F activity_update >/dev/null 2>&1; then
    activity_update "$id" running "$art" 2>/dev/null || true
  fi
  printf '  %s…%s\n' "${D:-}" "${R:-}"
  # real provider invocation in the background; stdout+stderr → session artifact
  provider_ask "$line" "$ROOT" >"$art" 2>&1 &
  pid=$!
  if declare -F activity_spinner >/dev/null 2>&1; then
    activity_spinner "$pid" Analyst "$line" "$provider" "$start" || rc=$?
  else
    if wait "$pid" 2>/dev/null; then rc=0; else rc=$?; fi
  fi
  elapsed=$(( $(date +%s) - start ))
  if declare -F activity_update >/dev/null 2>&1; then
    if (( rc == 0 )); then
      activity_update "$id" done "$art" 2>/dev/null || true
    else
      activity_update "$id" failed "$art" 2>/dev/null || true
    fi
  fi
  if declare -F activity_strip >/dev/null 2>&1; then
    activity_strip 2>/dev/null || true
  fi
  if (( rc == 0 )); then
    if declare -F activity_card >/dev/null 2>&1; then
      activity_card done Analyst "$elapsed" "$art"
    fi
    repl_render_reply "$art"
  else
    if declare -F activity_card >/dev/null 2>&1; then
      activity_card failed Analyst "$elapsed" "$art"
    fi
    [[ -s "$art" ]] && repl_render_reply "$art"
    printf '  %sprovider refused%s — /agents · raw: %s\n' "${RD:-}" "${R:-}" "$art"
  fi
}

repl_run_slash() { # $1=line without leading /
  local line="$1" cmd args
  IFS=' ' builtin read -r cmd args <<<"$line"
  case "$cmd" in
    ''|help)
      printf '  /status /agents|/runtime /onboarding /splash\n'
      printf '  /judge /score /checks /bench /report /run\n'
      printf '  /memory /org /gh /skill /smoke /harness-checks\n'
      printf '  /workers /provider /clear /exit   · bare text → provider\n'
      ;;
    clear) printf '%s' "${CLR:-}"; repl_header ;;
    exit|quit) return 99 ;;
    status) cmd_status ;;
    agents|runtime) cmd_agents $args ;;
    workers)
      if declare -F activity_strip >/dev/null 2>&1; then
        activity_strip 2>/dev/null || true
      else
        printf '  %sno worker activity yet%s\n' "${D:-}" "${R:-}"
      fi
      ;;
    provider)
      if [[ -n "$args" ]]; then
        if runtime_have "$args"; then
          CONSULT_PROVIDER="$args"
          printf '  %sprovider → %s%s\n' "$G" "$args" "$R"
        else
          printf '  %sprovider %s is not a usable installed agent%s\n' "$RD" "$args" "$R"
        fi
      elif declare -F runtime_cycle >/dev/null 2>&1; then
        local next
        next=$(runtime_cycle 2>/dev/null || true)
        if [[ -n "$next" ]]; then
          CONSULT_PROVIDER="$next"
          printf '  %sprovider → %s%s\n' "$G" "$next" "$R"
        else
          printf '  %sno installed agent to cycle to%s\n' "$RD" "$R"
        fi
      else
        printf '  %sprovider cycle unavailable%s\n' "$RD" "$R"
      fi
      ;;
    onboarding) cmd_onboarding $args ;;
    splash) cmd_splash $args ;;
    judge)
      [[ -n "$args" ]] || { printf '  usage: /judge <client> [set <mode>]\n'; return 0; }
      # shellcheck disable=SC2086
      set -- $args
      if [[ "${2:-}" == set ]]; then cmd_judge_set "$1" "${3:-}"; else cmd_judge "$1"; fi
      repl_foot_select "$1"
      ;;
    score)
      [[ -n "$args" ]] || { printf '  usage: /score <client>\n'; return 0; }
      set -- $args
      cmd_score "$1"
      repl_foot_select "$1"
      ;;
    checks)
      [[ -n "$args" ]] || { printf '  usage: /checks <client>\n'; return 0; }
      cmd_checks $args ;;
    bench)
      [[ -n "$args" ]] || { printf '  usage: /bench <client> [run]\n'; return 0; }
      set -- $args
      if [[ "${2:-}" == run ]]; then cmd_bench_run "$1"; else cmd_bench "$1"; fi
      repl_foot_select "$1"
      ;;
    report)
      [[ -n "$args" ]] || { printf '  usage: /report <client>\n'; return 0; }
      set -- $args
      cmd_report "$1"
      repl_foot_select "$1"
      ;;
    run)
      set -- $args
      [[ $# -ge 2 ]] || { printf '  usage: /run <client> <iter>\n'; return 0; }
      cmd_run_detail "$1" "$2"
      repl_foot_select "$1"
      ;;
    memory) cmd_memory ;;
    org) cmd_org ;;
    gh)
      [[ -n "$args" ]] || { printf '  usage: /gh <sub> …\n'; return 0; }
      cmd_gh $args ;;
    skill)
      set -- $args
      [[ $# -ge 2 ]] || { printf '  usage: /skill <name> <target> [out]\n'; return 0; }
      cmd_skill "$@" ;;
    smoke) cmd_smoke ;;
    harness-checks) cmd_harness_checks $args ;;
    *) printf '  unknown /%s — /help\n' "$cmd" ;;
  esac
  return 0
}

cmd_chat() {
  if [[ ! -t 0 || ! -t 1 ]]; then
    die 'chat needs a TTY. Remedy: run `productteam chat` in a terminal, or use a one-shot subcommand.'
  fi
  repl_header
  local line
  while true; do
    repl_footer
    repl_prompt
    if ! IFS= read -r -e line; then
      printf '\n'
      break
    fi
    # trim
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [[ -z "$line" ]] && continue
    if [[ "$line" == /* ]]; then
      local rc=0
      repl_run_slash "${line#/}" || rc=$?
      (( rc == 99 )) && break
      continue
    fi
    repl_ask "$line"
  done
}
