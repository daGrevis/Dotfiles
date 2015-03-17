import re

from subprocess import check_output


ICONS = {
    "fa-volume-up": "\uf028",
    "fa-volume-off": "\uf026",
}

amixer_output = check_output(["amixer", "sget", "Master"]).decode("utf-8")

volumes = re.findall(r"(\d+)\%", amixer_output)
is_muted = re.search(r"\[off\]", amixer_output) is not None

volume_left, volume_right = volumes

if volume_left == volume_right:
    output_volumes = "{}%".format(volume_left)
else:
    output_volumes = "L/R {}%/{}%".format(*volumes)

volume_total = sum([int(x) for x in volumes])
if is_muted or volume_total == 0:
    output_icon = ICONS["fa-volume-off"]
else:
    output_icon = ICONS["fa-volume-up"]

output = "{output_icon} {output_volumes}".format(
    output_icon=output_icon,
    output_volumes=output_volumes,
)

print(output)
