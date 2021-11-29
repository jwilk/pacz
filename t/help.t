#!/bin/sh

# Copyright © 2021 Jakub Wilk <jwilk@jwilk.net>
# SPDX-License-Identifier: MIT

set -e -u
pdir="${0%/*}/.."
prog="$pdir/pacz"
echo 1..1
out=$("$prog" --help)
sed -e 's/^/# /' <<EOF
$out
EOF
echo ok 1

# vim:ts=4 sts=4 sw=4 et ft=sh
