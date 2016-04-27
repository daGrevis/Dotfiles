import psutil

from lemony import set_bold

from utils import Widget, ICONS


def format_percentage(x):
    s = "{}".format(round(x))
    s = set_bold(s)
    s += "%"

    return s


class CpuWidget(Widget):

    def render(self):
        cpu_percentages = map(
            format_percentage,
            sorted(psutil.cpu_percent(interval=3, percpu=True), reverse=True)
        )

        output = (
            self.set_icon_foreground_color(ICONS["entypo"]["gauge"])
            + " "
            + self.wrap_in_brackets(" ".join(cpu_percentages))
        )

        return output
