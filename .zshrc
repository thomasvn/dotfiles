export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="refined"
plugins=(aliases aws fzf git kubectl)

# PATH
eval "$(/opt/homebrew/bin/brew shellenv)"
[ -f "$HOME/.google-cloud-sdk/path.zsh.inc" ] && . "$HOME/.google-cloud-sdk/path.zsh.inc"
path=(
  ~/.local/bin
  ~/.krew/bin
  ~/go/bin
  ~/.cargo/bin
  ~/.deno/bin
  ~/Library/Python/3.11/bin
  /opt/homebrew/opt/libpq/bin
  /opt/homebrew/share/google-cloud-sdk/bin
  $path
)

source "$ZSH/oh-my-zsh.sh"
source ~/.aliases

# Languages
export RUSTC_WRAPPER=~/.cargo/bin/sccache
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

# Kubernetes
export KUBECONFIG="./.kubeconfig:$HOME/.kube/config:$HOME/.kube/config-apptio-clusters"  # Prefer local kubeconfig
[ -f "$HOME/.google-cloud-sdk/completion.zsh.inc" ] && . "$HOME/.google-cloud-sdk/completion.zsh.inc"
if (( $+commands[kubecolor] )); then
  alias kubectl="kubecolor"
  compdef kubecolor=kubectl
  alias watch='KUBECOLOR_FORCE_COLORS=true watch --color '
fi

# Podman as Docker
alias docker=podman
alias docker-compose=podman-compose
export DOCKER_HOST="unix://$HOME/.local/share/containers/podman/machine/podman.sock"

# Misc
export HOMEBREW_UPGRADE_RESTART_SERVICES=true
[ -f "$HOME/.pingidentity/config" ] && . "$HOME/.pingidentity/config"
[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

# Dotfiles daily sync
if [ -z "$(find ~/code/dotfiles/.git/last-sync -mtime -1 2>/dev/null)" ]; then
  touch ~/code/dotfiles/.git/last-sync && (~/code/dotfiles/sync.sh >/dev/null 2>&1 &)
fi
