import subprocess
import re

from datetime import datetime
from decimal import Decimal


ICONS = {
    "fa-bolt": "\uf0e7",
    "fa-desktop": "\uf108",
    "fa-toggle-off ": "\uf204",
    "fa-plug": "\uf1e6",
    "fa-wifi": "\uf1eb",
    "fa-volume-up": "\uf028",
    "fa-volume-off": "\uf026",
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


def battery_widget():
    acpi_output = subprocess.check_output(["acpi", "-b"]).decode("utf-8")

    is_full = re.search(r"Full", acpi_output) is not None

    if is_full:
        output = "{icon} 100%".format(
            icon=ICONS["fa-bolt"],
        )
    else:
        percentage = re.search(r"(\d+)\%", acpi_output).group(1)
        time_til = re.search(r"\d+:\d+:\d+", acpi_output).group(0)
        is_charging = re.search(r"Charging", acpi_output) is not None

        output = "{icon} {percentage}%{is_charging} ({time_til})".format(
            icon=ICONS["fa-bolt"],
            percentage=percentage,
            is_charging="+" if is_charging else "",
            time_til=time_til,
        )

    return output


def datetime_widget():
    now = datetime.now()

    day_position = str(now.day)[-1:]
    day_postfix = "th"
    if day_position == "1":
        day_postfix = "st"
    elif day_position == "2":
        day_postfix = "nd"
    elif day_position == "3":
        day_postfix = "rd"

    output = "\uf017 {}".format(now.strftime("%H:%M, %B %-d{}".format(day_postfix)))

    return output


def monitor_widget():
    TEMPERATURE_MIN = 3500
    TEMPERATURE_MAX = 5500

    xbacklight_output = subprocess.check_output(["xbacklight"]).decode("utf-8")

    redshift_output = subprocess.check_output([
        "redshift",
        "-l",
        "57:24",
        "-p",
    ]).decode("utf-8")
    temperature = Decimal(re.findall(r"(\d+)", redshift_output)[0])

    output_icon = ICONS["fa-desktop"]

    output_brightness = Decimal(xbacklight_output).quantize(Decimal("1"))

    # 3500K -> 100%
    # 5000K -> 25%
    # 5500K -> 0%
    temperature_warmth = (
        (TEMPERATURE_MAX - temperature) /
        Decimal((TEMPERATURE_MAX - TEMPERATURE_MIN) / 100)
    )

    output_temperature = "{temperature_warmth}%".format(
        temperature_warmth=temperature_warmth,
    )

    output = "{icon} {brightness}% ({temperature})".format(
        icon=output_icon,
        brightness=output_brightness,
        temperature=output_temperature,
    )

    return output


def network_widget():
    wicd_output = subprocess.check_output(["wicd-cli", "--status"]).decode("utf-8")

    is_wireless = re.search(r"Wireless", wicd_output) is not None
    is_wired = re.search(r"Wired", wicd_output) is not None

    if is_wireless:
        network_name = re.search(r"Connected to (\S+)", wicd_output).group(1)

        output_icon = ICONS["fa-wifi"]
        output_text = network_name
    elif is_wired:
        output_icon = ICONS["fa-plug"]
        output_text = "Ethernet"
    else:
        output_icon = ICONS["fa-toggle-off"]
        output_text = "No network"

    output = "{} {}".format(output_icon, output_text)

    return output


def sound_widget():
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
        output_icon = ICONS["fa-volume-off"]
    else:
        output_icon = ICONS["fa-volume-up"]

    output = "{output_icon} {output_volumes}".format(
        output_icon=output_icon,
        output_volumes=output_volumes,
    )

    if is_muted:
        output = draw_line_over(output)

    return output


widgets = [
    network_widget(),
    battery_widget(),
    monitor_widget(),
    sound_widget(),
    datetime_widget(),
]
output = "  ".join(widgets)

print(output)
