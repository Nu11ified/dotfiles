#!/usr/bin/env bash
set -euo pipefail

workspace="${1:?workspace is required}"
focused="${FOCUSED:-}"

if [ -z "$focused" ] && command -v aerospace >/dev/null 2>&1; then
  focused="$(aerospace list-workspaces --focused 2>/dev/null || true)"
fi

if [ "$workspace" = "$focused" ]; then
  sketchybar --set "$NAME" \
    background.color=0xffffffff \
    background.border_color=0xffffffff \
    icon.color=0xff111111 \
    label.drawing=off \
    label.color=0xff111111
else
  sketchybar --set "$NAME" \
    background.color=0x33222222 \
    background.border_color=0x00333333 \
    icon.color=0xffe8e8e8 \
    label.drawing=off \
    label.color=0xffa8a8a8
fi
