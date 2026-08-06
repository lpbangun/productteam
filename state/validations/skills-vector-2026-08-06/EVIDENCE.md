# Evidence index — skills-vector-2026-08-06

| Artifact | Path |
|----------|------|
| Frozen contract | `BENCHMARK-CONTRACT.md` |
| Contract JSON | `contract.json` |
| Lock note | `LOCK.md` |
| Lock hashes | `evidence/lock-hashes.txt` |
| Product inference | `inference.md` |
| Unittest transcript | `evidence/unittest.txt` |
| Compileall | `evidence/compileall.txt` |
| Commit | `evidence/commit.txt` |
| Diff summary | `evidence/diff-summary.txt` |
| PR URL | `evidence/pr-url.txt` |
| PR body | `pr-body.md` |
| Learning | `learning.md` |
| Status | `STATUS.md` |

## Reasoning (why this change)
Role briefs are the product. Accepting a single horizon or duplicate claim ids lets incomplete occupational drafts pass construction while still claiming to encode “time-bound scenarios” and sourced claims. Tightening `validate_brief` raises correctness and product-clarity without touching providers, LangGraph topology, or scope.

## Commands run (real)
```bash
uv venv .venv
uv pip install --python .venv/bin/python -e .
.venv/bin/python -m unittest discover -s tests -v   # 16 OK
.venv/bin/python -m compileall -q src tests
```

## PR
https://github.com/lpbangun/skills-vector/pull/1 — **PR-only, not merged.**
