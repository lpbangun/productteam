# Lessons and organization review

## Product lessons

- Both frameworks can express the required presentation-only architecture without moving ProductTeam authority into the UI.
- Native tests exposed real framework risks: OpenTUI requires correct Solid preload configuration; Textual application fields can collide with framework internals; real PTY smoke found the latter when headless tests did not.
- Static evidence suggests Textual needs less custom application code and substantially fewer installed dependencies. It remains a hypothesis, not a migration decision, until the same external interaction and performance run completes.
- Process ownership belongs in a framework-neutral adapter contract even when implementation details differ.

## Organization self-review

What worked: benchmark-before-build; exact Builder directory isolation; parallel independent implementations; candidate-local repairs only; direct Principal verification; independent Analyst and mandatory final Critic; refusal to bypass the frozen contract.

What failed: the prebuild reviews proved adversarial unit cases but never ran one honest reference client through the generated executable proxy and complete trace audit. The benchmark was sophisticated but not end-to-end runnable. That omission voided the expensive comparison.

Required process correction: before hashing a future interactive benchmark, execute a minimal honest reference client through every boundary and record (1) proxy mode after all permission hardening, (2) all required argv traces accepted by the trace policy, (3) one complete scenario with cleanup, and (4) scorer acceptance of the generated evidence. Then freeze. This is a review/process change, not a permanent worker or architecture change.
