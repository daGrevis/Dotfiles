import subprocess
import re
import shutil
from datetime import timedelta
from decimal import Decimal

from lemony import set_bold, set_underline, set_line_color

from widgets import Widget, ICONS, COLORS, humanize_timedelta, cache


class BatteryWidget(Widget):

    @cache.it("widgets.battery", expires=timedelta(seconds=10))
    def get_acpi_output(self):
        return subprocess.check_output(["acpi", "-b"]).decode("utf-8")

    def render(self):
        acpi_output = self.get_acpi_output()

        is_full = (re.search(r"Full", acpi_output) is not None or
                   re.search(r"100%", acpi_output) is not None)

        if is_full:
            return ""

        is_charging = re.search(r"Charging", acpi_output) is not None
        percentage = Decimal(re.search(r"(\d+)\%", acpi_output).group(1))

        icon = ICONS["entypo"]["flash"]

        duration_groups = re.search(r"(\d+):(\d+):(\d+)", acpi_output).groups()

        if duration_groups:
            duration_parts = map(int, duration_groups)
        else:
            duration_parts = (0, 0, 0)

        h, m, s = duration_parts
        duration_timedelta = timedelta(hours=h, minutes=m, seconds=s)

        duration = humanize_timedelta(duration_timedelta, discard_names=("second", ))

        if is_charging:
            text = "{} til charged"
        else:
            text = "{} til discharged"
        text = text.format(set_bold(duration))

        output = "".join([
            self.set_icon_foreground_color(icon),
            " ",
            self.wrap_in_brackets([
                set_bold(percentage),
                "/100%",
                ", ",
                text,
            ]),
        ])

        if not is_charging and percentage < 20:
            output = set_line_color(set_underline(output), COLORS["red"])

        return output

    def is_available(self):
        return (shutil.which("acpi") is not None
                and self.get_acpi_output() != "")
