---
name: justfile
description: just コマンドランナーのリファレンス。justfile の書き方と GitHub Actions での使用例を提供。
---

# justfile Skill

just はプロジェクト固有のコマンドを管理するコマンドランナー。Make に似た構文だがよりシンプル。

## 基本構文

```just
# デフォルトレシピ（最初に定義されたものが just 実行時に呼ばれる）
default:
  @echo "Available: just --list"

# 基本レシピ
build:
  cargo build --release

# 依存関係
test: build
  cargo test

# 引数
greet name:
  echo "Hello, {{name}}!"

# デフォルト引数
serve port="8080":
  python -m http.server {{port}}

# 可変長引数
run *args:
  cargo run -- {{args}}
```

## 変数

```just
# 文字列
version := "1.0.0"

# シェルコマンドの結果
git_hash := `git rev-parse --short HEAD`

# 環境変数（デフォルト付き）
home := env_var_or_default("HOME", "/tmp")

# 使用
info:
  echo "Version: {{version}}, Hash: {{git_hash}}"
```

## 設定

```just
# シェル指定
set shell := ["bash", "-cu"]

# .env 読み込み
set dotenv-load

# エラー時に停止しない
set ignore-errors

# コマンド表示を抑制
set quiet

# 作業ディレクトリ
set working-directory := "subdir"
```

## 条件分岐

```just
# OS 判定
install:
  {{if os() == "macos" { "brew install foo" } else { "apt install foo" }}}

# アーキテクチャ判定
build:
  {{if arch() == "aarch64" { "make arm" } else { "make x86" }}}
```

## 組み込み関数

| 関数 | 説明 |
|------|------|
| `os()` | OS 名 (linux, macos, windows) |
| `arch()` | アーキテクチャ (x86_64, aarch64) |
| `env_var("NAME")` | 環境変数取得 |
| `justfile_directory()` | justfile のディレクトリ |
| `invocation_directory()` | 呼び出し元ディレクトリ |

## よく使うコマンド

```bash
just              # デフォルトレシピ実行
just recipe       # 指定レシピ実行
just recipe arg   # 引数付き実行
just --list       # レシピ一覧
just --dry-run    # 実行せず表示
just --choose     # fzf で選択
just --fmt        # フォーマット
```

## GitHub Actions

`extractions/setup-just@v3` を使用。完全な例は `assets/gh_action_example.yaml` を参照。

```yaml
steps:
  - uses: actions/checkout@v4

  - uses: extractions/setup-just@v3
    # with:
    #   just-version: '1.40.0'  # バージョン指定（任意）

  - run: just build
  - run: just test
```

## 実用的な justfile 例

```just
set dotenv-load
set shell := ["bash", "-cu"]

default:
  @just --list

# 開発サーバー
dev:
  npm run dev

# ビルド
build:
  npm run build

# テスト
test *args:
  npm test {{args}}

# lint + format
check:
  npm run lint
  npm run format:check

# CI 用（GitHub Actions から呼ばれる）
ci: check build test

# リリース
release version:
  git tag -a v{{version}} -m "Release v{{version}}"
  git push origin v{{version}}

# クリーンアップ
clean:
  rm -rf dist node_modules
```

## 参考

- https://github.com/casey/just
- https://just.systems/man/en/
- https://github.com/extractions/setup-just
