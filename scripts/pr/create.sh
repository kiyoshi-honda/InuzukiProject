#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/course-env.sh"

BRANCH="$(git branch --show-current)"
[[ "$BRANCH" != "main" && -n "$BRANCH" ]] || { echo "エラー: mainからはPRを作成できません。" >&2; exit 1; }
git diff --quiet && git diff --cached --quiet || { echo "エラー: 先に変更をcommitしてください。" >&2; exit 1; }

if [[ "$BRANCH" =~ ^feat/issue-([0-9]+)- ]]; then
  DEFAULT_ISSUE="${BASH_REMATCH[1]}"
else
  DEFAULT_ISSUE=""
fi
read -r -p "関連Issue番号を入力してください${DEFAULT_ISSUE:+ [${DEFAULT_ISSUE]} }: " ISSUE_NUMBER
ISSUE_NUMBER="${ISSUE_NUMBER:-$DEFAULT_ISSUE}"
[[ "$ISSUE_NUMBER" =~ ^[0-9]+$ ]] || { echo "エラー: Issue番号は数字で入力してください。" >&2; exit 1; }
ISSUE_TITLE="$(gh issue view "$ISSUE_NUMBER" --json title --jq .title)"
read -r -p "PR題名を入力してください [${ISSUE_TITLE}]: " TITLE
TITLE="${TITLE:-$ISSUE_TITLE}"
DEFAULT_BODY="docs/temp/pr-${ISSUE_NUMBER}.md"
read -r -p "PR本文ファイルを入力してください [${DEFAULT_BODY}]: " BODY_FILE
BODY_FILE="${BODY_FILE:-$DEFAULT_BODY}"
[[ -f "$BODY_FILE" ]] || { echo "エラー: PR本文ファイルがありません: $BODY_FILE" >&2; exit 1; }
"${SCRIPT_DIR}/validate-body.sh" "$BODY_FILE" --check-related-issues

echo "--- 作成するPR ---"
echo "ブランチ: $BRANCH"
echo "関連Issue: #$ISSUE_NUMBER"
echo "題名: $TITLE"
echo "本文ファイル: $BODY_FILE"
cat "$BODY_FILE"
read -r -p "この内容でpushしてPull Requestを作成しますか? [y/N] " ANSWER
[[ "$ANSWER" == "y" || "$ANSWER" == "Y" ]] || { echo "中止しました。"; exit 0; }
git push -u origin "$BRANCH"
gh pr create --base main --head "$BRANCH" --title "$TITLE" --body-file "$BODY_FILE"
