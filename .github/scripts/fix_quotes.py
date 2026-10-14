#!/usr/bin/env python3
"""Remove the line break the converter writes right after [quote] and [spoiler]
(including forms with attributes, like [quote=Name] or [spoiler=Title]), which
Nexus renders as an empty first line inside notes and spoilers. Text inside
[code] blocks is left alone.

Usage: python fix_quotes.py nexus_bbcode.txt [-o out.txt]   (default: edit in place)
"""
import re
import sys
from pathlib import Path

CODE_RE = re.compile(r"\[code\].*?\[/code\]", re.S | re.I)
QUOTE_OPEN_RE = re.compile(r"(\[(?:quote|spoiler)(?:[= ][^\]]*)?\])[ \t]*\r?\n", re.I)


def fix(text):
    stash = []

    def hide(m):
        stash.append(m.group(0))
        return f"\x00C{len(stash) - 1}\x00"

    text = CODE_RE.sub(hide, text)
    text, n = QUOTE_OPEN_RE.subn(r"\1", text)
    for i in range(len(stash) - 1, -1, -1):
        text = text.replace(f"\x00C{i}\x00", stash[i])
    return text, n


def main():
    args = sys.argv[1:]
    if not args or args[0] in ("-h", "--help"):
        sys.exit(__doc__)
    src = Path(args[0])
    out = Path(args[args.index("-o") + 1]) if "-o" in args else src
    result, n = fix(src.read_text(encoding="utf-8"))
    out.write_text(result, encoding="utf-8", newline="")
    print(f"Removed {n} line break(s) after [quote]/[spoiler] in {out}", file=sys.stderr)


if __name__ == "__main__":
    main()