# flatdir

複数のディレクトリを一元管理し、fzfを使った高速なディレクトリ移動・管理ができるCLIツールです。

## 概要

プロジェクトディレクトリを複数のルートディレクトリでflat（階層なし）に管理し、以下のことができます：

- fzfによる高速なディレクトリ選択・移動
- 不要になったプロジェクトのアーカイブ・削除
- 新しいプロジェクトの作成やGitリポジトリのクローン
- zoxideスコアによる使用頻度順の表示

## セットアップ

1. シェルのエイリアスを設定してください：
```bash
alias flatdir="/path/to/flatdir/entrypoint.sh"
```

2. ディレクトリ移動を有効にするため、以下のwrapper関数を追加してください：
```bash
fd() {
    local selected
    selected=$(flatdir)
    if [[ -n "$selected" ]]; then
        cd "$selected"
    fi
}
```

## 依存関係

以下のコマンドが必要です：
- `fzf` - ディレクトリ選択UI
- `eza` - ディレクトリ一覧表示（preview用）
- `rich` - READMEファイルの表示（preview用）
- `gh` - GitHubリポジトリ作成（`init --git`使用時のみ）
- `zoxide` - 使用頻度順のソート

## 基本的な使い方

### ディレクトリ移動
```bash
# fzfでディレクトリを選択して移動
fd
```
管理対象ディレクトリ内のプロジェクトをfzfで一覧表示し、選択したディレクトリに移動します。プレビューでREADMEの内容やディレクトリの中身を確認できます。

### 管理対象ディレクトリの設定
```bash
# 管理対象ディレクトリを追加
flatdir track ~/Projects

# 管理対象ディレクトリ一覧を表示
flatdir list

# 管理対象ディレクトリを削除
flatdir untrack
```

**推奨事項**: このツールはプロジェクトをフラット（階層なし）で管理する思想で作られています。複数の管理対象ディレクトリを設定することは可能ですが、1つのディレクトリですべてのプロジェクトを管理する方がシンプルで使いやすくなります。

### 新しいプロジェクトの作成
```bash
# 新しいディレクトリを作成
flatdir init my-project

# GitHubリポジトリ付きでプロジェクトを作成
flatdir init my-repo --git
```

### Gitリポジトリのクローン
```bash
# 既存のリポジトリをクローン
flatdir clone https://github.com/user/repo.git
```

### プロジェクトの整理
```bash
# 使わなくなったプロジェクトをアーカイブ
flatdir archive

# アーカイブしたプロジェクトを復元
flatdir restore

# プロジェクトを完全に削除
flatdir remove
```

アーカイブ機能では、`.venv`、`node_modules`、`__pycache__`などの重いディレクトリの削除を提案し、容量を節約できます。

## 使用例

```bash
# 管理対象ディレクトリを追加
flatdir track ~/Projects

# ディレクトリ一覧から選択して移動
fd

# 新しいプロジェクトを作成
flatdir init my-new-project

# GitHubリポジトリ付きでプロジェクト作成
flatdir init my-repo --git

# Gitリポジトリをクローン
flatdir clone https://github.com/user/repo

# プロジェクトをアーカイブ
flatdir archive

# アーカイブしたプロジェクトを復元
flatdir restore

# 不要なプロジェクトを削除
flatdir remove
```
