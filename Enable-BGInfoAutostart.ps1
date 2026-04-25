# 1. Resolve BGInfo and config paths from environment
$exePath = Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Links\bginfo.exe'
$configPath = Join-Path $env:USERPROFILE '.bginfo\config.bgi'

if (-not (Test-Path $exePath)) {
    throw "BGInfo executable not found at: $exePath"
}

if (-not (Test-Path $configPath)) {
    throw "BGInfo config not found at: $configPath"
}

# 2. Build BGInfo arguments
$myArgs = ('"{0}" /timer:0 /silent /nolicprompt' -f $configPath)

# 3. Create action
$action = New-ScheduledTaskAction -Execute $exePath -Argument $myArgs

# 4. Create the Trigger
$trigger = New-ScheduledTaskTrigger -AtLogOn

# 5. Create settings
$settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Minutes 1)

# 6. Register task
Register-ScheduledTask -TaskName "BGInfo" -Action $action -Trigger $trigger -Settings $settings -RunLevel Limited -Force
