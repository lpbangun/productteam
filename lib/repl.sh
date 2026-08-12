# lib/repl.sh — interactive session (V1 robots mark locked).
# Enter via: productteam chat
# Bare text → provider_ask. /cmd → argv handlers. No daemon.
# Chat chrome: role_chrome prompt (active Principal), file-backed activity
# strip (Analyst worker), live spinner, completion card, markdown-lite reply,
# dim timestamped turn separators with a plain-file markdown transcript
# (/export), live slash-verb hints while typing a / prefix (readline -x, no
# raw mode), and an honest footer (engagement · mode-badge · provider ·
# last-iter · overall · history-spark) redrawn immediately above each prompt.

ROBOTS_MARK=(
  ' ▄██▄═════▄██▄═════▄██▄ '
  '█ ██ █   █ ██ █   █ ██ █'
  '█▄▄▄▄█═══█▄▄▄▄█═══█▄▄▄▄█'
  ' ▐▌▐▌     ▐▌▐▌     ▐▌▐▌ '
)

# ── session + footer state ──────────────────────────────────────────
SESSION_DIR='' SESSION_ART='' SESSION_TS=''
FOOT_ENGAGEMENT=''
SESSION_TRANSCRIPT=''       # $SESSION_DIR/transcript.md once repl_session_init runs
REPL_HINT_BOUND=''          # non-empty while slash-hint readline bindings are live
HINT_BUFFER='' HINT_DEDUP='' # readline hint state (slash prefix + last rendered set)

# ── slash verb palette: derived from the command registry (chat_supported)
# plus the chat-only verbs; /help and live hints render from this list ──
repl_slash_verbs=()
repl_palette_build() {
  local i v
  repl_slash_verbs=()
  if declare -p CMD_REGISTRY >/dev/null 2>&1 && (( ${#CMD_REGISTRY[@]} > 0 )); then
    for i in "${!CMD_REGISTRY[@]}"; do
      cmd_reg_get "$i"
      [[ "$REG_CHAT" == 1 ]] && repl_slash_verbs+=("$REG_NAME")
    done
  else
    # Frozen fallback while the registry is not sourced (standalone repl
    # sourcing); membership identical to the registry-driven palette.
    repl_slash_verbs=(help status agents runtime onboarding splash judge score
      checks bench report run memory org gh skill smoke harness-checks
      workers provider clear export exit quit)
  fi
  for v in "${CMD_CHAT_ONLY[@]:-}"; do
    repl_slash_verbs+=("$v")
  done
}
repl_palette_build

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
  SESSION_TRANSCRIPT="$d/transcript.md"
}

repl_foot_select() { # $1=client — remember the engagement for the footer
  FOOT_ENGAGEMENT="$1"
}

# judgment_badge <mode> → Product Judgment chip. Override is the only loud
# state (existing escalate styling — no third hue); the rest are dim/structural.
judgment_badge() {
  local mode="$1"
  case "${mode:-}" in
    Override) status_badge escalate "$mode" ;;
    Guided|Directive|Challenge) printf '%s%s%s' "${D:-}" "$mode" "${R:-}" ;;
    *) printf '%s%s%s' "${D:-}" "${mode:-—}" "${R:-}" ;;
  esac
}

repl_history_spark() { # $1=engagement (relative to $STATE) → spark() over history.jsonl overalls
  local eng="$1" f vals out
  f="${STATE:-$ROOT/state/engagements}/$eng/history.jsonl"
  [[ -f "$f" ]] || return 0
  vals=$(jq -r '.overall' "$f" 2>/dev/null || true)
  [[ -n "$vals" ]] || return 0
  if declare -F spark >/dev/null 2>&1; then
    out=$(spark <<<"$vals")
  else
    out=''
  fi
  [[ -n "$out" ]] && printf '%s' "$out"
}

# ── slash palette: one canonical verb list drives /help AND live hints ──
repl_slash_hints() { # $1=prefix ('' or without leading /) → matching verbs, one per line
  local pre="$1" v
  pre="${pre#/}"
  for v in "${repl_slash_verbs[@]}"; do
    if [[ -z "$pre" || "$v" == "$pre"* ]]; then
      printf '%s\n' "$v"
    fi
  done
}

