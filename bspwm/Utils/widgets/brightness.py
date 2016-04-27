import subprocess
import shutil
from decimal import Decimal

from lemony import set_bold, progress_bar

from utils import Widget, ICONS


class BrightnessWidget(Widget):

    def get_xbacklight_output(self):
        return subprocess.check_output(["xbacklight"]).decode("utf-8")

    def render(self):
        xbacklight_output = self.get_xbacklight_output()

        brightness = Decimal(xbacklight_output).quantize(Decimal("1"))

        if brightness < 50:
            icon = ICONS["entypo"]["light-down"]
        else:
            icon = ICONS["entypo"]["light-up"]

        bar = progress_bar(brightness, 10)

        output = "".join([
            self.set_icon_foreground_color(icon),
            " ",
            self.wrap_in_brackets([
                set_bold(brightness),
                "/100%"
            ]),
            " ",
            self.wrap_in_brackets([
                bar
            ]),
        ])

        return output

    def is_available(self):
        if shutil.which("xbacklight") is None:
            return False

        try:
            self.get_xbacklight_output()
        except subprocess.CalledProcessError:
            return False

        return True
