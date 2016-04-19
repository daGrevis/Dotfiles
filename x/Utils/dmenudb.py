#!/usr/bin/env python
import re
from sys import argv
from os.path import expanduser


DB_FILEPATH = expanduser("~") + "/tmp/dmenudb"


def main():
    try:
        argv[1]
        is_insert = True
    except IndexError:
        is_insert = False

    if is_insert and argv[1] == "":
        print("Empty phrase, ignoring for convenience")
        exit(0)

    lines = read_db()

    if not is_insert:
        entries = parse_lines(lines)
        new_lines = unparse_entries(sort_entries(entries))
        output = "".join(new_lines)

        print(output, end="")

        if lines != new_lines:
            write_db(output)
    else:
        new_phrase = " ".join(argv[1:])

        entries = parse_lines(lines)
        entries = insert_entry(new_phrase, entries)
        new_lines = unparse_entries(sort_entries(entries))
        output = "".join(new_lines)

        write_db(output)

    exit(0)


def read_db(filepath=DB_FILEPATH):
    try:
        with open(filepath) as f:
            lines = f.readlines()
    except FileNotFoundError:
        lines = []

    return lines


def write_db(output, filepath=DB_FILEPATH):
    with open(DB_FILEPATH, "w+") as f:
        f.write(output)


def parse_lines(lines):
    if not lines:
        return []

    split_pattern = re.compile(r"\s+")
    entries = []
    for line in lines:
        freq, phrase = re.split(split_pattern, line, maxsplit=1)
        freq = int(freq)
        phrase = phrase.rstrip()

        entries.append([freq, phrase])

    return entries


def unparse_entries(entries):
    max_pad = len(str(max([freq for freq, _ in entries]))) + 1
    lines = []
    for freq, phrase in entries:
        pad_count = max_pad - len(str(freq))

        lines.append(
            str(freq) + (" " * pad_count) + phrase + "\n",
        )

    return lines


def insert_entry(new_phrase, entries):
    index_found = False
    for i, (freq, phrase) in enumerate(entries):
        if phrase == new_phrase:
            index_found = True
            break

    if index_found:
        entry = [freq + 1, phrase]
        entries[i] = entry
    else:
        entry = [0, new_phrase]
        entries.append(entry)

    return entries


def sort_entries(entries):
    return sorted(entries, reverse=True)


main()
