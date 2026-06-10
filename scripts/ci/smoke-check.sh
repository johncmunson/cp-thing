#!/usr/bin/env bash
set -euo pipefail

: "${DEPLOYMENT_URL:?DEPLOYMENT_URL is required}"

tmp_body="$(mktemp)"
trap 'rm -f "$tmp_body"' EXIT

curl_args=(
  --silent
  --show-error
  --location
  --retry 3
  --retry-delay 5
  --retry-connrefused
  --connect-timeout 10
  --max-time 30
  --output "$tmp_body"
  --write-out "%{http_code}"
)

if [ -n "${VERCEL_AUTOMATION_BYPASS_SECRET:-}" ]; then
  curl_args+=(--header "x-vercel-protection-bypass: ${VERCEL_AUTOMATION_BYPASS_SECRET}")
fi

set +e
status="$(curl "${curl_args[@]}" "$DEPLOYMENT_URL")"
curl_exit=$?
set -e

if [ "$curl_exit" -ne 0 ]; then
  echo "Smoke check failed: curl exited with $curl_exit after HTTP ${status:-000}." >&2
  tail -c 2000 "$tmp_body" >&2 || true
  exit "$curl_exit"
fi

case "$status" in
  2*|3*)
    echo "Smoke check passed with HTTP $status."
    ;;
  401|403)
    if [ -z "${VERCEL_AUTOMATION_BYPASS_SECRET:-}" ]; then
      echo "::warning::Smoke check returned HTTP $status. The deployment is likely protected. Add a GitHub secret named VERCEL_AUTOMATION_BYPASS_SECRET to make this check authenticated."
      exit 0
    fi

    echo "Smoke check returned HTTP $status even with Vercel automation bypass configured." >&2
    tail -c 2000 "$tmp_body" >&2 || true
    exit 1
    ;;
  *)
    echo "Smoke check failed with HTTP ${status:-000}." >&2
    tail -c 2000 "$tmp_body" >&2 || true
    exit 1
    ;;
esac
