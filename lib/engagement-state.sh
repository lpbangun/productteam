#!/usr/bin/env bash
# engagement-state.sh — durable escalations, pause/authorized resume, continuation,
# and file-derived inspect packs. Sourced by bin/consult.
# Plain JSON under the engagement; atomic writers (tmp + rename).
# One shared progress-block predicate: open escalations and an active pause block
# the same progress set (checks, provider score, gate implement) until an
# owner-authorized resume stamps everything resolved/resumed/consumed.

escalations_path() { # client dir → escalations.json path
  printf '%s/escalations.json' "$1"
}
pause_path() { # client dir → pause.json path
  printf '%s/pause.json' "$1"
}
auth_resume_path() { # client dir → default authorize-resume.json path
  printf '%s/authorize-resume.json' "$1"
}
continuation_path() { # client dir → continuation.json path
  printf '%s/continuation.json' "$1"
}

atomic_write() { # file → writes stdin payload atomically (tmp + rename)
  local file="$1" tmp
  mkdir -p "$(dirname "$file")"
  tmp="$file.tmp.$$"
  cat > "$tmp"
  mv "$tmp" "$file"
}

escalation_token() { # → opaque durable resume-token receipt (correlation, not auth)
  local token
  if [[ -r /proc/sys/kernel/random/uuid ]]; then
    IFS= read -r token < /proc/sys/kernel/random/uuid
    printf '%s' "$token"
  elif command -v uuidgen >/dev/null 2>&1; then
    uuidgen
  else
    printf '%s-%s' "$(date -u +%s%N)" "$RANDOM$RANDOM"
  fi
}

# An entry is OPEN/blocking iff it is NOT a fully stamped resolved entry.
# Hand-edited "resolved" without options+token+resolved_at still blocks.
esc_open_ids() { # client dir → blocking entry ids (one per line); never fails
  local d="$1" f
  f=$(escalations_path "$d")
  [[ -f "$f" ]] || return 0
  jq -r '.[] | select(((.status? // "") == "resolved" and ((.options? // []) | type) == "array" and ((.options? // []) | length) > 0 and ((.resume_token? // "") | length) > 0 and ((.resolved_at? // "") | length) > 0) | not) | .id' "$f" 2>/dev/null || true
}

esc_entry() { # client dir, id → JSON entry (or 'null'); never fails
  local d="$1" id="$2" f
  f=$(escalations_path "$d")
  [[ -f "$f" ]] || { printf 'null'; return 0; }
  jq -c --arg id "$id" '[.[] | select(.id == $id)][0] // null' "$f" 2>/dev/null || printf 'null'
}

progress_blocked_reason() { # client dir → non-empty reason iff any open escalation or active pause; never fails
  local d="$1" c reason='' f
  c=$(basename "$d")
  f=$(escalations_path "$d")
  if [[ -f "$f" ]]; then
    if ! jq -e 'type == "array"' "$f" >/dev/null 2>&1; then
      reason+="invalid escalations.json ($f)"
    else
      local ids id
      ids=$(esc_open_ids "$d")
      if [[ -n "$ids" ]]; then
        id=$(printf '%s\n' "$ids" | head -1)
        reason+="open escalation '$id' in $f"
      fi
    fi
  fi
  f=$(pause_path "$d")
  if [[ -f "$f" ]]; then
    if jq -e '(.paused == true or (.status? // "") == "paused")' "$f" >/dev/null 2>&1; then
      [[ -z "$reason" ]] || reason+="; "
      reason+="paused ($f)"
    elif ! jq -e '(.paused == false)' "$f" >/dev/null 2>&1; then
      [[ -z "$reason" ]] || reason+="; "
      reason+="invalid pause.json ($f)"
    fi
  fi
  if [[ -n "$reason" ]]; then
    printf 'progress blocked for %s: %s' "$c" "$reason"
  fi
}

