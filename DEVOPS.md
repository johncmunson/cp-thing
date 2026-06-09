# DevOps / CI/CD Status

This document summarizes the current state of the app's DevOps and CI/CD setup.

## Current Deployment Flow

- Vercel is connected to the GitHub repository.
- Pushing a non-`main` branch creates a Vercel Preview Deployment.
- Merging to `main` triggers a Vercel Production Deployment.
- Vercel remains the source of truth for deployments; GitHub Actions is currently used for validation, not deployment.

## Current CI Setup

A GitHub Actions workflow exists at:

```txt
.github/workflows/ci.yml
```

The workflow runs on pull requests and updates to pull requests.

- Pull requests
- Pushes to `main`

It uses:

- Node.js `24`
- pnpm `10.28.0`
- Frozen lockfile installs via `pnpm install --frozen-lockfile`

The CI workflow currently defines these jobs:

- `lint` — runs `pnpm lint`
- `typecheck` — runs `pnpm typecheck`
- `test` — runs `pnpm test`
- `build` — runs `pnpm build`

The `test` job also installs Chromium for Playwright/Vitest browser tests and caches Playwright's browser download directory to avoid re-downloading Chromium on every run.
