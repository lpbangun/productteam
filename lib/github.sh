#!/usr/bin/env bash
# github.sh — gated GitHub workflow helpers for the harness.
# Sourced by bin/productteam. No --admin. No force. Merge requires authorize-merge.
# Functions: gh_preflight, gh_pr_create, gh_pr_status, gh_pr_checks, gh_pr_merge, gh_pr_validate.

_gh() {
  command -v gh >/dev/null 2>&1 || { printf 'productteam: gh not found on PATH\n' >&2; return 127; }
  gh "$@"
}

_gh_repo_dir() { printf '%s' "${1:-$PWD}"; }

gh_preflight() {
  local dir; dir=$(_gh_repo_dir "${1:-}")
  (
    cd "$dir"
    printf 'gh_user=%s\n' "$(gh api user -q .login 2>/dev/null || echo unknown)"
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
    if [[ -n "$pr" ]]; then
      _gh pr view "$pr" --json number,url,state,mergeable,statusCheckRollup,reviews,title
    else
      _gh pr view --json number,url,state,mergeable,statusCheckRollup,reviews,title
    fi
  )
}

gh_pr_checks() {
  local dir; dir=$(_gh_repo_dir "${1:-}")
  local pr="${2:-}"
  (
    cd "$dir"
    if [[ -n "$pr" ]]; then
      _gh pr checks "$pr" 2>/dev/null || true
      _gh pr view "$pr" --json statusCheckRollup,url
    else
      _gh pr checks 2>/dev/null || true
      _gh pr view --json statusCheckRollup,url
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
    printf 'productteam: merge refused — missing authorize-merge file.\n' >&2
    printf 'Create state/harness-evolution/authorize-merge (or set CONSULT_AUTHORIZE_MERGE)\n' >&2
    printf 'with an explicit owner authorization note. Force/admin merge is forbidden.\n' >&2
    return 2
  fi
  if grep -qiE '(^|[^-])--admin|force-merge|force push|bypass checks' "$auth"; then
    printf 'productteam: merge refused — authorize file must not request force/admin bypass.\n' >&2
    return 2
  fi
  (
    cd "$dir"
    local args=(pr merge --merge)
    [[ -n "$pr" ]] && args+=("$pr")
    printf 'productteam: merging with authorization from %s (non-force)\n' "$auth" >&2
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
