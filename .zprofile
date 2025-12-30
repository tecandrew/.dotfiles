export HOMEBREW_NO_AUTO_UPDATE=1
#export HOMEBREW_CASK_OPTS="--appdir=~/Applications"

export COMPOSE_BAKE=true
# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
eval "$(/opt/homebrew/bin/brew shellenv)"
