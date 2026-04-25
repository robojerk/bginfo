$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$cscript = Join-Path $env:SystemRoot "System32\cscript.exe"

if (-not (Test-Path $cscript)) {
    throw "cscript.exe not found at $cscript"
}

$scripts = Get-ChildItem -Path $scriptDir -Filter "*.vbs" | Sort-Object Name

if (-not $scripts) {
    Write-Host "No .vbs scripts found."
    exit 0
}

$failed = $false
foreach ($script in $scripts) {
    Write-Host ("`n=== {0} ===" -f $script.Name)
    & $cscript //nologo $script.FullName
    if ($LASTEXITCODE -ne 0) {
        $failed = $true
        Write-Host ("ExitCode: {0}" -f $LASTEXITCODE)
    }
}

if ($failed) {
    Write-Host "`nValidation completed with failures."
    exit 1
}

Write-Host "`nValidation completed successfully."