escalation_block() { # client, client dir, id, summary, options… → escalations.json + pause.json atomically
  local c="$1" d="$2" id="$3" summary="$4"
  shift 4
  local f token ts options entries payload
  f=$(escalations_path "$d")
  if [[ -f "$f" ]] && jq -e --arg id "$id" '[.[] | select(.id == $id)] | length > 0' "$f" >/dev/null 2>&1; then
    die "escalation id '$id' already exists for $c ($f) — ids are unique"
  fi
  token=$(escalation_token)
  ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  options=$(printf '%s\n' "$@" | jq -R . | jq -s -c .)
  entries='[]'
  if [[ -f "$f" ]]; then
    entries=$(cat "$f")
    jq -e 'type == "array"' <<<"$entries" >/dev/null 2>&1 \
      || die "escalations.json for $c is not a JSON array ($f)"
  fi
  payload=$(jq -n --arg id "$id" --arg summary "$summary" --argjson options "$options" \
    --arg token "$token" --arg ts "$ts" \
    '{id:$id,summary:$summary,options:$options,status:"blocked",resume_token:$token,blocked_at:$ts}')
  jq -c --argjson e "$payload" '. + [$e]' <<<"$entries" | atomic_write "$f"
  jq -n --arg id "$id" --arg reason "$summary" --arg token "$token" --arg ts "$ts" \
    '{paused:true,status:"paused",reason:$reason,id:$id,resume_token:$token,paused_at:$ts,escalated:true}' \
    | atomic_write "$(pause_path "$d")"
  printf 'blocked %s: escalation %s — options: %s · resume token %s\n' "$c" "$id" "$*" "$token"
}

escalation_status() { # client, client dir → machine-readable escalation + pause JSON; exit 0
  local c="$1" d="$2" f p
  f=$(escalations_path "$d"); p=$(pause_path "$d")
  local open='[]' resolved='[]' missing=false paused=false
  if [[ -f "$f" ]]; then
    open=$(jq -c '[.[] | select(((.status? // "") == "resolved" and ((.options? // []) | type) == "array" and ((.options? // []) | length) > 0 and ((.resume_token? // "") | length) > 0 and ((.resolved_at? // "") | length) > 0) | not)]' "$f" 2>/dev/null || printf '[]')
    resolved=$(jq -c '[.[] | select((.status? // "") == "resolved" and ((.options? // []) | type) == "array" and ((.options? // []) | length) > 0 and ((.resume_token? // "") | length) > 0 and ((.resolved_at? // "") | length) > 0)]' "$f" 2>/dev/null || printf '[]')
  else
    missing=true
  fi
  if [[ -f "$p" ]] && jq -e '(.paused == true or (.status? // "") == "paused")' "$p" >/dev/null 2>&1; then
    paused=true
  fi
  jq -n --arg client "$c" --argjson paused "$paused" --argjson open "$open" \
    --argjson resolved "$resolved" --argjson missing "$missing" \
    --arg pause_artifact "$([[ -f "$p" ]] && printf '%s' "$p" || printf '')" \
    --arg escalations_artifact "$([[ -f "$f" ]] && printf '%s' "$f" || printf '')" \
    '{client:$client,paused:$paused,open:$open,resolved:$resolved,missing:$missing,escalations_artifact:(if $escalations_artifact=="" then null else $escalations_artifact end),pause_artifact:(if $pause_artifact=="" then null else $pause_artifact end)}'
}

escalation_memory_append() { # memory file, entry line → insert under ## Lessons (create file/section if absent); fails on unwritable dir
  local mem="$1" entry="$2" tmp line
  mkdir -p "$(dirname "$mem")" || return 1
  tmp="$mem.tmp.$$"
  if [[ -f "$mem" ]]; then
    line=$(grep -n '^## Lessons' "$mem" 2>/dev/null | head -1 | cut -d: -f1)
    if [[ -n "$line" ]]; then
      awk -v n="$line" -v e="$entry" 'NR==n{print; print ""; print e; next} {print}' "$mem" > "$tmp" || return 1
    else
      { cat "$mem"; printf '\n## Lessons\n\n%s\n' "$entry"; } > "$tmp" || return 1
    fi
  else
    printf '# MEMORY.md — Organizational Memory\n\n## Lessons\n\n%s\n' "$entry" > "$tmp" || return 1
  fi
  mv "$tmp" "$mem"
}

