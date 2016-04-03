import logging
import os
from os import path as os_path
from sys import stdout

from widgets import notify_exception
from widgets.uptime import UptimeWidget
from widgets.network import NetworkWidget
from widgets.disk_usage import DiskUsageWidget
from widgets.memory import MemoryWidget
from widgets.cpu import CpuWidget


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


widgets = [
    UptimeWidget(),
    NetworkWidget(),
    DiskUsageWidget(),
    MemoryWidget(),
    CpuWidget(),
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
