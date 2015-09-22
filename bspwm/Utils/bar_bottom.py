import logging
import subprocess
import re
from os import path
from sys import argv, stdout

from lemony import set_foreground_color, set_background_color, set_bold, set_line_color, set_underline, set_monitor

from widgets import COLORS, Widget, cache


logger = logging.getLogger()

logger_handler = logging.FileHandler(
    path.join(path.expanduser("~"), "tmp/bar_bottom.log"),
)

logger_formatter = logging.Formatter("%(asctime)s - %(message)s")
logger_handler.setFormatter(logger_formatter)

logger.addHandler(logger_handler)


MONITOR_PREFIXES = ("M", "m")
DESKTOP_OCCUPIED_PREFIXES = ("O", "o")
DESKTOP_FOCUSED_PREFIXES = ("F", "O", "U")
DESKTOP_URGENT_PREFIXES = ("U", "u")
DESKTOP_PREFIXES = (
    "F",
    "O",
    "U",
    "f",
    "o",
    "u",
)
LAYOUT_PREFIX = "L"

SHORT_TITLE_MAPPING = {
    "firefox": [r"(.+ - )?Mozilla Firefox$", r".*Pentadactyl$"],
    "hipchat": [r"^HipChat$"],
    "mpv": [r".+ - mpv$"],
    "skype": [r".+ - Skype™$"],
    "spotify": [r"^Spotify Premium - Linux Preview$"],
    "transmission": [r"^Transmission$"],
    "vim": [r"^Vim$", r"^.* - GVIM\d*$"],
}


class DesktopWidget(Widget):

    def __init__(self, desktop, focused_color):
        super()

        self.desktop = desktop
        self.focused_color = focused_color

    def render(self):
        d = self.desktop

        text = " {} ".format(d["name"])

        background_color = COLORS["01"]
        foreground_color = COLORS["05"]
        bold_text = False
        if d["is_occupied"]:
            background_color = COLORS["02"]
        if d["is_focused"]:
            background_color = self.focused_color
        if d["is_urgent"]:
            background_color = COLORS["red"]
        if d["is_focused"] or d["is_urgent"]:
            foreground_color = COLORS["01"]
            bold_text = True

        text = set_background_color(text, background_color)
        text = set_foreground_color(text, foreground_color)
        if bold_text:
            text = set_bold(text)

        return text


class WindowWidget(Widget):

    def __init__(self, title, is_focused=False):
        super()

        self.title = title
        self.is_focused = is_focused

    def render(self):
        text = " {} ".format(self.title)

        background_color = COLORS["01"]
        foreground_color = COLORS["05"]
        if self.is_focused:
            background_color = COLORS["02"]

        text = set_background_color(text, background_color)
        text = set_foreground_color(text, foreground_color)

        return text


def get_focused_window_id():
    try:
        output = subprocess.check_output([
            "bspc query -w focused -W",
        ], shell=True).decode("utf-8")
    except subprocess.CalledProcessError:
        return None
    window_id = output.strip()

    return window_id


def get_focused_monitor_name():
    output = subprocess.check_output([
        "bspc query -m focused -M",
    ], shell=True).decode("utf-8")
    monitor_name = output.strip()

    return monitor_name


def get_window_ids_in_current_desktop():
    output = subprocess.check_output([
        "bspc query -d focused -W",
    ], shell=True).decode("utf-8")
    window_ids = output.split("\n")[:-1]

    return window_ids


def get_window_ids():
    output = subprocess.check_output([
        "bspc query -d focused -W",
    ], shell=True).decode("utf-8")
    window_ids = output.split("\n")[:-1]

    return window_ids


def get_titles(window_ids):
    output = subprocess.check_output([
        "xtitle {}".format(" ".join(window_ids)),
    ], shell=True).decode("utf-8")
    titles = output.split("\n")[:-1]

    return titles


def get_monitors(line):
    parts = line[1:].split(":")

    monitors = []
    monitor_id = 1
    for part in parts:
        prefix = part[0]
        content = part[1:]

        if prefix in MONITOR_PREFIXES:
            monitor = {
                "monitor_id": monitor_id,
                "monitor_name": content,
                "desktops": [],
            }
            monitors.append(monitor)

            monitor_id += 1

        if prefix == LAYOUT_PREFIX:
            monitor["is_tiled"] = content == "T"
            monitor["is_monocle"] = content == "M"

        if prefix in DESKTOP_PREFIXES:
            monitor["desktops"].append({
                "name": content,
                "is_occupied": prefix in DESKTOP_OCCUPIED_PREFIXES,
                "is_focused": prefix in DESKTOP_FOCUSED_PREFIXES,
                "is_urgent": prefix in DESKTOP_URGENT_PREFIXES,
            })

    return monitors


try:
    line = argv[1]
except IndexError:
    line = None


window_ids = get_window_ids_in_current_desktop()
focused_window_id = get_focused_window_id()
titles = get_titles(window_ids)
titles_by_window_id = dict(zip(window_ids, titles))

windows = [{"id": w,
            "title": titles_by_window_id[w],
            "is_focused": w == focused_window_id,
            } for w in window_ids]

for i, window in enumerate(windows):
    for new_title, regexs in SHORT_TITLE_MAPPING.items():
        for regex in regexs:
            if re.match(regex, window["title"]) is not None:
                windows[i]["title"] = new_title

                break

monitors = cache.get("bar_bottom.monitors", [])
if line is not None:
    if line.startswith("window_manage"):
        pass
    elif line.startswith("window_unmanage"):
        pass
    elif line.startswith("window_focus"):
        pass
    elif line.startswith("window_state"):
        pass
    elif line.startswith("desktop_focus"):
        pass
    elif line.startswith("desktop_layout"):
        pass
    elif line.startswith("monitor_focus"):
        pass
    else:
        monitors = get_monitors(line)
        cache.set("bar_bottom.monitors", monitors)

# Renders and outputs widgets.

focused_monitor_name = get_focused_monitor_name()
for monitor in monitors:
    if monitor["monitor_id"] == 1:
        focused_color = COLORS["blue"]
    else:
        focused_color = COLORS["green"]
    desktop_widgets = [
        DesktopWidget(desktop, focused_color)
        for desktop in monitor["desktops"]
    ]

    rendered_widgets = []
    for w in desktop_widgets:
        if not w.is_available():
            continue

        try:
            rendered_widgets.append(w.render())
        except Exception as exc:
            logger.exception(exc)

    desktop_output = "".join(rendered_widgets)

    window_output = None
    if monitor["monitor_name"] == focused_monitor_name:
        window_widgets = [
            WindowWidget(w["title"], w["is_focused"])
            for w in windows
        ]

        rendered_widgets = []
        for w in window_widgets:
            if not w.is_available():
                continue

            try:
                rendered_widgets.append(w.render())
            except Exception as exc:
                logger.exception(exc)

            window_output = "".join(rendered_widgets)

    if window_output is None or not windows:
        output = desktop_output
    else:
        output = desktop_output + "  " + window_output

    if monitor["monitor_name"] == focused_monitor_name:
        output = set_line_color(set_underline(output), focused_color)

    stdout.write(set_monitor(
        output,
        monitor["monitor_id"] - 1
    ))
