#!/usr/bin/env bash
# judgment-gate.sh — durable per-mode judgment gates + machine status.
# Sourced by bin/consult. Plain JSON beside engagement.md; atomic writers.
# The current `Mode:` line in engagement.md is the sole authority.

judgment_mode() { # client dir → current Mode ('' if missing/unparseable); never fails
  local d="$1"
  [[ -f "$d/engagement.md" ]] || { printf ''; return 0; }
  awk '/^Mode:/{gsub(/\*/,""); print $2; exit}' "$d/engagement.md"
}

jget() { # file, key → string value or '' (missing/invalid never fails)
  local f="$1" k="$2"
  if [[ -f "$f" ]]; then
    jq -r --arg k "$k" 'if has($k) then .[$k] else "" end' "$f" 2>/dev/null || printf ''
  else
    printf ''
  fi
}

judgment_file() { # client dir, mode → durable payload path ('' for unknown mode)
  local d="$1" mode="$2"
  case "$mode" in
    Guided)    printf '%s/judgment/selection.json' "$d" ;;
    Directive) printf '%s/judgment/directive.json' "$d" ;;
    Challenge) printf '%s/judgment/challenge.json' "$d" ;;
    Override)  printf '%s/judgment/override.json' "$d" ;;
    *)         return 0 ;;
  esac
}

judgment_selection_ok() { # client dir, expected mode → 0 iff selection is complete for that mode
  local d="$1" expected="${2:-Guided}" f="$1/judgment/selection.json" dir sel mode ts
  [[ -f "$f" ]] || return 1
  dir=$(jget "$f" direction); sel=$(jget "$f" selected_by)
  mode=$(jget "$f" mode); ts=$(jget "$f" ts)
  [[ -n "$dir" && -n "$sel" && "$mode" == "$expected" && -n "$ts" ]]
}

judgment_directive_ok() { # client dir → 0 iff directive.json is complete for Directive
  local d="$1" f="$1/judgment/directive.json" dir dec mode ts
  [[ -f "$f" ]] || return 1
  dir=$(jget "$f" direction); dec=$(jget "$f" decision)
  mode=$(jget "$f" mode); ts=$(jget "$f" ts)
  [[ -n "$dir" && -n "$dec" && "$mode" == Directive && -n "$ts" ]]
}

judgment_challenge_ok() { # client dir → 0 iff challenge complete and current-mode selection matches safer alternative
  local d="$1" f="$1/judgment/challenge.json" s="$1/judgment/selection.json" harmful alt ev sel mode ts
  [[ -f "$f" ]] || return 1
  harmful=$(jget "$f" harmful); alt=$(jget "$f" safer_alternative); ev=$(jget "$f" evidence)
  mode=$(jget "$f" mode); ts=$(jget "$f" ts)
  [[ -n "$harmful" && -n "$alt" && -n "$ev" && "$mode" == Challenge && -n "$ts" ]] || return 1
  judgment_selection_ok "$d" Challenge || return 1
  sel=$(jget "$s" direction)
  [[ "$sel" == "$alt" ]]
}

judgment_override_ok() { # client dir → 0 iff override.json is complete and non_waivers all true
  local d="$1" f="$1/judgment/override.json" dir crit ev mode ts
  [[ -f "$f" ]] || return 1
  dir=$(jget "$f" direction); crit=$(jget "$f" critic_record); ev=$(jget "$f" evidence_record)
  mode=$(jget "$f" mode); ts=$(jget "$f" ts)
  [[ -n "$dir" && -n "$crit" && -n "$ev" && "$mode" == Override && -n "$ts" ]] || return 1
  jq -e '(.risks | type) == "array" and (.risks | length) > 0' "$f" >/dev/null 2>&1 || return 1
  jq -e '.non_waivers.critic == true and .non_waivers.evidence == true and .non_waivers.frozen_contract == true' "$f" >/dev/null 2>&1 || return 1
}

