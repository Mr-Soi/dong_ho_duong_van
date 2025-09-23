# deploy & backup
docker compose up -d --build web
if ($LASTEXITCODE -eq 0) {
  $ts=(Get-Date -Format yyyyMMdd_HHmm);
  docker exec dhdv_sql /opt/mssql-tools18/bin/sqlcmd -C -S localhost -d master -U dhdv_app -P 'S@f3App_2025!' -Q "BACKUP DATABASE [dhdv] TO DISK=N'/var/opt/mssql/backup/dhdv_$ts.bak' WITH INIT"
  docker cp dhdv_sql:/var/opt/mssql/backup/dhdv_$ts.bak F:\dhdv_stack_v_2.9\backup\
  Write-Output ""Deployed & Snapshotted: dhdv_$ts.bak""
} else { exit 1 }
