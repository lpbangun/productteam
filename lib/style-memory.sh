#!/usr/bin/env bash
# style-memory.sh — org-level style + per-engagement project memory (plain files).
# Sourced by bin/productteam. Requires CONSULT_ROOT and jq.

style_dir() {
  printf '%s' "${CONSULT_STYLE_DIR:-${CONSULT_ROOT:?CONSULT_ROOT unset}/state/style}"
}

style_md_path() { printf '%s/style.md' "$(style_dir)"; }
style_json_path() { printf '%s/style.json' "$(style_dir)"; }

style_atomic_write() {
  local file="$1" tmp
  mkdir -p "$(dirname "$file")"
  tmp="$file.tmp.$$.$RANDOM"
  cat > "$tmp"
  mv "$tmp" "$file"
}

style_valid_section() {
  case "${1,,}" in taste|risk|stack|never) return 0 ;; *) return 1 ;; esac
}

style_section_heading() {
  case "${1,,}" in
    taste)  printf '## Taste' ;;
    risk)   printf '## Risk' ;;
    stack)  printf '## Stack' ;;
    never)  printf '## Never' ;;
  esac
}

# Parse bullet lines under a ## Section heading from style.md.
style_parse_section_lines() { # section → JSON array stdout
  local section="$1" md heading line in_section=''
  md=$(style_md_path)
  heading=$(style_section_heading "$section")
  [[ -f "$md" ]] || { printf '[]'; return 0; }
  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" == "$heading" ]]; then
      in_section=1
      continue
    fi
    if [[ -n "$in_section" && "$line" =~ ^##\  ]]; then
      break
    fi
    if [[ -n "$in_section" && "$line" =~ ^-[[:space:]]+ ]]; then
      printf '%s\n' "${line#- }"
    fi
  done < "$md" | jq -R -s 'split("\n") | map(select(length > 0))'
}

style_sync_json_from_md() {
  local md json taste risk stack never ts source updated
  md=$(style_md_path)
  json=$(style_json_path)
  [[ -f "$md" ]] || return 1
  taste=$(style_parse_section_lines taste)
  risk=$(style_parse_section_lines risk)
  stack=$(style_parse_section_lines stack)
  never=$(style_parse_section_lines never)
  updated='null'
  source='owner'
  if [[ -f "$json" ]]; then
    updated=$(jq -r '.updated // null' "$json" 2>/dev/null || printf 'null')
    source=$(jq -r '.source // "owner"' "$json" 2>/dev/null || printf 'owner')
  fi
  ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  jq -n --argjson taste "$taste" --argjson risk "$risk" --argjson stack "$stack" \
    --argjson never "$never" --arg updated "$ts" --arg source "$source" \
    '{taste:$taste,risk:$risk,stack:$stack,never:$never,updated:$updated,source:$source}' \
    | style_atomic_write "$json"
}

style_missing() {
  [[ ! -f "$(style_md_path)" ]]
}

style_read_arrays() { # stdout: taste risk stack never as jq arrays (from json if present else md)
  local md json
  md=$(style_md_path)
  json=$(style_json_path)
  if [[ -f "$json" ]]; then
    jq -c '{taste:(.taste // []),risk:(.risk // []),stack:(.stack // []),never:(.never // [])}' "$json" 2>/dev/null && return 0
  fi
  if [[ -f "$md" ]]; then
    jq -n \
      --argjson taste "$(style_parse_section_lines taste)" \
      --argjson risk "$(style_parse_section_lines risk)" \
      --argjson stack "$(style_parse_section_lines stack)" \
      --argjson never "$(style_parse_section_lines never)" \
      '{taste:$taste,risk:$risk,stack:$stack,never:$never}'
    return 0
  fi
  printf '{"taste":[],"risk":[],"stack":[],"never":[]}'
}

style_derive_pack() { # → inspect "style" JSON object
  local md pointer arrays missing=true
  md=$(style_md_path)
  pointer="$md"
  if [[ -f "$md" ]]; then
    missing=false
    arrays=$(style_read_arrays)
    jq -n --arg pointer "$pointer" --argjson missing "$missing" --argjson a "$arrays" \
      '{missing:$missing,pointer:$pointer,taste:$a.taste,risk:$a.risk,stack:$a.stack,never:$a.never}'
  else
    jq -n --argjson missing "$missing" \
      '{missing:$missing,pointer:null,taste:[],risk:[],stack:[],never:[]}'
  fi
}

style_init() { # → path to style.md or fail if present
  local dir md json readme
  dir=$(style_dir)
  md=$(style_md_path)
  json=$(style_json_path)
  readme="$dir/README.md"
  [[ ! -f "$md" ]] || { printf 'style already initialized: %s\n' "$md" >&2; return 1; }
  mkdir -p "$dir"
  cat > "$md" <<'EOF'
# Org style — owner-edited

Append-mostly taste, risk, stack, and never rules. Only owner edits or
Critic-accepted lessons evolve this file.

## Taste

- prefer smallest diffs; evidence over prose

## Risk

- escalate auth/architecture; no force-push

## Stack

- bash CLI + plain state files; no DB/daemon

## Never

- auto-Implement past judgment gates; invent permanent workers
EOF
  style_sync_json_from_md
  if [[ ! -f "$readme" ]]; then
    cat > "$readme" <<'EOF'
# Org style

Owner-edited `style.md` (+ machine mirror `style.json`) under this directory.

- `productteam style show` — read org style
- `productteam style init` — create starter files if missing
- `productteam style append <taste|risk|stack|never> <text…>` — append-only
- `productteam style accept-lesson <path>` — append Critic-accepted lesson with provenance

Rewrite/delete requires explicit owner confirmation (`style rewrite --i-am-owner`).
Inspect and role invoke load style into context; they never mutate it.
EOF
  fi
  printf '%s' "$md"
}

style_append() { # section text…
  local section="$1"; shift
  local text="$*" md tmp heading line in_section='' found=''
  style_valid_section "$section" || { printf 'section must be taste|risk|stack|never\n' >&2; return 1; }
  [[ -n "${text//[[:space:]]/}" ]] || { printf 'append text must be non-empty\n' >&2; return 1; }
  md=$(style_md_path)
  [[ -f "$md" ]] || { printf 'style missing — run: productteam style init\n' >&2; return 1; }
  heading=$(style_section_heading "$section")
  tmp="$md.tmp.$$.$RANDOM"
  while IFS= read -r line || [[ -n "$line" ]]; do
    printf '%s\n' "$line" >> "$tmp"
    if [[ "$line" == "$heading" ]]; then
      found=1
      printf -- '- %s\n' "$text" >> "$tmp"
    fi
  done < "$md"
  [[ -n "$found" ]] || { rm -f "$tmp"; printf 'section %s not found in %s\n' "$section" "$md" >&2; return 1; }
  mv "$tmp" "$md"
  style_sync_json_from_md
}

style_accept_lesson() { # path-to-lesson-excerpt
  local path="$1" excerpt section='never' line
  [[ -f "$path" ]] || { printf 'lesson file not found: %s\n' "$path" >&2; return 1; }
  excerpt=$(head -c 500 "$path" | tr '\n' ' ' | sed 's/[[:space:]]\+/ /g; s/^ //; s/ $//')
  [[ -n "$excerpt" ]] || { printf 'lesson excerpt empty: %s\n' "$path" >&2; return 1; }
  md=$(style_md_path)
  [[ -f "$md" ]] || style_init >/dev/null
  line="$excerpt (source: critic-lesson $path)"
  style_append never "$line"
  jq -c --arg source 'critic-lesson' '.source = $source' "$(style_json_path)" | style_atomic_write "$(style_json_path)"
}

style_rewrite_refuse() { # unless owner flag → refuse
  local owner_flag="$1"
  [[ "$owner_flag" == '--i-am-owner' ]] || {
    printf 'style rewrite refused — append-only by default; pass --i-am-owner to confirm dangerous rewrite\n' >&2
    return 1
  }
  printf 'style rewrite still refused — use manual owner edit of %s\n' "$(style_md_path)" >&2
  return 1
}

style_show() { # [--json]
  local json=0 a
  for a in "$@"; do
    case "$a" in
      --json) json=1 ;;
      *) printf 'unknown option %s\n' "$a" >&2; return 1 ;;
    esac
  done
  if style_missing; then
    if (( json )); then
      jq -n '{missing:true,pointer:null,taste:[],risk:[],stack:[],never:[]}'
    else
      printf 'Style: missing (owner has not set %s)\n' "$(style_md_path)"
    fi
    return 0
  fi
  if (( json )); then
    style_derive_pack
  else
    cat "$(style_md_path)"
  fi
}

