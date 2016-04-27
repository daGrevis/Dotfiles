from sys import stdout

from utils import cache

import widgets


WIDGET_CLASSES = [
    widgets.DatetimeWidget,
    widgets.UptimeWidget,
    widgets.ForecastWidget,
    widgets.WicdWidget,
    widgets.BrightnessWidget,
    widgets.SoundWidget,
    widgets.BatteryWidget,
]

outputs = []
for widget_class in WIDGET_CLASSES:
    widget = widget_class()

    output = cache.get(["widget_output", widget.get_name()], None)
    if output is not None:
        outputs.append(output)


output = (" " * 4).join(outputs)

stdout.write(output)
