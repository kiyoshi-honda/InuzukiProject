# InuzukiProject

Spring Boot を題材に、4人程度のチームで Agent-Driven Development（ADD）を学ぶ演習用リポジトリです。

## 開発の入口

作業の正本は GitHub Issue と Pull Request（PR）です。各機能は小さな Issue として作成し、1 Issue を1本の短いPRで実装します。`main` への直接push、共有の作業計画書・完了報告書の作成はしません。

1. Issue の受入条件と変更境界を確認する。
2. `main` から `feat/issue-番号-短い名前` ブランチを作る。
3. Copilot と変更計画・テスト計画を確認してから実装する。
4. `inujanken` で `./gradlew test`（Windows は `./gradlew.bat test`）を実行する。
5. PR を作成し、受入条件の確認結果と自分の理解を記載する。
6. 学生レビューとCIの成功後に `main` へマージする。

詳しい作業契約は [AGENTS.md](AGENTS.md)、起動とデモは [docs/runbooks](docs/runbooks) を参照してください。

## 文書化の原則

通常の調査・完了・レビュー記録は Issue、PR、レビューコメントに残します。将来も参照する設計判断だけを [docs/adr](docs/adr) に、繰り返した障害だけを [docs/troubleshooting.md](docs/troubleshooting.md) に記録します。

## 現在の構成

- アプリケーション: `inujanken/`
- Java 25 / Spring Boot / Gradle Wrapper
- Web、Thymeleaf、Spring Security、MyBatis、H2
