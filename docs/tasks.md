# ログイン実装計画

作成日: 2025-11-11

目的: 調査レポート（docs/reports/investigate/2025-11-11_ログイン実装調査.md）に基づき、ID: `yamada` / PW: `taro` でログインできるようにするための実装計画を記載する。

実装方針（確認事項）
- パスワードの扱い: 開発段階の動作確認を迅速に行うために一時的にNoOp(平文)でテストするか、最初からBCryptで実装するかを決定してください。
- ログイン画面: Spring Security のデフォルトログイン画面で良いか、カスタムの `login.html` を作成するかを決定してください。

全体の流れ（概要）
1. main ブランチにいることを確認する
2. 新しいブランチを作成（例: `feat/login`）
4. セキュリティ設定クラスを追加（in-memory ユーザ登録）
6. 起動・動作確認（gradle bootRun）
7. 完了レポートの作成（docs/reports/done/）および `docs/specs.md` の更新

タスク一覧（優先度順）

タスク 1: ブランチ準備（必須・高）
- 説明: 実装作業を行うため、必ず main ブランチにいることを確認し、新規ブランチを作成する。
- 手順:
  1. リポジトリルートで `git branch --show-current` を実行して現在ブランチを確認する。
  2. main ブランチでない場合は `git switch main`（必要に応じて `git pull`）を行う。
  3. 新規ブランチを作成: `git switch -c feat/login`。
- 関連ファイル: なし
- DoD: `git status` で作業ブランチが `feat/login` になっていること。

タスク 3: セキュリティ設定クラスの追加（必須・高）
- 説明: in-memory ユーザを登録し、フォームログインを有効化する設定クラスを追加する。
- 変更 / 追加ファイル:
  - `src/main/java/inuzuki/is/inujanken/SecurityConfig.java`（新規）
- 実装要点:
  - パッケージ名は既存のアプリケーションパッケージに合わせる（`inuzuki.is.inujanken`）。
  - in-memory ユーザ `yamada` をパスワード `taro` で登録。
  - 開発用の PasswordEncoder は相談の上 NoOp または BCrypt を使用。
  - 静的リソース（`/css/**`, `/js/**`, `/images/**`, `/static/**` 等）は `permitAll()` に設定。
  - ルート(`/`)へのアクセスは認証済みユーザのみ許可するか、ログイン後の遷移先を設定。
- DoD: アプリ起動後、未認証状態で保護ページにアクセスするとログイン画面（デフォルトまたはカスタム）が表示されること。

タスク 5: 起動確認とマニュアル検証（必須・高）
- 説明: 実装後に実行・検証を行う。
- 手順:
  1. `inujanken/` ディレクトリで `gradle bootRun` を実行する。
  2. ブラウザで `http://localhost:8080/` にアクセスする（アプリが別ポート設定ならそのポート）。
  3. 保護されたページにリダイレクトされるか、ログイン画面が表示されることを確認する。
  4. ID:`yamada` / PW:`taro` でログインが成功し、ログイン後のページ（トップなど）に遷移することを確認する。
- 関連ファイル: `src/main/resources/application.properties`（ポートや設定を変更する場合）
- DoD: ブラウザで実際に `yamada/taro` でログインできること。

タスク 6: 文書化と完了報告（必須・中）
- 説明: 実装が完了したら done レポートを作成し、`docs/specs.md` を更新する。
- 変更ファイル:
  - `docs/reports/done/done_YYYY-MM-DD_ログイン実装.md`（新規）
  - `docs/specs.md`（必要に応じて更新）
- 記載内容:
  - 実装したタスクの詳細、確認手順、使用したブランチ名（例: `feat/login`）、テスト結果、注意点。
- DoD: done レポートが作成され、`docs/specs.md` に実装が反映されていること。

関連ファイル一覧（ワークスペースルートからの相対パス）
- inujanken/src/main/java/inuzuki/is/inujanken/InujankenApplication.java
- inujanken/src/main/resources/application.properties
- inujanken/src/main/resources/static/index.html
- src/main/java 以下の既存パッケージ構成に従って SecurityConfig を追加
- docs/specs.md
- docs/reports/done/

動作確認用テストケース（手動）
1. 未ログイン状態で保護対象ページ（`/` など）にアクセス → ログイン画面へリダイレクトされる
2. ID:`yamada` / PW:`taro` でログイン → 認証成功して保護ページへアクセス可能
3. 間違ったパスワードでログイン → 認証失敗しログイン画面に戻る
4. 静的リソース（`/static/index.html` 等）へのアクセスは認証不要（`permitAll`）で表示される

自動テスト（オプション）
- Spring Boot の統合テスト（MockMvc）で認証の成功/失敗をテストするJUnitテストを追加することが可能。必要であれば別タスクとして追加します。

必要なコマンド（作業者が実行する）
- ブランチ作成例:
  - git switch main
  - git pull
  - git switch -c feat/login
- 依存解決と起動:
  - cd inujanken
  - gradle bootRun

依頼するユーザ判断（次の指示で指定してください）
1. 平文(NoOp)での簡易検証を行うか、BCryptで実装するかを選択してください。
2. カスタムログインページ（`login.html`）を作るか、デフォルトのログイン画面で問題ないか選択してください。

備考
- この計画は調査レポートの範囲内で実装するための最小限のタスクに分割しています。要件の変更や追加機能がある場合は、計画を再作成します。

以上。
