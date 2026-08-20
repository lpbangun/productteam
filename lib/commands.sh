# lib/commands.sh — the thin command registry (single source, contract
# cli-interface-20260812-v3). One data table drives, without duplication: the
# help command table, `help --json` command metadata, top-level dispatch
# validation/routing (aliases runtime/worktree and -h/--help stay hand-written
# at the call site), the chat slash palette (/help verb list and live hints),
# slash routing, and explicit chat_supported / chat_reason per command.
#
# Data table + existing handlers only: no plugin host, no eval, no daemon.
# Handler logic stays in the existing command functions (domain authority);
# this file only names them and carries descriptive metadata.

_csep=$'\x1f'   # record field separator (never appears in usage/summary text)

CMD_REGISTRY=()

cmd_reg_add() { # name aliases usage summary min_args handler chat_supported chat_reason
  local name="$1" aliases="$2" usage="$3" summary="$4" min_args="$5"
  local handler="$6" chat="$7" reason="$8"
  CMD_REGISTRY+=("$name$_csep$aliases$_csep$usage$_csep$summary$_csep$min_args$_csep$handler$_csep$chat$_csep$reason")
}

# ── frozen membership: the 33-command table (help is the canonical surface) ──
# chat_supported: 18 read/delegated CLI commands safe in a session.
# chat_reason:    non-empty safety/usefulness reason for the 15 unsupported.
# Chat-only verbs (palette-only, not CLI commands) live in CMD_CHAT_ONLY.
cmd_reg_add 'agents'          ''    'productteam agents [--json]'                                    'Coding agents on this device' 0 cmd_agents 1 ''
cmd_reg_add 'baseline'        ''    'productteam baseline <client> [--allow-dirty <reason>]'         'iter-0 via workspace + checks/score entrypoints' 1 cmd_baseline 0 'usefulness: one-shot iter-0 bootstrap gated by --allow-dirty; owner-gated write'
cmd_reg_add 'bench'           ''    'productteam bench <client> [run --iter <n>]'                    'Benchmark contract + history + latest scores' 1 dispatch_bench 1 ''
cmd_reg_add 'card'            ''    'productteam card list|show|seed-specialist …'                   'Named agent cards (state/agents/)' 1 cmd_card 0 'safety/usefulness: seed-specialist writes agent cards; read side available via card list|show CLI'
cmd_reg_add 'chat'            ''    'productteam chat'                                               'Interactive session (TTY; V1 robots mark)' 0 cmd_chat 0 'safety: nested sessions re-enter the same REPL with no isolation; no usefulness'
cmd_reg_add 'checks'          ''    'productteam checks <client> [--allow-dirty <reason>]'           'Deterministic checks in isolated workspace' 1 cmd_checks 1 ''
cmd_reg_add 'direction'       ''    'productteam direction <client> propose|list|clear|rebut …'      'Guided direction proposals + Critic rebuttal (see gate rebut alias)' 2 cmd_direction 0 'safety: proposal/clear ops mutate durable direction state; owner-gated'
cmd_reg_add 'escalation'      ''    'productteam escalation <client> block <id> <summary> <option> [option...]' 'productteam escalation <client> status|resume <id> <token>' 2 cmd_escalation 0 'safety: block/resume carry authorization tokens; must not run mid-session'
cmd_reg_add 'gate'            ''    'productteam gate <client> status|implement|select|direct|challenge|override|rebut …' 'Durable judgment decisions + machine status' 2 cmd_gate 0 'safety: owner-gated durable decisions must leave a durable record; session context bypasses it'
cmd_reg_add 'gh'              ''    'productteam gh preflight|pr-create|status|checks|merge|validate …' 'GitHub auth, PRs, checks (tokens redacted)' 1 cmd_gh 1 ''
cmd_reg_add 'harness-checks'  ''    'productteam harness-checks [iter-dir]'                           'Objective harness-apc checks + secrets scan' 0 cmd_harness_checks 1 ''
cmd_reg_add 'help'            ''    'productteam help [--json]'                                      'This text' 0 cmd_help 1 ''
cmd_reg_add 'inspect'         ''    'productteam inspect <client> [out]'                             'Regenerate the file-derived inspect pack' 1 cmd_inspect 0 'usefulness: regenerates the inspect pack (a write op) from files; read side is the file itself'
cmd_reg_add 'judge'           ''    'productteam judge <client> [set <mode>]'                        'Product Judgment mode + mission' 1 dispatch_judge 1 ''
cmd_reg_add 'memory'          ''    'productteam memory'                                             'Organizational memory' 0 cmd_memory 1 ''
cmd_reg_add 'onboarding'      ''    'productteam onboarding [--yes]'                                 'First run: agents, provider, first score' 0 cmd_onboarding 1 ''
cmd_reg_add 'open'            ''    'productteam open <client> --repo <abs-path> [--mode …] [--scorer …]' 'Cold engagement stub + freeze stamp + workspace' 1 cmd_open 0 'usefulness: one-shot cold-start needing --repo absolute-path args; safety: creates engagement state mid-session'
cmd_reg_add 'org'             ''    'productteam org'                                                'Roles, loop, autonomy' 0 cmd_org 1 ''
cmd_reg_add 'pool'            ''    'productteam pool list|show|search|add|add-from-iter …'          'Cross-engagement experience excerpts (state/experience-pool/)' 1 cmd_pool 0 'usefulness: search/add are one-shot CLI ops; read side via pool list|show|search'
cmd_reg_add 'project-memory'  ''    'productteam project-memory show|append <client> …'              'Per-engagement notes (state/engagements/<client>/memory/)' 1 cmd_project_memory 0 'usefulness: append is a one-shot CLI op; read side via project-memory show'
cmd_reg_add 'report'          ''    'productteam report <client>'                                    'Latest iteration report' 1 cmd_report 1 ''
cmd_reg_add 'role'            ''    'productteam role <client> invoke <Analyst|Builder|Critic> <iter> [task]' 'productteam role <client> seal <iter> <input-file> | status [iter] | close <iter>' 2 cmd_role 0 'safety: seal/invoke enforce authorship and stamp integrity; must not run mid-session'
cmd_reg_add 'run'             ''    'productteam run <client> <iter>'                                'Show scores for iteration n' 2 cmd_run_detail 1 ''
cmd_reg_add 'run-loop'        ''    'productteam run-loop <client> --max-hours <n> --max-iters <m> [--dry-run] [--resume] [--no-provider]' 'Overnight loop driver (inspect→gate→roles→score→close)' 0 cmd_run_loop 0 'safety/usefulness: long-running overnight driver with its own signal handling; not a chat verb'
cmd_reg_add 'runtime'         ''    'productteam runtime [--check]'                                  'Alias of agents; --check fails if none' 0 cmd_agents 1 ''
cmd_reg_add 'score'           ''    'productteam score <client> --iter <n>'                          'Score via the declared scorer + Analyst stamp' 1 cmd_score 1 ''
cmd_reg_add 'skill'           ''    'productteam skill <critique|benchmark|design-sprint> <target> [out-dir]' 'Run /critique|/benchmark|/design-sprint' 2 cmd_skill 1 ''
cmd_reg_add 'smoke'           ''    'productteam smoke'                                              'CLI smoke tests' 0 cmd_smoke 1 ''
cmd_reg_add 'splash'          ''    'productteam splash [--frames]'                                  'Knowledge-graph banner (CONSULT_NO_SPLASH=1 skips)' 0 cmd_splash 1 ''
cmd_reg_add 'status'          ''    'productteam status [--json]'                                    'The same overview, named explicitly' 0 cmd_status 1 ''
cmd_reg_add 'style'           ''    'productteam style show|init|append|accept-lesson|rewrite …'     'Org taste/risk/stack/never (state/style/)' 1 cmd_style 0 'safety: org style is owner-edited durable memory; read side via style show CLI'
cmd_reg_add 'tui'             ''    'productteam tui'                                               'Optional Textual cockpit (TTY)' 0 cmd_tui 0 'safety/usefulness: optional presentation client; TTY required; must not nest inside chat'
cmd_reg_add 'workspace'       'worktree' 'productteam workspace <client> ensure|status|remove'        'Isolated client worktree lifecycle' 2 cmd_workspace 0 'safety: worktree mutation; in-session invocation could touch dirty/foreign worktrees'

