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

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# better zsh
eval "$(starship init zsh)"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
