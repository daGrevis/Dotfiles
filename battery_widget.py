from subprocess import check_output
from re import search, findall


acpi_output = check_output(["acpi", "-bt"]).decode("utf-8")

percentage = search(r"(\d+)\%", acpi_output).group(1)
thermals = findall(r"(\d+\.\d+) degrees", acpi_output)

print("\uf0e7 {}% ({})".format(
    percentage,
    ", ".join(["{}C".format(x) for x in thermals])
))
