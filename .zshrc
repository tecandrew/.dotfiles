export DOTFILES=$HOME/.dotfiles
export EDITOR="zed --wait"

add_to_path() {
  if [[ -d "$1" ]] && [[ ":$PATH:" != *":$1:"* ]]; then
    export PATH="$1:$PATH"
  fi
}

# PATH env
add_to_path "/opt/homebrew/opt/postgresql@17/bin"

# aliases
alias finder="open"
alias nextdns="sh -c \"\$(curl -s https://nextdns.io/diag)\""
alias nvim="vi"
alias gd="git diff"
alias ga="git add"
alias gc="git commit"
alias gl="git log --oneline"
alias gll="git log"
alias l="ls"
alias ll="ls -lah"
alias k="kubectl"
alias tf="terraform"
alias gcl="gitlab-ci-local"
alias neofetch="fastfetch"

# `ghosttic <ssh_host>`
function ghosttic() {
  infocmp -x | ssh $1 -- tic -x -
  ssh -A $1
}
alias ghosttic="ghosttic"

# fnm (faster nvm)
eval "$(fnm env --use-on-cd --shell zsh)"

# better zsh
eval "$(starship init zsh)"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

source $HOME/.env
source /Users/AndresT/.config/op/plugins.sh
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
