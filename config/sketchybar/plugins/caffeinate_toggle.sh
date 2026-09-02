#!/usr/bin/env bash
set -euo pipefail

action="${1:-refresh}"
domain="gui/$(id -u)"
label="${CAFFEINATE_LABEL:-com.nu11ified.caffeinate-toggle}"
job="$domain/$label"
plist="${CAFFEINATE_PLIST:-$HOME/.config/sketchybar/caffeinate.plist}"

is_active() {
  launchctl print "$job" >/dev/null 2>&1
}

start_caffeinate() {
  if is_active; then
    return
  fi

  if [ ! -r "$plist" ]; then
    printf 'Missing caffeinate launchd configuration: %s\n' "$plist" >&2
    exit 1
  fi

  launchctl bootstrap "$domain" "$plist"
}

stop_caffeinate() {
  if is_active; then
    launchctl bootout "$job"
  fi
}

case "$action" in
  toggle)
    if is_active; then
      stop_caffeinate
    else
      start_caffeinate
    fi
    ;;
  on)
    start_caffeinate
    ;;
  off)
    stop_caffeinate
    ;;
  refresh)
    ;;
  *)
    printf 'Unknown action: %s\n' "$action" >&2
    exit 2
    ;;
esac

if is_active; then
  color=0xffa6e3a1
else
  color=0xfff38ba8
fi

if command -v sketchybar >/dev/null 2>&1; then
  sketchybar --set caffeinate.toggle icon.color="$color" >/dev/null 2>&1 || true
fi
