param(
  [Parameter(Mandatory=$true)] [string]$BakPath,        # F:\dhdv_stack_v_2.9\backup\dhdv_YYYYMMDD_HHMMSS.bak
  [string]$SqlContainer = "dhdv_sql",
  [string]$WebContainer = "dhdv_web",
  [string]$SaPassword  = "S@f3Pass_2025!",
  [string]$CompatSql   = "db\compat\compat_all.sql"
)

$ErrorActionPreference = "Stop"

# 1) Copy .bak vào container & RESTORE
$contBak = "/var/opt/mssql/backup/restore_in.bak"
docker cp $BakPath "$SqlContainer`:$contBak"
docker exec $SqlContainer /opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P $SaPassword -C -Q @"
ALTER DATABASE [dhdv] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
RESTORE DATABASE [dhdv] FROM DISK=N'$contBak' WITH REPLACE;
ALTER DATABASE [dhdv] SET MULTI_USER;
"@

# 2) Chạy compat_all.sql
docker cp $CompatSql "$SqlContainer`:/tmp/compat_all.sql"
docker exec $SqlContainer /opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P $SaPassword -d dhdv -C -i "/tmp/compat_all.sql"

# 3) Reload web
docker compose -f docker-compose.prod.yml up -d --build web

# 3.1) Wait /ready = 200
$ok = $false
for ($i=0; $i -lt 30; $i++) {
  try {
    $r = Invoke-WebRequest -Uri "http://127.0.0.1:8080/ready" -Method Get -UseBasicParsing -TimeoutSec 5 -Proxy $null
    if ($r.StatusCode -eq 200) { $ok = $true; break }
  } catch { }
  Start-Sleep -Seconds 2
}
if (-not $ok) { Write-Warning "Web not ready after wait - continuing anyway" }

# 4) Smoke (origin)
$urls = @(
  "http://127.0.0.1:8080/People",
  "http://127.0.0.1:8080/Albums",
  "http://127.0.0.1:8080/Posts"
)
$codes = foreach ($u in $urls) {
  & curl.exe -s -o NUL -H "Accept-Encoding: identity" -w "%{http_code}" $u
}
Write-Host "Origin People/Albums/Posts => $($codes -join ', ')"

# 5) Smoke (domain) — probe từng URL, không fail toàn bài
$domainUrls = @(
  "https://donghoduongvan.com/People",
  "https://donghoduongvan.com/Albums",
  "https://donghoduongvan.com/Posts"
)
$h = foreach ($u in $domainUrls) { & curl.exe -s -I -o NUL -w "%{http_code}" $u }
Write-Host "Domain People/Albums/Posts => $($h -join ', ')"
