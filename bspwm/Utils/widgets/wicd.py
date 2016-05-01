import subprocess
import shutil
import re
import random
import socket
from datetime import timedelta

import requests
from lemony import set_bold, set_overline, set_line_color

from utils import Widget, ICONS, COLORS, cache


class WicdWidget(Widget):

    def get_wicd_output(self):
        return subprocess.check_output(["wicd-cli", "--status"]).decode("utf-8")

    @cache.it("widgets.wicd", expires=timedelta(seconds=10))
    def is_down(self):
        urls = [
            "http://google.com",
            "http://youtube.com",
            "http://facebook.com",
            "http://twitter.com",
            "http://amazon.com",
            "http://yahoo.com",
            "http://wikipedia.org",
        ]
        random.shuffle(urls)

        for url in urls[:3]:
            try:
                response = requests.get(url, timeout=2)
                response.raise_for_status()

                return False
            except (
                requests.exceptions.ConnectionError,
                requests.exceptions.Timeout,
                requests.exceptions.HTTPError,
            ):
                continue

        return True

    def render(self):
        local_ip = socket.gethostbyname(socket.gethostname())

        wicd_output = self.get_wicd_output()

        is_wireless = re.search(r"Wireless", wicd_output) is not None
        is_wired = re.search(r"Wired", wicd_output) is not None

        if is_wireless:
            icon = ICONS["entypo"]["signal"]
            text = re.search(r"Connected to (\S+)", wicd_output).group(1)

        if is_wired:
            icon = ICONS["font-awesome"]["plug"]
            text = "ethernet"

        overline_color = None
        if (not is_wireless and not is_wired):
            icon = ICONS["entypo"]["cancel"]
            text = "no connection"
            overline_color = COLORS["red"]
        elif self.is_down():
            icon = ICONS["entypo"]["cancel"]
            text = "failing connections"
            overline_color = COLORS["yellow"]

        text = set_bold(text)

        text += ", " + local_ip

        output = (
            self.set_icon_foreground_color(icon)
            + " "
            + self.wrap_in_brackets([text])
        )

        if overline_color is not None:
            output = set_line_color(set_overline(output), overline_color)

        return output

    def is_available(self):
        return shutil.which("wicd-cli") is not None