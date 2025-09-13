# smoke.ps1
$ROOT   = $PSScriptRoot; if (-not $ROOT) { $ROOT = (Get-Location).Path }
$LOGDIR = Join-Path $ROOT 'logs'
$LOG    = Join-Path $LOGDIR 'smoke_latest.log'

New-Item -ItemType Directory -Force -Path $LOGDIR | Out-Null
Remove-Item $LOG -ErrorAction SilentlyContinue

$urls = @(
  "https://donghoduongvan.com/Home/Intro",
  "https://donghoduongvan.com/Home/Charter",
  "https://donghoduongvan.com/Home/Contact",
  "http://127.0.0.1:8080/ping"
)

foreach ($u in $urls) {
  try   { $code = (Invoke-WebRequest -Uri $u -Method Get -TimeoutSec 10 -UseBasicParsing).StatusCode }
  catch { $code = $_.Exception.Response.StatusCode.value__; if (-not $code) { $code = 000 } }
  "$code $u" | Tee-Object -FilePath $LOG -Append
}