# ── chat-only verbs: palette-only, never CLI commands ───────────────────
CMD_CHAT_ONLY=(provider workers clear export exit quit)

# ── accessors ─────────────────────────────────────────────────────────
cmd_reg_get() { # $1=index → REG_NAME REG_ALIASES REG_USAGE REG_SUMMARY REG_MIN REG_HANDLER REG_CHAT REG_REASON
  local rec="${CMD_REGISTRY[$1]:-}" IFS
  IFS=$_csep read -r REG_NAME REG_ALIASES REG_USAGE REG_SUMMARY REG_MIN REG_HANDLER REG_CHAT REG_REASON <<<"$rec"
  REG_MIN="${REG_MIN:-0}"
  REG_CHAT="${REG_CHAT:-0}"
  REG_REASON="${REG_REASON:-}"
}

cmd_reg_index() { # $1=name-or-alias → prints registry index ('' when none); always exits 0
  local n="$1" i rec name aliases a
  for i in "${!CMD_REGISTRY[@]}"; do
    rec="${CMD_REGISTRY[$i]}"
    name="${rec%%$_csep*}"
    if [[ "$name" == "$n" ]]; then
      printf '%s' "$i"
      return 0
    fi
    aliases="${rec#*$_csep}"
    aliases="${aliases%%$_csep*}"
    for a in $aliases; do
      if [[ "$a" == "$n" ]]; then
        printf '%s' "$i"
        return 0
      fi
    done
  done
  return 0
}

cmd_reg_names() { # → registry-ordered command names, one per line
  local i
  for i in "${!CMD_REGISTRY[@]}"; do
    cmd_reg_get "$i"
    printf '%s\n' "$REG_NAME"
  done
}

cmd_reg_chat_names() { # → registry-ordered chat-supported command names, one per line
  local i
  for i in "${!CMD_REGISTRY[@]}"; do
    cmd_reg_get "$i"
    [[ "$REG_CHAT" == 1 ]] && printf '%s\n' "$REG_NAME"
  done
}

cmd_help_json() { # → `help --json`: 33-command registry + chat-only verbs (frozen shape)
  local tsv='' i co_json line
  for i in "${!CMD_REGISTRY[@]}"; do
    cmd_reg_get "$i"
    printf -v line '%s\t%s\t%s\t%s\n' "$REG_NAME" "$REG_USAGE" "$REG_CHAT" "$REG_REASON"
    tsv+="$line"
  done
  co_json=$(printf '%s\n' "${CMD_CHAT_ONLY[@]}" | jq -R -s 'split("\n") | map(select(length > 0))')
  printf '%s' "$tsv" | jq -Rs --argjson co "$co_json" '
    split("\n") | map(select(length > 0)) | map(split("\t")) |
    { contract: "cli-interface-20260812-v3",
      commands: map({name: .[0], usage: .[1], chat_supported: (.[2] == "1")} +
                    (if .[2] == "0" then {chat_reason: .[3]} else {} end)),
      chat_only: $co }'
}
