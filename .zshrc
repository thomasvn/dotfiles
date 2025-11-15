# THEME
ZSH_THEME="refined"

# OMZ PLUGINS
plugins=(
  aliases
  fzf
  git
  kubectl
)

# PATH
export ZSH="$HOME/.oh-my-zsh"
eval "$(/opt/homebrew/bin/brew shellenv)"
if [ -f "$HOME/.google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/.google-cloud-sdk/path.zsh.inc"; fi
export PATH="${PATH}:${HOME}/.krew/bin"
export PATH="${PATH}:${HOME}/Library/Python/3.11/bin"
export PATH="${PATH}:${HOME}/go/bin"
export PATH="${PATH}:${HOME}/.cargo/bin"
export PATH="${PATH}:/opt/homebrew/share/google-cloud-sdk/bin"
export PATH="${PATH}:/opt/homebrew/opt/libpq/bin"

# SCRIPTS & ALIASES
source ~/.aliases

# KUBERNETES
if [ -s "$(command -v kubecolor)" ]; then
  alias kubectl="kubecolor"
  compdef kubecolor=kubectl
  alias watch='KUBECOLOR_FORCE_COLORS=true watch --color '
fi
export USE_GKE_GCLOUD_AUTH_PLUGIN=True
[[ $commands[kubectl] ]] && source <(kubectl completion zsh)
if [ -f '/Users/thomasnguyen/.google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/thomasnguyen/.google-cloud-sdk/completion.zsh.inc'; fi  # gcloud
export KUBECONFIG="./.kubeconfig:${HOME}/.kube/config"  # Prioritize local kubeconfig
