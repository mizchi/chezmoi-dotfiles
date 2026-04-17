---
name: ast-grep-practice
description: ast-grep をプロジェクト lint ツールとして運用するためのガイド。sgconfig.yml 設定、fix/rewrite ルール、constraints、transform、テスト、CI 統合、既存 linter との使い分けを扱う。汎用 linter で表現できないルールを ast-grep で書くときに使用。
---

# ast-grep Practice

汎用 lint ツール（ESLint, oxlint, Biome, clippy 等）で表現できないパターンを ast-grep で補完する。自然言語プロンプトより再現可能な静的ルールを常に優先する。

## インストール

```bash
# npm (プロジェクトローカル推奨)
npm install -D @ast-grep/cli
npx ast-grep --help

# または cargo
cargo install ast-grep --locked

# または brew
brew install ast-grep
```

## クイックスタート

最小構成で動作確認する:

```bash
mkdir -p rules rule-tests
cat > sgconfig.yml << 'EOF'
ruleDirs:
  - rules
testConfigs:
  - testDir: rule-tests
EOF

cat > rules/no-console-log.yml << 'EOF'
id: no-console-log
language: TypeScript
severity: warning
rule:
  pattern: console.log($$$ARGS)
message: console.log を残さない。
fix: ''
EOF

cat > rule-tests/no-console-log-test.yml << 'EOF'
id: no-console-log
valid:
  - logger.info('ok')
invalid:
  - console.log('debug')
  - "console.log('a', 'b')"
EOF

ast-grep test --skip-snapshot-tests  # テスト実行
ast-grep scan src/                    # プロジェクトスキャン
```

## 原則

- まず既存 linter でカバーできないか確認する
- ast-grep は「構造的パターン」が必要なときに使う
- ルールは TDD で開発する: テストファースト → ルール実装 → CI 統合
- `fix` を書けるなら書く。検出だけのルールより自動修正付きルールを優先する

## 既存 linter との使い分け

| ケース | ツール |
|--------|--------|
| unused import, no-console, naming convention | ESLint / oxlint / Biome |
| type error, unreachable code | TypeScript compiler / clippy |
| formatting | Prettier / Biome / rustfmt |
| 特定の関数呼び出しパターンの禁止 | ast-grep |
| deprecated API の検出と自動書き換え | ast-grep (fix) |
| 特定コンテキスト内での禁止パターン | ast-grep (inside/has) |
| プロジェクト固有の構造制約 | ast-grep |

ast-grep を使うべきサイン:
- 既存ルールの設定だけでは表現できない
- AST の親子・兄弟関係に依存する
- 自動書き換え（migration）が必要

## プロジェクト設定

### sgconfig.yml

```yaml
ruleDirs:            # 必須: ルールファイルの格納先
  - rules
testConfigs:         # 任意: テスト設定
  - testDir: rule-tests
utilDirs:            # 任意: 共有ユーティリティルール
  - rule-utils
languageGlobs:       # 任意: 非標準拡張子のマッピング (TS/JS/Python 等は不要)
  html: ['*.vue', '*.svelte', '*.astro']
```

### ディレクトリ構成

```
project/
  sgconfig.yml
  rules/
    no-direct-env-access.yml
    prefer-result-type.yml
  rule-tests/
    no-direct-env-access-test.yml
    prefer-result-type-test.yml
    __snapshots__/
  rule-utils/
    is-async-function.yml
```

`ast-grep scan` は `sgconfig.yml` のある場所から `ruleDirs` 内の全ルールを実行する。

## ルールファイル構造

```yaml
id: no-direct-env-access
language: TypeScript
severity: warning
rule:
  pattern: process.env.$KEY
  not:
    inside:
      kind: function_declaration
      has:
        pattern: getEnv
      stopBy: end
message: process.env を直接参照しない。getEnv() を経由する。
note: 環境変数の型安全なアクセスを保証するため。
fix: getEnv('$KEY')
files:
  - "src/**"
ignores:
  - "src/config.ts"
```

### フィールド

| フィールド | 必須 | 説明 |
|-----------|------|------|
| `id` | Yes | ルール識別子 |
| `language` | Yes | 対象言語 |
| `rule` | Yes | マッチ条件 |
| `severity` | No | `hint`, `warning`, `error` |
| `message` | No | 1 行の説明 |
| `note` | No | 詳細説明・修正ガイド |
| `fix` | No | 自動修正テンプレート |
| `constraints` | No | メタ変数の追加制約 |
| `transform` | No | メタ変数のテキスト変換 |
| `files` | No | 対象 glob |
| `ignores` | No | 除外 glob |
| `url` | No | ドキュメント URL |

