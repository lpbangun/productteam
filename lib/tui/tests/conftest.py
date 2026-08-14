# conftest.py — make lib/tui importable from pytest without lib/ becoming a
# package (lib/ is bash; there is deliberately no __init__.py anywhere).

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
