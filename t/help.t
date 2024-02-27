#!/usr/bin/env bash

# Copyright © 2021 Jakub Wilk <jwilk@jwilk.net>
# SPDX-License-Identifier: MIT

set -e -u
pdir="${0%/*}/.."
prog="$pdir/pacz"
echo 1..1
xout=$(
    < "$pdir/README" \
    grep -A999 '^   [$] pacz --help$' |
    tail -n +2 |
    grep -B999 -m1 '^[^ ]' |
    head -n -1 |
    sed -e 's/^   //'
)
out=$("$prog" --help)
say() { printf "%s\n" "$@"; }
diff=$(diff -u <(say "$xout") <(say "$out")) || true
if [ -z "$diff" ]
then
    echo 'ok 1'
else
    sed -e 's/^/# /' <<< "$diff"
    echo 'not ok 1'
fi

# vim:ts=4 sts=4 sw=4 et ft=sh
