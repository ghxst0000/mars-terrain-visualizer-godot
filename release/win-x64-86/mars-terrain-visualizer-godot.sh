#!/bin/sh
echo -ne '\033c\033]0;mars-terrain-visualizer-godot\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/mars-terrain-visualizer-godot.x86_64" "$@"
