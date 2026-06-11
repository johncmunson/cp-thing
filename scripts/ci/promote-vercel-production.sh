#!/usr/bin/env bash
set -euo pipefail

: "${DEPLOYMENT_URL:?DEPLOYMENT_URL is required}"
: "${VERCEL_ORG_ID:?VERCEL_ORG_ID is required}"

pnpm exec vercel promote "$DEPLOYMENT_URL" --yes --scope "$VERCEL_ORG_ID"

{
  echo "### Production promotion"
  echo "- Promoted: $DEPLOYMENT_URL"
} >> "$GITHUB_STEP_SUMMARY"
