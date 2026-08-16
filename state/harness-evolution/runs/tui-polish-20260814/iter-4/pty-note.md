# PTY note — iteration 4

Full native run: **4 failed, 35 passed** (`pytest.txt`). All four failures are real-PTY rows:

- `/status` rendered the command title but did not expose the later `harness-cli` engagement needle.
- Provider interrupt never rendered `partial analysis begins` before timeout.
- Typed `@Builder` never rendered `builder analysis complete` before timeout.
- New SIGWINCH test did not find its overly contiguous raw-PTY wide-header needle `▣─▣─▣ ProductTeam`.

Source inspection identifies one product regression: `_provider_thread` drains the artifact only once before blocking on `proc.wait()`. A slow provider therefore cannot stream later bytes. Restore repeated drain while the process is alive; do not wait for process exit before presenting speech.

The SIGWINCH test must inspect an ANSI-normalized screen/delta or equivalent observable chrome, because Textual may insert terminal styling/control sequences between differently styled header glyphs. It must still prove compact `ProductTeam {score}`, no heads/cwd at 40, composer visible, and restored heads at 80.

Activity/footer/static resize tests pass in `test_layout.py` (12 passed), but iter-4 is not accepted while native pytest is red.
