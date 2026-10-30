#!/usr/bin/env bash
# macOS settings taken from the old laptop.

set -euo pipefail

# Dock
defaults write com.apple.dock autohide -bool false
defaults write com.apple.dock tilesize -int 55

# Finder: list view, show all extensions
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Scrolling: "natural" direction off
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Trackpad: tap to click off
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool false

killall Dock Finder 2>/dev/null || true
echo "Done. Some settings need logout. Keyboard layouts (U.S. + Russian) — add manually in System Settings."
