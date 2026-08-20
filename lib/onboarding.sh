# lib/onboarding.sh — first-run setup for a new user.
#
# Non-interactive by design: nothing is prompted and stdin is never read, so
# the same command behaves identically in a terminal, a script and CI.
# `productteam onboarding` previews; `productteam onboarding --yes` (or
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

  # Shared role chrome + status badges (empty defaults when uncolored).
  # shellcheck source=lib/theme.sh
  source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/theme.sh"

  printf '\n  %sProductTeam — onboarding%s\n' "${B:-}" "${R:-}"
  printf '  %sNothing is prompted and stdin is never read.%s\n\n' "${D:-}" "${R:-}"

  printf '  1. Detect the coding agents here      %sproductteam agents%s\n' "${B:-}" "${R:-}"
  if [[ "$present" == none* ]]; then
    printf '       %s %s%s%s\n' "$(status_badge pending)" "${D:-}" "$present" "${R:-}"
  else
    printf '       %s %s%s%s\n' "$(status_badge done)" "${D:-}" "$present" "${R:-}"
  fi
  printf '  2. Pick the provider for prompts      %sCONSULT_PROVIDER=<binary>%s\n' "${B:-}" "${R:-}"
  if [[ -z "$prov" || "$prov" == none* ]]; then
    printf '       %s %sactive: %s%s\n' "$(status_badge pending)" "${D:-}" "${prov:-none yet}" "${R:-}"
  else
    printf '       %s %sactive: %s%s\n' "$(status_badge done)" "${D:-}" "$prov" "${R:-}"
  fi
  printf '  3. Open an engagement                 %sstate/engagements/<client>/engagement.md%s\n' "${B:-}" "${R:-}"
  if [[ -n "$engagements" ]]; then
    printf '       %s %spresent: %s%s\n' "$(status_badge done)" "${D:-}" "$engagements" "${R:-}"
  else
    printf '       %s %spresent: %s%s\n' "$(status_badge pending)" "${D:-}" "${engagements:-none yet}" "${R:-}"
  fi
  printf '  4. Score that client                  %sproductteam score <client> --iter <n>%s\n' "${B:-}" "${R:-}"
  printf '       %s %sthe scorer is declared by the engagement contract.json%s\n' "$(status_badge pending)" "${D:-}" "${R:-}"
  printf '  5. Read scores, history, reasoning    %sproductteam bench <client>%s\n\n' "${B:-}" "${R:-}"

  if [[ "$apply" == 1 ]]; then
    mkdir -p "$STATE_ROOT"
    desired=$(printf 'provider=%s' "${prov:-none}")
    if [[ -f "$cfg" && "$(cat "$cfg")" == "$desired" ]]; then
      printf '  %s %salready configured: %s%s\n' "$(status_badge done)" "${D:-}" "$cfg" "${R:-}"
    else
      printf '%s\n' "$desired" > "$cfg"
      printf '  %s %swrote %s%s\n' "$(status_badge done)" "${D:-}" "$cfg" "${R:-}"
    fi
    [[ -e "$marker" ]] || printf 'seen\n' > "$marker"
  else
    printf '  %s %spreview only — nothing written. Apply with --yes%s\n' "$(status_badge pending)" "${D:-}" "${R:-}"
  fi

  printf '\n  %sNext: productteam bench %s%s\n\n' "${B:-}" "$(onboarding_first_client)" "${R:-}"
}
