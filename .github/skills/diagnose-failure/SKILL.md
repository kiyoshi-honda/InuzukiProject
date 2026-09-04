---
name: diagnose-failure
description: Spring Bootの不具合やテスト失敗を再現し、根拠をもって最小修正へ導く。
---

# 不具合を診断する

開始時に「使用Skill: diagnose-failure」と明示する。

1. 期待結果、実際の結果、再現手順を確認する。
2. ログとコードから原因候補を挙げ、最小の確認方法を提案する。
3. 原因・修正範囲・再発防止テストを学生が承認してから変更する。
4. 修正後に `gradle test` を実行し、画面に影響する場合は `gradle bootRun` による手動確認も依頼する。