repl_slash_hint_line() { # $1=prefix → space-joined matching verbs ('' when none)
  local pre="$1" out='' v
  pre="${pre#/}"
  for v in "${repl_slash_verbs[@]}"; do
    if [[ -z "$pre" || "$v" == "$pre"* ]]; then
      [[ -n "$out" ]] && out+=' '
      out+="$v"
    fi
  done
  printf '%s' "$out"
}

_repl_hint_wire() { # install readline -x callbacks so typing / + letters renders hints
  local seq
  if [[ -n "$REPL_HINT_BOUND" || ! -t 0 ]]; then
    return 0
  fi
  bind -x '"/": _repl_hint_cb /' 2>/dev/null || return 0
  for seq in a b c d e f g h i j k l m n o p q r s t u v w x y z 0 1 2 3 4 5 6 7 8 9 -; do
    bind -x "\"$seq\": _repl_hint_cb $seq" 2>/dev/null || true
  done
  bind -x '"\C-h": _repl_hint_cb ""' 2>/dev/null || true
  bind -x '"\177": _repl_hint_cb ""' 2>/dev/null || true
  REPL_HINT_BOUND=1
}

_repl_hint_unwire() { # remove chat-local readline callbacks before process exit
  local seq
  [[ -n "$REPL_HINT_BOUND" ]] || return 0
  bind -r '"/"' 2>/dev/null || true
  for seq in a b c d e f g h i j k l m n o p q r s t u v w x y z 0 1 2 3 4 5 6 7 8 9 -; do
    bind -r "\"$seq\"" 2>/dev/null || true
  done
  bind -r '"\C-h"' 2>/dev/null || true
  bind -r '"\177"' 2>/dev/null || true
  REPL_HINT_BOUND=''
}

