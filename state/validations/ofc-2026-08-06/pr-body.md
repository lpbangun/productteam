## Summary

- Add `.github/workflows/ci.yml` so pull requests and `main` pushes run `npm test` then `npm run build` on Node 22.
- Require `npm test` in the Pages deploy workflow before `vite build`, so a failing suite cannot publish.
- Point the README clone block at the real repo URL and document the CI/Pages path (live static demo linked).

## Why

Portfolio reviewers and the Pages deploy previously had a build-only path. Domain regressions could ship to GitHub Pages without the Vitest suite. This is the single high-leverage correctness/DX lift for validation contract `ofc-val-2026-08-06`.

## Test plan

- [x] Local `npm test` (15 tests) green
- [x] Local `npm run build` green
- [ ] GitHub Actions CI workflow green on this PR
- [ ] No secrets / vision expansion (no backend, auth, or real AI)
