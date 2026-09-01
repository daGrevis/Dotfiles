#!/usr/bin/env python3

"""Clean a tmux selection on its way to the clipboard.

Three fixes, in this order:

1. Right-trim every line. TUI apps paint colored backgrounds by writing
   literal spaces with SGR attrs, because ECH/EL would erase the styling.
   tmux already drops those cells, because copy mode strips trailing ASCII
   spaces and only `capture-pane -N` keeps them. It does not strip U+00A0,
   which Claude Code writes after a prompt marker, so that one character
   outlives every yank and this step is what removes it.
2. Remove the indent that all lines share. Claude Code draws its output
   behind a 2-space gutter, and there is no setting for it
   (anthropics/claude-code#48768 asked for one and is closed). A shared
   indent carries no information, and relative indentation survives. The
   bullet that starts a message occupies that gutter instead of padding it,
   so it becomes two spaces first and the strip then takes it away.
3. Join the lines that the sender wrapped by hand. Claude Code measures the
   pane width and writes real newline characters at the wrap points, so tmux
   cannot tell a wrap from a paragraph break
   (anthropics/claude-code#42296 asked for soft wrap and is closed as not
   planned). Pass --no-reflow to keep every newline.

A line joins the line above it only when all of these hold:

- The line above ends near the widest line in the selection, and the first
  word of this line does not fit in the space that is left. That is the wrap
  test itself, so a paragraph that ends early stays on its own line.
- Both lines have the same indent, or the line above starts a list item and
  this line is indented to sit under its text. Wrapped text keeps its
  indent, and code changes it.
- The line does not start a list, a quote, a heading, or a table row.
- The line is not inside a fenced code block.
- The line above does not end with punctuation that belongs to code.

The joint gets a space, unless the widest line in the selection reaches the
pane width. Text that a program wrapped always breaks between words, and it
stops short of the last column. Text that the terminal wrapped can break
inside a word, and it always fills the last column.
"""

import os
import re
import subprocess
import sys

# The markers that Claude Code puts in front of a first line: a bullet on a
# message, a chevron on a prompt. Each one occupies the gutter that every
# other line pads with spaces, so the line reads as indent 0 and holds the
# shared indent at 0 for the whole selection. One space in place of the
# marker puts the line back in the same column as the rest, and the shared
# indent strip then removes all of it. An empty prompt is a marker and
# nothing after it, so the separator is optional. The separator is U+00A0
# on that empty prompt, so this runs before the right-trim.
MARKER = re.compile(r"^( *)[⏺❯](?=[ \xa0]|$)")

# A line that starts a new block never continues the line above it.
BLOCK_START = re.compile(r"^(?:[-*+>|#]|\d+[.)]\s)")

# A list item, so that its own wrapped lines can be recognised.
LIST_ITEM = re.compile(r"^(?:[-*+>]\s+|\d+[.)]\s+)")

# Punctuation that ends a line of code far more often than a wrapped
# sentence. Code that arrives without a fence, from a diff or a file, is the
# one case the wrap test alone gets wrong.
CODE_END = re.compile(r"[;:={}()\[\]<>]$")

# Below this width a selection is too short for the wrap test to mean
# anything, so leave it alone.
MIN_WIDTH = 40


def indent_of(line):
    return len(line) - len(line.lstrip(" "))


def pane_width():
    # Outside tmux there is no pane to ask about, and a bare display-message
    # would answer for whatever pane the default server has active.
    if not os.environ.get("TMUX"):
        return 0
    try:
        out = subprocess.run(
            ["tmux", "display-message", "-p", "#{pane_width}"],
            capture_output=True,
            text=True,
            timeout=2,
        )
        return int(out.stdout.strip())
    except (OSError, ValueError, subprocess.SubprocessError):
        return 0


def continues(above, line, limit):
    if not line.strip():
        return False
    if BLOCK_START.match(line.lstrip(" ")):
        return False
    if CODE_END.search(above):
        return False
    item = LIST_ITEM.match(above.lstrip(" "))
    wrapped_indent = indent_of(above) + (item.end() if item else 0)
    if indent_of(line) not in (indent_of(above), wrapped_indent):
        return False
    first_word = line.split()[0]
    return len(above) + 1 + len(first_word) > limit


def reflow(lines):
    widths = [len(line) for line in lines if line.strip()]
    limit = max(widths) if widths else 0
    if limit < MIN_WIDTH:
        return lines
    separator = "" if limit >= pane_width() > 0 else " "

    out = []
    above = None
    in_fence = False
    for line in lines:
        if line.lstrip(" ").startswith("```"):
            in_fence = not in_fence
            out.append(line)
            above = None
            continue
        if in_fence or above is None:
            out.append(line)
            above = line
            continue
        if continues(above, line, limit):
            out[-1] = out[-1] + separator + line.lstrip(" ")
        else:
            out.append(line)
        above = line
    return out


def main():
    data = sys.stdin.buffer.read().decode("utf-8", "replace")
    ends_with_newline = data.endswith("\n")
    lines = [MARKER.sub(r"\1 ", line) for line in data.split("\n")]
    lines = [line.rstrip() for line in lines]
    if ends_with_newline:
        lines.pop()

    indents = [indent_of(line) for line in lines if line.strip()]
    if indents:
        shared = min(indents)
        lines = [line[shared:] if line.strip() else line for line in lines]

    if "--no-reflow" not in sys.argv:
        lines = reflow(lines)

    out = "\n".join(lines)
    if ends_with_newline:
        out += "\n"
    sys.stdout.write(out)


main()
