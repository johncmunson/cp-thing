#!/usr/bin/env bash
set -euo pipefail

: "${VERCEL_ORG_ID:?VERCEL_ORG_ID is required}"

deployment_ids_file="$(mktemp)"
next_args=()

while :; do
  response="$(pnpm exec vercel list \
    --yes \
    --environment=preview \
    --meta "githubCommitRef=$GIT_BRANCH" \
    --format=json \
    --scope "$VERCEL_ORG_ID" \
    "${next_args[@]}")"

  printf '%s\n' "$response" | jq -r '.deployments[]?.id' >> "$deployment_ids_file"

  next_page="$(printf '%s\n' "$response" | jq -r '.pagination.next // empty')"
  if [ -z "$next_page" ]; then
    break
  fi

  next_args=(--next "$next_page")
done

sort -u "$deployment_ids_file" -o "$deployment_ids_file"
deployment_count="$(wc -l < "$deployment_ids_file" | tr -d ' ')"

if [ "$deployment_count" = "0" ]; then
  echo "No Vercel preview deployments found for branch $GIT_BRANCH."
  echo "removed_count=0" >> "$GITHUB_OUTPUT"
  echo "failed_count=0" >> "$GITHUB_OUTPUT"
  exit 0
fi

failed_count=0
while IFS= read -r deployment_id; do
  if [ -z "$deployment_id" ]; then
    continue
  fi

  echo "Removing Vercel preview deployment $deployment_id"
  if ! pnpm exec vercel remove "$deployment_id" --yes --scope "$VERCEL_ORG_ID"; then
    echo "::warning::Failed to remove Vercel preview deployment $deployment_id"
    failed_count=$((failed_count + 1))
  fi
done < "$deployment_ids_file"

removed_count=$((deployment_count - failed_count))
echo "removed_count=$removed_count" >> "$GITHUB_OUTPUT"
echo "failed_count=$failed_count" >> "$GITHUB_OUTPUT"
