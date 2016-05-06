import time
import re
from subprocess import run, PIPE
from decimal import Decimal

import psutil

from lemony import set_bold, set_underline, set_line_color

from utils import Widget, COLORS, debug


def to_mb(b):
    return b / 1024 / 1024


def do_ping():
    ping = {}

    ping_process = run(
        "ping -c 3 -i 0.5 google.com",
        shell=True,
        stdout=PIPE,
    )
    if ping_process.returncode != 0:
        # No ping.
        return False

    ping_output = str(ping_process.stdout)

    timing_pattern = r"([0-9\.]+)\/([0-9\.]+)\/([0-9\.]+)\/([0-9\.])+ ms"
    timing_groups = re.search(timing_pattern, ping_output).groups()

    ping["timing_min"] = Decimal(timing_groups[0])
    ping["timing_avg"] = Decimal(timing_groups[1])
    ping["timing_max"] = Decimal(timing_groups[2])
    ping["timing_mdev"] = Decimal(timing_groups[3])

    loss_pattern = r"(\d+)\% packet loss"
    loss_groups = re.search(loss_pattern, ping_output).groups()

    ping["packet_loss"] = Decimal(loss_groups[0])

    return ping


def format_speed(speed):
    speed_mb = to_mb(speed)
    text = str(round(speed_mb, 1))

    if speed_mb >= 1:
        return set_bold(text)
    else:
        return text

class NetworkingWidget(Widget):

    def render(self):
        time_start = time.time()
        snetio_before = psutil.net_io_counters()

        ping = do_ping()

        ping_delta = time.time() - time_start

        # Wait at least two seconds.
        if ping_delta < 2:
            time.sleep(2 - ping_delta)

        snetio_now = psutil.net_io_counters()

        speed_delta = time.time() - time_start

        down = (snetio_now.bytes_recv - snetio_before.bytes_recv) / speed_delta
        up = (snetio_now.bytes_sent - snetio_before.bytes_sent) / speed_delta

        down_text = format_speed(down)
        up_text = format_speed(up)

        text = "{}/{} MB/s".format(
            down_text,
            up_text,
        )

        if ping:
            text += ", ping {}ms".format(
                set_bold(round(ping["timing_avg"])),
            )
        else:
            text += ", " + set_bold("no ping")

        if ping and ping["packet_loss"]:
            text += " ({}% loss)".format(
                set_bold(round(ping["packet_loss"])),
            )

        output = (
            self.wrap_in_brackets([
                text,
            ])
        )

        return output
