# システム仕様（全体）

## 概要
- プロジェクト名: Inuzanken
- 目的: Spring Boot で実装された Web アプリケーション。静的ページ表示と認証機能を持つサンプルアプリ。
- アプリケーションのエントリポイント: `inujanken/src/main/java/inuzuki/is/inujanken/InujankenApplication.java`

## プロジェクト構成（主要部分、ワークスペースルートからの相対パス）
- inujanken/
  - `build.gradle` - ビルド定義
  - `src/main/java/inuzuki/is/inujanken/` - Java ソース
    - `InujankenApplication.java` - アプリケーション起動クラス
    - `SecurityConfig.java` - 認証関連の設定（追加済み）
  - `src/main/resources/static/` - 静的リソース（`index.html` 等）
  - `src/main/resources/templates/` - Thymeleaf テンプレート（任意）
  - `src/main/resources/application.properties` - アプリ設定

## 使用技術・依存関係
- Java, Spring Boot
- 主要依存（想定、プロジェクトの `build.gradle` を参照）:
  - `org.springframework.boot:spring-boot-starter-web`
  - `org.springframework.boot:spring-boot-starter-thymeleaf`（テンプレートを使用する場合）
  - `org.springframework.boot:spring-boot-starter-security`（認証）

## 認証（実装済み）
- 方式: Spring Security を利用したフォーム認証（デフォルトのログイン画面を使用）。
- 実装場所: `inujanken/src/main/java/inuzuki/is/inujanken/SecurityConfig.java`
- ユーザ: in-memory にて以下を登録
  - ユーザ名: `yamada`
  - パスワード: `taro`（BCrypt でエンコードして保存）
  - ロール: `USER`
- セキュリティ設定の要点:
  - 静的リソース (`/css/**`, `/js/**`, `/images/**`, `/webjars/**`, `/index.html`, `/static/**`) は認証不要（permitAll）
  - その他のリクエストは認証を要求する
  - デフォルトのフォームログイン、ログアウトを有効化

## 実行方法
- ワークフロー推奨:
  1. main にいることを確認し、新規ブランチを作成して実装・コミットする（例: `feat/login`）。
  2. `cd inujanken`
  3. `gradle bootRun` で起動
- ブラウザ確認:
  - `http://localhost:8080/` にアクセス
  - 保護ページにアクセスするとログイン画面にリダイレクトされる
  - ユーザ `yamada` / パスワード `taro` でログインして保護ページが表示されることを確認する

## 検証項目（DoD）
- `gradle bootRun` でアプリが正常に起動する
- 未認証で保護ページへアクセスした場合、ログイン画面へリダイレクトされる
- `yamada/taro` でログインできること
- 静的リソース（例: `src/main/resources/static/index.html`）は認証不要で表示されること

## 関連ファイル一覧（重要）
- `inujanken/src/main/java/inuzuki/is/inujanken/InujankenApplication.java`
- `inujanken/src/main/java/inuzuki/is/inujanken/SecurityConfig.java` (追加済)
- `inujanken/src/main/resources/static/index.html`
- `inujanken/src/main/resources/application.properties`
- `docs/reports/investigate/2025-11-11_ログイン実装調査.md`
- `docs/reports/done/done_2025-11-11_ログイン実装.md`
- `docs/tasks.md`

## テスト
- 手動テスト: 動作確認手順のとおり。ログイン成功/失敗、静的リソースの閲覧を確認する。
- 自動テスト（任意）: Spring の MockMvc を使った統合テストで、認証成功/失敗を検証するテストケースを追加可能。

## 開発ワークフローと運用上の注意
- 実装は必ず main ブランチから新しいブランチを切って行うこと（例: `feat/login`）。
- 実装完了後は `docs/reports/done/` に完了レポートを作成し、`docs/specs.md` を更新すること。
- パスワードは本番では平文や NoOp を使わず、必ず安全なエンコーダ（BCrypt 等）を使用すること。

## 今後の課題・改善案
- 本番用のユーザ管理をデータベースに切替（JPA/MyBatis 等）し、永続的なユーザ管理を実装する。
- カスタムログインページ（`login.html`）の追加と UI 改善。
- ユーザ登録・パスワードリセット機能の追加。
- 自動テスト（MockMvc）を CI に組み込む。

以上。
