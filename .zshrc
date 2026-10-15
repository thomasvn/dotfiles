export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="refined"
plugins=(aliases fzf git kubectl)

# PATH
eval "$(/opt/homebrew/bin/brew shellenv)"
[ -f "$HOME/.google-cloud-sdk/path.zsh.inc" ] && . "$HOME/.google-cloud-sdk/path.zsh.inc"
export PATH="$HOME/.local/bin:$HOME/.krew/bin:$HOME/go/bin:$HOME/.cargo/bin:$HOME/.deno/bin:$HOME/Library/Python/3.11/bin:/opt/homebrew/opt/libpq/bin:$PATH"

source "$ZSH/oh-my-zsh.sh"
source ~/.aliases

# Kubernetes
export USE_GKE_GCLOUD_AUTH_PLUGIN=True
export KUBECONFIG="./.kubeconfig:$HOME/.kube/config"  # Prefer local kubeconfig
[ -f "$HOME/.google-cloud-sdk/completion.zsh.inc" ] && . "$HOME/.google-cloud-sdk/completion.zsh.inc"
if (( $+commands[kubecolor] )); then
  alias kubectl="kubecolor"
  compdef kubecolor=kubectl
  alias watch='KUBECOLOR_FORCE_COLORS=true watch --color '
fi
