import psutil

from lemony import set_bold, set_overline, set_line_color

from widgets import Widget, ICONS, COLORS, cache


def format_percentage(x):
    s = "{}".format(round(x))

    if x >= 1:
        s = set_bold(s)

    s += "%"

    if x >= 95:
        s = set_line_color(set_overline(s), COLORS["yellow"])

    return s


class CpuWidget(Widget):

    @cache.it("widgets.cpu", expires=1)
    def render(self):
        cpu_percentages = map(
            format_percentage,
            sorted(psutil.cpu_percent(interval=0.1, percpu=True), reverse=True)
        )

        output = (
            self.set_icon_foreground_color(ICONS["entypo"]["gauge"])
            + " "
            + self.wrap_in_brackets(" ".join(cpu_percentages))
        )

        return output
