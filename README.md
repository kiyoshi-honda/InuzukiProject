# InuzukiProject

4人程度の学生チームが、GitHub Copilotを共同作業者として使い、Spring BootのWebアプリケーションを7週間程度で開発する演習用リポジトリです。このREADMEは、初学者が実際に入力するコマンド、Copilotへの依頼、期待される出力を順番に説明します。

## 最初に理解すること

このプロジェクトで「正しい」と判断する根拠は、次の順です。

1. `docs/project.md`: アプリ全体の目的、範囲、現在の構成、開発環境。
2. GitHub Issue: 今回の小さな機能、DoD、変更してよいファイル。
3. テスト: DoDが今も動くことの自動確認。
4. Pull Request: 誰が何を変え、どう確認したか。

`tasks.md`、大きな機能仕様書、実装完了レポートは作成しません。相談・実装・レビューの履歴はIssueとPRに残します。将来の設計にも影響する判断だけは `docs/adr/` に残します。
- 誰も残さないかもしれない．毎回の振り返り時に学生にどう指示をすれば必要な情報を残させることができるか要検討

## 例として実装する機能

以降では「ログイン済み利用者が `/game` を開くと、じゃんけんの手を選ぶ画面が表示される」を例にします。現在の `SecurityConfig.java` は `/` を公開し、それ以外のURLにログインを要求しています。そのため `/game` 用のControllerと画面を追加すれば、未ログイン利用者のログイン画面への遷移は既存設定で実現できます。

この機能を2件のIssueとして記述した完成例は [examples/issues.example.md](examples/issues.example.md) です。
対応するPull Request本文の完成例は [examples/pull-request.example.md](examples/pull-request.example.md) です。

## 0. 初回だけ行う準備

### 0-1. PortableGit Bashを開く

WindowsのPowerShellではなく、演習環境で設定済みのPortableGit Bashを開きます。エクスプローラーでcloneした `InuzukiProject` フォルダを開き、そのフォルダでPortableGit Bashを起動してください。

演習用JDK・Gradle・GitHub CLIのPATH設定はPortableGit Bashの起動時に自動で行われます。手動で `JAVA_HOME` や `PATH` を設定しません。次を入力し、`25.0.4`、`Gradle 9.7.0`、`gh version` が表示されることを確認します。

```bash
java -version
gradle --version
gh --version
```

### 0-2. GitHub CLIへログインする

次を入力します。

```bash
$ gh auth login
```

画面の質問には、通常は次を選びます。

```text
? Where do you use GitHub? GitHub.com
? What is your preferred protocol for Git operations on this host? SSH
? Generate a new SSH key to add to your GitHub account? No
? How would you like to authenticate GitHub CLI? Login with a web browser

! First copy your one-time code: 24ED-D9D4
Press Enter to open https://github.com/login/device in your browser...
✓ Authentication complete.
- gh config set -h github.com git_protocol ssh
✓ Configured git protocol
✓ Logged in as ???? <- ここに自分のGitHub名が表示されていればOK>
! You were already logged in to this account
```

表示されたワンタイムコードをブラウザで入力して認可します。成功後、次のように自分のGitHub名が表示されます。

```bash
gh api user --jq .login
# 例: student-a
```

トークン、パスワード、ワンタイムコードをIssue、PR、ソースコードに貼り付けてはいけません。

### 0-3. 土台をmainへ確定する（教員または統合担当だけ）

学生が作業を始める前に、演習環境・instructions・scriptsがコミット済みであることを確認します。

PortableGit Bashをリポジトリ直下で開いた場合は、そのまま次を入力します。リポジトリ内のサブフォルダで開いた場合は、最初のコマンドで現在位置からリポジトリ直下へ移動します。

```bash
cd "$(git rev-parse --show-toplevel)"
git status
```

何も変更がなければ、次のように表示されます。

```text
On branch main
nothing to commit, working tree clean
```

この状態を全員の出発点にします。教員・統合担当以外は、共有の土台を直接変更せず、必ずIssue用ブランチを作ります。

## 1. 何を作るかをAIと相談する

### 1-1. 演習開始時のブレーンストーミング

最初の発散的な相談には外部Web AIを利用して構いません。未公開コード、GitHub URL、個人情報、認証情報は入力しません。AIに案を丸投げせず、学生が大まかに考えたテーマを入力し、その案を条件に照らして詳細化させます。次のプロンプトをそのまま使えます。

