#!/usr/bin/env bash
set -euo pipefail

label="$(pmset -g batt 2>/dev/null | awk -F'; *' '/%/{gsub(/^[ \t]+|[ \t]+$/, "", $1); split($1,a," "); print a[length(a)]; exit}')"
if [ -z "${label:-}" ]; then
  label="AC"
fi

sketchybar --set "$NAME" label="$label"
