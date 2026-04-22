#!/usr/bin/env bash
set -euo pipefail

DOTFILES=$HOME/.dotfiles
MACOS_MARKER="$HOME/.cache/dotfiles/macos-applied"

reset_prefs=false
for arg in "$@"; do
    case "$arg" in
        --reset-prefs) reset_prefs=true ;;
        *) echo "-- WARN: unknown flag: $arg" ;;
    esac
done

use_dotfile() {
    local file_path="$1"

    if [ ! -e "$file_path" ] || [ ! -L "$file_path" ]; then
        if [ -e "$file_path" ]; then
            read -r -p "-- PROMPT: '$file_path' exists and is not a symlink. Replace? (y/N) " confirm
            if [[ ! "$confirm" =~ ^[Yy] ]]; then
                echo "-- INFO: Skipping '$file_path'"
                return
            fi
        fi
        rm -rf "$file_path"
        mkdir -p "$(dirname "$file_path")"

        if [ -n "${2:-}" ]; then
            local custom_target="$DOTFILES/$2"
            # Use the custom target provided as second parameter
            echo "-- INFO: Creating symlink to target: $file_path -> $custom_target"
            ln -sf "$custom_target" "$file_path"
        else
            # -- Default behavior
            # Extract the filename from the full path
            filename=$(basename "$file_path")
            target="$DOTFILES/$filename"
            echo "-- INFO: Created symlink: $file_path -> $target"
            ln -sf "$target" "$file_path"
        fi
    else
        echo "-- WARN: Not replacing '$file_path'; already exists "
    fi
}

read -r -p "Setup for work? (y/N) " reply

# Check if input starts with y or Y using a regex character class
if [[ "$reply" =~ ^[Yy] ]]; then
    work=true
else
    work=false
fi

if [ "$work" = true ]; then
  echo "-- WARN: setting up for work!"
fi

# symlinks files to the .dotfiles
use_dotfile "$HOME/.zprofile"
use_dotfile "$HOME/.zshrc"
use_dotfile "$HOME/.gitconfig"
use_dotfile "$HOME/.tmux.conf"
use_dotfile "$HOME/.vimrc"
use_dotfile "$HOME/.config/zed/settings.json" .zedconfig
use_dotfile "$HOME/Library/Application Support/com.mitchellh.ghostty/config" .ghosttyconfig

echo "-- INFO: setting up default files & directories"
mkdir -p "$HOME/xx" "$HOME/.config/op/"
touch "$HOME/.env"
touch "$HOME/.config/op/plugins.sh"

# Apply macOS preferences early — independent of brew, so a brew failure
# below doesn't block prefs from applying.
if [ "$reset_prefs" = true ] || [ ! -f "$MACOS_MARKER" ]; then
    echo "-- INFO: setting macOS preferences"
    source "$DOTFILES/.macos"
    mkdir -p "$(dirname "$MACOS_MARKER")"
    touch "$MACOS_MARKER"
else
    echo "-- INFO: macOS preferences already applied; pass --reset-prefs to re-apply"
fi

# Check if Xcode Command Line Tools are installed
if ! xcode-select -p &>/dev/null; then
    echo "-- INFO: Xcode Command Line Tools not found. Installing..."
    xcode-select --install
    echo "-- INFO: Waiting for Xcode Command Line Tools install to finish..."
    until xcode-select -p &>/dev/null; do sleep 5; done
    echo "-- INFO: Xcode Command Line Tools install complete."
else
    echo "-- INFO: Xcode Command Line Tools already installed."
fi

# Check for Homebrew and install if we don't have it
if ! command -v brew >/dev/null 2>&1; then
    echo "-- INFO: Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "-- INFO: Homebrew already installed"
fi

# install homebrew deps. Use `|| warn` so one bad formula/cask doesn't halt
# the rest of setup (e.g. duti below).
echo "-- INFO: Installing brew pkgs..."
brew bundle install --file "$DOTFILES/Brewfile" \
    || echo "-- WARN: some Brewfile entries failed; continuing"

if [ "$work" == false ]; then
    brew bundle install --file "$DOTFILES/mas.Brewfile" \
        || echo "-- WARN: some mas.Brewfile entries failed; continuing"
else
    echo "-- WARN: Installing work brew pkgs and SKIPPING mac apps"
    brew bundle install --file "$DOTFILES/work/Brewfile" \
        || echo "-- WARN: some work/Brewfile entries failed; continuing"
fi

# 'run-once' init cmds
echo "-- INFO: Forcing Zed as default editor"
if ! command -v duti >/dev/null 2>&1; then
    echo "-- WARN: 'duti' not found; Zed not set as default editor for plain files"
else
    # `|| true` since some UTIs (e.g. public.data) may return error -50
    # on newer macOS versions where Launch Services has tightened handlers.
    duti -s dev.zed.Zed public.plain-text all || true
    duti -s dev.zed.Zed public.unix-executable all || true
    duti -s dev.zed.Zed public.data all || true
fi

# Work-only: install Vite+ (https://viteplus.dev)
if [ "$work" = true ] && [ ! -f "$HOME/.vite-plus/env" ]; then
    echo "-- INFO: Installing Vite+"
    curl -fsSL https://vite.plus | bash \
        || echo "-- WARN: Vite+ install failed; continuing"
fi
