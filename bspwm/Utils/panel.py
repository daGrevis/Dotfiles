import os
import subprocess
import re
import shutil

from datetime import datetime
from decimal import Decimal


try:
    COLORS = {
        k[len("COLOR_"):]: os.environ[k]
        for k
        in (
            "COLOR_00",
            "COLOR_01",
            "COLOR_02",
            "COLOR_03",
            "COLOR_04",
            "COLOR_05",
            "COLOR_06",
            "COLOR_07",

            "COLOR_08",
            "COLOR_09",
            "COLOR_0A",
            "COLOR_0B",
            "COLOR_0C",
            "COLOR_0D",
            "COLOR_0E",
            "COLOR_0F",
        )
    }
except KeyError:
    print("COLOR_* variables are missing!")
    exit(-1)

# Some aliases.
COLORS["on_grey"] = COLORS["04"]
COLORS["red"] = COLORS["08"]
COLORS["orange"] = COLORS["09"]
COLORS["yellow"] = COLORS["0A"]
COLORS["green"] = COLORS["0B"]
COLORS["teal"] = COLORS["0C"]
COLORS["blue"] = COLORS["0D"]
COLORS["purple"] = COLORS["0E"]
COLORS["brown"] = COLORS["0F"]

ICONS = {
    "fa-bolt": "\uf0e7",
    "fa-clock": "\uf017",
    "fa-desktop": "\uf108",
    "fa-plug": "\uf1e6",
    "fa-toggle-off": "\uf204",
    "fa-volume-off": "\uf026",
    "fa-volume-up": "\uf028",
    "fa-wifi": "\uf1eb",
}


def draw_line_over(text):
    return "%{+o}" + text + "%{-o}"


def to_bar_color_format(color):
    """
    From #RRGGBB to #FFRRGGBB if it's hex, otherwise pass-through.
    """
    if color[0] == "#":
        return "#FF" + color[1:]
    else:
        return color


def set_foreground_color(text, hex_color):
    return ("%{F" + to_bar_color_format(hex_color) + "}" +
            text +
            "%{F-}")


def set_background_color(text, hex_color):
    return ("%{B" + to_bar_color_format(hex_color) + "}" +
            text +
            "%{B-}")


class Widget(object):

    def get_output(self):
        raise NotImplementedError()

    def is_available(self):
        return True


class NetworkWidget(Widget):

    def get_output(self):
        wicd_output = subprocess.check_output(["wicd-cli", "--status"]).decode("utf-8")

        is_wireless = re.search(r"Wireless", wicd_output) is not None
        is_wired = re.search(r"Wired", wicd_output) is not None

        if is_wireless:
            network_name = re.search(r"Connected to (\S+)", wicd_output).group(1)

            output_icon = set_foreground_color(ICONS["fa-wifi"], COLORS["blue"])
            output_text = network_name
        elif is_wired:
            output_icon = set_foreground_color(ICONS["fa-plug"], COLORS["green"])
            output_text = "Ethernet"
        else:
            output_icon = set_foreground_color(ICONS["fa-toggle-off"], COLORS["red"])
            output_text = "No network"

        output = "{} {}".format(output_icon, output_text)

        return output

    def is_available(self):
        return shutil.which("wicd-cli") is not None


class BatteryWidget(Widget):

    def get_output(self):
        acpi_output = subprocess.check_output(["acpi", "-b"]).decode("utf-8")

        is_full = (re.search(r"Full", acpi_output) is not None or
                   re.search(r"100%", acpi_output) is not None)

        if is_full:
            output = "{icon} 100%".format(
                icon=set_foreground_color(ICONS["fa-bolt"], COLORS["yellow"]),
            )
        else:
            percentage = Decimal(re.search(r"(\d+)\%", acpi_output).group(1))
            time_til = re.search(r"\d+:\d+:\d+", acpi_output).group(0)
            is_charging = re.search(r"Charging", acpi_output) is not None

            if is_charging:
                color = COLORS["yellow"]
            elif not is_charging and percentage > 20:
                color = COLORS["green"]
            elif percentage <= 20:
                color = COLORS["red"]

            output = "{icon} {percentage}%{is_charging} ({time_til})".format(
                icon=set_foreground_color(ICONS["fa-bolt"], color),
                percentage=percentage,
                is_charging="+" if is_charging else "",
                time_til=time_til,
            )

        return output

    def is_available(self):
        return shutil.which("acpi") is not None


