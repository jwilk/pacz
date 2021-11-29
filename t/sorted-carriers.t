#!/bin/sh

# Copyright © 2021 Jakub Wilk <jwilk@jwilk.net>
# SPDX-License-Identifier: MIT

set -e -u
export LC_ALL=C
pdir="${0%/*}/.."
prog="$pdir/pacz"
echo 1..1
if msg=$(grep '^sub carrier::[^_]' "$prog" | sort -c 2>&1)
then
    echo ok 1
else
    case $msg in
        *': disorder: '*)
            msg="disorder: ${msg#*'disorder: '}";;
        *)
            ;;
    esac
    echo not ok 1 "$msg"
fi

# vim:ts=4 sts=4 sw=4 et ft=sh
