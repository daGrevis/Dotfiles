# Renders a logo image as quadrant block characters in 24-bit color, into one
# file for each terminal width from 25 to 80 columns.
#
# Usage: render.py IMAGE MODE PREFIX COLOR...
#
# The file for a width is PREFIX-WIDTH.txt. The logo in it is 4 columns
# narrower than the width, for an indent of 2 columns and a margin of 2 columns
# on the right, and it has an empty line on the top and bottom. Each cell gets
# the COLOR that most of its subpixels are nearest to. With MODE "rows", each
# row gets one color, for logos with horizontal stripes. With MODE "cells",
# each cell gets its own color. A subpixel is on when the logo covers at least
# half of it.

import sys
from PIL import Image

path, mode, prefix = sys.argv[1], sys.argv[2], sys.argv[3]
palette = [tuple(int(h[i:i + 2], 16) for i in (0, 2, 4)) for h in sys.argv[4:]]
glyphs = " ▘▝▀▖▌▞▛▗▚▐▜▄▙▟█"

img = Image.open(path).convert("RGBA")
img = img.crop(img.getbbox())
w, h = img.size


def nearest(r, g, b):
    return min(range(len(palette)), key=lambda i: sum((c - p) ** 2 for c, p in zip((r, g, b), palette[i])))


def render(cols):
    # A cell is about twice as tall as it is wide, and it has 2x2 subpixels, so
    # a subpixel is square when the image is scaled to cols*2 x rows*2 with
    # rows = h / w * cols / 2. BOX gives each subpixel the average of the area
    # that it covers, so its alpha is the part that the logo covers.
    rows = round(h / w * cols / 2)
    px = img.resize((cols * 2, rows * 2), Image.BOX).load()
    out = []
    for row in range(rows):
        masks, votes = [], []
        for col in range(cols):
            mask, v = 0, [0] * len(palette)
            for bit, (dx, dy) in enumerate([(0, 0), (1, 0), (0, 1), (1, 1)]):
                r, g, b, a = px[col * 2 + dx, row * 2 + dy]
                if a >= 128:
                    mask |= 1 << bit
                    v[nearest(r, g, b)] += 1
            masks.append(mask)
            votes.append(v)
        if mode == "rows":
            total = [sum(v[i] for v in votes) for i in range(len(palette))]
            row_color = total.index(max(total))
        line, cur = "  ", None
        for mask, v in zip(masks, votes):
            if mask:
                c = row_color if mode == "rows" else v.index(max(v))
                if c != cur:
                    line += "\033[38;2;%d;%d;%dm" % palette[c]
                    cur = c
            line += glyphs[mask]
        out.append(line.rstrip())
    out[-1] += "\033[0m"
    # The margin on the left and right is 2 columns. A cell is about twice as
    # tall as it is wide, so 1 empty line on the top and bottom gives the same
    # margin.
    return "\n".join([""] + out + [""]) + "\n"


for width in range(25, 81):
    with open(f"{prefix}-{width}.txt", "w") as f:
        f.write(render(width - 4))
