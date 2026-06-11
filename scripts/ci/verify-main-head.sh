#!/usr/bin/env bash
set -euo pipefail

current_sha="$(gh api "repos/${GITHUB_REPOSITORY}/git/ref/heads/main" --jq '.object.sha')"

if [ "$current_sha" = "$EXPECTED_SHA" ]; then
  echo "should_deploy=true" >> "$GITHUB_OUTPUT"
  echo "Main still points at $EXPECTED_SHA; continuing."
else
  echo "should_deploy=false" >> "$GITHUB_OUTPUT"
  echo "::notice::Skipping production deploy because main moved from $EXPECTED_SHA to $current_sha."
  {
    echo "### Production deployment skipped"
    echo "- Reason: CI completed for a commit that is no longer the tip of main."
    echo "- Workflow SHA: $EXPECTED_SHA"
    echo "- Current main SHA: $current_sha"
  } >> "$GITHUB_STEP_SUMMARY"
fi