judgment_implement_refusal() { # client dir, mode, direction ('' = bound) → prints refusal reason ('' = allowed); never fails
  local d="$1" mode="$2" want="${3:-}" f bound harmful
  case "$mode" in
    Guided)
      f="$d/judgment/selection.json"
      if [[ ! -f "$f" ]]; then
        printf 'Guided: no selection recorded for %s — run: consult gate %s select <direction> (expected %s)' "$(basename "$d")" "$(basename "$d")" "$f"
        return 0
      fi
      judgment_selection_ok "$d" || { printf 'Guided: selection.json for %s must have non-empty direction + selected_by (%s)' "$(basename "$d")" "$f"; return 0; }
      bound=$(jget "$f" direction)
      ;;
    Directive)
      f="$d/judgment/directive.json"
      if [[ ! -f "$f" ]]; then
        printf 'Directive: no directive recorded for %s — run: consult gate %s direct <direction> (expected %s)' "$(basename "$d")" "$(basename "$d")" "$f"
        return 0
      fi
      judgment_directive_ok "$d" || { printf 'Directive: directive.json for %s must record direction + decision (%s)' "$(basename "$d")" "$f"; return 0; }
      bound=$(jget "$f" direction)
      ;;
    Challenge)
      f="$d/judgment/challenge.json"
      if [[ ! -f "$f" ]]; then
        printf 'Challenge: no challenge recorded for %s — run: consult gate %s challenge <harmful> <safer> <evidence> (expected %s)' "$(basename "$d")" "$(basename "$d")" "$f"
        return 0
      fi
      bound=$(jget "$f" safer_alternative)
      harmful=$(jget "$f" harmful)
      local challenge_evidence challenge_mode challenge_ts
      challenge_evidence=$(jget "$f" evidence)
      challenge_mode=$(jget "$f" mode)
      challenge_ts=$(jget "$f" ts)
      if [[ -z "$harmful" || -z "$bound" || -z "$challenge_evidence" || "$challenge_mode" != Challenge || -z "$challenge_ts" ]]; then
        printf 'Challenge: challenge.json must record mode, timestamp, harmful, safer_alternative, and evidence for %s (%s)' "$(basename "$d")" "$f"
        return 0
      fi
      if [[ -n "$want" && "$want" == "$harmful" ]]; then
        printf 'Challenge: "%s" is the challenged harmful path for %s — always refused (safer alternative: %s; %s)' "$want" "$(basename "$d")" "$bound" "$f"
        return 0
      fi
      judgment_challenge_ok "$d" || { printf 'Challenge: selection.json must select safer_alternative for %s (challenge: %s; selection: %s/judgment/selection.json)' "$(basename "$d")" "$f" "$d"; return 0; }
      ;;
    Override)
      f="$d/judgment/override.json"
      if [[ ! -f "$f" ]]; then
        printf 'Override: no override recorded for %s — run: consult gate %s override <direction> <risk> <critic-record> <evidence-record> (expected %s)' "$(basename "$d")" "$(basename "$d")" "$f"
        return 0
      fi
      judgment_override_ok "$d" || { printf 'Override: override.json for %s must record exact direction, non-empty risks, critic_record, evidence_record and non_waivers.{critic,evidence,frozen_contract}=true — non-waivable (%s)' "$(basename "$d")" "$f"; return 0; }
      bound=$(jget "$f" direction)
      ;;
    *)
      printf 'mode "%s" unknown/missing for %s — engagement.md Mode: must be Guided|Directive|Challenge|Override' "$mode" "$(basename "$d")"
      return 0
      ;;
  esac
  if [[ -n "$want" && "$want" != "$bound" ]]; then
    printf '%s: direction "%s" != bound direction "%s" for %s (%s)' "$mode" "$want" "$bound" "$(basename "$d")" "$f"
    return 0
  fi
}

judgment_bound_direction() { # client dir, mode → bound implementable direction ('' if not derivable)
  local d="$1" mode="$2"
  case "$mode" in
    Guided)    jget "$d/judgment/selection.json" direction ;;
    Directive) jget "$d/judgment/directive.json" direction ;;
    Challenge) jget "$d/judgment/challenge.json" safer_alternative ;;
    Override)  jget "$d/judgment/override.json" direction ;;
    *)         printf '' ;;
  esac
}

jflag() { # file, jq predicate → true|false (missing file/invalid → false); never fails
  local f="$1" expr="$2"
  [[ -f "$f" ]] && jq -e "$expr" "$f" >/dev/null 2>&1 && printf 'true' || printf 'false'
}

