import re
from subprocess import check_output


ICONS = {
    "fa-toggle-off ": "\uf204",
    "fa-plug": "\uf1e6",
    "fa-wifi": "\uf1eb",
}

wicd_output = check_output(["wicd-cli", "--status"]).decode("utf-8")

is_wireless = re.search(r"Wireless", wicd_output) is not None
is_wired = re.search(r"Wired", wicd_output) is not None

if is_wireless:
    network_name = re.search(r"Connected to (\S+)", wicd_output).group(1)

    output_icon = ICONS["fa-wifi"]
    output_text = network_name
elif is_wired:
    output_icon = ICONS["fa-plug"]
    output_text = "Ethernet"
else:
    output_icon = ICONS["fa-toggle-off"]
    output_text = "No network"

output = "{} {}".format(output_icon, output_text)

print(output)
