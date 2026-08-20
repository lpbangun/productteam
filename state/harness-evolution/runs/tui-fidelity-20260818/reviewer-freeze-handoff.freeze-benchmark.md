# Reviewer freeze handoff — tui-fidelity-20260818

**Verdict:** fail today on B6+ (as required before freeze). Freeze itself: **ACCEPT-FOR-FREEZE**.

## Files

| path | role |
|---|---|
| `state/harness-evolution/runs/tui-fidelity-20260818/frozen-benchmark.md` | immutable freeze; contains literal `ACCEPT-FOR-FREEZE` |
| `state/harness-evolution/runs/tui-fidelity-20260818/FREEZE-SHA.txt` | SHA-256 of the freeze |
| `state/harness-evolution/runs/tui-fidelity-20260818/reviewer-freeze-handoff.freeze-benchmark.md` | this report |

No app/product file was edited.

## Hash

- algorithm: SHA-256
- command: `sha256sum state/harness-evolution/runs/tui-fidelity-20260818/frozen-benchmark.md`
- path: `state/harness-evolution/runs/tui-fidelity-20260818/frozen-benchmark.md`
- hash: `da6335f2a7c100ee4a0f4a46c117986ddb1edf6adbe7a13e198c5dbd70794acd`
- verify: `sha256sum -c state/harness-evolution/runs/tui-fidelity-20260818/FREEZE-SHA.txt` → **OK**

## Commands + exit codes (recorded, not invented)

| check | command | exit | output |
|---|---|---|---|
| sources | `sha256sum` locked + decide HTML | 0 | locked `2a9627cb17ec3bf41e0f205ebc8b7d6842741c5aa2670ee3f40fb70746db8121`; decide `db911fcbdb5075493f9b2fcc9e696f7c168fb32727b008a0d829458ef5fbfc63`; remotes matched |
| B1 | `lib/tui/.venv/bin/python -m pytest lib/tui/tests --collect-only -q` | 0 | `73 tests collected in 0.32s` |
| B2 | `lib/tui/.venv/bin/python -m pytest lib/tui/tests -q` | 0 | `73 passed, 1 warning in 171.98s (0:02:51)` |
| B3 | `tests/cli-interface-parity.sh` | 0 | `cli-interface parity v3: PASS` |
| B4 | `tests/visual-cli.sh` | 1 | `14/14 pass · 0 fail · 0 skipped · live provider proof missing` (allowed pre-existing) |
| B6+ | live visual/TTY probe vs today's compressed first paint | 1 | **20 FAIL(S)** — B6 persist, B7 splash-only plane, B8 prefix width 12, B9 no unpin, B10 score-first home, B11 no no-provider copy, B12 four chips at 40, B13 no ✓ on chip, B14 ★/no title/no in-dock k of n, B15 two-row confirm, B16 home+SIGWINCH chips |

## B6+ fails today

Yes. Compressed first paint at 80×24 / 40×20 is still:

```text
▣─▣─▣ ProductTeam · exp-tui-migration · —
  9.5  osint-loop-research · iter-2 · +0.0
…
◆ Principal ◇ Analyst ▸ Builder ◉ Critic
PREFIX=''
```

Splash auto-finishes at step 5; header/rule/chips stay mounted; `#role-prefix` width 12.

## Residual risks

- `spikes/visualizer/classic.html` and `app.js` are absent; freeze cites locked + decide pages.
- Existing `HOME_ROW_RE` encodes score-first home; worker may retarget that regex to `● name …… score` only if B1–B5 coverage is kept.
- B4 exit 1 remains the pre-existing live-provider hole; do not mock.
- BENCHMARK.md B1–B5 do not exist as a file; they are frozen as the established 73-test / parity / visual-cli / size bar and must not be weakened.

Implementation may begin. Do not amend the freeze after this hash.
