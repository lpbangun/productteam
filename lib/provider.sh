# Provider + runtime seam — the only place the system knows which model runs.
# Default: authenticated Cursor `agent` CLI (headless). No API keys, no mocks.
# Swap by setting CONSULT_PROVIDER to any binary that answers a prompt
# on stdout:  CONSULT_PROVIDER=mytool bin/consult bench <client> run
#
# Supported coding runtimes (detected when present on PATH):
#   agent (Cursor) · claude · codex · opencode · gemini · cursor
#
# Cursor agent flags used by default wrapper:
#   -p/--print  headless · --trust workspace · --sandbox disabled for real checks

# Ordered preference for auto-pick when CONSULT_PROVIDER is unset.
CONSULT_RUNTIME_CANDIDATES=(agent claude codex opencode gemini)

runtime_have() { # $1=bin → 0 if on PATH
  command -v "$1" >/dev/null 2>&1
}

runtime_detect() {
  # Print TSV: name<TAB>status<TAB>path_or_note
  local name
  for name in agent claude codex opencode gemini cursor; do
    if runtime_have "$name"; then
      printf '%s\tfound\t%s\n' "$name" "$(command -v "$name")"
    else
      printf '%s\tmissing\tnot on PATH\n' "$name"
    fi
  done
}

runtime_default() {
  # Resolve default provider binary name.
  if [[ -n "${CONSULT_PROVIDER:-}" ]]; then
    printf '%s' "$CONSULT_PROVIDER"
    return 0
  fi
  local name
  for name in "${CONSULT_RUNTIME_CANDIDATES[@]}"; do
    if runtime_have "$name"; then
      printf '%s' "$name"
      return 0
    fi
  done
  return 1
}

provider_ask() { # $1=prompt  $2=cwd (optional)
  local prompt="$1" cwd="${2:-$PWD}"
  local bin
  if [[ -n "${CONSULT_PROVIDER:-}" ]]; then
    bin="$CONSULT_PROVIDER"
  else
    bin="$(runtime_default)" || {
      printf 'consult: no coding runtime found (tried: %s). Install one or set CONSULT_PROVIDER.\n' \
        "${CONSULT_RUNTIME_CANDIDATES[*]}" >&2
      return 127
    }
  fi
  if ! runtime_have "$bin" && [[ "$bin" != /* || ! -x "$bin" ]]; then
    # Allow absolute path to an executable even if not on PATH basename lookup
    if [[ "$bin" == /* && -x "$bin" ]]; then
      :
    else
      printf 'consult: provider %s not found on PATH. Set CONSULT_PROVIDER to a working binary, or install agent|claude|codex|opencode|gemini.\n' "$bin" >&2
      return 127
    fi
  fi
  if [[ "$bin" == "agent" || "$bin" == "cursor-agent" || "$(basename "$bin")" == "agent" ]]; then
    ( cd "$cwd" && "$bin" -p --trust --sandbox disabled --output-format text "$prompt" )
  else
    ( cd "$cwd" && "$bin" -p "$prompt" --output-format text )
  fi
}
