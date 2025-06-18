DOTFILES=$HOME/.dotfiles
use_dotfile() {
    local file_path="$1"

    if [ ! -e "$file_path" ] || [ ! -L "$file_path" ]; then
        rm -rf "$file_path"

        if [ -n "$2" ]; then
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

# symlinks files to the .dotfiles
use_dotfile $HOME/.zprofile
use_dotfile $HOME/.zshrc
use_dotfile $HOME/.gitconfig
use_dotfile $HOME/.tmux.conf
use_dotfile $HOME/.vimrc
use_dotfile $HOME/.config/zed/settings.json .zedconfig
use_dotfile "$HOME/Library/Application Support/com.mitchellh.ghostty/config" .ghosttyconfig

# Check if Xcode Command Line Tools are installed
if ! xcode-select -p &>/dev/null; then
    echo "-- INFO: Xcode Command Line Tools not found. Installing..."
    xcode-select --install
else
    echo "-- INFO: Xcode Command Line Tools already installed."
fi

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
    echo "-- INFO: Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "-- INFO: Homebrew already installed"
fi

# install homebrew deps
echo "-- INFO: Installing brew pkgs..."
brew bundle install --file $DOTFILES/Brewfile

# 'run-once' init cmds
echo "-- INFO: Forcing Zed as default editor"
if test ! $(which duti); then
    echo "-- WARN: 'duti' not found; Zed not set as default editor for plain files"
else
    duti -s dev.zed.Zed public.plain-text all
    duti -s dev.zed.Zed public.unix-executable all
    duti -s dev.zed.Zed public.data all
fi

echo "-- INFO: Installing nvm"
if test ! $(which nvm); then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
else
    echo "-- WARN: nvm already installed"
fi

echo "-- INFO: initializing git-lfs"
git lfs install

echo "-- INFO: setting up git/project directory"
mkdir -p $HOME/xx
