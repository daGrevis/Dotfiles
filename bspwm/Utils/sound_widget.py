import re
from subprocess import check_output


ICONS = {
    "fa-volume-up": "\uf028",
    "fa-volume-off": "\uf026",
}


def draw_line_over(text):
    return "%{+o}" + text + "%{-o}"

amixer_output = check_output([
    "amixer",
    "sget",
    "Master",
]).decode("utf-8")

volumes = [int(x) for x in re.findall(r"(\d+)\%", amixer_output)]
is_muted = re.search(r"\[off\]", amixer_output) is not None

volume_total = sum([int(x) for x in volumes])

output_volumes = check_output([
    "python",
    "Utils/get_volume.py",
]).decode("utf-8")
output_volumes = output_volumes.strip()

if is_muted or volume_total == 0:
    output_icon = ICONS["fa-volume-off"]
else:
    output_icon = ICONS["fa-volume-up"]

output = "{output_icon} {output_volumes}".format(
    output_icon=output_icon,
    output_volumes=output_volumes,
)

if is_muted:
    output = draw_line_over(output)

print(output)
