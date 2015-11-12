import logging
import os
import subprocess
import re
import shutil
from os import path as os_path
from sys import stdout
from datetime import datetime, timedelta
from decimal import Decimal

import requests
import psutil
from lemony import set_bold, set_overline, set_line_color, progress_bar

from widgets import Widget, ICONS, COLORS, humanize_timedelta, cache, notify_exception, debug


# To silence the damn linter!
if False:
    FileExistsError = None
    FileNotFoundError = None


logger = logging.getLogger()

logger_handler = logging.FileHandler(
    os_path.join(os_path.expanduser("~"), "tmp/bar_top.log"),
)

logger_formatter = logging.Formatter("%(asctime)s - %(message)s")
logger_handler.setFormatter(logger_formatter)

logger.addHandler(logger_handler)


DEBUG = bool(os.environ.get("PANEL_DEBUG", False))

FORECAST_IO_API_KEY = os.environ["FORECAST_IO_API_KEY"]
LOCATION_LAT = os.environ["LOCATION_LAT"]
LOCATION_LNG = os.environ["LOCATION_LNG"]


class MemoryWidget(Widget):

    def render(self):
        memory = psutil.virtual_memory()

        total_gb = memory.total / 1024 / 1024 / 1024
        used_gb = (memory.total - memory.available) / 1024 / 1024 / 1024

        icon = ICONS["font-awesome"]["server"]
        text = "{}/{} GB".format(
            set_bold(round(used_gb, 2)),
            round(total_gb, 1),
        )

        output = (self.set_icon_foreground_color(icon) + " "
                  + self.wrap_in_brackets([text]))

        if memory.percent >= 75:
            output = set_line_color(set_overline(output), COLORS["red"])

        return output


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


class BatteryWidget(Widget):

    @cache.it("widgets.battery", expires=timedelta(seconds=10))
    def get_acpi_output(self):
        return subprocess.check_output(["acpi", "-b"]).decode("utf-8")

    def render(self):
        acpi_output = self.get_acpi_output()

        is_full = (re.search(r"Full", acpi_output) is not None or
                   re.search(r"100%", acpi_output) is not None)
        is_charging = re.search(r"Charging", acpi_output) is not None

        percentage = Decimal(re.search(r"(\d+)\%", acpi_output).group(1))

        icon = ICONS["entypo"]["flash"]

        if is_full:
            output = "".join([
                self.set_icon_foreground_color(icon),
                " ",
                self.wrap_in_brackets([
                    set_bold(percentage),
                    "/100%"
                ]),
            ])

            if percentage < 20:
                output = set_line_color(set_overline(output), COLORS["red"])
        else:
            duration_groups = re.search(r"(\d+):(\d+):(\d+)", acpi_output).groups()

            if duration_groups:
                duration_parts = map(int, duration_groups)
            else:
                duration_parts = (0, 0, 0)

            h, m, s = duration_parts
            duration_timedelta = timedelta(hours=h, minutes=m, seconds=s)

            duration = humanize_timedelta(duration_timedelta, discard_names=("second", ))

            if is_charging:
                text = "{} til charged".format(duration)
            else:
                text = "{} til discharged".format(duration)

            output = "".join([
                self.set_icon_foreground_color(icon),
                " ",
                self.wrap_in_brackets([
                    set_bold(percentage),
                    "/100%",
                    ", ",
                    set_bold(text),
                ]),
            ])

        if not is_charging and percentage < 40:
            output = set_line_color(set_overline(output), COLORS["red"])

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
            icon = ICONS["font-awesome"]["volume-off"]
        elif volume < 50:
            icon = ICONS["font-awesome"]["volume-down"]
        else:
            icon = ICONS["font-awesome"]["volume-up"]

        bar = progress_bar(volume)

        output = "".join([
            self.set_icon_foreground_color(icon),
            " ",
            self.wrap_in_brackets([
                set_bold(volume),
                "/100%"
            ]),
            " ",
            self.wrap_in_brackets([
                bar
            ]),
        ])

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
            icon = ICONS["entypo"]["light-down"]
        else:
            icon = ICONS["entypo"]["light-up"]

        bar = progress_bar(brightness)

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


def get_forecast():
    try:
        response = requests.get("https://api.forecast.io/forecast/{api_key}/{lat},{lng}".format(
            api_key=FORECAST_IO_API_KEY,
            lat=LOCATION_LAT,
            lng=LOCATION_LNG,
        ), timeout=2)
    except requests.ConnectionError:
        return None

    return response.json()


