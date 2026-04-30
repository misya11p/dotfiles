# dotfiles

自分用dotfiles管理リポジトリ

## 準備


### [Homebrew](https://brew.sh)のインストール (macOS)

次のコマンドを実行し、指示に従ってパスを通す

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### zsh&gitのインストール (Linux)

次のコマンドを実行

```sh
sudo apt update
sudo apt install zsh git
chsh -s $(which zsh)
zsh
```

## Setup

リポジトリをクローン

```sh
git clone https://github.com/misya11p/dotfiles ~/.dotfiles
```

次のコマンドを実行。zshファイルの設定とパッケージのインストール。

```sh
. ~/.dotfiles/scripts/setup.sh
```
