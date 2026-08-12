# Framework evidence comparison

Date: 2026-08-12. Both spikes consumed the same live boundary: `productteam status --json`, `help --json`, `agents --json`, engagement `inspect-pack.json`, and `state/.cli/runs/session-*/workers.tsv`. Neither wrote state or invoked a provider.

| Measure | Existing Bash CLI/REPL | Ink 7.1.1 spike | OpenTUI 0.5.1 spike |
|---|---:|---:|---:|
| Interactive/source lines measured | `lib/repl.sh` 504 + registry 122 | 1,417 source + 837 tests | 1,130 source + 593 tests |
| Runtime package tree | 0 framework packages | 39 installed nodes | 14 installed nodes |
| Installed dependency size | 0 | 22,860 KiB | 81,468 KiB |
| Measured live-data snapshot | `status --json`: 0.26 s, 7,552 KiB max RSS | 3.35 s, 254,860 KiB | 2.92 s, 253,716 KiB |
| Runtime floor | Bash + documented CLI tools | Node >=22 | Bun, or Node >=26.4 with experimental FFI for live renderer |
| Package size metadata | n/a | npm unpacked package 556,730 bytes | npm unpacked core 13,056,185 bytes plus platform-native package |
| Focused tests | frozen parity + smoke + visual | 35/35 | 31/31 |
| Interactive launch here | canonical chat passed real agent cycle | Node 22 PTY launched; filter input and Ctrl+C exit passed | Node 22 launch refused; Bun PTY launched; filter input and Ctrl+C exit passed |

## Behavioral comparison

| Criterion | Bash | Ink | OpenTUI |
|---|---|---|---|
| Canonical automation | Native one-shot interface | Preserved; adapter only | Preserved; adapter only |
| Durable state authority | Plain files | Same files, read-only | Same files, read-only |
| Header/evidence/activity/palette | Existing chat chrome; no panes | Representative fixed panes, transient selection, scroll/focus | Representative header, ScrollBox, activity, Input/Select palette |
| Running/completed/failed/interrupted | Real worker TSV; Ctrl+C records failed + preserves partial artifact | Reads real TSV; interrupted is explicitly represented as “recorded as failed/130,” not fabricated | Reads real TSV; renderer supports all labels, but canonical interruption remains failed/130 |
| Resize/narrow width | Visual contract and truncation primitives pass | Tests pass at 30/40/60/80 columns | Tests pass at 20/40 columns |
| Unicode width/wrapping | Existing visual suite passes current contract | CJK/double-width tests pass | CJK/combining/ZWJ/emoji tests pass |
| Multiline input | Not provided | Not implemented by spike | Not implemented by spike |
| Scrolling/focus/keymap | Readline command input; no pane focus | Implemented for bounded evidence/activity/palette | Implemented with OpenTUI controls |
| Streaming output | Real provider output/artifact lifecycle in Bash REPL | No provider execution or streaming; read-only snapshot/reload | No provider execution or streaming; read-only snapshot |
| Signal/subprocess ownership | Real provider process-group kill/reap proven by visual suite | Owns no provider child; Ctrl+C exits cleanly | Owns no provider child; Ctrl+C exits cleanly under Bun |
| NO_COLOR/non-TTY/CI | Frozen parity and visual suite pass | ANSI-free snapshot; non-TTY interactive refusal tested | ANSI-free snapshot; non-TTY interactive refusal tested |
| Accessibility/screen reader | Plain redirected output remains available | No framework screen-reader contract demonstrated | No framework screen-reader contract demonstrated |
| Packaging | Existing shell distribution | Adds Node 22, React, Ink, 39-package tree | Adds Bun or experimental Node FFI and native binaries for Darwin/Linux/Windows variants |
| API/maturity evidence | Repository-owned stable surface | Current npm 7.1.1; modified 2026-07-16 | Current npm 0.5.1; modified 2026-08-12; pre-1.0 and native FFI runtime constraint |
| Net deletion if retained now | n/a | 0 replaceable Bash lines deleted; >1,400 source lines added | 0 replaceable Bash lines deleted; >1,100 source lines added |

## Evidence

- `evidence/ink-tests.txt`: 35/35.
- `evidence/opentui-tests.txt`: 31/31.
- `evidence/ink-snapshot.txt`, `evidence/opentui-snapshot.txt`: live canonical data, redirected output.
- `evidence/live-chat-cycle.typescript`: real authenticated `agent` runtime through the retained Bash path.
- `evidence/visual-final.json`: 14/14 plus live provider proof.
- Runtime metadata: `npm view ink@7.1.1 ...`; `npm view @opentui/core@0.5.1 ...`; installed-tree measurements taken before cleanup.

## Gate result

Neither framework earns retention:

1. Existing visual behavior is 14/14 and the repaired parity contract passes. No recurring repaint, Unicode, scrolling, multiline, or streaming defect was demonstrated.
2. Both preserve the canonical CLI and plain-file authority, but neither spike implements multiline editing or provider streaming.
3. Ink adds a Node 22 floor, 39 package nodes, about 22.3 MiB installed, >1,400 source lines, and roughly 3.35 s live-data snapshot startup.
4. OpenTUI adds native platform packaging, about 79.6 MiB installed here, >1,100 source lines, and cannot launch its live renderer on the repository’s Node 22 runtime; Bun works.
5. Neither deletes any replaceable Bash UI code. Both miss the required 25–30% net deletion by the full margin.
6. No screen-reader evidence exists for either interactive renderer; only their non-TTY snapshots remain accessible as plain text.

Decision: **not yet**. Delete both prototype trees and dependencies. Retain the repaired Bash CLI/REPL. Reconsider only after measured recurring defects or user tasks require multiline editing, large scrollback panes, focus/keymap state, or rich streaming, and a candidate proves signal ownership plus at least 25–30% net deletion after adapters/tests.
