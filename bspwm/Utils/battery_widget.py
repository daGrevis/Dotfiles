from subprocess import check_output
from re import search


ICONS = {
    "fa-bolt": "\uf0e7",
}

acpi_output = check_output(["acpi", "-b"]).decode("utf-8")

is_full = search(r"Full", acpi_output) is not None

if is_full:
    output = "{icon} 100%".format(
        icon=ICONS["fa-bolt"],
    )
else:
    percentage = search(r"(\d+)\%", acpi_output).group(1)
    time_til = search(r"\d+:\d+:\d+", acpi_output).group(0)
    is_charging = search(r"Charging", acpi_output) is not None

    output = "{icon} {percentage}%{is_charging} ({time_til})".format(
        icon=ICONS["fa-bolt"],
        percentage=percentage,
        is_charging="+" if is_charging else "",
        time_til=time_til,
    )

print(output)
