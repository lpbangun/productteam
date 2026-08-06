# Lessons — iter-2

## Expected
Lift github-integration and safety-discipline; close Critic nits from iter-1.

## Actual
Gated `consult gh` workflow shipped; real PR created; merge gate proven by
refusal without authorize file. MEMORY + judge harness-evolution fixed.

## What worked
- Single `gh` verb with subcommands (not three peer commands)
- Authorize-file gate before any merge attempt

## What failed
- gh preflight permissions JSON sometimes empty in combined runs — still
  have auth scopes evidence

## Change next time
- Iter 3: ship /critique /benchmark /design-sprint skills
- Merge harness PR only with authorize-merge after skills land
