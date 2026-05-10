#!/usr/bin/env bash
set -euo pipefail

label="${INFO:-}"
if [ -z "$label" ]; then
  label="$(osascript -e 'tell application "System Events" to get name of first process whose frontmost is true' 2>/dev/null || printf unknown)"
fi

sketchybar --set "$NAME" label="$label"
