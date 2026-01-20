# jj (Jujutsu) ベストプラクティス

## 基本概念

jj は Git と異なり、ワーキングコピーの変更を**自動的にコミット**する。`jj status` などのコマンド実行時に変更が自動記録される。

- 新規ファイルは自動追跡（`.gitignore` で除外しない限り）
- 「現在のブランチ」という概念がない
- ブックマーク（Git のブランチに相当）は必要になるまで作成しない

## 基本ワークフロー

```bash
# 状態確認
jj status
jj log

# 変更を記録（自動コミットされているので describe でメッセージを付ける）
jj describe -m "変更内容"

# 新しい変更を開始（現在の変更を確定して次へ）
jj new

# 直前のコミットを編集したい場合
jj new @-          # 親に移動
# ... 編集 ...
jj squash          # 子にマージ
```

## GitHub PR ワークフロー

### ブックマーク作成とプッシュ

```bash
# 方法1: 自動生成（push-xxxx のような名前）
jj git push -c @-

# 方法2: 明示的に命名
jj bookmark create feature-name -r @-
jj git push
```

### PR 更新（レビュー対応）

```bash
# 方法1: コミット追加型（履歴を残す）
# 新しいコミットを追加してプッシュ

# 方法2: コミット修正型（履歴を書き換え）
jj new @-              # 修正したいコミットの子に移動
# ... 修正 ...
jj squash              # 親にマージ
jj git push --bookmark feature-name  # force push
```

### リモートの更新を取り込む

```bash
jj git fetch
jj rebase -d main      # main の最新にリベース
```

## 便利なコマンド

| コマンド | 説明 |
|---------|------|
| `jj log -r 'all()'` | 全コミットを表示 |
| `jj split -i` | 対話的にコミットを分割（git add -p 相当） |
| `jj squash` | 現在の変更を親にマージ |
| `jj abandon` | コミットを破棄 |
| `jj undo` | 直前の操作を取り消し |
| `jj op log` | 操作履歴を表示 |

## コンフリクト解決

コンフリクトはファイル内にマーカーとして埋め込まれる。一度に全て解決する必要はない。

```bash
# コンフリクト状態で新しいコミットを作成
jj new
# ... 解決 ...
jj squash   # 解決を元のコミットにマージ
```

## 注意点

- `jj git push --all` はブックマークのみをプッシュ（全リビジョンではない）
- Vite/Vitest 使用時は `.jj/**` を watch 対象から除外する
- ブックマークの競合は `jj bookmark move <name> --to <commit>` で解決
