#!/usr/bin/env python3
"""Prepare a GitHub README for the Markdown -> Nexus BBCode converter.

What it does (outside of code blocks / inline code):
  * removes HTML anchors without an href, e.g. <a id="foo"></a>
    (keeps any text that was inside them)
  * turns in-page links into plain text:
        [Binding](#binding)          -> Binding
        <a href="#binding">Binding</a> -> Binding
  * rewrites relative image paths (Markdown and <img src>) to raw URLs in
    the repo, e.g. images/a.png -> https://raw.githubusercontent.com/OWNER/REPO/BRANCH/images/a.png
  * <!-- nocolor --> / <!-- /nocolor --> comments become literal [nocolor] /
    [/nocolor] tags; colorize_bbcode.py leaves bold text between them uncolored
    and removes the tags
  * with --toc-spoiler: wraps the 'Table of contents' section in <details>
    so it becomes a spoiler on Nexus

Usage:
    python strip_for_nexus.py README.md \
        --raw-base https://raw.githubusercontent.com/OWNER/REPO/BRANCH/ \
        --toc-spoiler -o README_nexus.md

Then run the converter on the result:
    markdown_to_bbcodenm -i README_nexus.md -o bbcode.txt
"""
import argparse
import posixpath
import re
import sys
from pathlib import Path
from urllib.parse import quote

FENCE_RE = re.compile(r"^(```|~~~).*?^\1[ \t]*$", re.M | re.S)
INLINE_CODE_RE = re.compile(r"(?<!`)(`+)(?!`)(.+?)(?<!`)\1(?!`)", re.S)

# <a ...> tags that have no href (anchors like <a id="x"></a> / <a name="x">)
ANCHOR_LINE_RE = re.compile(
    r"^[ \t]*<a\s+(?![^>]*\bhref\b)[^>]*>\s*</a>[ \t]*\r?\n", re.M | re.I
)
ANCHOR_RE = re.compile(r"<a\s+(?![^>]*\bhref\b)[^>]*>(.*?)</a>", re.S | re.I)

# <a href="#something">text</a>
HTML_INPAGE_RE = re.compile(
    r"<a\s+[^>]*\bhref\s*=\s*[\"']#[^\"']*[\"'][^>]*>(.*?)</a>", re.S | re.I
)

# [text](#something)  (not images)
MD_INPAGE_RE = re.compile(r"(?<!!)\[([^\]]*)\]\(\s*#[^)]*\)")

# ![alt](path "optional title")
MD_IMG_RE = re.compile(
    r'(!\[[^\]]*\]\()\s*(?:<([^>]+)>|([^)\s]+))(\s+"[^"]*")?\s*(\))'
)

# <img ... src="path" ...>
HTML_IMG_RE = re.compile(
    r"(<img\b[^>]*?\bsrc\s*=\s*)([\"'])([^\"']+)\2", re.I | re.S
)

ABSOLUTE_RE = re.compile(r"^([a-z][a-z0-9+.\-]*:|//)", re.I)


def make_raw_url(path: str, base: str) -> str:
    """Turn a repo-relative path into a raw URL; leave absolute URLs alone."""
    if ABSOLUTE_RE.match(path):
        return path
    clean = path.lstrip("/")
    clean = posixpath.normpath(clean)
    if clean.startswith(".."):
        return path  # points outside the repo, leave it
    # '%' is kept safe so already-encoded paths aren't double-encoded
    return base.rstrip("/") + "/" + quote(clean, safe="/%")


def transform(text: str, base: str, stats: dict) -> str:
    def count(key):
        def repl_wrapper(fn):
            def inner(m):
                stats[key] += 1
                return fn(m)

            return inner

        return repl_wrapper

    text = ANCHOR_LINE_RE.sub(lambda m: (stats.__setitem__("anchors", stats["anchors"] + 1) or ""), text)
    text = ANCHOR_RE.sub(count("anchors")(lambda m: m.group(1)), text)
    text = HTML_INPAGE_RE.sub(count("inpage")(lambda m: m.group(1)), text)
    text = MD_INPAGE_RE.sub(count("inpage")(lambda m: m.group(1)), text)

    def md_img(m):
        path = m.group(2) or m.group(3)  # <path with spaces> or plain path
        new = make_raw_url(path, base)
        if new != path:
            stats["images"] += 1
        return f"{m.group(1)}{new}{m.group(4) or ''}{m.group(5)}"

    def html_img(m):
        new = make_raw_url(m.group(3), base)
        if new != m.group(3):
            stats["images"] += 1
        return f"{m.group(1)}{m.group(2)}{new}{m.group(2)}"

    text = MD_IMG_RE.sub(md_img, text)
    text = HTML_IMG_RE.sub(html_img, text)
    return text


