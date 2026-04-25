[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param(
    [switch]$Uninstall,
    [switch]$RemoveInstallDir
)

$ErrorActionPreference = 'Stop'
$script:HasShouldProcess = $null -ne $PSCmdlet

function Invoke-SafeShouldProcess {
    param(
        [string]$Target,
        [string]$Action
    )

    if ($script:HasShouldProcess) {
        return $PSCmdlet.ShouldProcess($Target, $Action)
    }

    return $true
}

function Get-BGInfoPath {
    $cmd = Get-Command bginfo.exe -ErrorAction SilentlyContinue
    if ($cmd -and $cmd.Source -and (Test-Path $cmd.Source)) {
        return $cmd.Source
    }

    $cmd64 = Get-Command bginfo64.exe -ErrorAction SilentlyContinue
    if ($cmd64 -and $cmd64.Source -and (Test-Path $cmd64.Source)) {
        return $cmd64.Source
    }

    $candidates = @(
        (Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Links\bginfo.exe'),
        (Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Links\bginfo64.exe'),
        (Join-Path $env:ProgramData 'chocolatey\bin\bginfo.exe'),
        (Join-Path $env:ProgramData 'chocolatey\bin\bginfo64.exe'),
        (Join-Path $env:ProgramFiles 'BGInfo\Bginfo64.exe'),
        (Join-Path $env:ProgramFiles 'BGInfo\Bginfo.exe'),
        (Join-Path $env:ProgramFiles 'Sysinternals\Bginfo64.exe'),
        (Join-Path $env:ProgramFiles 'Sysinternals\Bginfo.exe'),
        (Join-Path ${env:ProgramFiles(x86)} 'BGInfo\Bginfo64.exe'),
        (Join-Path ${env:ProgramFiles(x86)} 'BGInfo\Bginfo.exe'),
        (Join-Path ${env:ProgramFiles(x86)} 'Sysinternals\Bginfo64.exe'),
        (Join-Path ${env:ProgramFiles(x86)} 'Sysinternals\Bginfo.exe')
    )

    foreach ($candidate in $candidates) {
        if ($candidate -and (Test-Path $candidate)) {
            return $candidate
        }
    }

    return $null
}

function Install-BGInfoWithWinget {
    $winget = Get-Command winget.exe -ErrorAction SilentlyContinue
    if (-not $winget) {
        throw 'BGInfo was not detected and winget is not available. Install BGInfo manually and rerun install.ps1.'
    }

    Write-Host 'BGInfo not detected. Installing via winget (Microsoft.Sysinternals.BGInfo)...'
    & $winget.Source install --id Microsoft.Sysinternals.BGInfo --exact --accept-package-agreements --accept-source-agreements

    if ($LASTEXITCODE -ne 0) {
        throw "winget install failed with exit code $LASTEXITCODE."
    }
}

function Test-InstallState {
    param(
        [string]$InstallDir,
        [string]$TaskName,
        [string]$ShortcutPath
    )

    $requiredFiles = @(
        'cpuname.vbs',
        'gpu.vbs',
        'igpu.vbs',
        'hdinfo.vbs',
        'ipaddr.vbs',
        'mac.vbs',
        'networkspeed.vbs',
        'osversion.vbs',
        'ram.vbs',
        'sshstatus.vbs',
        'Validate-Scripts.ps1',
        'README.md',
        'steam_gear.jpg'
    )

    $missing = @()
    foreach ($name in $requiredFiles) {
        $path = Join-Path $InstallDir $name
        if (-not (Test-Path $path)) {
            $missing += $name
        }
    }

    $task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    $shortcutExists = Test-Path $ShortcutPath

    Write-Host ''
    Write-Host 'Post-install verification:'
    Write-Host ("- Install directory: {0}" -f $(if (Test-Path $InstallDir) { 'OK' } else { 'Missing' }))
    Write-Host ("- Scheduled task: {0}" -f $(if ($task) { 'OK' } else { 'Missing' }))
    Write-Host ("- Start Menu shortcut: {0}" -f $(if ($shortcutExists) { 'OK' } else { 'Missing' }))

    if ($missing.Count -gt 0) {
        Write-Warning ("Missing copied files: {0}" -f ($missing -join ', '))
    } else {
        Write-Host '- Copied files: OK'
    }
}

function Resolve-ProjectRoot {
    $localRoot = $null

    if ($PSScriptRoot) {
        $localRoot = $PSScriptRoot
    } elseif ($MyInvocation.MyCommand.Path) {
        $localRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
    }

    if ($localRoot -and (Test-Path $localRoot)) {
        return $localRoot
    }

    $repoRawBase = 'https://raw.githubusercontent.com/robojerk/bginfo/main'
    $stagingRoot = Join-Path $env:TEMP ('bginfo-install-' + [Guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $stagingRoot -Force | Out-Null

    Write-Host 'Running from memory. Downloading project files from GitHub...'

    $requiredFiles = @(
        'cpuname.vbs',
        'gpu.vbs',
        'igpu.vbs',
        'hdinfo.vbs',
        'ipaddr.vbs',
        'mac.vbs',
        'networkspeed.vbs',
        'osversion.vbs',
        'ram.vbs',
        'sshstatus.vbs',
        'Validate-Scripts.ps1',
        'README.md',
        'steam_gear.jpg'
    )

    foreach ($name in $requiredFiles) {
        $url = "$repoRawBase/$name"
        $destination = Join-Path $stagingRoot $name
        Invoke-WebRequest -Uri $url -OutFile $destination
    }

    $configUrl = "$repoRawBase/config.bgi"
    $configDestination = Join-Path $stagingRoot 'config.bgi'
    try {
        Invoke-WebRequest -Uri $configUrl -OutFile $configDestination -ErrorAction Stop
    } catch {
        # Optional file, ignore if not found.
    }

    return $stagingRoot
}

$installDir = Join-Path $env:USERPROFILE '.bginfo'
$taskName = 'BGInfo'
$configPath = Join-Path $installDir 'config.bgi'
$shortcutDir = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\BGInfo'
$shortcutPath = Join-Path $shortcutDir 'Run BGInfo.lnk'

if ($Uninstall) {
    Write-Host 'Running uninstall mode...'

    if (Invoke-SafeShouldProcess -Target $taskName -Action 'Unregister scheduled task') {
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue
    }

    if (Invoke-SafeShouldProcess -Target $shortcutPath -Action 'Remove Start Menu shortcut') {
        Remove-Item -Path $shortcutPath -Force -ErrorAction SilentlyContinue
    }

    if (Invoke-SafeShouldProcess -Target $shortcutDir -Action 'Remove empty BGInfo Start Menu folder') {
        if (Test-Path $shortcutDir) {
            $remaining = Get-ChildItem -Path $shortcutDir -Force -ErrorAction SilentlyContinue
            if (-not $remaining) {
                Remove-Item -Path $shortcutDir -Force -ErrorAction SilentlyContinue
            }
        }
    }

    if ($RemoveInstallDir -and (Invoke-SafeShouldProcess -Target $installDir -Action 'Remove install directory')) {
        Remove-Item -Path $installDir -Recurse -Force -ErrorAction SilentlyContinue
    }

    Write-Host 'Uninstall complete.'
    return
}

$projectRoot = Resolve-ProjectRoot

Write-Host "Installing BGInfo assets to: $installDir"
if (Invoke-SafeShouldProcess -Target $installDir -Action 'Create install directory') {
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null
}

# Copy all VBS scripts used by BGInfo.
Get-ChildItem -Path $projectRoot -Filter '*.vbs' | ForEach-Object {
    $destination = Join-Path $installDir $_.Name
    if (Invoke-SafeShouldProcess -Target $destination -Action "Copy $($_.Name)") {
        Copy-Item -Path $_.FullName -Destination $destination -Force
    }
}

# Copy helper docs/scripts/assets for easier maintenance on target machine.
foreach ($extra in @('README.md', 'Validate-Scripts.ps1', 'steam_gear.jpg')) {
    $source = Join-Path $projectRoot $extra
    if (Test-Path $source) {
        $destination = Join-Path $installDir $extra
        if (Invoke-SafeShouldProcess -Target $destination -Action "Copy $extra") {
            Copy-Item -Path $source -Destination $destination -Force
        }
    }
}

# Optional BGInfo layout file.
$sourceConfig = Join-Path $projectRoot 'config.bgi'
if (Test-Path $sourceConfig) {
    if (Invoke-SafeShouldProcess -Target $configPath -Action 'Copy config.bgi') {
        Copy-Item -Path $sourceConfig -Destination $configPath -Force
        Write-Host "Copied config.bgi"
    }
} else {
    Write-Warning "config.bgi not found in project root. Task/shortcut will run BGInfo without a custom layout."
}

$bginfoPath = Get-BGInfoPath
if (-not $bginfoPath) {
    Install-BGInfoWithWinget
    $bginfoPath = Get-BGInfoPath
}

if (-not $bginfoPath) {
    throw 'BGInfo installation completed but executable path could not be detected. Verify BGInfo install and rerun install.ps1.'
}

if (Test-Path $configPath) {
    $bginfoArgs = ('"{0}" /timer:0 /silent /nolicprompt' -f $configPath)
} else {
    $bginfoArgs = '/timer:0 /silent /nolicprompt'
}

Write-Host "Using BGInfo executable: $bginfoPath"

# Register or update the logon scheduled task.
$action = New-ScheduledTaskAction -Execute $bginfoPath -Argument $bginfoArgs
$trigger = New-ScheduledTaskTrigger -AtLogOn
$settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Minutes 1)

if (Invoke-SafeShouldProcess -Target $taskName -Action 'Register scheduled task') {
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -RunLevel Limited -Force | Out-Null
    Write-Host "Scheduled task '$taskName' is registered."
}

# Create Start Menu shortcut for manual execution.
if (Invoke-SafeShouldProcess -Target $shortcutDir -Action 'Create Start Menu folder') {
    New-Item -ItemType Directory -Path $shortcutDir -Force | Out-Null
}

if (Invoke-SafeShouldProcess -Target $shortcutPath -Action 'Create Start Menu shortcut') {
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $bginfoPath
    $shortcut.Arguments = $bginfoArgs
    $shortcut.WorkingDirectory = $installDir
    $shortcut.IconLocation = $bginfoPath
    $shortcut.Save()
    Write-Host "Start Menu shortcut created at: $shortcutPath"
}

Test-InstallState -InstallDir $installDir -TaskName $taskName -ShortcutPath $shortcutPath
Write-Host 'Install complete.'