---
name: prepare-pull-request
description: 実装済みIssueの証拠を集め、学生との対話を通じてdocs/tempのPR本文を作成する。
---

# PR本文を準備する

開始時に「使用Skill: prepare-pull-request」と明示する。PRを作成・pushしない。

1. 現在のブランチ名からIssue番号を読み取る。読み取れない場合だけ学生へIssue番号を質問する。
2. Issue本文のDoD、実装計画、git差分、直近のcommit、テスト結果を確認する。
3. 情報が不足している場合、学生へ一度に質問する。必ず、DoDごとの確認結果、`gradle test` の結果、`gradle bootRun` による手動確認結果、学生自身が説明する設計上の要点、AI提案を採用・不採用にした理由を聞く。
4. 回答を得たら、`docs/temp/` がなければ作成し、`docs/temp/pr-<Issue番号>.md` を作成または上書きする。
5. PR本文は次の見出しを各1回ずつ使う。`関連Issue`、`変更内容`、`確認するDoD` には必ず具体的な内容を書く。残りの2項目は空欄でもよい。`関連Issue` には実在するIssue番号を含める。Issueを完了させる `Closes #<Issue番号>` は、そのIssueがOpenの場合だけ使い、完了済みIssueの参照には `Refs #<Issue番号>` を使う。

   ```md
   ## 関連Issue
   Closes #<Issue番号>

   ## 変更内容
   ## 確認するDoD
   ## テストと確認内容
   ## 自分の理解とAI利用
   ```
6. 作成したファイルのパスと、学生が次に `bash scripts/pr/create.sh` を実行して登録することを報告する。
