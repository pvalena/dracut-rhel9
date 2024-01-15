#!/usr/bin/zsh

set -e

zsh -n "$0"

x="$1"
shift

grep -r "$x" | grep -v ^test | grep -v ^origin/ | grep -v ^spec/ | grep -v ^dracut\.8\: | grep -v ^dracut\.html | grep -v '^man/' | grep -v '^NEWS\.' | grep -v '^\.' | grep -v '^Makefile' | grep "$x"
