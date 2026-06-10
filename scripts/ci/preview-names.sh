#!/usr/bin/env bash
set -euo pipefail

# Computes stable resource names for a PR preview branch.
#
# Usage:
#   scripts/ci/preview-names.sh [git_branch] [head_sha]
#
# In GitHub Actions this can also infer the branch/SHA from the event-specific
# environment variables set by the deploy-preview and cleanup-preview workflows.

git_branch="${1:-${GIT_BRANCH:-}}"
head_sha="${2:-${HEAD_SHA:-}}"

if [ -z "$git_branch" ]; then
  case "${GITHUB_EVENT_NAME:-}" in
    delete)
      if [ "${DELETE_REF_TYPE:-}" != "branch" ]; then
        echo "Not a branch delete event; skipping."
        exit 0
      fi
      git_branch="${DELETE_REF:-}"
      ;;
    pull_request)
      git_branch="${PR_HEAD_REF:-}"
      head_sha="${PR_HEAD_SHA:-$head_sha}"
      ;;
    workflow_dispatch)
      git_branch="${DISPATCH_REF:-}"
      ;;
    workflow_run)
      git_branch="${PR_HEAD_BRANCH:-${WORKFLOW_HEAD_BRANCH:-}}"
      head_sha="${PR_HEAD_SHA:-${WORKFLOW_HEAD_SHA:-$head_sha}}"
      ;;
  esac
fi

if [ -z "$git_branch" ]; then
  echo "Unable to determine preview git branch." >&2
  exit 1
fi

if [ "${GITHUB_EVENT_NAME:-}" = "workflow_run" ] && [ -z "$head_sha" ]; then
  echo "Unable to determine preview head SHA from CI workflow_run payload." >&2
  exit 1
fi

branch_slug="$(printf '%s' "$git_branch" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//; s/-+/-/g' | cut -c1-48)"
if [ -z "$branch_slug" ]; then
  branch_slug="branch"
fi

branch_hash="$(printf '%s' "$git_branch" | sha1sum | cut -c1-8)"
neon_branch="preview/${branch_slug}-${branch_hash}"
emit_outputs() {
  echo "git_branch=$git_branch"
  echo "branch_slug=$branch_slug"
  echo "neon_branch=$neon_branch"

  if [ -n "$head_sha" ]; then
    echo "head_sha=$head_sha"
    echo "sha_short=${head_sha:0:7}"
  fi
}

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  emit_outputs >> "$GITHUB_OUTPUT"
else
  emit_outputs
fi