project_memory_dir() { printf '%s/memory' "$1"; }
project_memory_md_path() { printf '%s/project.md' "$(project_memory_dir "$1")"; }
project_memory_json_path() { printf '%s/project.json' "$(project_memory_dir "$1")"; }

project_memory_derive_pack() { # client_dir → inspect "project_memory" JSON
  local d="$1" md pointer missing=true excerpt=''
  md=$(project_memory_md_path "$d")
  if [[ -f "$md" ]]; then
    missing=false
    pointer="$md"
    if [[ $(wc -c < "$md") -le 2048 ]]; then
      excerpt=$(cat "$md")
    fi
    jq -n --arg pointer "$pointer" --argjson missing "$missing" --arg excerpt "$excerpt" \
      '{missing:$missing,pointer:$pointer,excerpt:(if $excerpt=="" then null else $excerpt end)}'
  else
    jq -n --argjson missing "$missing" '{missing:$missing,pointer:null,excerpt:null}'
  fi
}

project_memory_append() { # client_dir text…
  local d="$1"; shift
  local text="$*" md dir
  [[ -n "${text//[[:space:]]/}" ]] || { printf 'append text must be non-empty\n' >&2; return 1; }
  dir=$(project_memory_dir "$d")
  md=$(project_memory_md_path "$d")
  mkdir -p "$dir"
  if [[ -f "$md" ]]; then
    printf '\n- %s\n' "$text" >> "$md"
  else
    cat > "$md" <<EOF
# Project memory

Append-mostly notes for this engagement (constraints, vocabulary, owner prefs).

- $text
EOF
  fi
  jq -n --arg pointer "$md" --argjson missing false \
    '{missing:$missing,pointer:$pointer}' | style_atomic_write "$(project_memory_json_path "$d")"
}

