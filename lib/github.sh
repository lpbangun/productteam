#!/usr/bin/env bash
# github.sh — gated GitHub workflow helpers for the harness.
# Sourced by bin/productteam. No --admin. No force. Merge requires authorize-merge.
# Functions: gh_preflight, gh_pr_create, gh_pr_status, gh_pr_checks, gh_pr_merge, gh_pr_validate.

# Shared role chrome + status badges (empty defaults when uncolored).
# shellcheck source=lib/theme.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/theme.sh"

_gh() {
  command -v gh >/dev/null 2>&1 || { printf 'productteam: gh not found on PATH\n' >&2; return 127; }
  gh "$@"
}

_gh_repo_dir() { printf '%s' "${1:-$PWD}"; }

gh_preflight() {
  local dir; dir=$(_gh_repo_dir "${1:-}")
  (
    cd "$dir"
    local user
    user=$(gh api user -q .login 2>/dev/null || echo unknown)
    if [[ "$user" == unknown ]]; then
      printf '  %s\n' "$(status_badge error 'auth: not logged in')" >&2
    else
      printf '  %s\n' "$(status_badge success "auth: $user")" >&2
    fi
    printf 'gh_user=%s\n' "$user"
    gh auth status 2>&1 | grep -E 'Logged in|Token scopes' | sed 's/Token:.*/Token: [redacted]/' || true
    local slug
    slug=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || true)
    if [[ -n "$slug" ]]; then
      printf 'repo=%s\n' "$slug"
      gh api "repos/$slug" --jq 'permissions|{admin:.admin,push:.push,pull:.pull}' 2>/dev/null || true
    fi
  )
}

gh_pr_create() {
  local dir; dir=$(_gh_repo_dir "${1:-}")
  local title="${CONSULT_PR_TITLE:-productteam: improvement}"
  local body_file="${CONSULT_PR_BODY:-}"
  local branch="${CONSULT_PR_BRANCH:-}"
  (
    cd "$dir"
    if [[ -z "$branch" ]]; then
      branch=$(git rev-parse --abbrev-ref HEAD)
    fi
    git push -u origin "HEAD:refs/heads/$branch" >&2
    local args=(pr create --title "$title" --head "$branch")
    if [[ -n "$body_file" && -f "$body_file" ]]; then
      args+=(--body-file "$body_file")
    else
      args+=(--body "Opened by Product Consulting Harness (gated GitHub workflow).")
    fi
    _gh "${args[@]}"
  )
}

gh_pr_status() {
  local dir; dir=$(_gh_repo_dir "${1:-}")
  local pr="${2:-}"
  (
    cd "$dir"
    local json
    if [[ -n "$pr" ]]; then
      json=$(_gh pr view "$pr" --json number,url,state,mergeable,statusCheckRollup,reviews,title)
    else
      json=$(_gh pr view --json number,url,state,mergeable,statusCheckRollup,reviews,title)
    fi
    local state
    state=$(printf '%s' "$json" | jq -r '.state // empty' 2>/dev/null || true)
    case "$state" in
      OPEN)   printf '  %s\n' "$(status_badge running "PR $state")" >&2 ;;
      MERGED) printf '  %s\n' "$(status_badge success "PR $state")" >&2 ;;
      CLOSED) printf '  %s\n' "$(status_badge error "PR $state")" >&2 ;;
      *)      printf '  %s\n' "$(status_badge pending 'PR state')" >&2 ;;
    esac
    printf '%s\n' "$json"
  )
}

gh_pr_checks() {
  local dir; dir=$(_gh_repo_dir "${1:-}")
  local pr="${2:-}"
  (
    cd "$dir"
    local checks_out
    if [[ -n "$pr" ]]; then
      checks_out=$(_gh pr checks "$pr" 2>/dev/null || true)
      _gh pr view "$pr" --json statusCheckRollup,url
    else
      checks_out=$(_gh pr checks 2>/dev/null || true)
      _gh pr view --json statusCheckRollup,url
    fi
    if [[ -n "$checks_out" ]]; then
      if grep -qiE 'fail|error' <<<"$checks_out"; then
        printf '  %s\n' "$(status_badge error 'checks: failing')" >&2
      else
        printf '  %s\n' "$(status_badge success 'checks: passing')" >&2
      fi
    else
      printf '  %s\n' "$(status_badge pending 'checks: none reported')" >&2
    fi
  )
}

gh_pr_merge() {
  local dir; dir=$(_gh_repo_dir "${1:-}")
  local pr="${2:-}"
  local auth="${CONSULT_AUTHORIZE_MERGE:-}"
  if [[ -z "$auth" ]]; then
    local cand
    for cand in \
      "$dir/.productteam-authorize-merge" \
      "${CONSULT_ROOT:-}/state/harness-evolution/authorize-merge"
    do
      [[ -f "$cand" ]] && auth="$cand" && break
    done
  fi
  if [[ -z "$auth" || ! -f "$auth" ]]; then
    printf '  %s\n' "$(status_badge escalate 'merge refused — missing authorize-merge file.')" >&2
    printf 'Create state/harness-evolution/authorize-merge (or set CONSULT_AUTHORIZE_MERGE)\n' >&2
    printf 'with an explicit owner authorization note. Force/admin merge is forbidden.\n' >&2
    return 2
  fi
  if grep -qiE '(^|[^-])--admin|force-merge|force push|bypass checks' "$auth"; then
    printf '  %s\n' "$(status_badge escalate 'merge refused — authorize file must not request force/admin bypass.')" >&2
    return 2
  fi
  (
    cd "$dir"
    local args=(pr merge --merge)
    [[ -n "$pr" ]] && args+=("$pr")
    printf '  %s\n' "$(status_badge success "merging with authorization from $auth (non-force)")" >&2
    _gh "${args[@]}"
  )
}

gh_pr_validate() {
  local dir; dir=$(_gh_repo_dir "${1:-}")
  local ref="${2:-HEAD}"
  local out="${3:-/dev/stdout}"
  (
    cd "$dir"
    local sha
    sha=$(git rev-parse "$ref")
    {
      echo "validate_sha=$sha"
      echo "ref=$ref"
      echo "ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
      if [[ -f package.json ]]; then
        if jq -e '.scripts.test' package.json >/dev/null 2>&1; then
          npm test 2>&1 | tail -30
        elif jq -e '.scripts.build' package.json >/dev/null 2>&1; then
          npm run build 2>&1 | tail -20
        else
          echo 'no test/build script'
        fi
      else
        echo 'no package.json — skipped npm'
      fi
      git log -1 --oneline "$sha"
    } | tee "$out"
  )
}
