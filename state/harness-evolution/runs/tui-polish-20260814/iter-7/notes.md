# Iteration 7 notes — evidence, Command, toasts, cards

## Functions implemented

- Product-side stream classifier for real report/bench shapes; summary and path payloads split before RichLog write.
- Existing `#dock` evidence state: bordered label, styled file rows, 6/3 compact caps, display-only controls, honest close footer and focus.
- Mute Command rails for slash request, supported stream, refusal, and usage; no role hue.
- Observable session toasts for export/provider cycle without extra transcript lines.
- Role-owned completion/error rail cards without speech replay; interrupt preserves exact PTY phrases and one warning toast.
- Speaking-turn markdown-lite proof for heading, diff signs, evidence path, neutral body, fence, role rail, and attached card.

## Verification

| Check | Result |
|---|---|
| Native pytest | PASS — 52 passed (`pytest.txt`) |
| Real PTY | PASS — 5 passed (`pty-test.txt`) |
| CLI parity | PASS — 33/18/15/6 (`cli-interface-parity.txt`) |
| Visual CLI | 14/14; allowed exit 1 only for existing live-provider proof (`visual-cli.txt`) |
| Evidence function | PASS — report + bench summary/path separation and panel behavior |
| Command/toast/card semantics | PASS — owned, distinct surfaces with effects retained |

## Remaining blocker order

Only TUI splash remains a zero-score function before the Reviewer. Iter-8 should implement the locked TUI-owned boot splash and its key skip/glow proofs. Iter-9/10 remain available for real-PTY activity/evidence and source-only home/header/prompt-export proof gaps.