### 抑制コメント

```typescript
// ast-grep-ignore
someCode()

// ast-grep-ignore: no-direct-env-access
process.env.NODE_ENV
```

## メタ変数の注意点

パターンマッチの落とし穴:

- `$OBJ.$PROP` は **ドットアクセスのみ** マッチする。`obj['key']`（ブラケットアクセス）にはマッチしない
- `$VAR` は単一の AST ノード 1 つにマッチ
- `$$$VARS` はゼロ個以上の AST ノードにマッチ（可変長引数、複数文、等）
- `$_` はワイルドカード（キャプチャしない）。同名でも異なる内容にマッチ可能
- メタ変数はノード全体を占める必要がある: `obj.on$EVENT` や `"hello $NAME"` は動かない

## fix (自動修正)

### 基本

```yaml
rule:
  pattern: console.log($ARG)
fix: logger.info($ARG)
```

メタ変数はそのまま `fix` テンプレート内で使える。マッチしなかったメタ変数は空文字になる。

### 削除

```yaml
rule:
  pattern: console.log($$$ARGS)
fix: ''
```

`fix: ''` でマッチしたノードを削除する。ただし空行が残ることがある。末尾カンマや区切り文字も消したい場合は `expandEnd` を使う。

### 複数行

```yaml
rule:
  pattern: |
    def foo($X):
      $$$S
fix: |-
  def bar($X):
    $$$S
```

インデントは元コードの位置に合わせて保持される。

### 範囲拡張 (FixConfig)

末尾のカンマなどを含めて削除したい場合:

```yaml
fix:
  template: ''
  expandEnd:
    regex: ','
```

### CLI での簡易書き換え

```bash
ast-grep run --pattern 'oldFunc($$$ARGS)' --rewrite 'newFunc($$$ARGS)' --lang typescript .
# --update-all で確認なしに一括適用
```

## constraints

メタ変数に追加条件を付ける。`$ARG` のみ対象（`$$$ARGS` は不可）。ルールマッチ後にフィルタされる。

```yaml
rule:
  pattern: $OBJ.$METHOD($$$ARGS)
constraints:
  METHOD:
    regex: '^(get|set|delete)$'
  OBJ:
    kind: identifier
```

使えるフィールド: `kind`, `regex`, `pattern`

注意: `not` 内の制約付きメタ変数は期待通り動作しないことがある。

## transform

マッチしたメタ変数をテキスト変換してから `fix` で使う。

### replace (正規表現置換)

```yaml
transform:
  NEW_NAME:
    replace:
      source: $NAME
      replace: 'get(\w+)'
      by: 'fetch$1'
fix: $NEW_NAME($$$ARGS)
```

### substring (部分文字列)

```yaml
transform:
  INNER:
    substring:
      source: $STR
      startChar: 1
      endChar: -1
```

負のインデックスは末尾から。Python のスライスと同じ。

### convert (ケース変換)

```yaml
transform:
  SNAKE:
    convert:
      source: $NAME
      toCase: snakeCase
      separatedBy: [caseChange]
```

対応ケース: `camelCase`, `snakeCase`, `kebabCase`, `pascalCase`, `upperCase`, `lowerCase`, `capitalize`

### rewrite (実験的)

メタ変数内のノードを rewriter ルールで再帰的に書き換える。

```yaml
transform:
  REWRITTEN:
    rewrite:
      source: $$$BODY
      rewriters: [migrate-api-call]
      joinBy: "\n"
```

## utils (ユーティリティルール)

`utilDirs` に定義した共通ルールを `matches` で参照する。

```yaml
# rule-utils/is-async-function.yml
id: is-async-function
language: TypeScript
rule:
  any:
    - kind: function_declaration
      has:
        field: async
        regex: async
    - kind: arrow_function
      has:
        field: async
        regex: async
```

```yaml
# rules/async-no-try-catch.yml
id: async-no-try-catch
language: TypeScript
rule:
  all:
    - matches: is-async-function
    - has:
        pattern: await $EXPR
        stopBy: end
    - not:
        has:
          kind: try_statement
          stopBy: end
message: async 関数に try-catch がない。
severity: warning
```

## テスト

### テストファイル形式

テストファイル内の `id` がルールファイルの `id` と一致している必要がある。ファイル名は自由（慣例は `{rule-id}-test.yml`）。