judgment_status() { # client, client dir → status JSON (valid; exit 0 even when refused)
  local client="$1" d="$2" mode f='' known=0 allowed='null' decision='indeterminate' reason='' bound='' ts='' req='{}' pre='{}'
  mode=$(judgment_mode "$d")
  case "$mode" in
    Guided|Directive|Challenge|Override) known=1 ;;
    *) mode='unknown' ;;
  esac
  if (( known )); then
    f=$(judgment_file "$d" "$mode")
    bound=$(judgment_bound_direction "$d" "$mode")
    reason=$(judgment_implement_refusal "$d" "$mode" '')
    if [[ -z "$reason" ]]; then
      allowed='true'; decision='allowed'; reason='implement allowed'
    else
      allowed='false'; decision='refused'
    fi
    [[ -f "$f" ]] && ts=$(jget "$f" ts) || f=''
    case "$mode" in
      Guided)
        req='{"selection.json":"selection with non-empty direction + selected_by"}'
        pre=$(jq -n \
          --argjson selection_present "$(jflag "$d/judgment/selection.json" 'true')" \
          --argjson direction_present "$(jflag "$d/judgment/selection.json" '((.direction? // "") | length) > 0')" \
          --argjson selected_by_present "$(jflag "$d/judgment/selection.json" '((.selected_by? // "") | length) > 0')" \
          '{selection_present:$selection_present,direction_present:$direction_present,selected_by_present:$selected_by_present}')
        ;;
      Directive)
        req='{"directive.json":"direction + decision (+ risks array, may be empty)"}'
        pre=$(jq -n \
          --argjson directive_present "$(jflag "$d/judgment/directive.json" 'true')" \
          --argjson direction_present "$(jflag "$d/judgment/directive.json" '((.direction? // "") | length) > 0')" \
          --argjson decision_present "$(jflag "$d/judgment/directive.json" '((.decision? // "") | length) > 0')" \
          --argjson risks_recorded "$(jflag "$d/judgment/directive.json" 'has("risks")')" \
          '{directive_present:$directive_present,direction_present:$direction_present,decision_present:$decision_present,risks_recorded:$risks_recorded}')
        ;;
      Challenge)
        req='{"challenge.json":"harmful + safer_alternative + evidence","selection.json":"direction == safer_alternative"}'
        pre=$(jq -n \
          --argjson challenge_present "$(jflag "$d/judgment/challenge.json" 'true')" \
          --argjson harmful_present "$(jflag "$d/judgment/challenge.json" '((.harmful? // "") | length) > 0')" \
          --argjson safer_alternative_present "$(jflag "$d/judgment/challenge.json" '((.safer_alternative? // "") | length) > 0')" \
          --argjson evidence_present "$(jflag "$d/judgment/challenge.json" '((.evidence? // "") | length) > 0')" \
          --argjson selection_matches "$( { [[ -f "$d/judgment/challenge.json" && -f "$d/judgment/selection.json" ]] && jq -e --arg alt "$(jget "$d/judgment/challenge.json" safer_alternative)" '.mode == "Challenge" and ((.ts? // "") | length) > 0 and .direction == $alt' "$d/judgment/selection.json" >/dev/null 2>&1; } && printf 'true' || printf 'false')" \
          '{challenge_present:$challenge_present,harmful_present:$harmful_present,safer_alternative_present:$safer_alternative_present,evidence_present:$evidence_present,selection_matches:$selection_matches}')
        ;;
      Override)
        req='{"override.json":"direction + non-empty risks + critic_record + evidence_record + non_waivers.{critic,evidence,frozen_contract}=true"}'
        pre=$(jq -n \
          --argjson override_present "$(jflag "$d/judgment/override.json" 'true')" \
          --argjson direction_present "$(jflag "$d/judgment/override.json" '((.direction? // "") | length) > 0')" \
          --argjson risks_present "$(jflag "$d/judgment/override.json" '(.risks | type) == "array" and (.risks | length) > 0')" \
          --argjson critic_record_present "$(jflag "$d/judgment/override.json" '((.critic_record? // "") | length) > 0')" \
          --argjson evidence_record_present "$(jflag "$d/judgment/override.json" '((.evidence_record? // "") | length) > 0')" \
          --argjson non_waivers_present "$(jflag "$d/judgment/override.json" '.non_waivers.critic == true and .non_waivers.evidence == true and .non_waivers.frozen_contract == true')" \
          '{override_present:$override_present,direction_present:$direction_present,risks_present:$risks_present,critic_record_present:$critic_record_present,evidence_record_present:$evidence_record_present,non_waivers_present:$non_waivers_present}')
        ;;
    esac
  else
    reason='mode missing/unknown — engagement.md Mode: must be Guided|Directive|Challenge|Override'
  fi
  jq -n \
    --arg client "$client" \
    --arg mode "$mode" \
    --argjson allowed "$allowed" \
    --arg decision "$decision" \
    --arg reason "$reason" \
    --arg bound_direction "$bound" \
    --arg artifact "$f" \
    --arg artifact_ts "$ts" \
    --argjson required "$req" \
    --argjson present "$pre" \
    '{client:$client,mode:$mode,allowed:$allowed,decision:$decision,reason:$reason,bound_direction:(if $bound_direction=="" then null else $bound_direction end),artifact:(if $artifact=="" then null else $artifact end),artifact_ts:(if $artifact_ts=="" then null else $artifact_ts end),required:$required,present:$present}'
}

