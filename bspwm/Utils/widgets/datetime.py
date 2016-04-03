from datetime import datetime

from lemony import set_bold

from widgets import Widget, ICONS


class DatetimeWidget(Widget):

    def render(self):
        now = datetime.now()

        icon = ICONS["elusive"]["clock"]
        dt = (now.strftime("%m-") + set_bold(now.strftime("%d %H:%M")))
        weekday = now.strftime("%A")

        return (self.set_icon_foreground_color(icon) + " "
                + self.wrap_in_brackets([dt, ", ", weekday]))
