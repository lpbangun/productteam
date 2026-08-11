#!/usr/bin/env bash
# agent-cards.sh — durable named agent cards (markdown + json). Plain files under state/agents/.
# Sourced by bin/productteam. Requires CONSULT_ROOT and jq.

agent_cards_root() {
  printf '%s/state/agents' "${CONSULT_ROOT:?CONSULT_ROOT unset}"
}

agent_card_json_path() { # id → permanent card json path
  printf '%s/%s.json' "$(agent_cards_root)" "$1"
}

agent_card_md_path() { # id → permanent card md path
  printf '%s/%s.md' "$(agent_cards_root)" "$1"
}

agent_card_engagement_dir() { # client dir → engagement agents dir
  printf '%s/agents' "$1"
}

agent_card_engagement_json() { # client dir → specialist json if present
  printf '%s/specialist.json' "$(agent_card_engagement_dir "$1")"
}

agent_card_normalize_key() {
  printf '%s' "${1,,}"
}

agent_card_id_for_role() {
  case "$1" in
    Principal) printf 'principal' ;;
    Analyst)   printf 'analyst' ;;
    Builder)   printf 'builder' ;;
    Critic)    printf 'critic' ;;
    *) return 1 ;;
  esac
}

agent_card_read_json() { # path → stdout json or fail
  local f="$1"
  [[ -f "$f" ]] || return 1
  jq -e '.id and .display_name and .role and .kind' "$f" >/dev/null 2>&1 || return 1
  jq -c '.' "$f"
}

