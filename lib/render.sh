# lib/render.sh — markdown-lite + evidence rendering for the CLI surface.
# Consumes theme vars (B D R G RD) set by bin/productteam; degrades to plain
# text when they are empty (batch runners, NO_COLOR, non-TTY).

: "${B:=}" "${D:=}" "${R:=}" "${G:=}" "${RD:=}"

# render_evidence sign path text → "sign path: text" on one line.
#   sign: signed delta (+0.5 / -0.3) or empty for neutral — G for +, RD for -,
#         dim for neutral; path is bold; text is dim.
render_evidence() {
  local sign="$1" path="$2" text="$3" acc path_style
  case "${sign:0:1}" in
    +) acc="$G" ;;
    -) acc="$RD" ;;
    *) acc="$D" ;;
  esac
  [[ -n "$sign" ]] && printf '%s%s%s ' "$acc" "$sign" "$R"
  if [[ -n "$path" ]]; then
    path_style="${B}"
    [[ -n "$sign" ]] && path_style="${acc}${B}"
    printf '%s%s%s: %s%s%s' "$path_style" "$path" "$R" "$D" "$text" "$R"
  else
    printf '%s%s%s' "$D" "$text" "$R"
  fi
}

# render_markdown_lite file → markdown-lite to stdout (2-space indent).
# Headings bold+accented, fence markers dim with fenced body unstyled,
# verdict lines bold, leading +/- diff lines accented, evidence-path lines
# emphasized. Under NO_COLOR / non-TTY the markdown markers are kept so the
# content stays readable; no content is ever dropped.
render_markdown_lite() {
  local f="$1" line in_fence=0
  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" == '```'* ]]; then
      printf '  %s```%s\n' "$D" "$R"
      in_fence=$((1 - in_fence))
      continue
    fi
    if (( in_fence )); then
      printf '  %s\n' "$line"
      continue
    fi
    # heading: bold + accent; markers dropped only when colors are live
    if [[ "$line" =~ ^#{1,6}[[:space:]]+(.*)$ ]]; then
      if [[ -n "$B" ]]; then
        printf '  %s%s%s%s\n' "$B" "$G" "${BASH_REMATCH[1]}" "$R"
      else
        printf '  %s\n' "$line"
      fi
      continue
    fi
    # leading diff line: +foo / -foo (not "- " bullets, not "---" separators)
    if [[ "$line" =~ ^([+-])[^[:space:]-] ]]; then
      if [[ "${BASH_REMATCH[1]}" == '+' ]]; then
        printf '  %s%s%s%s\n' "$G" "${BASH_REMATCH[1]}" "$R" "${line:1}"
      else
        printf '  %s%s%s%s\n' "$RD" "${BASH_REMATCH[1]}" "$R" "${line:1}"
      fi
      continue
    fi
    # verdict line: whole line bold
    if [[ "$line" == '**'* ]]; then
      if [[ -n "$B" ]]; then
        printf '  %s%s%s\n' "$B" "${line//\*\*/}" "$R"
      else
        printf '  %s\n' "$line"
      fi
      continue
    fi
    # evidence-path line: path: text at line start (path carries a path-ish char)
    local pline="$line"
    [[ "$pline" == '`'* ]] && pline="${pline:1}"
    if [[ "$pline" =~ ^([^[:space:]:]*[./_-][^[:space:]:]*):[[:space:]](.*)$ ]]; then
      printf '  %s%s%s: %s%s%s\n' "$B" "${BASH_REMATCH[1]}" "$R" "$D" "${BASH_REMATCH[2]}" "$R"
      continue
    fi
    # inline **bold** segments
    if [[ "$line" == *'**'* && -n "$B" ]]; then
      local out='' rest="$line" prefix bold
      while [[ "$rest" == *'**'* ]]; do
        prefix="${rest%%\*\**}"
        rest="${rest#*\*\*}"
        if [[ "$rest" != *'**'* ]]; then
          out+="${prefix}**${rest}"
          rest=''
          break
        fi
        bold="${rest%%\*\**}"
        rest="${rest#*\*\*}"
        out+="${prefix}${B}${bold}${R}"
      done
      printf '  %s%s\n' "$out" "$rest"
      continue
    fi
    printf '  %s\n' "$line"
  done < "$f"
}
