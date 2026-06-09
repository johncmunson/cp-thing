const environment = process.env.VERCEL_ENV ?? process.env.NODE_ENV ?? "local"

console.log(`[db:migrate] No database configured yet; skipping migrations for ${environment}.`)
