# Critic final verdict

## Verdict

**NON-CONVERGENT — delete both prototypes; retain neither.**

This is a fail-closed benchmark result, not evidence that either framework is inferior.

## Frozen contradictions

1. `spikes/shared/pty_driver.py:create_proxy` writes `bin/productteam`, sets mode 0555 at line 176, then the recursive permission loop at lines 189–190 changes every file—including that proxy—to 0444. Both clients must execute this proxy for the six required read-only seams. Textual surfaced `PermissionError`; OpenTUI rendered an initial frame but could not establish dynamic palette, argv-log, or boundary proof.
2. `audit_trace_text` forbids the substring `agent` in exec traces while the required allowlist and `verify_boundary` mandate `agents --json`. An honest required seam therefore triggers the forbidden trace condition.

Both defects belong to the frozen 18-file manifest. Correcting either after implementation would violate the benchmark freeze. Candidate-local workarounds would violate exact argv and source-fix rules.

## Review of diff and scores

Candidate-local native suites, strict event validation, non-TTY contracts, direct terminal 0/17 restoration, lifecycle unit proof, and base rendering are real. They do not replace the missing common four-size action/observation proof. The Analyst therefore kept all mandatory dimensions below 9. Neither candidate passes the mandatory retention gate; no Textual tie-break, OpenTUI material-advantage claim, retain-both test, or production migration is authorized.

## Organization review

The organization correctly froze before independent implementation and refused post-freeze benchmark edits. It failed by accepting a shared harness whose executable permission and trace allowlist were not exercised end-to-end before hashing. Future evidence spikes must run one honest reference candidate through every frozen boundary—including executable proxy creation and required trace tokens—before authorization. Critic approval must cite that complete dry run, not only adversarial unit tests.
