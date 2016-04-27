from datetime import timedelta

import psutil
from lemony import set_bold, set_overline, set_line_color

from utils import Widget, ICONS, COLORS, cache


class DiskUsageWidget(Widget):

    def __init__(self, paths=None):
        self.paths = paths

    @cache.it("widgets.disk_usage", expires=timedelta(seconds=5))
    def get_disk_usages(self):
        paths = self.paths

        # Defaults.
        if paths is None:
            paths = [
                "/",  # root
                "/home/",  # home dir
            ]

        return map(psutil.disk_usage, paths)

    def to_gb(self, b):
        gb = b / 1024 / 1024 / 1024
        return gb

    def render(self):
        disk_usages = self.get_disk_usages()

        text_parts = []
        for disk_usage in disk_usages:
            total = disk_usage.free + disk_usage.used
            used = disk_usage.used
            free = disk_usage.free
            percentage = used / total * 100

            text = "{}/{} GB".format(
                set_bold(round(self.to_gb(used))),
                round(self.to_gb(total)),
            )

            is_critical = False

            # Numbers below are pretty random and should be adjusted manually.
            is_storage_drive = self.to_gb(total) >= 80
            if is_storage_drive:
                if self.to_gb(free) < 20:
                    is_critical = True
            else:
                if disk_usage.percent >= 90:
                    is_critical = True

            if is_critical:
                text += " ({}%)".format(round(percentage, 2))
                text = set_line_color(set_overline(text), COLORS["red"])

            text_parts.append(text)

        icon = ICONS["entypo"]["database"]
        text = ", ".join(text_parts)

        output = (self.set_icon_foreground_color(icon) + " "
                  + self.wrap_in_brackets([text]))

        return output
