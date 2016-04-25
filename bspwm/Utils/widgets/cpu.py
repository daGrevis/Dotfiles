import psutil

from lemony import set_bold, set_overline, set_line_color

from widgets import Widget, ICONS, COLORS


def format_percentage(x):
    s = "{}".format(round(x))

    if x >= 1:
        s = set_bold(s)

    s += "%"

    return s


class CpuWidget(Widget):

    def render(self):
        cpu_percentages = map(
            format_percentage,
            sorted(psutil.cpu_percent(interval=2, percpu=True), reverse=True)
        )

        output = (
            self.set_icon_foreground_color(ICONS["entypo"]["gauge"])
            + " "
            + self.wrap_in_brackets(" ".join(cpu_percentages))
        )

        return output
