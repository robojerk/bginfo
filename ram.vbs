'=============================================================================
' Show RAM Info Script for BGInfo in GB
'=============================================================================
' Description: This script gets the total installed physical RAM and displays
' it in gigabytes (GB)
'=============================================================================

On Error Resume Next

' Connect to WMI
Set wmi = GetObject("winmgmts:\\.\root\cimv2")
If Err.Number <> 0 Then
    Echo "N/A"
    WScript.Quit 1
End If

' Get total physical memory in bytes
Set computer = wmi.ExecQuery("SELECT TotalPhysicalMemory FROM Win32_ComputerSystem")
result = "N/A"

' Convert to GB and display
For Each system In computer
    If Not IsNull(system.TotalPhysicalMemory) Then
        ' Convert bytes to GB and round to 2 decimal places
        ramGB = Round(system.TotalPhysicalMemory / 1024 / 1024 / 1024, 0)
        result = ramGB & " GB"
        Exit For
    End If
Next
Echo result

' Clean up
Set computer = Nothing
Set wmi = Nothing