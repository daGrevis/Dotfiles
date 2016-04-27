# In [9]: psutil.net_io_counters().bytes_recv / 1024 / 1024
# Out[9]: 484.22121238708496

# In [10]: psutil.net_io_counters().bytes_sent / 1024 / 1024
# Out[10]: 367.929482460022
import time

import psutil

from lemony import set_bold, set_overline, set_line_color

from utils import Widget


class NetworkingWidget(Widget):

    def render(self):
        # debug("yo")
        net_io_counters = psutil.net_io_counters()

        time.sleep(1)

        current_net_io_counters = psutil.net_io_counters()

        output = (
            self.wrap_in_brackets([
                "testik",
            ])
        )

        return output
