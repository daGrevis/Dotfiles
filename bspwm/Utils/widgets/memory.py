import psutil
from lemony import set_bold, set_overline, set_line_color, progress_bar

from widgets import Widget, ICONS, COLORS, debug


class MemoryWidget(Widget):

    def render(self):
        memory = psutil.virtual_memory()

        total_mb = memory.total / 1024 / 1024
        used_mb = (memory.total - memory.available) / 1024 / 1024

        icon = ICONS["font-awesome"]["server"]
        text = "{}/{} MB".format(
            set_bold(round(used_mb)),
            round(total_mb),
        )

        output = (self.set_icon_foreground_color(icon) + " "
                  + self.wrap_in_brackets([text]))

        if memory.percent >= 75:
            output = set_line_color(set_overline(output), COLORS["red"])

        # GB per step unless it's <= 2 GB.
        bar_steps = round(total_mb / 1000)
        if bar_steps <= 2:
            bar_steps = 10

        bar = progress_bar(memory.percent, bar_steps)

        output += " " + self.wrap_in_brackets(bar)

        return output
