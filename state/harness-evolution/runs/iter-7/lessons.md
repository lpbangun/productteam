# Lessons — iter 7

- A continuously repainting PTY can starve a naive `select()` drain loop. Bound drains by wall-clock time before using them as interaction probes.
- Interrupt honesty needs process-tree evidence, not only a message. Record both provider and child PIDs, assert both dead, preserve artifact bytes, and keep the prompt alive.
- Bash job control (`set -m` around the background turn) supplies an isolated process group without adding `setsid` as a runtime dependency.
- A command palette needs one verb source shared by `/help`, matching, and dispatch tests; prose containing slash paths can pollute naive command extraction.
- Exported transcripts should contain the same timestamped turn separators users see, not a reconstructed approximation.
- Run the full dependency-policy suite after targeted visual convergence; visual checks alone cannot detect a new executable dependency.
