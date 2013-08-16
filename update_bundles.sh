#!/bin/bash

CUR_DIR=$(pwd)

for i in $(find . -name ".git" | cut -c 3-); do
    cd "$i";
    cd ..;

    git pull origin master;

    cd $CUR_DIR
done
