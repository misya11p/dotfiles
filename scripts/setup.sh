#!/bin/bash

# ======================================================================
# zsh configuration setup
# ======================================================================

DOTFILES_ROOT=$(dirname "$(dirname "$(readlink -f "$0")")")

DIR_BACKUP="$DOTFILES_ROOT/backup/$(date +'%Y%m%d%H%M%S')"
mkdir -p $DIR_BACKUP

[ ! -d "$HOME/.config/zsh" ] && mkdir -p "$HOME/.config/zsh"

[ -f "$HOME/.zshenv" ] && mv "$HOME/.zshenv" "$DIR_BACKUP/.zshenv.bak"
[ -f "$HOME/.zshrc" ] && mv "$HOME/.zshrc" "$DIR_BACKUP/.zshrc.bak"
[ -f "$HOME/.config/zsh/.zshenv" ] && mv "$HOME/.config/zsh/.zshenv" "$DIR_BACKUP/.zshenv_config.bak"
[ -f "$HOME/.config/zsh/.zshrc" ] && mv "$HOME/.config/zsh/.zshrc" "$DIR_BACKUP/.zshrc_config.bak"

ZDOTDIR_CONFIG='export ZDOTDIR="$HOME"/.config/zsh'
if [ -f /etc/zshenv ]; then
    echo "$ZDOTDIR_CONFIG" | sudo tee -a /etc/zshenv > /dev/null
elif [ -f /etc/zsh/zshenv ]; then
    echo "$ZDOTDIR_CONFIG" | sudo tee -a /etc/zsh/zshenv > /dev/null
else
    echo "Notice: /etc/zshenv or /etc/zsh/zshenv not found. Please set ZDOTDIR manually if needed."
fi

source $DOTFILES_ROOT/zsh/zshenv
echo "Completed setting up zsh configuration files."

# ======================================================================
# Install tools and applications
# ======================================================================

## macOS
if [[ "$(uname)" == "Darwin" ]]; then
  brew install bat
  brew install eza
  brew install dua-cli
  brew install fzf
  brew install fastfetch
  brew install zoxide
  brew install neovim
  brew install uv
  brew install mise
  brew install gh
  brew install rich
  brew install ripgrep
  brew install duf
  brew install delta
  brew install btop
  brew install atuin
  brew install lazygit
  brew install trash
  brew install font-0xproto-nerd-font

  curl https://sh.rustup.rs -sSf | sh # rust

## Linux (Ubuntu/Debian)
elif [[ "$(uname)" == "Linux" ]]; then
  sudo apt update
  sudo apt install -y gcc curl wget file unzip
  sudo apt install -y eza fzf ripgrep fastfetch trash-cli gh duf lazygit

  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh # zoxide
  curl -LsSf https://astral.sh/uv/install.sh | sh # uv
  curl https://sh.rustup.rs -sSf | sh # rust
  curl https://mise.run | sh # mise

  $HOME/.local/share/cargo/bin/cargo install atuin bat git-delta dua-cli btop

  # neovim
  curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
  sudo rm -rf /opt/nvim-linux-x86_64
  sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
  sudo ln -s /opt/nvim-linux-x86_64/bin/nvim $HOME/.local/bin/nvim
  rm nvim-linux-x86_64.tar.gz

  # rich-cli
  $HOME/.local/bin/uv tool install rich-cli
fi

## common

### lazyvim
git clone https://github.com/LazyVim/starter $HOME/.config/nvim && rm -rf $HOME/.config/nvim/.git

### zinit
bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"

## finish
ZDOTDIR="$HOME/.config/zsh"
rm $ZDOTDIR/.zshrc
rm $ZDOTDIR/.zshenv
. $DOTFILES_ROOT/scripts/link.sh
echo "Completed installing tools and applications. Please restart your terminal to apply the changes."