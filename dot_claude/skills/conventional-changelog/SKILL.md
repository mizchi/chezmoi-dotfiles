---
name: conventional-changelog
description: Conventional Commits 規約と CHANGELOG 自動生成の横断リファレンス。commit 書式、Keep a Changelog 形式、semver タグ運用、release-please / changesets / git-cliff / towncrier 等の生成ツール比較を含む。新規リポジトリで release フローを整備するとき、既存 repo の commit 規約を統一するとき、言語に合った changelog ツールを選ぶとき、release-please 以外の選択肢を検討するときに使う。
---

# Conventional Changelog

commit メッセージを Conventional Commits 規約で書き、そこから CHANGELOG と semver タグを機械的に生成する運用のガイド。npm / cargo / python / rust / go を横断してツールを選び、手で CHANGELOG を書かずに済ませる。

## いつ使うか

- 新規 repo に release フローを整備する
- 既存 repo の commit メッセージが揺れていて、CHANGELOG 生成を導入したい
- release-please を試したが合わない / 別ツールを検討したい
- 言語（Rust / Python / Go 等）に合った changelog ツールを探している
- tag と CHANGELOG が手運用で壊れがち、自動化したい

## Conventional Commits 書式

形式: `<type>[optional scope]: <subject>`

```
feat(api): add rate-limit middleware
fix(auth): reject expired tokens before DB lookup
docs: clarify OAuth flow diagram
chore: bump deps
```

### type の一覧と semver 影響

| type | semver bump | CHANGELOG 掲載 |
|---|---|---|
| `feat` | **minor** | ✓ (Added / Features) |
| `fix` | **patch** | ✓ (Fixed) |
| `perf` | patch | ✓ (Changed) |
| `refactor` | なし | × (デフォルト) |
| `docs` | なし | × |
| `style` | なし | × |
| `test` | なし | × |
| `build` | なし | × |
| `ci` | なし | × |
| `chore` | なし | × |
| `revert` | 直前に依存 | ✓ |

### Breaking change（major bump）

2 通り: footer に `BREAKING CHANGE:` を書く、または type の後に `!`:

```
feat(api)!: replace REST endpoint with GraphQL

BREAKING CHANGE: /api/v1/users is removed. Use GraphQL Query.user instead.
```

両方書くのが丁寧（タイトル見てすぐ分かる + footer で詳細）。

### scope

optional だが付けると CHANGELOG が読みやすくなる。monorepo では package 名を scope に:

```
feat(@pkg/auth): add oauth2 flow
feat(@pkg/billing): stripe migration
```

scope で release-please の「変更対象パッケージ」も自動判定される（manifest モード）。

### subject

- 小文字で始める（文末ピリオドなし）
- 命令形（"add X" / "fix Y"、"added" や "fixes" は避ける）
- 50 文字以内が目安

### body / footer

空行を挟んで本文、さらに空行で footer（`Closes #123`, `Co-authored-by: ...`, `BREAKING CHANGE: ...`）。

## CHANGELOG.md 形式（Keep a Changelog）

