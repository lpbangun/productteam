# Convergence blocker map — iter-6 through iter-10

Authority: owner extension in `extension.md`; acceptance remains immutable D01–D29. Baseline: `iter-5/reviewer-gate.md`, 8/29 dimensions >=9.0; zeros D08/D12/D13/D16/D25.

## Functional blockers

| Cluster | Baseline | Root blocker | Completion proof | Planned iteration |
|---|---:|---|---|---:|
| Structured ask | D08 0.0; contributes to D01/D15/D25/D28 | No structured event consumer or dock state beyond slash | Canonical `ask.json`; exact colored question; single/multi/recommended/k-of-n; arrows/Space/Enter/Esc; atomic structured response; composer retained; malformed event refuses | 6 |
| Write confirmation | D13 0.0; contributes to D25/D28 | Exact write argv reaches `_exec_cli` immediately | Exact intercepts for `gh merge`, `checks --allow-dirty`, `onboarding --yes`; Cancel/Esc produces no argv; Run preserves and executes original argv | 6 |
| Evidence panel | D12 0.0; contributes to D01/D25/D28 | Report/bench path lists stream as ordinary transcript lines | Command summary rail plus bordered labelled file panel; long paths withheld from chat; report and bench fixtures; close restores composer | 7 |
| Command/toast/card semantics | D10 6.0, D11 7.5, D14 5.8, D19 8.0, D21 8.2 | Slash/session output lacks Command rails; done card detached; session verbs add transcript lines | Command rails for run/refuse/usage; speaking markdown snapshot; attached completion/error cards; export/provider-cycle mute toasts | 7 |
| TUI boot splash | D16 0.0; D26 5.0 | No TUI-owned boot state | Angular ASCII heads once; neutral idle; Principal→Analyst→Builder→Principal live glow; composer/footer visible; any key skip; `/splash` remains real CLI Command | 8 |

## Proof and scoring blockers after functions exist

| Cluster | Baseline | Missing evidence or behavior | Planned iteration |
|---|---:|---|---:|
| Home/header | D03 8.5, D05 8.5 | Explicit recency order; honest empty fixture; middle-head live pulse; compact score slot on PTY | 8–9 |
| Identity/markdown | D04 8.6, D10 6.0 | Speaking-turn markdown-lite snapshot and locked You/err token evidence | 7–9 |
| Activity/speech/compact | D06 7.5, D07 8.4, D09 8.2, D24 8.6 | Real PTY empty-artifact silence, visible braille/m:ss/caps, 40-col live cap, prompt-export capture | 9 |
| Global layout/footer | D01 8.0, D15 8.0 | All ask/confirm/evidence/splash states and dock-specific footer strings need reachable tests/snapshots | 6–9 |
| Coverage | D28 7.2 | Frozen ask/confirm/evidence/splash/activity PTY rows absent | 6–9 |
| Final score closure | all remaining 8.x | Independent citations may expose residual gaps after functional work | 10, only if Reviewer still reports sub-9 |

## Iteration contracts

1. **Iter-6:** ask + confirm shared dock state machine. Remove D08/D13 zeros.
2. **Iter-7:** evidence panel + Command rails + toast/card/markdown semantics. Remove D12 zero and close D10/D11/D14/D19/D21.
3. **Iter-8:** TUI-owned splash + header/home reachability. Remove D16 zero; D25 must now have all three backend seams.
4. **Iter-9:** real-PTY proof closure for activity/speech/compact/prompt export and any Reviewer-named gaps.
5. **Iter-10:** final Reviewer-directed closure only. No speculative features.

## Non-negotiable regression checks every iteration

- Native `lib/tui/tests` green, snapshots intentional.
- Real PTY `/status` + `/gate` no-spawn, Builder role, provider interrupt, SIGWINCH.
- CLI parity 33/18/15/6.
- Visual CLI 14/14; only existing live-provider exception may control exit 1.
- One Writer, immutable freeze hashes, argv arrays, no provider mock, no second supervisor/state authority.

No zero-score function may be replaced by a placeholder, transcript scrape, no-op confirmation, fake provider event, or purely visual snapshot.
