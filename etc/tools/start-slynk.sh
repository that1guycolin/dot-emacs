#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

sbcl --load \
    /data/data/com.termux/files/home/.config/emacs/etc/tools/start-slynk.lisp
