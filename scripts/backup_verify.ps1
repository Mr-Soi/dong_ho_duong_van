$last = Get-ChildItem F:\dhdv_stack_v_2.9\backup\dhdv_*.bak | Sort-Object LastWriteTime -Desc | Select-Object -First 1
if (-not $last) { exit 2 } else { Write-Output "LATEST=$(.Name) TIME=$(.LastWriteTime.ToString('s'))" }
