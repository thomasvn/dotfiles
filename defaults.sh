# macOS defaults

# Screenshots
defaults write com.apple.screencapture location ~/Downloads
killall SystemUIServer

# Dock
defaults write com.apple.dock autohide -bool true
killall Dock

# Daily shutdown at 23:59:00
sudo pmset repeat shutdown MTWRFSU 22:00:00

# Checking and removing schedules
# $ pmset -g sched
# $ sudo pmset repeat cancel
