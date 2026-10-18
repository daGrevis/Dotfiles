#!/usr/bin/env bash

# Starts claude. In ~, it starts claude in a new temporary directory instead,
# because Claude Code keeps the trust for ~ only for the session, so the trust
# dialog shows on each start there. A directory that is not in a git repo gets
# the trust of its parents, so one trust entry for $dir in ~/.claude.json
# covers every directory that mktemp makes in it.

set -eu

if [ "$PWD" = "$HOME" ]; then
    dir="${TMPDIR:-/tmp}/claude-home-$(id -u)"
    mkdir -p "$dir"
    # Everything in $dir is trusted, so another user must not own it.
    if [ ! -O "$dir" ]; then
        echo "$dir is owned by another user" >&2
        exit 1
    fi
    # The cwd of claude is a real path, and on macOS $TMPDIR is in /var, which
    # is a symlink to /private/var.
    dir=$(cd "$dir" && pwd -P)
    # claude makes ~/.claude.json on its first start, so on a new setup the
    # first start in ~ shows the trust dialog, and the next one adds the entry.
    if [ -f ~/.claude.json ] && ! jq -e --arg dir "$dir" '.projects[$dir].hasTrustDialogAccepted' ~/.claude.json > /dev/null; then
        tmp=$(mktemp)
        jq --arg dir "$dir" '.projects[$dir].hasTrustDialogAccepted = true' ~/.claude.json > "$tmp"
        mv "$tmp" ~/.claude.json
    fi
    cd "$(mktemp -d "$dir/XXXXXX")"
fi

exec claude "$@"