judgment_atomic_write() { # file → writes stdin payload atomically (tmp + rename)
  local file="$1" tmp
  mkdir -p "$(dirname "$file")"
  tmp="$file.tmp.$$"
  cat > "$tmp"
  mv "$tmp" "$file"
}

judgment_write_selection() { # client dir, direction, selected_by (default principal) → path
  local d="$1" dir="$2" sel="${3:-principal}"
  jq -n --arg mode "$(judgment_mode "$d")" --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --arg direction "$dir" --arg selected_by "$sel" --arg decision 'allowed' \
    '{mode:$mode,ts:$ts,direction:$direction,selected_by:$selected_by,decision:$decision}' \
    | judgment_atomic_write "$d/judgment/selection.json"
  printf '%s' "$d/judgment/selection.json"
}

judgment_write_directive() { # client dir, direction, risks… (may be empty) → path
  local d="$1" dir="$2"; shift 2
  local risks='[]'
  if (( $# > 0 )); then
    risks=$(printf '%s\n' "$@" | jq -R . | jq -s -c .)
  fi
  jq -n --arg mode "$(judgment_mode "$d")" --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --arg direction "$dir" --arg decision 'allowed' --argjson risks "$risks" \
    '{mode:$mode,ts:$ts,direction:$direction,risks:$risks,decision:$decision}' \
    | judgment_atomic_write "$d/judgment/directive.json"
  printf '%s' "$d/judgment/directive.json"
}

judgment_write_challenge() { # client dir, harmful, safer_alternative, evidence → path
  local d="$1" harmful="$2" safer="$3" evidence="$4"
  jq -n --arg mode "$(judgment_mode "$d")" --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --arg direction "$harmful" --arg safer_alternative "$safer" --arg evidence "$evidence" \
    --arg decision 'refused' \
    '{mode:$mode,ts:$ts,harmful:$direction,safer_alternative:$safer_alternative,evidence:$evidence,decision:$decision}' \
    | judgment_atomic_write "$d/judgment/challenge.json"
  printf '%s' "$d/judgment/challenge.json"
}

judgment_write_override() { # client dir, direction, risk, critic_record, evidence_record → path
  local d="$1" dir="$2" risk="$3" crit="$4" ev="$5" risks
  risks=$(jq -nc --arg r "$risk" '[$r]')
  jq -n --arg mode "$(judgment_mode "$d")" --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --arg direction "$dir" --argjson risks "$risks" --arg critic_record "$crit" \
    --arg evidence_record "$ev" --arg decision 'allowed' \
    '{mode:$mode,ts:$ts,direction:$direction,risks:$risks,critic_record:$critic_record,evidence_record:$evidence_record,decision:$decision,non_waivers:{critic:true,evidence:true,frozen_contract:true}}' \
    | judgment_atomic_write "$d/judgment/override.json"
  printf '%s' "$d/judgment/override.json"
}
