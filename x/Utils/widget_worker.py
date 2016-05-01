import logging
from os import path
from multiprocessing import Process
from time import time, sleep
import importlib

from utils import cache, notify_exception


logger = logging.getLogger()

logger_handler = logging.FileHandler(
    path.join(path.expanduser("~"), "tmp/widget_worker.log"),
)

logger_formatter = logging.Formatter("%(asctime)s - %(message)s")
logger_handler.setFormatter(logger_formatter)

logger.addHandler(logger_handler)


VERBOSE = True
MIN_SLEEPING_TIME_INTERVAL = .5

WIDGETS = [
    "BatteryWidget",
    "BrightnessWidget",
    "CpuWidget",
    "DatetimeWidget",
    "DiskUsageWidget",
    "ForecastWidget",
    "MemoryWidget",
    "NetworkingWidget",
    "SoundWidget",
    "UptimeWidget",
    "WicdWidget",
]


def maybe_sleep(start_time, min_sleep=MIN_SLEEPING_TIME_INTERVAL):
    delta = time() - start_time
    sleep_time = min_sleep - delta
    if sleep_time > 0:
        if VERBOSE:
            print("sleeping for", round(sleep_time, 2))
        sleep(sleep_time)
    else:
        if VERBOSE:
            print("not sleeping", round(delta, 2))


def f(classname):
    i = 0
    try:
        while True:
            i += 1
            start_time = time()

            # Reload for live feedback.
            import widgets
            widgets = importlib.reload(widgets)
            widget_class = getattr(widgets, widget_classname)

            try:
                widget = widget_class()

                if VERBOSE:
                    print(i, widget.get_name())

                if not widget.is_available():
                    maybe_sleep(start_time)
                    continue

                output = widget.render()
            except Exception as exc:
                notify_exception()
                logger.exception(exc)

                maybe_sleep(start_time)
                # Wait a bit more to avoid spam.
                sleep(2)
                continue

            # Widgets may return False which means that they shouldn't be rendered.
            if output == False:
                maybe_sleep(start_time)
                continue

            cache.set(
                ["widget_output", widget.get_name()],
                output,
            )

            maybe_sleep(start_time)
            continue
    except KeyboardInterrupt:
        return

# For each widget instance, create a new process that loops forever while updating the widget.
for widget_classname in WIDGETS:
    Process(target=f, args=[widget_classname]).start()
