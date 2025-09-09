# DHDV production quick deploy (Cloudflare + Caddy)

1) Put these files in your project root (same folder as `publish/`):
   - `docker-compose.prod.yml`
   - `Caddyfile`
   - `deploy.ps1`
   - create `.env.prod` from `.env.prod.example` and fill secrets.

2) In Cloudflare set SSL/TLS mode to **Full** (not Strict/Flexible). Keep DNS "orange cloud" proxied.

3) Deploy:
   - Open PowerShell in the folder and run:
     `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force`
     `.\deploy.ps1 -Import`   # only the first time (loads data)
     `.\deploy.ps1`           # start/refresh web + caddy

4) Check logs if needed:
   `docker compose -f docker-compose.prod.yml logs -f caddy web`
