---
name: handoff
description: Write a short handoff file (handoff-<slug>.md) in the current directory, so that a fresh session can continue the work. Use when the context window fills up, before /clear, or when the user asks for a handoff, a session summary, or to save state.
---

# Handoff

Write one Markdown file to the current working directory. Name it
`handoff-<slug>.md`, where the slug is 2 to 5 kebab-case words for the task, for
example `handoff-rework-clean-yank-script.md`.

Two readers must continue from it after days away: the user, and a fresh session
with no context.

## Rules

- Overwrite the handoff file for this task if it exists. Never create a second one.
- Keep the file under 50 lines, and each line under 100 characters.
- One item per line, as a Markdown list. Never write comma-separated items.
- Write only what the reader cannot get from the code, from `git diff`, or from
  `CLAUDE.md`. The diff shows what changed, not why, and not whether it is finished.
- Name real paths, for example `sh/clean-yank.py:42`. Do not quote file contents.
- Use these fields only. Do not add fields. Do not write paragraphs.
- Write the default text if a field has nothing important.
- Report the file name when you finish. Do not print the content.

## Format

```
# Handoff: [task in 5 words or less]

**Goal**: [one to two sentences]

**Done**:
- [completed item]

**WIP**:
- [item name]: [optionally description]

**Next**:
- [the most important step first]

**Dead ends**:
- [approach that was tried, and why it failed]

**Watch out**:
- [gotcha, constraint, or question that the user must answer]
```

Skip field if empty.
