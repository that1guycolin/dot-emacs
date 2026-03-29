#!/bin/sh

case "$XDG_SESSION_TYPE" in
    wayland)
        SOCKET="emacs-wayland"
        ;;
    x11)
        SOCKET="emacs-x11"
        ;;
    "")
        logger -t emacs-smart "XDG_SESSION_TYPE is not set"
        echo "emacs-smart: XDG_SESSION_TYPE is not set." >&2
        exit 1
        ;;
    *)
        logger -t emacs-smart "unsupported XDG_SESSION_TYPE: $XDG_SESSION_TYPE"
        echo "emacs-smart: unsupported XDG_SESSION_TYPE: $XDG_SESSION_TYPE" >&2
        exit 1
        ;;
esac

exec emacsclient --socket-name="$SOCKET" -c -a "" "$@"
