#!/bin/bash
CURDIR=`pwd`

for dir in `ls`
do
    if [ -d $dir ]
    then
        cd $dir
        pwd
        git pull
        cd $CURDIR
    fi
done