```text
学生チームの大まかな案は次のとおりです。

【学生の案】
（例: サークル活動で、参加者同士が練習試合の組合せと結果を管理できるようにしたい）

この案を別のアプリ案に置き換えず、発展・詳細化してください。
以下を満たす必要があります。
- Spring BootとDBを使う。
- 複数利用者が存在し、利用者間に何らかのインタラクションがある。
- 掲示板やチャットを主機能にしない。
- セットアップ手順と、ロール別ユーザマニュアルを用意できる。

対象利用者、中心となる操作、利用者間インタラクション、保存データ、ロール、主要画面を整理してください。
各条件について、満たす見込み・不足情報・確認質問を表にしてください。
最初の1週間で動かす最小の縦切りを示し、質問を最大5個示してください。
コード、DB定義、GitHub Issue本文は出力しないでください。
```

入力は「技術制約と教育上の制約」、出力は「比較可能な候補表」です。学生が候補を選んだ後だけ、合意結果を `docs/project.md` の「開発するアプリケーションの条件」を満たす形で短く反映します。

### 1-2. 開発途中のブレーンストーミング

VS Codeでこのリポジトリを開き、Copilot Chatから `.github/prompts/brainstorm-next.prompt.md` を選びます。入力は現在のコード、open Issue、最近のPRです。出力は「次週に実装できる最大3件の候補」であり、まだIssueにはしません。

Copilotの出力から学生が1件を選んだら、次の工程へ進みます。候補を採用しなかった理由まで保存する必要はありません。

## 2. 機能案をIssueにする

### 2-1. CopilotとIssue案・実装計画を作る

実体は [.github/prompts/plan-issues.prompt.md](.github/prompts/plan-issues.prompt.md) です。Copilot Chatの入力欄で `/plan-issues` と入力して選び、表示された入力欄に次を入れます。

```text
ログイン済み利用者がじゃんけん画面を表示できるようにする。
今回は手の送信、勝敗計算、履歴保存を実装しない。
```

`/plan-issues` は対話的に進みます。最初の応答では、CopilotはIssueの分割案だけを表で示し、「このIssue分割で各Issueの実装計画を作成しますか？」と質問します。この時点ではファイルを作成しません。

学生全員で分割案、依存関係、今回しないことを確認し、Chatで次のように返します。

```text
このIssue分割で実装計画を作成してください。
```

承認後、Copilotは既存コードとテストを確認し、各Issueの実装計画を含む `docs/temp/issues.md` を作成します。`docs/temp/` は `.gitignore` によりGitへ登録されません。出力には、複数Issueのための一意な `id`、重複しない `title`、任意の `assignee`、草案内の `depends-on`、Issue本文、実装計画が含まれます。

この例のために、作成されたファイルを表示します。

```bash
cat docs/temp/issues.md
```

期待する構造は次のとおりです。`game-result` は草案ID `game-page` に依存するため、登録時に実際のIssue番号への依存関係に変換されます。既存Issueへ依存する場合は `depends-on: 12` のように番号を指定できます。この番号は登録時点でOpenでなければなりません。

登録スクリプトは、各Issueについて次の6見出しが各1回あることを検査します。このうち「機能の概要」「DoD（受入条件）」「DoD確認方法」には記述が必須です。残りの3項目は、今回不要なら見出しだけでも構いません。不足していればGitHubへ登録せず停止します。制約の根拠は [docs/template-constraints.md](docs/template-constraints.md) です。

```text
## 機能の概要
## DoD（受入条件）
## 関連ファイル・変更境界
## 実装計画
## DoD確認方法
## 変更しないものとリスク
```

