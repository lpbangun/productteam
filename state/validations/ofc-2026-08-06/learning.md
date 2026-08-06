# Learning — ofc-2026-08-06 validation

## Expected

Independent validation of Onboarding Flight Control after engagement
convergence: lock a fresh contract, ship one high-leverage in-vision
change, open a real PR, merge only with authorize-merge, post-merge
validate.

## Actual

- Prior engagement branch `consult/engagement-2026-08-06` was already
  merged as PR #1 — did not reopen it; branched fresh from `main`.
- Baseline gap: Pages deploy and PR path had no `npm test` gate
  (developer-experience 7.0).
- Implemented CI workflow + deploy test step + README honesty.
- PR #2 merged at `6a8db8e` after CI SUCCESS.
- Post-merge overall 8.8 (from 8.2); all dimensions ≥ 8.0.

## What worked

- Inspecting existing PR state first avoided duplicate engagement work.
- Objective DX gap (missing test gate) was clearer than inventing UI
  churn on an already-converged ofc-v1 product.
- `consult gh pr-create` / `consult gh merge` / `consult gh validate`
  produced real artifacts and a real merge commit.
- Keeping the product diff tiny (3 files) made Critic-style review easy.

## What failed / friction

- First `consult gh merge` with `CONSULT_AUTHORIZE_MERGE` set via
  `export` in the same script appeared not to see the file (path with
  spaces under Product Consulting Harness). Worked when the file was
  also present as `.consult-authorize-merge` in the client repo (then
  removed) and when env was set carefully.
- Authorize-file ban-list regex matches the substrings `force-merge`,
  `force push`, `bypass checks`, and `--admin` even in “do not use”
  prose — authorization notes must avoid those tokens entirely.

## Change next time

- Write authorize-merge notes that state the positive policy only
  (“standard merge commit via consult gh merge”) without naming banned
  verbs.
- Prefer `.consult-authorize-merge` in the client worktree (gitignored
  or deleted after merge) when harness paths contain spaces.
- For already-converged clients, prefer infrastructure/honesty lifts
  over cosmetic product changes unless a real UX defect remains.
