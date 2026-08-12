#!/usr/bin/env bash
# Real git-worktree probe for the workspace isolation seam.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
C="$ROOT/bin/consult"
TMP=$(mktemp -d)
CLIENT="workspace-smoke-$$"
ENGAGEMENT="$ROOT/state/engagements/$CLIENT"
SOURCE="$TMP/source"
WORKROOT="$TMP/workspaces"
cleanup() {
  if [[ -d "$SOURCE" ]]; then
    git -C "$SOURCE" worktree remove --force "$WORKROOT/$CLIENT" >/dev/null 2>&1 || true
  fi
  rm -rf "$ENGAGEMENT" "$TMP"
}
trap cleanup EXIT

mkdir -p "$SOURCE" "$ENGAGEMENT/runs"
git -C "$SOURCE" init -q
git -C "$SOURCE" config user.email workspace-smoke@example.invalid
git -C "$SOURCE" config user.name 'Workspace Smoke'
printf 'real worktree probe\n' > "$SOURCE/README.md"
git -C "$SOURCE" add README.md
git -C "$SOURCE" commit -qm initial
cat > "$ENGAGEMENT/engagement.md" <<EOF
# Workspace smoke
Repo: $SOURCE
Mode: **Directive**
EOF

run_consult() {
  CONSULT_WORKSPACE_ROOT="$WORKROOT" "$C" "$@"
}

snapshot=$(run_consult workspace "$CLIENT" ensure)
path=$(jq -r '.path' <<<"$snapshot")
source_path=$(jq -r '.source_repo' <<<"$snapshot")
[[ "$path" != "$source_path" && -d "$path" ]]
jq -e '.exists == true and .dirty == false and (.sha | length == 40)' <<<"$snapshot" >/dev/null
printf 'PASS workspace-default-isolated\n'

status=$(run_consult workspace "$CLIENT" status)
jq -e --arg path "$path" '.exists == true and .path == $path and .dirty == false' <<<"$status" >/dev/null
[[ -f "$ENGAGEMENT/workspace.json" ]]
printf 'PASS workspace-lifecycle\n'

printf 'dirty\n' > "$path/scratch.txt"
if run_consult workspace "$CLIENT" ensure >"$TMP/dirty.out" 2>&1; then
  printf 'dirty workspace unexpectedly passed\n' >&2
  exit 1
fi
grep -q "workspace-dirty: $CLIENT" "$TMP/dirty.out"
printf 'PASS workspace-dirty-refusal\n'

allowed=$(run_consult workspace "$CLIENT" ensure --allow-dirty 'smoke audit')
jq -e '.dirty == true and .allow_dirty_reason == "smoke audit"' <<<"$allowed" >/dev/null
CONSULT_ROOT="$ROOT" source "$ROOT/lib/workspace.sh"
workspace_write_evidence "$allowed" "$ENGAGEMENT/runs/check-probe/workspace.json" checks
jq -e '.operation == "checks" and .dirty == true and .allow_dirty_reason == "smoke audit" and (.path | length > 0) and (.sha | length == 40)' \
  "$ENGAGEMENT/runs/check-probe/workspace.json" >/dev/null
printf 'PASS workspace-dirty-escape-evidence\n'

if run_consult workspace "$CLIENT" remove >"$TMP/remove.out" 2>&1; then
  printf 'dirty workspace removal unexpectedly passed\n' >&2
  exit 1
fi
grep -q "workspace-dirty: $CLIENT" "$TMP/remove.out"
rm "$path/scratch.txt"
run_consult workspace "$CLIENT" remove
[[ ! -e "$path" && ! -e "$ENGAGEMENT/workspace.json" ]]
printf 'PASS workspace-safe-remove\n'
