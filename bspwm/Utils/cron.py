import subprocess
import schedule
import time
from datetime import date

from widgets import notify_send


def test_job():
    print("called test_job")


def notify_updates():
    print("called notify_updates")
    subprocess.call("zsh -c notify-updates", shell=True)


def food_notification():
    print("called food_notification")
    notify_send("Food", "How about some?")


def review_notification():
    print("called review_notification")
    notify_send("Reviews", "Better do them.")


def when_weekday(fn):
    if date.today().weekday() in range(0, 5):
        return fn
    else:
        return lambda: "noop"


# schedule.every().second.do(test_job)

# schedule.every().hour.at("xx:00").do(notify_updates)

schedule.every().day.at("12:00").do(when_weekday(food_notification))

schedule.every().day.at("10:30").do(when_weekday(review_notification))
schedule.every().day.at("14:00").do(when_weekday(review_notification))

schedule.every().day.at("11:00").do(notify_updates)
schedule.every().day.at("17:00").do(notify_updates)
schedule.every().day.at("22:00").do(notify_updates)


ticks = 0
while True:
    ticks += 1
    print("tick: {}".format(ticks))

    schedule.run_pending()

    time.sleep(1)
