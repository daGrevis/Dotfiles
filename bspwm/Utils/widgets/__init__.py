import importlib


WIDGETS = [
    ["battery", "BatteryWidget"],
    ["brightness", "BrightnessWidget"],
    ["cpu", "CpuWidget"],
    ["date_and_time", "DatetimeWidget"],
    ["disk_usage", "DiskUsageWidget"],
    ["forecast", "ForecastWidget"],
    ["memory", "MemoryWidget"],
    ["networking", "NetworkingWidget"],
    ["sound", "SoundWidget"],
    ["uptime", "UptimeWidget"],
    ["wicd", "WicdWidget"],
]

# We want dynamic import here. Live feedback while editing widget is amazing!
for modulename, classname in WIDGETS:
    module = importlib.import_module("widgets." + modulename)
    module = importlib.reload(module)
    klass = getattr(module, classname)
    vars()[classname] = klass
