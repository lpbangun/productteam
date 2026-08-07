# Provider + runtime seam — the only place the system knows which model runs.
# Default: the authenticated Cursor `agent` CLI (headless). No API keys, no mocks.
# Swap by setting CONSULT_PROVIDER to any binary that answers a prompt on
# stdout:  CONSULT_PROVIDER=mytool bin/productteam bench <client> run
#
# Detection rules (documented in README "Agent detection"):
#   1. $PATH decides first. A file on PATH carrying a catalog name but no
#      execute bit is reported missing, never silently replaced by a copy
#      found elsewhere — a broken install is not a working one.
#   2. Otherwise the extra install dirs below are scanned and the absolute
#      path is reported, so agents installed off a login shell's PATH show up.
#   3. Versions come from `<bin> --version`, time-bounded; anything unreadable
#      prints `unknown` rather than a guess.

# The single agent catalog (auto-pick order). Do not duplicate this list elsewhere.
AGENT_CATALOG=(agent claude codex opencode gemini cursor droid aider goose crush amp copilot plandex qwen)

# Extra directories scanned after $PATH. Override with CONSULT_AGENT_DIRS.
AGENT_SCAN_DIRS="$HOME/.local/bin:$HOME/bin:/usr/local/bin:/opt/homebrew/bin"
AGENT_SCAN_DIRS+=":$HOME/.bun/bin:$HOME/.cargo/bin:$HOME/go/bin:/snap/bin"
AGENT_SCAN_DIRS+=":$HOME/.npm-global/bin:$HOME/.deno/bin"
AGENT_SCAN_DIRS+=":$HOME/.opencode/bin:$HOME/.cursor/bin"
AGENT_SCAN_DIRS+=":$HOME/.claude/local"

# Seconds allowed for one `--version` probe.
AGENT_VERSION_TIMEOUT=1

agent_locate() { # $1=name → "found<TAB>/abs/path" | "shadowed<TAB>" | "missing<TAB>"
  local name="$1" dir p
  local -a dirs=()
  IFS=: read -ra dirs <<<"$PATH"
  for dir in "${dirs[@]}"; do
    [[ -n "$dir" ]] || continue
    p="$dir/$name"
    if [[ -e "$p" && ! -d "$p" ]]; then
      if [[ -x "$p" ]]; then printf 'found\t%s\n' "$p"; else printf 'shadowed\t\n'; fi
      return 0
    fi
  done
  IFS=: read -ra dirs <<<"${CONSULT_AGENT_DIRS:-$AGENT_SCAN_DIRS}"
  for dir in "${dirs[@]}"; do
    [[ -n "$dir" ]] || continue
    p="$dir/$name"
    if [[ -x "$p" && ! -d "$p" ]]; then printf 'found\t%s\n' "$p"; return 0; fi
  done
  printf 'missing\t\n'
}

agent_version() { # $1=path → "1.2.3" or "unknown"
  local v
  v=$(timeout "$AGENT_VERSION_TIMEOUT" "$1" --version </dev/null 2>/dev/null \
        | head -3 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?([.-][A-Za-z0-9]+)?' | head -1)
  printf '%s' "${v:-unknown}"
}

runtime_detect() {
  # Print TSV: name<TAB>found|missing<TAB>path<TAB>version<TAB>note
  local name status path
  for name in "${AGENT_CATALOG[@]}"; do
    IFS=$'\t' read -r status path < <(agent_locate "$name")
    case "$status" in
      found)    printf '%s\tfound\t%s\t%s\ton PATH or a known install dir\n' \
                  "$name" "$path" "$(agent_version "$path")" ;;
      shadowed) printf '%s\tmissing\t\tunknown\ta file of this name on PATH is not executable\n' "$name" ;;
      *)        printf '%s\tmissing\t\tunknown\tnot installed\n' "$name" ;;
    esac
  done
}

runtime_have() { # $1=bin or path → 0 when it is a usable executable
  if [[ "$1" == */* ]]; then
    [[ -x "$1" && ! -d "$1" ]]
    return
  fi
  local st rest
  IFS=$'\t' read -r st rest < <(agent_locate "$1")
  [[ "$st" == found ]]
}

runtime_path() { # $1=bin or path → absolute path when known, else the name
  if [[ "$1" == */* ]]; then printf '%s' "$1"; return 0; fi
  local st p
  IFS=$'\t' read -r st p < <(agent_locate "$1")
  if [[ "$st" == found ]]; then printf '%s' "$p"; else printf '%s' "$1"; fi
}

runtime_default() {
  # Resolve the provider binary: CONSULT_PROVIDER, else first present catalog entry.
  if [[ -n "${CONSULT_PROVIDER:-}" ]]; then
    printf '%s' "$CONSULT_PROVIDER"
    return 0
  fi
  local name
  for name in "${AGENT_CATALOG[@]}"; do
    if runtime_have "$name"; then
      printf '%s' "$name"
      return 0
    fi
  done
  return 1
}

provider_ask() { # $1=prompt  $2=cwd (optional)
  local prompt="$1" cwd="${2:-$PWD}" bin base
  bin="$(runtime_default)" || {
    printf 'productteam: no coding agent found. Run `productteam agents` for the catalog, install one, or set CONSULT_PROVIDER=<binary>.\n' >&2
    return 127
  }
  runtime_have "$bin" || {
    printf 'productteam: provider %s is not a usable executable. Run `productteam agents`, or set CONSULT_PROVIDER=<binary>.\n' "$bin" >&2
    return 127
  }
  base=$(basename "$bin")
  if [[ "$base" == agent || "$base" == cursor-agent ]]; then
    ( cd "$cwd" && "$bin" -p --trust --sandbox disabled --output-format text "$prompt" )
  else
    ( cd "$cwd" && "$bin" -p "$prompt" --output-format text )
  fi
}
