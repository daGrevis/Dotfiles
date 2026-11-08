# claude-afk

## Purpose

claude-afk is a tool that spends free Claude subscription usage while you are away. A systemd timer starts a runner at fixed intervals. The runner finds the tasks that are due, checks the usage limits, and starts `claude -p` for one task.

Each task is a directory with a `prompt.md` that you write. Claude keeps its scripts, data, notes and findings in the same directory. Thus each run can continue and improve the work of the run before it.

## Commands

- Start the timer now and at each login: `systemctl --user enable --now claude-afk.timer`
- Stop the ticks: `systemctl --user stop claude-afk.timer`
- Stop a run now: `systemctl --user stop claude-afk.service`
- Read the log of the runner itself: `journalctl --user -u claude-afk`
- Show each task, if it is due, if the usage limits let it run, and the number of open findings, with no run: `claude-afk status`
- Run one task now, also with `enabled: false`, and with no check of the usage limits before the run: `claude-afk run <task>`. The usage limits can still stop the run.

The timer starts `claude-afk tick` every 15 minutes, while the machine is on. A tick runs at most one task. User units start at login, and `loginctl enable-linger` makes them start at boot.

## Tasks

### Files

All tasks are in `~/claude-afk/` on this machine. Each task directory is a git repository. Before each run, the runner commits your own edits. After each run, it commits all changes of the run.

```
~/claude-afk/
  config                     you: global defaults, same keys as the frontmatter
  <task>/
    prompt.md                you: settings and instructions
    notes.md                 Claude: memory for the next run, questions for you
    output/INDEX.md          Claude: findings with status
    .claude/settings.json    you, optional: permissions for this task
    .afk/last-run            runner: time of the last run
    .afk/log                 runner: one line per decision
    .afk/runs/<time>.json    runner: output of each run
    ...                      Claude: scripts, data and results
```

### Settings

`prompt.md` starts with the settings of the task in frontmatter. The runner sends the text after the frontmatter as the prompt.

```
---
schedule: 08..20/3:00
priority: 10
timeout: 20m
---
Your instructions for Claude ...
```

`~/claude-afk/config` can hold the same keys, one `key: value` per line, as global values for all tasks. The keys are:

- `schedule`: required. It uses the systemd `OnCalendar` syntax, for example `08..20/3:00`, `Mon..Fri 09:00` or `hourly`. `systemd-analyze calendar --iterations=5 '<expression>'` shows the next 5 times. The schedule gives only how often a task can run, and the `reserve` gives when.
- `enabled`: `false` stops the task. The default is `true`. Claude does not change it, but it can propose a stop in `notes.md`.
- `priority`: an integer. When more than one task is due, the task with the highest number runs. The default is 0.
- `model`: for example `sonnet` or `claude-opus-5-5`. Do not use Haiku, because auto mode refuses it and the run then gets no tools. The default is `model` from your `~/.claude/settings.json`.
- `effort`: for example `low`, `medium` or `high`. The default is `high`.
- `timeout`: the hard limit of one run, for example `20m`, `1h` or `90s`. A number with no unit is minutes. The default is `20m`. A task with a timeout of more than 7 hours 55 minutes never runs, because the token of a run lives at most 8 hours.
- `reserve`: the share of the 5h window that the tasks leave for you. It is a list of `HH:MM=value` entries with spaces between them. Each value from 0 to 1 applies from its time until the next entry. The default is `01:00=0 09:00=0.5 15:00=0.8 23:00=0.5`. A run starts only when the free share is at least the reserve plus 0.1, and it stops below the reserve.
- `max_week_pace`: the used share of the week can be at most this value multiplied by the elapsed share of the week. The default is 1.0. Thus the tasks spread their usage over the week, and they stop in a week when you work much.
- `min_free_week`: the share of the week that the tasks always leave for you. The default is 0.3.
- `env`: names of variables from `~/.env` on the host, with spaces between them, for example `GMAIL_ADDRESS GMAIL_APP_PASSWORD`. The container gets each one with its value. An injected instruction can send these values to any host, as with `mounts`.
- `mounts`: host directories or files for the container of the task, with spaces between them. Each one ends with `:ro` (read-only, the default) or `:rw`, for example `~/Code/project:ro`. The container gets each one at the same path, and it cannot see other host files. The prompt must say what Claude can do with each one. Do not mount secrets. A web page that the task reads can tell Claude to send the files to any host.

### Findings

Claude writes each finding as one file in `output/`, for example `output/0007-<slug>.md`. Each file ends with a `## Response` heading for your answer. The next run distills the answer into `notes.md`, as "Notes" tells, and changes its method.

`output/INDEX.md` has one line per finding with its status: `open` (no answer), `answered` (Claude read the answer) or `updated` (Claude changed the finding after the answer).

The runs get none of your Claude Code settings, thus none of your writing rules. Each task prompt must say how Claude writes its findings.

### Notes

`notes.md` is the memory of a task. It holds only the current state, so that it does not grow with each run. The git history keeps each earlier version. The runner tells each run the word count, and the run keeps the file under 1500 words.

The file has these parts, in this order:

- `## What the user wants`: the rules that Claude distilled from all your answers. Each rule gives its source in short, for example `(0040, Q03)`.
- `## Method`: how Claude does the work now, and what it learned about its tools and sources.
- `## Last run`: what the last run did and found. Each run replaces it.
- `## Plan`: the next steps.
- `## Questions`: at most 5 questions and proposals for you, each with a name such as `Q07`.
- `## Response`: your answers. Answer a question by its name.

Your answers are the text under `## Response` in `notes.md` and in the findings, and each other channel that a task adds. The runner commits your edits before each run and tells the run which files you changed. The run distills each new answer into `## What the user wants`. It adds a rule, makes a rule more exact, or replaces a rule that the answer contradicts. It writes a vague answer as its best reading, with a question. Then it removes your answers from `notes.md`, but not from the findings.

### Log

`.afk/log` has one line per decision of the runner, but only when the task is due. Each line has the time, the decision, the reason, and the 5h and week numbers:

```
2026-10-29 14:00 skip  5h limit: 42% free, needs 60%, reserve 50%
2026-10-29 14:00 wait  other-task runs first: priority 20
2026-10-29 14:15 run   5h 61% free, reserve 50%, week 55% free, week used 45% of pace 47%
2026-10-29 14:24 end   watchdog: 5h 48% free, reserve 50%, 9 min
2026-10-30 03:15 run   5h 100% free, reserve 0%, week 52% free, week used 48% of pace 49%
2026-10-30 03:33 end   ok, 18 min, 23 turns
```

`.afk/runs/<time>.json` has the full output of claude, and `.afk/runs/<time>.err` has its errors, if there are any.
