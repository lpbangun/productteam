# Provider seam — the only place the system knows which model runs.
# Default: the authenticated claude CLI (headless). No API keys, no mocks.
# Swap by setting CONSULT_PROVIDER to any binary that answers a prompt
# on stdout:  CONSULT_PROVIDER=mytool bin/consult bench <client> run
provider_ask() { # $1=prompt  $2=cwd (optional)
  local prompt="$1" cwd="${2:-$PWD}"
  ( cd "$cwd" && "${CONSULT_PROVIDER:-claude}" -p "$prompt" --output-format text )
}
