#!/usr/bin/env bash
# experience-pool.sh — cross-engagement sealed what-worked / what-failed excerpts.
# Plain files only: INDEX.jsonl + entries/<id>.md. No vector DB, no agent-code evolution.
# Sourced by bin/productteam. Requires CONSULT_ROOT and jq.

pool_root() {
  printf '%s' "${CONSULT_EXPERIENCE_POOL_DIR:-${CONSULT_ROOT:?CONSULT_ROOT unset}/state/experience-pool}"
}

pool_index_path() { printf '%s/INDEX.jsonl' "$(pool_root)"; }
pool_entries_dir() { printf '%s/entries' "$(pool_root)"; }
pool_entry_path() { printf '%s/%s.md' "$(pool_entries_dir)" "$1"; }

pool_resolve_path() { # stored path → absolute readable path
  local p="$1" root
  [[ -n "$p" ]] || { printf ''; return 0; }
  [[ "$p" == /* ]] && { printf '%s' "$p"; return 0; }
  root=$(pool_root)
  if [[ "$p" == entries/* ]]; then
    printf '%s/%s' "$root" "$p"
  else
    printf '%s/%s' "$(pool_entries_dir)" "$(basename "$p")"
  fi
}

pool_atomic_write() {
  local file="$1" tmp
  mkdir -p "$(dirname "$file")"
  tmp="$file.tmp.$$.$RANDOM"
  cat > "$tmp"
  mv "$tmp" "$file"
}

pool_valid_domain() {
  case "$1" in ideation|implement|scoring|client|org) return 0 ;; *) return 1 ;; esac
}

pool_valid_kind() {
  case "$1" in worked|failed) return 0 ;; *) return 1 ;; esac
}

pool_slugify() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]\+/-/g; s/^-//; s/-$//; s/-\+/-/g' | cut -c1-32
}

pool_next_id() { # title slug → YYYYMMDD-slug-n
  local slug="$1" date prefix n id index
  date=$(date -u +%Y%m%d)
  slug=$(pool_slugify "$slug")
  [[ -n "$slug" ]] || slug='entry'
  prefix="$date-$slug"
  n=0
  index=$(pool_index_path)
  if [[ -f "$index" ]]; then
    while IFS= read -r line; do
      [[ -n "$line" ]] || continue
      id=$(jq -r '.id // empty' <<<"$line" 2>/dev/null || true)
      [[ "$id" == "$prefix"-* ]] || continue
      local suffix=${id##*-}
      [[ "$suffix" =~ ^[0-9]+$ ]] && (( suffix > n )) && n=$suffix
    done < "$index"
  fi
  while [[ -f "$(pool_entry_path "$prefix-$((n + 1))")" ]]; do
    (( n++ ))
  done
  printf '%s-%s' "$prefix" "$((n + 1))"
}

pool_index_count() {
  local index f
  index=$(pool_index_path)
  [[ -f "$index" ]] || { printf '0'; return 0; }
  f=$(grep -c . "$index" 2>/dev/null || printf '0')
  printf '%s' "$f"
}

pool_missing() {
  local root index
  root=$(pool_root)
  index=$(pool_index_path)
  [[ ! -d "$root" ]] || [[ ! -f "$index" ]] || [[ "$(pool_index_count)" -eq 0 ]]
}

pool_cite_line() { # entry md path → first non-empty cite line or title
  local path="$1" line title=''
  [[ -f "$path" ]] || { printf ''; return 0; }
  title=$(sed -n '1s/^# //p' "$path")
  while IFS= read -r line; do
    [[ -z "${line//[[:space:]]/}" ]] && continue
    [[ "$line" == "## Cite" ]] && { in_cite=1; continue; }
    [[ -n "${in_cite:-}" && "$line" =~ ^##\  ]] && break
    if [[ -n "${in_cite:-}" ]]; then
      line="${line#- }"
      printf '%s' "$line"
      return 0
    fi
  done < "$path"
  printf '%s' "$title"
}

pool_add() { # --kind --domain --title [--client] [--iter] [--tags] [--body|--body-file]
  local kind='' domain='' title='' client='' iter='' tags='' body='' body_file=''
  while (( $# )); do
    case "$1" in
      --kind) kind="$2"; shift 2 ;;
      --domain) domain="$2"; shift 2 ;;
      --title) title="$2"; shift 2 ;;
      --client) client="$2"; shift 2 ;;
      --iter) iter="$2"; shift 2 ;;
      --tags) tags="$2"; shift 2 ;;
      --body) body="$2"; shift 2 ;;
      --body-file) body_file="$2"; shift 2 ;;
      *) printf 'unknown pool add option: %s\n' "$1" >&2; return 1 ;;
    esac
  done
  [[ -n "$kind" && -n "$domain" && -n "$title" ]] || {
    printf 'pool add requires --kind worked|failed --domain <d> --title <t>\n' >&2
    return 1
  }
  pool_valid_kind "$kind" || { printf 'kind must be worked or failed\n' >&2; return 1; }
  pool_valid_domain "$domain" || { printf 'domain must be ideation|implement|scoring|client|org\n' >&2; return 1; }
  [[ -n "${title//[[:space:]]/}" ]] || { printf 'title must be non-empty\n' >&2; return 1; }
  if [[ -n "$body_file" ]]; then
    [[ -f "$body_file" ]] || { printf 'body file not found: %s\n' "$body_file" >&2; return 1; }
    body=$(cat "$body_file")
  fi
  [[ -n "${body//[[:space:]]/}" ]] || { printf 'body required via --body or --body-file\n' >&2; return 1; }

  local id ts path index tags_json worked failed root readme
  root=$(pool_root)
  mkdir -p "$(pool_entries_dir)"
  readme="$root/README.md"
  [[ -f "$readme" ]] || pool_init_readme >/dev/null
  id=$(pool_next_id "$title")
  ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  path="entries/${id}.md"
  [[ ! -e "$(pool_resolve_path "$path")" ]] || { printf 'entry already exists: %s\n' "$path" >&2; return 1; }

  if [[ "$kind" == worked ]]; then
    worked="$body"
    failed='_(none recorded)_'
  else
    failed="$body"
    worked='_(none recorded)_'
  fi

  cat > "$(pool_resolve_path "$path")" <<EOF
# $title

## What worked

$worked

## What failed

$failed

## Context

- kind: $kind
- domain: $domain
- client: ${client:-—}
- iter: ${iter:-—}
- sealed: $ts

## Cite

- pool entry $id · add via productteam pool add
EOF

  if [[ -n "$tags" ]]; then
    tags_json=$(printf '%s' "$tags" | tr ',' '\n' | sed '/^[[:space:]]*$/d' | jq -R . | jq -s -c .)
  else
    tags_json='[]'
  fi

  index=$(pool_index_path)
  local row tmp
  row=$(jq -nc --arg id "$id" --arg ts "$ts" --arg kind "$kind" --arg domain "$domain" \
    --arg client "$client" --argjson iter "${iter:-null}" --arg title "$title" --arg path "$path" \
    --argjson tags "$tags_json" \
    '{id:$id,ts:$ts,kind:$kind,domain:$domain,client:(if $client=="" then null else $client end),iter:$iter,title:$title,path:$path,tags:$tags}')
  if [[ -f "$index" ]]; then
    tmp="$index.tmp.$$.$RANDOM"
    cat "$index" > "$tmp"
    printf '%s\n' "$row" >> "$tmp"
    mv "$tmp" "$index"
  else
    mkdir -p "$root"
    printf '%s\n' "$row" | pool_atomic_write "$index"
  fi
  printf '%s' "$id"
}

pool_init_readme() {
  local root readme
  root=$(pool_root)
  readme="$root/README.md"
  mkdir -p "$(pool_entries_dir)"
  cat > "$readme" <<'EOF'
# Experience pool

Cross-engagement sealed excerpts: what worked / what failed. Not source patches.

- `INDEX.jsonl` — one line per entry `{id,ts,kind,domain,client,iter,title,path,tags[]}`
- `entries/<id>.md` — sealed excerpt with ## What worked | ## What failed | ## Context | ## Cite

Retrieve via `productteam pool list|show|search|retrieve`. Inspect and role invoke load top entries into context.

Write explicitly: `productteam pool add …` or `productteam pool add-from-iter …`
EOF
  touch "$(pool_index_path)" 2>/dev/null || true
  [[ -s "$(pool_index_path)" ]] || : > "$(pool_index_path)"
  printf '%s' "$readme"
}

pool_list() { # [--domain] [--kind worked|failed|both] [--client] [--json]
  local domain='' kind='both' client='' json=0
  while (( $# )); do
    case "$1" in
      --domain) domain="$2"; shift 2 ;;
      --kind) kind="$2"; shift 2 ;;
      --client) client="$2"; shift 2 ;;
      --json) json=1; shift ;;
      *) printf 'unknown pool list option: %s\n' "$1" >&2; return 1 ;;
    esac
  done
  local index
  index=$(pool_index_path)
  [[ -f "$index" ]] || { (( json )) && printf '[]' || return 0; return 0; }
  local rows='[]' line
  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    rows=$(jq -c --argjson r "$rows" --argjson row "$line" '. + [$row]' <<<"$rows")
  done < "$index"
  rows=$(jq -c --arg domain "$domain" --arg kind "$kind" --arg client "$client" '
    map(
      select(
        ($domain == "" or .domain == $domain) and
        ($client == "" or .client == $client) and
        ($kind == "both" or .kind == $kind)
      )
    ) | sort_by(.ts) | reverse
  ' <<<"$rows")
  if (( json )); then
    printf '%s' "$rows"
  else
    jq -r '.[] | "\(.id)\t\(.kind)\t\(.domain)\t\(.title)"' <<<"$rows"
  fi
}

pool_show() { # id
  local id="$1" path stored
  [[ -n "$id" ]] || { printf 'usage: pool show <id>\n' >&2; return 1; }
  stored=$(pool_index_row "$id" | jq -r '.path // empty')
  if [[ -n "$stored" && "$stored" != null ]]; then
    path=$(pool_resolve_path "$stored")
  else
    path=$(pool_entry_path "$id")
  fi
  [[ -f "$path" ]] || { printf 'entry not found: %s\n' "$id" >&2; return 1; }
  cat "$path"
}

pool_index_row() { # id → JSON row or null
  local id="$1" index line
  index=$(pool_index_path)
  [[ -f "$index" ]] || { printf 'null'; return 0; }
  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    jq -e --arg id "$id" '.id == $id' <<<"$line" >/dev/null 2>&1 && { printf '%s' "$line"; return 0; }
  done < "$index"
  printf 'null'
}

pool_search() { # query [--json]
  local query='' json=0
  if [[ $# -ge 1 && "$1" != --* ]]; then
    query="$1"; shift
  fi
  while (( $# )); do
    case "$1" in
      --json) json=1; shift ;;
      *) printf 'unknown pool search option: %s\n' "$1" >&2; return 1 ;;
    esac
  done
  [[ -n "${query//[[:space:]]/}" ]] || { printf 'search query required\n' >&2; return 1; }
  local index root entries_dir
  index=$(pool_index_path)
  root=$(pool_root)
  entries_dir=$(pool_entries_dir)
  [[ -f "$index" ]] || { (( json )) && printf '[]'; return 0; }

  local results='[]' line id path title domain kind ts matches
  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    id=$(jq -r '.id' <<<"$line")
    path=$(pool_resolve_path "$(jq -r '.path' <<<"$line")")
    title=$(jq -r '.title' <<<"$line")
    domain=$(jq -r '.domain' <<<"$line")
    kind=$(jq -r '.kind' <<<"$line")
    ts=$(jq -r '.ts' <<<"$line")
    matches=0
    grep -qi "$query" <<<"$title" && (( matches++ )) || true
    grep -qi "$query" <<<"$line" && (( matches++ )) || true
    [[ -f "$path" ]] && grep -qi "$query" "$path" && (( matches++ )) || true
    (( matches > 0 )) || continue
    results=$(jq -nc --argjson arr "$results" --arg id "$id" --arg title "$title" \
      --arg domain "$domain" --arg kind "$kind" --arg ts "$ts" --arg path "$path" \
      --argjson matches "$matches" \
      '$arr + [{id:$id,title:$title,domain:$domain,kind:$kind,ts:$ts,path:$path,matches:$matches}]')
  done < "$index"
  results=$(jq -c 'sort_by(.matches, .ts) | reverse' <<<"$results")
  if (( json )); then
    printf '%s' "$results"
  else
    jq -r '.[] | "\(.matches)\t\(.id)\t\(.title)"' <<<"$results"
  fi
}

pool_retrieve() { # domain [limit]
  local domain="${1:-}" limit="${2:-3}"
  local index
  index=$(pool_index_path)
  [[ -f "$index" ]] || { printf '[]'; return 0; }
  local rows='[]' line
  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    rows=$(jq -c --argjson r "$rows" --argjson row "$line" '. + [$row]' <<<"$rows")
  done < "$index"
  if [[ -n "$domain" ]]; then
    rows=$(jq -c --arg domain "$domain" '[.[] | select(.domain == $domain)] | sort_by(.ts) | reverse' <<<"$rows")
  else
    rows=$(jq -c 'sort_by(.ts) | reverse' <<<"$rows")
  fi
  jq -c --argjson limit "$limit" '.[:$limit]' <<<"$rows"
}

pool_retrieve_for_inspect() { # → JSON array up to 3 with cite_line
  local limit=3 domains=(client implement scoring ideation org) collected='[]' domain chunk id path cite
  for domain in "${domains[@]}"; do
    chunk=$(pool_retrieve "$domain" "$limit")
    while IFS= read -r line; do
      [[ -n "$line" ]] || continue
      id=$(jq -r '.id' <<<"$line")
      jq -e --arg id "$id" '[.[] | .id] | index($id)' <<<"$collected" >/dev/null 2>&1 && continue
      path=$(pool_resolve_path "$(jq -r '.path' <<<"$line")")
      cite=$(pool_cite_line "$path")
      collected=$(jq -c --argjson arr "$collected" --argjson row "$line" --arg cite "$cite" \
        '$arr + [($row + {cite_line:$cite})]' <<<"$collected")
      (( $(jq 'length' <<<"$collected") >= limit )) && break 2
    done < <(jq -c '.[]' <<<"$chunk")
  done
  jq -c --argjson limit "$limit" '.[:$limit]' <<<"$collected"
}

pool_derive_pack() { # → inspect experience_pool JSON object
  local root pointer missing=true index_count=0 retrieved='[]'
  root=$(pool_root)
  pointer="$root"
  if pool_missing; then
    jq -n --argjson missing true --arg pointer "$pointer" --argjson retrieved "$retrieved" --argjson index_count 0 \
      '{missing:$missing,pointer:$pointer,retrieved:$retrieved,index_count:$index_count}'
    return 0
  fi
  missing=false
  index_count=$(pool_index_count)
  retrieved=$(pool_retrieve_for_inspect)
  jq -n --argjson missing "$missing" --arg pointer "$pointer" --argjson retrieved "$retrieved" \
    --argjson index_count "$index_count" \
    '{missing:$missing,pointer:$pointer,retrieved:$retrieved,index_count:$index_count}'
}

experience_pool_request_fields() { # → jq object {experience_pool_ids:[]}
  local retrieved ids='[]' line
  if pool_missing; then
    jq -n '{experience_pool_ids:[]}'
    return 0
  fi
  retrieved=$(pool_retrieve_for_inspect)
  ids=$(jq -c '[.[].id]' <<<"$retrieved")
  jq -n --argjson ids "$ids" '{experience_pool_ids:$ids}'
}

experience_pool_prompt_block() { # → truncated block for role invoke
  local retrieved='' out='Experience pool (cite if relevant):' line id title path cite
  if pool_missing; then
    printf '%s empty (%s)\n' "$out" "$(pool_root)"
    return 0
  fi
  retrieved=$(pool_retrieve_for_inspect)
  if [[ "$(jq 'length' <<<"$retrieved")" -eq 0 ]]; then
    printf '%s empty\n' "$out"
    return 0
  fi
  printf '%s\n' "$out"
  jq -c '.[]' <<<"$retrieved" | while IFS= read -r line; do
    id=$(jq -r '.id' <<<"$line")
    title=$(jq -r '.title' <<<"$line")
    path=$(jq -r '.path' <<<"$line")
    cite=$(jq -r '.cite_line // .title' <<<"$line")
    printf -- '- [%s] %s (%s) — %s\n' "$id" "$(printf '%.60s' "$title")" "$path" "$(printf '%.80s' "$cite")"
  done
  printf '\n'
}

pool_lessons_path() { # client_dir iter → lessons file or empty
  local d="$1" iter="$2" lf
  lf="$d/runs/iter-$iter/lessons.md"
  [[ -f "$lf" ]] && { printf '%s' "$lf"; return 0; }
  [[ -f "$d/lessons.md" ]] && { printf '%s' "$d/lessons.md"; return 0; }
  lf="$d/runs/iter-$iter/report.md"
  [[ -f "$lf" ]] && { printf '%s' "$lf"; return 0; }
  printf ''
}

pool_add_from_iter() { # client_dir iter --kind --domain --title [--tags]
  local d="$1" iter="$2"
  shift 2
  local kind='' domain='' title='' tags=''
  while (( $# )); do
    case "$1" in
      --kind) kind="$2"; shift 2 ;;
      --domain) domain="$2"; shift 2 ;;
      --title) title="$2"; shift 2 ;;
      --tags) tags="$2"; shift 2 ;;
      *) printf 'unknown add-from-iter option: %s\n' "$1" >&2; return 1 ;;
    esac
  done
  [[ -n "$kind" && -n "$domain" && -n "$title" ]] || {
    printf 'add-from-iter requires --kind --domain --title\n' >&2
    return 1
  }
  local lessons client excerpt cite
  lessons=$(pool_lessons_path "$d" "$iter")
  [[ -n "$lessons" && -f "$lessons" ]] || {
    printf 'no lessons.md or report.md for iter %s under %s\n' "$iter" "$d" >&2
    return 1
  }
  client=$(basename "$d")
  excerpt=$(head -c 800 "$lessons" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
  [[ -n "${excerpt//[[:space:]]/}" ]] || { printf 'lessons excerpt empty: %s\n' "$lessons" >&2; return 1; }
  cite="source: $lessons (iter $iter)"
  local body
  body="$excerpt

$cite"
  pool_add --kind "$kind" --domain "$domain" --title "$title" --client "$client" --iter "$iter" \
    ${tags:+--tags "$tags"} --body "$body"
}

pool_seal_hint() { # client iter → hint line
  local client="$1" iter="$2"
  printf 'To seal experience: productteam pool add-from-iter %s %s --kind worked|failed --domain ideation|implement|scoring|client --title "…"\n' "$client" "$iter"
}
