#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

usage() {
    cat <<EOF
USAGE: ${0##*/} [OPTIONS] 

List all pacakges invoked via use-package in '~/.config/emacs/site-lisp'.

OPTIONS:
  -a, --additional-package PACKAGE
      Include PACKAGE in generated list. Useful if you call any packages with a
      function other than use-package.

  -e, --elpaca
      Add 'elpaca' and 'elpaca-use-package' to package list.
      This flag is the same as running '-a elpaca -a elpaca-use-package'.

  -h, --help
      Display this message and exit.

EOF
}

TEMP="$(mktemp)"

PARSED=$(getopt -o a:eh -l additional-package:,elpaca,help -- "$@") || {
    usage
    exit 1
}
eval set -- "$PARSED"

while true; do
    case "$1" in
        -a | --additional-package)
            echo "$2" >>"$TEMP"
            shift
            ;;
        -e | --elpaca)
            echo "elpaca" >>"$TEMP"
            echo "elpaca-use-package" >>"$TEMP"
            shift
            ;;
        -h | --help)
            usage
            exit 0
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "ERROR: Invalid option: $1" >&2
            usage
            exit 1
            ;;
    esac
done

ESCRIPT="${HOME}/.config/emacs/tools/list-use-packages.el"

for elfile in ${HOME}/.config/emacs/site-lisp/*; do
    emacs --script "$ESCRIPT" "$elfile" >>"$TEMP"
done

mapfile -t PACKAGES < <(sort "$TEMP" | uniq)

printf ';;; Packages included:\n'
printf ';; '

for i in "${!PACKAGES[@]}"; do
    if ((i > 0)); then
        printf ', '
    fi
    printf '%s' "${PACKAGES[i]}"
done

printf '\n'
