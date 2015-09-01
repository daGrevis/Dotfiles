import re
from subprocess import check_output


amixer_output = check_output(["amixer", "sget", "Master"]).decode("utf-8")

volumes = [int(x) for x in re.findall(r"(\d+)\%", amixer_output)]

volume_total = sum([int(x) for x in volumes])
volumes_count = len(volumes)
is_volumes_equal = volume_total // volumes_count == volumes[0]

if is_volumes_equal:
    output_volumes = volumes[0]
else:
    output_volumes = sum(volumes) / len(volumes)

print(output_volumes)
