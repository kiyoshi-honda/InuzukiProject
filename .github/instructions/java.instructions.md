---
applyTo: "inujanken/src/main/java/**/*.java"
---

# Java と Spring Boot

- 既存のパッケージ `inuzuki.is.inujanken` と既存の書式に従う。
- Controller はHTTP入出力、Service はユースケース、Mapper/Repository は永続化を担当する。責務を混ぜない。
- 変更理由がコードから明らかな場合、説明だけのコメントは追加しない。複雑な意図だけを日本語で記録する。
- 入力値・認可・例外時の振る舞いを受入条件とテストで確認する。

