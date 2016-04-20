from datetime import datetime, timedelta
from time import time

import psutil
from lemony import set_bold

from widgets import Widget, ICONS, humanize_timedelta, cache, debug


class UptimeWidget(Widget):

    @cache.it("widgets.uptime.uptime", 1)
    def get_uptime(self):
        boot_time = datetime.fromtimestamp(psutil.boot_time())
        since_timedelta = datetime.now() - boot_time

        return since_timedelta

    @cache.it("widgets.uptime.session", 1)
    def get_session(self):
        try:
            with open("tmp/session_ts") as f:
                since_unlock = (int(f.read().strip()))
        except FileNotFoundError:
            return None

        return timedelta(seconds=int(time()) - since_unlock)

    def render(self):
        uptime = self.get_uptime()
        session = self.get_session()

        uptime_text = humanize_timedelta(uptime, discard_names=("second", ))
        if uptime_text == "":
            # We discard seconds to avoid second change (it's annoying). When there's nothing to
            # show but seconds, just show text that doesn't change.
            uptime_text = ">1m"

        text = ""

        if session:
            session_text = humanize_timedelta(session, discard_names=("second", ))
            if session_text == "":
                session_text = ">1m"

            text += "{}, ".format(
                set_bold(session_text),
            )

        text += "uptime {}".format(
            set_bold(uptime_text),
        )

        icon = ICONS["entypo"]["back-in-time"]

        return (self.set_icon_foreground_color(icon) + " "
                + self.wrap_in_brackets([text]))
