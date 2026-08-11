#!/usr/bin/env bash
# direction-gate.sh — Guided product-direction proposals, selection binding, Critic rebuttal.
# Extends judgment-gate.sh; plain JSON beside engagement.md.

_direction_cards_ready() {
  declare -F agent_card_for_role >/dev/null 2>&1 && return 0
  [[ -n "${CONSULT_ROOT:-}" && -f "${CONSULT_ROOT}/lib/agent-cards.sh" ]] || return 1
  # shellcheck disable=SC1090
  source "${CONSULT_ROOT}/lib/agent-cards.sh"
}

direction_max() { # → clamped 1–5 (default 3)
  local n="${CONSULT_DIRECTION_MAX:-3}"
  [[ "$n" =~ ^[0-9]+$ ]] || n=3
  (( n < 1 )) && n=1
  (( n > 5 )) && n=5
  printf '%s' "$n"
}

direction_proposals_path() { printf '%s/judgment/proposals.json' "$1"; }
direction_rebuttal_path() { printf '%s/judgment/critic-rebuttal.json' "$1"; }

direction_proposer_card() { # role, client dir → {role, display_name} json
  local role="$1" d="$2" card='' dn=''
  _direction_cards_ready && card=$(agent_card_for_role "$role" "$d" 2>/dev/null || true)
  if [[ -n "$card" ]]; then
    dn=$(jq -r '.display_name' <<<"$card")
    jq -nc --arg role "$role" --arg display_name "$dn" '{role:$role,display_name:$display_name}'
    return 0
  fi
  case "$role" in
    Principal) dn='Kai' ;;
    Analyst)   dn='Meridian' ;;
    *)         dn="$role" ;;
  esac
  jq -nc --arg role "$role" --arg display_name "$dn" '{role:$role,display_name:$display_name}'
}

direction_proposed_by_default() { # client dir → json array Principal + Analyst cards
  local d="$1" p a
  p=$(direction_proposer_card Principal "$d")
  a=$(direction_proposer_card Analyst "$d")
  jq -nc --argjson p "$p" --argjson a "$a" '[$p, $a]'
}

direction_resolve_proposer() { # by name (Kai|Meridian|Principal|Analyst), client dir → display name
  local by="$1" d="$2" norm card=''
  norm=$(printf '%s' "${by,,}")
  case "$norm" in
    kai|principal) direction_proposer_card Principal "$d" | jq -r .display_name ;;
    meridian|analyst) direction_proposer_card Analyst "$d" | jq -r .display_name ;;
    *)
      _direction_cards_ready && card=$(agent_card_load "$by" "$d" 2>/dev/null || true)
      if [[ -n "$card" ]]; then jq -r .display_name <<<"$card"; return 0; fi
      printf '%s' "$by"
      ;;
  esac
}

direction_selector_display_name() { # selected_by, client dir → display name for selection.json
  direction_resolve_proposer "$1" "$2"
}

direction_count() { # client dir → integer count of directions in proposals.json
  local f
  f=$(direction_proposals_path "$1")
  [[ -f "$f" ]] || { printf '0'; return 0; }
  jq -r '(.directions // []) | length' "$f" 2>/dev/null || printf '0'
}

direction_propose_refusal() { # client dir → refusal or empty
  local d="$1" mode max count
  mode=$(judgment_mode "$d")
  if [[ "$mode" != Guided ]]; then
    printf 'direction propose requires Guided mode (current: %s)' "$mode"
    return 0
  fi
  max=$(direction_max)
  count=$(direction_count "$d")
  if (( count >= max )); then
    printf 'direction propose refused: %s directions already (max %s)' "$count" "$max"
    return 0
  fi
  printf ''
}

