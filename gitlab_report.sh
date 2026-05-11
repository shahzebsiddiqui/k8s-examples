#!/bin/bash

#BASE_URL="https://gitlab-fsl.jsc.nasa.gov/api/v4/users/1695/events"
TOKEN="${GITLAB_TOKEN}"

# Last 90 days (portable fallback for macOS/Linux)
if date -u -d "90 days ago" >/dev/null 2>&1; then
  AFTER=$(date -u -d "90 days ago" +%Y-%m-%d)
else
  AFTER=$(date -u -v-90d +%Y-%m-%d)
fi

page=1
all_events="[]"

echo "Fetching GitLab activity since $AFTER ..."

while true; do
  response=$(curl -s --header "PRIVATE-TOKEN: $TOKEN" \
    "$BASE_URL?after=$AFTER&per_page=100&page=$page")

  count=$(echo "$response" | jq 'length')

  if [ "$count" -eq 0 ]; then
    break
  fi

  all_events=$(jq -s 'add' <(echo "$all_events") <(echo "$response"))

  ((page++))
done

echo ""
echo "📅 GitLab Activity Timeline (last 90 days)"
echo "----------------------------------------"

echo "$all_events" | jq -r '
  sort_by(.created_at) | reverse |
  .[] |
  "\(.created_at) | \(.action_name) | \(.target_type // "N/A") | \(.project_id) | \(.target_title // .push_data.commit_title // "No title")"
'
