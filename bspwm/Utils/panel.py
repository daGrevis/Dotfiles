import logging
import os
import subprocess
import re
import shutil
from math import floor, ceil
from datetime import datetime, timedelta
from decimal import Decimal

import sweetcache
import sweetcache_redis
import requests


# To silence damn linter.
if False:
    FileExistsError = None
    FileNotFoundError = None


ISO_FORMAT = "%Y-%m-%d %H:%M:%S"


logger = logging.getLogger()

logger_handler = logging.FileHandler("tmp/panel.log")

logger_formatter = logging.Formatter("%(asctime)s - %(message)s")
logger_handler.setFormatter(logger_formatter)

logger.addHandler(logger_handler)


def is_night(dt):
    h = dt.hour

    return 21 <= h <= 23 or 0 <= h < 6


def parse_from_iso(datestr):
    return datetime.strptime(datestr, ISO_FORMAT)


def convert_to_iso(dt):
    return datetime.strftime(dt, ISO_FORMAT)


def draw_line_over(text):
    return "%{+o}" + text + "%{-o}"


def draw_line_under(text):
    return "%{+u}" + text + "%{-u}"


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


def set_font(text, font_index):
    return ("%{T" + str(font_index) + "}" +
            text +
            "%{T-}")


def set_bold_font(text):
    return set_font(text, 2)


def humanize_timedelta(delta):
    mapping = (
        ("year", timedelta(days=365.25)),
        ("month", timedelta(days=30)),
        ("week", timedelta(days=7)),
        ("day", timedelta(days=1)),
        ("hour", timedelta(hours=1)),
        ("minute", timedelta(minutes=1)),
        ("second", timedelta(seconds=1)),
    )

    results = []
    d = delta
    for name, duration_delta in mapping:
        if duration_delta <= d:
            count = floor(d / duration_delta)
            d -= duration_delta * count
            results.append((name, count))

    results = results[:2]

    name_mapping = {
        "year": "y",
        "month": "m",
        "week": "w",
        "day": "d",
        "hour": "h",
        "minute": "m",
        "second": "s",
    }

    output = ["{}{}".format(count, name_mapping[name]) for name, count in results]

    return " ".join(output)


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

DEBUG = bool(os.environ.get("PANEL_DEBUG", False))

WUNDERGROUND_API_KEY = os.environ["WUNDERGROUND_API_KEY"]
WUNDERGROUND_LOCATION = os.environ["WUNDERGROUND_LOCATION"]

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
    "back-in-time": "\ue807",
    "cancel": "\ue806",
    "clock": "\ue805",
    "cloud": "\ue813",
    "flash": "\ue80e",
    "light-down": "\ue803",
    "light-up": "\ue804",
    "plug": "\ue80c",
    "plug": "\ue80c",
    "server": "\ue80d",
    "volume-down": "\ue801",
    "volume-off": "\ue800",
    "volume-up": "\ue802",
    "wifi": "\ue80b",
}


cache = sweetcache.Cache(sweetcache_redis.RedisBackend)


def progress_bar(value, parts_total=5, used_char="=", empty_char="-"):
    value = int(value)

    step = 100 / parts_total
    parts_used = ceil(value / step)
    parts_empty = parts_total - parts_used


    parts = [used_char * parts_used] + [empty_char * parts_empty]
    return "".join(parts)


class Widget(object):

    def is_available(self):
        return True

    def wrap_in_brackets(self, texts):
        color = COLORS["04"]

        return "".join([
            set_foreground_color(set_bold_font("["), color),
            "".join(map(str, texts)),
            set_foreground_color(set_bold_font("]"), color),
        ])

    def set_icon_foreground_color(self, text):
        return set_foreground_color(text, COLORS["04"])