```md
# Issue草案

<!-- ISSUE
id: game-page
title: [Feature] じゃんけん画面を表示する
assignee: student-a
depends-on:
-->
## 機能の概要

ログイン済み利用者がじゃんけん画面を表示できる。
今回しないこと: 勝敗計算、履歴保存。

## DoD（受入条件）

- Given ログイン済み、When `/game` を開く、Then 手を選ぶ画面が表示される。

## 関連ファイル・変更境界

- 新規: `GameController.java`、`game.html`、対応するControllerテスト。
- `SecurityConfig.java`、DB、勝敗計算は変更しない。

## 実装計画

1. `GameController.java` を追加し、GET `/game` で画面を返す。
2. `game.html` を追加し、手の選択肢を表示する。
3. `GameControllerTest.java` を追加し、DoDを確認する。

## DoD確認方法

- DoD 1: MockMvcでログイン済み利用者の画面表示を確認する。

## 変更しないものとリスク

- `SecurityConfig.java`、DB、勝敗計算は変更しない。
<!-- END ISSUE -->

<!-- ISSUE
id: game-result
title: [Feature] じゃんけんの勝敗を表示する
assignee:
depends-on: game-page
-->
## 機能の概要

利用者が選んだ手と相手の手から勝敗を表示する。
今回しないこと: 履歴保存。

## DoD（受入条件）

- Given じゃんけん画面、When グーを選んで勝負する、Then 勝敗が表示される。

## 関連ファイル・変更境界

## 実装計画

1. `GameService.java` に勝敗判定を実装する。
2. ServiceのJUnitテストを追加する。
3. Controllerと画面を更新して結果を表示する。

## DoDと確認方法

- DoD 1: JUnitで勝ち・負け・あいこを確認する。

## 変更しないものとリスク

- 履歴保存とランキングは実装しない。
<!-- END ISSUE -->
```

学生全員で、各Issueの「今回しないこと」「DoD」「変更境界」「実装計画」を確認してから登録します。

### 2-2. Issueを決定的に登録する

複数Issueをまとめて登録します。次を入力します。

```bash
bash scripts/issue/register-from-file.sh docs/temp/issues.md
```

`assignee:` が空欄のIssueがある場合、スクリプトは登録を始めずに担当者GitHub名を質問します。例では、次を入力します。

```text
Issue『[Feature] じゃんけんの勝敗を表示する』の担当者GitHub名を入力してください: student-b
```

次に、登録予定と既存Issueの判定結果が表示されます。

```text
--- Issue登録プレビュー ---
[新規登録] id=game-page title=[Feature] じゃんけん画面を表示する assignee=student-a depends-on=なし
[新規登録] id=game-result title=[Feature] じゃんけんの勝敗を表示する assignee=student-b depends-on=game-page
この内容で新規Issueを登録し、依存関係を設定しますか? [y/N]
```

内容が正しければ `y` を入力します。成功すると、実際のIssue番号と依存関係が表示されます。

```text
作成: #12 [Feature] じゃんけん画面を表示する
作成: #13 [Feature] じゃんけんの勝敗を表示する
依存関係を設定: #13 は #12 に依存
完了しました。
```

同じ `docs/temp/issues.md` でスクリプトをもう一度実行しても、同一の `title` を持つIssueを検索して登録をスキップします。二重登録はされません。GitHub画面で直接起票する場合も、`Feature` Issue Formが同じ必須項目の入力を求めます。ただし既存IssueがOpenかという依存関係の検査は、必ずこの登録スクリプトを使って行います。

## 3. 実行可能なIssueを選び、ブランチを作る

実行可能とは、openであり、未完了の依存IssueがないIssueです。作業ツリーに未コミットの変更があると、このスクリプトは最初に停止します。変更を確認してcommitしてから、次を入力します。

```bash
bash scripts/issue/ready.sh
```

最初に、実行可能なIssue一覧が表示されます。

```text
#12  [Feature] じゃんけん画面を表示する  担当: student-a
```

`#13` が `#12` に依存していれば、`#12` がcloseされるまで `#13` は表示されません。

次に、開始するIssue番号を入力します。この例では `12` を入力します。

```text
開始するIssue番号を # なしで入力してください: 12
```

現在の担当が実行者と異なる、または未割当の場合、担当を実行者へ変更してよいか質問されます。担当者を変えたくない場合は `n` を入力し、作業を中止します。

```text
Issue #12 の現在の担当: student-b
実行者 student-a を担当者に変更しますか? [y/N] y
```

続けて、ブランチ名の末尾を入力します。英小文字・数字・ハイフンだけを使います。`game-page` と入力すると、実際のブランチ名は `feat/issue-12-game-page` になります。

```text
ブランチ名の末尾を英小文字・数字・ハイフンで入力してください（例: game-page）: game-page
```

スクリプトは、担当変更、作成するブランチ、実行予定のGitコマンドを表示します。内容を確認して `y` を入力した場合だけ実行されます。

```text
--- 実行内容の確認 ---
Issue: #12
実行者: student-a
担当者変更: student-b → student-a
作成するブランチ: feat/issue-12-game-page
実行するコマンド: git fetch origin main / git switch main / git pull --ff-only origin main / git switch -c feat/issue-12-game-page
上記を実行しますか? [y/N] y
```

