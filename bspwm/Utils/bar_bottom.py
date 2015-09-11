from sys import argv, stdout

from lemony import set_bold_font, set_foreground_color, set_background_color, set_monitor, render_widgets

from widgets import Widget, COLORS


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


class DesktopWidget(Widget):

    def __init__(self, desktop, focused_color):
        super()

        self.desktop = desktop
        self.focused_color = focused_color

    def render(self):
        d = self.desktop

        text = " {} ".format(d["name"])

        color = COLORS["01"]
        if d["is_occupied"]:
            color = COLORS["02"]
        if d["is_focused"]:
            color = self.focused_color
        if d["is_urgent"]:
            color = COLORS["red"]
        text = set_background_color(text, color)

        color = COLORS["05"]
        if d["is_focused"] or d["is_urgent"]:
            color = COLORS["01"]
        text = set_foreground_color(text, color)

        text = set_bold_font(text)

        return text


try:
    line = argv[1]
except IndexError:
    line = ""


status_prefix = line[0]
parts = line[1:].split(":")

monitors = []
for part in parts:
    prefix = part[0]
    content = part[1:]

    if prefix in MONITOR_PREFIXES:
        monitor = {
            "nth": int(content) - 1,
            "desktops": [],
        }
        monitors.append(monitor)

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

for monitor in monitors:
    if monitor["nth"] == 0:
        focused_color = COLORS["blue"]
    else:
        focused_color = COLORS["green"]

    widgets = [
        DesktopWidget(desktop, focused_color)
        for desktop in monitor["desktops"]
    ]
    rendered_widgets = render_widgets(widgets)

    output = "".join(rendered_widgets)

    stdout.write(
        set_monitor(output, monitor["nth"])
    )
