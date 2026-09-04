---
agent: "agent"
description: "合意した機能案を、登録可能な複数Issueの草案へ分割する"
---

実装はしない。このPromptは、学生との対話を次の2段階で行う。GitHubへの登録、コードの作成、Issueコメントの投稿はしない。

## 第1段階: Issue分割の相談

学生が入力した機能を、1人が1〜2日で完了できるIssueに分割する。学生の案を別の機能へ置き換えない。各Issueについて、`id`、題名、利用者価値、今回しないこと、依存する草案ID、分割理由を表で示す。A1〜A6との関係で不足する情報があれば、質問を最大5個だけ示す。

この段階では `docs/temp/issues.md` を作成・更新しない。最後に「このIssue分割で各Issueの実装計画を作成しますか？」と質問して停止する。

## 第2段階: 実装計画の作成

学生がIssue分割を明示的に承認した場合だけ実行する。`docs/project.md`、関連する既存コード・テスト、必要に応じて `springboot_samples` を確認し、各Issueについて次を作成する。

1. 変更予定ファイルと変更理由
2. 実装順序
3. DoD確認方法（DoDごとの自動テストまたは手動確認）
4. 変更しないものとリスク

`docs/temp/` がなければ作成し、下記形式の完全な内容を `docs/temp/issues.md` に作成または上書きする。作成後は、Issue数、依存関係、assigneeが未記入のIssue、計画上の未解決事項を短く報告する。

作成後は、登録スクリプトを実行する前に、草案の構造が崩れていないかを確認する。これは、Issueブロックや必須見出しが不足した状態で登録すると、登録スクリプトが停止し、学生が修正箇所を探す必要があるためである。

コマンドを示す前に、学生へ次を短く説明する。

- Issueブロック数と各見出し数が同じなら、すべてのIssueに同じ項目がある可能性が高い。
- `Start conditions` は今回の機能に開始条件が含まれる場合だけ、その記述箇所を学生が確認するための検索である。該当しない機能なら「該当なし」と報告してよい。
- `Trailing whitespace` の出力がなければ、行末の不要な空白は見つからなかったことを表す。
- この確認は内容の正しさを保証するものではない。学生はDoD、変更範囲、依存関係、実装計画を読んで承認してから登録する。

構造確認には、PortableGitに標準で含まれる `grep` だけを使う。`rg`、`ripgrep`、`git diff --check` は使わず、次を実行して結果を学生に説明してから報告する。`docs/temp/` はGit管理しない一時ファイルなので、`git diff --check` では検査できないためである。

```bash
cd "$(git rev-parse --show-toplevel)"
printf 'ISSUE blocks: '; grep -c '^<!-- ISSUE$' docs/temp/issues.md || true
printf 'DoD headings: '; grep -c '^## DoD（受入条件）$' docs/temp/issues.md || true
printf 'DoD verification headings: '; grep -c '^## DoD確認方法$' docs/temp/issues.md || true
printf 'Plan headings: '; grep -c '^## 実装計画$' docs/temp/issues.md || true
printf 'Start conditions:\n'; grep -n -E '全員が開始ボタン|開始状態' docs/temp/issues.md || true
printf 'Trailing whitespace:\n'; grep -n -E '[[:blank:]]$' docs/temp/issues.md || true
```

`id` は英小文字・数字・ハイフンだけを使う草案内の一意な名前、`title` は他の草案と重複しない題名、`assignee` は未決定なら空欄にする。`depends-on` は、同じ草案で作るIssueの草案ID、または既にGitHubにあるOpen Issue番号をカンマ区切りで記載できる（例: `database-schema, 12`）。本文にメタデータのコメントを含めない。

```md
# Issue草案

<!-- ISSUE
id: game-page
title: [Feature] じゃんけん画面を表示する
assignee: student-a
depends-on:
-->
## 機能の概要

ログイン済み利用者がじゃんけんの手を選ぶ画面を表示できる。
今回しないこと: 手の送信、勝敗計算、履歴保存。

## DoD（受入条件）

- Given ログイン済み、When `/game` を開く、Then 手を選ぶ画面が表示される。

## 関連ファイル・変更境界

- 新規: `inujanken/src/main/java/.../GameController.java`
- 新規: `inujanken/src/test/java/.../GameControllerTest.java`

## 実装計画

1. `GameController.java` を追加し、GET `/game` で `game` を返す。
2. `game.html` を追加し、手の選択肢を表示する。
3. `GameControllerTest.java` を追加し、ログイン済みと未ログインのDoDを確認する。

## DoD確認方法

- DoD 1: MockMvcでログイン済み利用者の画面表示を確認する。
- DoD 2: MockMvcで未ログイン利用者のログイン画面遷移を確認する。

## 変更しないものとリスク

- `SecurityConfig.java` の認証方針は変更しない。
<!-- END ISSUE -->
```

合意済み機能:

${input:feature}
