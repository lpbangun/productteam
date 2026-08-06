# Harness-evolution loop sequence (documented, fixed)

Executable manually by the Principal session. No second orchestrator.

1. Inspect harness tree + `bin/consult status` + `bin/consult runtime`
2. Confirm lock: `git diff -- state/harness-evolution/HARNESS-BENCHMARK-CONTRACT.md state/harness-evolution/contract.json`
3. Critic debates priorities → `runs/iter-N/critic-priority-debate.md` or report section
4. Builder implements accepted scope only
5. `bin/consult harness-checks state/harness-evolution/runs/iter-N`
6. `bin/consult smoke` (full) when client path matters; else CONSULT_SMOKE_SKIP_CLIENT=1
7. Independent evaluator writes `runs/iter-N/scores.json`
8. Critic writes `runs/iter-N/critic-verdict.md`
9. Write `lessons.md`; append `history.jsonl`; update MEMORY.md
10. Stop if every dim ≥ 8.0 + checklist, or after 5 improvement iters

Stop conditions honor `harness-apc-v1`.
