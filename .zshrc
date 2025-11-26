#zmodload zsh/zprof

# Add deno completions to search path
#if [[ ":$FPATH:" != *":/Users/andrest/.zsh/completions:"* ]]; then export FPATH="/Users/andrest/.zsh/completions:$FPATH"; fi
source $HOME/.env

export DOTFILES=$HOME/.dotfiles
export EDITOR="zed --wait"

add_to_path() {
  if [[ -d "$1" ]] && [[ ":$PATH:" != *":$1:"* ]]; then
    export PATH="$1:$PATH"
  fi
}

# PATH env
add_to_path "/opt/homebrew/opt/postgresql@17/bin"
add_to_path "$HOME/.local/bin"
add_to_path "/opt/homebrew/opt/openjdk@11/bin"
add_to_path "$HOME/.opengrep/cli/latest"

# aliases
alias j="just"
alias finder="open"
alias nextdns="sh -c \"\$(curl -s https://nextdns.io/diag)\""
alias nvim="vi"
alias gd="git diff"
alias ga="git add"
alias gc="git commit"
alias gl="git log --oneline --reverse -10"
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

source $HOME/.config/op/plugins.sh
. "/Users/andrest/.deno/env"

# bun completions
#[ -s "/Users/andrest/.bun/_bun" ] && source "/Users/andrest/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

#zprof
