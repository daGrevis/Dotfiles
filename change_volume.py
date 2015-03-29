"""
Changes volume and guarantees that new volume divides by step w/o remainder.
It's some kind of sick need for me.

Usage:

    python change_volume.py 5
    python change_volume.py -5
"""
import re
from sys import argv
from subprocess import check_output, call, DEVNULL


input_step = argv[1]

step = int(input_step)

amixer_output = check_output(["amixer", "sget", "Master"]).decode("utf-8")
volume = int(re.findall(r"(\d+)\%", amixer_output)[0])

volume_normalized = (volume // step) * step

if volume != volume_normalized:
    step_diff = (volume_normalized + step) - volume
else:
    step_diff = step

amixer_expr = "{diff_abs}%{sign}".format(
    diff_abs=abs(step_diff),
    sign="+" if step_diff > 0 else "-",
)

call(["amixer", "set", "Master", amixer_expr], stdout=DEVNULL)

print(step_diff)
exit(0)
