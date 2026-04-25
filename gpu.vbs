'=============================================================================
' GPU Info Script for BGInfo
'=============================================================================
' Description: This script gets the dedicated GPU name, ignoring integrated GPUs
'=============================================================================

On Error Resume Next

' Connect to WMI
Set wmi = GetObject("winmgmts:\\.\root\cimv2")

' Get GPU info - look for NVIDIA or AMD GPUs
Set gpus = wmi.ExecQuery("SELECT Name FROM Win32_VideoController WHERE Name LIKE '%NVIDIA%' OR Name LIKE '%AMD%' OR Name LIKE '%Radeon%'")

' Get GPU name
For Each gpu In gpus
    If Not IsNull(gpu.Name) Then
        Echo gpu.Name
        Exit For
    End If
Next

' Clean up
Set gpus = Nothing
Set wmi = Nothing