class MemoryWidget(Widget):

    @cache.it("widgets.memory", expires=timedelta(seconds=2))
    def get_total_and_used(self):
        free_output = subprocess.check_output(["free", "-m"]).decode("utf-8")
        total, used = [int(x) for x in
                       re.search(r"Mem:\s+(\d+)\s+(\d+)", free_output).groups()]

        return total, used

    def render(self):
        total, used = self.get_total_and_used()
        percantage = used * 100 / total

        icon = ICONS["server"]

        text = "{}/100%, {}/{} GB".format(
            round(percantage),
            round(used / 1024, 1),
            round(total / 1024, 1),
        )

        return (self.set_icon_foreground_color(icon) + " "
                + self.wrap_in_brackets([text]))


class NetworkWidget(Widget):

    def is_down(self):
        try:
            response = requests.get("http://google.com")
            response.raise_for_status()

            return False
        except (
            requests.exceptions.ConnectionError,
            requests.exceptions.Timeout,
            requests.exceptions.HTTPError,
        ):
            return True

    @cache.it("widgets.network", expires=timedelta(seconds=5))
    def render(self):
        wicd_output = subprocess.check_output(["wicd-cli", "--status"]).decode("utf-8")

        is_wireless = re.search(r"Wireless", wicd_output) is not None
        is_wired = re.search(r"Wired", wicd_output) is not None

        if is_wireless:
            is_down = False
            icon = ICONS["wifi"]
            text = re.search(r"Connected to (\S+)", wicd_output).group(1)

        if is_wired:
            is_down = False
            icon = ICONS["plug"]
            text = "ethernet"

        if (not is_wireless and not is_wired) or self.is_down():
            is_down = True
            icon = ICONS["cancel"]
            text = "no network"

        output = (self.set_icon_foreground_color(icon) + " "
                  + self.wrap_in_brackets([text]))

        if is_down:
            output = draw_line_over(output)

        return output

    def is_available(self):
        return shutil.which("wicd-cli") is not None


class BatteryWidget(Widget):

    @cache.it("widgets.battery", expires=timedelta(minutes=1))
    def get_acpi_output(self):
        return subprocess.check_output(["acpi", "-b"]).decode("utf-8")

    def render(self):
        acpi_output = self.get_acpi_output()

        is_full = (re.search(r"Full", acpi_output) is not None or
                   re.search(r"100%", acpi_output) is not None)

        percentage = Decimal(re.search(r"(\d+)\%", acpi_output).group(1))

        icon = ICONS["flash"]

        if is_full:
            output = "".join([
                self.set_icon_foreground_color(icon),
                " ",
                self.wrap_in_brackets([
                    percentage,
                    "/100%"
                ]),
            ])
        else:
            is_charging = re.search(r"Charging", acpi_output) is not None
            duration_text = re.search(r"\d+:\d+:\d+", acpi_output).group(0)

            duration_parts = map(int, duration_text.split(":"))

            h, m, s = duration_parts
            duration_timedelta = timedelta(hours=h, minutes=m, seconds=s)

            duration = humanize_timedelta(duration_timedelta)

            if is_charging:
                text = "+{}".format(duration)
            else:
                text = "-{}".format(duration)

            output = "".join([
                self.set_icon_foreground_color(icon),
                " ",
                self.wrap_in_brackets([
                    percentage,
                    "/100%",
                    ", ",
                    text,
                ]),
            ])

        return output

    def is_available(self):
        return (shutil.which("acpi") is not None
                and self.get_acpi_output() != "")


class SoundWidget(Widget):

    def get_amixer_output(self):
        return subprocess.check_output([
            "amixer",
            "sget",
            "Master",
        ]).decode("utf-8")

    def render(self):
        amixer_output = self.get_amixer_output()

        volumes = [int(x) for x in re.findall(r"(\d+)\%", amixer_output)]
        volume = volumes[0]
        volume_total = sum([x for x in volumes])
        is_muted = re.search(r"\[off\]", amixer_output) is not None
        is_off = is_muted or volume_total == 0

        if is_off:
            icon = ICONS["volume-off"]
        elif volume < 50:
            icon = ICONS["volume-down"]
        else:
            icon = ICONS["volume-up"]

        bar = progress_bar(volume)

        output = "".join([
            self.set_icon_foreground_color(icon),
            " ",
            self.wrap_in_brackets([
                volume,
                "/100%"
            ]),
            " ",
            self.wrap_in_brackets([
                bar
            ]),
        ])

        if is_off:
            output = draw_line_over(output)

        return output

    def is_available(self):
        if shutil.which("amixer") is None:
            return False

        try:
            self.get_amixer_output()
        except subprocess.CalledProcessError:
            return False

        return True