[keepachangelog.com](https://keepachangelog.com/) に準拠。version 降順、semver、セクションは決まった 6 種:

```markdown
# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- foo bar

## [1.2.0] - 2026-04-19

### Added

- New `--json` output flag for `foo scan` ([#42](https://github.com/owner/repo/pull/42))

### Changed

- `parse_config` now accepts YAML in addition to TOML

### Fixed

- Crash when config file is empty ([#40](https://github.com/owner/repo/issues/40))

### Deprecated

- `--legacy-mode` flag. Use `--mode=legacy` instead.

### Removed

- `foo bar --old-flag` (deprecated in 1.0.0)

### Security

- Upgrade `openssl` to 3.2.0 to address CVE-2025-XXXXX

## [1.1.0] - 2026-03-01

...

[Unreleased]: https://github.com/owner/repo/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/owner/repo/compare/v1.1.0...v1.2.0
```

6 セクション:
- `Added`: 新機能
- `Changed`: 既存機能の変更
- `Deprecated`: 削除予定（まだ残っている）
- `Removed`: 削除済み
- `Fixed`: バグ修正
- `Security`: 脆弱性対応

## semver タグ運用

- tag は `v<MAJOR>.<MINOR>.<PATCH>` 形式（`v1.2.3`）。`v` prefix が主流
- pre-release は `v1.0.0-beta.1` / `v1.0.0-rc.1`
- `git tag -a v1.2.3 -m "Release v1.2.3"`（annotated tag）→ `git push origin v1.2.3`
- tag 打ちとデプロイの連動は GitHub Release + Actions の `on: release` で組む

## ツール比較

| ツール | 対応言語 | 方式 | CHANGELOG 生成 | version bump | 主な利点 | 弱点 |
|---|---|---|---|---|---|---|
| **release-please** | npm / python / rust / go / java / php / ruby | Release PR が自動で作られる | ○ | ○ (PR merge で tag) | monorepo 対応、Google 製で安定 | PR ベースで学習コスト |
| **changesets** | npm 専用 | `changeset add` で手動記録 | ○ | ○ | monorepo + 柔軟 (npm workspaces) | commit 駆動ではない |
| **conventional-changelog-cli** | 言語非依存（コマンド） | commit から 1 発生成 | ○ | × | 軽量、既存 CHANGELOG に追記 | tag / bump は別で手動 |
| **standard-version** (deprecated) | npm | commit → bump + CHANGELOG | ○ | ○ | シンプル | **メンテ停止**、release-please に移行推奨 |
| **git-cliff** | 言語非依存（Rust 製） | TOML 設定で高カスタマイズ | ○ | × | 高速、テンプレ柔軟、Rust エコシステムに好まれる | tag / bump は別 |
| **towncrier** | Python | news fragment を PR 毎に書く | ○ | × | fragment で merge 時の衝突回避 | 独特なワークフロー |
| **auto** (intuit/auto) | 複数 | label ベース + CI 統合 | ○ | ○ | GitHub label 駆動 | 独自 label 規約 |

### 一言推奨

- **npm 単一 package で自動化したい** → release-please
- **npm monorepo** → release-please（manifest モード）or changesets（細かい制御）
- **Rust** → git-cliff
- **Python** → towncrier（or release-please）
- **Go / 汎用** → git-cliff or release-please
- **CHANGELOG だけ生成したい（tag 管理は手動）** → conventional-changelog-cli or git-cliff

## release-please セットアップ（最推奨パス）

npm project で新規導入する場合:

```json
// release-please-config.json
{
  "$schema": "https://raw.githubusercontent.com/googleapis/release-please/main/schemas/config.json",
  "release-type": "node",
  "packages": {
    ".": { "package-name": "my-pkg", "changelog-path": "CHANGELOG.md" }
  },
  "include-v-in-tag": true,
  "bump-minor-pre-major": true
}
```

```json
// .release-please-manifest.json
{ ".": "0.0.0" }
```

```yaml
# .github/workflows/release-please.yml
name: release-please
on:
  push:
    branches: [main]
permissions:
  contents: write
  pull-requests: write
jobs:
  release-please:
    runs-on: ubuntu-latest
    steps:
      - uses: googleapis/release-please-action@v4
        with:
          config-file: release-please-config.json
          manifest-file: .release-please-manifest.json
```

commit を conventional 規約で書いて main に push すると、自動で「Release PR」が作られる。merge すると tag + GitHub Release + CHANGELOG 更新が走る。npm publish 連動は別 workflow（`on: release`）で。

詳細は `npm-release` skill（ローカル管理）の publish フロー参照。

## git-cliff セットアップ（Rust / 汎用）

```bash
cargo install git-cliff
# or
brew install git-cliff
```

```toml
# cliff.toml
[changelog]
header = "# Changelog\n"
body = """
{% if version %}## [{{ version }}] - {{ timestamp | date(format="%Y-%m-%d") }}{% endif %}
{% for group, commits in commits | group_by(attribute="group") %}
### {{ group | upper_first }}
{% for commit in commits %}
- {{ commit.message | upper_first }} ({{ commit.id | truncate(length=7, end="") }})
{% endfor %}
{% endfor %}
"""

[git]
conventional_commits = true
commit_parsers = [
  { message = "^feat", group = "Added" },
  { message = "^fix", group = "Fixed" },
  { message = "^perf", group = "Changed" },
  { message = "^docs", skip = true },
  { message = "^chore", skip = true },
]
filter_unconventional = false
```

```bash
git-cliff --output CHANGELOG.md            # 全履歴から再生成
git-cliff --unreleased --prepend CHANGELOG.md  # 未リリース分だけ上に追記
git-cliff --tag v1.2.0 --output CHANGELOG.md   # 特定 tag 向けに生成
```

## conventional-changelog-cli（軽量、言語非依存）

```bash
npm install -g conventional-changelog-cli
conventional-changelog -p angular -i CHANGELOG.md -s -r 0
# -p: preset (angular / atom / ember / eslint / jquery / jshint)
# -i: input, -s: same file, -r 0: 全履歴
```

preset は主に `angular`（conventional commits の origin）。既存 CHANGELOG に追記する運用に向く。

## pre-commit で commit メッセージを検査

commit 時点で conventional 規約違反を弾く:

### commitlint

```bash
npm install -D @commitlint/cli @commitlint/config-conventional
```

```js
// commitlint.config.js
module.exports = { extends: ['@commitlint/config-conventional'] };
```

```yaml
# .pre-commit-config.yaml (prek / pre-commit)
- repo: https://github.com/alessandrojcm/commitlint-pre-commit-hook
  rev: v9.16.0
  hooks:
    - id: commitlint
      stages: [commit-msg]
```

### commitizen（対話的 commit 作成）

```bash
npm install -D commitizen cz-conventional-changelog
# package.json
"config": { "commitizen": { "path": "./node_modules/cz-conventional-changelog" } }
# 使用
git cz
```

## よくある失敗

- **commit 規約途中から導入**: 既存履歴は壊れた形式のまま。release-please は「規約違反 commit」を scan 時に無視する。遡及書き換えは不要、次から揃える
- **`chore:` ばかり使って release PR が立たない**: bug fix なのに `chore:` と書くと CHANGELOG に載らない / version も bump しない。**重要度ではなく「変更の種類」で type を選ぶ**（fix はユーザーに見える修正、chore は内部整理）
- **BREAKING CHANGE を subject に書いて footer を省く**: release-please は footer の `BREAKING CHANGE:` か type の `!` を見る。subject に「breaking: ...」と書いても major bump しない
- **CHANGELOG を手動編集 + tool 併用**: release-please の管理下にある CHANGELOG を手編集すると、次回生成で drift。追記は必ず PR へ（release-please の「Edit」機能を使う）
- **tag を先に打って release-please で PR を作る**: release-please は PR merge 時に tag を打つ。手動 tag と競合する。手動運用なら conventional-changelog-cli / git-cliff + 手 tag に統一

## Red flags

| 出てくる思考 | 実態 |
|---|---|
| 「CHANGELOG は手で書いた方が丁寧」 | commit から生成すれば漏れない。手書きは漏れ・表記揺れが必ず起きる |
| 「tag を先に打ってから changelog を書く」 | 順序が逆。commit → tool が CHANGELOG 生成 → tag、を守る |
| 「breaking change は subject に書けばわかる」 | tool は footer / `!` を機械的に読む。subject の自然文は無視される |
| 「プロジェクト固有の type を増やそう」 | `feat` / `fix` / `chore` の範囲で表現できる。独自 type は tool の preset が対応しない |
| 「conventional 違反 commit を rebase で直す」 | 遡及書き換えは履歴汚染。違反は次から揃えれば良い、tool は無視してくれる |

## 関連

- `npm-release` — release-please + OIDC Trusted Publishing で publish まで自動化（セッション固有のローカル管理）
- `apm-usage` references/publishing.md — skill 公開時の CHANGELOG 慣習
- `gh-fix-ci` — release workflow が CI で落ちたとき
- Keep a Changelog: https://keepachangelog.com/
- Conventional Commits: https://www.conventionalcommits.org/
- release-please: https://github.com/googleapis/release-please
- git-cliff: https://git-cliff.org/
