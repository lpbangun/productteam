# Provider seam — the only place the system knows which model runs.
# Default: authenticated Cursor `agent` CLI (headless). No API keys, no mocks.
# Swap by setting CONSULT_PROVIDER to any binary that answers a prompt
# on stdout:  CONSULT_PROVIDER=mytool bin/consult bench <client> run
#
# Cursor agent flags used by default wrapper:
#   -p/--print  headless · --trust workspace · --sandbox disabled for real checks
provider_ask() { # $1=prompt  $2=cwd (optional)
  local prompt="$1" cwd="${2:-$PWD}"
  local bin="${CONSULT_PROVIDER:-agent}"
  if [[ "$bin" == "agent" || "$bin" == "cursor-agent" ]]; then
    ( cd "$cwd" && agent -p --trust --sandbox disabled --output-format text "$prompt" )
  else
    ( cd "$cwd" && "$bin" -p "$prompt" --output-format text )
  fi
}
