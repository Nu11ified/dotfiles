#!/usr/bin/env bash
set -euo pipefail

label="$(uptime | awk -F'load averages?: ' '{print $2}' | awk '{print $1}')"
sketchybar --set "$NAME" label="$label"