NOCOLOR_COMMENT_RE = re.compile(r"<!--\s*(/?)nocolor\s*-->", re.I)


def convert_nocolor(text: str, stats: dict) -> str:
    """Turn <!-- nocolor --> / <!-- /nocolor --> comments into literal [nocolor] /
    [/nocolor] tags. The converter passes literal BBCode-like text through as-is;
    colorize_bbcode.py then leaves bold text between the tags uncolored and
    removes the tags."""

    def repl(m):
        if m.group(1):
            return "[/nocolor]"
        stats["nocolor"] += 1
        return "[nocolor]"

    return NOCOLOR_COMMENT_RE.sub(repl, text)


TOC_RE = re.compile(
    r"^#{1,6}[ \t]+(?:table of contents|contents|toc)[ \t]*\r?\n(.*?)(?=^#{1,6}[ \t]|\Z)",
    re.M | re.S | re.I,
)


def wrap_toc(text: str, stats: dict) -> str:
    """Replace the 'Table of contents' heading + its list with a collapsible
    <details> block (the converter turns <details> into a Nexus [spoiler])."""

    def repl(m):
        stats["toc"] += 1
        body = m.group(1).strip("\r\n")
        return (
            "<details>\n<summary>Table of contents</summary>\n\n"
            + body
            + "\n\n</details>\n\n"
        )

    return TOC_RE.sub(repl, text, count=1)


def process(text: str, base: str, toc_spoiler: bool = False):
    stats = {"anchors": 0, "inpage": 0, "images": 0, "toc": 0, "nocolor": 0}
    text = text.replace("\r\n", "\n").replace("\r", "\n")
    protected = []

    def stash(m):
        protected.append(m.group(0))
        return f"\x00PROTECTED{len(protected) - 1}\x00"

    # Hide fenced code blocks and inline code so they are never modified
    text = FENCE_RE.sub(stash, text)
    text = INLINE_CODE_RE.sub(stash, text)

    text = transform(text, base, stats)
    text = convert_nocolor(text, stats)
    if toc_spoiler:
        text = wrap_toc(text, stats)

    # Restore (inline code may have been stashed inside nothing else, but loop
    # anyway in case of nesting order)
    for i in range(len(protected) - 1, -1, -1):
        text = text.replace(f"\x00PROTECTED{i}\x00", protected[i])
    return text, stats


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("input", help="path to the README.md")
    ap.add_argument(
        "--raw-base",
        required=True,
        help="raw URL of the repo root, e.g. https://raw.githubusercontent.com/OWNER/REPO/BRANCH/",
    )
    ap.add_argument(
        "--toc-spoiler",
        action="store_true",
        help="wrap the 'Table of contents' section in a collapsible block (becomes a Nexus [spoiler])",
    )
    ap.add_argument("-o", "--output", help="output file (default: <input>_nexus.md, '-' for stdout)")
    args = ap.parse_args()

    src = Path(args.input)
    text = src.read_text(encoding="utf-8")
    result, stats = process(text, args.raw_base, args.toc_spoiler)

    if args.output == "-":
        sys.stdout.write(result)
    else:
        out = Path(args.output) if args.output else src.with_name(src.stem + "_nexus" + src.suffix)
        out.write_text(result, encoding="utf-8", newline="")
        print(f"Wrote {out}", file=sys.stderr)

    print(
        f"Removed {stats['anchors']} anchor(s), unlinked {stats['inpage']} in-page link(s), "
        f"rewrote {stats['images']} image path(s)"
        + (", spoilered the table of contents" if stats["toc"] else "")
        + (f", converted {stats['nocolor']} nocolor region(s) to [nocolor] tags." if stats["nocolor"] else "."),
        file=sys.stderr,
    )


if __name__ == "__main__":
    main()