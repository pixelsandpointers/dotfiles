#!/bin/bash
# Flatpak Obsidian Wayland configuration
# Fixes resolution issues by enabling Wayland support

flatpak override --user md.obsidian.Obsidian \
  --socket=wayland \
  --env=OBSIDIAN_USE_WAYLAND=1 \
  --env=ELECTRON_ENABLE_WAYLAND=1 \
  --env=ELECTRON_OZONE_PLATFORM_HINT=wayland

echo "Obsidian Wayland configuration applied."
echo "Restart Obsidian for changes to take effect."
