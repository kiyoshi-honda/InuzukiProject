# アーキテクチャ

## 現在の構成

- アプリケーションは `inujanken/` 配下の Spring Boot プロジェクトである。
- Java 25、Spring Boot、Gradle Wrapper を使用する。
- Web、Thymeleaf、Spring Security、MyBatis、H2 を依存関係に含む。
- エントリポイントは `inujanken/src/main/java/inuzuki/is/inujanken/InujankenApplication.java` である。

## 実装の境界

- Controller: HTTPリクエストと画面・レスポンスを扱う。
- Service: ユースケースを扱う。
- Mapper/Repository: DBアクセスを扱う。
- Test: Issueの受入条件を自動確認する。

機能の詳細仕様・進捗・変更履歴は GitHub Issue とPRを正本とする。