project_memory_show() { # client_dir [--json]
  local d="$1"; shift
  local json=0 a md
  for a in "$@"; do
    case "$a" in
      --json) json=1 ;;
      *) printf 'unknown option %s\n' "$a" >&2; return 1 ;;
    esac
  done
  md=$(project_memory_md_path "$d")
  if [[ ! -f "$md" ]]; then
    if (( json )); then
      jq -n '{missing:true,pointer:null}'
    else
      printf 'Project memory: missing (%s)\n' "$md"
    fi
    return 0
  fi
  if (( json )); then
    project_memory_derive_pack "$d"
  else
    cat "$md"
  fi
}

style_memory_request_fields() { # client_dir → jq object for request.json
  local d="$1" md pm style_missing pm_pointer
  md=$(style_md_path)
  pm=$(project_memory_md_path "$d")
  if style_missing; then
    style_missing=true
  else
    style_missing=false
  fi
  if [[ -f "$pm" ]]; then pm_pointer="$pm"; else pm_pointer=''; fi
  jq -n \
    --arg style_pointer "$( [[ "$style_missing" == true ]] && printf '' || printf '%s' "$md" )" \
    --argjson style_missing "$style_missing" \
    --arg project_memory_pointer "$( [[ -n "$pm_pointer" ]] && printf '%s' "$pm_pointer" || printf '' )" \
    '{
      style_pointer:(if $style_pointer=="" then null else $style_pointer end),
      style_missing:$style_missing,
      project_memory_pointer:(if $project_memory_pointer=="" then null else $project_memory_pointer end)
    }'
}

style_memory_prompt_block() { # client_dir → truncated Style/Project/Lessons text (max ~2KB)
  local d="$1" out='' md pm lf excerpt max=2048 used=0 chunk lesson_file=''
  if style_missing; then
    out="Style: missing (owner has not set $(style_md_path))
"
  else
    md=$(style_md_path)
    out="Style ($(style_dir)):
$(head -c 800 "$md")

"
    used=${#out}
  fi
  pm=$(project_memory_md_path "$d")
  if [[ -f "$pm" ]]; then
    chunk=$(head -c $(( max - used - 80 )) "$pm")
    out+="Project memory:
$chunk

"
    used=${#out}
  else
    out+="Project memory: missing ($(project_memory_dir "$d")/project.md)

"
    used=${#out}
  fi
  lesson_file=''
  while IFS= read -r lf; do
    [[ -f "$lf" ]] && lesson_file="$lf"
  done < <(printf '%s\n' "$d"/runs/iter-*/lessons.md | sort -V)
  [[ -n "$lesson_file" ]] || { [[ -f "$d/lessons.md" ]] && lesson_file="$d/lessons.md"; }
  if [[ -n "$lesson_file" && -f "$lesson_file" ]]; then
    chunk=$(head -c $(( max - used - 80 )) "$lesson_file")
    out+="Lessons ($lesson_file):
$chunk

"
  fi
  printf '%s' "${out:0:$max}"
}

_lessons_excerpt() { # client_dir → excerpt string or empty
  local d="$1" lf='' lesson_file
  while IFS= read -r lesson_file; do
    [[ -f "$lesson_file" ]] && lf="$lesson_file"
  done < <(printf '%s\n' "$d"/runs/iter-*/lessons.md | sort -V)
  [[ -n "$lf" ]] || { [[ -f "$d/lessons.md" ]] && lf="$d/lessons.md"; }
  [[ -n "$lf" && -f "$lf" ]] || { printf ''; return 0; }
  if [[ $(wc -c < "$lf") -le 2048 ]]; then
    cat "$lf"
  else
    head -c 500 "$lf"
  fi
}

lessons_derive_pack() { # client_dir → inspect "lessons" JSON (extended)
  local d="$1" lf='' lesson_file excerpt=''
  while IFS= read -r lesson_file; do
    [[ -f "$lesson_file" ]] && lf="$lesson_file"
  done < <(printf '%s\n' "$d"/runs/iter-*/lessons.md | sort -V)
  [[ -n "$lf" ]] || { [[ -f "$d/lessons.md" ]] && lf="$d/lessons.md"; }
  if [[ -n "$lf" ]]; then
    excerpt=$(_lessons_excerpt "$d")
    jq -n --arg pointer "$lf" --arg excerpt "$excerpt" \
      '{pointer:$pointer,missing:false,excerpt:(if $excerpt=="" then null else $excerpt end)}'
  else
    jq -n '{pointer:null,missing:true,excerpt:null}'
  fi
}
