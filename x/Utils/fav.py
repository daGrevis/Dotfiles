#!/usr/bin/env python
import argparse
import re
from os import environ as env


def main():
    args = get_args()

    is_insert = args.subparser_name == "insert"
    is_ls = args.subparser_name == "ls"

    if is_insert and not args.phrase:
        print("Empty phrase, ignoring")
        exit(0)

    db_filepath = env.get("FAVFILE", "default.fav")

    lines = read_db(db_filepath)

    if is_ls:
        if not lines:
            output = ""
            write_db(output, db_filepath)
            exit(0)

        entries = sort(parse(lines))
        new_lines = unparse(entries)
        output = "".join(new_lines)

        if args.only_phrases:
            phrases = [phrase for freq, phrase in entries]
            print("\n".join(phrases))
        else:
            print(output, end="")

        if lines != new_lines:
            write_db(output, db_filepath)

        exit(0)
    elif is_insert:
        entries = parse(lines)
        entries = insert_entry(args.phrase, entries)
        entries = sort(entries)
        new_lines = unparse(sort(entries))
        output = "".join(new_lines)

        write_db(output, db_filepath)
        exit(0)


def get_args():
    arg_parser = argparse.ArgumentParser(
        description="Manage a list of most frequently used phrases",
    )
    arg_subparsers = arg_parser.add_subparsers(dest="subparser_name")

    ls_parser = arg_subparsers.add_parser("ls", help="list phrases sorted by frequency")
    ls_parser.add_argument("--only-phrases", action="store_true", help="do not show frequencies")

    insert_parser = arg_subparsers.add_parser("insert", help="insert phrase")
    insert_parser.add_argument("phrase", nargs="?")

    args = arg_parser.parse_args()

    return args


def read_db(filepath):
    try:
        with open(filepath) as f:
            lines = f.readlines()
    except FileNotFoundError:
        lines = []

    return lines


def write_db(output, filepath):
    with open(filepath, "w+") as f:
        f.write(output)


def parse(lines):
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


def unparse(entries):
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


def sort(entries):
    return sorted(entries, reverse=True)


main()
