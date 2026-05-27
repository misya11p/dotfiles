---
name: python-coding-rules
description: Skills related to rules and best practices for Python coding
---

# Python Coding Rules

- Use `pathlib` for all path management. Do not use `os.path` or `glob.glob`.
- Follow the prefixes below for path-related variable names:
    - File path: fpath
    - File name: fname
    - Directory path: dpath
    - Directory name: dname
- Variable names should follow the `abstract_concrete` pattern:
    - This improves readability when listing multiple related variables. Example: dpath_dataset, dpath_output, fpath_config
- Use `typer` to manage command-line arguments. Ensure the `-h` help flag is enabled.

```
CONTEXT_SETTINGS = dict(help_option_names=["-h", "--help"])
app = typer.Typer(add_completion=False, context_settings=CONTEXT_SETTINGS)
```

- Limit code lines to 79 characters, and comments or strings to 72 characters.
- When writing long strings, effectively use parentheses `()` as shown below to keep them within 79 characters:

```
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
