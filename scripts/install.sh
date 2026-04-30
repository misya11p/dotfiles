#!/bin/bash

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

## Linux
elif [[ "$(uname)" == "Linux" ]]; then
  sudo apt update
  sudo apt install -y gcc curl eza fzf ripgrep fastfetch trash-cli gh duf lazygit

  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh # zoxide
  curl -LsSf https://astral.sh/uv/install.sh | sh # uv
  curl https://sh.rustup.rs -sSf | sh # rust
  curl https://mise.run | sh # mise

  cargo install atuin bat git-delta dua-cli btop

  # neovim
  curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
  sudo rm -rf /opt/nvim-linux-x86_64
  sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
  sudo ln -s /opt/nvim-linux64/bin/nvim ~/.local/bin/nvim
  rm nvim-linux-x86_64.tar.gz

  # rich-cli
  ~/.local/bin/uv tool install rich-cli
fi

## common

### neovim
git clone https://github.com/LazyVim/starter ~/.config/nvim && rm -rf ~/.config/nvim/.git

### zinit
bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
rm ~/.zshrc