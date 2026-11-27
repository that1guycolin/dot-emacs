#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

sbcl --load \
    "${XDG_CONFIG_HOME:-${HOME}/.config}/emacs/etc/tools/start-slynk.lisp"
