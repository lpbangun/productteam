# Principal priorities — iteration 1

Evaluator separation: the Principal proposes work and expected lift; it does not assign or alter benchmark scores.

## Proposed work list

1. **Correct and re-freeze the pre-build benchmark before production edits.** The current contract/test omits the mission’s verified `/score <client> --iter <n>` and `/bench <client> run --iter <n>` signature drift and treats a manually duplicated slash list as the expected end state. Add observable PTY assertions for required argument forwarding, quoted paths/arguments, command metadata output, and explicit unsupported reasons. Expected lift: argument/usage parity, chat reachability/classification, argv safety, metadata simplicity.
2. **Introduce one descriptive command registry and make help, top-level validation/dispatch, slash palette, and slash dispatch consume it.** Keep domain handlers in existing modules; aliases include `runtime`, `worktree`, and help flags. No `eval`; parse slash input into an argv array and preserve quoted spaces. Expected lift: reachability, chat reachability/classification, argument/usage parity, metadata simplicity/deletion.
3. **Expose the minimum frontend boundary.** Add command metadata JSON and file-derived status JSON for engagement list/current transient selection inputs; reuse `inspect`, activity TSV, gate/workspace/role JSON, and `agents --json`. Document authority and shapes. Expected lift: frontend machine boundary, help/README/onboarding parity.
4. **Fix verified canonical defects, not unrelated cosmetics.** Repair slash signatures, stale onboarding score syntax, README parity, and `bench`/`run` handling of non-contract score summaries. Investigate the cold-checkout workspace mismatch; fix source behavior only if it can self-heal safely without overwriting a dirty workspace. Do not edit durable style memory merely to satisfy a duplicated-entry probe unless the duplicate is proven to be introduced by this CLI work. Expected lift: reachability, usage parity, docs parity, visual/smoke.
5. **Run isolated Ink and OpenTUI spikes only after the canonical boundary is stable.** Both consume live CLI JSON/files. Measure dependency tree/size, cold start, resize/narrow width, Unicode/wrapping, multiline/scroll/focus/keymap, streaming, accessibility, testing, signal/subprocess ownership, non-TTY/CI, packaging, maturity, and net deletion potential. Expected lift: evidence for dependencies/cold-start and architecture decision; no framework retention absent every gate.
6. **Preserve signal and automation contracts.** Real authenticated agent runtime only for provider-path verification; no mocks. Run the frozen parity test, smoke, visual suite, syntax checks, focused PTY/signal paths, and a real terminal transcript. Expected lift: Ctrl+C/partial artifacts, non-TTY/NO_COLOR/exit, visual/smoke.

## Scope controls

- Preserve the three pre-existing untracked paths recorded in `baseline-evidence.md`.
- No plugin framework, daemon, database, server, duplicate durable state, or interactive default.
- At most six organization iterations. Framework prototypes are disposable unless the evidence gate passes.
