from sys import stdout

from widgets import cache
from widgets.datetime import DatetimeWidget
from widgets.uptime import UptimeWidget
from widgets.weather import WeatherWidget
from widgets.network import NetworkWidget
from widgets.brightness import BrightnessWidget
from widgets.sound import SoundWidget


widgets = [
    DatetimeWidget(),
    UptimeWidget(),
    WeatherWidget(),
    NetworkWidget(),
    BrightnessWidget(),
    SoundWidget(),
]

outputs = []
for widget in widgets:
    output = cache.get(["widget_output", widget.get_name()], None)
    if output:
        outputs.append(output)


output = (" " * 4).join(outputs)

stdout.write(output)
