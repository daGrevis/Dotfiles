from datetime import datetime

import psutil
from lemony import set_bold

from widgets import Widget, ICONS, humanize_timedelta


class UptimeWidget(Widget):

    def get_since(self):
        boot_time = datetime.fromtimestamp(psutil.boot_time())
        since_timedelta = datetime.now() - boot_time

        return since_timedelta

    def render(self):
        since = self.get_since()

        uptime_text = humanize_timedelta(since, discard_names=("second", ))

        if uptime_text == "":
            # We discard seconds to avoid second change (it's annoying). When there's nothing to
            # show but seconds, just show text that doesn't change.
            text = "seconds ago"
        else:
            text = "up {}".format(
                set_bold(uptime_text),
            )

        icon = ICONS["entypo"]["back-in-time"]

        return (self.set_icon_foreground_color(icon) + " "
                + self.wrap_in_brackets([text]))
