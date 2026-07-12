#!/bin/sh
# shellcheck disable=SC2068

case "$XDG_SESSION_TYPE" in
    "x11")
        BUILD="gtk"
        ;;
    "wayland")
        BUILD="pgtk"
        ;;
    *)
    echo "XDG_SESSION_TYPE=${XDG_SESSION_TYPE}."
    echo "Allowed options are x11, tty, & wayland."
    exit 42
    ;;
esac

#shellcheck disable=SC2086
STATUS="$(systemctl --user is-active "emacs-${XDG_SESSION_TYPE}")"

[ "$STATUS" = "active" ] || systemctl --user start "emacs-${XDG_SESSION_TYPE}"
/usr/local/emacs-${BUILD}/bin/emacsclient $@

