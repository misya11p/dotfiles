# flatdir 仕様書

## 概要

管理するディレクトリ群を全て一つのルートディレクトリでflatに管理して、自由にアーカイブして非表示にしたり、コマンド一つでfzf使ってリスト表示して自由にcdしたりできるcliツール

- 自分用に使う CLI ツール。
- entrypoint はリポジトリ直下に `entrypoint.sh` を置き、alias（例: `alias flatdir="path/to/entrypoint.sh"`）で呼ぶ前提。

あなたLLM はこの README を元に実装する。不足仕様があれば必ずユーザーに質問すること。

## 方針

* shell script は **絶対に 1 ファイルに詰めない**
* スパゲティコード禁止
* 関数は責務分離
* set -eu の利用、エラー処理を明確に
* 外部コマンド（fzf, eza, rich, gh）は安全に実行し、失敗時は即エラーにする
* 必要なら POSIX ではなく bash 前提で書いていい
* mv / rm まわりは必ず確認を挟む

## ディレクトリ構成

```
.
├── entrypoint.sh      # サブコマンドの分岐だけ書く
├── lib/
│   ├── common.sh      # 共通関数・configロード
│   ├── add.sh
│   ├── list.sh
│   ├── fzf_select.sh
│   ├── archive.sh
│   ├── restore.sh
│   ├── remove.sh
│   ├── init.sh
│   └── clone.sh
└── config/
    └── config         # key=value 形式で管理対象一覧など
```

`entrypoint.sh` は lib/common.sh を読み込み、
それ以降の処理は lib/*.sh に丸投げする構造にする。

## コマンド仕様

### flatdir track <path>
* 管理対象ディレクトリを config に追加
* path がディレクトリじゃない場合や存在していない場合はエラー
* 既に登録済みならその旨表示して終了

### flatdir untrack
* fzf で管理対象ディレクトリ（監視対象root）を選び、config から削除

### flatdir list
* 管理対象ディレクトリ一覧を表示

### flatdir
* fzf で「管理対象ディレクトリ直下のディレクトリ（深さ1）」をリスト化
* 表示順は zoxide score を利用
* preview
  * README があれば rich
  * なければ eza -l
* 選ばれたパスを stdout に出すだけ（cd は wrapper 側任せ）

### flatdir remove
* fzf で選択し rm に移動

### flatdir archive
* fzf で選択し `$FLATDIR_DIR_ARCHIVE` へ移動
* 以下のディレクトリを削除候補として表示し、削除するか確認
  * .venv
  * node_modules
  * __pycache__
  * etc
* デフォルト削除はしない。必ずユーザ確認。

### flatdir restore
* archive から元の場所へ戻す
* 既に同名の path がある場合はエラーを出して中断

### flatdir init <name> [--git]
* 管理対象ディレクトリのどれかを選び、その下に name を作成
* `--git` がある場合、gh コマンドでリポジトリ作成 → clone
* gh が無い場合は丁寧にエラー

### flatdir clone <git-url>
* 管理対象ディレクトリを選んで clone
* 衝突時は上書き確認

## common.sh が持つべきもの

* 設定ファイル読み込み（.config/flatdir/config）
* エラー関数
  ```
  die() { echo "$1" >&2; exit 1; }
  ```
* コマンド実行ラッパ
  ```
  run_cmd() { command "$@" || die "failed: $*"; }
  ```
* 確認関数
  ```
  confirm() { read -r -p "$1 [y/N] " ans; [[ "$ans" == "y" ]]; }
  ```

## 引き継ぎメモ（次のエージェント向け）

このREADMEは仕様書ですが、会話の中で以下の変更・修正が入りました（実装も反映済み）。

### 直近の実装変更点

- `add` サブコマンドは **`track` にリネーム**済み。
  - 追加実装: `lib/track.sh`
  - entrypoint: `entrypoint.sh` の `track)` 分岐
- 監視対象rootを解除する **`untrack`** を新規追加済み。
  - `flatdir untrack`（引数なし）で fzf から管理対象rootを選び、config から削除
  - 実装: `lib/untrack.sh` / entrypoint: `untrack)`

### fzf/previewまわりの重要ポイント

- `flatdir`（サブコマンド無し）は **cdはしない**。選択したディレクトリの **フルパスをstdoutに出すだけ**（cdはwrapper側）。
- fzfの一覧表示は **フルパスではなく相対パス**表示に変更済み。
  - managed roots が1つ: root からの相対（=深さ1なので実質ディレクトリ名）
  - managed roots が2つ以上: HOME からの相対
  - 変換関数を `lib/common.sh` に追加:
    - `flatdir_display_path_for_dir <abs>`
    - `flatdir_abs_path_from_display <disp>`
- previewは README があれば `rich` を使用し、幅は `FZF_PREVIEW_COLUMNS` を参照（サンプル `samples/cd-git.sh` 準拠）。
  - preview実体: `flatdir_preview_exec_for_path`（`lib/common.sh`）
- fzfのpreviewに bash -lc を使う場合、引数の渡し方で `$1` が空になりやすいので注意。
  - 現状は `bash -lc '... "$1" ...' _ {2}` 形式で安定化済み。

### 既知の設計メモ

- `run_cmd` を alias で提供していたが、非対話shellでは alias が効かず `command not found` になる事があったため、各所は基本 `flatdir_run_cmd` を使用する方針。
- `init` は managed roots が1つの時は root選択を省略するよう `flatdir_pick_managed_root` を調整済み。

## エージェントへの要求

* ファイル分割を必ず守る
* 関数名・変数名は衝突しないよう prefix を付けてもいい
* エラー処理を甘くしない
* ログや進捗は簡潔に
* 曖昧な点があれば必ずユーザーに質問すること
* 「とりあえず動く」ではなく「壊れにくい」実装を目指すこと
