#!/usr/bin/env bash
# experience-pool-smoke — cross-engagement pool + inspect/role wiring.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
C="$ROOT/bin/productteam"
TMP=$(mktemp -d)
POOL_TMP="$TMP/pool"
CLIENT_A="pool-smoke-a-$$"
CLIENT_B="pool-smoke-b-$$"
EDIR_A="$ROOT/state/engagements/$CLIENT_A"
EDIR_B="$ROOT/state/engagements/$CLIENT_B"
SOURCE="$TMP/client"
export CONSULT_EXPERIENCE_POOL_DIR="$POOL_TMP"

cleanup() {
  "$C" workspace "$CLIENT_A" remove >/dev/null 2>&1 || true
  "$C" workspace "$CLIENT_B" remove >/dev/null 2>&1 || true
  rm -rf "$EDIR_A" "$EDIR_B" "$TMP"
}
trap cleanup EXIT

expect_refuse() {
  local label="$1"; shift
  if "$C" "$@" >"$TMP/out" 2>&1; then
    printf 'FAIL %s unexpectedly passed\n' "$label" >&2
    exit 1
  fi
}

bootstrap_client() {
  local name="$1" edir="$2"
  mkdir -p "$SOURCE"
  git -C "$SOURCE" init -q 2>/dev/null || true
  git -C "$SOURCE" config user.email pool-smoke@example.invalid
  git -C "$SOURCE" config user.name 'Pool Smoke'
  printf '# stub\n' > "$SOURCE/README.md"
  git -C "$SOURCE" add README.md
  git -C "$SOURCE" commit -qm initial 2>/dev/null || true
  mkdir -p "$edir"
  cat > "$edir/engagement.md" <<EOF
# Pool smoke $name
Mode: **Directive**
Repo: $SOURCE
Mission: Experience pool smoke engagement.
EOF
  cat > "$edir/contract.json" <<'EOF'
{"contract":"pool-smoke-v1","scorer":"provider"}
EOF
}

bootstrap_client "$CLIENT_A" "$EDIR_A"
bootstrap_client "$CLIENT_B" "$EDIR_B"

# Empty pool → inspect honest
"$C" inspect "$CLIENT_A" >/dev/null
pack="$EDIR_A/inspect-pack.json"
jq -e '.experience_pool.missing == true and (.experience_pool.retrieved | length) == 0 and .experience_pool.index_count == 0' "$pack" >/dev/null
printf 'PASS inspect-empty-pool-honest\n'

# refuse add without required flags
expect_refuse pool-add-refuse pool add --title 'no flags'
grep -qi 'requires --kind' "$TMP/out"
printf 'PASS pool-add-refuses-missing-flags\n'

# add worked + failed entries
WORKED_ID=$("$C" pool add --kind worked --domain implement --title "Pool smoke worked $$" \
  --client "$CLIENT_A" --iter 1 --tags smoke,worked --body "Isolated workspace + archived evidence worked.")
FAILED_ID=$("$C" pool add --kind failed --domain scoring --title "Pool smoke failed $$" \
  --client "$CLIENT_A" --body "Self-grading without Critic audit failed.")
[[ -f "$POOL_TMP/entries/${WORKED_ID}.md" ]]
[[ -f "$POOL_TMP/entries/${FAILED_ID}.md" ]]
printf 'PASS pool-add-worked-failed\n'

# list + domain filter
count=$(CONSULT_EXPERIENCE_POOL_DIR="$POOL_TMP" "$C" pool list --domain implement --json | jq 'length')
[[ "$count" -ge 1 ]]
printf 'PASS pool-list-domain\n'

# search finds entry
search_hit=$(CONSULT_EXPERIENCE_POOL_DIR="$POOL_TMP" "$C" pool search "Pool smoke worked" --json | jq -r '.[0].id')
[[ "$search_hit" == "$WORKED_ID" ]]
printf 'PASS pool-search\n'

# show entry
grep -q 'What worked' <<<"$("$C" pool show "$WORKED_ID")"
printf 'PASS pool-show\n'

# first client inspect retrieves pool entries (includes seeds if shared — use isolated pool only)
"$C" inspect "$CLIENT_A" >/dev/null
jq -e --arg id "$WORKED_ID" '.experience_pool.missing == false and .experience_pool.index_count >= 2 and ([.experience_pool.retrieved[].id] | index($id)) != null' "$pack" >/dev/null
printf 'PASS inspect-retrieves-pool\n'

# second engagement inspect cites earlier entry path
"$C" inspect "$CLIENT_B" >/dev/null
pack_b="$EDIR_B/inspect-pack.json"
jq -e --arg id "$WORKED_ID" '.experience_pool.retrieved | (map(.path) | any(test("entries/"))) and (map(.id) | index($id) != null)' "$pack_b" >/dev/null
printf 'PASS second-engagement-retrieves-earlier\n'

# role invoke records experience_pool_ids
"$C" gate "$CLIENT_A" direct 'Pool smoke task.' smoke >/dev/null 2>&1 || true
if CONSULT_PROVIDER=/nonexistent/pool-provider "$C" role "$CLIENT_A" invoke Analyst 5 'Return POOL_SMOKE.' >"$TMP/out" 2>&1; then
  printf 'FAIL role-invoke unexpectedly passed\n' >&2
  exit 1
fi
req="$EDIR_A/roles/iter-5/Analyst/attempt-1/request.json"
[[ -f "$req" ]]
jq -e --arg id "$WORKED_ID" '.experience_pool_ids | type == "array" and length >= 1 and index($id) != null' "$req" >/dev/null
printf 'PASS role-request-pool-ids\n'

# add-from-iter extracts lessons
mkdir -p "$EDIR_A/runs/iter-7"
cat > "$EDIR_A/runs/iter-7/lessons.md" <<EOF
Lesson unique token pool-lesson-$$ — workspace restore after checks prevented invoke blocks.
EOF
FROM_ITER=$("$C" pool add-from-iter "$CLIENT_A" 7 --kind worked --domain implement \
  --title "Lessons excerpt $$" --tags from-iter)
grep -q 'pool-lesson' "$POOL_TMP/entries/${FROM_ITER}.md"
printf 'PASS pool-add-from-iter\n'

printf 'PASS experience-pool-smoke\n'
