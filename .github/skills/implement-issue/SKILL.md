---
name: implement-issue
description: GitHub IssueのDoDと変更境界に従い、小さなSpring Boot機能を実装・検証する。
---

# Issueを実装する

開始時に「使用Skill: implement-issue」と明示する。

1. Issue本文・コメント・依存関係を確認し、DoD、変更境界、登録済みの実装計画を要約する。
2. 関連コードとテストを読み、変更予定ファイルとテスト計画を学生へ提示する。
3. 承認された範囲だけを実装し、DoDを確認するテストを追加・更新する。
4. `gradle test` を実行する。Web画面を変更した場合は、`gradle bootRun` で起動して学生にブラウザでのDoD確認を依頼する。
5. DoDごとの自動テスト結果・手動確認結果・残る懸念をPR本文用にまとめる。
