# PTY note — iteration 8

Principal acceptance exported `CONSULT_NO_SPLASH=1` as required for non-splash freeze rows.

- Full native suite: **67 passed** (`pytest.txt`), including 15 behavioral splash tests with the env explicitly removed.
- Existing real PTY suite: **5 passed** (`pty-test.txt`): status/gate, interrupt, Builder role/card, confirm cancel/composer, SIGWINCH.
- Splash native tests inspect the displayed `#splash` widget and prove exact 39/35-column ASCII, neutral idle, one-at-a-time OK glow Principal→Analyst→Builder→Principal, natural finish, composer/footer/@Principal visibility, any-key skip including Ctrl+C/Ctrl+Q/Ctrl+P, no submit/dock/spawn, 40x20 non-cover, once-only resize behavior, env bypass, and `/splash` CLI separation.
- Existing non-TTY tests remain in the 67: exit 2, empty stdout, required stderr, no ESC under NO_COLOR.

A dedicated live-PTY splash frame remains a 10-band proof opportunity for iter-9; the function itself is implemented and behaviorally exercised through Textual's native application runtime.
