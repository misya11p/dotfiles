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
brew install volta
volta install node
brew install gh
brew install rich
brew install ripgrep
brew install tlrc
brew install duf

## macOS
if [[ "$(uname)" == "Darwin" ]]; then
  brew install macmon
  brew install trash
  brew install font-0xproto-nerd-font

## Linux
elif [[ "$(uname)" == "Linux" ]]; then
  brew install trash-cli
fi


