# lib/onboarding.sh — first-run setup for a new user.
#
# Non-interactive by design: nothing is prompted and stdin is never read, so
# the same command behaves identically in a terminal, a script and CI.
# `consult onboarding` previews; `consult onboarding --yes` (or
# CONSULT_NONINTERACTIVE=1) writes. Everything it writes lives under
# CONSULT_STATE_ROOT and is byte-identical on every re-run, so repeating
# onboarding is always safe.

onboarding_first_client() {
  local first
  first=$( { ls "$STATE" 2>/dev/null || true; } | head -1)
  printf '%s' "${first:-<client>}"
}

onboarding_run() { # $1=1 to write, anything else to preview
  local apply="${1:-0}"
  local cfg="$STATE_ROOT/config" marker="$STATE_ROOT/first-run"
  local prov present engagements desired

  prov="$(runtime_default 2>/dev/null || true)"
  present=$(runtime_detect | awk -F'\t' '$2 == "found" { printf "%s %s (%s)  ", $1, $4, $3 }')
  [[ -n "$present" ]] || present='none on this device yet — install one, then re-run'
  engagements=$( { ls "$STATE" 2>/dev/null || true; } | tr '\n' ' ')

  printf '\n  %sProduct Consulting Harness — onboarding%s\n' "${B:-}" "${R:-}"
  printf '  %sNothing is prompted and stdin is never read.%s\n\n' "${D:-}" "${R:-}"

  printf '  1. Detect the coding agents here      %sconsult agents%s\n' "${B:-}" "${R:-}"
  printf '       %s%s%s\n' "${D:-}" "$present" "${R:-}"
  printf '  2. Pick the provider for prompts      %sCONSULT_PROVIDER=<binary>%s\n' "${B:-}" "${R:-}"
  printf '       %sactive: %s%s\n' "${D:-}" "${prov:-none yet}" "${R:-}"
  printf '  3. Open an engagement                 %sstate/engagements/<client>/engagement.md%s\n' "${B:-}" "${R:-}"
  printf '       %spresent: %s%s\n' "${D:-}" "${engagements:-none yet}" "${R:-}"
  printf '  4. Score that client                  %sconsult score <client>%s\n' "${B:-}" "${R:-}"
  printf '       %sthe scorer is declared by the engagement contract.json%s\n' "${D:-}" "${R:-}"
  printf '  5. Read scores, history, reasoning    %sconsult bench <client>%s\n\n' "${B:-}" "${R:-}"

  if [[ "$apply" == 1 ]]; then
    mkdir -p "$STATE_ROOT"
    desired=$(printf 'provider=%s' "${prov:-none}")
    if [[ -f "$cfg" && "$(cat "$cfg")" == "$desired" ]]; then
      printf '  %salready configured: %s%s\n' "${D:-}" "$cfg" "${R:-}"
    else
      printf '%s\n' "$desired" > "$cfg"
      printf '  %swrote %s%s\n' "${D:-}" "$cfg" "${R:-}"
    fi
    [[ -e "$marker" ]] || printf 'seen\n' > "$marker"
  else
    printf '  %spreview only — nothing written. Apply with --yes%s\n' "${D:-}" "${R:-}"
  fi

  printf '\n  %sNext: consult bench %s%s\n\n' "${B:-}" "$(onboarding_first_client)" "${R:-}"
}