`y` の後、Issue担当を更新し、次の順で `origin/main` を最新化して新しいブランチへ切り替えます。

```text
git fetch origin main
git switch main
git pull --ff-only origin main
git switch -c feat/issue-12-game-page
```

成功時は、実行した内容と現在のブランチ・commit・作業ツリーの状態が最後に表示されます。

```text
--- 実施内容 ---
Issue #12 の担当者: student-a
実行済み: git fetch origin main
実行済み: git switch main
実行済み: git pull --ff-only origin main
実行済み: git switch -c feat/issue-12-game-page
現在のブランチ: feat/issue-12-game-page
現在のcommit: abc1234 最新のコミットメッセージ
作業ツリー: 0 件の未コミット変更
```

未コミット変更がある場合は、次のように停止します。この場合は勝手に削除せず、変更を確認してcommitするか、教員・統合担当に相談します。

```text
停止: 未コミットの変更があります。先に変更を確認してcommitしてください。
 M inujanken/src/main/java/...
```

## 4. Copilotに実装を依頼し、学生が確認する

Copilot Chatで、`implement-issue` Skillを使うことを明示して次の依頼を入力します。Skillを使った場合、Copilotの最初の応答に `使用Skill: implement-issue` と表示されます。

```text
`implement-issue` Skillを使って、Issue #12 本文の実装計画に従って実装してください。

制約:
- DoDと関連ファイル・変更境界の範囲だけを変更する。
- GameController、game.html、対応テストを実装する。
- SecurityConfig.java、DB、勝敗計算は変更しない。
- 実装後に `gradle test` を実行し、DoDごとの結果を報告する。
- Web画面を変更したため、`gradle bootRun` によるブラウザ確認の手順も示す。
```

Copilotが変更した後、学生は必ず差分を読みます。

```bash
git status
git diff
```

期待される `git status` の例です。

```text
On branch feat/issue-12-game-page
Untracked files:
  inujanken/src/main/java/inuzuki/is/inujanken/GameController.java
  inujanken/src/main/resources/templates/game.html
  inujanken/src/test/java/inuzuki/is/inujanken/GameControllerTest.java
```

次にテストします。

```bash
cd inujanken
gradle test
```

成功時の最後には次のように表示されます。

```text
BUILD SUCCESSFUL
```

自動テストの後、実際にアプリケーションを起動して操作します。`gradle bootRun` は起動したまま待機するコマンドです。このターミナルでは別のコマンドを入力せず、ブラウザ確認が終わるまでそのままにします。

```bash
gradle bootRun
```

成功時には、次のようにアプリケーションが起動したことを示すログが表示されます。

```text
Started InujankenApplication in ... seconds
```

ブラウザで `http://localhost:8080/game` を開きます。未ログインならログイン画面が表示されます。`yamada` と `taro` でログイン後、「じゃんけん」の見出しとグー・チョキ・パーの選択肢が表示されることを確認します。確認後、ターミナルで `Ctrl+C` を押して停止します。

テストが失敗したら、すぐに「直して」とは言いません。`diagnose-failure` Skillを使うことを明示してCopilotに次のように依頼します。最初の応答に `使用Skill: diagnose-failure` と表示されます。

```text
`diagnose-failure` Skillを使って、このテスト失敗を診断してください。
修正はまだしないでください。再現条件、ログから分かる事実、原因候補、最小の確認方法を示してください。
```

学生が原因と修正範囲を理解してから修正を承認します。修正後は同じSkillの手順に従い、`gradle test` と、画面に影響する場合は `gradle bootRun` によるブラウザ確認を再実施します。

## 5. commitし、PRを作成する

テスト成功後、変更をcommitします。

```bash
cd ..
git add inujanken/src/main/java/inuzuki/is/inujanken/GameController.java
git add inujanken/src/main/resources/templates/game.html
git add inujanken/src/test/java/inuzuki/is/inujanken/GameControllerTest.java
git commit -m "feat: add game page"
```

成功すると、次のようにコミット数とファイル数が表示されます。

```text
[feat/issue-12-game-page abc1234] feat: add game page
 3 files changed, ... insertions(+)
```

