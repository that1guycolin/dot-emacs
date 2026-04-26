#!/bin/sh
# shellcheck disable=SC2068

case "$XDG_SESSION_TYPE" in
    "x11")
	/usr/local/emacs-gtk/bin/emacs-gtk $@
	;;
    "wayland")
	/usr/local/emacs-pgtk/bin/emacs-pgtk $@
	;;
    "tty")
	/usr/local/emacs-lucid/bin/emacs-lucid -nw $@
	;;
    *)
	echo "XDG_SESSION_TYPE=$XDG_SESSION_TYPE."
	exit 42
	;;
esac
