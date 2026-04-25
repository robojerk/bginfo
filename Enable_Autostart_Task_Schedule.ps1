# 1. Path to the EXE
$exePath = 'C:\Users\rob\AppData\Local\Microsoft\WinGet\Links\bginfo.exe'

# 2. Use a custom name like $myArgs instead of $args
$myArgs = '"C:\Users\rob\.bginfo\config.bgi" /timer:0 /silent /nolicprompt'

# 3. Create the Action (This will work now)
$action = New-ScheduledTaskAction -Execute $exePath -Argument $myArgs

# 4. Create the Trigger
$trigger = New-ScheduledTaskTrigger -AtLogOn

# 5. Create Settings
$settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Minutes 1)

# 6. Register the Task
Register-ScheduledTask -TaskName "BGInfo" -Action $action -Trigger $trigger -Settings $settings -RunLevel Limited -Force