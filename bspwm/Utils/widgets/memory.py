import psutil
from lemony import set_bold, set_overline, set_line_color, progress_bar

from utils import Widget, ICONS, COLORS


class MemoryWidget(Widget):

    def render(self):
        memory = psutil.virtual_memory()

        total_gb = memory.total / 1024 / 1024 / 1024
        used_gb = (memory.total - memory.available) / 1024 / 1024 / 1024

        icon = ICONS["font-awesome"]["server"]
        text = "{}/{} GB".format(
            set_bold(round(used_gb, 1)),
            round(total_gb, 1),
        )

        output = (self.set_icon_foreground_color(icon) + " "
                  + self.wrap_in_brackets([text]))

        if memory.percent >= 75:
            output = set_line_color(set_overline(output), COLORS["red"])

        bar = progress_bar(memory.percent)

        output += " " + self.wrap_in_brackets(bar)

        return output
