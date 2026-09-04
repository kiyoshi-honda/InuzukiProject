#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/course-env.sh"

is_executable() {
  local number="$1" state blockers
  state="$(gh issue view "$number" --json state --jq '.state')"
  blockers="$(gh issue view "$number" --json blockedBy --jq '[.blockedBy[] | select(.state != "CLOSED")] | length')"
  [[ "$state" == "OPEN" && "$blockers" == "0" ]]
}

git diff --quiet && git diff --cached --quiet || {
  echo "停止: 未コミットの変更があります。先に変更を確認してcommitしてください。" >&2
  git status --short
  exit 1
}

echo "--- 実行可能なIssue（openかつ未完了の依存Issueなし） ---"
candidate_count=0
while IFS=$'\t' read -r number title assignees; do
  if is_executable "$number"; then
    echo "#$number  $title  担当: ${assignees:-未割当}"
    candidate_count=$((candidate_count + 1))
  fi
done < <(gh issue list --state open --limit 1000 --json number,title,assignees --jq '.[] | [.number, .title, ([.assignees[].login] | join(","))] | @tsv')

[[ "$candidate_count" -gt 0 ]] || { echo "実行可能なIssueはありません。"; exit 0; }
read -r -p "開始するIssue番号を # なしで入力してください: " ISSUE_NUMBER
[[ "$ISSUE_NUMBER" =~ ^[0-9]+$ ]] || { echo "停止: Issue番号は数字で入力してください。" >&2; exit 1; }
is_executable "$ISSUE_NUMBER" || { echo "停止: Issue #$ISSUE_NUMBER は実行可能ではありません。" >&2; exit 1; }

CURRENT_USER="$(gh api user --jq .login)"
ASSIGNEES="$(gh issue view "$ISSUE_NUMBER" --json assignees --jq '[.assignees[].login] | join(",")')"
if [[ ",$ASSIGNEES," != *",$CURRENT_USER,"* ]]; then
  echo "Issue #$ISSUE_NUMBER の現在の担当: ${ASSIGNEES:-未割当}"
  read -r -p "実行者 ${CURRENT_USER} を担当者に変更しますか? [y/N] " CHANGE_ASSIGNEE
  [[ "$CHANGE_ASSIGNEE" == "y" || "$CHANGE_ASSIGNEE" == "Y" ]] || { echo "停止: 担当者を変更しないため開始しません。"; exit 0; }
fi

read -r -p "ブランチ名の末尾を英小文字・数字・ハイフンで入力してください（例: game-page）: " BRANCH_SUFFIX
[[ "$BRANCH_SUFFIX" =~ ^[a-z0-9][a-z0-9-]*$ ]] || { echo "停止: 不正なブランチ名です。" >&2; exit 1; }
BRANCH_NAME="feat/issue-${ISSUE_NUMBER}-${BRANCH_SUFFIX}"
git show-ref --verify --quiet "refs/heads/$BRANCH_NAME" && { echo "停止: ブランチ $BRANCH_NAME は既に存在します。" >&2; exit 1; }

echo "--- 実行内容の確認 ---"
echo "Issue: #$ISSUE_NUMBER"
echo "実行者: $CURRENT_USER"
echo "担当者変更: ${ASSIGNEES:-未割当} → $CURRENT_USER"
echo "作成するブランチ: $BRANCH_NAME"
echo "実行するコマンド: git fetch origin main / git switch main / git pull --ff-only origin main / git switch -c $BRANCH_NAME"
read -r -p "上記を実行しますか? [y/N] " CONFIRM
[[ "$CONFIRM" == "y" || "$CONFIRM" == "Y" ]] || { echo "中止しました。"; exit 0; }

if [[ ",$ASSIGNEES," != *",$CURRENT_USER,"* ]]; then
  for assignee in ${ASSIGNEES//,/ }; do
    [[ -n "$assignee" ]] && gh issue edit "$ISSUE_NUMBER" --remove-assignee "$assignee" >/dev/null
  done
  gh issue edit "$ISSUE_NUMBER" --add-assignee "$CURRENT_USER" >/dev/null
fi
git fetch origin main
git switch main
git pull --ff-only origin main
git switch -c "$BRANCH_NAME"

echo "--- 実施内容 ---"
echo "Issue #$ISSUE_NUMBER の担当者: $CURRENT_USER"
echo "実行済み: git fetch origin main"
echo "実行済み: git switch main"
echo "実行済み: git pull --ff-only origin main"
echo "実行済み: git switch -c $BRANCH_NAME"
echo "現在のブランチ: $(git branch --show-current)"
echo "現在のcommit: $(git log -1 --oneline)"
echo "作業ツリー: $(git status --porcelain | wc -l) 件の未コミット変更"
