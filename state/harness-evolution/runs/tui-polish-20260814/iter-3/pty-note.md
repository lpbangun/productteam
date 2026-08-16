# PTY note — iteration 3

`lib/tui/.venv/bin/python -m pytest lib/tui/tests/test_pty.py -q` → **3 passed** (`pty-test.txt`). The same three PTY tests also pass inside the full native run (`pytest.txt`: 36 passed).

- Burst `/status\r` now reaches Composer while the slash OptionList is visible and streams real `Product Consulting Harness` output.
- `/gate\r` then refuses with registry reason/usage and does not spawn gate.
- Provider interrupt still preserves the partial artifact, records worker `failed`, and exits 130 on the second Ctrl+C.
- Typed `@Builder` still records Builder/done/mission in `workers.tsv`.

Product fix: `_refresh_dock` refocuses Composer after making/updating the OptionList; `_close_dock` refocuses Composer after hiding it. Composer remains the only Enter/Tab/arrow slash-routing path; no duplicate option-selected route.

Still absent: live `80→40→80` resize, activity-vs-speech, structured ask, confirm, evidence panel, and TUI splash.
