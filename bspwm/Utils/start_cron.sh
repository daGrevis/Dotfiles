#!/bin/sh

stop_cron.sh
PYTHONPATH=~/Python/lemony:~/Python/sweetcache-redis:~/Python/sweetcache \
    python ~/Utils/cron.py
