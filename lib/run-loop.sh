#!/usr/bin/env bash
# run-loop.sh — thin overnight loop driver (file orchestration, not a second org brain).
# Sourced by bin/productteam. Uses existing inspect/gate/role/score/escalation seams.

loop_dir() { printf '%s/loop' "$1"; }
loop_progress_path() { printf '%s/progress.json' "$(loop_dir "$1")"; }
loop_heartbeat_path() { printf '%s/heartbeat' "$(loop_dir "$1")"; }
loop_log_path() { printf '%s/run.log' "$(loop_dir "$1")"; }

loop_no_lift_limit() {
  local n="${CONSULT_NO_LIFT_STREAK:-2}"
  [[ "$n" =~ ^[0-9]+$ ]] || n=2
  printf '%s' "$n"
}

loop_time_limit_seconds() { # max_hours → seconds (CONSULT_LOOP_TEST_SECONDS overrides)
  local max_hours="$1"
  if [[ -n "${CONSULT_LOOP_TEST_SECONDS:-}" && "${CONSULT_LOOP_TEST_SECONDS}" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
    awk -v s="${CONSULT_LOOP_TEST_SECONDS}" 'BEGIN{printf "%.0f", s+0.5}'
    return 0
  fi
  awk -v h="$max_hours" 'BEGIN{printf "%.0f", h * 3600 + 0.5}'
}

loop_elapsed_seconds() { # started_at ISO → integer seconds since start
  local started="$1" now start_s now_s
  now=$(date -u +%s)
  start_s=$(date -u -d "$started" +%s 2>/dev/null || date -u -j -f '%Y-%m-%dT%H:%M:%SZ' "$started" +%s 2>/dev/null || printf '%s' "$now")
  now_s=$now
  printf '%s' "$((now_s - start_s))"
}

loop_log_msg() { # client dir, message
  local d="$1" msg="$2" log ts
  log=$(loop_log_path "$d")
  mkdir -p "$(dirname "$log")"
  ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  printf '%s %s\n' "$ts" "$msg" >> "$log"
}

loop_touch_heartbeat() { # client dir
  local d="$1" hb ts
  hb=$(loop_heartbeat_path "$d")
  mkdir -p "$(dirname "$hb")"
  ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  printf '%s\n' "$ts" > "$hb"
}

loop_read_progress() { # client dir → JSON on stdout
  local d="$1" f
  f=$(loop_progress_path "$d")
  [[ -f "$f" ]] || { printf 'null'; return 0; }
  jq -c . "$f" 2>/dev/null || printf 'null'
}

loop_write_progress() { # client dir; jq patch object on stdin
  local d="$1" f tmp cur ts patch
  f=$(loop_progress_path "$d")
  mkdir -p "$(dirname "$f")"
  ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  cur=$(loop_read_progress "$d")
  [[ "$cur" == 'null' ]] && cur='{}'
  patch=$(cat)
  tmp="$f.tmp.$$"
  jq -c --arg ts "$ts" --argjson patch "$patch" \
    '. * $patch + {updated_at:$ts, heartbeat_at:$ts}' <<<"$cur" > "$tmp"
  mv "$tmp" "$f"
}

loop_set_phase() { # client dir, phase
  local d="$1" phase="$2"
  jq -n --arg phase "$phase" '{phase:$phase}' | loop_write_progress "$d"
}

loop_latest_overall() { # client dir → numeric overall or empty
  local d="$1" rd ov
  rd=$(printf '%s\n' "$d"/runs/iter-* 2>/dev/null | sort -V | tail -1)
  [[ -n "$rd" && -f "$rd/scores.json" ]] || return 0
  ov=$(jq -r '.overall // empty' "$rd/scores.json" 2>/dev/null || true)
  [[ -n "$ov" && "$ov" != 'null' ]] || return 0
  printf '%s' "$ov"
}

loop_critic_reject() { # client dir, iter → 0 iff REJECT for this iter
  local d="$1" iter="$2" f verdict got
  f="$d/judgment/critic-rebuttal.json"
  [[ -f "$f" ]] || return 1
  verdict=$(jget "$f" verdict)
  got=$(jget "$f" iter)
  [[ "$verdict" == REJECT && "$got" == "$iter" ]]
}

loop_update_no_lift() { # client dir → writes no_lift_streak + last_overall via progress patch
  local d="$1" cur ov last delta streak limit
  ov=$(loop_latest_overall "$d")
  cur=$(loop_read_progress "$d")
  last=$(jq -r '.last_overall // empty' <<<"$cur")
  streak=$(jq -r '.no_lift_streak // 0' <<<"$cur")
  if [[ -z "$ov" ]]; then
    jq -n --argjson streak "$streak" --arg last "${last:-null}" \
      '{no_lift_streak:$streak, last_overall:(if $last == "null" or $last == "" then null else ($last|tonumber?) end)}' \
      | loop_write_progress "$d"
    return 0
  fi
  if [[ -n "$last" && "$last" != 'null' ]]; then
    delta=$(awk -v a="$ov" -v b="$last" 'BEGIN{printf "%.2f", a-b}')
    if awk -v d="$delta" 'BEGIN{exit !(d <= 0)}'; then
      streak=$((streak + 1))
    else
      streak=0
    fi
  fi
  jq -n --argjson streak "$streak" --argjson ov "$ov" \
    '{no_lift_streak:$streak, last_overall:$ov}' | loop_write_progress "$d"
  limit=$(loop_no_lift_limit)
  if (( streak >= limit )); then
    return 1
  fi
  return 0
}

loop_check_time_exceeded() { # client dir, max_hours → 0 if exceeded
  local d="$1" max_hours="$2" cur started limit elapsed
  cur=$(loop_read_progress "$d")
  started=$(jq -r '.started_at // empty' <<<"$cur")
  [[ -n "$started" ]] || return 1
  limit=$(loop_time_limit_seconds "$max_hours")
  elapsed=$(loop_elapsed_seconds "$started")
  (( elapsed >= limit ))
}

loop_stop() { # client dir, reason, [detail] → never returns
  local d="$1" reason="$2" detail="${3:-}"
  local status='stopped'
  [[ "$reason" == 'max-iters' ]] && status='completed'
  jq -n --arg status "$status" --arg reason "$reason" --arg detail "$detail" \
    '{status:$status, stop_reason:$reason, stop_detail:(if $detail=="" then null else $detail end)}' \
    | loop_write_progress "$d"
  loop_log_msg "$d" "stop: $reason${detail:+ — $detail}"
  loop_touch_heartbeat "$d"
  exit 0
}

loop_pause_for_signal() { # client dir
  local d="$1"
  jq -n '{status:"paused", stop_reason:"killed-resume-pending"}' | loop_write_progress "$d"
  loop_log_msg "$d" 'signal received — paused for resume (killed-resume-pending)'
  loop_touch_heartbeat "$d"
  exit 0
}

loop_run_one_iter() { # client, client dir, iter, dry_run, no_provider
  local c="$1" d="$2" iter="$3" dry="$4" no_prov="$5"
  local block mode refusal hint sleep_s

  if [[ -n "${CONSULT_LOOP_PHASE_SLEEP:-}" ]]; then
    sleep_s="${CONSULT_LOOP_PHASE_SLEEP}"
    [[ "$sleep_s" =~ ^[0-9]+([.][0-9]+)?$ ]] && sleep "$sleep_s" 2>/dev/null || true
  fi

  loop_set_phase "$d" inspect
  loop_touch_heartbeat "$d"
  jq -n --argjson pid "$$" '{pid:$pid, status:"running", stop_reason:null}' | loop_write_progress "$d"

  max_hours=$(jq -r '.max_hours' <<<"$(loop_read_progress "$d")")
  if loop_check_time_exceeded "$d" "$max_hours"; then
    loop_stop "$d" max-hours "elapsed >= limit"
  fi

  inspect_write_pack "$c" "$d" "$d/inspect-pack.json" >/dev/null
  loop_log_msg "$d" "iter $iter: inspect complete"

  block=$(progress_blocked_reason "$d")
  [[ -z "$block" ]] || loop_stop "$d" escalation "$block"

  loop_set_phase "$d" gate
  mode=$(judgment_mode "$d")
  refusal=$(judgment_implement_refusal "$d" "$mode" '')
  [[ -z "$refusal" ]] || loop_stop "$d" gate-block "$refusal"

  if loop_critic_reject "$d" "$iter"; then
    loop_stop "$d" critic-reject "Critic verdict REJECT for iter $iter"
  fi
  loop_log_msg "$d" "iter $iter: gate clear"

  loop_set_phase "$d" role
  if (( dry || no_prov )); then
    loop_log_msg "$d" "iter $iter: role phase simulated (dry-run/no-provider)"
  else
    loop_log_msg "$d" "iter $iter: role phase — no auto-Builder (seal+rebuttal required manually)"
    if [[ -f "$(role_seal_path "$d" "$iter")" ]] && judgment_critic_rebuttal_ok "$d" "$iter" 2>/dev/null; then
      loop_log_msg "$d" "iter $iter: Builder seal+rebuttal present — invoke manually if needed"
    fi
  fi

  loop_set_phase "$d" score
  if (( dry || no_prov )); then
    loop_log_msg "$d" "iter $iter: score skipped (dry-run/no-provider)"
  else
    refusal=$(role_stamp_refusal "$d" "$iter")
    if [[ -z "$refusal" ]]; then
      local scorer
      scorer=$(engagement_scorer "$d")
      if [[ "$scorer" == checks ]]; then
        if CHECKS_LAST_DIR='' CHECKS_LAST_SNAPSHOT='' cmd_checks "$c" 2>>"$(loop_log_path "$d")"; then
          cmd_score_checks_publish "$c" "$d" "$iter" '' 2>>"$(loop_log_path "$d")" || \
            loop_log_msg "$d" "iter $iter: score publish refused"
        else
          loop_log_msg "$d" "iter $iter: checks failed"
        fi
      elif [[ "$scorer" == provider ]]; then
        if cmd_bench_run "$c" --iter "$iter" >>"$(loop_log_path "$d")" 2>&1; then
          loop_log_msg "$d" "iter $iter: provider score complete"
        else
          loop_log_msg "$d" "iter $iter: provider score refused or failed"
        fi
      fi
    else
      loop_log_msg "$d" "iter $iter: score skipped — $refusal"
    fi
  fi

  loop_set_phase "$d" close
  if loop_critic_reject "$d" "$iter"; then
    loop_stop "$d" critic-reject "Critic verdict REJECT for iter $iter"
  fi
  if role_latest_success "$d" "$iter" Critic >/dev/null 2>&1; then
    refusal=$(role_stamp_refusal "$d" "$iter")
    if [[ -z "$refusal" && -z "$(progress_blocked_reason "$d")" ]]; then
      if close_out=$(role_close "$d" "$iter" 2>&1); then
        loop_log_msg "$d" "iter $iter: closed — $close_out"
      else
        loop_log_msg "$d" "iter $iter: close refused — $close_out"
      fi
    else
      loop_log_msg "$d" "iter $iter: close skipped — envelopes incomplete or blocked"
    fi
  else
    loop_log_msg "$d" "iter $iter: close skipped — Critic envelope incomplete"
  fi

  loop_set_phase "$d" memory
  hint=$(pool_seal_hint "$c" "$iter")
  loop_log_msg "$d" "iter $iter: $hint"

  if ! loop_update_no_lift "$d"; then
    loop_stop "$d" no-lift "no_lift_streak >= $(loop_no_lift_limit)"
  fi
  loop_log_msg "$d" "iter $iter: complete"
}

run_loop() { # client, client dir, max_hours, max_iters, dry_run, no_provider, resume
  local c="$1" d="$2" max_hours="$3" max_iters="$4" dry="$5" no_prov="$6" resume="$7"
  local prog iter start_ts log rel_log max_i

  mkdir -p "$(loop_dir "$d")"
  log=$(loop_log_path "$d")
  rel_log="state/engagements/$c/loop/run.log"
  touch "$log"
  trap 'loop_pause_for_signal "'"$d"'"' TERM INT

  prog=$(loop_read_progress "$d")
  if [[ "$prog" != 'null' ]]; then
    local status pid
    status=$(jq -r '.status // empty' <<<"$prog")
    pid=$(jq -r '.pid // 0' <<<"$prog")
    if [[ "$status" == 'running' && "$pid" =~ ^[0-9]+$ && "$pid" -gt 0 && "$pid" != "$$" ]]; then
      if kill -0 "$pid" 2>/dev/null; then
        die "run-loop already active for $c (pid $pid) — refuse duplicate; use --resume after kill if intentional"
      fi
    fi
  fi

  if (( resume )); then
    [[ "$prog" != 'null' ]] || die "run-loop --resume: no progress file at $(loop_progress_path "$d")"
    local rstatus rreason
    rstatus=$(jq -r '.status // empty' <<<"$prog")
    rreason=$(jq -r '.stop_reason // empty' <<<"$prog")
    if [[ "$rstatus" == 'running' ]]; then :;
    elif [[ "$rstatus" == 'paused' && "$rreason" == 'killed-resume-pending' ]]; then :;
    else
      die "run-loop --resume: progress status=$rstatus stop_reason=$rreason — expected running or paused/killed-resume-pending"
    fi
    iter=$(jq -r '.iter // 0' <<<"$prog")
    max_hours=$(jq -r '.max_hours // empty' <<<"$prog")
    max_iters=$(jq -r '.max_iters // empty' <<<"$prog")
    [[ -n "$max_hours" && -n "$max_iters" ]] || die 'run-loop --resume: progress missing max_hours/max_iters'
    loop_log_msg "$d" "resume from iter $iter phase $(jq -r '.phase // "unknown"' <<<"$prog")"
    jq -n --argjson pid "$$" '{status:"running", stop_reason:null, pid:$pid}' | loop_write_progress "$d"
  else
    start_ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    iter=0
    jq -n \
      --arg client "$c" --arg started "$start_ts" --arg log "$rel_log" \
      --argjson max_iters "$max_iters" --argjson max_hours "$max_hours" \
      --argjson pid "$$" \
      '{client:$client, started_at:$started, updated_at:$started, heartbeat_at:$started,
        status:"running", stop_reason:null, iter:0, max_iters:$max_iters, max_hours:$max_hours,
        phase:"inspect", no_lift_streak:0, last_overall:null, pid:$pid, log:$log}' \
      | loop_write_progress "$d"
    loop_log_msg "$d" "run-loop start max_hours=$max_hours max_iters=$max_iters dry=$dry no_provider=$no_prov"
  fi

  max_i=$(jq -r '.max_iters' <<<"$(loop_read_progress "$d")")
  iter=$(jq -r '.iter' <<<"$(loop_read_progress "$d")")

  while true; do
    max_hours=$(jq -r '.max_hours' <<<"$(loop_read_progress "$d")")
    if loop_check_time_exceeded "$d" "$max_hours"; then
      loop_stop "$d" max-hours "elapsed >= limit"
    fi
    iter=$(jq -r '.iter' <<<"$(loop_read_progress "$d")")
    if (( iter >= max_i )); then
      loop_stop "$d" max-iters "completed $iter iterations"
    fi
    next=$((iter + 1))
    loop_run_one_iter "$c" "$d" "$next" "$dry" "$no_prov"
    jq -n --argjson iter "$next" '{iter:$iter, phase:"inspect"}' | loop_write_progress "$d"
    iter=$next
    if (( iter >= max_i )); then
      loop_stop "$d" max-iters "completed $iter iterations"
    fi
  done
}
