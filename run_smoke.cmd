@echo off
setlocal
set "BASE=%~dp0"
set "LOGDIR=%BASE%logs"
if not exist "%LOGDIR%" mkdir "%LOGDIR%"
for /f "usebackq tokens=1 delims=" %%t in (`powershell -NoProfile -Command "(Get-Date -Format yyyyMMdd_HHmmss)"`) do set "TS=%%t"
powershell -NoProfile -ExecutionPolicy Bypass -File "%BASE%smoke.ps1" *>> "%LOGDIR%\smoke_%TS%.log" 2>>&1
copy /Y "%LOGDIR%\smoke_%TS%.log" "%LOGDIR%\smoke_latest.log" >NUL
