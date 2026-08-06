# Iter-2 report — GitHub seam + Critic nits

**Mode:** Directive  
**Contract:** harness-apc-v1 (lock unmodified)

## Scope (Critic-narrowed)

1. One gated GitHub workflow: `lib/github.sh` + `consult gh …`
2. Merge refuses without authorize-merge; never admin bypass
3. MEMORY.md harness-evolution lesson; `consult judge harness-evolution`
4. Lock hash stability check in harness-checks

## Diff summary

| Change | Why |
|--------|-----|
| `lib/github.sh` | preflight/pr-create/status/checks/merge/validate |
| `bin/consult` | `gh` subcommands; judge harness-evolution |
| `lib/harness-checks.sh` | github seam, merge refuse, lock hashes, MEMORY |
| README/ARCHITECTURE | document shipped GH surface |
| MEMORY.md | iter-1 lesson |

## Verification

- Smoke + harness-checks 15/15 green
- Real PR opened via `consult gh pr-create` (see evidence/)
- Merge without auth refused (recorded)

## Deferred

- product-skills (Iter 3)
- authorize+merge of this PR (owner gate; may merge after skills)
