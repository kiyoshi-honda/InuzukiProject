# ローカル開発

## 演習用環境

`C:\oit\isdev26-byod` に同梱された以下を使用します。OSに別のJavaやGradleがあっても使用しません。

- JDK: `amazonjdk25.0.4_7`
- Gradle: `gradle-9.7.0`
- シェル: `PortableGit-2.55.0.3-64\bin\bash.exe`

## 起動とテスト

PortableGit Bash を起動し、リポジトリ直下から実行します。

```bash
export JAVA_HOME=/c/oit/isdev26-byod/amazonjdk25.0.4_7
export PATH=/c/oit/isdev26-byod/PortableGit-2.55.0.3-64/usr/bin:/c/oit/isdev26-byod/PortableGit-2.55.0.3-64/bin:/c/oit/isdev26-byod/gradle-9.7.0/bin:$JAVA_HOME/bin:$PATH
cd inujanken
gradle test
gradle bootRun
```

ブラウザで `http://localhost:8080/` を開きます。停止はターミナルで `Ctrl+C` です。