class SoundWidget(Widget):

    def get_output(self):
        amixer_output = subprocess.check_output([
            "amixer",
            "sget",
            "Master",
        ]).decode("utf-8")

        volumes = [int(x) for x in re.findall(r"(\d+)\%", amixer_output)]
        is_muted = re.search(r"\[off\]", amixer_output) is not None

        volume_total = sum([int(x) for x in volumes])

        output_volumes = subprocess.check_output([
            "python",
            "Utils/get_volume.py",
        ]).decode("utf-8")
        output_volumes = output_volumes.strip()

        if is_muted or volume_total == 0:
            output_icon = set_foreground_color(ICONS["fa-volume-off"], COLORS["red"])
        else:
            output_icon = set_foreground_color(ICONS["fa-volume-up"], COLORS["green"])

        output = "{output_icon} {output_volumes}".format(
            output_icon=output_icon,
            output_volumes=output_volumes,
        )

        if is_muted:
            output = draw_line_over(output)

        return output

    def is_available(self):
        return shutil.which("amixer") is not None


class MonitorWidget(Widget):
    TEMPERATURE_MIN = 3500
    TEMPERATURE_MAX = 5500

    def get_output(self):
        xbacklight_output = subprocess.check_output(["xbacklight"]).decode("utf-8")

        redshift_output = subprocess.check_output([
            "redshift",
            "-l",
            "57:24",
            "-p",
        ]).decode("utf-8")
        temperature = Decimal(re.findall(r"(\d+)K", redshift_output)[0])

        # 3500K -> 100%
        # 5000K -> 25%
        # 5500K -> 0%
        temperature_warmth = (((self.TEMPERATURE_MAX - self.TEMPERATURE_MIN) -
                               (temperature - self.TEMPERATURE_MIN)) /
                              (self.TEMPERATURE_MAX - self.TEMPERATURE_MIN) *
                              100)
        temperature_warmth = temperature_warmth.quantize(Decimal("1"))

        if 0 <= temperature_warmth < 40:
            color = COLORS["blue"]
        elif 50 <= temperature_warmth < 80:
            color = COLORS["brown"]
        else:
            color = COLORS["orange"]

        output_icon = set_foreground_color(ICONS["fa-desktop"], color)

        output_brightness = Decimal(xbacklight_output).quantize(Decimal("1"))

        output_temperature = "{temperature_warmth}%".format(
            temperature_warmth=temperature_warmth,
        )

        output = "{icon} {brightness}% ({temperature})".format(
            icon=output_icon,
            brightness=output_brightness,
            temperature=output_temperature,
        )

        return output

    def is_available(self):
        return (
            shutil.which("xbacklight") is not None and
            shutil.which("redshift") is not None
        )


class DatetimeWidget(Widget):

    def _get_color(self, h):
        # We choose color of clock based on daytime.
        if 6 <= h < 12:
            color = COLORS["green"]
        elif 12 <= h < 18:
            color = COLORS["yellow"]
        elif 18 <= h < 21:
            color = COLORS["orange"]
        elif 21 <= h <= 23 or 0 <= h < 6:
            color = COLORS["purple"]

        return color

    def _get_postfix(self, day):
        position = str(day)[-1:]

        postfix = "th"
        if position == "1":
            postfix = "st"
        elif position == "2":
            postfix = "nd"
        elif position == "3":
            postfix = "rd"

        return postfix

    def get_output(self):
        now = datetime.now()

        output = "{icon} {text}".format(
            icon=set_foreground_color(ICONS["fa-clock"], self._get_color(now.hour)),
            text=now.strftime("%H:%M, %B %-d{}".format(self._get_postfix(now.day))),
        )

        return output


widgets = [
    NetworkWidget(),
    BatteryWidget(),
    MonitorWidget(),
    SoundWidget(),
    DatetimeWidget(),
]

output = "  ".join([
    w.get_output()
    for w in widgets
    if w.is_available()
])

print(output)
