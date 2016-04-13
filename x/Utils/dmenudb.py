#!/usr/bin/env python
import re
from sys import argv
from os.path import expanduser

DB_FILEPATH = expanduser("~") + "/tmp/dmenudb"

try:
    new_phrase = argv[1]
except IndexError:
    with open(DB_FILEPATH) as f:
        print(f.read(), end="")
        exit(0)

if not new_phrase:
    print("Empty phrase, ignoring for convenience")
    exit(1)

try:
    with open(DB_FILEPATH) as f:
        lines = f.readlines()
except FileNotFoundError:
    lines = []

split_pattern = re.compile(r"\s+")
phrase_exists = False
entries = []
for line in lines:
    freq, phrase = re.split(split_pattern, line, maxsplit=1)
    freq = int(freq)
    phrase = phrase.rstrip()

    if phrase == new_phrase:
        freq += 1
        phrase_exists = True

    entries.append([freq, phrase])

entries = sorted(entries, reverse=True)

if not phrase_exists:
    entries.append([0, new_phrase])

max_pad = len(str(max([freq for freq, _ in entries]))) + 1
lines_back = []
for freq, phrase in entries:
    pad_count = max_pad - len(str(freq))

    lines_back.append(
        str(freq) + (" " * pad_count) + phrase,
    )

db_blob = "\n".join(lines_back) + "\n"
with open(DB_FILEPATH, "w+") as f:
    f.write(db_blob)
