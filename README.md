# BGInfo Custom Scripts

Small set of custom scripts for Microsoft Sysinternals BGInfo.

These scripts return one line of output each so BGInfo can display system and network details on the desktop background.

## Included Scripts

- `cpuname.vbs` - First CPU model name.
- `gpu.vbs` - Dedicated GPU name (NVIDIA/AMD match).
- `igpu.vbs` - Integrated GPU name (Intel/AMD iGPU match).
- `ram.vbs` - Total installed memory in GB.
- `osversion.vbs` - Windows edition + display version.
- `hdinfo.vbs` - Fixed drive free/total space (multiple output styles).
- `ipaddr.vbs` - IPv4 address with connection type hint (`wired`/`wifi`).
- `networkspeed.vbs` - Link speed for selected active adapter.
- `mac.vbs` - MAC address of the first active adapter with IPv4.
- `sshstatus.vbs` - OpenSSH server service state.
- `Enable-BGInfoAutostart.ps1` - Registers BGInfo task at logon.

## Network Adapter Selection

- `ipaddr.vbs`, `networkspeed.vbs`, and `mac.vbs` all auto-detect the first active adapter with IPv4.
- No external `mac` file is required.

## Requirements

- Windows with WMI available.
- BGInfo installed (`bginfo.exe`).
- Scripts configured as custom fields inside your `.bgi` file.

## Setup in BGInfo

1. Open BGInfo.
2. Create a Custom field for each script you want.
3. Use command pattern:
   - `cscript //nologo "C:\path\to\script.vbs"`
4. Place fields on your layout.
5. Save the configuration file (`.bgi`).

## Install

Quick install from GitHub:

- `irm "https://raw.githubusercontent.com/robojerk/bginfo/main/install.ps1" | iex`

Safer install flow (review script before execution):

- `$script = irm "https://raw.githubusercontent.com/robojerk/bginfo/main/install.ps1"`
- `$script`
- `iex $script`

What `install.ps1` does:

- Copies `.vbs` scripts to `~/.bginfo`
- Copies `README.md`, `Validate-Scripts.ps1`, and `steam_gear.jpg`
- Copies `config.bgi` if present
- Verifies BGInfo install (winget/chocolatey/manual paths)
- Installs BGInfo with `winget` if it is missing
- Registers BGInfo scheduled task at logon
- Creates Start Menu shortcut for manual runs
- Runs a quick post-install verification (task, shortcut, copied files)

Useful install modes:

- Preview changes: `.\install.ps1 -WhatIf`
- Prompt for each change: `.\install.ps1 -Confirm`
- Uninstall task + shortcut: `.\install.ps1 -Uninstall`
- Uninstall and remove `~/.bginfo`: `.\install.ps1 -Uninstall -RemoveInstallDir`

## Optional Autostart Task

`Enable-BGInfoAutostart.ps1` creates a scheduled task named `BGInfo` that runs at user logon.

Before running it, verify paths in the script match your machine:

- BGInfo executable path
- BGInfo config path (`.bgi`)

Run in PowerShell:

- `powershell -ExecutionPolicy Bypass -File .\Enable-BGInfoAutostart.ps1`

## Notes

- BGInfo is a legacy utility and out of the box it is not great at surfacing the most useful details for modern PCs.
- These scripts make BGInfo more practical today by pulling modern system/network metrics (for example current adapter/IP data, modern Windows version info, and clearer hardware fields).
- Scripts are designed to emit simple single-line output for BGInfo consumption.
- Scripts include `N/A` fallbacks so BGInfo fields do not silently go blank.
- Output formatting is standardized with consistent unit spacing (for example `GB`, `Mb/s`, `Gb/s`).
- If output is blank, run the script manually with `cscript //nologo` to troubleshoot.
- `osversion.vbs` uses WMI + registry (no `wmic.exe` dependency).

## Validation

Run all VBScript fields once with:

- `powershell -ExecutionPolicy Bypass -File .\Validate-Scripts.ps1`