escalation_resume() { # client, client dir, id, token → authorized resume; fail closed on any validation/write failure
  local c="$1" d="$2" id="$3" token="$4"
  local pf ef auth authby dec ts entry
  pf=$(pause_path "$d"); ef=$(escalations_path "$d")
  [[ -f "$pf" ]] || die "not paused for $c — nothing to resume ($pf missing)"
  if ! jq -e '(.paused == true or (.status? // "") == "paused")' "$pf" >/dev/null 2>&1; then
    die "not paused for $c — pause is not active ($pf)"
  fi
  local open
  open=$(esc_open_ids "$d")
  [[ -n "$open" ]] || die "no open escalation for $c to resume"
  grep -qx "$id" <<<"$open" || die "escalation '$id' is not open for $c — resume refused"
  entry=$(esc_entry "$d" "$id")
  [[ "$entry" != 'null' ]] || die "escalation '$id' not found for $c ($ef)"
  local recorded
  recorded=$(jq -r '.resume_token // empty' <<<"$entry")
  [[ -n "$recorded" && "$recorded" == "$token" ]] \
    || die "resume token for escalation '$id' does not match — resume refused for $c ($ef)"
  auth="${CONSULT_AUTHORIZE_RESUME:-$(auth_resume_path "$d")}"
  [[ -f "$auth" ]] || die "resume refused — missing authorization file: create $auth with {\"id\":\"...\",\"token\":\"...\",\"authorized_by\":\"...\",\"decision\":\"...\"} matching this escalation (the CLI never mints it)"
  if jq -e '((.status? // "") == "consumed") or ((.consumed_at? // "") | length) > 0' "$auth" >/dev/null 2>&1; then
    die "resume refused — authorization already consumed ($auth); a fresh owner authorization is required"
  fi
  jq -e --arg id "$id" --arg token "$token" '.id == $id and .token == $token' "$auth" >/dev/null 2>&1 \
    || die "resume refused — authorization id/token do not exactly match escalation '$id' ($auth)"
  authby=$(jq -r '.authorized_by // empty' "$auth" 2>/dev/null)
  dec=$(jq -r '.decision // empty' "$auth" 2>/dev/null)
  [[ -n "$authby" ]] || die "resume refused — authorize file must carry non-empty authorized_by ($auth)"
  [[ -n "$dec" ]] || die "resume refused — authorize file must carry non-empty decision ($auth)"
  if grep -qiE '(^|[^-])--admin|force push|bypass checks|waive' "$auth"; then
    die "resume refused — authorize file must not request force/admin/waiver ($auth)"
  fi

  ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  # 1. engagement continuation record (atomic)
  jq -n --arg ts "$ts" --arg id "$id" --arg token "$token" --arg reason "$dec" \
    --arg auth_path "$auth" --arg event 'resumed' \
    '{event:$event,ts:$ts,id:$id,token:$token,reason:$reason,auth_path:$auth_path,escalation_resolved:true,pause_resumed:true,auth_consumed:true}' \
    | atomic_write "$(continuation_path "$d")"
  # 2. MEMORY pointer (append-only under ## Lessons) — failure leaves the pause in place (fail closed)
  escalation_memory_append "${CONSULT_MEMORY_FILE:-$CONSULT_ROOT/MEMORY.md}" \
    "- $ts · $c authorized resume — escalation $id resolved, pause resumed, authorization consumed ($(basename "$auth")). Continuation: $(continuation_path "$d"). Decision: $dec" \
    || die "resume refused — MEMORY pointer not writable (${CONSULT_MEMORY_FILE:-$CONSULT_ROOT/MEMORY.md}); pause left in place"
  # 3. unblock stamps: escalation resolved (options+token preserved), pause resumed, auth consumed
  jq -c --arg id "$id" --arg ts "$ts" \
    'map(if .id == $id then . + {status:"resolved",resolved_at:$ts} else . end)' "$ef" | atomic_write "$ef"
  local remaining rid rtoken
  remaining=$(esc_open_ids "$d")
  if [[ -n "$remaining" ]]; then
    rid=$(printf '%s\n' "$remaining" | head -1)
    rtoken=$(jq -r --arg id "$rid" '[.[] | select(.id == $id)][0].resume_token // empty' "$ef" 2>/dev/null)
    jq -c --arg id "$rid" --arg token "$rtoken" --arg ts "$ts" \
      '. + {paused:true,status:"paused",id:$id,resume_token:$token,resumed_at:$ts,note:"additional open escalation remains"}' \
      "$pf" | atomic_write "$pf"
  else
    jq -c --arg id "$id" --arg ts "$ts" '. + {paused:false,status:"resumed",resumed_at:$ts}' "$pf" | atomic_write "$pf"
  fi
  jq -c --arg ts "$ts" '. + {status:"consumed",consumed_at:$ts}' "$auth" | atomic_write "$auth"
  printf 'resumed %s: escalation %s resolved · pause resumed · authorization consumed (%s)\n' "$c" "$id" "$auth"
}

