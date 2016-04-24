import logging
from os import path
from multiprocessing import Process
from time import time, sleep

from widgets import cache, notify_exception
from widgets.datetime import DatetimeWidget
from widgets.uptime import UptimeWidget
from widgets.weather import WeatherWidget
from widgets.network import NetworkWidget
from widgets.brightness import BrightnessWidget
from widgets.sound import SoundWidget
from widgets.battery import BatteryWidget
from widgets.disk_usage import DiskUsageWidget
from widgets.memory import MemoryWidget
from widgets.cpu import CpuWidget


logger = logging.getLogger()

logger_handler = logging.FileHandler(
    path.join(path.expanduser("~"), "tmp/widget_worker.log"),
)

logger_formatter = logging.Formatter("%(asctime)s - %(message)s")
logger_handler.setFormatter(logger_formatter)

logger.addHandler(logger_handler)


TIME_INTERVAL = .5

WIDGETS = [
    DatetimeWidget(),
    UptimeWidget(),
    WeatherWidget(),
    NetworkWidget(),
    SoundWidget(),
    BrightnessWidget(),
    BatteryWidget(),
    CpuWidget(),
    MemoryWidget(),
    DiskUsageWidget(),
]


# For each widget instance, create a new process that loops forever while updating the widget.
for widget in WIDGETS:
    def f(widget):
        i = 0
        try:
            while True:
                i += 1
                start_time = time()

                def maybe_sleep():
                    sleep_time = TIME_INTERVAL - (time() - start_time)
                    if sleep_time > 0:
                        sleep(sleep_time)

                if not widget.is_available():
                    maybe_sleep()
                    continue

                try:
                    output = widget.render()
                except Exception as exc:
                    notify_exception()
                    logger.exception(exc)

                if not output:
                    maybe_sleep()
                    continue

                cache.set(
                    ["widget_output", widget.get_name()],
                    output,
                )
                print("tick", i)

                maybe_sleep()
        except KeyboardInterrupt:
            return

    Process(target=f, args=[widget]).start()