_repl_hint_cb() { # $1=char to inject; renders the currently matching verbs
  local ch="$1" line="${READLINE_LINE:-}" pt="${READLINE_POINT:-0}" hint
  # Mirror readline's insertion of the typed char ('' = backspace removal).
  if [[ -n "$ch" ]]; then
    READLINE_LINE="${line:0:pt}$ch${line:pt}"
    READLINE_POINT=$((pt + 1))
  else
    if (( pt > 0 )); then
      READLINE_LINE="${line:0:$((pt - 1))}${line:pt}"
      READLINE_POINT=$((pt - 1))
    fi
  fi
  if [[ "$READLINE_LINE" == /* ]]; then
    hint=$(repl_slash_hint_line "$READLINE_LINE")
  else
    hint=''
  fi
  # Wipe the hint region, draw the new palette to the right, return to prompt.
  printf '\r%*s\r' "${REPL_HINT_WIPE:-72}" ''
  if [[ -n "$hint" ]]; then
    printf '%*s%s' "${REPL_HINT_COL:-34}" '' "$hint"
  fi
  printf '\r'
}

# ── turn separators + transcript (plain markdown, inspectable) ──────
repl_turn_sep() { # $1=kind (user|assistant|command) → dim `── HH:MM:SS · kind ──` line
  printf '  %s── %s · %s ──%s\n' "${D:-}" "$(date +%H:%M:%S)" "$1" "${R:-}"
}

repl_transcript_append() { # $1=kind $2=content → honest markdown turn in transcript.md
  local kind="$1" content="$2" ts
  repl_session_init
  [[ -n "$SESSION_TRANSCRIPT" ]] || return 0
  ts=$(date +%H:%M:%S)
  case "$kind" in
    user)      printf '── %s · user ──\n\n## User\n\n%s\n\n' "$ts" "$content" ;;
    assistant) printf '── %s · assistant ──\n\n## Assistant\n\n%s\n\n' "$ts" "$content" ;;
    command)   printf '── %s · command ──\n\n## Command\n\n%s\n\n' "$ts" "$content" ;;
    *) return 0 ;;
  esac >> "$SESSION_TRANSCRIPT"
}

repl_export_session() { # → ${STATE_ROOT}/sessions/chat-<ts>.md, prints the path
  local root out ts
  root="${STATE_ROOT:-$ROOT/state/.cli}"
  ts=$(date +%Y%m%d-%H%M%S)
  out="$root/sessions/chat-$ts.md"
  mkdir -p "$root/sessions" 2>/dev/null || true
  {
    printf '# Chat session — %s\n\n' "$(date '+%Y-%m-%d %H:%M:%S')"
    if [[ -n "$SESSION_TRANSCRIPT" && -f "$SESSION_TRANSCRIPT" ]]; then
      cat "$SESSION_TRANSCRIPT"
    else
      printf '_No turns recorded yet._\n'
    fi
  } > "$out"
  printf '  %s%s%s\n' "$B" "$out" "$R"
}

# ── interrupt cleanup: kill+reap the provider child, preserve bytes ──
repl_interrupt_cleanup() { # $1=pid/process-group $2=artifact $3=worker-id
  local pid="$1" art="$2" wid="$3" size
  # The background provider owns process group $pid. Kill the group so its
  # grandchildren cannot outlive an interrupted turn; fall back to the pid.
  kill -TERM -- "-$pid" 2>/dev/null || kill -TERM "$pid" 2>/dev/null || true
  wait "$pid" 2>/dev/null || true
  if declare -F activity_update >/dev/null 2>&1 && [[ -n "$wid" ]]; then
    activity_update "$wid" failed "$art" 2>/dev/null || true
  fi
  if [[ -s "$art" ]]; then
    size=$(wc -c < "$art" 2>/dev/null || echo 0)
    printf '  %sCtrl+C — partial output left on disk%s (%s bytes): %s\n' \
      "${D:-}" "${R:-}" "$size" "$art"
  else
    printf '  %sCtrl+C — no output captured yet (empty artifact):%s %s\n' \
      "${D:-}" "${R:-}" "$art"
  fi
}

repl_footer() { # honest status line, redrawn immediately above each prompt
  local prov mode last ov spark d
  prov="${CONSULT_PROVIDER:-$(runtime_default 2>/dev/null || echo none)}"
  mode='—'; last='—'; ov='—'; spark=''
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
    spark=$(repl_history_spark "$FOOT_ENGAGEMENT")
  fi
  printf '  %sengagement: %s · mode: %s · provider: %s · last-iter: %s · overall: %s%s' \
    "${D:-}" "${FOOT_ENGAGEMENT:-—}" "$(judgment_badge "$mode")" "$prov" "$last" "$ov" "${R:-}"
  if [[ -n "$spark" ]]; then
    printf ' · %shistory: %s%s' "${D:-}" "$spark" "${R:-}"
  fi
  printf '\n'
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
  local line="$1" provider rc=0 id='' art='' start elapsed pid interrupted=0 monitor_was_on=0
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
  printf '  %s… working%s — %sCtrl+C leaves partial on disk%s\n' "${D:-}" "${R:-}" "${D:-}" "${R:-}"
  # A temporary Bash job-control group lets interrupt cleanup terminate the
  # provider tree with builtins only; no new runtime dependency or daemon.
  [[ $- == *m* ]] && monitor_was_on=1
  set -m
  provider_ask "$line" "$ROOT" >"$art" 2>&1 &
  pid=$!
  (( monitor_was_on == 1 )) || set +m
  # Scoped SIGINT: kill/reap the provider, keep the REPL alive afterwards.
  trap 'interrupted=1; repl_interrupt_cleanup "$pid" "$art" "$id"; rc=130' INT
  if declare -F activity_spinner >/dev/null 2>&1; then
    activity_spinner "$pid" Analyst "$line" "$provider" "$start" || rc=$?
  else
    if wait "$pid" 2>/dev/null; then rc=0; else rc=$?; fi
  fi
  trap - INT
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
    repl_turn_sep assistant
    repl_render_reply "$art"
    repl_transcript_append assistant "$(cat "$art")"
  else
    if declare -F activity_card >/dev/null 2>&1; then
      activity_card failed Analyst "$elapsed" "$art"
    fi
    if (( interrupted == 0 )); then
      repl_turn_sep assistant
      [[ -s "$art" ]] && repl_render_reply "$art"
      printf '  %sprovider refused%s — /agents · raw: %s\n' "${RD:-}" "${R:-}" "$art"
    fi
  fi
}

# ── safe shell-like tokenizer: single/double quotes + backslash honored;
# $(), ;, and metacharacters stay inert — argv is never re-parsed, no eval ──
repl_tokenize() { # $1=line → REPLY_ARGS array
  local line="$1" w='' quote='' c nxt i
  REPLY_ARGS=()
  for (( i = 0; i < ${#line}; i++ )); do
    c="${line:i:1}"
    if [[ -n "$quote" ]]; then
      if [[ "$c" == "$quote" ]]; then
        quote=''
      elif [[ "$c" == '\' && "$quote" == '"' ]]; then
        if (( i + 1 < ${#line} )); then
          nxt="${line:i+1:1}"
          case "$nxt" in
            '$'|'`'|'"'|'\') w+="$nxt"; i=$((i+1)) ;;
            *) w+='\' ;;
          esac
        else
          w+='\'
        fi
      else
        w+="$c"
      fi
    else
      case "$c" in
        \') quote="'" ;;
        \") quote='"' ;;
        '\')
          if (( i + 1 < ${#line} )); then
            i=$((i+1)); w+="${line:i:1}"
          else
            w+='\'
          fi
          ;;
        ' '|$'\t') [[ -n "$w" ]] && { REPLY_ARGS+=("$w"); w=''; } ;;
        *) w+="$c" ;;
      esac
    fi
  done
  [[ -n "$w" ]] && REPLY_ARGS+=("$w")
}

repl_run_slash() { # $1=line without leading / → 0 keeps the session, 99 exits
  local line="$1" verb idx
  repl_tokenize "$line"
  verb="${REPLY_ARGS[0]:-}"
  if [[ -z "$verb" || "$verb" == 'help' ]]; then
    local v out=''
    for v in "${repl_slash_verbs[@]}"; do
      out+="/$v "
    done
    printf '  %s\n' "${out% }"
    printf '  bare text → provider · /export writes markdown under the CLI sessions directory\n'
    return 0
  fi
  case "$verb" in
    clear)
      printf '%s' "${CLR:-}"
      repl_header
      return 0
      ;;
    exit|quit) return 99 ;;
    export) repl_export_session; return 0 ;;
    provider)
      local want="${REPLY_ARGS[1]:-}" next
      if [[ -n "$want" ]]; then
        if runtime_have "$want"; then
          CONSULT_PROVIDER="$want"
          printf '  %sprovider → %s%s\n' "$G" "$want" "$R"
        else
          printf '  %sprovider %s is not a usable installed agent%s\n' "$RD" "$want" "$R"
        fi
      elif declare -F runtime_cycle >/dev/null 2>&1; then
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
      return 0
      ;;
    workers)
      if declare -F activity_strip >/dev/null 2>&1; then
        activity_strip 2>/dev/null || true
      else
        printf '  %sno worker activity yet%s\n' "${D:-}" "${R:-}"
      fi
      return 0
      ;;
  esac
  idx=$(cmd_reg_index "$verb")
  if [[ -z "$idx" ]]; then
    printf '  unknown /%s — /help\n' "$verb"
    return 0
  fi
  cmd_reg_get "$idx"
  if [[ "$REG_CHAT" != 1 ]]; then
    printf '  unknown /%s — /help\n' "$verb"
    printf '  %s%s%s\n' "${D:-}" "$REG_REASON" "${R:-}"
    return 0
  fi
  if (( ${#REPLY_ARGS[@]} - 1 < REG_MIN )); then
    printf '  usage: %s\n' "$REG_USAGE"
    return 0
  fi
  local -a argv=("${REPLY_ARGS[@]:1}")
  # Subshell isolates handler errors/dies so the session always survives.
  (
    "$REG_HANDLER" "${argv[@]}"
  ) || true
  case "$verb" in
    judge|score|bench|report|run)
      if (( ${#argv[@]} >= 1 )); then
        repl_foot_select "${argv[0]}"
      fi
      ;;
  esac
  return 0
}

cmd_chat() {
  if [[ ! -t 0 || ! -t 1 ]]; then
    die 'chat needs a TTY. Remedy: run `productteam chat` in a terminal, or use a one-shot subcommand.'
  fi
  repl_header
  local line
  _repl_hint_wire
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
      repl_turn_sep command
      repl_transcript_append command "$line"
      repl_run_slash "${line#/}" || rc=$?
      (( rc == 99 )) && break
      continue
    fi
    repl_turn_sep user
    repl_transcript_append user "$line"
    repl_ask "$line"
  done
  _repl_hint_unwire
}
