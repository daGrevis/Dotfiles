from datetime import datetime


now = datetime.now()

day_position = str(now.day)[-1:]
day_postfix = "th"
if day_position == "1":
    day_postfix = "st"
elif day_position == "2":
    day_postfix = "nd"
elif day_position == "3":
    day_postfix = "rd"

print("\uf017 {}".format(now.strftime("%H:%M, %B %-d{}".format(day_postfix))))
