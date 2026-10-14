# プロジェクト概要

## 開発者（GitHub名）
- igaki
- kiyoshi-honda

## 開発するアプリケーションの条件

具体的なアプリケーションは学生チームの意見を起点に決める。次の条件をすべて満たすこと。

- **A1**: Spring Bootで開発する。
- **A2**: DBを利用する。
- **A3**: 複数の利用者が存在し、利用者間に何らかのインタラクションがある。
- **A4**: チャットや掲示板など、テキスト交換を主目的とするアプリケーションではない。補助的なチャット機能は可とする。
- **A5**: GitHubリポジトリの状態から起動するためのセットアップ手順がある。
- **A6**: 起動後に操作するための、ロール別のユーザマニュアルがある。


## 開発環境

PortableGit Bash を起動して開発する。JDK、Gradle、GitHub CLIのPATH設定は自動で行われる。

初回だけ `gh auth login` を実行してGitHubへ認証する。`java -version`、`gradle --version`、`gh --version` で環境を確認する。

## 現在の構成

- アプリ本体: `inujanken/`
- 技術: Java 25 / Spring Boot 4 / Thymeleaf / Spring Security / MyBatis / H2

## ドキュメント構成

機能単位の仕様はGitHub IssueのAC、実装済みの振る舞いはテストとマージ済みPRを正本とする。

同じ原因が2回以上発生した障害を `docs/troubleshooting.md` に記録する。

## 用語と完了の定義

- **AC（Acceptance Criteria／受け入れ基準）**: 個々のIssueで、その機能を受け入れられるかを判定する観測・テスト可能な条件。原則として Given / When / Then 形式で書く。
- **DoD（Definition of Done／完了の定義）**: すべての実装Issueに共通する、mainへマージして完了扱いにしてよい条件。Issue固有の機能要件は書かない。

### 共通DoD

実装を伴うIssueは、次のすべてを満たしたときに完了とする。

1. Issueに担当者、AC、変更境界、必要な依存Issueが記録されている。
2. Issueごとのブランチで実装し、mainへ直接コミットしていない。
3. 実装がIssueの変更境界とACの範囲に収まっている。
4. すべてのACについて、自動テストまたは手動確認の結果がPRに記録されている。
5. `inujanken/` で `gradle test` が成功している。
6. Web画面を変更した場合、`gradle bootRun` による手動確認を行っている。
7. PRがテンプレートを満たし、関連Issueを正しく参照している。
8. 実装者以外がACと差分をレビューし、CI成功後にマージしている。

## おおまかな案の概要

## 対象利用者と利用者間インタラクション

## 中心となる操作

## 主要画面
