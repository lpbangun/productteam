# Lessons — iter-0 (baseline)

## Expected
Honest baseline against harness-apc-v1 before APC-lifting changes.

## Actual
Overall **4.4**. Weakest: product-skills 1.0, github-integration 2.0,
runtime-routing / memory-learning / autonomy-loop 3.0.

## What worked
- Independent evaluator + locked contract before implementation
- Critic cut `consult evolve` / `consult learn` / parallel `runtime.sh`

## What failed
- Smoke still had a no-op `bench agcode-learning run` that invokes the
  provider and can hang — fixed in iter-1

## Change next time
- Never invoke provider scoring inside smoke “refuse” tests
- Keep Iter-1 to Critic-accepted four deliverables only
