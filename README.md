# dotfiles

自分用dotfiles管理リポジトリ

## 準備

### 1. zshのインストール

- macOSの場合はデフォルトで入っているので不要
- Linuxの場合は以下のコマンドでインストール

```sh
sudo apt update
sudo apt install zsh
chsh -s $(which zsh)
```

### 2. [Homebrew](https://brew.sh)のインストール

次のコマンドを実行し、指示に従ってパスを通す

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Linuxの場合は[こちら](https://docs.brew.sh/Homebrew-on-Linux)を参照

### 3. [ghq](https://github.com/x-motemen/ghq)のインストール

次のコマンドを実行

```sh
brew install ghq
```

### 4. dotfilesのクローン

次のコマンドを実行

```sh
curl -fsSL https://raw.githubusercontent.com/misya11p/dotfiles/main/scripts/clone.sh | bash
```

## install & setup

本リポジトリに移動

```sh
cd $HOME/.repo/github.com/misya11p/dotfiles
```

次のコマンドを実行。環境変数などの設定を行う。

```sh
sh scripts/setup.sh
source $HOME/.config/zsh/.zshenv
```

次のコマンドを実行。パッケージインストール。

```sh
sh scripts/install.sh
source $HOME/.config/zsh/.zshrc
```