class BrightnessWidget(Widget):

    def get_xbacklight_output(self):
        return subprocess.check_output(["xbacklight"]).decode("utf-8")

    def render(self):
        xbacklight_output = self.get_xbacklight_output()

        brightness = Decimal(xbacklight_output).quantize(Decimal("1"))

        if brightness < 50:
            icon = ICONS["light-down"]
        else:
            icon = ICONS["light-up"]

        bar = progress_bar(brightness)

        output = "".join([
            self.set_icon_foreground_color(icon),
            " ",
            self.wrap_in_brackets([
                brightness,
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


def get_forecast():
    link = "http://api.wunderground.com/api/{api_key}/conditions/q/{location}.json"
    link = link.format(
        api_key=WUNDERGROUND_API_KEY,
        location=WUNDERGROUND_LOCATION,
    )
    forecast = requests.get(link)

    return forecast.json()


class WeatherWidget(Widget):

    @cache.it("widgets.weather", expires=timedelta(minutes=5))
    def get_forecast(self):
        return get_forecast()["current_observation"]

    def render(self):
        forecast = self.get_forecast()

        temperature = float(forecast["temp_c"])
        wind = float(forecast["wind_kph"])
        wind_dir = forecast["wind_dir"]

        temperature = "{}C".format(
            round(temperature),
        )

        humidity = forecast["relative_humidity"]

        wind = "{}km/h".format(
            round(wind),
        )

        wind_dir = wind_dir

        if wind_dir == "Variable":
            wind_dir = "X"

        icon = ICONS["cloud"]

        in_brackets = [
            temperature,
            humidity,
            wind,
            wind_dir,
        ]

        output = (self.set_icon_foreground_color(icon) + " "
                  + self.wrap_in_brackets(", ".join(in_brackets)))

        return output


class DatetimeWidget(Widget):

    def render(self):
        now = datetime.now()

        icon = ICONS["clock"]
        dt = (now.strftime("%Y-%m-%d ")
              + set_bold_font(now.strftime("%H:%M"))
              + now.strftime(":%S"))
        weekday = now.strftime("%A")

        return (self.set_icon_foreground_color(icon) + " "
                + self.wrap_in_brackets([dt, ", ", weekday]))


class UptimeWidget(Widget):

    @cache.it("widgets.uptime", expires=timedelta(seconds=1))
    def get_since(self):
        since_output = subprocess.check_output(["cat", "/proc/uptime"]).decode("utf-8")

        since_seconds = float(since_output.split(" ")[0])

        since_timedelta = timedelta(seconds=since_seconds)

        return since_timedelta

    def render(self):
        since = self.get_since()

        icon = ICONS["back-in-time"]
        text = "up {}".format(
            humanize_timedelta(since),
        )

        return (self.set_icon_foreground_color(icon) + " "
                + self.wrap_in_brackets([text]))


widgets = [
    UptimeWidget(),
    NetworkWidget(),
    MemoryWidget(),
    BatteryWidget(),
    BrightnessWidget(),
    SoundWidget(),
    WeatherWidget(),
    DatetimeWidget(),
]

widgets_rendered = []
for w in widgets:
    if not w.is_available():
        continue

    try:
        widgets_rendered.append(w.render())
    except Exception as e:
        if DEBUG:
            raise
        else:
            logger.exception(e)

output = (" " * 4).join(widgets_rendered)

# logger.error(output)

print(output)
