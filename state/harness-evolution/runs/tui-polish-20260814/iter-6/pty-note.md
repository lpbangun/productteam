# PTY note — iteration 6

`lib/tui/.venv/bin/python -m pytest lib/tui/tests/test_pty.py -q` → **5 passed** (`pty-test.txt`). Full native suite: **47 passed** (`pytest.txt`).

- Existing real PTY status/gate, provider interrupt, typed Builder role, and SIGWINCH 80→40→80 remain green.
- New real PTY confirmation path types `/gh merge`, renders `Run /gh merge`, `Cancel`, and `↑↓ choose · enter run · esc cancel` above a visible `@Principal` composer; Esc closes without executing and restores idle footer; `/exit` returns 0.
- Native recorder tests prove Cancel/Esc leaves the argv log empty and Run preserves exact argv for all three locked writes. `/gh preflight` remains unintercepted and `/gate` remains no-spawn.
- A discovered live defect was repaired: the auto-width `#role-prefix` previously consumed the Horizontal and left the composer effectively off-screen. It is now bounded to width 12; native tests prove composer width >=20 at 40 and 80 columns in idle/slash/ask/confirm, and the real PTY visibly echoes typed composer text.

Ask is file-backed and native-proven through canonical single/multi fixtures beside the active artifact; no provider mock or prose scraping is used.
