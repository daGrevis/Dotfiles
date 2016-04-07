import os
from datetime import timedelta
from decimal import Decimal

import requests
from lemony import set_bold, set_underline, set_line_color

from widgets import Widget, ICONS, COLORS, cache


FORECAST_IO_API_KEY = os.environ["FORECAST_IO_API_KEY"]
LOCATION_LAT = os.environ["LOCATION_LAT"]
LOCATION_LNG = os.environ["LOCATION_LNG"]


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
        wind_mph = Decimal(forecast["currently"]["windSpeed"])
        wind_ms = wind_mph * Decimal("0.44704")
        # wind_kmh = wind_mph * Decimal("1.60934")
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
            temperature_text = "{}C ({}C)".format(
                set_bold(round(apparent_temperature)),
                round(temperature),
                round(temperature),
            )

        wind_text = "{}m/s {}".format(
            set_bold(round(wind_ms, 1)),
            set_bold(wind_direction),
        )

        # See https://en.wikipedia.org/wiki/Beaufort_scale#Modern_scale
        if wind_ms >= 8:
            color = COLORS["yellow"]
            if wind_ms >= Decimal("10.8"):
                color = COLORS["red"]

            wind_text = set_line_color(set_underline(wind_text), color)

        text = ", ".join([
            temperature_text,
            wind_text,
        ])

        output = (self.set_icon_foreground_color(icon) + " "
                  + self.wrap_in_brackets(text))

        if forecast.get("alerts", []):
            output = set_line_color(set_underline(output), COLORS["red"])

        return output
