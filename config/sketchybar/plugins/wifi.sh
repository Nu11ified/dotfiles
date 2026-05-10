#!/usr/bin/env bash
set -euo pipefail

device="$(networksetup -listallhardwareports 2>/dev/null | awk '/Wi-Fi|AirPort/{getline; print $2; exit}')"
label="offline"

if [ -n "${device:-}" ]; then
  ssid="$(ipconfig getsummary "$device" 2>/dev/null | awk -F' : ' '/ SSID /{print $2; exit}')"
  if [ -z "$ssid" ]; then
    ssid="$(networksetup -getairportnetwork "$device" 2>/dev/null | sed 's/^Current Wi-Fi Network: //')"
  fi
  if [ -n "$ssid" ] && [ "$ssid" != "You are not associated with an AirPort network." ]; then
    label="$ssid"
  elif ifconfig "$device" 2>/dev/null | grep -q 'status: active'; then
    ip="$(ipconfig getifaddr "$device" 2>/dev/null || true)"
    label="${ip:-online}"
  fi
fi

if [ -n "${NAME:-}" ]; then
  sketchybar --set "$NAME" label="$label"
else
  printf "%s\n" "$label"
fi
