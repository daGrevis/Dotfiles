import os
from datetime import datetime, timedelta
from math import floor

import sweetcache
import sweetcache_redis
from lemony import BaseWidget, set_foreground_color, set_bold


ISO_FORMAT = "%Y-%m-%d %H:%M:%S"


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
    "font-awesome": {
        "plug": "\ue986",
        "server": "\ue97e",
        "volume-down": "\ue892",
        "volume-off": "\ue891",
        "volume-up": "\ue893",
    },
    "entypo": {
        "back-in-time": "\ueab1",
        "cancel": "\uea1a",
        "database": "\ueada",
        "database": "\ueada",
        "dot": "\ueac4",
        "flash": "\ueabb",
        "gauge": "\ueae5",
        "light-down": "\uea6c",
        "light-up": "\uea6d",
        "signal": "\ueaae",
    },
    "elusive": {
        "clock": "\uebc6",
        "tasks": "\uec2c",
    },
    "meteocons": {
        "cloud-flash-inv": "\ueb34",
        "cloud-inv": "\ueb33",
        "cloud-moon-inv": "\ueb32",
        "cloud-sun-inv": "\ueb31",
        "hail-inv": "\ueb26",
        "moon-inv": "\ueb30",
        "rain-inv": "\ueb36",
        "sun-inv": "\ueb2f",
    }
}


cache = sweetcache.Cache(sweetcache_redis.RedisBackend)


class Widget(BaseWidget):

    def wrap_in_brackets(self, texts):
        color = COLORS["04"]

        return "".join([
            set_foreground_color(set_bold("["), color),
            "".join(map(str, texts)),
            set_foreground_color(set_bold("]"), color),
        ])

    def set_icon_foreground_color(self, text):
        return set_foreground_color(text, COLORS["05"])


def parse_from_iso(datestr):
    return datetime.strptime(datestr, ISO_FORMAT)


def convert_to_iso(dt):
    return datetime.strftime(dt, ISO_FORMAT)


def is_night(dt):
    h = dt.hour

    return 21 <= h <= 23 or 0 <= h < 6


def humanize_timedelta(delta, discard_names=[]):
    assert not delta < timedelta(), "Delta must not be negative"

    durations_to_names = (
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
    for name, duration_delta in durations_to_names:
        if duration_delta <= d:
            count = floor(d / duration_delta)

            d -= duration_delta * count

            # TODO: Also cosmetics. See below.
            if name in discard_names:
                continue

            results.append((name, count))

    # TODO: Next are cosmetics that should be moved out to other function.

    # results = results[:2]

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
