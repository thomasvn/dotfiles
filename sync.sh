#!/bin/sh
# Links dotfiles into place, pulls remote changes, and stages local edits for review.
cd ~/code/dotfiles || exit 1

# Back up a real file once, then replace it with a symlink to the repo
link() {
  [ -e "$2" ] && [ ! -L "$2" ] && mv "$2" "$2.bak"
  ln -sfn ~/code/dotfiles/$1 "$2"
}

link .zshrc ~/.zshrc
link .aliases ~/.aliases
link .vimrc ~/.vimrc
link .claude/CLAUDE.md ~/.claude/CLAUDE.md
link .claude/CLAUDE.md ~/.codex/AGENTS.md
link .oh-my-zsh/completions ~/.oh-my-zsh/completions
link .ghostty/config ~/Library/Application\ Support/com.mitchellh.ghostty/config

git pull --rebase --autostash || exit 1

# Stage only; commit manually
git add -A
