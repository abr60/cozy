#!/usr/bin/env bash
ln -sf "$HOME/.config/hypr/animations/fast.lua" "$HOME/.config/hypr/animations.lua"
hyprctl reload >/dev/null 2>&1 || true
