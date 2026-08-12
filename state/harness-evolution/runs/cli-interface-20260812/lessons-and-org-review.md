# Lessons and organization self-review

## Lessons

- Freeze review must test named defects, not only nearby abstractions. Advisor v1 omitted slash `--iter`, quoting, onboarding, and summary-score failures; two Critic passes corrected the freeze before Builder work.
- A command registry earns its weight only when it deletes independent routing metadata. The retained table drives help, JSON help, validation, dispatch, slash hints, slash classification, and slash routing while handlers remain in domain modules.
- Safe shell parsing is observable behavior. PTY probes proved quoted argv, required-option forwarding, inert metacharacters, and session survival without `eval`.
- A frontend boundary can be useful even when no frontend is retained. JSON/file seams reduced future coupling without adding durable state.
- Working prototypes are cheap evidence, not an adoption argument. Both candidates passed their own tests and still failed packaging, runtime, streaming, accessibility, and net-deletion gates.
- Literal benchmark rubrics can conflict with evidence preservation. Refuse score gaming; report the mismatch and propose a future contract change.

## Organization self-review

### Roles

- **Principal:** owned sequence, priorities, accepted/overruled Critic points, framework decision, and reporting; never assigned benchmark scores.
- **Analyst:** baseline and final scores independently produced with file/command evidence. Iterations 3–6 repeated the unchanged audit at the explicit cap.
- **Builder:** implementation split into registry/boundary and verified-defect slices after one over-broad Builder stalled in discovery. The split reduced orchestration friction.
- **Critic:** rejected two incomplete freezes, accepted v3, audited final diff/scores/architecture/org, and accepted terminal non-convergence.
- **Temporary Advisor:** valuable for benchmark/test construction, but initial output preserved omissions and included a mis-aimed style-memory probe. Critic review was necessary.

### Friction and improvements

1. The initial Builder assignment bundled too many interfaces and stalled. Future work should split by file ownership once the registry contract is fixed.
2. Benchmark creation took three versions. Future Advisor prompts must enumerate every user-named defect as a required failing probe and forbid state-content hygiene probes unrelated to the product surface.
3. Tests that create engagement runs mutate tracked pointers and workspace metadata. Final cleanup restored those files and removed only this run’s generated check directories. Future runners should accept an output/state-root override for all stateful checks.
4. The frozen portability dimension conflated active dependency pins with immutable provenance. Future contracts should score behavior via isolated execution, not broad scans of historical artifacts.
5. No new permanent worker is justified. Advisor and framework specialists were temporary and disbanded; the four-role organization remains sufficient.

### Scope/churn judgment

Production change: 392 inserted / 279 deleted across tracked files, plus 122-line new command registry. The 489-line frozen parity test is evidence scaffold. Disposable framework code and all framework dependencies were deleted. No daemon, server, database, plugin host, package cache, or `productteam tui` remains.
