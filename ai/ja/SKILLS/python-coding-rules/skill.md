---
name: python-coding-rules
description: Pythonコーディング時のルールやベストプラクティスに関するスキル
---

# Python Coding Rules

- path管理は全てpathlibを用いる。`os.path`や`glob.glob`は使わない。
- path系の変数名prefixは以下に従う
    - ファイルパス: fpath
    - ファイル名: fname
    - ディレクトリパス: dpath
    - ディレクトリ名: dname
- 変数名は`抽象_具体`
    - 関連する複数の変数を並べた時に見やすくなる。例: dpath_dataset, dpath_output, fpath_config
- コマンドライン引数の管理は`typer`を使う。その際、`-h`でのヘルプ表示を有効にする。

```python
CONTEXT_SETTINGS = dict(help_option_names=["-h", "--help"])
app = typer.Typer(add_completion=False, context_settings=CONTEXT_SETTINGS)
```

- 1行79字、コメントなどは72字に収める
- 長い文字列を書くときは以下のように`()`をうまく使って79字に収める

```python
@app.command()
def main(
    api_key: str = typer.Option(
        None,
        "--api-key", "-k",
        help=(
            "API key for authentication. Defaults to the value of the "
            "OPENROUTER_API_KEY environment variable."
        ),
    ),
):
```
