# dotfiles

自分用dotfiles管理リポジトリ

## 準備

### zshのインストール

- macOSの場合はデフォルトで入っているので不要
- Linuxの場合は以下のコマンドでインストール

```sh
sudo apt update
sudo apt install zsh
chsh -s $(which zsh)
zsh
```

### [Homebrew](https://brew.sh)のインストール（macOS）

次のコマンドを実行し、指示に従ってパスを通す

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## Setup

リポジトリをクローン

```sh
git clone https://github.com/misya11p/dotfiles ~/.dotfiles
```

次のコマンドを実行。zshファイルの設定とパッケージのインストール。

```sh
./scripts/setup.sh
```
