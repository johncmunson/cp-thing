#!/usr/bin/env bash
set -euo pipefail

: "${VERCEL_ORG_ID:?VERCEL_ORG_ID is required}"

if ! deployment_output="$(pnpm exec vercel deploy --prebuilt --prod --skip-domain --yes --no-wait --format=json --scope "$VERCEL_ORG_ID")"; then
  printf '%s\n' "$deployment_output"
  exit 1
fi

if ! deployment_url="$(printf '%s\n' "$deployment_output" | jq -r '.url // .deployment.url // empty')"; then
  printf '%s\n' "$deployment_output"
  echo "Unable to parse deployment JSON output." >&2
  exit 1
fi

if [ -z "$deployment_url" ]; then
  printf '%s\n' "$deployment_output"
  echo "Unable to determine deployment URL." >&2
  exit 1
fi

echo "url=$deployment_url" >> "$GITHUB_OUTPUT"
{
  echo "### Production deployment"
  echo "- URL: $deployment_url"
  echo "- Commit: $COMMIT_SHA"
  echo "- Promotion: pending smoke check"
} >> "$GITHUB_STEP_SUMMARY"
