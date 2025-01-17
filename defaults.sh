# macOS defaults

# Screenshots
defaults write com.apple.screencapture location ~/Downloads
killall SystemUIServer

# Dock
defaults write com.apple.dock autohide -bool true
killall Dock
