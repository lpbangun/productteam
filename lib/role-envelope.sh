#!/usr/bin/env bash
# role-envelope.sh — single-turn role calls, sealed Builder input, authorship gates.
# Sourced by bin/consult. Plain files only; no worker loop or provider routing.

role_name() {
  case "${1,,}" in
    analyst) printf 'Analyst' ;;
    builder) printf 'Builder' ;;
    critic) printf 'Critic' ;;
    *) return 1 ;;
  esac
}

role_iter_ok() { [[ "$1" =~ ^[0-9]+$ ]]; }
role_root() { printf '%s/roles/iter-%s' "$1" "$2"; }
role_dir() { printf '%s/%s' "$(role_root "$1" "$2")" "$3"; }
role_seal_path() { printf '%s/Builder/seal.json' "$(role_root "$1" "$2")"; }
role_stamp_path() { printf '%s/Analyst/stamp.json' "$(role_root "$1" "$2")"; }
role_close_path() { printf '%s/close.json' "$(role_root "$1" "$2")"; }

role_atomic_write() { # file; payload on stdin
  local file="$1" tmp
  mkdir -p "$(dirname "$file")"
  tmp="$file.tmp.$$.$RANDOM"
  cat > "$tmp"
  mv "$tmp" "$file"
}

role_sha() { sha256sum "$1" | cut -d' ' -f1; }

