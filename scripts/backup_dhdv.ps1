$ts=(Get-Date -Format yyyyMMdd_HHmm);
docker exec dhdv_sql /opt/mssql-tools18/bin/sqlcmd -C -S localhost -d master -U sa -P 'S@f3Pass_2025!' -Q "BACKUP DATABASE [dhdv] TO DISK=N'/var/opt/mssql/backup/dhdv_$ts.bak' WITH INIT";
docker cp dhdv_sql:/var/opt/mssql/backup/dhdv_$ts.bak F:\dhdv_stack_v_2.9\backup\
Get-ChildItem F:\dhdv_stack_v_2.9\backup\dhdv_*.bak | ? LastWriteTime -lt (Get-Date).AddDays(-14) | Remove-Item -Force
