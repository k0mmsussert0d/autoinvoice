#!/bin/bash

printf "Configuration of autoinvoice bash-sciprt started\n"

# Installing required packages
printf "Dependencies will now be installed using apt-get\n"
sudo apt-get --assume-yes install gcc bc sed gawk libreoffice

# Configure the environment
mkdir -p conf-enabled
mkdir -p data
echo $(date '+%m') > data/month
echo $(date '+%Y') > data/year
if [[ $? -ne 0 ]]; then
    printf "User %s is not allowed to perform mkdir\nExiting\n" "$USER"
    exit 1
fi

# Build c apps
printf "Compiling C dependencies using your gcc compiler\n"
gcc dateadd.c -std=c11 -o dateadd
gcc utf.c -std=c11 -o utf
if [[ $? -ne 0 ]]; then
    printf "Building C apps failed. You need a C11 compatible GCC compiler\nExiting\n"
    exit 1
fi

printf "Installed successfully\n"