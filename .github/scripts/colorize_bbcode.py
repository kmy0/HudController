#!/usr/bin/env python3
"""Recolor headings and bold text in BBCode produced by markdown_to_bbcodenm.

The converter writes headings as [size=N]...[/size] and bold as [b]...[/b].
This wraps their contents in [color=...]:

    [size=5]Title[/size]  ->  [size=5][color=#E8A33D]Title[/color][/size]
    [b]word[/b]           ->  [b][color=#7FB3FF]word[/color][/b]

Anything inside [code]...[/code] is left alone, and bold text that is inside
a heading is not colored a second time. Bold text between [nocolor] and
[/nocolor] is left uncolored (strip_for_nexus.py writes those tags from the
<!-- nocolor --> ... <!-- /nocolor --> comments in the README); the tags
themselves are removed from the output.

Usage:
    python colorize_bbcode.py nexus_bbcode.txt -o nexus_bbcode_colored.txt \
        --header-color "#E8A33D" --bold-color "#7FB3FF"

Optional:
    --size-color 6=#FF5555 --size-color 5=#E8A33D   per-heading-size colors
    --header-sizes 4,5,6                            only recolor these sizes
"""
import argparse
import re
import sys
from pathlib import Path

CODE_RE = re.compile(r"\[code\].*?\[/code\]", re.S | re.I)
SIZE_RE = re.compile(r"\[size=(\d+)\](.*?)\[/size\]", re.S | re.I)
# bold open/close tokens; the close may be [/b] or the [\b] typo some converter docs show
BOLD_TOKEN_RE = re.compile(r"\[b\]|\[[/\\]b\]", re.I)
HAS_COLOR_RE = re.compile(r"^\s*\[color=", re.I)
# Literal [nocolor]...[/nocolor] region tags (the converter passes literal BBCode-like
# text through as-is). A tag alone on its line is removed together with its line
# break; backslash escapes are tolerated in case the brackets get escaped.
NC_OPEN = r"\\?\[nocolor\\?\]"
NC_CLOSE = r"\\?\[\\?/nocolor\\?\]"
NC_OPEN_LINE_RE = re.compile(rf"^[ \t]*{NC_OPEN}[ \t]*\n?", re.M | re.I)
NC_CLOSE_LINE_RE = re.compile(rf"^[ \t]*{NC_CLOSE}[ \t]*\n?", re.M | re.I)
NC_OPEN_RE = re.compile(NC_OPEN, re.I)
NC_CLOSE_RE = re.compile(NC_CLOSE, re.I)
NC_REGION_RE = re.compile("\x01(.*?)\x02", re.S)


def map_outer_bold(text, fn):
    """Call fn(inner, original) for every OUTERMOST [b]...[/b] span and splice the
    result in. Nested bold (the converter turns inline code into [b]) stays inside
    its parent, so tags are never mis-paired. Unbalanced tags are left untouched."""
    out, pos, depth, start, inner_start = [], 0, 0, 0, 0
    for m in BOLD_TOKEN_RE.finditer(text):
        if m.group(0).lower() == "[b]":
            if depth == 0:
                start, inner_start = m.start(), m.end()
            depth += 1
        elif depth:
            depth -= 1
            if depth == 0:
                out.append(text[pos:start])
                out.append(fn(text[inner_start:m.start()], text[start:m.end()]))
                pos = m.end()
    out.append(text[pos:])
    return "".join(out)


def colorize(text, header_color, bold_color, size_colors, header_sizes):
    stats = {"headers": 0, "bold": 0, "regions": 0, "unbalanced": 0}
    stash = []

    def hide(s):
        stash.append(s)
        return f"\x00STASH{len(stash) - 1}\x00"

    # 1. protect code blocks
    text = CODE_RE.sub(lambda m: hide(m.group(0)), text)

    # 2. headings: color them, then hide so the bold pass skips them
    def heading(m):
        size = int(m.group(1))
        inner = m.group(2)
        color = size_colors.get(size, header_color)
        if color is None or size not in header_sizes or HAS_COLOR_RE.match(inner):
            return hide(m.group(0))
        stats["headers"] += 1
        return hide(f"[size={size}][color={color}]{inner}[/color][/size]")

    text = SIZE_RE.sub(heading, text)

    # 2b. [nocolor]...[/nocolor] regions: hide their contents (tags are dropped) so
    # the bold pass below never sees them
    text = NC_OPEN_LINE_RE.sub("\x01", text)
    text = NC_CLOSE_LINE_RE.sub("\x02", text)
    text = NC_OPEN_RE.sub("\x01", text)
    text = NC_CLOSE_RE.sub("\x02", text)

    def region(m):
        stats["regions"] += 1
        return hide(m.group(1))

    text = NC_REGION_RE.sub(region, text)
    stats["unbalanced"] = text.count("\x01") + text.count("\x02")
    text = text.replace("\x01", "").replace("\x02", "")

    # 3. bold text
    def bold(inner, original):
        if bold_color is None or not inner.strip() or HAS_COLOR_RE.match(inner):
            return original
        stats["bold"] += 1
        return f"[b][color={bold_color}]{inner}[/color][/b]"

    text = map_outer_bold(text, bold)

    # 4. restore (later stashes can contain earlier placeholders, so go backwards)
    for i in range(len(stash) - 1, -1, -1):
        text = text.replace(f"\x00STASH{i}\x00", stash[i])
    return text, stats


