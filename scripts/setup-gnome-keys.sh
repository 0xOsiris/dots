#!/bin/bash

# GNOME Keybinding Setup Script
# Sets up custom keyboard shortcuts for window management
# Run this after installing dotfiles: ~/.dotfiles/scripts/setup-gnome-keys.sh

set -e

echo "Setting up GNOME keyboard shortcuts..."

# Get existing custom keybindings
EXISTING=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings 2>/dev/null || echo "[]")

# Define our custom keybindings path
CUSTOM_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"

# =============================================================================
# Custom Keybinding 0: Dropdown Terminal (F12)
# =============================================================================
echo "  - F12: Toggle Ghostty dropdown terminal"

gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:${CUSTOM_PATH}/custom0/ \
    name "Ghostty Dropdown"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:${CUSTOM_PATH}/custom0/ \
    command "ghostty --quick-terminal"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:${CUSTOM_PATH}/custom0/ \
    binding "F12"

# =============================================================================
# Custom Keybinding 1: New Ghostty Window (Super+Shift+Return)
# =============================================================================
echo "  - Super+Shift+Return: New Ghostty window"

gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:${CUSTOM_PATH}/custom1/ \
    name "New Ghostty Window"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:${CUSTOM_PATH}/custom1/ \
    command "ghostty"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:${CUSTOM_PATH}/custom1/ \
    binding "<Super><Shift>Return"

# =============================================================================
# Custom Keybinding 2: Launch Neovim (Super+Shift+E)
# =============================================================================
echo "  - Super+Shift+E: Launch Neovim in Ghostty"

gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:${CUSTOM_PATH}/custom2/ \
    name "Neovim"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:${CUSTOM_PATH}/custom2/ \
    command "ghostty -e nvim"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:${CUSTOM_PATH}/custom2/ \
    binding "<Super><Shift>e"

# =============================================================================
# Register all custom keybindings
# =============================================================================
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings \
    "['${CUSTOM_PATH}/custom0/', '${CUSTOM_PATH}/custom1/', '${CUSTOM_PATH}/custom2/']"

echo ""
echo "GNOME keyboard shortcuts configured!"
echo ""
echo "Shortcuts:"
echo "  F12              - Toggle dropdown terminal"
echo "  Super+Shift+Return - New Ghostty window"
echo "  Super+Shift+E    - Open Neovim in Ghostty"
echo ""
echo "Note: You may need to log out and back in for changes to take effect."
