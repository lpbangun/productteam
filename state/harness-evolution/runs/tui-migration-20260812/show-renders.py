#!/usr/bin/env python3
"""Show the retained OpenTUI and Textual tmux captures side by side.

This is not a live TUI. Both prototype trees were deleted. The files under
frame-captures/ are the only remaining screens.
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
FRAMES = HERE / "frame-captures"
INSPECT = HERE / "evidence" / "opentui-solid" / "iter-1"
SIZES = ("120x36", "80x24", "60x24", "40x20")


def read_lines(path: Path) -> list[str]:
    if not path.is_file():
        raise SystemExit(f"missing capture: {path}")
    return path.read_text(encoding="utf-8").splitlines()


def pad(lines: list[str], width: int, height: int) -> list[str]:
    out = [line[:width].ljust(width) for line in lines[:height]]
    while len(out) < height:
        out.append(" " * width)
    return out


def side_by_side(left: list[str], right: list[str], left_title: str, right_title: str) -> str:
    left_w = max((len(line) for line in left), default=40)
    right_w = max((len(line) for line in right), default=40)
    height = max(len(left), len(right), 1)
    left_p = pad(left, left_w, height)
    right_p = pad(right, right_w, height)
    header = f"{left_title.ljust(left_w)} | {right_title}"
    rule = f"{'─' * left_w}─┼─{'─' * right_w}"
    rows = [f"{left_line} │ {right_line}" for left_line, right_line in zip(left_p, right_p)]
    return "\n".join([header, rule, *rows, rule])


def frames_for(size: str) -> tuple[Path, Path]:
    return (
        FRAMES / "opentui-solid" / f"{size}-base.txt",
        FRAMES / "textual-rich" / f"{size}-base.txt",
    )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--size", choices=SIZES, default="80x24", help="terminal size to compare")
    parser.add_argument("--all", action="store_true", help="print every size without pausing")
    args = parser.parse_args()
    sizes = SIZES if args.all else (args.size,)

    print("CAPTURES ONLY — live OpenTUI/Textual apps were deleted")
    print("Blank Textual rows are in the capture files, not a viewer bug.")
    print()

    for index, size in enumerate(sizes, start=1):
        left_path, right_path = frames_for(size)
        block = side_by_side(
            read_lines(left_path),
            read_lines(right_path),
            f"OpenTUI {size}",
            f"Textual {size}",
        )
        if sys.stdout.isatty() and not args.all:
            sys.stdout.write("\033[2J\033[H")
        print(f"[{index}/{len(sizes)}]")
        print(block)
        print()
        if not args.all:
            break

    inspect_base = INSPECT / "120x36-inspect-base.txt"
    if inspect_base.is_file() and args.all:
        print("OpenTUI extra inspect capture (no Textual equivalent)")
        print("\n".join(read_lines(inspect_base)))
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except KeyboardInterrupt:
        print()
        raise SystemExit(130)
