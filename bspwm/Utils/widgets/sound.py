import subprocess
import shutil
import re

from lemony import set_bold, set_underline, set_line_color, progress_bar

from utils import Widget, ICONS, COLORS


class SoundWidget(Widget):

    def get_amixer_output(self):
        return subprocess.check_output([
            "amixer",
            "sget",
            "Master",
        ]).decode("utf-8")

    def render(self):
        amixer_output = self.get_amixer_output()

        volumes = [int(x) for x in re.findall(r"(\d+)\%", amixer_output)]
        volume = volumes[0]
        volume_total = sum([x for x in volumes])
        is_muted = re.search(r"\[off\]", amixer_output) is not None
        is_off = is_muted or volume_total == 0

        if is_off:
            icon = ICONS["font-awesome"]["volume-off"]
        elif volume < 50:
            icon = ICONS["font-awesome"]["volume-down"]
        else:
            icon = ICONS["font-awesome"]["volume-up"]

        bar = progress_bar(volume, 10)

        output = "".join([
            self.set_icon_foreground_color(icon),
            " ",
            self.wrap_in_brackets([
                set_bold(volume),
                "/100%"
            ]),
            " ",
            self.wrap_in_brackets([
                bar
            ]),
        ])

        if is_muted:
            output = set_line_color(set_underline(output), COLORS["yellow"])

        return output

    def is_available(self):
        if shutil.which("amixer") is None:
            return False

        try:
            self.get_amixer_output()
        except subprocess.CalledProcessError:
            return False

        return True
