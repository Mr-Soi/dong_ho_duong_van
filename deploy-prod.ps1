param([switch]$RunImport=$false,[string]$ComposeFile="docker-compose.prod.yml",[string]$EnvFile=".env.prod")
Write-Host "==> Build images" -ForegroundColor Cyan
docker buildx bake
Write-Host "==> Up stack (prod)" -ForegroundColor Cyan
docker compose -f $ComposeFile --env-file $EnvFile up -d
if ($RunImport) { Write-Host "==> Run one-off import job" -ForegroundColor Cyan; docker compose -f $ComposeFile --env-file $EnvFile run --rm import }
$dom=(Get-Content $EnvFile | Select-String -Pattern '^CADDY_DOMAIN=').ToString().Split('=')[-1]
Write-Host ("Done. Check https://{0}" -f $dom) -ForegroundColor Green
