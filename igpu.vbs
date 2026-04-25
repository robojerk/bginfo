'=============================================================================
' Integrated GPU Info Script for BGInfo
'=============================================================================
' Description: This script gets the integrated GPU name (Intel/AMD)
'=============================================================================

On Error Resume Next

' Connect to WMI
Set wmi = GetObject("winmgmts:\\.\root\cimv2")
If Err.Number <> 0 Then
    Echo "N/A"
    WScript.Quit 1
End If

' Get iGPU info - look for Intel or AMD integrated graphics
Set gpus = wmi.ExecQuery("SELECT Name FROM Win32_VideoController WHERE " & _
    "Name LIKE '%Intel%' OR " & _
    "Name LIKE '%AMD Radeon Graphics%' OR " & _
    "Name LIKE '%AMD Radeon(TM) Graphics%' OR " & _
    "Name LIKE '%AMD Ryzen%'")

' Get iGPU name
gpuName = "N/A"
For Each gpu In gpus
    If Not IsNull(gpu.Name) Then
        gpuName = gpu.Name
        Exit For
    End If
Next
Echo gpuName

' Clean up
Set gpus = Nothing
Set wmi = Nothing