direction_propose() { # d, title, tradeoffs, lift, proposer_name, evidence paths… → path or refusal on stderr
  local d="$1" title="$2" tradeoffs="$3" lift="$4" by="$5"
  shift 5
  local refusal f max count next_id evidence='[]' proposed_by proposed payload path
  refusal=$(direction_propose_refusal "$d")
  [[ -z "$refusal" ]] || { printf '%s\n' "$refusal" >&2; return 1; }
  f=$(direction_proposals_path "$d")
  max=$(direction_max)
  proposed_by=$(direction_resolve_proposer "$by" "$d")
  if (( $# > 0 )); then
    evidence=$(printf '%s\n' "$@" | jq -R . | jq -s -c .)
  fi
  if [[ -f "$f" ]]; then
    count=$(direction_count "$d")
    next_id="d$((count + 1))"
    payload=$(jq -c \
      --arg id "$next_id" --arg title "$title" --arg tradeoffs "$tradeoffs" \
      --arg expected_lift "$lift" --argjson evidence "$evidence" --arg proposed_by "$proposed_by" \
      '.directions += [{id:$id,title:$title,tradeoffs:$tradeoffs,expected_lift:$expected_lift,evidence_paths:$evidence,proposed_by:$proposed_by}]' "$f")
  else
    next_id='d1'
    payload=$(jq -n \
      --arg mode Guided --argjson max "$max" --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
      --argjson proposed_by_team "$(direction_proposed_by_default "$d")" \
      --arg id "$next_id" --arg title "$title" --arg tradeoffs "$tradeoffs" \
      --arg expected_lift "$lift" --argjson evidence "$evidence" --arg proposer "$proposed_by" \
      '{mode:$mode,proposed_by:$proposed_by_team,max:$max,directions:[{id:$id,title:$title,tradeoffs:$tradeoffs,expected_lift:$expected_lift,evidence_paths:$evidence,proposed_by:$proposer}],ts:$ts}')
  fi
  printf '%s' "$payload" | judgment_atomic_write "$f"
  printf '%s' "$f"
}

direction_list() { # d [--json] → stdout
  local d="$1" json="${2:-0}" f
  f=$(direction_proposals_path "$d")
  if [[ ! -f "$f" ]]; then
    if (( json )); then jq -n '{mode:"Guided",directions:[],max:(env.CONSULT_DIRECTION_MAX|tonumber? // 3),proposed_by:[]}'
    else printf '  (no proposals yet)\n'; fi
    return 0
  fi
  if (( json )); then cat "$f"; return 0; fi
  jq -r '.directions[] | "\(.id): \(.title) (by \(.proposed_by)) — \(.tradeoffs)"' "$f" | while IFS= read -r line; do
    printf '  %s\n' "$line"
  done
  jq -r '"  proposers: " + ([.proposed_by[] | "\(.display_name) (\(.role))"] | join(", "))' "$f" 2>/dev/null || true
}

direction_clear() { # d, owner_flag (0|1) → 0 on success
  local d="$1" owner="${2:-0}"
  (( owner )) || { printf 'direction clear requires --i-am-owner (proposals are pre-selection scratch)\n' >&2; return 1; }
  local f
  f=$(direction_proposals_path "$d")
  [[ -f "$f" ]] && rm -f "$f"
  return 0
}

direction_proposal_lookup() { # d, id_or_title → prints title|proposal_id or empty
  local d="$1" key="$2" f title pid
  f=$(direction_proposals_path "$d")
  [[ -f "$f" ]] || return 1
  title=$(jq -r --arg k "$key" '.directions[] | select(.id == $k) | .title' "$f" 2>/dev/null | head -1)
  if [[ -n "$title" && "$title" != null ]]; then
    pid="$key"
    printf '%s|%s' "$title" "$pid"
    return 0
  fi
  return 1
}

judgment_select_direction() { # d, direction_or_id, selected_by → selection path
  local d="$1" key="$2" sel="${3:-principal}" dir proposal_id='' display_name lookup
  dir="$key"
  if lookup=$(direction_proposal_lookup "$d" "$key" 2>/dev/null); then
    dir="${lookup%%|*}"
    proposal_id="${lookup#*|}"
  fi
  display_name=$(direction_selector_display_name "$sel" "$d")
  judgment_write_selection "$d" "$dir" "$sel" "$proposal_id" "$display_name" >/dev/null
  printf '%s' "$d/judgment/selection.json"
}

judgment_critic_rebuttal_ok() { # d, iter → 0 iff rebuttal complete and not REJECT
  local d="$1" iter="$2" f verdict got
  f=$(direction_rebuttal_path "$d")
  [[ -f "$f" ]] || return 1
  verdict=$(jget "$f" verdict)
  got=$(jget "$f" iter)
  [[ "$verdict" == ACCEPT || "$verdict" == ACCEPT-WITH-NITS ]] || return 1
  [[ "$got" == "$iter" ]] || return 1
  [[ -n "$(jget "$f" rebuttal)" && -n "$(jget "$f" ts)" ]]
}

judgment_critic_rebuttal_refusal() { # d, mode, iter → refusal or empty
  local d="$1" mode="$2" iter="$3" f verdict got rebuttal client
  client=$(basename "$d")
  case "$mode" in
    Guided) ;;
    *) printf ''; return 0 ;;
  esac
  f=$(direction_rebuttal_path "$d")
  if [[ ! -f "$f" ]]; then
    printf 'Guided: missing Critic rebuttal for iter %s on %s — run: productteam direction rebut %s %s ACCEPT|ACCEPT-WITH-NITS|REJECT <text…> (expected %s)' \
      "$iter" "$client" "$client" "$iter" "$f"
    return 0
  fi
  got=$(jget "$f" iter)
  verdict=$(jget "$f" verdict)
  rebuttal=$(jget "$f" rebuttal)
  if [[ "$got" != "$iter" ]]; then
    printf 'Guided: critic-rebuttal.json iter %s != requested iter %s for %s (%s)' "$got" "$iter" "$client" "$f"
    return 0
  fi
  if [[ -z "$rebuttal" || -z "$(jget "$f" ts)" ]]; then
    printf 'Guided: critic-rebuttal.json for %s must record verdict, rebuttal, and ts (%s)' "$client" "$f"
    return 0
  fi
  if [[ "$verdict" == REJECT ]]; then
    printf 'Guided: Critic verdict REJECT for iter %s on %s — Builder seal blocked (%s)' "$iter" "$client" "$f"
    return 0
  fi
  if [[ "$verdict" != ACCEPT && "$verdict" != ACCEPT-WITH-NITS ]]; then
    printf 'Guided: critic-rebuttal.json verdict must be ACCEPT|ACCEPT-WITH-NITS|REJECT for %s (%s)' "$client" "$f"
    return 0
  fi
  printf ''
}

