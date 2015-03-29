import re
from subprocess import check_output
from decimal import Decimal


ICONS = {
    "fa-desktop": "\uf108",
}

xbacklight_output = check_output(["xbacklight"]).decode("utf-8")
brightness = Decimal(xbacklight_output).quantize(Decimal("1"))

redshift_output = check_output(["redshift", "-p"]).decode("utf-8")
temperature = re.findall(r"(\d+)K", redshift_output)[0]

output = "{icon} {brightness}% ({temperature}K)".format(
    icon=ICONS["fa-desktop"],
    brightness=brightness,
    temperature=temperature,
)

print(output)
