# THEME
ZSH_THEME="refined"

# PLUGINS
plugins=(
  aliases
  aws
  fzf
  git
  kubectl
  ##### EXTERNAL #####
  alias-tips
  zsh-autosuggestions
  # zsh-completions
  zsh-kubectl-prompt
  zsh-syntax-highlighting
)

# PATH
export ZSH="$HOME/.oh-my-zsh"
eval "$(/opt/homebrew/bin/brew shellenv)"
if [ -f '/Users/thomasnguyen/.google-cloud-sdk/path.zsh.inc' ]; then . '/Users/thomasnguyen/.google-cloud-sdk/path.zsh.inc'; fi
export PATH="${PATH}:${HOME}/.krew/bin"
export PATH="${PATH}:/Users/thomasnguyen/Library/Python/3.11/bin"
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"
export PATH="${PATH}:/Users/thomasnguyen/.cargo/bin"

# SCRIPTS & ALIASES
source $ZSH/oh-my-zsh.sh
source ~/.aliases

# KUBECTL PROMPT
RPROMPT='%{$fg[blue]%}($ZSH_KUBECTL_PROMPT)%{$reset_color%}'
export USE_GKE_GCLOUD_AUTH_PLUGIN=True

# COMMAND COMPLETIONS
[[ $commands[kubectl] ]] && source <(kubectl completion zsh)  # kubectl
if [ -f '/Users/thomasnguyen/.google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/thomasnguyen/.google-cloud-sdk/completion.zsh.inc'; fi  # gcloud

# SHELL
# eval "$(starship init zsh)"

