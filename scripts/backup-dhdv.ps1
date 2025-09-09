param(
  [string]$SqlContainer="dhdv_stack_v1-sql-1",
  [string[]]$Databases=@("dhdv","don7069c_dongho"),
  [string]$OutDir="D:\backups\dhdv",
  [int]$KeepDays=14
)
$env:SA_PASSWORD = $env:SA_PASSWORD -as [string]
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$stamp=(Get-Date -Format "yyyyMMdd_HHmm")
foreach($db in $Databases){
  $bak="${db}_$stamp.bak"
  docker exec -i $SqlContainer /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$env:SA_PASSWORD" -C -Q "BACKUP DATABASE [$db] TO DISK=N'/var/opt/mssql/backup/$bak' WITH INIT, COMPRESSION, CHECKSUM;"
  docker cp "$SqlContainer:/var/opt/mssql/backup/$bak" "$OutDir\$bak"
}
Get-ChildItem $OutDir -Filter *.bak | ? { $_.LastWriteTime -lt (Get-Date).AddDays(-$KeepDays) } | Remove-Item -Force
