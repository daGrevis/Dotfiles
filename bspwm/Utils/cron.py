import schedule
import time
from widgets import notify_send


def food_notification():
    notify_send("Food", "How about some?")


def review_notification():
    notify_send("Reviews", "Better do them.")


schedule.every().day.at("12:00").do(food_notification)
schedule.every().day.at("10:30").do(review_notification)
schedule.every().day.at("14:00").do(review_notification)


while True:
    schedule.run_pending()
    time.sleep(1)