agent_card_load() { # id|display_name|role [client_dir] → json stdout
  local key="$1" client_dir="${2:-}" norm id f card role_id
  norm=$(agent_card_normalize_key "$key")
  case "$norm" in
    principal|analyst|builder|critic|specialist) id="$norm" ;;
    *)
      case "$key" in
        Principal|Analyst|Builder|Critic) id=$(agent_card_id_for_role "$key") || return 1 ;;
        *)
          for f in "$(agent_cards_root)"/*.json; do
            [[ -f "$f" ]] || continue
            [[ "$(basename "$f" .json)" == _* ]] && continue
            if [[ "$(agent_card_normalize_key "$(jq -r .display_name "$f")")" == "$norm" ]]; then
              agent_card_read_json "$f" && return 0
            fi
            if [[ "$(agent_card_normalize_key "$(jq -r .id "$f")")" == "$norm" ]]; then
              agent_card_read_json "$f" && return 0
            fi
            if [[ "$(jq -r .role "$f")" == "$key" ]]; then
              agent_card_read_json "$f" && return 0
            fi
          done
          if [[ -n "$client_dir" ]]; then
            f=$(agent_card_engagement_json "$client_dir")
            if [[ -f "$f" ]]; then
              if [[ "$norm" == specialist ]] || \
                 [[ "$(agent_card_normalize_key "$(jq -r .display_name "$f")")" == "$norm" ]] || \
                 [[ "$(agent_card_normalize_key "$(jq -r .id "$f")")" == "$norm" ]]; then
                agent_card_read_json "$f" && return 0
              fi
            fi
          fi
          return 1
          ;;
      esac
      ;;
  esac
  if [[ "$id" == specialist && -n "$client_dir" ]]; then
    f=$(agent_card_engagement_json "$client_dir")
    [[ -f "$f" ]] && { agent_card_read_json "$f"; return $?; }
    f="$(agent_cards_root)/_templates/specialist.json"
    agent_card_read_json "$f"
    return $?
  fi
  f=$(agent_card_json_path "$id")
  agent_card_read_json "$f"
}

agent_card_for_role() { # Role [client_dir] → permanent card json
  local role="$1" client_dir="${2:-}" id
  if [[ -n "${CONSULT_ROLE_CARD:-}" ]]; then
    agent_card_load "${CONSULT_ROLE_CARD}" "$client_dir" && return 0
  fi
  id=$(agent_card_id_for_role "$role") || return 1
  agent_card_load "$id" "$client_dir"
}

agent_card_for_engagement() { # client_dir → specialist json or empty
  local d="$1" f
  f=$(agent_card_engagement_json "$d")
  [[ -f "$f" ]] || return 1
  agent_card_read_json "$f"
}

agent_card_list_ids() { # → permanent card ids (one per line)
  local f base
  for f in "$(agent_cards_root)"/*.json; do
    [[ -f "$f" ]] || continue
    base=$(basename "$f" .json)
    [[ "$base" == _* ]] && continue
    printf '%s\n' "$base"
  done | sort
}

agent_card_list() { # [--json]
  local json=0 a
  for a in "$@"; do
    case "$a" in
      --json) json=1 ;;
      *) return 1 ;;
    esac
  done
  if (( json )); then
    local ids card arr='[]' id
    ids=$(agent_card_list_ids)
    while IFS= read -r id; do
      [[ -z "$id" ]] && continue
      card=$(agent_card_load "$id") || continue
      arr=$(jq -c --argjson x "$card" '. + [$x]' <<<"$arr")
    done <<<"$ids"
    jq -c '.' <<<"$arr"
    return 0
  fi
  local id card
  while IFS= read -r id; do
    [[ -z "$id" ]] && continue
    card=$(agent_card_load "$id") || continue
    jq -r '"\(.display_name) (\(.role)) — \(.id)"' <<<"$card"
  done <<<"$(agent_card_list_ids)"
}

agent_card_show() { # name|id|role [--json] [client_dir]
  local key='' json=0 client_dir='' a
  while (( $# )); do
    case "$1" in
      --json) json=1; shift ;;
      -*) return 1 ;;
      *)
        if [[ -z "$key" ]]; then key="$1"; shift
        elif [[ -z "$client_dir" ]]; then client_dir="$1"; shift
        else return 1; fi
        ;;
    esac
  done
  [[ -n "$key" ]] || return 1
  local card
  card=$(agent_card_load "$key" "$client_dir") || return 1
  if (( json )); then
    printf '%s\n' "$card"
    return 0
  fi
  local id md
  id=$(jq -r .id <<<"$card")
  md=$(agent_card_md_path "$id")
  if [[ "$id" == specialist && -n "$client_dir" && -f "$(agent_card_engagement_dir "$client_dir")/specialist.md" ]]; then
    cat "$(agent_card_engagement_dir "$client_dir")/specialist.md"
    return 0
  fi
  [[ -f "$md" ]] && { cat "$md"; return 0; }
  jq -r '
    "# \(.display_name)\n\nRole: \(.role)\nKind: \(.kind)\n\n## Traits\n" +
    (.traits | map("- " + .) | join("\n")) + "\n\n## Duties\n" +
    (.duties | map("- " + .) | join("\n")) + "\n\n## Anti-duties\n" +
    (.anti_duties | map("- " + .) | join("\n")) + "\n\n## Voice\n\n\(.voice)\n"
  ' <<<"$card"
}

agent_card_seed_specialist() { # client_dir [display_name] → paths created
  local d="$1" name="${2:-Ada}" dest dir tpl_json tpl_md
  [[ -d "$d" ]] || return 1
  dest=$(agent_card_engagement_dir "$d")
  dir="$dest"
  mkdir -p "$dir"
  tpl_json="$(agent_cards_root)/_templates/specialist.json"
  tpl_md="$(agent_cards_root)/_templates/specialist.md"
  [[ -f "$tpl_json" && -f "$tpl_md" ]] || return 1
  jq --arg name "$name" '.display_name = $name' "$tpl_json" > "$dir/specialist.json"
  sed "s/^name: Ada$/name: $name/" "$tpl_md" > "$dir/specialist.md"
  printf '%s/specialist.json\n' "$dir"
}

agent_card_prompt_block() { # card json → prompt prefix for role_invoke
  local card="$1" role="$2" client="$3" iter="$4"
  jq -r --arg role "$role" --arg client "$client" --argjson iter "$iter" '
    "You are \(.display_name), the \(.role) of a consulting organization.\n" +
    "Role binding: \($role) · Client: \($client) · Iteration: \($iter)\n\n" +
    "Traits: \(.traits | join(", "))\n" +
    "Voice: \(.voice)\n\n" +
    "Duties:\n" + (.duties | map("- " + .) | join("\n")) + "\n\n" +
    "Anti-duties:\n" + (.anti_duties | map("- " + .) | join("\n")) + "\n\n" +
    "Single-turn task:\n"
  ' <<<"$card"
}

agent_card_jq_fields() { # card json → jq object for envelope fields
  jq -c '{display_name, card_id: .id, traits, voice}' <<<"$1"
}
