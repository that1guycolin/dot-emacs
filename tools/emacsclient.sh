#!/bin/sh
# shellcheck disable=SC2068

case "$XDG_SESSION_TYPE" in
    "x11")
	BUILD="lucid"
	;;
    "wayland")
	BUILD="pgtk"
	;;
    "tty")
	BUILD="lucid"
	;;
    *)
	echo "XDG_SESSION_TYPE=$XDG_SESSION_TYPE."
	echo "Allowed options are x11, tty, & wayland."
	exit 42
	;;
esac

#shellcheck disable=SC2086
STATUS="$(systemctl --user is-active "emacs-${XDG_SESSION_TYPE}")"

if [[ "$STATUS" == "active" ]]; then
    "/usr/local/emacs-${BUILD}/bin/emacsclient-${BUILD}" "$@"
else
    systemctl --user start "emacs-${XDG_SESSION_TYPE}"
    "/usr/local/emacs-${BUILD}/bin/emacsclient-${BUILD}" "$@"
fi
