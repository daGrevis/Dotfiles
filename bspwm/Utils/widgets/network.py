import subprocess
import shutil
import re
from datetime import timedelta

import requests
from lemony import set_bold, set_overline, set_line_color

from widgets import Widget, ICONS, COLORS, cache


class NetworkWidget(Widget):

    @cache.it("widgets.network.wicd_output", expires=timedelta(seconds=5))
    def get_wicd_output(self):
        return subprocess.check_output(["wicd-cli", "--status"]).decode("utf-8")

    @cache.it("widgets.network.is_down", expires=timedelta(seconds=20))
    def is_down(self):
        try:
            response = requests.get("http://google.com", timeout=2)
            response.raise_for_status()

            return False
        except (
            requests.exceptions.ConnectionError,
            requests.exceptions.Timeout,
            requests.exceptions.HTTPError,
        ):
            return True

    def render(self):
        wicd_output = self.get_wicd_output()

        is_wireless = re.search(r"Wireless", wicd_output) is not None
        is_wired = re.search(r"Wired", wicd_output) is not None

        if is_wireless:
            is_down = False
            icon = ICONS["entypo"]["signal"]
            text = re.search(r"Connected to (\S+)", wicd_output).group(1)

        if is_wired:
            is_down = False
            icon = ICONS["font-awesome"]["plug"]
            text = "ethernet"

        if (not is_wireless and not is_wired) or self.is_down():
            is_down = True
            icon = ICONS["entypo"]["cancel"]
            text = "no network"

        output = (self.set_icon_foreground_color(icon) + " "
                  + self.wrap_in_brackets([set_bold(text)]))

        if is_down:
            output = set_line_color(set_overline(output), COLORS["red"])

        return output

    def is_available(self):
        return shutil.which("wicd-cli") is not None