judgment_write_critic_rebuttal() { # d, iter, verdict, rebuttal text → path
  local d="$1" iter="$2" verdict="$3" rebuttal="$4" dn='' role='Critic'
  _direction_cards_ready && dn=$(agent_card_for_role Critic "$d" 2>/dev/null | jq -r '.display_name // "Vesper"' || true)
  [[ -n "$dn" ]] || dn='Vesper'
  case "$verdict" in
    ACCEPT|ACCEPT-WITH-NITS|REJECT) ;;
    *) return 1 ;;
  esac
  jq -n \
    --arg mode Guided --argjson iter "$iter" --arg verdict "$verdict" \
    --arg rebuttal "$rebuttal" --arg display_name "$dn" --arg role "$role" \
    --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    '{mode:$mode,iter:$iter,verdict:$verdict,rebuttal:$rebuttal,display_name:$display_name,role:$role,ts:$ts}' \
    | judgment_atomic_write "$(direction_rebuttal_path "$d")"
  printf '%s' "$(direction_rebuttal_path "$d")"
}

role_seal_direction_refusal() { # d, input file → refusal or empty
  local d="$1" input="$2" mode bound
  mode=$(judgment_mode "$d")
  [[ "$mode" == Guided ]] || { printf ''; return 0; }
  bound=$(judgment_bound_direction "$d" "$mode")
  if [[ -z "$bound" ]]; then
    printf 'Guided: no bound direction for seal — run: productteam gate %s select <direction>' "$(basename "$d")"
    return 0
  fi
  if ! grep -qF "$bound" "$input" 2>/dev/null; then
    printf 'Guided: sealed Builder input must cite bound direction "%s" (substring check)' "$bound"
    return 0
  fi
  printf ''
}