class WeatherWidget(Widget):

    @cache.it("widgets.weather", expires=timedelta(days=1) / 400)
    def get_forecast(self):
        return get_forecast()

    def render(self):
        forecast = self.get_forecast()

        if forecast is None:
            return

        to_c = lambda x: (x - Decimal(32)) / Decimal("1.8")

        temperature = to_c(Decimal(forecast["currently"]["temperature"]))
        apparent_temperature = to_c(Decimal(forecast["currently"]["apparentTemperature"]))
        precipitation = Decimal(forecast["currently"]["precipProbability"])
        humidity = Decimal(forecast["currently"]["humidity"])
        wind_mph = Decimal(forecast["currently"]["windSpeed"])
        wind_kmh = wind_mph * Decimal("1.60934")
        wind_degrees = Decimal(forecast["currently"]["windBearing"])

        wind_directions_to_ranges = {
            "N": [(337.5, 360), (0, 22.5)],
            "NE": [(22.5, 67.5)],
            "E": [(67.5, 112.5)],
            "SE": [(112.5, 157.5)],
            "S": [(157.5, 202.5)],
            "SW": [(202.5, 247.5)],
            "W": [(247.5, 292.5)],
            "NW": [(292.5, 337.5)],
        }
        wind_direction = None
        for direction, degree_ranges in wind_directions_to_ranges.items():
            for degrees_from, degrees_to in degree_ranges:
                if wind_degrees >= degrees_from and wind_degrees <= degrees_to:
                    wind_direction = direction

                    break

            if wind_direction is not None:
                break

        icon_mapping = {
            "clear-day": "sun-inv",
            "clear-night": "moon-inv",
            "cloudy": "cloud-inv",
            "fog": "cloud-inv",
            "hail": "rain-inv",
            "partly-cloudy-day": "cloud-sun-inv",
            "partly-cloudy-night": "cloud-moon-inv",
            "rain": "rain-inv",
            "sleet": "snow-heavy-inv",
            "snow": "snow-heavy-inv",
            "thunderstorm": "cloud-flash-inv",
            "tornado": None,
            "wind": None,
        }
        icon = ICONS["meteocons"].get(
            icon_mapping.get(forecast["currently"]["icon"], None),
            "-",
        )

        if temperature == apparent_temperature:
            temperature_text = "{}C".format(
                set_bold(round(temperature)),
            )
        else:
            temperature_text = "~{}°C".format(
                set_bold(round(apparent_temperature)),
                round(temperature),
            )

        precipitation_text = "{}% rain".format(
            set_bold(round(precipitation * 100)),
        )

        humidity_text = "{}% RH".format(
            set_bold(round(humidity * 100)),
        )

        wind_text = "{}km/h {}".format(
            set_bold(round(wind_kmh)),
            set_bold(wind_direction),
        )

        # See https://en.wikipedia.org/wiki/Beaufort_scale#Modern_scale
        if wind_kmh >= 29:
            color = COLORS["orange"]
            if wind_kmh >= 39:
                color = COLORS["red"]

            wind_text = set_line_color(set_overline(wind_text), color)

        text = ", ".join([
            temperature_text,
            precipitation_text,
            humidity_text,
            wind_text,
        ])

        output = (self.set_icon_foreground_color(icon) + " "
                  + self.wrap_in_brackets(text))

        if forecast.get("alerts", []):
            output = set_line_color(set_overline(output), COLORS["red"])

        return output


class DatetimeWidget(Widget):

    def render(self):
        now = datetime.now()

        icon = ICONS["elusive"]["clock"]
        dt = (now.strftime("%m-") + set_bold(now.strftime("%d %H:%M")))
        weekday = now.strftime("%A")

        return (self.set_icon_foreground_color(icon) + " "
                + self.wrap_in_brackets([dt, ", ", weekday]))


class UptimeWidget(Widget):

    def get_since(self):
        boot_time = datetime.fromtimestamp(psutil.boot_time())
        since_timedelta = datetime.now() - boot_time

        return since_timedelta

    def render(self):
        since = self.get_since()

        uptime_text = humanize_timedelta(since, discard_names=("second", ))

        if uptime_text == "":
            # We discard seconds to avoid second change (it's annoying). When there's nothing to
            # show but seconds, just show text that doesn't change.
            text = "seconds ago"
        else:
            text = "up {}".format(
                set_bold(uptime_text),
            )

        icon = ICONS["entypo"]["back-in-time"]

        return (self.set_icon_foreground_color(icon) + " "
                + self.wrap_in_brackets([text]))


class LoadWidget(Widget):

    @cache.it("widgets.load.cpu_count")
    def get_cpu_count(self):
        return psutil.cpu_count()

    def render(self):
        cpu_count = 8
        avgs = map(Decimal, os.getloadavg())

        avgs_percentage = [round(x / cpu_count * 100) for x in avgs]

        icon = ICONS["elusive"]["tasks"]
        text = ", ".join([
            "{}%".format(set_bold(x)) for x
            in avgs_percentage
        ])

        output = (self.set_icon_foreground_color(icon) + " "
                  + self.wrap_in_brackets([text]))

        if sum(avgs_percentage) / 3 >= 75:
            output = set_line_color(set_overline(output), COLORS["red"])

        return output


class CpuWidget(Widget):

    def render(self):
        cpu_percentage = Decimal(psutil.cpu_percent(interval=1))

        icon = ICONS["entypo"]["gauge"]
        text = "{}/100%".format(
            set_bold(round(cpu_percentage)),
        )

        output = (self.set_icon_foreground_color(icon) + " "
                  + self.wrap_in_brackets([text]))

        if cpu_percentage >= 75:
            output = set_line_color(set_overline(output), COLORS["red"])

        return output


class DiskUsageWidget(Widget):

    def __init__(self, paths=None):
        self.paths = paths

    @cache.it("widgets.disk_usages", expires=timedelta(seconds=5))
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


widgets = [
    DatetimeWidget(),
    UptimeWidget(),
    WeatherWidget(),
    NetworkWidget(),
    MemoryWidget(),
    LoadWidget(),
    CpuWidget(),
    DiskUsageWidget(),
    SoundWidget(),
    BrightnessWidget(),
    BatteryWidget(),
]

rendered_widgets = []
for w in widgets:
    if not w.is_available():
        continue

    try:
        rendered_widget = w.render()
        if rendered_widget:
            rendered_widgets.append(rendered_widget)
    except Exception as exc:
        notify_exception()
        logger.exception(exc)

output = (" " * 4).join(rendered_widgets)


stdout.write(output)
