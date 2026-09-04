# Issue草案

<!-- ISSUE
id: game-page
title: [Feature] じゃんけん画面を表示する
assignee: student-a
depends-on:
-->
## 機能の概要

ログイン済み利用者が `/game` を開くと、じゃんけんの手を選ぶ画面を表示できるようにする。
今回しないこと: 手の送信、勝敗計算、履歴保存。

## DoD（受入条件）

- Given `yamada` でログイン済み、When `/game` を開く、Then 「じゃんけん」の見出しとグー・チョキ・パーの選択肢が表示される。
- Given 未ログイン、When `/game` を開く、Then ログイン画面へ遷移する。
- `gradle test` が成功する。

## 関連ファイル・変更境界

- 新規: `inujanken/src/main/java/inuzuki/is/inujanken/GameController.java`
- 新規: `inujanken/src/main/resources/templates/game.html`
- 新規または更新: `inujanken/src/test/java/inuzuki/is/inujanken/GameControllerTest.java`
- `SecurityConfig.java` の認証方針は変更しない。

## 実装計画

1. `GameController.java` を追加し、GET `/game` で `game` テンプレートを返す。
2. `game.html` を追加し、じゃんけんの手を選ぶ画面を表示する。
3. `GameControllerTest.java` を追加し、ログイン済みと未ログインの表示を確認する。

## DoD確認方法

- DoD 1: MockMvcでログイン済み利用者のHTTP 200と画面表示を確認する。
- DoD 2: MockMvcで未ログイン利用者のログイン画面遷移を確認する。
- DoD 3: `gradle test` が成功することを確認する。

## 変更しないものとリスク

- `SecurityConfig.java` の認証方針、DB、勝敗計算は変更しない。
<!-- END ISSUE -->

<!-- ISSUE
id: game-result
title: [Feature] じゃんけんの勝敗を表示する
assignee:
depends-on: game-page
-->
## 機能の概要

利用者が選んだ手と相手の手から、勝敗を画面に表示する。
今回しないこと: 履歴保存、ランキング。

## DoD（受入条件）

- Given じゃんけん画面、When グーを選んで勝負する、Then 勝敗と両者の手が表示される。
- 勝ち、負け、あいこの各条件を自動テストで確認できる。

## 関連ファイル・変更境界

- 新規または更新: `inujanken/src/main/java/inuzuki/is/inujanken/GameController.java`
- 新規: `inujanken/src/main/java/inuzuki/is/inujanken/GameService.java`
- 更新: `inujanken/src/main/resources/templates/game.html`
- 新規または更新: `inujanken/src/test/java/inuzuki/is/inujanken/GameControllerTest.java`
- 新規: `inujanken/src/test/java/inuzuki/is/inujanken/GameServiceTest.java`

## 実装計画

1. `GameService.java` を追加し、勝敗判定を実装する。
2. `GameServiceTest.java` を追加し、勝ち・負け・あいこを確認する。
3. `GameController.java` と `game.html` を更新し、選んだ手と勝敗を表示する。

## DoD確認方法

- DoD 1: MockMvcでフォーム送信後の勝敗表示を確認する。
- DoD 2: JUnitで勝ち・負け・あいこの勝敗判定を確認する。

## 変更しないものとリスク

- DBへの履歴保存とランキングは実装しない。
<!-- END ISSUE -->