```yaml
# rule-tests/no-direct-env-access-test.yml
id: no-direct-env-access
valid:
  - getEnv('NODE_ENV')
  - "function setup() { return getEnv('PORT') }"
invalid:
  - process.env.NODE_ENV
  - process.env.PORT
```

### テスト実行

```bash
# 分類テスト (valid/invalid が正しいか)
ast-grep test --skip-snapshot-tests

# スナップショット生成・更新
ast-grep test -U

# スナップショット対話的レビュー
ast-grep test --interactive
```

テスト結果:
- `.` : パス
- `N` : ノイジー (false positive — valid コードにマッチ)
- `M` : ミッシング (false negative — invalid コードにマッチしない)

### ワークフロー

1. `rule-tests/` にテストファイルを書く (Red)
2. `rules/` にルールを書く (Green)
3. `ast-grep test --skip-snapshot-tests` で確認
4. `ast-grep test -U` でスナップショット生成
5. スナップショットをレビューして commit

## CI 統合

### justfile

```just
ast-grep-test:
  ast-grep test

ast-grep-lint:
  ast-grep scan

check: format-check typecheck ast-grep-lint test
```

### GitHub Actions

```yaml
- name: Install ast-grep
  run: cargo install ast-grep --locked
  # or: npm install -g @ast-grep/cli

- name: Lint with ast-grep
  run: ast-grep scan

- name: Test ast-grep rules
  run: ast-grep test
```

`ast-grep scan` は violation があると非ゼロで終了する。`--format json` で JSON 出力。

## kind 名の調べ方

kind 名は言語の Tree-sitter grammar に依存する。

```bash
# CST ダンプ（全ノード表示）
ast-grep run --pattern 'YOUR_CODE_HERE' --lang typescript --debug-query=cst

# AST ダンプ（名前付きノードのみ）
ast-grep run --pattern 'YOUR_CODE_HERE' --lang typescript --debug-query=ast
```

### TypeScript/JavaScript でよく使う kind

| kind | 対応するコード |
|------|---------------|
| `function_declaration` | `function foo() {}` |
| `arrow_function` | `() => {}` |
| `call_expression` | `foo()` |
| `member_expression` | `obj.prop` |
| `variable_declarator` | `const x = 1` の `x = 1` 部分 |
| `lexical_declaration` | `const x = 1` 全体 |
| `type_alias_declaration` | `type Foo = ...` |
| `interface_declaration` | `interface Foo {}` |
| `import_statement` | `import ... from '...'` |
| `export_statement` | `export ...` |
| `try_statement` | `try { ... } catch { ... }` |
| `if_statement` | `if (...) { ... }` |
| `class_declaration` | `class Foo {}` |
| `method_definition` | クラス内メソッド |
| `pair` | `{ key: value }` の 1 ペア |
| `template_string` | `` `...` `` |

### Rust でよく使う kind

| kind | 対応するコード |
|------|---------------|
| `function_item` | `fn foo() {}` |
| `struct_item` | `struct Foo {}` |
| `enum_item` | `enum Foo {}` |
| `impl_item` | `impl Foo {}` |
| `trait_item` | `trait Foo {}` |
| `use_declaration` | `use std::io;` |
| `let_declaration` | `let x = 1;` |
| `const_item` | `const X: i32 = 1;` |
| `match_expression` | `match x { ... }` |
| `if_expression` | `if x { ... }` |
| `call_expression` | `foo()` |
| `field_expression` | `obj.field` |
| `macro_invocation` | `println!(...)` |
| `closure_expression` | `\|x\| x + 1` |
| `unsafe_block` | `unsafe { ... }` |
| `async_block` | `async { ... }` |
| `for_expression` | `for x in iter { ... }` |
| `mod_item` | `mod foo { ... }` |

### Go でよく使う kind

| kind | 対応するコード |
|------|---------------|
| `function_declaration` | `func foo() {}` |
| `method_declaration` | `func (r Recv) foo() {}` |
| `type_declaration` | `type Foo struct {}` |
| `struct_type` | `struct { ... }` |
| `interface_type` | `interface { ... }` |
| `call_expression` | `foo()` |
| `selector_expression` | `obj.Method` |
| `short_var_declaration` | `x := 1` |
| `var_declaration` | `var x int` |
| `const_declaration` | `const x = 1` |
| `import_declaration` | `import "fmt"` |
| `if_statement` | `if x { ... }` |
| `for_statement` | `for i := 0; ... { ... }` |
| `return_statement` | `return x` |
| `defer_statement` | `defer f()` |
| `go_statement` | `go f()` |
| `channel_type` | `chan int` |

