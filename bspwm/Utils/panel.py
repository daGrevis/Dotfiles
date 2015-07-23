import os
import subprocess
import re
import shutil

from datetime import datetime, timedelta
from decimal import Decimal

import forecastio
import sweetcache


# To silence damn linter.
if False:
    FileExistsError = None
    FileNotFoundError = None


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

FORECAST_IO_API_KEY = os.environ["FORECAST_IO_API_KEY"]
LOCATION_LAT = float(os.environ["LOCATION_LAT"])
LOCATION_LNG = float(os.environ["LOCATION_LNG"])

# Some aliases.
COLORS["on_grey"] = COLORS["04"]
COLORS["grey"] = COLORS["05"]
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
    "fa-cloud": "\uf0c2",
    "fa-desktop": "\uf108",
    "fa-ellipsis-v": "\uf142",
    "fa-moon-o":"\uf186",
    "fa-plug": "\uf1e6",
    "fa-server": "\uf233",
    "fa-sun-o":"\uf185",
    "fa-toggle-off": "\uf204",
    "fa-volume-off": "\uf026",
    "fa-volume-up": "\uf028",
    "fa-wifi": "\uf1eb",
}


ISO_FORMAT = "%Y-%m-%d %H:%M:%S"


cache = sweetcache.Cache(sweetcache.RedisBackend)


def is_night(dt):
    h = dt.hour

    return 21 <= h <= 23 or 0 <= h < 6


def parse_from_iso(datestr):
    return datetime.strptime(datestr, ISO_FORMAT)


def convert_to_iso(dt):
    return datetime.strftime(dt, ISO_FORMAT)


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


def get_forecast():
    forecast = forecastio.load_forecast(
        FORECAST_IO_API_KEY,
        LOCATION_LAT,
        LOCATION_LNG,
    )

    return forecast


class InFilesystemWidgetCache(object):

    def _create_dir(self):
        try:
            os.mkdir("/tmp/widgets/")
        except FileExistsError:
            pass

    def get_cache_time_path(self):
        return "/tmp/widgets/{}.cache_time".format(self.WIDGET_NAME)

    def get_cache_data_path(self):
        return "/tmp/widgets/{}.cache_data".format(self.WIDGET_NAME)

    def _get_cache_time(self):
        self._create_dir()

        cache_time = None

        output = None
        try:
            with open(self.get_cache_time_path()) as f:
                output = f.read()
        except FileNotFoundError:
            pass

        if output is not None:
            cache_time = parse_from_iso(output)

        return cache_time

    def _get_cache_data(self):
        self._create_dir()

        with open(self.get_cache_data_path()) as f:
            output = f.read()

        return output

    def _save_to_cache(self):
        self._create_dir()

        with open(self.get_cache_time_path(), "w") as f:
            inpt = convert_to_iso(self._cache_time)
            f.write(inpt)

        with open(self.get_cache_data_path(), "w") as f:
            f.write(self._cache_data)


class Widget(InFilesystemWidgetCache):

    def __init__(self, cache_ttl=None):
        self.cache_ttl = cache_ttl

        self._cache_time = None
        self._cache_data = None

    def is_cache_enabled(self):
        return self.cache_ttl is not None

    def is_cache_expired(self):
        return self._cache_time is None or datetime.now() - self._cache_time > self.cache_ttl

    def render(self):
        if self.is_cache_enabled():
            self._cache_time = self._get_cache_time()

            if self.is_cache_expired():
                self._cache_time = datetime.now()
                self._cache_data = self.get_output()

                self._save_to_cache()
            else:
                self._cache_data = self._get_cache_data()

            return self._cache_data
        else:
            return self.get_output()

    def get_output(self):
        if self._cache_data is not None:
            return self._cache_data

    def is_available(self):
        return True


