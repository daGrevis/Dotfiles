import psutil
from lemony import set_bold, set_overline, set_line_color, progress_bar

from widgets import Widget, ICONS, COLORS


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

        bar = progress_bar(memory.percent, 10)

        output += " " + self.wrap_in_brackets(bar)

        return output
