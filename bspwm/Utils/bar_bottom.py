import logging
import subprocess
import re
from os import path
from sys import argv, stdout

from lemony import (
    set_foreground_color, set_background_color, set_bold, set_line_color, set_underline,
    set_monitor,
)

from widgets import COLORS, Widget, cache, notify_exception, debug


logger = logging.getLogger()

logger_handler = logging.FileHandler(
    path.join(path.expanduser("~"), "tmp/bar_bottom.log"),
)

logger_formatter = logging.Formatter("%(asctime)s - %(message)s")
logger_handler.setFormatter(logger_formatter)

logger.addHandler(logger_handler)


SHORT_WINDOW_NAME_MAPPING = {
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

        text = " {} ".format(d["desktop_name"])

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

    def __init__(self, window):
        super()

        self.window = window

    def render(self):
        w = self.window

        short_name = get_short_window_name(w["window_name"])

        text = " {} ".format(short_name)

        background_color = COLORS["01"]
        foreground_color = COLORS["05"]
        if w["is_focused"]:
            background_color = COLORS["02"]

        text = set_background_color(text, background_color)
        text = set_foreground_color(text, foreground_color)

        return text


def get_monitors(line):
    """
    monitors = [
        {
            monitor_id: int

            monitor_name: str

            is_monocle: bool
            is_tiled: bool
            is_active: bool

            desktops: [
                {
                    desktop_name: str

                    is_focused: bool
                    is_occupied: bool
                    is_urgent: bool
                },
                ...
            ]

        },
        ...
    ]
    """

    parts = line[1:].split(":")

    monitors = []
    monitor_id = 1
    for part in parts:
        prefix = part[0]
        content = part[1:]

        # If it's a monitor...
        if prefix in "Mm":
            monitor = {
                "monitor_name": content,

                "is_active": prefix == "M",

                "desktops": [],
            }

            monitor["monitor_id"] = monitor_id
            monitor_id += 1

            monitors.append(monitor)

        # Adds the layout options to monitor....
        if prefix == "L":
            monitor["is_tiled"] = content == "T"
            monitor["is_monocle"] = content == "M"

        # If it's a desktop that belongs to monitor...
        if prefix in "FOUfou":
            monitor["desktops"].append({
                "desktop_name": content,

                "is_focused": prefix in "FOU",
                "is_occupied": prefix in "Oo",
                "is_urgent": prefix in "Uu",
            })

    return monitors


def get_window_ids_in_monitor(monitor_id):
    output = subprocess.check_output([
        "bspc",
        "query",
        "-m",
        "^{}".format(monitor_id),
        "-W",
    ]).decode("utf-8")
    window_ids = output.split("\n")[:-1]

    return window_ids


def get_window_ids_in_focused_desktops():
    output = subprocess.check_output([
        "bspc",
        "query",
        "-d",
        "focused",
        "-W",
    ]).decode("utf-8")
    window_ids = output.split("\n")[:-1]

    return window_ids


def get_focused_window_id():
    try:
        output = subprocess.check_output([
            "bspc",
            "query",
            "-w",
            "focused",
            "-W",
        ]).decode("utf-8")
    except subprocess.CalledProcessError:
        return None
    window_id = output.strip()

    return window_id


def get_window_names(window_ids):
    output = subprocess.check_output(
        ["xtitle"] + window_ids
    ).decode("utf-8")
    names = output.split("\n")[:-1]

    return names


def get_short_window_name(name):
    for short_name, regexs in SHORT_WINDOW_NAME_MAPPING.items():
        for regex in regexs:
            if re.match(regex, name) is not None:
                return short_name

    return name


def get_windows(monitor_id):
    """
    windows = [
        {
            window_id: int

            window_name: str

            is_focused: bool
        },
        ...
    ]
    """

    window_ids_in_focused_desktops = get_window_ids_in_focused_desktops()
    window_ids_in_monitor = get_window_ids_in_monitor(monitor_id)

    # Can't use sets here because need to maintain order.
    window_ids = [
        window_id
        for window_id
        in window_ids_in_focused_desktops
        if window_id in window_ids_in_monitor
    ]

    focused_window_id = get_focused_window_id()
    window_id_to_window_names = dict(zip(window_ids, get_window_names(window_ids)))
    windows = [{
        "window_id": window_id,
        "window_name": window_id_to_window_names[window_id],
        "is_focused": window_id == focused_window_id,
    } for window_id in window_ids]

    return windows


def render_to_monitor(monitor, windows):
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

        rendered_widgets.append(w.render())

    desktop_output = "".join(rendered_widgets)

    window_output = None
    if monitor["is_active"]:
        window_widgets = [
            WindowWidget(w)
            for w in windows
        ]

        rendered_widgets = []
        for w in window_widgets:
            if not w.is_available():
                continue

            rendered_widgets.append(w.render())

            window_output = "".join(rendered_widgets)

    if window_output is None or not windows:
        output = desktop_output
    else:
        output = desktop_output + "  " + window_output

    if monitor["is_active"]:
        output = set_line_color(set_underline(output), focused_color)

    stdout.write(set_monitor(
        output,
        monitor["monitor_id"] - 1
    ))


def render(monitors):
    for monitor in monitors:
        render_to_monitor(
            monitor,
            get_windows(monitor["monitor_id"]),
        )


def main():
    try:
        line = argv[1]
    except IndexError:
        return

    if line.startswith("W"):
        monitors = get_monitors(line)

        cache.set("bar_bottom.monitors", monitors)
    else:
        monitors = cache.get("bar_bottom.monitors", [])

    # if line.startswith("monitor_focus"):
    #     pass

    # if line.startswith("desktop_focus"):
    #     pass

    # if line.startswith("desktop_layout"):
    #     pass

    # if line.startswith("window_state"):
    #     pass

    # if line.startswith("window_focus"):
    #     pass

    # if line.startswith("window_manage"):
    #     pass

    # if line.startswith("window_unmanage"):
    #     pass

    render(monitors)


try:
    main()
except Exception as exc:
    notify_exception()
    logger.exception(exc)
