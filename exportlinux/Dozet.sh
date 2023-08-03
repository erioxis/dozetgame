#!/bin/sh
echo -ne '\033c\033]0;Dozet\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Dozet.x86_64" "$@"
