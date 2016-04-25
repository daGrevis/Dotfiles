#!/bin/bash

pkill -f widget_worker.py

PYTHONPATH=~/Utils:~/Python/lemony:~/Python/sweetcache-redis:~/Python/sweetcache \
    python ~/Utils/widget_worker.py
