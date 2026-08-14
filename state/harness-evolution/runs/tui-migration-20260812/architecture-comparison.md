# Architecture comparison

Both evaluated candidates remained presentation clients: shared screen/event fixtures in; existing ProductTeam CLI and plain-file projections read through adapters; no daemon, database, provider invocation, judgment engine, or durable-state authority. Both candidate trees were deleted after the non-convergence decision; details below are recorded evidence, not retained code.

## OpenTUI + Solid — evaluated

- Bun/TypeScript client with OpenTUI core, Solid renderer, and keymap at 0.5.2; Solid 1.9.12.
- Controller owned transient signals; the Solid application rendered the header, scrollbox, workers, composer, palette, evidence, permission, and notification surfaces.
- Exact argv seams and lifecycle process-group ownership were separated into adapters/lifecycle modules.
- Candidate source: 1,371 nonblank noncomment lines; tests: 646.
- Installed dependencies: 124,379,136 allocated bytes, 111 unique packages. Packaged artifacts: 65,536 allocated bytes.
- Risk: pre-1.0 framework APIs, Solid transform/preload requirements, Bun/native distribution, and more custom focus/layout glue.

## Textual + Rich — evaluated

- Python client on Textual 8.2.8 and Rich 15.0.0.
- The application used framework-native RichLog, TextArea, ModalScreen, bindings, workers, and snapshot support; adapters and lifecycle remained separate.
- Candidate source: 812 nonblank noncomment lines; tests: 530.
- Installed dependencies: 38,866,944 allocated bytes, 19 unique packages. Packaged artifacts: 28,672 allocated bytes.
- Risk: framework internal-name collisions are possible (one `_notifications` collision was found by real PTY smoke and fixed); Python packaging still must ship dependencies, not only source zip.

## Decision

The static evidence favored Textual on implementation size, dependency footprint, framework stability, and first-party application infrastructure. That was not a valid winner claim: the frozen common interaction, process, latency, RSS, and boundary measurements did not complete. Per the decision rules, neither prototype was retained.

Framework-neutral artifacts retained for a later authorized spike: event envelope/schema, semantic screen projection, CLI registry metadata, argv-only adapter contract, read-only file projections, process-group cancellation semantics, terminal/exit contract, scenario/action vocabulary, and evidence scoring.
