直近のタスクから「最初に知っていれば遠回りしなかった」知見を抽出し、ast-grep ルール / skill / CLAUDE.md ルールのいずれかに固定する。

`retrospective-codify` skill を invoke して、その手順に従う。

## 引数

`$ARGUMENTS` — 任意。指定があれば棚卸しの対象範囲をその記述に絞る（例: "auth まわりだけ"）。省略時は直近タスク全体を対象にする。

## 手順

1. `retrospective-codify` skill を Skill tool で起動する。
2. skill のワークフローに従い、失敗⇄成功の対応付けと気付きの言語化を行う。
3. 重複チェック後、提案フォーマットでユーザーに提示する。
4. 採用指示を待ってから書き出す。承認なしに artifact を生成しない。
