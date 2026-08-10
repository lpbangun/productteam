#!/usr/bin/env bash
# workspace.sh — isolated client worktrees and provenance evidence.
# Sourced by bin/consult. CONSULT_ROOT must name the harness root.

workspace_source_repo() {
  local engagement_dir="$1" repo
  repo=$(awk -F': ' '/^Repo:/{print $2; exit}' "$engagement_dir/engagement.md")
  [[ -n "$repo" && -d "$repo" ]] || {
    printf 'workspace-source-missing: %s\n' "${repo:-Repo: is unset}" >&2
    return 2
  }
  git -C "$repo" rev-parse --show-toplevel 2>/dev/null || {
    printf 'workspace-not-git: %s\n' "$repo" >&2
    return 2
  }
}

workspace_path() {
  local client="$1"
  printf '%s/%s' "${CONSULT_WORKSPACE_ROOT:-$CONSULT_ROOT/tmp/workspaces}" "$client"
}

workspace_metadata_path() {
  printf '%s/workspace.json' "$1"
}

workspace_is_dirty() {
  [[ -n "$(git -C "$1" status --porcelain --untracked-files=all 2>/dev/null)" ]]
}

workspace_snapshot() {
  local client="$1" engagement_dir="$2" allow_reason="${3:-}"
  local source path sha dirty=false exists=false
  source=$(workspace_source_repo "$engagement_dir") || return
  path=$(workspace_path "$client")
  if [[ -d "$path" ]] && git -C "$path" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    exists=true
    sha=$(git -C "$path" rev-parse HEAD)
    workspace_is_dirty "$path" && dirty=true
  else
    sha=''
  fi
  jq -n \
    --arg client "$client" \
    --arg source_repo "$source" \
    --arg path "$path" \
    --arg sha "$sha" \
    --argjson exists "$exists" \
    --argjson dirty "$dirty" \
    --arg allow_dirty_reason "$allow_reason" \
    '{client:$client,source_repo:$source_repo,path:$path,sha:$sha,exists:$exists,dirty:$dirty,allow_dirty_reason:(if $allow_dirty_reason == "" then null else $allow_dirty_reason end)}'
}

workspace_ensure() {
  local client="$1" engagement_dir="$2" allow_reason="${3:-}"
  local source path metadata tmp created
  source=$(workspace_source_repo "$engagement_dir") || return
  path=$(workspace_path "$client")
  metadata=$(workspace_metadata_path "$engagement_dir")

  if [[ -f "$metadata" ]]; then
    local recorded_source recorded_path
    recorded_source=$(jq -r '.source_repo // empty' "$metadata" 2>/dev/null)
    recorded_path=$(jq -r '.path // empty' "$metadata" 2>/dev/null)
    if [[ "$recorded_source" != "$source" || "$recorded_path" != "$path" ]]; then
      printf 'workspace-metadata-mismatch: %s (%s)\n' "$client" "$metadata" >&2
      return 2
    fi
  fi

  if [[ ! -d "$path" ]]; then
    mkdir -p "$(dirname "$path")"
    git -C "$source" worktree add --detach "$path" HEAD >&2 || {
      printf 'workspace-create-failed: %s (%s)\n' "$client" "$path" >&2
      return 2
    }
  elif ! git -C "$path" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    printf 'workspace-invalid: %s (%s)\n' "$client" "$path" >&2
    return 2
  fi

  if workspace_is_dirty "$path" && [[ -z "$allow_reason" ]]; then
    printf "workspace-dirty: %s (%s); retry with --allow-dirty 'reason'\n" "$client" "$path" >&2
    return 2
  fi

  created=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  [[ -f "$metadata" ]] && created=$(jq -r '.created_at // empty' "$metadata")
  [[ -n "$created" ]] || created=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  tmp="$metadata.tmp.$$"
  workspace_snapshot "$client" "$engagement_dir" "$allow_reason" |
    jq --arg created_at "$created" '. + {created_at:$created_at}' > "$tmp"
  mv "$tmp" "$metadata"
  workspace_snapshot "$client" "$engagement_dir" "$allow_reason"
}

workspace_remove() {
  local client="$1" engagement_dir="$2"
  local source path metadata
  source=$(workspace_source_repo "$engagement_dir") || return
  path=$(workspace_path "$client")
  metadata=$(workspace_metadata_path "$engagement_dir")
  if [[ ! -d "$path" ]]; then
    rm -f "$metadata"
    return 0
  fi
  if workspace_is_dirty "$path"; then
    printf 'workspace-dirty: %s (%s); remove refused\n' "$client" "$path" >&2
    return 2
  fi
  git -C "$source" worktree remove "$path" >&2 || {
    printf 'workspace-remove-failed: %s (%s)\n' "$client" "$path" >&2
    return 2
  }
  rm -f "$metadata"
}

workspace_write_evidence() {
  local snapshot="$1" output="$2" operation="$3"
  mkdir -p "$(dirname "$output")"
  jq --arg operation "$operation" --arg recorded_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    '. + {operation:$operation,recorded_at:$recorded_at}' <<<"$snapshot" > "$output"
}