role_next_attempt() { # role directory -> integer
  local dir="$1" n=0 p base
  if [[ -d "$dir" ]]; then
    while IFS= read -r p; do
      [[ -d "$p" ]] || continue
      base=${p##*/attempt-}
      [[ "$base" =~ ^[0-9]+$ ]] && (( base > n )) && n=$base
    done < <(printf '%s\n' "$dir"/attempt-* | sort -V)
  fi
  printf '%s' "$((n + 1))"
}

role_latest_complete() { # client dir, iter, Role -> latest valid attempt directory
  local dir p latest=''
  dir=$(role_dir "$1" "$2" "$3")
  [[ -d "$dir" ]] || return 1
  while IFS= read -r p; do
    [[ -d "$p" && -f "$p/manifest.json" ]] || continue
    role_manifest_ok "$p" && latest="$p"
  done < <(printf '%s\n' "$dir"/attempt-* | sort -V)
  [[ -n "$latest" ]] || return 1
  printf '%s' "$latest"
}

role_latest_success() { # client dir, iter, Role -> latest valid exit-0 attempt
  local dir p latest=''
  dir=$(role_dir "$1" "$2" "$3")
  [[ -d "$dir" ]] || return 1
  while IFS= read -r p; do
    [[ -d "$p" && -f "$p/manifest.json" ]] || continue
    role_manifest_ok "$p" || continue
    [[ "$(jq -r '.exit // -1' "$p/result.json")" == 0 ]] && latest="$p"
  done < <(printf '%s\n' "$dir"/attempt-* | sort -V)
  [[ -n "$latest" ]] || return 1
  printf '%s' "$latest"
}

role_manifest_ok() { # attempt directory
  local a="$1" req res
  [[ -f "$a/request.json" && -f "$a/result.json" && -f "$a/manifest.json" ]] || return 1
  jq -e '.role and .provider and (.iter | type == "number") and (.exit | type == "number") and .request_sha256 and .result_sha256' "$a/manifest.json" >/dev/null 2>&1 || return 1
  req=$(role_sha "$a/request.json")
  res=$(role_sha "$a/result.json")
  jq -e --arg req "$req" --arg res "$res" '.request_sha256 == $req and .result_sha256 == $res' "$a/manifest.json" >/dev/null 2>&1
}

role_seal() { # client dir, iter, input file, sealed-by
  local d="$1" iter="$2" input="$3" by="$4" seal abs sha
  role_iter_ok "$iter" || { printf 'iteration must be a non-negative integer\n'; return 1; }
  [[ -f "$input" ]] || { printf 'Builder input file not found: %s\n' "$input"; return 1; }
  seal=$(role_seal_path "$d" "$iter")
  [[ ! -e "$seal" ]] || { printf 'Builder input already sealed: %s\n' "$seal"; return 1; }
  abs=$(realpath "$input")
  sha=$(role_sha "$abs")
  jq -n --arg role Builder --argjson iter "$iter" --arg input "$abs" --arg sha "$sha" \
    --arg by "$by" --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    '{role:$role,iter:$iter,input_path:$input,input_sha256:$sha,sealed_by:$by,sealed_at:$ts,write_once:true}' \
    | role_atomic_write "$seal"
  printf '%s' "$seal"
}

role_seal_refusal() { # client dir, iter -> refusal or empty
  local d="$1" iter="$2" seal input expected actual
  seal=$(role_seal_path "$d" "$iter")
  [[ -f "$seal" ]] || { printf 'missing sealed Builder input: %s' "$seal"; return 0; }
  if ! jq -e --argjson iter "$iter" '.role == "Builder" and .iter == $iter and (.input_path | type == "string" and length > 0) and (.input_sha256 | test("^[0-9a-f]{64}$"))' "$seal" >/dev/null 2>&1; then
    printf 'invalid Builder seal: %s' "$seal"; return 0
  fi
  input=$(jq -r '.input_path' "$seal")
  expected=$(jq -r '.input_sha256' "$seal")
  [[ -f "$input" ]] || { printf 'sealed Builder input missing: %s (seal %s)' "$input" "$seal"; return 0; }
  actual=$(role_sha "$input")
  [[ "$actual" == "$expected" ]] || { printf 'sealed Builder input hash mismatch: %s (seal %s)' "$input" "$seal"; return 0; }
  printf ''
}

role_write_attempt() { # d iter Role provider identity task input_ref input_sha exit refusal output
  local d="$1" iter="$2" role="$3" provider="$4" identity="$5" task="$6" input_ref="$7" input_sha="$8" exit_code="$9"
  shift 9
  local refusal="$1" output="$2" rdir attempt ad requested ran reqsha ressha output_sha
  rdir=$(role_dir "$d" "$iter" "$role")
  attempt=$(role_next_attempt "$rdir")
  ad="$rdir/attempt-$attempt"
  requested=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  mkdir -p "$ad"
  jq -n --arg role "$role" --argjson iter "$iter" --arg provider "$provider" --arg identity "$identity" \
    --arg task "$task" --arg input_ref "$input_ref" --arg input_sha "$input_sha" --arg ts "$requested" \
    '{role:$role,iter:$iter,provider:$provider,identity:$identity,task:$task,input_ref:(if $input_ref=="" then null else $input_ref end),input_sha256:(if $input_sha=="" then null else $input_sha end),requested_at:$ts}' \
    | role_atomic_write "$ad/request.json"
  ran=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  output_sha=$(printf '%s' "$output" | sha256sum | cut -d' ' -f1)
  jq -n --arg role "$role" --argjson iter "$iter" --arg provider "$provider" --arg identity "$identity" \
    --argjson exit "$exit_code" --arg refusal "$refusal" --arg output "$output" --arg output_sha "$output_sha" --arg ts "$ran" \
    '{role:$role,iter:$iter,provider:$provider,identity:$identity,exit:$exit,ran_at:$ts,refusal_reason:(if $refusal=="" then null else $refusal end),output:$output,output_sha256:$output_sha}' \
    | role_atomic_write "$ad/result.json"
  reqsha=$(role_sha "$ad/request.json")
  ressha=$(role_sha "$ad/result.json")
  jq -n --arg role "$role" --argjson iter "$iter" --arg provider "$provider" --arg identity "$identity" \
    --arg requested "$requested" --arg ran "$ran" --argjson exit "$exit_code" --arg req "$reqsha" --arg res "$ressha" \
    '{role:$role,iter:$iter,provider:$provider,identity:$identity,requested_at:$requested,ran_at:$ran,exit:$exit,request_sha256:$req,result_sha256:$res}' \
    | role_atomic_write "$ad/manifest.json"
  printf '%s' "$ad"
}

role_write_stamp() { # d iter attempt dir
  local d="$1" iter="$2" ad="$3" stamp result_sha
  stamp=$(role_stamp_path "$d" "$iter")
  result_sha=$(role_sha "$ad/result.json")
  jq -n --arg role Analyst --argjson iter "$iter" --arg identity "$(jq -r '.identity' "$ad/result.json")" \
    --arg provider "$(jq -r '.provider' "$ad/result.json")" --arg result "$ad/result.json" --arg sha "$result_sha" \
    --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    '{role:$role,iter:$iter,identity:$identity,provider:$provider,result_path:$result,result_sha256:$sha,stamped_at:$ts}' \
    | role_atomic_write "$stamp"
}

role_invoke() { # client, dir, Role, iter, task -> stdout provider reply
  local c="$1" d="$2" role="$3" iter="$4" task="$5" identity provider input_ref='' input_sha='' refusal='' output='' rc=0 snapshot repo ad
  role_iter_ok "$iter" || { printf 'iteration must be a non-negative integer\n' >&2; return 1; }
  identity="${CONSULT_ROLE_IDENTITY:-${role,,}}"
  [[ -n "${identity//[[:space:]]/}" ]] || { printf 'role identity must be non-blank\n' >&2; return 1; }
  provider="${CONSULT_PROVIDER:-$(runtime_default 2>/dev/null || printf unresolved)}"

  refusal=$(progress_blocked_reason "$d")
  if [[ "$role" == Builder && -z "$refusal" ]]; then
    refusal=$(role_seal_refusal "$d" "$iter")
    if [[ -z "$refusal" ]]; then
      input_ref=$(jq -r '.input_path' "$(role_seal_path "$d" "$iter")")
      input_sha=$(jq -r '.input_sha256' "$(role_seal_path "$d" "$iter")")
      task=$(cat "$input_ref")
      refusal=$(judgment_implement_refusal "$d" "$(judgment_mode "$d")" "$(judgment_bound_direction "$d" "$(judgment_mode "$d")")")
    fi
  fi
  if [[ -n "$refusal" ]]; then
    ad=$(role_write_attempt "$d" "$iter" "$role" "$provider" "$identity" "$task" "$input_ref" "$input_sha" 1 "$refusal" '')
    printf '%s (envelope %s)\n' "$refusal" "$ad" >&2
    return 1
  fi

  snapshot=$(workspace_ensure "$c" "$d" '') || {
    refusal="isolated workspace unavailable for $c"
    ad=$(role_write_attempt "$d" "$iter" "$role" "$provider" "$identity" "$task" "$input_ref" "$input_sha" 1 "$refusal" '')
    printf '%s (envelope %s)\n' "$refusal" "$ad" >&2
    return 1
  }
  repo=$(jq -r '.path' <<<"$snapshot")
  set +e
  output=$(provider_ask "Role: $role\nClient: $c\nIteration: $iter\nSingle-turn task:\n$task\nReturn only your result for this role." "$repo" 2>&1)
  rc=$?
  set -e
  [[ $rc -eq 0 ]] || refusal="provider $provider failed with exit $rc"
  ad=$(role_write_attempt "$d" "$iter" "$role" "$provider" "$identity" "$task" "$input_ref" "$input_sha" "$rc" "$refusal" "$output")
  if [[ $rc -eq 0 && "$role" == Analyst ]]; then role_write_stamp "$d" "$iter" "$ad"; fi
  if [[ $rc -ne 0 ]]; then printf '%s (envelope %s)\n' "$refusal" "$ad" >&2; return "$rc"; fi
  printf '%s\n' "$output"
}

role_stamp_refusal() { # dir iter -> refusal or empty
  local d="$1" iter="$2" stamp result expected actual builder evaluator bad
  stamp=$(role_stamp_path "$d" "$iter")
  [[ -f "$stamp" ]] || { printf 'scores invalid: missing Analyst stamp %s' "$stamp"; return 0; }
  if ! jq -e --argjson iter "$iter" '.role == "Analyst" and .iter == $iter and (.identity|length>0) and (.result_path|length>0) and (.result_sha256|test("^[0-9a-f]{64}$"))' "$stamp" >/dev/null 2>&1; then
    printf 'scores invalid: malformed Analyst stamp %s' "$stamp"; return 0
  fi
  result=$(jq -r '.result_path' "$stamp")
  expected=$(jq -r '.result_sha256' "$stamp")
  [[ -f "$result" ]] || { printf 'scores invalid: Analyst result missing for stamp %s' "$stamp"; return 0; }
  actual=$(role_sha "$result")
  [[ "$actual" == "$expected" && "$(jq -r '.exit // -1' "$result")" == 0 ]] || { printf 'scores invalid: Analyst stamp/result mismatch %s' "$stamp"; return 0; }
  evaluator=$(jq -r '.identity' "$stamp")
  if bad=$(role_latest_success "$d" "$iter" Builder 2>/dev/null); then
    builder=$(jq -r '.identity' "$bad/result.json")
    [[ "$builder" != "$evaluator" ]] || { printf 'scores invalid: implementer = evaluator (%s) for iter %s' "$builder" "$iter"; return 0; }
  fi
  printf ''
}

role_close() { # dir iter
  local d="$1" iter="$2" refusal critic stamp close builder='' evaluator critic_sha stamp_sha
  role_iter_ok "$iter" || { printf 'iteration must be a non-negative integer\n'; return 1; }
  refusal=$(progress_blocked_reason "$d")
  [[ -z "$refusal" ]] || { printf '%s\n' "$refusal"; return 1; }
  refusal=$(role_stamp_refusal "$d" "$iter")
  [[ -z "$refusal" ]] || { printf '%s\n' "$refusal"; return 1; }
  critic=$(role_latest_success "$d" "$iter" Critic 2>/dev/null || true)
  [[ -n "$critic" ]] || { printf 'cannot close: missing complete Critic envelope under %s\n' "$(role_dir "$d" "$iter" Critic)"; return 1; }
  close=$(role_close_path "$d" "$iter")
  [[ ! -e "$close" ]] || { printf 'iteration already closed: %s\n' "$close"; return 1; }
  stamp=$(role_stamp_path "$d" "$iter")
  evaluator=$(jq -r '.identity' "$stamp")
  local bd
  bd=$(role_latest_success "$d" "$iter" Builder 2>/dev/null || true)
  [[ -z "$bd" ]] || builder=$(jq -r '.identity' "$bd/result.json")
  critic_sha=$(role_sha "$critic/manifest.json")
  stamp_sha=$(role_sha "$stamp")
  jq -n --argjson iter "$iter" --arg critic "$critic/manifest.json" --arg critic_sha "$critic_sha" \
    --arg stamp "$stamp" --arg stamp_sha "$stamp_sha" --arg implementer "$builder" --arg evaluator "$evaluator" \
    --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    '{iter:$iter,decision:"closed",closed_at:$ts,critic_manifest:$critic,critic_manifest_sha256:$critic_sha,analyst_stamp:$stamp,analyst_stamp_sha256:$stamp_sha,implementer_identity:(if $implementer=="" then null else $implementer end),evaluator_identity:$evaluator}' \
    | role_atomic_write "$close"
  printf '%s' "$close"
}

role_status() { # client dir [iter] -> stable JSON
  local c="$1" d="$2" iter="${3:-}" root role ad item asked='[]' ran='[]' produced='[]' missing='[]'
  if [[ -z "$iter" ]]; then
    iter=0
    if [[ -d "$d/roles" ]]; then
      local p n
      while IFS= read -r p; do
        [[ -d "$p" ]] || continue
        n=${p##*/iter-}
        [[ "$n" =~ ^[0-9]+$ ]] && (( n > iter )) && iter=$n
      done < <(printf '%s\n' "$d"/roles/iter-* | sort -V)
    fi
  fi
  role_iter_ok "$iter" || return 1
  root=$(role_root "$d" "$iter")
  for role in Analyst Builder Critic; do
    ad=$(role_latest_complete "$d" "$iter" "$role" 2>/dev/null || true)
    if [[ -z "$ad" ]]; then
      missing=$(jq -c --arg p "$root/$role/attempt-*/manifest.json" '. + [$p]' <<<"$missing")
      continue
    fi
    item=$(jq -c --arg request "$ad/request.json" \
      '{role,identity,provider,task,input_ref,input_sha256,at:.requested_at,request:$request}' "$ad/request.json")
    asked=$(jq -c --argjson x "$item" '. + [$x]' <<<"$asked")
    item=$(jq -c --arg result "$ad/result.json" \
      '{role,identity,provider,exit,refusal_reason,output_sha256,at:.ran_at,result:$result}' "$ad/result.json")
    ran=$(jq -c --argjson x "$item" '. + [$x]' <<<"$ran")
    if [[ "$(jq -r '.exit' "$ad/result.json")" == 0 ]]; then
      item=$(jq -c --arg manifest "$ad/manifest.json" --arg result "$ad/result.json" \
        '{role,identity,provider,exit,request_sha256,result_sha256,manifest:$manifest,result:$result}' "$ad/manifest.json")
      produced=$(jq -c --argjson x "$item" '. + [$x]' <<<"$produced")
    fi
  done
  jq -n --arg client "$c" --argjson iter "$iter" --arg root "$root" --argjson asked "$asked" --argjson ran "$ran" --argjson produced "$produced" --argjson missing "$missing" \
    '{client:$client,iter:$iter,artifact_root:$root,asked:$asked,ran:$ran,produced:$produced,missing:$missing}'
}
