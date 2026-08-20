# __main__.py — `productteam tui` entry point.
#
# Non-TTY stdin or stdout → exit 2, stderr names the TTY remedy, stdout stays
# empty. NO_COLOR is honored natively by Textual (it pops NO_COLOR and applies
# a monochrome filter); nothing extra is needed on the Python side.

from __future__ import annotations

import sys


def main() -> None:
    if not sys.stdin.isatty() or not sys.stdout.isatty():
        print("productteam tui requires an interactive TTY", file=sys.stderr)
        raise SystemExit(2)
    from app import ProductTeamApp

    app = ProductTeamApp()
    raise SystemExit(app.run())


if __name__ == "__main__":
    main()