class MemoryWidget(Widget):

    WIDGET_NAME = "MemoryWidget"

    def _get_total_and_used(self):
        free_output = subprocess.check_output(["free", "-m"]).decode("utf-8")
        total, used = [int(x) for x in
                       re.search(r"Mem:\s+(\d+)\s+(\d+)", free_output).groups()]

        return total, used

    def get_output(self):
        total, used = self._get_total_and_used()
        percantage = used * 100 / total

        icon_color = COLORS["green"]
        if percantage >= 90:
            icon_color = COLORS["red"]
        elif percantage >= 75:
            icon_color = COLORS["brown"]
        elif percantage >= 15:
            icon_color = COLORS["blue"]

        total_output = "{}GB".format(round(total / 1024, 1))
        if used < 1024:
            used_output = "{}MB".format(used)
        else:
            used_output = "{}GB".format(round(used / 1024, 1))

        return "{icon} {used} of {total} ({percantage}%)".format(
            used=used_output,
            total=total_output,
            percantage=round(percantage),
            icon=set_foreground_color(ICONS["fa-server"], icon_color),
        )


class NetworkWidget(Widget):

    WIDGET_NAME = "NetworkWidget"

    def get_output(self):
        # Not on until proven otherwise.
        output_icon = set_foreground_color(ICONS["fa-toggle-off"], COLORS["red"])
        output_text = "No network"

        is_up = os.system("zsh -c check-network") == 0
        if is_up:
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
                # Is up? Not really.
                is_up = False

        output = "{} {}".format(output_icon, output_text)

        if not is_up:
            output = draw_line_over(output)

        return output

    def is_available(self):
        return shutil.which("wicd-cli") is not None


class BatteryWidget(Widget):

    WIDGET_NAME = "BatteryWidget"

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

    WIDGET_NAME = "SoundWidget"

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

    WIDGET_NAME = "MonitorWidget"

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


class WeatherWidget(Widget):

    WIDGET_NAME = "WeatherWidget"

    def get_output(self):
        key = "widgets.weather.output"
        output = cache.get(key, None)
        if output is None:
            forecast_currently = get_forecast().currently()

            try:
                forecast_currently.d["precipType"]
                has_precipitation = True
            except KeyError:
                has_precipitation = False

            if has_precipitation:
                icon = ICONS["fa-cloud"]
                icon_color = COLORS["grey"]
            else:
                if is_night(datetime.now()):
                    icon = ICONS["fa-moon-o"]
                    icon_color = COLORS["grey"]
                else:
                    icon = ICONS["fa-sun-o"]
                    icon_color = COLORS["yellow"]

            text = "{temperature}C ({apparentTemperature}C)".format(
                temperature=forecast_currently.temperature,
                apparentTemperature=forecast_currently.apparentTemperature,
            )

            output = "{icon} {text}".format(
                icon=set_foreground_color(icon, icon_color),
                text=text,
            )

            cache.set(key, output, expires=timedelta(seconds=100))

        return output


class DatetimeWidget(Widget):

    WIDGET_NAME = "DatetimeWidget"

    def _get_color(self, dt):
        h = dt.hour

        # We choose color of clock based on daytime.
        if 6 <= h < 12:
            color = COLORS["green"]
        elif 12 <= h < 18:
            color = COLORS["yellow"]
        elif 18 <= h < 21:
            color = COLORS["orange"]
        elif is_night(dt):
            color = COLORS["purple"]

        return color

    def _get_postfix(self, dt):
        position = str(dt.day)[-1:]

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
            icon=set_foreground_color(ICONS["fa-clock"], self._get_color(now)),
            text=now.strftime("%H:%M, %B %-d{}".format(self._get_postfix(now))),
        )

        return output


widgets = [
    MemoryWidget(cache_ttl=timedelta(seconds=2)),
    NetworkWidget(cache_ttl=timedelta(seconds=5)),
    BatteryWidget(cache_ttl=timedelta(seconds=10)),
    MonitorWidget(),
    SoundWidget(),
    WeatherWidget(),
    DatetimeWidget(),
]

output = "  ".join([
    w.render()
    for w in widgets
    if w.is_available()
])
output += "  {icon} ".format(icon=set_foreground_color(ICONS["fa-ellipsis-v"], COLORS["on_grey"]))

print(output)
