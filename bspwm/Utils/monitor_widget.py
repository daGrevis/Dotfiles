import re
from subprocess import check_output
from decimal import Decimal


ICONS = {
    "fa-desktop": "\uf108",
}

TEMPERATURE_MIN = 3500
TEMPERATURE_MAX = 5500

xbacklight_output = check_output(["xbacklight"]).decode("utf-8")

redshift_output = check_output([
    "redshift",
    "-l",
    "57:24",
    "-p",
]).decode("utf-8")
temperature = Decimal(re.findall(r"(\d+)", redshift_output)[0])

output_icon = ICONS["fa-desktop"]

output_brightness = Decimal(xbacklight_output).quantize(Decimal("1"))

# 3500K -> 100%
# 5000K -> 25%
# 5500K -> 0%
temperature_warmth = (
    100 - ((temperature - TEMPERATURE_MIN) /
           (TEMPERATURE_MAX - TEMPERATURE_MIN) * 100)
)
output_temperature = "{temperature_warmth}%w".format(
    temperature_warmth=temperature_warmth,
)

output = "{icon} {brightness}% ({temperature})".format(
    icon=output_icon,
    brightness=output_brightness,
    temperature=output_temperature,
)

print(output)
