#!/usr/bin/env bash
set -euo pipefail

action="${1:-refresh}"
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/aerospace"
state_file="$state_dir/enabled"

read_state() {
  if [ -r "$state_file" ] && [ "$(cat "$state_file")" = "off" ]; then
    printf 'off\n'
  else
    printf 'on\n'
  fi
}

write_state() {
  mkdir -p "$state_dir"
  printf '%s\n' "$1" > "$state_file"
}

case "$action" in
  toggle)
    if aerospace enable off --fail-if-noop >/dev/null 2>&1; then
      state="off"
    else
      aerospace enable on >/dev/null
      state="on"
    fi
    write_state "$state"
    ;;
  on)
    aerospace enable on >/dev/null 2>&1 || true
    state="on"
    write_state "$state"
    ;;
  restore)
    state="$(read_state)"
    aerospace enable "$state" >/dev/null 2>&1 || true
    ;;
  workspace)
    workspace="${2:?workspace is required}"
    if [ "$(read_state)" = "on" ]; then
      aerospace workspace "$workspace"
    fi
    exit 0
    ;;
  refresh)
    state="$(read_state)"
    ;;
  *)
    printf 'Unknown action: %s\n' "$action" >&2
    exit 2
    ;;
esac

if [ "$state" = "on" ]; then
  enabled=1
  focused="$(aerospace list-workspaces --focused 2>/dev/null || true)"
  sketchybar --set aerospace.toggle \
    icon="󰐥" \
    icon.color=0xffa6e3a1 \
    background.drawing=off
else
  enabled=0
  focused=""
  sketchybar --set aerospace.toggle \
    icon="󰐥" \
    icon.color=0xfff38ba8 \
    background.drawing=off
fi

if [ "${SENDER:-}" != "aerospace_state_change" ]; then
  sketchybar --trigger aerospace_state_change ENABLED="$enabled" FOCUSED="$focused"
fi
