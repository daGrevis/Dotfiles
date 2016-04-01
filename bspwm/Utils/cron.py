import subprocess
import schedule
import time
from widgets import notify_send


def test_job():
    print("called test_job")


def notify_updates():
    print("called notify_updates")
    subprocess.call("notify-updates", shell=True)


def food_notification():
    print("called food_notification")
    notify_send("Food", "How about some?")


def review_notification():
    print("called review_notification")
    notify_send("Reviews", "Better do them.")


# schedule.every().second.do(test_job)

schedule.every().hour.at("xx:00").do(notify_updates)

schedule.every().day.at("12:00").do(food_notification)

schedule.every().day.at("10:30").do(review_notification)
schedule.every().day.at("14:00").do(review_notification)


ticks = 0
while True:
    ticks += 1
    # print("tick: {}".format(ticks))

    schedule.run_pending()

    time.sleep(1)
