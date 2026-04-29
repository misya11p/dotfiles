# Install necessary packages via Homebrew

## commons
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

git clone https://github.com/LazyVim/starter ~/.config/nvim && rm -rf ~/.config/nvim/.git

bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"

## macOS
if [[ "$(uname)" == "Darwin" ]]; then
  brew install trash
  brew install font-0xproto-nerd-font

## Linux
elif [[ "$(uname)" == "Linux" ]]; then
  brew install trash-cli
fi
