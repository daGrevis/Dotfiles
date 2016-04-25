#!/usr/bin/env python
import argparse
import re
from os import environ as env


def main():
    args = get_args()

    is_insert = args.subparser_name == "insert"
    is_ls = args.subparser_name == "ls"

    if is_insert and not args.name:
        print("Empty name, ignoring")
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

        if args.only_names:
            names = [name for freq, name in entries]
            print("\n".join(names))
        else:
            print(output, end="")

        if lines != new_lines:
            write_db(output, db_filepath)

        exit(0)
    elif is_insert:
        entries = parse(lines)
        entries = insert_entry(args.name, entries)
        entries = sort(entries)
        new_lines = unparse(sort(entries))
        output = "".join(new_lines)

        write_db(output, db_filepath)
        exit(0)


def get_args():
    arg_parser = argparse.ArgumentParser(
        description="Manage a list of faves",
    )
    arg_subparsers = arg_parser.add_subparsers(dest="subparser_name")

    ls_parser = arg_subparsers.add_parser("ls", help="list names sorted by frequency")
    ls_parser.add_argument("--only-names", action="store_true", help="do not show frequencies")

    insert_parser = arg_subparsers.add_parser("insert", help="insert name")
    insert_parser.add_argument("name", nargs="?")

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
        freq, name = re.split(split_pattern, line, maxsplit=1)
        freq = int(freq)
        name = name.rstrip()

        entries.append([freq, name])

    return entries


def unparse(entries):
    max_pad = len(str(max([freq for freq, _ in entries]))) + 1
    lines = []
    for freq, name in entries:
        pad_count = max_pad - len(str(freq))

        lines.append(
            str(freq) + (" " * pad_count) + name + "\n",
        )

    return lines


def insert_entry(new_name, entries):
    index_found = False
    for i, (freq, name) in enumerate(entries):
        if name == new_name:
            index_found = True
            break

    if index_found:
        entry = [freq + 1, name]
        entries[i] = entry
    else:
        entry = [0, new_name]
        entries.append(entry)

    return entries


def sort(entries):
    return sorted(entries, reverse=True)


main()
