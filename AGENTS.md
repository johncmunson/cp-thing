<!-- BEGIN:nextjs-agent-rules -->

# This is NOT the Next.js you know

This version has breaking changes — APIs, conventions, and file structure may all differ from your training data. Read the relevant guide in `node_modules/next/dist/docs/` before writing any code. Heed deprecation notices.

<!-- END:nextjs-agent-rules -->

- Always prefer `pnpm` and/or `pnpx` over any other package manager such as `npm` or `yarn`
- Test logic, services, hooks, etc. Avoid writing pedantic frontend tests such as "the button is blue".
- Production migrations run before the new Vercel deployment is promoted, so keep them backward-compatible with the currently live app (expand/contract; do not drop or rename in the same deploy).
- Don't forget: deleting code is a virtue
