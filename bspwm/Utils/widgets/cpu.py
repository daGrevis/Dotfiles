import psutil

from lemony import set_bold

from utils import Widget, ICONS


def format_percentage(x):
    x = min(x, 99)

    s = "{}".format(round(x))

    if len(s) == 1:
        s = " " + s

    if x >= 90:
        s = set_bold(s)

    s += "%"

    return s


class CpuWidget(Widget):

    def render(self):
        print("render called")
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
