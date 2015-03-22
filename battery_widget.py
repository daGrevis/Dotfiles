from subprocess import check_output
from re import search


acpi_output = check_output(["acpi", "-b"]).decode("utf-8")

percentage = search(r"(\d+)\%", acpi_output).group(1)
is_charging = search(r"Charging", acpi_output) is not None

print("\uf0e7 {percentage}%{is_charging}".format(
    percentage=percentage,
    is_charging="+" if is_charging else "",
))
