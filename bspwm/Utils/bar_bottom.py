from sys import argv

from lemony import set_bold_font, set_foreground_color, render_widgets

from widgets import Widget, ICONS, COLORS


class DesktopWidget(Widget):

    def __init__(self, desktops):
        super()

        self.desktops = desktops

    def render(self):
        texts = []
        for desktop in self.desktops:
            status = desktop[0]
            name = desktop[1:]

            is_occupied = status in ("o", "O")
            is_focused = status == "O" or status == "F"

            if is_occupied:
                icon = ICONS["font-awesome"]["circle"]
            else:
                icon = ICONS["font-awesome"]["circle-empty"]

            if is_focused:
                icon = set_foreground_color(icon, COLORS["blue"])

            texts.append(
                icon + set_bold_font(name),
            )

        return self.wrap_in_brackets([
            "  ".join(texts)
        ])


try:
    line = argv[1]
except IndexError:
    line = ""

# print(line)


parts = line.split(":")
monitor_name = parts[0]
desktops = parts[1:11]


widgets = [
    DesktopWidget(desktops),
]
rendered_widgets = render_widgets(widgets)

output = "" + "".join(rendered_widgets)

print(output)
exit(0)