### Python でよく使う kind

| kind | 対応するコード |
|------|---------------|
| `function_definition` | `def foo():` |
| `class_definition` | `class Foo:` |
| `call` | `foo()` |
| `attribute` | `obj.attr` |
| `import_statement` | `import ...` |
| `import_from_statement` | `from ... import ...` |
| `if_statement` | `if ...:` |
| `try_statement` | `try: ...` |
| `with_statement` | `with ...:` |
| `decorator` | `@decorator` |

## 実践的なルール例

### TypeScript: deprecated API の書き換え

```yaml
id: migrate-old-api
language: TypeScript
severity: error
rule:
  pattern: oldClient.fetch($URL, $OPTS)
fix: newClient.request($URL, $OPTS)
message: oldClient.fetch は廃止。newClient.request に移行する。
```

### 特定 import の禁止

```yaml
id: no-lodash-import
language: TypeScript
severity: warning
rule:
  pattern: import $_ from 'lodash'
message: lodash の全体 import を禁止。lodash/xxx を使う。
fix: import $_ from 'lodash/xxx' // TODO: 正しいパスに修正
```

### TypeScript: React コンポーネント内の直接 fetch 禁止

```yaml
id: no-fetch-in-component
language: TypeScript
severity: warning
rule:
  pattern: fetch($$$ARGS)
  inside:
    any:
      - kind: function_declaration
        has:
          field: return_type
          pattern: JSX.Element
      - kind: arrow_function
        inside:
          kind: variable_declarator
          regex: '^[A-Z]'
    stopBy: end
message: コンポーネント内で直接 fetch しない。hooks か server action を使う。
```

### Rust: unwrap() の禁止

```yaml
id: no-unwrap
language: Rust
severity: warning
rule:
  pattern: $EXPR.unwrap()
  not:
    inside:
      kind: function_item
      regex: '#\[test\]'
      stopBy: end
message: テスト以外で unwrap() を使わない。? か expect() を使う。
note: unwrap() は panic するため、本番コードでは避ける。
```

### Rust: unsafe ブロックの検出

```yaml
id: flag-unsafe-block
language: Rust
severity: warning
rule:
  kind: unsafe_block
message: unsafe ブロック。安全性の根拠をコメントで示す。
```

### Rust: println! を log マクロに移行

```yaml
id: no-println-in-lib
language: Rust
severity: warning
rule:
  pattern: println!($$$ARGS)
  not:
    inside:
      kind: function_item
      regex: 'fn main'
      stopBy: end
message: ライブラリコードで println! を使わない。log::info! 等を使う。
fix: log::info!($$$ARGS)
files:
  - "src/lib.rs"
  - "src/**/mod.rs"
  - "src/**/*.rs"
ignores:
  - "src/main.rs"
  - "src/bin/**"
```

### Go: エラー無視の検出

```yaml
id: no-ignored-error
language: Go
severity: error
rule:
  kind: short_var_declaration
  has:
    kind: identifier
    regex: '^_$'
    field: left
  has:
    kind: call_expression
    field: right
    stopBy: end
message: エラーを _ で無視しない。適切にハンドリングする。
```

### Go: defer で Close する忘れ防止

```yaml
id: defer-close-after-open
language: Go
severity: warning
rule:
  kind: short_var_declaration
  has:
    pattern: os.Open($PATH)
    field: right
    stopBy: end
  not:
    precedes:
      pattern: defer $_.Close()
      stopBy:
        kind: return_statement
message: os.Open の直後に defer Close() を入れる。
```

### Python: bare except の禁止

```yaml
id: no-bare-except
language: Python
severity: warning
rule:
  kind: except_clause
  not:
    has:
      kind: identifier
      stopBy: neighbor
message: bare except を使わない。具体的な例外型を指定する。
```

### Python: print() をロガーに移行

```yaml
id: no-print-in-src
language: Python
severity: warning
rule:
  pattern: print($$$ARGS)
  not:
    inside:
      kind: function_definition
      regex: 'def main'
      stopBy: end
message: print() ではなく logger を使う。
fix: logger.info($$$ARGS)
files:
  - "src/**"
```

## References

- ast-grep docs: https://ast-grep.github.io/
- Rule reference: https://ast-grep.github.io/reference/yaml.html
- sgconfig: https://ast-grep.github.io/reference/sgconfig.html
- Playground: https://ast-grep.github.io/playground.html
- Rule catalog: https://ast-grep.github.io/catalog/
