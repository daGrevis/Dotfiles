---
name: pickup
description: Continue work from a handoff file (handoff-<slug>.md) in the current directory. Use at the start of a fresh session, or when the user says pickup, continue where we left off, or resume the handoff.
---

# Pickup

## Steps

1. List `handoff-*.md` in the current working directory.
2. If there is no such file, tell the user and stop.
3. If there is one file, use it. If there are several, use the one that the user
   names. If the user names none, list them with their modification time and ask
   which one to use.
4. Read the file.
5. Read the paths that the file names. Run `git status` and `git diff`. Rebuild
   the context from the repository, not from the handoff alone.
6. State the goal and suggest how we can continue, but don't start the work.

## Rules

- The handoff is a map, not the truth. If the file and the code disagree, trust
  the code and tell the user.
- Do not repeat the handoff, user can read it.
- When the next step is done, or when the session ends, update the same file with
  the `handoff` skill. A stale handoff is worse than no handoff.