commit後、Copilot Chatで `prepare-pull-request` Skillを使うことを明示して依頼します。このSkillは現在のブランチ名からIssue番号を読み取り、Issue本文、実装計画、差分、commit、テスト結果を確認します。最初の応答に `使用Skill: prepare-pull-request` と表示されます。

```text
`prepare-pull-request` Skillを使って、PR本文を準備してください。
```

Skillは不足している情報をまとめて質問します。学生は実行結果を自分で確認して回答します。

```text
- DoDごとの確認結果は何ですか?
- `gradle test` の最終結果は何ですか?
- `gradle bootRun` 後、ブラウザで何を確認しましたか?
- 今回、Controller・Template・Testはそれぞれ何を担当しますか?
- AIの提案で採用しなかったものと、その理由は何ですか?
```

回答後、SkillはPR本文を `docs/temp/pr-12.md` に自動作成します。`docs/temp/` はGitへ登録されません。本文には、関連Issue、変更内容、確認するDoD、テストと確認内容、自分の理解とAI利用が含まれます。作成スクリプトは、次の5見出しが各1回あることを確認します。そのうち「関連Issue」「変更内容」「確認するDoD」には記述が必須で、残りの2項目は空欄でも構いません。関連Issueには実在するIssue番号を `#12` の形で記載します。`Closes #12` はOpen Issueだけに使え、完了済みIssueを参照する場合は `Refs #12` と書きます。

```text
## 関連Issue
## 変更内容
## 確認するDoD
## テストと確認内容
## 自分の理解とAI利用
```

学生は、作成結果を確認します。

```bash
cat docs/temp/pr-12.md
```

確認後、引数なしでPR登録スクリプトを実行します。

```bash
bash scripts/pr/create.sh
```

スクリプトは、現在のブランチ名からIssue番号の候補を表示し、関連Issue番号、PR題名、PR本文ファイルを対話的に収集します。Enterだけを押すと、Issue番号はブランチ名から、題名はIssueの題名から、本文は `docs/temp/pr-12.md` から設定されます。

```text
関連Issue番号を入力してください [12]:
PR題名を入力してください [[Feature] じゃんけん画面を表示する]:
PR本文ファイルを入力してください [docs/temp/pr-12.md]:
--- 作成するPR ---
ブランチ: feat/issue-12-game-page
関連Issue: #12
題名: [Feature] じゃんけん画面を表示する
本文ファイル: docs/temp/pr-12.md
（PR本文が表示される）
この内容でpushしてPull Requestを作成しますか? [y/N]
```

内容が正しければ `y` を入力します。スクリプトはその後にだけ、pushとPR作成を実行します。GitHubの画面から直接作成・編集されたPRも、`Validate pull request body` が同じ形式を検査します。リポジトリ管理者は、このチェックを `main` へのマージ必須条件に設定します。

```text
git push -u origin feat/issue-12-game-page
gh pr create --base main --head feat/issue-12-game-page ...
```

成功するとPRのURLが表示されます。別の学生がIssueのDoD、差分、テストを確認し、レビューします。CI成功、レビュー承認、DoD確認がそろったら `main` へマージします。

## 6. 火曜の振り返りと教員ヒアリング

火曜13:30に、対象期間のマージ済みPRを集計します。例として2026年9月1日から9月7日を集計する場合は次を入力します。

```bash
bash scripts/report/weekly-summary.sh 2026-09-01 2026-09-07
```

出力は、Google Slidesへ貼り付けるMarkdown表です。

```md
| PR | 担当者 | マージ日時 | 関連Issue |
| --- | --- | --- | --- |
| [34 じゃんけん画面を表示する](...) | student-a | 2026-09-03T... | #12 |
```

各学生は、この表を根拠にして、Slidesへ次を記載します。

1. 自分のIssue・PRと実装内容
2. 自分が説明できる設計・テストの要点
3. AIの提案を採用・不採用にした理由
4. 次週に改善するプロンプト、Skill、作業手順

教員ヒアリングでは、作者本人がIssue、PR、テスト、画面デモを示しながら説明します。確認するのは「動いたか」だけではありません。なぜその設計にしたか、どのテストがDoDを保証するか、AIのどの提案を採用しなかったかを説明できることが目標です。

## 文書を追加してよい場合

- 認証方式やDB方式など、将来の実装にも影響する決定をした: `docs/adr/`
- 同じ原因の障害が2回以上起きた: `docs/troubleshooting.md`

それ以外はIssue、PR、テストに残します。これにより、実装と文書の乖離を防ぎます。
