#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/course-env.sh"

FROM="${1:-}"; TO="${2:-}"
[[ "$FROM" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ && "$TO" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || {
  echo "使い方: bash scripts/report/weekly-summary.sh 開始日 終了日" >&2; exit 1;
}

echo "# 週次開発一覧 (${FROM} から ${TO})"
echo
echo "| PR | 担当者 | マージ日時 | 関連Issue |"
echo "| --- | --- | --- | --- |"
while IFS=$'\t' read -r number title author merged_at url; do
  issues="$(gh pr view "$number" --json closingIssuesReferences --jq '[.closingIssuesReferences[].number | "#" + tostring] | join(", ")')"
  printf '| [%s %s](%s) | %s | %s | %s |\n' "$number" "$title" "$url" "$author" "$merged_at" "${issues:-なし}"
done < <(gh pr list --state merged --search "merged:${FROM}..${TO}" --limit 100 --json number,title,author,mergedAt,url --jq '.[] | [.number, .title, .author.login, .mergedAt, .url] | @tsv')

