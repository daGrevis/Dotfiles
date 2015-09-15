import logging
import os
import subprocess
import re
import shutil
from os import path
from sys import stdout
from datetime import datetime, timedelta
from decimal import Decimal

import requests
from lemony import set_bold, set_overline, set_line_color, progress_bar

from widgets import Widget, ICONS, COLORS, humanize_timedelta, cache


# try:
#     line = argv[1]
# except IndexError:
#     line = ""


# To silence the damn linter!
if False:
    FileExistsError = None
    FileNotFoundError = None


logger = logging.getLogger()

logger_handler = logging.FileHandler(
    path.join(path.expanduser("~"), "tmp/panel.log"),
)

logger_formatter = logging.Formatter("%(asctime)s - %(message)s")
logger_handler.setFormatter(logger_formatter)

logger.addHandler(logger_handler)


DEBUG = bool(os.environ.get("PANEL_DEBUG", False))

WUNDERGROUND_API_KEY = os.environ["WUNDERGROUND_API_KEY"]
WUNDERGROUND_LOCATION = os.environ["WUNDERGROUND_LOCATION"]


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

        icon = ICONS["font-awesome"]["server"]

        text = "{}/100%".format(
            set_bold(str(round(percantage))),
        )

        output = (self.set_icon_foreground_color(icon) + " "
                  + self.wrap_in_brackets([text]))

        if percantage >= 80:
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

    @cache.it("widgets.battery", expires=timedelta(minutes=1))
    def get_acpi_output(self):
        return subprocess.check_output(["acpi", "-b"]).decode("utf-8")

    def render(self):
        acpi_output = self.get_acpi_output()

        is_full = (re.search(r"Full", acpi_output) is not None or
                   re.search(r"100%", acpi_output) is not None)

        percentage = Decimal(re.search(r"(\d+)\%", acpi_output).group(1))

        icon = ICONS["entypo"]["flash"]

        if is_full:
            output = "".join([
                self.set_icon_foreground_color(icon),
                " ",
                self.wrap_in_brackets([
                    set_bold(str(percentage)),
                    "/100%"
                ]),
            ])

            if percentage < 20:
                output = set_line_color(set_overline(output), COLORS["red"])
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
                    set_bold(str(percentage)),
                    "/100%",
                    ", ",
                    set_bold(text),
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
                set_bold(str(volume)),
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
                set_bold(str(brightness)),
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
    forecast = requests.get(link, timeout=2)

    return forecast.json()


class WeatherWidget(Widget):

    @cache.it("widgets.weather", expires=timedelta(minutes=5))
    def get_forecast(self):
        return get_forecast()["current_observation"]

    def render(self):
        forecast = self.get_forecast()

        temperature = float(forecast["temp_c"])
        temperature = "{}C".format(
            set_bold(str(round(temperature))),
        )

        humidity = forecast["relative_humidity"]
        humidity = set_bold(humidity)

        wind = float(forecast["wind_kph"])
        wind_dir = forecast["wind_dir"]

        if wind == 0:
            wind = set_bold("0")
        else:
            wind = "{}km/h".format(
                set_bold(str(round(wind))),
            )

        wind_dir_to_abbr = {
            "Variable": "X",
            "North": "N",
            "East": "E",
            "South": "S",
            "West": "W",
        }

        try:
            wind_dir = wind_dir_to_abbr[wind_dir]
        except KeyError:
            pass

        wind_dir = set_bold(wind_dir)

        icon = ICONS["meteocons"]["sun-inv"]

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

    @cache.it("widgets.datetime", expires=timedelta(seconds=1))
    def render(self):
        now = datetime.now()

        icon = ICONS["elusive"]["clock"]
        dt = (now.strftime("%m-%d ") + set_bold(now.strftime("%H:%M")))
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

    @cache.it("widgets.load.load_avg", expires=timedelta(seconds=2))
    def get_load_avg(self):
        load_avg_output = subprocess.check_output(["cat", "/proc/loadavg"]).decode("utf-8")
        avgs = map(Decimal, load_avg_output.split(" ")[:3])

        return avgs

    @cache.it("widgets.load.core_count")
    def get_core_count(self):
        nproc_output = subprocess.check_output(["nproc"]).decode("utf-8")
        core_count = int(nproc_output)

        return core_count

    def render(self):
        icon = ICONS["elusive"]["tasks"]

        core_count = self.get_core_count()
        avgs = self.get_load_avg()

        avgs_percentage = [round(x / core_count * 100) for x in avgs]

        text = ", ".join([
            "{}%".format(set_bold(str(x))) for x
            in avgs_percentage
        ])

        output = (self.set_icon_foreground_color(icon) + " "
                  + self.wrap_in_brackets([text]))

        if sum(avgs_percentage) / 3 >= 80:
            output = set_line_color(set_overline(output), COLORS["red"])

        return output


class CpuWidget(Widget):

    @cache.it("widgets.cpu.core_count")
    def get_core_count(self):
        nproc_output = subprocess.check_output(["nproc"]).decode("utf-8")
        core_count = int(nproc_output)

        return core_count

    @cache.it("widgets.cpu.cpu_usage", expires=timedelta(seconds=2))
    def get_cpu_usage(self):
        top_output = subprocess.check_output(["top", "-b", "-n 2"]).decode("utf-8")
        core_count = self.get_core_count()

        cpu_lines = [x for x in top_output.split("\n") if "Cpu" in x]

        cpu_usages = [int(re.search(r"(\d+)\[", x).group(1)) for x
                      in cpu_lines]

        x = [0] * core_count
        for i, usage in enumerate(cpu_usages):
            x[i]

        return x[core_count:]

    def render(self):
        icon = ICONS["entypo"]["gauge"]

        text = self.get_cpu_usage()

        return (self.set_icon_foreground_color(icon) + " "
                + self.wrap_in_brackets([text]))


widgets = [
    DatetimeWidget(),
    UptimeWidget(),
    WeatherWidget(),
    NetworkWidget(),
    MemoryWidget(),
    LoadWidget(),
    # CpuWidget(),
    SoundWidget(),
    BrightnessWidget(),
    BatteryWidget(),
]

rendered_widgets = []
for w in widgets:
    if not w.is_available():
        continue

    try:
        rendered_widgets.append(w.render())
    except Exception as exc:
        logger.exception(exc)

output = (" " * 4).join(rendered_widgets)


stdout.write(output)
