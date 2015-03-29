import re
from subprocess import check_output


ICONS = {
    "fa-volume-up": "\uf028",
    "fa-volume-off": "\uf026",
}

amixer_output = check_output(["amixer", "sget", "Master"]).decode("utf-8")

volumes = [int(x) for x in re.findall(r"(\d+)\%", amixer_output)]
is_muted = re.search(r"\[off\]", amixer_output) is not None

volume_total = sum([int(x) for x in volumes])
volumes_count = len(volumes)
is_volumes_equal = volume_total // volumes_count == volumes[0]

if is_volumes_equal:
    output_volumes = "{}%".format(volumes[0])
elif volumes_count == 2:
    output_volumes = "L/R {}%/{}%".format(*volumes)
else:
    output_volumes = "/".join(volumes)

if is_muted or volume_total == 0:
    output_icon = ICONS["fa-volume-off"]
else:
    output_icon = ICONS["fa-volume-up"]

output = "{output_icon} {output_volumes}".format(
    output_icon=output_icon,
    output_volumes=output_volumes,
)

print(output)
