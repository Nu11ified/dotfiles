#!/usr/bin/env bash
set -euo pipefail

state_file="${XDG_STATE_HOME:-$HOME/.local/state}/aerospace/enabled"
workspace_state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/sketchybar/workspaces"
aerospace_query="$HOME/.config/aerospace/scripts/aerospace-query"
args=()
refresh_apps="${FULL_REFRESH:-0}"
focused_workspace=""
focused_app=""

app_icon() {
  case "$1" in
    Zen | Helium | Safari | "Google Chrome" | Firefox | Brave*) printf '󰖟' ;;
    Ghostty | Terminal | Termius | Warp | iTerm2 | Alacritty) printf '' ;;
    ChatGPT | Claude | Codex) printf '󰚩' ;;
    Code | Cursor | "Visual Studio Code" | Xcode | Zed) printf '󰨞' ;;
    Messages | Discord | Slack | "Microsoft Teams" | Teams) printf '󰍡' ;;
    Emacs) printf '' ;;
    Finder) printf '󰉋' ;;
    "System Settings" | "System Information") printf '󰒓' ;;
    Music | Spotify) printf '󰎄' ;;
    *) printf '󰘔' ;;
  esac
}

if [ "${SENDER:-}" = "display_change" ] || [ "${SENDER:-}" = "system_woke" ]; then
  if [ -x "$HOME/.config/displayplacer/apply-layout" ]; then
    "$HOME/.config/displayplacer/apply-layout" >/dev/null 2>&1 || true
  fi
  sleep 0.25
  refresh_apps=1
fi

if [ -r "$state_file" ] && [ "$(cat "$state_file")" = "off" ]; then
  for workspace in 1 2 3 4 5 6 7 8 9; do
    args+=(
      --set "space.$workspace"
      background.color=0x00000000
      background.border_color=0x00000000
      icon.color=0xff6c6875
      label.color=0xff6c6875
    )
  done
  sketchybar "${args[@]}"
  exit 0
fi

if [ "${SENDER:-}" = "aerospace_focus_change" ]; then
  focused_window="$("$aerospace_query" list-windows --focused --format '%{workspace}|%{app-name}' 2>/dev/null || true)"
  focused_workspace="${focused_window%%|*}"
  focused_app="${focused_window#*|}"
  case "$focused_workspace" in
    1|2|3|4|5|6|7|8|9)
      if [ -n "$focused_app" ]; then
        mkdir -p "$workspace_state_dir"
        printf '%s\n' "$focused_app" > "$workspace_state_dir/$focused_workspace"
        sketchybar --set "space.$focused_workspace" \
          label="$(app_icon "$focused_app")" \
          label.drawing=on \
          background.color=0xffffffff \
          background.border_color=0xffffffff \
          icon.color=0xff111111 \
          label.color=0xff111111
      fi
      ;;
  esac
  exit 0
fi

workspace_state="$(
  "$aerospace_query" list-workspaces --all \
    --format '%{workspace}|%{workspace-is-focused}|%{workspace-is-visible}|%{monitor-appkit-nsscreen-screens-id}' \
    2>/dev/null || true
)"

# AeroSpace reports the macOS DirectDisplayID, while SketchyBar's display=
# setting expects its arrangement-id. They are not guaranteed to have the
# same value, especially when monitors are arranged on both sides of the Mac.
display_map="$(
  sketchybar --query displays 2>/dev/null \
    | /usr/bin/jq -r '.[] | "\(.DirectDisplayID)|\(."arrangement-id")"' \
    2>/dev/null || true
)"

window_state=""
if [ "$refresh_apps" = "1" ]; then
  window_state="$(
    "$aerospace_query" list-windows --all \
      --format '%{workspace}|%{window-id}|%{app-name}' \
      2>/dev/null || true
  )"
fi

while IFS='|' read -r workspace focused visible display_id; do
  case "$workspace" in
    1|2|3|4|5|6|7|8|9) ;;
    *) continue ;;
  esac

  args+=(--set "space.$workspace")

  if [ "$refresh_apps" = "1" ]; then
    last_app=""
    if [ -r "$workspace_state_dir/$workspace" ]; then
      last_app="$(cat "$workspace_state_dir/$workspace")"
    fi
    if [ -z "$last_app" ] || ! printf '%s\n' "$window_state" | awk -F '|' -v workspace="$workspace" -v app="$last_app" '$1 == workspace && $3 == app { found=1 } END { exit !found }'; then
      last_app="$(printf '%s\n' "$window_state" | awk -F '|' -v workspace="$workspace" '$1 == workspace { print $3; exit }')"
    fi
    if [ -n "$last_app" ]; then
      args+=(label="$(app_icon "$last_app")" label.drawing=on)
    else
      args+=(label="·" label.drawing=on)
    fi
  fi

  sketchybar_display_id="$(
    printf '%s\n' "$display_map" \
      | awk -F '|' -v direct_display_id="$display_id" \
        '$1 == direct_display_id { print $2; exit }'
  )"
  if [ -n "$sketchybar_display_id" ]; then
    args+=(display="$sketchybar_display_id")
  fi

  if [ "$focused" = "true" ]; then
    args+=(
      background.color=0xffffffff
      background.border_color=0xffffffff
      icon.color=0xff111111
      label.color=0xff111111
    )
  elif [ "$visible" = "true" ]; then
    args+=(
      background.color=0x445c5366
      background.border_color=0xfff5c2e7
      icon.color=0xfff5c2e7
      label.color=0xfff5c2e7
    )
  else
    args+=(
      background.color=0x33222222
      background.border_color=0x00333333
      icon.color=0xffe8e8e8
      label.color=0xffe8e8e8
    )
  fi
done <<< "$workspace_state"

if [ "${#args[@]}" -gt 0 ]; then
  sketchybar "${args[@]}"
fi
