# Lessons — iter-1

## Expected
Lift runtime-routing, memory-learning, testing-evidence, product-judgment,
safety-discipline without architecture bloat.

## Actual
Shipped Critic-narrowed four deliverables. Harness checks 11/11 green.
Removed smoke hang on accidental provider invoke.

## What worked
- Extending `provider.sh` instead of new `runtime.sh`
- Secrets scan folded into harness-checks
- Judgment examples as artifacts (cheap lift)

## What failed
- N/A for scope; github-integration and product-skills still absent

## Change next time
- Iter 2: one gated GitHub workflow (not three peer verbs)
- Ban `--admin`; require authorize file
