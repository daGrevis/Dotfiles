from sys import argv, stdout

from lemony import set_bold_font, set_foreground_color, set_monitor, render_widgets

from widgets import Widget, COLORS, ICONS


MONITOR_PREFIXES = ("M", "m")
DESKTOP_OCCUPIED_PREFIXES = ("O", "o")
DESKTOP_FOCUSED_PREFIXES = ("F", "O", "U")
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
        icon = "  "

        if self.desktop["is_occupied"]:
            icon = ICONS["font-awesome"]["circle-empty"]

        if self.desktop["is_focused"]:
            icon = set_foreground_color(
                ICONS["font-awesome"]["circle"],
                self.focused_color,
            )

        text = "{}{}".format(
            icon,
            self.desktop["name"],
        )

        text = set_bold_font(text)

        return self.wrap_in_brackets([text])


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

    output = " ".join(rendered_widgets)

    stdout.write(
        set_monitor(output, monitor["nth"])
    )