TAG_RE = re.compile(
    r"\[([/\\])?(b|i|u|s|color|size|url|list|quote|spoiler|center|right|left)(?:[= ][^\]]*)?\]",
    re.I,
)


def find_tag_problem(text):
    """Return a description of the first misnested/unclosed BBCode tag, or None.
    Read-only check used for warnings; code blocks are ignored."""
    text = CODE_RE.sub(lambda m: "\n" * m.group(0).count("\n"), text)
    stack = []
    for m in TAG_RE.finditer(text):
        name = m.group(2).lower()
        line = text.count("\n", 0, m.start()) + 1
        if not m.group(1):
            stack.append((name, line))
            continue
        if not stack:
            return f"line {line}: [/{name}] closes but nothing is open"
        top, top_line = stack[-1]
        if top != name:
            return f"line {line}: [/{name}] closes while [{top}] (opened on line {top_line}) is still open"
        stack.pop()
    if stack:
        name, line = stack[-1]
        return f"[{name}] opened on line {line} is never closed"
    return None


def main():
    ap = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    ap.add_argument("input", help="BBCode file written by markdown_to_bbcodenm")
    ap.add_argument("-o", "--output", help="output file (default: overwrite nothing, write <input>_colored.txt; '-' = stdout)")
    ap.add_argument("--header-color", help='color for all headings, e.g. "#E8A33D" or orange')
    ap.add_argument("--bold-color", help='color for bold text, e.g. "#7FB3FF"')
    ap.add_argument(
        "--size-color",
        action="append",
        default=[],
        metavar="N=COLOR",
        help="color for one heading size (1-6); overrides --header-color. Repeatable.",
    )
    ap.add_argument(
        "--header-sizes",
        default="1,2,3,4,5,6",
        help="comma-separated [size=N] values treated as headings (default: all)",
    )
    args = ap.parse_args()

    size_colors = {}
    for item in args.size_color:
        n, _, c = item.partition("=")
        if not n.strip().isdigit() or not c:
            ap.error(f"bad --size-color value: {item!r} (expected N=COLOR)")
        size_colors[int(n)] = c.strip()

    header_sizes = {int(x) for x in args.header_sizes.split(",") if x.strip()}

    if not (args.header_color or args.bold_color or size_colors):
        ap.error("give at least one of --header-color, --bold-color, --size-color")

    src = Path(args.input)
    text = src.read_text(encoding="utf-8")
    result, stats = colorize(text, args.header_color, args.bold_color, size_colors, header_sizes)

    if args.output == "-":
        sys.stdout.write(result)
    else:
        out = Path(args.output) if args.output else src.with_name(src.stem + "_colored" + src.suffix)
        out.write_text(result, encoding="utf-8", newline="")
        print(f"Wrote {out}", file=sys.stderr)

    print(
        f"Colored {stats['headers']} heading(s) and {stats['bold']} bold span(s); "
        f"left {stats['regions']} [nocolor] region(s) uncolored.",
        file=sys.stderr,
    )
    if stats["unbalanced"]:
        print(
            f"Warning: {stats['unbalanced']} unmatched [nocolor] / [/nocolor] tag(s) were removed; "
            "each opening tag needs a closing one.",
            file=sys.stderr,
        )
    before, after = find_tag_problem(text), find_tag_problem(result)
    if after and not before:
        print(f"Warning: the recolored output has a tag problem: {after}", file=sys.stderr)
    elif after:
        print(f"Note: the converter output already had a tag problem: {after}", file=sys.stderr)


if __name__ == "__main__":
    main()