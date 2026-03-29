#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

usage() {
    cat <<EOF
USAGE: list-use-pacakges.sh FILE.el

List all packages invoked via use-package in an .el file.

FLAGS:
  -h, --help
      Print this message and exit.
EOF
}

if [[ $# -eq 0 ]]; then
    echo "ERROR: Please provide a file with extension .el."
    usage
    exit 1
elif [[ $# -gt 1 ]]; then
    echo "ERROR: Only one file accepted."
    usage
    exit 2
elif [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    usage
    exit 0
else
    ELFILE="$1"
fi

[[ "$ELFILE" == *.el ]] || {
    echo "ERROR: File must end in .el"
    usage
    exit 3
}

TEMP="$(mktemp)"
"${HOME}/projects/dot-emacs/list-use-packages.el" "$ELFILE" | sort >"$TEMP"
mapfile -t PACKAGE_NAMES <"$TEMP"

TEMP="$(mktemp)"
for PACKAGE in "${PACKAGE_NAMES[@]}"; do
    echo "${PACKAGE}," >>"$TEMP"
done
mapfile -t PACKAGES <"$TEMP"
echo "${PACKAGES[@]}"
