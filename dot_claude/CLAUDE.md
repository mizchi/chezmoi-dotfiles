# 開発スタイル

TDD で開発する（探索 → Red → Green → Refactoring）。
KPI やカバレッジ目標が与えられたら、達成するまで試行する。
不明瞭な指示は質問して明確にする。

# コード設計

- 関心の分離を保つ
- 状態とロジックを分離する
- 可読性と保守性を重視する

# ツール

- VCS: jj を優先（未初期化なら `jj git init --colocate`）
- タスク: justfile
- Node.js: pnpm, v24+
- E2E: playwright

# 環境

- GitHub: mizchi
- リポジトリ: ghq 管理（`~/ghq/github.com/owner/repo`）
