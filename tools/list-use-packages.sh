#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

usage() {
    cat <<EOF
USAGE: ${0##*/} [OPTIONS] FILE.el

Alphabetically list pacakges invoked via use-package in FILE.el.

OPTIONS:
  -h, --help
      Display this message and exit.

EOF
}

PARSED=$(getopt -o h -l help -- "$@") || {
    usage
    exit 1
}
eval set -- "$PARSED"

while true; do
    case "$1" in
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

[[ $# -eq 1 ]] || {
    echo "ERROR: Wrong number of arguments."
    usage
    exit 42
}

ELFILE="$1"
[ -f "$ELFILE" ] || {
    echo "ERROR: ${ELFILE} does not exist."
    usage
    exit 42
}

ESCRIPT="${HOME}/.emacs.d/tools/list-use-packages.el"

mapfile -t PACKAGES < <(
    emacs --script "$ESCRIPT" "$ELFILE" | sort | uniq
)

printf ';;; Packages included:\n'
printf ';; '

for i in "${!PACKAGES[@]}"; do
    if ((i > 0)); then
        printf ', '
    fi
    printf '%s' "${PACKAGES[i]}"
done

printf '\n'
