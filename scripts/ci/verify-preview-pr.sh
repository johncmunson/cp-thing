#!/usr/bin/env bash
set -euo pipefail

pr_number=""

write_outputs() {
  {
    echo "number=${pr_number:-}"
    echo "should_deploy=$1"
  } >> "$GITHUB_OUTPUT"
}

skip_preview() {
  local reason="$1"
  write_outputs false
  echo "::notice::$reason"
  {
    echo "### Preview deployment skipped"
    echo "- Reason: $reason"
    echo "- Git branch: $GIT_BRANCH"
    echo "- Workflow SHA: $HEAD_SHA"
    if [ -n "${pr_number:-}" ]; then
      echo "- Pull request: #$pr_number"
    fi
  } >> "$GITHUB_STEP_SUMMARY"
}

if [ -n "$EVENT_PR_NUMBER" ]; then
  pr_json="$(gh pr view "$EVENT_PR_NUMBER" --repo "$GITHUB_REPOSITORY" --json number,state,headRefName,headRefOid,isCrossRepository)"
else
  pr_json="$(gh pr list --repo "$GITHUB_REPOSITORY" --head "$GIT_BRANCH" --state open --json number,state,headRefName,headRefOid,isCrossRepository --jq '.[0] // empty')"
fi

if [ -z "$pr_json" ] || [ "$pr_json" = "null" ]; then
  skip_preview "No open pull request was found for $GIT_BRANCH."
  exit 0
fi

pr_number="$(printf '%s\n' "$pr_json" | jq -r '.number // empty')"
pr_state="$(printf '%s\n' "$pr_json" | jq -r '.state // empty')"
pr_head_ref="$(printf '%s\n' "$pr_json" | jq -r '.headRefName // empty')"
pr_head_sha="$(printf '%s\n' "$pr_json" | jq -r '.headRefOid // empty')"
is_cross_repo="$(printf '%s\n' "$pr_json" | jq -r '.isCrossRepository // false')"

if [ "$pr_state" != "OPEN" ]; then
  skip_preview "Pull request #$pr_number is no longer open."
  exit 0
fi

if [ "$is_cross_repo" = "true" ]; then
  skip_preview "Pull request #$pr_number is from a fork."
  exit 0
fi

if [ "$pr_head_ref" != "$GIT_BRANCH" ]; then
  skip_preview "Pull request #$pr_number now points at $pr_head_ref, not $GIT_BRANCH."
  exit 0
fi

if [ "$pr_head_sha" != "$HEAD_SHA" ]; then
  skip_preview "Pull request #$pr_number moved from $HEAD_SHA to $pr_head_sha."
  exit 0
fi

write_outputs true
echo "Pull request #$pr_number is open and still points at $HEAD_SHA."
