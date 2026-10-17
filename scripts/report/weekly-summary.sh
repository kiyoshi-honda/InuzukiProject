#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
cd "$REPO_ROOT"

for command_name in gh jq date; do
  command -v "$command_name" >/dev/null 2>&1 || {
    echo "エラー: ${command_name} が見つかりません。GitHub CLI と jq を利用できる環境で実行してください。" >&2
    exit 1
  }
done

LOGIN="$(gh api user --jq .login)"
REPOSITORY="${GITHUB_REPOSITORY:-$(gh repo view --json nameWithOwner --jq .nameWithOwner)}"
REPORT_FILE="docs/weekly-summary_${LOGIN}.html"
NOW="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
TEMP_DIR="$(mktemp -d)"
trap 'rm -rf -- "$TEMP_DIR"' EXIT

html_escape() {
  sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' -e 's/"/\&quot;/g' -e "s/'/&#39;/g"
}
markdown_html() {
  local markdown="$1"
  # jqのTSV出力でエスケープされた制御文字を、Markdownへ戻す。
  markdown="${markdown//\\r\\n/$'\n'}"
  markdown="${markdown//\\n/$'\n'}"
  markdown="${markdown//\\r/}"
  markdown="${markdown//\\t/$'\t'}"
  # 外部APIへ本文を送らず、HTML内のJavaScriptが安全にレンダリングする。
  printf '<pre class="markdown-source">%s</pre>' "$(printf '%s' "$markdown" | html_escape)"
}
format_time() { date -d "$1" '+%Y-%m-%d %H:%M JST'; }
duration() {
  local seconds days hours minutes
  seconds=$(( $(date -d "$2" +%s) - $(date -d "$1" +%s) ))
  (( seconds >= 0 )) || { printf '算出不可'; return; }
  days=$((seconds / 86400)); hours=$(((seconds % 86400) / 3600)); minutes=$(((seconds % 3600) / 60))
  if (( days > 0 )); then printf '%s日%s時間%s分' "$days" "$hours" "$minutes"
  elif (( hours > 0 )); then printf '%s時間%s分' "$hours" "$minutes"
  else printf '%s分' "$minutes"; fi
}
entry_start() {
  [[ -f "$REPORT_FILE" ]] || { printf '1970-01-01T00:00:00Z'; return; }
  local recollect latest
  recollect="$(sed -n 's/.*name="weekly-summary-recollect-from" content="\([^"]*\)".*/\1/p' "$REPORT_FILE" | head -n 1)"
  latest="$(grep -o 'data-end="[^"]*"' "$REPORT_FILE" | sed 's/data-end="\([^"]*\)"/\1/' | sort | tail -n 1)"
  if [[ -n "$recollect" ]]; then printf '%s' "$recollect"
  elif [[ -n "$latest" ]]; then printf '%s' "$latest"
  else printf '1970-01-01T00:00:00Z'; fi
}

START="$(entry_start)"
ENTRY_ID="$(date -u '+%Y%m%dT%H%M%SZ')"
if [[ -f "$REPORT_FILE" ]]; then
  sed -n '/<!-- WEEKLY-SUMMARY-ENTRY /,/<!-- \/WEEKLY-SUMMARY-ENTRY -->/p' "$REPORT_FILE" > "$TEMP_DIR/old-entries.html"
else
  : > "$TEMP_DIR/old-entries.html"
fi

# 一括GraphQL要求は、PR数とネストしたコミット・関連Issueの積が上限を超える。
# 一覧はREST APIで取得し、関連Issueだけを対象PRごとに個別取得する。
echo "PR一覧を取得しています（REST API）..." >&2
gh api --paginate --slurp "repos/${REPOSITORY}/pulls?state=all&sort=updated&direction=desc&per_page=100" \
  | jq 'add // []' > "$TEMP_DIR/all-pulls-rest.json"
jq --arg login "$LOGIN" '
  [ .[] | select(.user.login == $login) |
    {number, title, body: (.body // "（本文なし）"), url: .html_url, createdAt: .created_at, closedAt: .closed_at} ]
' "$TEMP_DIR/all-pulls-rest.json" > "$TEMP_DIR/prs.json"

echo "Open Issue一覧を取得しています（REST API）..." >&2
gh api --paginate --slurp "repos/${REPOSITORY}/issues?state=open&per_page=100" \
  | jq 'add // [] |
    [ .[] | select(.pull_request == null) |
      {number, title, body: (.body // "（本文なし）"), url: .html_url, createdAt: .created_at,
       assignees: [.assignees[] | {login}], author: {login: .user.login}} ]
  ' > "$TEMP_DIR/open-issues.json"
gh api --paginate --slurp "repos/${REPOSITORY}/issues/comments?since=${START}&per_page=100" | jq 'add // []' > "$TEMP_DIR/issue-comments.json"
gh api --paginate --slurp "repos/${REPOSITORY}/pulls/comments?since=${START}&per_page=100" | jq 'add // []' > "$TEMP_DIR/review-comments.json"
gh api --paginate --slurp "repos/${REPOSITORY}/commits?author=${LOGIN}&since=${START}&until=${NOW}&per_page=100" | jq 'add // []' > "$TEMP_DIR/commits.json"

jq --arg start "$START" --arg end "$NOW" '[ .[] | select((.createdAt >= $start and .createdAt <= $end) or (.closedAt != null and .closedAt >= $start and .closedAt <= $end)) ]' "$TEMP_DIR/prs.json" > "$TEMP_DIR/period-prs.json"
mv "$TEMP_DIR/period-prs.json" "$TEMP_DIR/period-prs-base.json"
: > "$TEMP_DIR/period-prs-details.jsonl"
while IFS= read -r pr_number; do
  pr_number="${pr_number%$'\r'}"
  pr="$(jq --argjson number "$pr_number" '.[] | select(.number == $number)' "$TEMP_DIR/period-prs-base.json")"
  echo "PR #${pr_number} の詳細を取得しています..." >&2
  commits="$(gh api --paginate --slurp "repos/${REPOSITORY}/pulls/${pr_number}/commits?per_page=100" \
    | jq '[add[] | {committedDate: .commit.committer.date, authoredDate: .commit.author.date}]')"
  closing='[]'
  if [[ "$(jq -r '.closedAt != null' <<<"$pr")" == true ]]; then
    if ! closing="$(gh pr view "$pr_number" --repo "$REPOSITORY" --json closingIssuesReferences --jq '.closingIssuesReferences' 2>"$TEMP_DIR/pr-${pr_number}-closing-error.log")"; then
      echo "警告: PR #${pr_number} の関連Issueを取得できませんでした。Issue情報なしで続行します。" >&2
      closing='[]'
    fi
  fi
  jq --argjson commits "$commits" --argjson closing "$closing" \
    '. + {commits: $commits, closingIssuesReferences: $closing}' <<<"$pr" >> "$TEMP_DIR/period-prs-details.jsonl"
done < <(jq -r '.[].number' "$TEMP_DIR/period-prs-base.json" | tr -d '\r')
jq -s '.' "$TEMP_DIR/period-prs-details.jsonl" > "$TEMP_DIR/period-prs.json"

jq --arg login "$LOGIN" --arg start "$START" --arg end "$NOW" '[ .[] | select(.user.login == $login and .created_at >= $start and .created_at <= $end) ]' "$TEMP_DIR/issue-comments.json" > "$TEMP_DIR/period-issue-comments.json"
jq --arg login "$LOGIN" --arg start "$START" --arg end "$NOW" '[ .[] | select(.user.login == $login and .created_at >= $start and .created_at <= $end) ]' "$TEMP_DIR/review-comments.json" > "$TEMP_DIR/period-review-comments.json"

{
  echo "<!-- WEEKLY-SUMMARY-ENTRY id=\"$ENTRY_ID\" data-start=\"$START\" data-end=\"$NOW\" -->"
  echo "<template class=\"weekly-entry\" data-id=\"$ENTRY_ID\" data-start=\"$START\" data-end=\"$NOW\">"
  echo "<section><h2>記録日時: $(format_time "$NOW")</h2><p>対象期間: $(format_time "$START") から $(format_time "$NOW")。PR作者: <code>@$LOGIN</code></p>"
  echo '<h3>完了Issue（Issueを直接CloseしたPR）</h3><table><thead><tr><th>PR</th><th>Issue</th><th>開始</th><th>終了</th><th>所要時間</th></tr></thead><tbody>'
  found_issue=false
  while IFS=$'\t' read -r pr_number pr_title pr_url pr_body pr_created pr_closed commits closing; do
    [[ -n "$pr_closed" && "$closing" != "[]" ]] || continue
    while IFS=$'\t' read -r issue_number issue_title; do
      issue="$(gh issue view "$issue_number" --repo "$REPOSITORY" --json number,title,body,url,assignees,closedAt 2>/dev/null)" || continue
      issue_closed="$(jq -r '.closedAt // empty' <<<"$issue")"; [[ -n "$issue_closed" ]] || continue
      first_commit="$(jq -r '[.[].committedDate // .[].authoredDate] | map(select(. != null)) | min // empty' <<<"$commits")"
      begin="$pr_created"; [[ -n "$first_commit" && "$first_commit" < "$begin" ]] && begin="$first_commit"
      assignees="$(jq -r '[.assignees[].login] | join(", ") // "未設定"' <<<"$issue")"
      printf '<tr><td><a href="%s">#%s %s</a><div class="markdown">%s</div></td>' "$pr_url" "$pr_number" "$(printf '%s' "$pr_title" | html_escape)" "$(markdown_html "$pr_body")"
      printf '<td><a href="%s">#%s %s</a><br>担当: %s<div class="markdown">%s</div></td>' "$(jq -r .url <<<"$issue")" "$issue_number" "$(jq -r .title <<<"$issue" | html_escape)" "$(printf '%s' "$assignees" | html_escape)" "$(markdown_html "$(jq -r .body <<<"$issue")")"
      printf '<td>%s</td><td>%s</td><td>%s</td></tr>\n' "$(format_time "$begin")" "$(format_time "$issue_closed")" "$(duration "$begin" "$issue_closed")"
      found_issue=true
    done < <(jq -r '.[] | [.number, .title] | @tsv' <<<"$closing" | tr -d '\r')
  done < <(jq -r '.[] | [.number,.title,.url,(.body // ""),.createdAt,(.closedAt // ""),((.commits // []) | tojson),((.closingIssuesReferences // []) | tojson)] | @tsv' "$TEMP_DIR/period-prs.json" | tr -d '\r')
  "$found_issue" || echo '<tr><td colspan="5">該当なし</td></tr>'
  echo '</tbody></table><h3>IssueをCloseしていない完了PR</h3><table><thead><tr><th>PR</th><th>説明</th><th>開始</th><th>終了</th><th>所要時間</th></tr></thead><tbody>'
  found_pr=false
  while IFS=$'\t' read -r number title url body created closed commits closing; do
    [[ -n "$closed" && "$closing" == "[]" ]] || continue
    first_commit="$(jq -r '[.[].committedDate // .[].authoredDate] | map(select(. != null)) | min // empty' <<<"$commits")"
    begin="$created"; [[ -n "$first_commit" && "$first_commit" < "$begin" ]] && begin="$first_commit"
    printf '<tr><td><a href="%s">#%s %s</a></td><td><div class="markdown">%s</div></td><td>%s</td><td>%s</td><td>%s</td></tr>\n' "$url" "$number" "$(printf '%s' "$title" | html_escape)" "$(markdown_html "$body")" "$(format_time "$begin")" "$(format_time "$closed")" "$(duration "$begin" "$closed")"
    found_pr=true
  done < <(jq -r '.[] | [.number,.title,.url,(.body // ""),.createdAt,(.closedAt // ""),((.commits // []) | tojson),((.closingIssuesReferences // []) | tojson)] | @tsv' "$TEMP_DIR/period-prs.json" | tr -d '\r')
  "$found_pr" || echo '<tr><td colspan="5">該当なし</td></tr>'
  echo '</tbody></table><h3>自分の未完了PR</h3><ul>'
  jq -r '.[] | select(.closedAt == null) | [.url,.number,.title,(.body // ""),.createdAt] | @tsv' "$TEMP_DIR/prs.json" | tr -d '\r' | while IFS=$'\t' read -r url number title body created; do printf '<li><a href="%s">#%s %s</a>（作成: %s）<div class="markdown">%s</div></li>\n' "$url" "$number" "$(printf '%s' "$title" | html_escape)" "$(format_time "$created")" "$(markdown_html "$body")"; done
  echo '</ul><h3>未完了Issue（作成者・担当者を問わず）</h3><ul>'
  jq -r '.[] | [.url,.number,.title,(.author.login // "不明"), (if ([.assignees[].login] | length) == 0 then "未設定" else [.assignees[].login] | join(", ") end),(.body // "（本文なし）"),.createdAt] | @tsv' "$TEMP_DIR/open-issues.json" | tr -d '\r' | while IFS=$'\t' read -r url number title author assignees body created; do printf '<li><a href="%s">#%s %s</a>（作成: %s、作成者: %s、担当: %s）<div class="markdown">%s</div></li>\n' "$url" "$number" "$(printf '%s' "$title" | html_escape)" "$(format_time "$created")" "$(printf '%s' "$author" | html_escape)" "$(printf '%s' "$assignees" | html_escape)" "$(markdown_html "$body")"; done
  echo "</ul><h3>期間内のコミット</h3><p>$(jq 'length' "$TEMP_DIR/commits.json")件</p><h3>期間内のGitHubコメント</h3><ul>"
  for comments in "$TEMP_DIR/period-issue-comments.json" "$TEMP_DIR/period-review-comments.json"; do jq -r '.[] | [.html_url,.created_at,(.body // "")] | @tsv' "$comments"; done | tr -d '\r' | while IFS=$'\t' read -r url created body; do printf '<li><a href="%s">%s</a><div class="markdown">%s</div></li>\n' "$url" "$(format_time "$created")" "$(markdown_html "$body")"; done
  echo '</ul></section></template>'
  echo '<!-- /WEEKLY-SUMMARY-ENTRY -->'
} > "$TEMP_DIR/new-entry.html"

cat > "$REPORT_FILE" <<EOF
<!doctype html>
<html lang="ja"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>週次開発一覧 @$LOGIN</title><style>body{font-family:system-ui,sans-serif;max-width:1200px;margin:2rem auto;padding:0 1rem}button{margin:.25rem;padding:.4rem .7rem}table{border-collapse:collapse;width:100%;margin:1rem 0}th,td{border:1px solid #bbb;padding:.5rem;vertical-align:top;text-align:left}.markdown{max-width:42rem}.markdown pre{white-space:pre-wrap;background:#f6f8fa;padding:.5rem}.markdown code{background:#f6f8fa}.selected{font-weight:bold}</style>
</head><body><h1>週次開発一覧: @$LOGIN</h1><p>記録日時を選ぶと、その時点で収集した情報を表示します。削除後は保存ダイアログでこのHTMLを同じ場所・名前で上書きしてください。次回実行時、その記録の開始時刻から再収集します。</p><div id="history"></div><main id="content"></main>
$(cat "$TEMP_DIR/old-entries.html")
$(cat "$TEMP_DIR/new-entry.html")
<script>
const entries=()=>[...document.querySelectorAll('template.weekly-entry')];
const historyElement=document.querySelector('#history'), contentElement=document.querySelector('#content');
function render(id){const t=entries().find(x=>x.dataset.id===id);if(!t)return;contentElement.replaceChildren(t.content.cloneNode(true));document.querySelectorAll('#history button[data-id]').forEach(b=>b.classList.toggle('selected',b.dataset.id===id));}
function escapeHtml(s){return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;').replace(/'/g,'&#39;')}
function inlineMarkdown(s){return escapeHtml(s).replace(/\`([^\`]+)\`/g,'<code>\$1</code>').replace(/\*\*([^*]+)\*\*/g,'<strong>\$1</strong>').replace(/\[([^\]]+)\]\((https?:[^ )]+)\)/g,'<a href="\$2">\$1</a>')}
function markdownToHtml(text){const lines=text.replace(/\\r\\n/g,'\n').replace(/\\n/g,'\n').split('\n');let out='',list='';const close=()=>{if(list){out+='</'+list+'>';list=''}};for(const line of lines){let m;if((m=line.match(/^(#{1,6})\s+(.+)$/))){close();out+='<h'+m[1].length+'>'+inlineMarkdown(m[2])+'</h'+m[1].length+'>'}else if((m=line.match(/^[-*]\s+(.+)$/))){if(list!=='ul'){close();list='ul';out+='<ul>'}out+='<li>'+inlineMarkdown(m[1])+'</li>'}else if((m=line.match(/^\d+\.\s+(.+)$/))){if(list!=='ol'){close();list='ol';out+='<ol>'}out+='<li>'+inlineMarkdown(m[1])+'</li>'}else if(!line.trim()){close()}else{close();out+='<p>'+inlineMarkdown(line)+'</p>'}}close();return out}
function renderMarkdown(){document.querySelectorAll('.markdown-source').forEach(source=>{const rendered=document.createElement('div');rendered.className='markdown-rendered';rendered.innerHTML=markdownToHtml(source.textContent);source.replaceWith(rendered)})}
function redraw(){historyElement.replaceChildren();entries().forEach(t=>{const b=document.createElement('button');b.dataset.id=t.dataset.id;b.textContent=t.dataset.end.replace('T',' ').replace('Z',' UTC');b.onclick=()=>{render(t.dataset.id);renderMarkdown()};historyElement.append(b)});const d=document.createElement('button');d.textContent='表示中の記録を削除して保存';d.onclick=removeCurrent;historyElement.append(d);if(entries().length){render(entries().at(-1).dataset.id);renderMarkdown()}}
async function removeCurrent(){const b=document.querySelector('#history .selected');if(!b)return;const t=entries().find(x=>x.dataset.id===b.dataset.id);if(!confirm('この記録を削除しますか？'))return;const old=document.querySelector('meta[name="weekly-summary-recollect-from"]');const floor=[old?.content,t.dataset.start].filter(Boolean).sort()[0];old?.remove();const m=document.createElement('meta');m.name='weekly-summary-recollect-from';m.content=floor;document.head.append(m);t.previousSibling?.remove();t.nextSibling?.remove();t.remove();try{const h=await window.showSaveFilePicker({suggestedName:location.pathname.split('/').pop()||'weekly-summary.html',types:[{description:'HTML',accept:{'text/html':['.html']}}]});const w=await h.createWritable();await w.write('<!doctype html>\n'+document.documentElement.outerHTML);await w.close();alert('削除後のHTMLを保存しました。');location.reload()}catch(e){alert('保存されていません。同じファイル名で保存ダイアログを完了してください。')}redraw()}
redraw();
</script></body></html>
EOF
echo "作成しました: $REPORT_FILE"
echo "対象期間: $START から $NOW"
