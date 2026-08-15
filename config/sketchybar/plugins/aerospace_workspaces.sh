#!/usr/bin/env bash
set -euo pipefail

state_file="${XDG_STATE_HOME:-$HOME/.local/state}/aerospace/enabled"
args=()

if [ "${SENDER:-}" = "display_change" ] || [ "${SENDER:-}" = "system_woke" ]; then
  sleep 0.8
  "$HOME/.config/aerospace/scripts/arrange-monitors" || true
fi

if [ -r "$state_file" ] && [ "$(cat "$state_file")" = "off" ]; then
  for workspace in 1 2 3 4 5 6 7 8 9; do
    args+=(
      --set "space.$workspace"
      background.color=0x00000000
      background.border_color=0x00000000
      icon.color=0xff6c6875
    )
  done
  sketchybar "${args[@]}"
  exit 0
fi

workspace_state="$(
  aerospace list-workspaces --all \
    --format '%{workspace}|%{workspace-is-focused}|%{workspace-is-visible}|%{monitor-appkit-nsscreen-screens-id}' \
    2>/dev/null || true
)"

while IFS='|' read -r workspace focused visible display_id; do
  case "$workspace" in
    1|2|3|4|5|6|7|8|9) ;;
    *) continue ;;
  esac

  args+=(--set "space.$workspace")
  if [ -n "$display_id" ]; then
    args+=(display="$display_id")
  fi

  if [ "$focused" = "true" ]; then
    args+=(
      background.color=0xffffffff
      background.border_color=0xffffffff
      icon.color=0xff111111
    )
  elif [ "$visible" = "true" ]; then
    args+=(
      background.color=0x445c5366
      background.border_color=0xfff5c2e7
      icon.color=0xfff5c2e7
    )
  else
    args+=(
      background.color=0x33222222
      background.border_color=0x00333333
      icon.color=0xffe8e8e8
    )
  fi
done <<< "$workspace_state"

if [ "${#args[@]}" -gt 0 ]; then
  sketchybar "${args[@]}"
fi
