#!/bin/bash

printf "Configuration of autoinvoice bash-sciprt started\n"

# Configure the environment
mkdir conf-enabled
if [[ $? -ne 0 ]]; then
    printf "User %s is not allowed to perform mkdir\nExiting\n" "$USER"
    exit 1
fi

# Build c apps
gcc dateadd.c -o dateadd
gcc utf.c -std=c11 -o utf
if [[ $? -ne 0 ]]; then
    printf "Building C apps failed. You need a C11 compatible GCC compiler\nExiting\n"
    exit 1
fi

printf "Installed successfully\n"