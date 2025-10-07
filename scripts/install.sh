# Install necessary packages via Homebrew

## commons
brew install bat
brew install eza
brew install dua-cli
brew install fzf
brew install fastfetch
brew install zoxide
brew install pure
bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
brew install neovim
brew install uv
brew install volta
VOLTA_HOME="$XDG_DATA_HOME"/volta volta install node
brew install gh

## macOS
if [[ "$(uname)" == "Darwin" ]]; then
  brew install macmon
  brew install trash
  brew install font-0xproto-nerd-font

## Linux
elif [[ "$(uname)" == "Linux" ]]; then
  brew install trash-cli
fi