inspect_derive_pack() { # client, client dir → regenerable file-derived pack JSON (stdout); no wall-clock timestamps
  local c="$1" d="$2"
  local mode mode_missing=false
  mode=$(judgment_mode "$d")
  case "$mode" in Guided|Directive|Challenge|Override) ;; *) mode_missing=true ;; esac

  local gate jdir_missing=true
  gate=$(judgment_status "$c" "$d")
  [[ -d "$d/judgment" ]] && jdir_missing=false

  local hist='[]' latest='null' scores_missing=true latest_run='' hist_lines='' rd
  while IFS= read -r rd; do
    [[ -d "$rd" && -f "$rd/scores.json" ]] || continue
    scores_missing=false
    latest_run="$rd"
    hist_lines+=$(jq -nc --arg run "$rd" \
      --arg ts "$(jq -r '.ts // ""' "$rd/scores.json" 2>/dev/null)" \
      --arg kind "$(jq -r '.kind // ""' "$rd/scores.json" 2>/dev/null)" \
      --arg ov "$(jq -r '.overall // ""' "$rd/scores.json" 2>/dev/null)" \
      --arg weak "$(jq -r '[.scores | to_entries[] | {k:.key,s:.value.score}] | min_by(.s) | "\(.k) \(.s)"' "$rd/scores.json" 2>/dev/null)" \
      '{run:$run,ts:$ts,kind:$kind,overall:$ov,weakest:$weak}')
    hist_lines+=$'\n'
  done < <(printf '%s\n' "$d"/runs/iter-* | sort -V)
  [[ -n "$hist_lines" ]] && hist=$(jq -s -c . <<<"$hist_lines")
  [[ -n "$latest_run" ]] && latest=$(jq -c . "$latest_run/scores.json")
  local scores
  if [[ "$scores_missing" == true ]]; then
    scores=$(jq -nc '{missing:true,history:[],latest:null}')
  else
    scores=$(jq -nc --argjson hist "$hist" --argjson latest "$latest" --arg latest_run "$latest_run" \
      '{missing:false,history:$hist,latest:$latest,latest_run:$latest_run}')
  fi

  local hf history
  hf="$d/history.jsonl"
  if [[ -f "$hf" ]]; then
    history=$(jq -s -c --arg file "$hf" '{file:$file,missing:false,entries:.}' "$hf" 2>/dev/null) \
      || history=$(jq -nc --arg file "$hf" '{file:$file,missing:false,invalid:true,entries:[]}')
  else
    history=$(jq -nc --arg file "$hf" '{file:$file,missing:true,entries:[]}')
  fi

  local ef pf cf
  ef=$(escalations_path "$d"); pf=$(pause_path "$d"); cf=$(continuation_path "$d")
  local esc pause lessons cont missing='[]'
  if [[ -f "$ef" ]]; then
    esc=$(jq -c --arg file "$ef" \
      '{file:$file,missing:false,entries:(if type=="array" then . else [] end),open:([.[] | select(((.status? // "") == "resolved" and ((.options? // []) | type) == "array" and ((.options? // []) | length) > 0 and ((.resume_token? // "") | length) > 0 and ((.resolved_at? // "") | length) > 0) | not)] | length),resolved:([.[] | select((.status? // "") == "resolved" and ((.options? // []) | type) == "array" and ((.options? // []) | length) > 0 and ((.resume_token? // "") | length) > 0 and ((.resolved_at? // "") | length) > 0)] | length)}' \
      "$ef" 2>/dev/null) || esc=$(jq -nc --arg file "$ef" '{file:$file,missing:true,invalid:true}')
  else
    esc=$(jq -nc --arg file "$ef" '{file:$file,missing:true}')
  fi
  if [[ -f "$pf" ]]; then
    pause=$(jq -c --arg file "$pf" \
      '{file:$file,missing:false,paused:(.paused? // false),status:(.status? // "unknown"),reason:(.reason? // null),id:(.id? // null),paused_at:(.paused_at? // null),resumed_at:(.resumed_at? // null)}' \
      "$pf" 2>/dev/null) || pause=$(jq -nc --arg file "$pf" '{file:$file,missing:true,invalid:true}')
  else
    pause=$(jq -nc --arg file "$pf" '{file:$file,missing:true}')
  fi
  local style_json project_json
  declare -F style_derive_pack >/dev/null 2>&1 || {
    # shellcheck disable=SC1090
    [[ -f "${CONSULT_ROOT}/lib/style-memory.sh" ]] && source "${CONSULT_ROOT}/lib/style-memory.sh"
  }
  declare -F pool_derive_pack >/dev/null 2>&1 || {
    # shellcheck disable=SC1090
    [[ -f "${CONSULT_ROOT}/lib/experience-pool.sh" ]] && source "${CONSULT_ROOT}/lib/experience-pool.sh"
  }
  if declare -F style_derive_pack >/dev/null 2>&1; then
    style_json=$(style_derive_pack)
    project_json=$(project_memory_derive_pack "$d")
    lessons=$(lessons_derive_pack "$d")
  else
    local lf='' lesson_file
    while IFS= read -r lesson_file; do
      [[ -f "$lesson_file" ]] && lf="$lesson_file"
    done < <(printf '%s\n' "$d"/runs/iter-*/lessons.md | sort -V)
    [[ -n "$lf" ]] || { [[ -f "$d/lessons.md" ]] && lf="$d/lessons.md"; }
    if [[ -n "$lf" ]]; then
      lessons=$(jq -nc --arg pointer "$lf" '{pointer:$pointer,missing:false,excerpt:null}')
    else
      lessons=$(jq -nc '{pointer:null,missing:true,excerpt:null}')
    fi
    style_json=$(jq -nc '{missing:true,pointer:null,taste:[],risk:[],stack:[],never:[]}')
    project_json=$(jq -nc '{missing:true,pointer:null,excerpt:null}')
  fi
  local experience_pool_json
  if declare -F pool_derive_pack >/dev/null 2>&1; then
    experience_pool_json=$(pool_derive_pack)
  else
    experience_pool_json=$(jq -nc '{missing:true,pointer:null,retrieved:[],index_count:0}')
  fi
  local lf=''
  lf=$(jq -r '.pointer // empty' <<<"$lessons")
  if [[ -f "$cf" ]]; then
    cont=$(jq -c --arg file "$cf" '. + {file:$file,missing:false}' "$cf" 2>/dev/null) \
      || cont=$(jq -nc --arg file "$cf" '{file:$file,missing:true,invalid:true}')
  else
    cont=$(jq -nc --arg file "$cf" '{file:$file,missing:true}')
  fi

  for m in escalations.json pause.json continuation.json lessons.md; do
    case "$m" in
      escalations.json) [[ -f "$ef" ]] || missing=$(jq -c --arg m "$m" '. + [$m]' <<<"$missing") ;;
      pause.json)       [[ -f "$pf" ]] || missing=$(jq -c --arg m "$m" '. + [$m]' <<<"$missing") ;;
      continuation.json) [[ -f "$cf" ]] || missing=$(jq -c --arg m "$m" '. + [$m]' <<<"$missing") ;;
      lessons.md)       [[ -n "$lf" ]] || missing=$(jq -c --arg m "$m" '. + [$m]' <<<"$missing") ;;
    esac
  done
  if [[ "$jdir_missing" == true ]]; then missing=$(jq -c --arg m 'judgment/' '. + [$m]' <<<"$missing"); fi
  if [[ "$scores_missing" == true ]]; then missing=$(jq -c --arg m 'runs/iter-*/scores.json' '. + [$m]' <<<"$missing"); fi
  if [[ ! -f "$hf" ]]; then missing=$(jq -c --arg m 'history.jsonl' '. + [$m]' <<<"$missing"); fi
  if [[ "$mode_missing" == true ]]; then missing=$(jq -c --arg m 'engagement.md Mode:' '. + [$m]' <<<"$missing"); fi
  if jq -e '.missing == true' <<<"$style_json" >/dev/null 2>&1; then
    missing=$(jq -c --arg m 'state/style/style.md' '. + [$m]' <<<"$missing")
  fi
  if jq -e '.missing == true' <<<"$project_json" >/dev/null 2>&1; then
    missing=$(jq -c --arg m 'memory/project.md' '. + [$m]' <<<"$missing")
  fi

  local nsa='' open_ids oid
  open_ids=$(esc_open_ids "$d")
  if [[ -f "$pf" ]] && jq -e '(.paused == true or (.status? // "") == "paused")' "$pf" >/dev/null 2>&1; then
    nsa="authorized resume: create $(auth_resume_path "$d") (or set CONSULT_AUTHORIZE_RESUME) matching the escalation id+token with non-empty authorized_by and decision, then run: consult escalation $c resume <id> <token>"
  elif [[ -n "$open_ids" ]]; then
    oid=$(printf '%s\n' "$open_ids" | head -1)
    nsa="resolve open escalation '$oid': create the authorize-resume.json matching id+token, then run: consult escalation $c resume $oid <token>"
  else
    local refusal
    refusal=$(judgment_implement_refusal "$d" "$mode" '')
    if [[ -n "$refusal" ]]; then
      nsa="gate: $refusal"
    elif [[ "$scores_missing" == true ]]; then
      nsa="first measurement: consult score $c (or consult checks $c / consult bench $c run)"
    else
      nsa="continue the loop: consult bench $c run"
    fi
  fi
  if jq -e '.missing == true' <<<"$style_json" >/dev/null 2>&1; then
    [[ -z "$nsa" ]] || nsa+=" · "
    nsa+="org style missing: productteam style init (owner sets state/style/style.md)"
  fi

  local mode_json gate_json
  mode_json=$(jq -nc --arg value "$mode" --arg source "$d/engagement.md" \
    --argjson missing "$([[ "$mode_missing" == true ]] && printf true || printf false)" \
    '{value:$value,source:$source,missing:$missing}')
  gate_json=$(jq -nc --argjson status "$gate" \
    --argjson jdir_missing "$([[ "$jdir_missing" == true ]] && printf true || printf false)" \
    '{status:$status,judgment_dir_missing:$jdir_missing}')

  jq -n --arg client "$c" --argjson mode "$mode_json" --argjson gate "$gate_json" \
    --argjson scores "$scores" --argjson history "$history" \
    --argjson escalations "$esc" --argjson pause "$pause" \
    --argjson lessons "$lessons" --argjson continuation "$cont" \
    --argjson style "$style_json" --argjson project_memory "$project_json" \
    --argjson experience_pool "$experience_pool_json" \
    --arg next_suggested_action "$nsa" --argjson missing "$missing" \
    '{client:$client,mode:$mode,gate:$gate,scores:$scores,history:$history,escalations:$escalations,pause:$pause,lessons:$lessons,continuation:$continuation,style:$style,project_memory:$project_memory,experience_pool:$experience_pool,next_suggested_action:$next_suggested_action,missing:$missing}'
}

inspect_write_pack() { # client, client dir, out → rewrites the pack atomically; stdout: out path
  local c="$1" d="$2" out="$3"
  inspect_derive_pack "$c" "$d" | atomic_write "$out"
  printf '%s' "$out"
}
