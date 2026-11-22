#!/bin/sh
# Links dotfiles into place, pulls remote changes, and stages local edits for review.
cd ~/code/dotfiles || exit 1

# Back up a real file once, then replace it with a symlink to the repo
link() {
  [ -e "$2" ] && [ ! -L "$2" ] && mv "$2" "$2.bak"
  mkdir -p "$(dirname "$2")"
  ln -sfn ~/code/dotfiles/$1 "$2"
}

link .zshrc ~/.zshrc
link .aliases ~/.aliases
link .vimrc ~/.vimrc
link .claude/CLAUDE.md ~/.claude/CLAUDE.md
link .claude/CLAUDE.md ~/.codex/AGENTS.md
link .claude/CLAUDE.md ~/.kiro/steering/AGENTS.md
link .claude/CLAUDE.md ~/.config/amp/AGENTS.md
# Per skill, so Claude's account-managed skills/synced stays out of the repo
# Back up a real skill folder outside skills/, or link()'s .bak copy loads as a duplicate skill
for s in .claude/skills/*/; do
  name=$(basename "$s")
  for dir in ~/.claude/skills ~/.kiro/skills; do # Claude Code, Kiro CLI
    [ -d "$dir/$name" ] && [ ! -L "$dir/$name" ] && mkdir -p "$dir.bak" && mv "$dir/$name" "$dir.bak/"
    link "${s%/}" "$dir/$name"
  done
done
link .amp/settings.json ~/.config/amp/settings.json
link .oh-my-zsh/completions ~/.oh-my-zsh/completions
link .ghostty/config ~/Library/Application\ Support/com.mitchellh.ghostty/config

# KiroCrew rewrites its config files, so pin shared settings via its CLI instead of symlinking
if command -v kirocrew >/dev/null; then
  # Repo path too: KiroCrew won't follow ~/.claude/skills links that point outside its extra paths
  kirocrew config set --local skills.extra_paths "[\"$HOME/code/dotfiles/.claude/skills\", \"$HOME/.claude/skills\"]"
  kirocrew config set --local agent.yolo_duration until_shutdown
  kirocrew config set --local agent.chat_turn_timeout_secs 86400
  kirocrew config set --local dashboard.prevent_sleep true
fi

git pull --rebase --autostash || exit 1

# Stage only; commit manually
git add -A
