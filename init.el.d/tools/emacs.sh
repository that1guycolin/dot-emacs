#!/bin/sh
# shellcheck disable=SC2068

case "$XDG_SESSION_TYPE" in
    "x11")
        /usr/local/emacs-gtk/bin/emacs $@
        ;;
    "wayland")
        /usr/local/emacs-pgtk/bin/emacs $@
        ;;
    "tty")
        /usr/local/emacs-lucid/bin/emacs -nw $@
        ;;
    *)
    echo "XDG_SESSION_TYPE=${XDG_SESSION_TYPE}."
    echo "Typical values are 'x11' or 'wayland'."
    exit 42
    ;;
esac
